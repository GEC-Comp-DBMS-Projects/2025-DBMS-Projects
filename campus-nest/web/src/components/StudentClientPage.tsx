"use client";

import React, { useState, useMemo } from "react";
import Link from "next/link";
import { UserPlus, Upload, School, TrendingUp, Users } from "lucide-react";

export default function StudentClientPage({ allStudents, stats }: { allStudents: any[], stats: any }) {
  console.log(allStudents);
  console.log(stats)
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedFilter, setSelectedFilter] = useState("All");

  const placementRate = (stats.totalReturned > 0) 
    ? (stats.placed / stats.totalReturned * 100).toFixed(1) 
    : 0;

  const filteredStudents = useMemo(() => {
    let filtered = allStudents;

    if (selectedFilter === 'Placed') {
      filtered = filtered.filter((s) => s.placementStatus?.toLowerCase() === 'placed');
    } else if (selectedFilter === 'Unplaced') {
      filtered = filtered.filter((s) => s.placementStatus?.toLowerCase() !== 'placed');
    }

    const query = searchQuery.toLowerCase();
    if (query) {
      filtered = filtered.filter((s) => {
        const name = `${s.firstName || ''} ${s.lastName || ''}`.toLowerCase();
        const department = (s.department || '').toLowerCase();
        const rollNumber = (s.rollNumber || '').toLowerCase();
        return name.includes(query) || department.includes(query) || rollNumber.includes(query);
      });
    }
    
    return filtered;
  }, [allStudents, searchQuery, selectedFilter]);

  // --- UI ---
  return (
    <div className="flex flex-col h-full gap-4">
      <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
        <div className="flex justify-between items-center mb-4">
          <div>
            <h1 className="text-2xl font-bold text-[#21464E]">Student Directory</h1>
            <p className="text-gray-500">Search, filter, and manage all students.</p>
          </div>
          <div className="flex gap-4">
            <Link href="/admin/students/add-single" className="flex items-center gap-2 px-4 py-2 bg-[#5D9493]/10 text-[#5D9493] rounded-lg font-semibold hover:bg-[#5D9493]/20 transition-colors">
              <UserPlus size={18} />
              Add Student
            </Link>
            <Link href="/admin/students/upload-csv" className="flex items-center gap-2 px-4 py-2 bg-[#5D9493] text-white rounded-lg font-semibold hover:bg-[#21464E] transition-colors">
              <Upload size={18} />
              Upload CSV
            </Link>
          </div>
        </div>
        
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <StatBox icon={School} title="Total Students" value={stats.totalReturned || 0} color="text-purple-500" />
          <StatBox icon={TrendingUp} title="Placement Rate" value={`${placementRate}%`} color="text-green-500" />
          <StatBox icon={Users} title="Placed" value={stats.placed || 0} color="text-primary" />
          <StatBox icon={Users} title="Unplaced" value={stats.totalReturned - stats.placed || 0} color="text-red-500" />
        </div>
      </div>

      <div className="bg-white p-4 rounded-2xl shadow-sm border border-gray-100 flex items-center gap-4">
        <input
          type="text"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          placeholder="Search by name, department, or roll no..."
          className="flex-grow p-3 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#5D9493]"
        />
        <div className="flex gap-2">
          {['All', 'Placed', 'Unplaced'].map((filter) => (
            <FilterChip
              key={filter}
              label={filter}
              isSelected={selectedFilter === filter}
              onTap={() => setSelectedFilter(filter)}
            />
          ))}
        </div>
      </div>
      <div className="flex-1 overflow-y-auto space-y-4">
        {filteredStudents.length > 0 ? (
          filteredStudents.map((student) => (
            <StudentCard key={student.id} student={student} />
          ))
        ) : (
          <div className="text-center py-10">
            <p className="text-gray-500">No students found matching your criteria.</p>
          </div>
        )}
      </div>
    </div>
  );
}

function StatBox({ icon: Icon, title, value, color }: { icon: React.ElementType, title: string, value: string | number, color: string }) {
  return (
    <div className="bg-gray-50 p-4 rounded-lg border border-gray-100">
      <div className={`p-2 rounded-lg bg-opacity-10 ${color.replace("text-", "bg-")} w-fit mb-2`}>
        <Icon size={20} className={color} />
      </div>
      <p className="text-2xl font-bold text-[#21464E]">{value}</p>
      <p className="text-sm font-semibold text-gray-500">{title}</p>
    </div>
  );
}

function FilterChip({ label, isSelected, onTap }: { label: string, isSelected: boolean, onTap: () => void }) {
  return (
    <button
      onClick={onTap}
      className={`
        px-4 py-2 rounded-full font-semibold text-sm transition-all
        ${isSelected
          ? "bg-[#5D9493] text-white shadow"
          : "bg-gray-100 text-gray-600 hover:bg-gray-200"
        }
      `}
    >
      {label}
    </button>
  );
}

function StudentCard({ student }: { student: any }) {
  const isPlaced = student.placementStatus?.toLowerCase() === 'placed';
  return (
    <Link href={`/admin/students/${student.id}`}>
      <div className="block bg-white p-5 rounded-2xl shadow-sm border border-gray-100 hover:shadow-md hover:border-[#5D9493]/50 transition-all">
        <div className="flex justify-between items-start">
          <div className="flex gap-4">
            <div className="w-12 h-12 rounded-full bg-[#5D9493]/10 flex items-center justify-center font-bold text-xl text-[#5D9493]">
              {student.firstName[0] || 'S'}
            </div>
            <div>
              <h3 className="text-lg font-bold text-[#21464E]">
                {student.firstName} {student.lastName}
              </h3>
              <p className="text-sm text-gray-500">
                {student.rollNumber} | {student.department}
              </p>
              <p className="text-sm text-gray-500">
                CGPA: {student.cgpa}
              </p>
            </div>
          </div>
          <div
            className={`
              px-3 py-1 rounded-full text-xs font-semibold
              ${isPlaced
                ? "bg-green-100 text-green-700"
                : "bg-red-100 text-red-700"
              }
            `}
          >
            {student.placementStatus || 'Unplaced'}
          </div>
        </div>
      </div>
    </Link>
  );
}
