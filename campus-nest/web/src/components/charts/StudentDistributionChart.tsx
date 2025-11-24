// components/charts/StudentDistributionChart.tsx
"use client";
import React, { useEffect, useState } from "react";
import { PieChart, Pie, Cell, Tooltip, ResponsiveContainer, Legend } from "recharts";
import { Montserrat } from "next/font/google";

const montserrat = Montserrat({ subsets: ["latin"] });

const chartColors = {
  primary: "#5D9493",
  secondary: "#8CA1A4",
  dark: "#21464E",
  gray: "#A1B5B7",
  orange: "#F39C12",
  purple: "#8E44AD",
};

const COLORS = [chartColors.primary, chartColors.orange, chartColors.purple, chartColors.secondary];

export default function StudentDistributionChart({ data }: { data: any[] }) {
  // Client-side guard to prevent hydration mismatch
  const [isClient, setIsClient] = useState(false);
  useEffect(() => setIsClient(true), []);

  if (!isClient) {
    return <div className="w-full h-full flex items-center justify-center text-gray">Loading Chart...</div>;
  }
  
  return (
    <div className="bg-light p-6 rounded-2xl shadow-md h-96">
      <h3 className="text-lg font-bold text-dark mb-4">
        Student Distribution
      </h3>
      <ResponsiveContainer width="100%" height="90%">
        <PieChart>
          <Pie
            data={data}
            dataKey="count"
            nameKey="department"
            cx="50%"
            cy="50%"
            outerRadius={100}
            fill="#8884d8"
            isAnimationActive={true}
          >
            {data.map((entry, index) => (
              <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
            ))}
          </Pie>
          <Tooltip
            contentStyle={{
              backgroundColor: chartColors.dark,
              borderRadius: "0.5rem",
              fontFamily: montserrat.style.fontFamily,
            }}
            labelStyle={{ color: "#ffffff" }}
          />
          <Legend
            wrapperStyle={{
              fontSize: "12px",
              fontFamily: montserrat.style.fontFamily,
              color: chartColors.dark,
            }}
          />
        </PieChart>
      </ResponsiveContainer>
    </div>
  );
}