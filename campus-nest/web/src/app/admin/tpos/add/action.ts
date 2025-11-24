"use server";

import { cookies } from "next/headers";
import { revalidatePath } from "next/cache";

export async function addTpoAction(payload: any) {
    const token = (await cookies()).get("auth_token")?.value;
  if (!token) {
    return { success: false, error: "Unauthorized: Admin token not found." };
  }

  // Basic validation
  if (!payload.firstName || !payload.lastName || !payload.email || !payload.password || !payload.department) {
    return { success: false, error: "Please fill all required fields." };
  }

  const url = "https://campusnest-backend-lkue.onrender.com/api/v1/admin/tpo";

  try {
    const response = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify(payload), // Send the payload directly
    });

    if (!response.ok) {
      const errorData = await response.json();
      return { success: false, error: errorData.message || "Failed to add TPO." };
    }

    const data = await response.json();

    // Refresh the list of TPOs on the main page
    revalidatePath("/admin/tpos");

    return { success: true, message: data.message || "TPO added successfully!" };

  } catch (error) {
    console.error("Add TPO Action Error:", error);
    if (error instanceof Error) {
      return { success: false, error: error.message };
    }
    return { success: false, error: "An unknown error occurred." };
  }
}
