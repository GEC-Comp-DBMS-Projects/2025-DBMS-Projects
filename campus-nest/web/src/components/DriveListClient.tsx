"use client";

import React, { useState, useMemo } from "react";
import Link from "next/link";
import { Briefcase, Building, MapPin, Search, Users } from "lucide-react";
import { format } from "date-fns";

export default function DriveListClient({ allDrives }: { allDrives: any[] }) {
    console.log(allDrives)
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState("All");

  const filteredDrives = useMemo(() => {
    return allDrives.filter((drive) => {
      const status = drive.status || "Unknown";
      if (statusFilter !== "All" && status.toLowerCase() !== statusFilter.toLowerCase()) {
        return false;
      }

      const query = searchQuery.toLowerCase();
      if (query) {
        const company = (drive.company_name?.name || "").toLowerCase();
        const position = (drive.position || "").toLowerCase();
        if (!company.includes(query) && !position.includes(query)) {
          return false;
        }
      }
      return true;
    });
  }, [allDrives, searchQuery, statusFilter]);

  return (
    <div className="flex flex-col gap-6">
      <div className="mb-2">
        <h1 className="text-3xl font-bold text-[#21464E]">Job Drives</h1>
        <p className="text-gray-500 mt-2">
          Browse and manage all active and past job drives.
        </p>
      </div>

      <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
        <div className="flex flex-col md:flex-row gap-4">
          <div className="flex-1 relative">
            <input
              type="text"
              placeholder="Search by company or position..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-3 text-black placeholder:text-gray-400 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#5D9493]"
            />
            <Search
              className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"
              size={20}
            />
          </div>
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#5D9493]"
          >
            <option value="All">All Statuses</option>
            <option value="Open">Open</option>
            <option value="Closed">Closed</option>
          </select>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredDrives.map((drive) => (
          <Link href={`/admin/drives/${drive._id}`} key={drive._id}>
            <div className="bg-white p-6 rounded-2xl shadow-lg border border-gray-100/50 hover:shadow-xl hover:border-[#5D9493]/50 transition-all cursor-pointer">
              <div className="flex items-center gap-4 mb-4">
                <div className="p-3 rounded-xl bg-[#5D9493]/10 text-[#5D9493]">
                  <Building size={24} />
                </div>
                <div>
                  <h3 className="text-lg font-bold text-[#21464E] leading-tight">
                    {drive.position}
                  </h3>
                  <p className="text-sm text-gray-600">
                    {drive.company_name?.name}
                  </p>
                </div>
              </div>
              <div className="space-y-2 text-sm text-gray-500">
                <div className="flex items-center gap-2">
                  <MapPin size={14} />
                  <span>{drive.location}</span>
                </div>
                <div className="flex items-center gap-2">
                  <Briefcase size={14} />
                  <span>{drive.salary_range}</span>
                </div>
                <div className="flex items-center gap-2">
                  <Users size={14} />
                  <span>{drive.totalApplications || 0} Applicants</span>
                </div>
              </div>
            </div>
          </Link>
        ))}
        {filteredDrives.length === 0 && (
          <p className="text-gray-500 col-span-3 text-center">
            No drives found that match your criteria.
          </p>
        )}
      </div>
    </div>
  );
}
