// components/charts/TopCompaniesChart.tsx
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

const montserrat = Montserrat({ subsets: ["latin"] });

const chartColors = {
  primary: "#5D9493",
  dark: "#21464E",
  gray: "#A1B5B7",
};

export default function TopCompaniesChart({ data }: { data: any[] }) {
  const [isClient, setIsClient] = useState(false);
  useEffect(() => setIsClient(true), []);

  if (!isClient) {
    return <div className="w-full h-96 flex items-center justify-center text-gray-500">Loading Chart...</div>;
  }
  
  // Get top 5 companies
  const top5Data = data.sort((a, b) => b.jobDriveCount - a.jobDriveCount).slice(0, 5);

  return (
    <div className="bg-light p-6 rounded-2xl shadow-md h-96">
      <h3 className="text-lg font-bold text-black mb-4">
        Companies by Job Drives
      </h3>
      <ResponsiveContainer width="100%" height="90%">
        <BarChart
          data={top5Data}
          layout="vertical"
          margin={{ top: 5, right: 10, left: 60, bottom: 0 }}
        >
          <CartesianGrid strokeDasharray="3 3" stroke={chartColors.gray} strokeOpacity={0.2} />
          <XAxis type="number" stroke={chartColors.gray} fontSize={12} allowDecimals={false} />
          <YAxis
            dataKey="companyName"
            type="category"
            stroke={chartColors.gray}
            fontSize={12}
            width={80} // Give space for company names
            fontFamily={montserrat.style.fontFamily}
          />
          <Tooltip
            contentStyle={{
              backgroundColor: chartColors.dark,
              borderRadius: "0.5rem",
              fontFamily: montserrat.style.fontFamily,
            }}
            labelStyle={{ color: "#ffffff" }}
            itemStyle={{ color: chartColors.primary }}
          />
          <Bar
            dataKey="jobDriveCount"
            name="Job Drives"
            fill={chartColors.primary}
            radius={[0, 6, 6, 0]}
            isAnimationActive={true}
            barSize={10}
          />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}