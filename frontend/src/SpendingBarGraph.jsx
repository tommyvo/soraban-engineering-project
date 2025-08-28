import React from 'react';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from 'recharts';

// summaryData: [{ date: 'YYYY-MM-DD', spending: number }]
export default function SpendingBarGraph({ summaryData }) {
  // Format for chart: { date: 'Aug 27', spending: 123 }
  const data = (summaryData || []).map(d => ({
    date: new Date(d.date).toLocaleDateString(undefined, { month: 'short', day: 'numeric' }),
    spending: d.spending
  }));

  return (
    <div style={{ width: '100%', height: 250, marginBottom: 32 }}>
      <h3>Spending Summary (last 7 days)</h3>
      <ResponsiveContainer width="100%" height={200}>
        <BarChart data={data} margin={{ top: 10, right: 20, left: 0, bottom: 0 }}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="date" />
          <YAxis />
          <Tooltip formatter={v => `$${v.toFixed(2)}`} />
          <Bar dataKey="spending" fill="#8884d8" />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}
