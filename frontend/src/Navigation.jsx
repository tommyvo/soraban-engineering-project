import React from "react";

export default function Navigation({ page, setPage }) {
  return (
    <nav style={{ marginBottom: 24 }}>
      <button onClick={() => setPage("transactions")}>Transactions</button>
      <button onClick={() => setPage("rules")}>Rules</button>
      <button onClick={() => setPage("review")}>Review</button>
    </nav>
  );
}
