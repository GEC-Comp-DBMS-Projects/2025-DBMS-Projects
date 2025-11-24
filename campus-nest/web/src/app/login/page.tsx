import React from "react";
import Image from "next/image";
import LoginForm from "@/components/LoginForm"; 

export default function LoginPage() {
  return (
    <main className="flex items-center justify-center min-h-screen p-6 bg-theme-gradient from-[#EBFBFA] via-[#5D9493] to-[#21464E]">
      <div className="w-full max-w-md">
        <div className="text-center mb-8">
          <Image
            src="/campusnest_logo.png"
            alt="CampusNest Logo"
            width={100}
            height={100}
            className="mx-auto rounded-2xl shadow-lg"
          />
          <h1 className="mt-6 text-3xl font-bold text-white">
            Admin Panel Login
          </h1>
          <p className="mt-2 text-white/80">
            Welcome to the CampusNest Admin Dashboard.
          </p>
        </div>

        <div className="bg-white/10 p-8 rounded-2xl shadow-xl backdrop-blur-lg border border-white/20">
          <LoginForm />
        </div>
      </div>
    </main>
  );
}
