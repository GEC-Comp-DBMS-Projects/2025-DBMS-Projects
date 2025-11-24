// components/charts/PlacementTimelineChart.tsx
"use client";
import React from "react";
import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from "recharts";

export default function PlacementTimelineChart({ data }: { data: any[] }) {
  // TODO: Update this chart once you know the data structure from your API
  
  return (
    <div className="bg-light p-6 rounded-2xl shadow-md h-96">
      <h3 className="text-lg font-bold text-dark mb-4">Placements Over Time</h3>
      <ResponsiveContainer width="100%" height="100%">
        <LineChart data={data} margin={{ top: 5, right: 10, left: -20, bottom: 20 }}>
          <CartesianGrid strokeDasharray="3 3" stroke="#A1B5B7" strokeOpacity={0.2} />
          <XAxis dataKey="month" stroke="#A1B5B7" fontSize={12} />
          <YAxis stroke="#A1B5B7" fontSize={12} />
          <Tooltip />
          <Line type="monotone" dataKey="placements" stroke="#5D9493" strokeWidth={3} />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}