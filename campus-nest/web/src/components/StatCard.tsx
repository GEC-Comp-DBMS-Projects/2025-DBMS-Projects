import React from "react";
import { LucideIcon } from "lucide-react";

type StatCardProps = {
  title: string;
  value: string | number;
  icon: LucideIcon;
  color: string; // e.g., "text-green-500"
};

export default function StatCard({ title, value, icon: Icon, color }: StatCardProps) {
  return (
    <div className="bg-white p-6 rounded-2xl shadow-lg border border-gray-200/50">
      <div className="flex items-start gap-4">
        <div className={`p-3 rounded-lg bg-opacity-10 ${color.replace("text-", "bg-")}`}>
          <Icon size={24} className={color} />
        </div>
        <div>
          <p className="text-sm font-semibold text-gray-500">{title}</p>
          <p className="text-3xl font-bold text-[#21464E]">{value}</p>
        </div>
      </div>
    </div>
  );
}