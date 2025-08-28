import React, { useEffect, useState, useRef } from "react";
import ReactPaginate from 'react-paginate';
import './App.css';
import SpendingBarGraph from './SpendingBarGraph';

import { subscribeToTransactions } from './transactions_subscription';

export default function TransactionList({ refreshFlag }) {
  const [transactions, setTransactions] = useState([]);
  const [spendingSummary, setSpendingSummary] = useState([]); // For spending summary
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selected, setSelected] = useState([]);
  const [bulkCategory, setBulkCategory] = useState("");
  const [bulkStatus, setBulkStatus] = useState(null);
  const [page, setPage] = useState(0); // 0-based for react-paginate
  const [totalPages, setTotalPages] = useState(1);

  // Fetch transactions initially and on refresh/bulk update
  useEffect(() => {
    let ignore = false;
    async function fetchTransactions() {
      setLoading(true);
      setError(null);
      try {
        const res = await fetch(`/api/v1/transactions?page=${page+1}`); // Kaminari is 1-based
        if (!res.ok) throw new Error("Failed to fetch");
        const data = await res.json();
        if (!ignore) {
          setTransactions(data.transactions || []);
          setTotalPages(data.total_pages || 1);
        }
      } catch {
        if (!ignore) setError("Could not load transactions");
      } finally {
        if (!ignore) setLoading(false);
      }
    }

    // Fetch all transactions for the spending summary
    async function fetchSpendingSummary() {
      try {
        const res = await fetch('/api/v1/transactions/spending_summary');
        if (!res.ok) throw new Error('Failed to fetch spending summary');
        const data = await res.json();
        setSpendingSummary(data);
      } catch {
        // ignore error for summary
      }
    }

    fetchTransactions();
    fetchSpendingSummary();
    return () => { ignore = true; };
  }, [refreshFlag, bulkStatus, page]);

  // Real-time updates via ActionCable
  const transactionsRef = useRef();
  transactionsRef.current = transactions;

  // Helper to fetch transactions
  const fetchTransactions = async (pageOverride) => {
    setLoading(true);
    setError(null);
    try {
      const res = await fetch(`/api/v1/transactions?page=${(pageOverride ?? page)+1}`);
      if (!res.ok) throw new Error("Failed to fetch");
      const data = await res.json();
      setTransactions(data.transactions || []);
      setTotalPages(data.total_pages || 1);
      // Also refresh spending summary
      const summaryRes = await fetch('/api/v1/transactions/spending_summary');
      if (summaryRes.ok) {
        const summaryData = await summaryRes.json();
        setSpendingSummary(summaryData);
      }
    } catch {
      setError("Could not load transactions");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    const sub = subscribeToTransactions({
      onCreate: (txn) => {
        if (!transactionsRef.current.some(t => t.id === txn.id)) {
          fetchTransactions();
        }
      },
      onUpdate: (txn) => {
        fetchTransactions();
      },
      onDestroy: (id) => {
        fetchTransactions();
        setSelected(sel => sel.filter(x => x !== id));
      },
      onBulkRefresh: () => fetchTransactions()
    });
    return () => { if (sub) sub.unsubscribe(); };
    // eslint-disable-next-line
  }, []);

  const toggleSelect = id => {
    setSelected(sel =>
      sel.includes(id) ? sel.filter(x => x !== id) : [...sel, id]
    );
  };

  const selectAll = e => {
    if (e.target.checked) {
      setSelected(transactions.map(tx => tx.id));
    } else {
      setSelected([]);
    }
  };

  const handleBulkUpdate = async () => {
    setBulkStatus(null);

    if (!bulkCategory || selected.length === 0) {
      setBulkStatus({ error: "Select transactions and enter a category." });
      return;
    }

    try {
      const res = await fetch("/api/v1/transactions/bulk_update", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ ids: selected, category: bulkCategory })
      });

      if (!res.ok) throw new Error("Bulk update failed");

      setBulkStatus({ success: "Updated!" });
      setSelected([]);
      setBulkCategory("");
    } catch (err) {
      setBulkStatus({ error: err.message });
    }
  };

  if (loading) return <div>Loading transactions...</div>;
  if (error) return <div style={{ color: "red" }}>{error}</div>;
  if (transactions.length === 0) return <div>No transactions found.</div>;

  return (
    <div style={{ maxWidth: 600, margin: "2rem auto" }}>
      <SpendingBarGraph summaryData={spendingSummary} />
      <h2>Transactions</h2>
      <div style={{ marginBottom: 16 }}>
        <input
          type="text"
          placeholder="New category"
          value={bulkCategory}
          onChange={e => setBulkCategory(e.target.value)}
          style={{ marginRight: 8 }}
        />
        <button onClick={handleBulkUpdate} disabled={selected.length === 0 || !bulkCategory}>
          Bulk Categorize
        </button>
        {bulkStatus?.success && <span style={{ color: 'green', marginLeft: 8 }}>{bulkStatus.success}</span>}
        {bulkStatus?.error && <span style={{ color: 'red', marginLeft: 8 }}>{bulkStatus.error}</span>}
      </div>
      <table className="transaction-table" style={{ width: "100%", borderCollapse: "collapse" }}>
        <thead>
          <tr>
            <th>
              <input
                type="checkbox"
                checked={selected.length === transactions.length && transactions.length > 0}
                onChange={selectAll}
                aria-label="Select all"
              />
            </th>
            <th>Date</th>
            <th>Description</th>
            <th>Amount</th>
            <th>Category</th>
          </tr>
        </thead>
        <tbody>
          {transactions.map(tx => (
            <tr key={tx.id}>
              <td style={{ textAlign: 'center' }}>
                <input
                  type="checkbox"
                  checked={selected.includes(tx.id)}
                  onChange={() => toggleSelect(tx.id)}
                  aria-label={`Select transaction ${tx.id}`}
                />
              </td>
              <td>{tx.date || ''}</td>
              <td>{tx.description}</td>
              <td>{tx.amount}</td>
              <td>{tx.category}</td>
            </tr>
          ))}
        </tbody>
      </table>
      <div style={{ margin: '1rem 0', display: 'flex', justifyContent: 'center' }}>
        <ReactPaginate
          previousLabel={"← Prev"}
          nextLabel={"Next →"}
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
