"use client";

import React, { useState, useMemo } from "react";
import Link from "next/link";
import { Users, Search, UserPlus } from "lucide-react";

export default function TpoClientPage({ allTpos }: { allTpos: any[] }) {
  const [searchQuery, setSearchQuery] = useState("");

  const filteredTpos = useMemo(() => {
    const query = searchQuery.toLowerCase();
    if (!query) return allTpos;

    return allTpos.filter((tpo) => {
      const name = `${tpo.firstName || ""} ${tpo.lastName || ""}`.toLowerCase();
      const email = (tpo.email || "").toLowerCase();
      const department = (tpo.department || "").toLowerCase();
      return name.includes(query) || email.includes(query) || department.includes(query);
    });
  }, [allTpos, searchQuery]);

  return (
    <div className="flex flex-col gap-6">
      {/* --- Header --- */}
      <div className="flex justify-between items-center mb-2">
        <div>
          <h1 className="text-3xl font-bold text-[#21464E]">TPO Management</h1>
          <p className="text-gray-500 mt-2">
            View, add, or manage TPO accounts.
          </p>
        </div>
        <Link
          href="/admin/tpos/add"
          className="flex items-center gap-2 py-3 px-4 rounded-lg text-white bg-[#5D9493] hover:bg-[#21464E] transition-all"
        >
          <UserPlus size={18} />
          <span className="font-semibold">Add New TPO</span>
        </Link>
      </div>

      {/* --- Search Bar --- */}
      <div className="relative">
        <input
          type="text"
          placeholder="Search by name, email, or department..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="w-full pl-10 pr-4 py-3 bg-white border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#5D9493]"
        />
        <Search
          className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"
          size={20}
        />
      </div>

      {/* --- TPO List --- */}
      <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
        <div className="flex flex-col divide-y divide-gray-100">
          {filteredTpos.length > 0 ? (
            filteredTpos.map((tpo) => (
              <TpoCard key={tpo.id} tpo={tpo} />
            ))
          ) : (
            <p className="text-gray-500 text-center py-10">
              No TPOs found that match your search.
            </p>
          )}
        </div>
      </div>
    </div>
  );
}

// --- Individual TPO Card ---
function TpoCard({ tpo }: { tpo: any }) {
  const name = `${tpo.firstName || ""} ${tpo.lastName || ""}`;
  const initial = (tpo.firstName?.[0] || "T").toUpperCase();

  return (
    <div className="flex items-center gap-4 py-4">
      <div className="w-12 h-12 rounded-full bg-[#5D9493]/10 flex items-center justify-center">
        <span className="text-xl font-bold text-[#5D9493]">{initial}</span>
      </div>
      <div className="flex-1">
        <p className="font-semibold text-[#21464E]">{name}</p>
        <p className="text-sm text-gray-500">{tpo.email}</p>
      </div>
      <span className="text-sm font-medium text-gray-600 bg-gray-100 px-3 py-1 rounded-full">
        {tpo.department || "N/A"}
      </span>
    </div>
  );
}
