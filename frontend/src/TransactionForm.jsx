import React, { useState } from "react";

const today = new Date().toISOString().slice(0, 10);
const initialState = {
  description: "",
  amount: "",
  category: "",
  date: today,
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
        date: form.date,
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
    } catch {
      setStatus({ error: "Network error" });
    }
  };

  return (
    <form onSubmit={handleSubmit} className="form-container">
      <h2>Add Transaction</h2>
      <div>
        <label>Description<br />
          <input name="description" value={form.description} onChange={handleChange} />
        </label>
      </div>
      <div>
        <label>Amount<br />
          <input name="amount" type="number" step="0.01" value={form.amount} onChange={handleChange} />
        </label>
      </div>
      <div>
        <label>Date<br />
          <input name="date" type="date" value={form.date} onChange={handleChange} />
        </label>
      </div>
      <div>
        <label>Category<br />
          <input name="category" value={form.category} onChange={handleChange} />
        </label>
      </div>
      <div>
        <label>Metadata (JSON, optional)<br />
          <input name="metadata" value={form.metadata} onChange={handleChange} placeholder='{"source":"manual"}' />
        </label>
      </div>
      <button type="submit" className="submit-button">Add</button>
      {status?.success && <div className="status-success">{status.success}</div>}
      {status?.error && <div className="status-error">{status.error}</div>}
    </form>
  );
}
