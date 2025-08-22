import React, { useState, useCallback } from 'react';
import TransactionList from './TransactionList';
import TransactionForm from './TransactionForm';


function App() {
  const [refreshFlag, setRefreshFlag] = useState(0);
  const refreshTransactions = useCallback(() => setRefreshFlag(f => f + 1), []);

  return (
    <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'flex-start', paddingTop: 40 }}>
      <div style={{ margin: '0 auto', background: '#fff', borderRadius: 12, boxShadow: '0 2px 8px #0001', padding: 24 }}>
        <TransactionList refreshFlag={refreshFlag} />
        <TransactionForm onSuccess={refreshTransactions} />
      </div>
    </div>
  );
}

export default App
