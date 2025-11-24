import React from "react";
import { cookies } from "next/headers";
import DriveListClient from "@/components/DriveListClient";

async function getAllDrives() {
  const token = (await cookies()).get("auth_token")?.value;
  if (!token) throw new Error("Unauthorized");

  const url = "https://campusnest-backend-lkue.onrender.com/api/v1/admin/drives";

  try {
    const res = await fetch(url, {
      headers: { Authorization: `Bearer ${token}` },
      next: { revalidate: 60 },
    });
    if (!res.ok) {
      const errorData = await res.text();
      throw new Error(errorData || "Failed to fetch drives");
    }
    const data = await res.json();
    return data.drives || [];
  } catch (error) {
    console.error("Error fetching all drives:", error);
    return []; 
  }
}

export default async function DrivesPage() {
  const drives = await getAllDrives();

  return (
    <DriveListClient allDrives={drives} />
  );
}
