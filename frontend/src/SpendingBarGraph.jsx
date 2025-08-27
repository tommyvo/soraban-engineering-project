import React from 'react';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from 'recharts';

export default function SpendingBarGraph({ transactions }) {
  // Get today and last 6 days
  const days = [...Array(7)].map((_, i) => {
    const d = new Date();
    d.setDate(d.getDate() - (6 - i));
    return d;
  });

  // Sum spending per day
  const data = days.map(day => {
    const dayStr = day.toISOString().slice(0, 10);
    const total = transactions
      .filter(tx => tx.date && tx.amount && tx.amount > 0 && tx.date.slice(0, 10) === dayStr)
      .reduce((sum, tx) => sum + Number(tx.amount), 0);
    return {
      date: day.toLocaleDateString(undefined, { month: 'short', day: 'numeric' }),
      spending: total
    };
  });

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
