import React, { useState, useCallback } from 'react';
import TransactionList from './TransactionList';
import TransactionForm from './TransactionForm';
import RuleManager from './RuleManager';
import Navigation from './Navigation';
import './App.css';

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
    } catch {
      setStatus({ error: 'Network error.' });
    }
  };

  return (
    <form onSubmit={handleSubmit} className="csv-import-form">
      <h3>Import Transactions from CSV</h3>
      <input type="file" accept=".csv,text/csv" onChange={handleFileChange} />
      <button type="submit">Upload</button>
      {status?.error && <div className="status-error">{status.error}</div>}
      {status?.success && <div className="status-success">{status.success}</div>}
    </form>
  );
}

function App() {
  const [refreshFlag, setRefreshFlag] = useState(0);
  const [page, setPage] = useState('transactions');
  const refreshTransactions = useCallback(() => setRefreshFlag(f => f + 1), []);

  return (
    <div className="app-container">
      <Navigation page={page} setPage={setPage} />
      <div className="app-card">
        {page === 'transactions' && <>
          <TransactionList refreshFlag={refreshFlag} />
          <TransactionForm onSuccess={refreshTransactions} />
          <CsvImportForm onSuccess={refreshTransactions} />
        </>}
        {page === 'rules' && <RuleManager />}
      </div>
    </div>
  );
}

export default App;
