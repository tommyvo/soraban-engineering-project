import React from "react";

export default function Navigation({ setPage, flaggedCount, transactionCount }) {
  return (
    <nav style={{ marginBottom: 24 }}>
      <button onClick={() => setPage("transactions")}>Transactions{typeof transactionCount === 'number' && transactionCount > 0 ? ` (${transactionCount})` : ''}</button>
      <button onClick={() => setPage("rules")}>Rules</button>
      <button onClick={() => setPage("review")}>
        Review{typeof flaggedCount === 'number' && flaggedCount > 0 ? ` (${flaggedCount})` : ''}
      </button>
    </nav>
  );
}
