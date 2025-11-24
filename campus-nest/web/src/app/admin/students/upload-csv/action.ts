"use server";

import { cookies } from "next/headers";

export async function uploadCsvAction(formData: FormData) {
  const cookieStore = await cookies();
  const token = cookieStore.get("auth_token")?.value;
  if (!token) {
    return { success: false, error: "Unauthorized" };
  }

  const file = formData.get("file") as File;
  if (!file || file.type !== "text/csv") {
    return { success: false, error: "Invalid file. Please upload a CSV." };
  }

  const cloudinaryFormData = new FormData();
  cloudinaryFormData.append("file", file);
  cloudinaryFormData.append(
    "upload_preset",
    process.env.CLOUDINARY_UPLOAD_PRESET!
  );
  
  const cloudName = process.env.CLOUDINARY_CLOUD_NAME;
  const cloudinaryUrl = `https://api.cloudinary.com/v1_1/${cloudName}/raw/upload`;

  try {
    const cloudinaryRes = await fetch(cloudinaryUrl, {
      method: "POST",
      body: cloudinaryFormData,
    });

    if (!cloudinaryRes.ok) {
      throw new Error("Failed to upload file to Cloudinary.");
    }

    const cloudinaryData = await cloudinaryRes.json();
    const csvFileUrl = cloudinaryData.secure_url;

    const backendUrl = "https://campusnest-backend-lkue.onrender.com/api/v1/admin/students/upload-csv";
    
    const backendRes = await fetch(backendUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({ csvUrl: csvFileUrl }),
    });

    if (!backendRes.ok) {
      const errorData = await backendRes.json();
      throw new Error(errorData.message || "Backend failed to process CSV.");
    }

    const backendData = await backendRes.json();
    return { success: true, message: backendData.message || "File uploaded!" };

  } catch (error) {
    console.error("Upload CSV Action Error:", error);
    if (error instanceof Error) {
      return { success: false, error: error.message };
    }
    return { success: false, error: "An unknown error occurred" };
  }
}
