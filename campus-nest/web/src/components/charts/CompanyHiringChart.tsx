// components/charts/CompanyHiringChart.tsx
"use client";
import React from "react";
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from "recharts";

export default function CompanyHiringChart({ data }: { data: any[] }) {
  // TODO: Update this chart once you know the data structure from your API
  
  return (
    <div className="bg-light p-6 rounded-2xl shadow-md h-96">
      <h3 className="text-lg font-bold text-dark mb-4">Top Hiring Companies</h3>
      <ResponsiveContainer width="100%" height="100%">
        <BarChart data={data} layout="vertical" margin={{ top: 5, right: 10, left: 60, bottom: 20 }}>
          <CartesianGrid strokeDasharray="3 3" stroke="#A1B5B7" strokeOpacity={0.2} />
          <XAxis type="number" stroke="#A1B5B7" fontSize={12} />
          <YAxis dataKey="companyName" type="category" stroke="#A1B5B7" fontSize={12} />
          <Tooltip />
          <Bar dataKey="hires" fill="#5D9493" radius={[0, 4, 4, 0]} />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}