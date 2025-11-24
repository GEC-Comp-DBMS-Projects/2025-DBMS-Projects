"use client";
import React from "react";
import { Bell } from "lucide-react";

export default function Header() {
  return (
    <header className="flex items-center justify-end p-6 border-b border-gray-200 bg-white">
      <div className="flex items-center gap-4">
        <button className="text-gray-500 rounded-full p-2 hover:bg-gray-100">
          <Bell size={20} />
        </button>
        <div className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center font-bold text-[#21464E] border-2 border-gray-300">
          CN
        </div>
      </div>
    </header>
  );
}