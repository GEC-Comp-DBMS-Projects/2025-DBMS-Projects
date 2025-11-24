// app/admin/layout.tsx
import React from "react";
import Sidebar from "@/components/Sidebar";
import Header from "@/components/Header";

// This layout wraps all your admin pages
export default function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex h-screen bg-[#F8F9F9]">
      <Sidebar />
      <div className="flex-1 flex flex-col overflow-hidden">
        
        {/* Main Content Area */}
        <main className="flex-1 overflow-y-auto bg-theme-gradient from-[#EBFBFA] via-[#EBFBFA] to-[#D6F5F4]">
          <Header />
          <div className="p-6">{children}</div>
        </main>
      </div>
    </div>
  );
}