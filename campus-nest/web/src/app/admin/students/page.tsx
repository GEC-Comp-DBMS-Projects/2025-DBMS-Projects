import React from "react";
import { cookies } from "next/headers";
import StudentClientPage from "@/components/StudentClientPage";

// --- API Data Fetching (Server-Side) ---
async function getStudentData() {
  const token = (await cookies()).get("auth_token")?.value;
  if (!token) throw new Error("Authentication token not found.");

  const url = "https://campusnest-backend-lkue.onrender.com/api/v1/admin/students";
  
  try {
    const res = await fetch(url, {
      headers: { Authorization: `Bearer ${token}` },
      next: { revalidate: 60 }, // Cache data for 60 seconds
    });

    if (!res.ok) {
      const errorText = await res.text();
      throw new Error(`Failed to fetch students: ${errorText}`);
    }
    
    return await res.json();

  } catch (error) {
    console.error("Error fetching student data:", error);
    return null; // Return null on error
  }
}

export default async function ManageStudentsPage() {
  const data = await getStudentData();

  if (!data) {
    return <div className="p-6 text-gray-700 font-semibold">Failed to load student data. Please refresh.</div>;
  }

  // Pass the fetched data as props to the Client Component
  return (
    <StudentClientPage 
      allStudents={data.students || []} 
      stats={data.statistics || {}} 
    />
  );
}
