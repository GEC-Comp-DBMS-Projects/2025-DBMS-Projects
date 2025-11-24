"use server";

import { cookies } from "next/headers";
import { revalidatePath } from "next/cache";

export async function sendAnnouncementAction(formData: FormData) {
  const token = (await cookies()).get("auth_token")?.value;
  if (!token) {
    return { success: false, error: "Unauthorized: Admin token not found." };
  }

  const subject = formData.get("subject") as string;
  const message = formData.get("message") as string;

  if (!subject || !message) {
    return { success: false, error: "Subject and Message are required." };
  }

  const url = "https://campusnest-backend-lkue.onrender.com/api/v1/admin/announcements";
  const payload = {
    subject,
    message,
  };

  try {
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
      return { success: false, error: errorData.message || "Failed to send announcement." };
    }

    const data = await response.json();

    return { success: true, message: data.message || "Announcement sent successfully!" };

  } catch (error) {
    console.error("Send Announcement Action Error:", error);
    if (error instanceof Error) {
      return { success: false, error: error.message };
    }
    return { success: false, error: "An unknown error occurred." };
  }
}
