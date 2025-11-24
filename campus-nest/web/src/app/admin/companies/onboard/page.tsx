import React, { Suspense } from "react";
import OnboardCompanyForm from "@/components/OnboardCompanyForm";
import { cookies } from "next/headers";

async function getCompanies() {
  const token = (await cookies()).get("auth_token")?.value;
  if (!token) throw new Error("Unauthorized");

  const url = "https://campusnest-backend-lkue.onrender.com/api/v1/admin/companies";
  try {
    const res = await fetch(url, { headers: { Authorization: `Bearer ${token}` } });
    if (!res.ok) throw new Error("Failed to fetch companies");
    const data = await res.json();
    return data.companies || [];
  } catch (error) {
    console.error("Error fetching companies:", error);
    return [];
  }
}

export default async function OnboardPage(props: {
  searchParams: Promise<{ companyId?: string }>;
}) {
  const searchParams = await props.searchParams; // ✅ await it first
  const companyId = searchParams?.companyId;

  const companies = await getCompanies();

  return (
    <div className="max-w-3xl mx-auto">
      <Suspense fallback={<div className="text-center p-10">Loading form...</div>}>
        <OnboardCompanyFormWrapper companyId={companyId} />
      </Suspense>
    </div>
  );
}

async function OnboardCompanyFormWrapper({ companyId }: { companyId?: string }) {
  const companies = await getCompanies();
  return (
    <OnboardCompanyForm
      allCompanies={companies}
      initialCompanyId={companyId}
    />
  );
}
