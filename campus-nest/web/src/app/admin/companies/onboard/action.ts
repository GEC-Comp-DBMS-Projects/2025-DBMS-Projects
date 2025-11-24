"use server";

import { cookies } from "next/headers";
import { revalidatePath } from "next/cache";

export async function onboardCompanyAction(formData: FormData) {
  const token = (await cookies()).get("auth_token")?.value;
  if (!token) {
    return { success: false, error: "Unauthorized" };
  }
  const mode = formData.get("mode");
  
  const recruiters = JSON.parse(formData.get("recruiters") as string);

  let url: string;
  let payload: any;

  try {
    if (mode === "new") {
      url = "https://campusnest-backend-lkue.onrender.com/api/v1/admin/company";
      payload = {
        name: formData.get("companyName"), // Renamed to 'name'
        industry: formData.get("industry"),
        website: formData.get("website"),
        description: formData.get("description"), // Added description
        recruiters: recruiters, // This list now includes the password
      };
    } else {
      const companyId = formData.get("companyId");
      if (!companyId) {
        return { success: false, error: "No company was selected." };
      }
      url = `https://campusnest-backend-lkue.onrender.com/api/v1/admin/company/${companyId}/recruiter`;
      
      // The backend for this route expects a single recruiter object,
      // but the Go struct shows `[]struct`. We'll send the list.
      // If it only accepts one, you may need to loop or send only the first.
      // Based on your struct, a list is correct.
      payload = {
        recruiters: recruiters, // This list now includes the password
      };
    }

    const response = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      const errorData = await response.json();
      return { success: false, error: errorData.message || "Failed to submit" };
    }

    const data = await response.json();

    // Revalidate the companies page to show the new data
    revalidatePath("/admin/companies");

    return { success: true, message: data.message || "Operation successful!" };

  } catch (error) {
    console.error("Onboard Company Action Error:", error);
    if (error instanceof Error) {
      return { success: false, error: error.message };
    }
    return { success: false, error: "An unknown error occurred" };
  }
}

