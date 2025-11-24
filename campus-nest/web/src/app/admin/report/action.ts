// app/admin/report/actions.ts
"use server";

import { cookies } from "next/headers";

export async function getReportData() {
  try {
    const token = (await cookies()).get("auth_token")?.value;

    if (!token) {
      throw new Error("Authentication token not found.");
    }

    const res = await fetch(
      "https://campusnest-backend-lkue.onrender.com/api/v1/admin/reports/export",
      { headers: { Authorization: `Bearer ${token}` } }
    );

    if (!res.ok) {
      const contentType = res.headers.get("content-type");
      let errorMessage = "Failed to fetch report data from API";

      if (contentType && contentType.includes("application/json")) {
        const errorData = await res.json();
        errorMessage = errorData.message || "Unknown API error";
      } else {
        errorMessage = await res.text();
      }
      
      console.error("API Error:", errorMessage);
      throw new Error(errorMessage);
    }

    const data = await res.json();
    console.log(data)
    return { success: true, data: data };

  } catch (error) {
    console.error("Error in getReportData action:", error);
    if (error instanceof Error) {
      return { success: false, error: error.message };
    }
    return { success: false, error: "An unknown error occurred" };
  }
}