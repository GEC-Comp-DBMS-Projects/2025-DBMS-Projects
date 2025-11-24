'use client';
import React, { useEffect, useState } from "react";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  CartesianGrid,
  TooltipProps,
} from "recharts";

const chartColors = {
  primary: "#5D9493",
  primaryHover: "#4A7978",
  gray: "#9CA3AF",
  gridStroke: "#f0f0f0",
};

export default function DepartmentPlacementChart({ data }: { data: any[] }) {
  const [isClient, setIsClient] = useState(false);

  useEffect(() => setIsClient(true), []);

  if (!isClient) {
    return (
      <div className="w-full h-96 flex items-center justify-center text-gray-500">
        Loading Chart...
      </div>
    );
  }

  const formatXAxis = (value: any): string => {
    const tick = Array.isArray(value) ? value.join(" ") : String(value);
    if (tick.includes("Information Technology")) return "IT";
    if (tick.includes("Computer Science")) return "CS";
    if (tick.includes("Electronics")) return "ETC";
    if (tick.includes("Mechanical")) return "Mech";
    return tick;
  };
  const CustomTooltip = ({ active, payload }: { active?: boolean; payload?: any[] }) => {
    if (active && payload && payload.length) {
      const entry = payload[0] as any;
      const department = entry.payload?.department;
      const value = typeof entry.value === "number" ? entry.value : Number(entry.value);

      return (
        <div
          style={{
            backgroundColor: "#fff",
            borderRadius: "10px",
            border: "1px solid #E5E7EB",
            padding: "12px 16px",
          }}
        >
          <p className="font-semibold text-sm text-gray-800 mb-1">
            {department}
          </p>
          <p className="text-lg font-bold" style={{ color: chartColors.primary }}>
            {value.toFixed(1)}%
          </p>
        </div>
      );
    }
    return null;
  };

  return (
    <div className="bg-white rounded-2xl shadow-sm p-6">
      <h2 className="text-xl font-semibold text-gray-800 mb-6">
        Placement Rate by Department
      </h2>

      <div className="w-full h-80">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart
            data={data}
            barGap={2}
            barCategoryGap="15%"
            margin={{ top: 10, right: 20, left: -10, bottom: 5 }}
          >
            <CartesianGrid
              strokeDasharray="3 3"
              vertical={false}
              stroke={chartColors.gridStroke}
            />
            <XAxis
              dataKey="department"
              tick={{ fill: chartColors.gray }}
              axisLine={false}
              tickLine={false}
              tickFormatter={formatXAxis}
            />
            <YAxis
              tick={{ fill: chartColors.gray }}
              axisLine={false}
              tickLine={false}
              tickFormatter={(tick) => `${tick}%`}
              domain={[0, 100]}
            />
            <Tooltip
              content={<CustomTooltip />}
              cursor={{ fill: "rgba(0, 0, 0, 0.05)" }}
            />
            <Bar
              dataKey="placementRate"
              fill={chartColors.primary}
              radius={[20, 20, 0, 0]}
              barSize={15}
              isAnimationActive={true}
              animationDuration={800}
            />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}