"use client";

import React, { useState, useTransition } from "react";
import { Loader2, Send } from "lucide-react";
import { sendAnnouncementAction } from "./action";

// This is the main client component for the page
export default function AnnouncementsPage() {
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [isPending, startTransition] = useTransition();

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setError(null);
    setSuccess(null);

    const formData = new FormData(e.currentTarget);

    startTransition(async () => {
      const result = await sendAnnouncementAction(formData);
      if (result.success) {
        setSuccess(result.message || "Announcement sent successfully!");
        (e.target as HTMLFormElement).reset(); // Reset the form
      } else {
        setError(result.error || "An unknown error occurred.");
      }
    });
  };

  return (
    <div className="flex flex-col gap-6 p-6 max-w-3xl mx-auto">
      {/* --- Header --- */}
      <div className="mb-2">
        <h1 className="text-3xl font-bold text-[#21464E]">Send Announcement</h1>
        <p className="text-gray-500 mt-2">
          Send a notification to all TPOs and Students.
        </p>
      </div>

      <div className="bg-white p-8 rounded-2xl shadow-lg border border-gray-100">
        <form onSubmit={handleSubmit} className="space-y-6">
          <div>
            <label
              htmlFor="subject"
              className="block text-sm font-semibold text-gray-700 mb-1"
            >
              Subject <span className="text-red-500">*</span>
            </label>
            <input
              type="text"
              name="subject"
              id="subject"
              required
              className="block w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#5D9493] placeholder:text-gray-400"
              placeholder="e.g., New Placement Drive"
            />
          </div>

          <div>
            <label
              htmlFor="message"
              className="block text-sm font-semibold text-gray-700 mb-1"
            >
              Message <span className="text-red-500">*</span>
            </label>
            <textarea
              name="message"
              id="message"
              rows={6}
              required
              className="block w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#5D9493] placeholder:text-gray-400"
              placeholder="Enter the full details of the announcement..."
            />
          </div>

          {error && (
            <div className="bg-red-100 border border-red-200 text-red-700 p-3 rounded-lg text-sm">
              {error}
            </div>
          )}
          {success && (
            <div className="bg-green-100 border border-green-200 text-green-700 p-3 rounded-lg text-sm">
              {success}
            </div>
          )}

          <button
            type="submit"
            disabled={isPending}
            className="w-full flex justify-center items-center gap-2 py-3 px-4 rounded-lg shadow-sm text-lg font-bold text-white bg-[#5D9493] hover:bg-[#21464E] focus:outline-none disabled:bg-gray-400 transition-all"
          >
            {isPending ? (
              <Loader2 className="animate-spin" size={24} />
            ) : (
              <Send size={20} />
            )}
            {isPending ? "Sending..." : "Send Announcement"}
          </button>
        </form>
      </div>
    </div>
  );
}
