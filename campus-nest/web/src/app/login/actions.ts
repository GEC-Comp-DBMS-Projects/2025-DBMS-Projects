"use server";
import { cookies } from "next/headers";

export async function handleLogin(email: string, password: string) {
  try {
    console.log(email, password)
    const response = await fetch(
      "https://campusnest-backend-lkue.onrender.com/api/v1/auth/login",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ email, password }),
      }
    );

    const contentType = response.headers.get("content-type");
    if (!contentType || !contentType.includes("application/json")) {
      const errorText = await response.text();
      console.error("Login Error: Server did not return JSON.", errorText);
      return { success: false, error: `Server Error: ${response.statusText}` };
    }

    const data = await response.json();

    if (!response.ok) {
      return { success: false, error: data.message || "Login failed" };
    }

    const token = data.token;
    console.log(token);
    if (!token) {
      return { success: false, error: "Token not found in response" };
    }

    const cookieStore = await cookies();
    cookieStore.set({
      name: "auth_token",
      value: token,
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      path: "/",
      maxAge: 60 * 60 * 24 * 7, 
    });

    return { success: true };
  } catch (error) {
    if (error instanceof Error) {
      return { success: false, error: error.message };
    }
    return { success: false, error: "An unknown error occurred" };
  }
}
