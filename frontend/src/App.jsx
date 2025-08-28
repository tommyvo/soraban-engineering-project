import React, { useState, useCallback, useEffect } from 'react';
import TransactionList from './TransactionList';
import TransactionForm from './TransactionForm';
import RuleManager from './RuleManager';
import Navigation from './Navigation';
import ReviewPage from './ReviewPage';
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
  const [flaggedCount, setFlaggedCount] = useState(0);
  const refreshTransactions = useCallback(() => setRefreshFlag(f => f + 1), []);

  // Fetch flagged count
  const fetchFlaggedCount = useCallback(async () => {
    try {
      const res = await fetch('/api/v1/flagged_transactions?page=1&per_page=1');
      if (!res.ok) return;
      const data = await res.json();
      setFlaggedCount(data.total_count || 0);
    } catch {}
  }, []);

  // On mount and when review page is shown, or after bulk refresh
  useEffect(() => {
    fetchFlaggedCount();
  }, [fetchFlaggedCount, page, refreshFlag]);

  // Listen for ActionCable bulk_refresh to update flagged count
  useEffect(() => {
    // Lazy load to avoid import loop
    import('./transactions_subscription').then(({ subscribeToTransactions }) => {
      const sub = subscribeToTransactions({
        onBulkRefresh: fetchFlaggedCount
      });
      return () => { if (sub) sub.unsubscribe(); };
    });
  }, [fetchFlaggedCount]);

  return (
    <div className="app-container">
      <Navigation page={page} setPage={setPage} flaggedCount={flaggedCount} />
      <div className="app-card">
        {page === 'transactions' && <>
          <TransactionList refreshFlag={refreshFlag} />
          <TransactionForm onSuccess={refreshTransactions} />
          <CsvImportForm onSuccess={refreshTransactions} />
        </>}
        {page === 'rules' && <RuleManager />}
        {page === 'review' && <div className="app-card"><ReviewPage onFlaggedChange={fetchFlaggedCount} /> </div>}
      </div>
    </div>
  );
}

export default App;
