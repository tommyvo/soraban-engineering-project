import React, { useState, useCallback } from 'react';
import TransactionList from './TransactionList';
import TransactionForm from './TransactionForm';

function CsvImportForm({ onSuccess }) {
  const [file, setFile] = useState(null);
  const [status, setStatus] = useState(null);

  const handleFileChange = (e) => {
    setFile(e.target.files[0]);
    setStatus(null);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setStatus(null);
    if (!file) {
      setStatus({ error: 'Please select a CSV file.' });
      return;
    }
    const formData = new FormData();
    formData.append('csv', file);
    try {
      const res = await fetch('/api/v1/csv_imports', {
        method: 'POST',
        body: formData
      });
      if (!res.ok) {
        const err = await res.json();
        setStatus({ error: err.error || 'Upload failed.' });
        return;
      }
      setStatus({ success: 'CSV uploaded and import started.' });
      setFile(null);
      if (onSuccess) onSuccess();
    } catch (err) {
      setStatus({ error: 'Network error.' });
    }
  };

  return (
    <form onSubmit={handleSubmit} style={{ marginBottom: 24 }}>
      <h3>Import Transactions from CSV</h3>
      <input type="file" accept=".csv,text/csv" onChange={handleFileChange} />
      <button type="submit" style={{ marginLeft: 8 }}>Upload</button>
      {status?.error && <div style={{ color: 'red', marginTop: 8 }}>{status.error}</div>}
      {status?.success && <div style={{ color: 'green', marginTop: 8 }}>{status.success}</div>}
    </form>
  );
}

function App() {
  const [refreshFlag, setRefreshFlag] = useState(0);
  const refreshTransactions = useCallback(() => setRefreshFlag(f => f + 1), []);

  return (
    <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'flex-start', paddingTop: 40 }}>
      <div style={{ margin: '0 auto', background: '#fff', borderRadius: 12, boxShadow: '0 2px 8px #0001', padding: 24 }}>
        <TransactionList refreshFlag={refreshFlag} />
        <TransactionForm onSuccess={refreshTransactions} />
        <CsvImportForm onSuccess={refreshTransactions} />
      </div>
    </div>
  );
}

export default App;
