import React, { useState, useEffect, useRef } from "react";
import { subscribeToTransactions } from "./transactions_subscription";
import ReactPaginate from 'react-paginate';
function ReviewPage() {
  const [transactions, setTransactions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [editingId, setEditingId] = useState(null);
  const [editData, setEditData] = useState({});
  const [page, setPage] = useState(0); // 0-based for react-paginate
  const [totalPages, setTotalPages] = useState(1);
  const transactionsRef = useRef();
  transactionsRef.current = transactions;

  // Helper to fetch flagged transactions
  const fetchFlagged = async (pageOverride) => {
    setLoading(true);
    setError(null);
    try {
      const res = await fetch(`/api/v1/flagged_transactions?page=${(pageOverride ?? page)+1}`);
      if (!res.ok) throw new Error("Failed to fetch");
      const data = await res.json();
      setTransactions(data.transactions || []);
      setTotalPages(data.total_pages || 1);
    } catch {
      setError("Could not load flagged transactions");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchFlagged();
    // eslint-disable-next-line
  }, [page]);

  // Live updates via ActionCable
  useEffect(() => {
    const sub = subscribeToTransactions({
      onCreate: (txn) => {
        if (Array.isArray(txn.anomalies) && txn.anomalies.length > 0 &&
          !transactionsRef.current.some(t => t.id === txn.id)) {
          setTransactions(prev => [txn, ...prev]);
        }
      },
      onUpdate: (txn) => {
        setTransactions(prev => {
          if (Array.isArray(txn.anomalies) && txn.anomalies.length > 0) {
            return prev.map(t => t.id === txn.id ? txn : t);
          } else {
            return prev.filter(t => t.id !== txn.id);
          }
        });
      },
      onDestroy: (id) => {
        setTransactions(prev => prev.filter(t => t.id !== id));
      },
      onBulkRefresh: fetchFlagged
    });
    return () => {
      if (sub) sub.unsubscribe();
    };
  }, []);

  const startEdit = (tx) => {
    setEditingId(tx.id);
    setEditData({...tx});
  };

  const cancelEdit = () => {
    setEditingId(null);
    setEditData({});
  };

  const handleEditChange = (e) => {
    setEditData({...editData, [e.target.name]: e.target.value});
  };

  const saveEdit = async () => {
    try {
      const res = await fetch(`/api/v1/transactions/${ editingId }`, {
        method: "PUT",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify(editData)
      });
      if (!res.ok) throw new Error("Update failed");
      // refetch the updated transaction to check anomalies
      const updatedRes = await fetch(`/api/v1/transactions/${ editingId }`);
      if (!updatedRes.ok) throw new Error("Failed to fetch updated transaction");
      const updatedTx = await updatedRes.json();
      setTransactions(txs => {
        if (Array.isArray(updatedTx.anomalies) && updatedTx.anomalies.length === 0) {
          // remove from list if no anomalies
          return txs.filter(tx => tx.id !== editingId);
        } else {
          // update in place
          return txs.map(tx => tx.id === editingId ? {...tx, ...updatedTx} : tx);
        }
      });
      cancelEdit();
    } catch {
      alert("Failed to update transaction");
    }
  };

  const deleteTx = async (id) => {
    try {
      const res = await fetch(`/api/v1/transactions/${ id }`, {method: "DELETE"});
      if (!res.ok) throw new Error("Delete failed");
      setTransactions(txs => txs.filter(tx => tx.id !== id));
    } catch {
      alert("Failed to delete transaction");
    }
  };

  const confirmAndDelete = (id) => {
    if (window.confirm("Are you sure you want to delete this transaction? This action cannot be undone.")) {
      deleteTx(id);
    }
  };

  const approveTx = async (id) => {
    try {
      const res = await fetch(`/api/v1/transactions/${ id }/approve`, {method: "POST"});
      if (!res.ok) throw new Error("Approve failed");
      setTransactions(txs => txs.filter(tx => tx.id !== id));
    } catch {
      alert("Failed to approve transaction");
    }
  };

  if (loading) return <div>Loading flagged transactions...</div>;
  if (error) return <div style={ {color: "red"} }>{ error }</div>;
  if (transactions.length === 0) return <div>No flagged transactions found.</div>;

  return (
    <div className="review-container">
      <h2>Review Flagged Transactions</h2>
      <table className="transaction-table review-table">
        <thead>
        <tr>
          <th>Date</th>
          <th>Description</th>
          <th>Amount</th>
          <th>Category</th>
          <th>Anomalies</th>
          <th>Actions</th>
        </tr>
        </thead>
        <tbody>
        { transactions.map(tx => (
          <tr key={ tx.id }>
            { editingId === tx.id ? (
              <>
                <td colSpan={ 6 } style={ {padding: 0} }>
                  <div className="edit-row-flex">
                    <input name="date" type="date" value={ editData.date || '' }
                      onChange={ handleEditChange } className="edit-input" />
                    <input name="description"
                      value={ editData.description || '' }
                      onChange={ handleEditChange } className="edit-input" />
                    <input name="amount" type="number"
                      value={ editData.amount || '' }
                      onChange={ handleEditChange } className="edit-input" />
                    <input name="category" value={ editData.category || '' }
                      onChange={ handleEditChange } className="edit-input" />
                    <div className="review-actions-col">
                      <button onClick={ saveEdit }
                        className="review-btn save">Update
                      </button>
                      <button onClick={ cancelEdit }
                        className="review-btn cancel">Cancel
                      </button>
                    </div>
                  </div>
                </td>
              </>
            ) : (
              <>
                <td>{ tx.date ? new Date(tx.date).toLocaleDateString() : '' }</td>
                <td>{ tx.description }</td>
                <td>{ tx.amount }</td>
                <td>{ tx.category }</td>
                <td>
                  { Array.isArray(tx.anomalies) && tx.anomalies.length > 0 ? (
                    <ul className="anomaly-list">
                      { tx.anomalies.map(anom => (
                        <li key={ anom.id }>{ anom.reason }</li>
                      )) }
                    </ul>
                  ) : <span className="anomaly-none">None</span> }
                </td>
                <td>
                  <div className="review-actions-col">
                    <button onClick={ () => approveTx(tx.id) }
                      className="review-btn approve">Approve
                    </button>
                    <button onClick={ () => startEdit(tx) }
                      className="review-btn edit">Edit
                    </button>
                    <button onClick={ () => confirmAndDelete(tx.id) }
                      className="review-btn delete">Delete
                    </button>
                  </div>
                </td>
              </>
            ) }
          </tr>
        )) }
        </tbody>
      </table>
      <div style={{ margin: '1rem 0', display: 'flex', justifyContent: 'center' }}>
        <ReactPaginate
          previousLabel={" Prev"}
          nextLabel={"Next "}
          breakLabel={"..."}
          pageCount={totalPages}
          marginPagesDisplayed={1}
          pageRangeDisplayed={3}
          onPageChange={({ selected }) => setPage(selected)}
          forcePage={page}
          containerClassName={"pagination"}
          activeClassName={"active"}
          disabledClassName={"disabled"}
        />
      </div>
    </div>
  );
}

export default ReviewPage;
