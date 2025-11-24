import React from "react";
import { cookies } from "next/headers";
import Link from "next/link";
import CompanyList from "@/components/CompanyList";
import { Plus } from "lucide-react";

async function getCompanies() {
  const token = (await cookies()).get("auth_token")?.value;
  if (!token) throw new Error("Unauthorized");

  const url = "https://campusnest-backend-lkue.onrender.com/api/v1/admin/companies";
  try {
    const res = await fetch(url, {
      headers: { Authorization: `Bearer ${token}` },
      next: { revalidate: 60 },
    });
    if (!res.ok) throw new Error("Failed to fetch companies");
    const data = await res.json();
    console.log(data)
    return data.companies || [];
  } catch (error) {
    console.error("Error fetching companies:", error);
    return [];
  }
}

export default async function CompaniesPage() {
  const companies = await getCompanies();

  return (
    <div className="flex flex-col gap-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-[#21464E]">
            Manage Companies
          </h1>
          <p className="text-gray-500 mt-2">
            View, add, or manage recruiters for companies.
          </p>
        </div>
        <Link
          href="/admin/companies/onboard"
          className="flex items-center gap-2 py-3 px-4 rounded-lg shadow-sm text-base font-bold text-white bg-[#5D9493] hover:bg-[#21464E] transition-all"
        >
          <Plus size={20} />
          Add New Company
        </Link>
      </div>
      <CompanyList initialCompanies={companies} />
    </div>
  );
}
