import React, { useEffect, useState } from "react";

export default function TransactionList({ refreshFlag }) {
  const [transactions, setTransactions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    async function fetchTransactions() {
      setLoading(true);
      setError(null);
      try {
        const res = await fetch("/api/v1/transactions");
        if (!res.ok) throw new Error("Failed to fetch");
        const data = await res.json();
        setTransactions(data);
      } catch (err) {
        setError("Could not load transactions");
      } finally {
        setLoading(false);
      }
    }
    fetchTransactions();
  }, [refreshFlag]);

  if (loading) return <div>Loading transactions...</div>;
  if (error) return <div style={{ color: "red" }}>{error}</div>;
  if (transactions.length === 0) return <div>No transactions found.</div>;

  return (
    <div style={{ maxWidth: 600, margin: "2rem auto" }}>
      <h2>Transactions</h2>
  <table style={{ width: "100%", borderCollapse: "collapse" }}>
        <thead>
          <tr>
            <th style={{ borderBottom: "1px solid #ccc", padding: '8px 12px' }}>Date</th>
            <th style={{ borderBottom: "1px solid #ccc", padding: '8px 12px' }}>Description</th>
            <th style={{ borderBottom: "1px solid #ccc", padding: '8px 12px' }}>Amount</th>
            <th style={{ borderBottom: "1px solid #ccc", padding: '8px 12px' }}>Category</th>
          </tr>
        </thead>
        <tbody>
          {transactions.map(tx => (
            <tr key={tx.id}>
              <td style={{ padding: '8px 12px' }}>{tx.date ? new Date(tx.date).toLocaleDateString() : ''}</td>
              <td style={{ padding: '8px 12px' }}>{tx.description}</td>
              <td style={{ padding: '8px 12px' }}>{tx.amount}</td>
              <td style={{ padding: '8px 12px' }}>{tx.category}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
