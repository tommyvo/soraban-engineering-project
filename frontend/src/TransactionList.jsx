import React, { useEffect, useState, useRef } from "react";
import './App.css';
import SpendingBarGraph from './SpendingBarGraph';

import { subscribeToTransactions } from './transactions_subscription';

export default function TransactionList({ refreshFlag }) {
  const [transactions, setTransactions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selected, setSelected] = useState([]);
  const [bulkCategory, setBulkCategory] = useState("");
  const [bulkStatus, setBulkStatus] = useState(null);

  // Fetch transactions initially and on refresh/bulk update
  useEffect(() => {
    let ignore = false;
    async function fetchTransactions() {
      setLoading(true);
      setError(null);
      try {
        const res = await fetch("/api/v1/transactions");
        if (!res.ok) throw new Error("Failed to fetch");
        const data = await res.json();
        if (!ignore) setTransactions(data);
      } catch {
        if (!ignore) setError("Could not load transactions");
      } finally {
        if (!ignore) setLoading(false);
      }
    }
    fetchTransactions();
    return () => { ignore = true; };
  }, [refreshFlag, bulkStatus]);

  // Real-time updates via ActionCable
  const transactionsRef = useRef();
  transactionsRef.current = transactions;
  // Helper to fetch transactions
  const fetchTransactions = async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await fetch("/api/v1/transactions");
      if (!res.ok) throw new Error("Failed to fetch");
      const data = await res.json();
      setTransactions(data);
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
          setTransactions(prev => [txn, ...prev]);
        }
      },
      onUpdate: (txn) => {
        setTransactions(prev => prev.map(t => t.id === txn.id ? txn : t));
      },
      onDestroy: (id) => {
        setTransactions(prev => prev.filter(t => t.id !== id));
        setSelected(sel => sel.filter(x => x !== id));
      },
      onBulkRefresh: fetchTransactions
    });
    return () => { if (sub) sub.unsubscribe(); };
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
      <SpendingBarGraph transactions={transactions} />
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
                checked={selected.length === transactions.length}
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
              <td>{tx.date ? new Date(tx.date).toLocaleDateString() : ''}</td>
              <td>{tx.description}</td>
              <td>{tx.amount}</td>
              <td>{tx.category}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
