import React from "react";
import { cookies } from "next/headers";
import TpoClientPage from "@/components/TpoClientPage";
import { redirect } from "next/navigation";

// --- Data Fetching ---
async function getTpos() {
    const token = (await cookies()).get("auth_token")?.value;
  if (!token) redirect("/login"); 

  const url = "https://campusnest-backend-lkue.onrender.com/api/v1/admin/tpos";

  try {
    const res = await fetch(url, {
      headers: { Authorization: `Bearer ${token}` },
      next: { revalidate: 60 }, // Cache for 1 minute
    });
    if (!res.ok) {
      const errorData = await res.text();
      throw new Error(errorData || "Failed to fetch TPOs");
    }
    const data = await res.json();
    console.log(data);
    return data.tpos || []; // Assuming the list is in a 'tpos' key
  } catch (error) {
    console.error("Error fetching TPOs:", error);
    return []; // Return empty on error
  }
}

export default async function TposPage() {
  const tpos = await getTpos();
  
  return (
    <TpoClientPage allTpos={tpos} />
  );
}
