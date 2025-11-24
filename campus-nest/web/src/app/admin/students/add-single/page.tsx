"use client";

import React, { useState, useTransition } from "react";
import { UserPlus, Loader2 } from "lucide-react";
import { addStudentAction } from "./action"; // We will create this next

export default function AddStudentPage() {
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [isPending, startTransition] = useTransition();

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setError(null);
    setSuccess(null);

    const formData = new FormData(e.currentTarget);

    startTransition(async () => {
      const result = await addStudentAction(formData);

      if (result.success) {
        setSuccess(result.message || "Student added successfully!");
        (e.target as HTMLFormElement).reset(); // Clear the form
      } else {
        setError(result.error || "An unknown error occurred.");
      }
    });
  };

  return (
    <div className="max-w-3xl mx-auto">
      <div className="bg-white p-8 rounded-2xl shadow-sm border border-gray-100">
        <h1 className="text-2xl font-bold text-[#21464E]">Add Single Student</h1>
        <p className="text-gray-500 mt-2 mb-6">
          Manually add a new student to the database.
        </p>

        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <FormInput name="firstName" label="First Name" required />
            <FormInput name="lastName" label="Last Name" required />
          </div>

          <FormInput
            name="email"
            label="Email Address"
            type="email"
            required
          />
          <FormInput name="rollNumber" label="Roll Number" required />
          <FormInput name="department" label="Department" required />

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <FormInput name="cgpa" label="CGPA" type="number" step="0.01" />
            <FormSelect
              name="gender"
              label="Gender"
              options={["Male", "Female", "Other"]}
            />
          </div>

          {/* Error/Success Messages */}
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

          {/* Submit Button */}
          <button
            type="submit"
            disabled={isPending}
            className="w-full flex justify-center items-center gap-2 py-3 px-4 rounded-lg shadow-sm text-lg font-bold text-white bg-[#5D9493] hover:bg-[#21464E] focus:outline-none disabled:bg-gray-400 transition-all"
          >
            {isPending ? (
              <Loader2 className="animate-spin" size={24} />
            ) : (
              <UserPlus size={24} />
            )}
            {isPending ? "Adding Student..." : "Add Student"}
          </button>
        </form>
      </div>
    </div>
  );
}

// --- Reusable Form Field Components ---
function FormInput({
  name,
  label,
  type = "text",
  required = false,
  step,
}: {
  name: string;
  label: string;
  type?: string;
  required?: boolean;
  step?: string;
}) {
  return (
    <div>
      <label
        htmlFor={name}
        className="block text-sm font-medium text-gray-700 mb-1"
      >
        {label} {required && <span className="text-red-500">*</span>}
      </label>
      <input
        type={type}
        name={name}
        id={name}
        step={step}
        required={required}
        className="block w-full px-3 py-2 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#5D9493]"
      />
    </div>
  );
}

function FormSelect({
  name,
  label,
  options,
}: {
  name: string;
  label: string;
  options: string[];
}) {
  return (
    <div>
      <label
        htmlFor={name}
        className="block text-sm font-medium text-gray-700 mb-1"
      >
        {label}
      </label>
      <select
        name={name}
        id={name}
        className="block w-full px-3 py-2 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#5D9493]"
      >
        <option value="">Select...</option>
        {options.map((option) => (
          <option key={option} value={option}>
            {option}
          </option>
        ))}
      </select>
    </div>
  );
}

