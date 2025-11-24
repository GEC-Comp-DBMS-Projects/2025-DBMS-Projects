"use server";

import { cookies } from "next/headers";
import { revalidatePath } from "next/cache";

export async function addStudentAction(formData: FormData) {
  const token = (await cookies()).get("auth_token")?.value;
  if (!token) {
    return { success: false, error: "Unauthorized" };
  }

  const payload = {
    firstName: formData.get("firstName"),
    lastName: formData.get("lastName"),
    email: formData.get("email"),
    rollNumber: formData.get("rollNumber"),
    department: formData.get("department"),
    cgpa: parseFloat(formData.get("cgpa") as string),
    gender: formData.get("gender"),
    placedStatus: "Unplaced"
  };

  const url = "https://campusnest-backend-lkue.onrender.com/api/v1/admin/student";

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
      return { success: false, error: errorData.message || "Failed to add student" };
    }

    const data = await response.json();

    // 3. Revalidate the student list page so it shows the new student
    revalidatePath("/admin/students");

    return { success: true, message: "Student added successfully!" };

  } catch (error) {
    console.error("Add Student Action Error:", error);
    if (error instanceof Error) {
      return { success: false, error: error.message };
    }
    return { success: false, error: "An unknown error occurred" };
  }
}
