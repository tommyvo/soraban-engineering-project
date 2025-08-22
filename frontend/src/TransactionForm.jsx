import React, { useState } from "react";

const initialState = {
  description: "",
  amount: "",
  category: "",
  metadata: ""
};

export default function TransactionForm({ onSuccess }) {
  const [form, setForm] = useState(initialState);
  const [status, setStatus] = useState(null);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setStatus(null);
    let metadataObj = {};
    try {
      metadataObj = form.metadata ? JSON.parse(form.metadata) : {};
    } catch {
      setStatus({ error: "Metadata must be valid JSON" });
      return;
    }
    const payload = {
      transaction: {
        description: form.description,
        amount: form.amount,
        category: form.category,
        metadata: metadataObj
      }
    };
    try {
      const res = await fetch("/api/v1/transactions", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload)
      });
      const data = await res.json();
      if (res.ok) {
        setStatus({ success: "Transaction added!" });
        setForm(initialState);
        if (onSuccess) onSuccess();
      } else {
        setStatus({ error: data.errors?.join(", ") || "Error" });
      }
    } catch (err) {
      setStatus({ error: "Network error" });
    }
  };

  return (
    <form onSubmit={handleSubmit} style={{ maxWidth: 400, margin: "2rem auto", padding: 24, border: "1px solid #ccc", borderRadius: 8 }}>
      <h2>Add Transaction</h2>
      <div>
        <label>Description<br />
          <input name="description" value={form.description} onChange={handleChange} required />
        </label>
      </div>
      <div>
        <label>Amount<br />
          <input name="amount" type="number" step="0.01" value={form.amount} onChange={handleChange} required />
        </label>
      </div>
      <div>
        <label>Category<br />
          <input name="category" value={form.category} onChange={handleChange} required />
        </label>
      </div>
      <div>
        <label>Metadata (JSON, optional)<br />
          <input name="metadata" value={form.metadata} onChange={handleChange} placeholder='{"source":"manual"}' />
        </label>
      </div>
      <button type="submit" style={{ marginTop: 16 }}>Add</button>
      {status?.success && <div style={{ color: "green", marginTop: 8 }}>{status.success}</div>}
      {status?.error && <div style={{ color: "red", marginTop: 8 }}>{status.error}</div>}
    </form>
  );
}
