// components/admin/QuickActionsGrid.tsx
import Link from "next/link";
import React from "react";
import { Megaphone, Briefcase, UserPlus } from "lucide-react";

const actions = [
  { href: "/admin/announcements", label: "Send Announcement", icon: Megaphone, color: "bg-primary/10 text-primary" },
  { href: "/admin/companies", label: "Onboard Company", icon: Briefcase, color: "bg-purple-500/10 text-purple-500" },
  { href: "/admin/students", label: "Add Students", icon: UserPlus, color: "bg-orange-500/10 text-orange-500" },
];

export default function QuickActionsGrid() {
  return (
    <div className="bg-light p-6 rounded-2xl shadow-md h-full">
      <h3 className="text-lg font-bold text-dark mb-4">Quick Actions</h3>
      <div className="flex flex-col gap-3">
        {actions.map((action) => (
          <Link
            key={action.label}
            href={action.href}
            className="flex items-center gap-4 p-4 rounded-lg bg-gray-50 hover:bg-gray-100 transition-all"
          >
            <div className={`p-3 rounded-lg ${action.color}`}>
              <action.icon size={20} />
            </div>
            <span className="font-semibold text-dark">{action.label}</span>
          </Link>
        ))}
      </div>
    </div>
  );
}