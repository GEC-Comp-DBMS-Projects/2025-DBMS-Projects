// components/charts/TpoPerformanceChart.tsx
"use client";
import React, { useEffect, useState } from "react";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  CartesianGrid,
} from "recharts";
import { Montserrat } from "next/font/google";

// Use the same font
const montserrat = Montserrat({ subsets: ["latin"] });

// Define the chart colors
const chartColors = {
  primary: "#5D9493",
  dark: "#21464E",
  gray: "#A1B5B7",
};

export default function TpoPerformanceChart({ data }: { data: any[] }) {
  // Client-side guard to prevent hydration mismatch
  const [isClient, setIsClient] = useState(false);
  useEffect(() => setIsClient(true), []);

  if (!isClient) {
    return <div className="w-full h-full flex items-center justify-center text-gray">Loading Chart...</div>;
  }

  return (
    <div className="bg-light p-6 rounded-2xl shadow-md h-96">
      <h3 className="text-lg font-bold text-dark mb-4">
        Placement Rate by TPO
      </h3>
      <ResponsiveContainer width="100%" height="90%">
        <BarChart data={data} margin={{ top: 5, right: 0, left: 0, bottom: 20 }}>
          <CartesianGrid strokeDasharray="3 3" stroke={chartColors.gray} strokeOpacity={0.2} />
          <XAxis
            dataKey="name"
            stroke={chartColors.gray}
            fontSize={12}
            fontFamily={montserrat.style.fontFamily}
          />
          <YAxis
            stroke={chartColors.gray}
            fontSize={12}
            fontFamily={montserrat.style.fontFamily}
            tickFormatter={(tick) => `${tick}%`}
          />
          <Tooltip
            contentStyle={{
              backgroundColor: chartColors.dark,
              borderColor: chartColors.dark,
              borderRadius: "0.5rem",
              fontFamily: montserrat.style.fontFamily,
            }}
            labelStyle={{ color: "#ffffff" }}
            itemStyle={{ color: chartColors.primary }}
          />
          <Bar
            dataKey="placementRate"
            fill={chartColors.primary}
            radius={[4, 4, 0, 0]}
            isAnimationActive={true}
          />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}