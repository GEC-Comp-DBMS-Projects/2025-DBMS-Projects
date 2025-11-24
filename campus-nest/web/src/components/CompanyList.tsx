"use client";

import React, { useState } from "react";
import Link from "next/link";
import { ChevronDown, Plus } from "lucide-react";

// Individual Company Card
function CompanyCard({ company }: { company: any }) {
  const [isExpanded, setIsExpanded] = useState(false);
  const companyName = company.Name || "N/A";
  const industry = company.Industry || "N/A";

  return (
    <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 transition-all">
      <div
        className="flex items-center cursor-pointer"
        onClick={() => setIsExpanded(!isExpanded)}
      >
        {/* Icon */}
        <div className="p-3 bg-[#5D9493]/10 text-[#5D9493] rounded-lg">
          <span className="text-xl font-bold">{companyName[0]}</span>
        </div>
        
        {/* Details */}
        <div className="ml-4 flex-1">
          <p className="font-semibold text-lg text-[#21464E]">{companyName}</p>
          <p className="text-sm text-gray-500">{industry}</p>
        </div>
        
        {/* Chevron */}
        <ChevronDown
          size={20}
          className={`text-gray-400 transition-transform ${
            isExpanded ? "rotate-180" : ""
          }`}
        />
      </div>

      {/* Expandable Section */}
      <div
        className={`overflow-hidden transition-all duration-300 ${
          isExpanded ? "max-h-40 mt-4" : "max-h-0"
        }`}
      >
        <div className="border-t border-gray-100 pt-4">
          <Link
            href={`/admin/companies/onboard?companyId=${company.ID}`}
            className="flex items-center justify-center gap-2 py-2 px-4 rounded-lg text-sm font-semibold text-[#5D9493] bg-[#5D9493]/10 hover:bg-[#5D9493]/20"
          >
            <Plus size={16} />
            Add Recruiter to this Company
          </Link>
        </div>
      </div>
    </div>
  );
}

// Main List Component
export default function CompanyList({
  initialCompanies,
}: {
  initialCompanies: any[];
}) {
  return (
    <div className="flex flex-col gap-4">
      {initialCompanies.length > 0 ? (
        initialCompanies.map((company) => (
          <CompanyCard key={company.ID} company={company} />
        ))
      ) : (
        <div className="text-center text-gray-500 mt-10">
          No companies found.
        </div>
      )}
    </div>
  );
}
