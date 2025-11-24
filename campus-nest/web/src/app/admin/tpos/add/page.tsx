"use client";

import React, { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { Loader2, Send, Plus, Trash } from "lucide-react";
import { addTpoAction } from "./action";

interface Qualification {
  title: string;
  description: string;
}

export default function AddTpoPage() {
  const [error, setError] = useState<string | null>(null);
  const [isPending, startTransition] = useTransition();
  const router = useRouter();

  const [formData, setFormData] = useState({
    firstName: "",
    lastName: "",
    email: "",
    password: "",
    department: "",
    gender: "Male",
  });
  
  // State for the dynamic qualifications list
  const [qualifications, setQualifications] = useState<Qualification[]>([
    { title: "", description: "" },
  ]);

  const handleFormChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleQualificationChange = (index: number, e: React.ChangeEvent<HTMLInputElement>) => {
    const newQualifications = [...qualifications];
    newQualifications[index] = {
      ...newQualifications[index],
      [e.target.name]: e.target.value,
    };
    setQualifications(newQualifications);
  };

  const addQualification = () => {
    setQualifications([...qualifications, { title: "", description: "" }]);
  };

  const removeQualification = (index: number) => {
    if (qualifications.length > 1) {
      setQualifications(qualifications.filter((_, i) => i !== index));
    }
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    // Combine form data and qualifications
    const finalPayload = {
      ...formData,
      qualifications: qualifications.filter(q => q.title), // Filter out empty qualifications
    };

    startTransition(async () => {
      const result = await addTpoAction(finalPayload);
      if (result.success) {
        alert("TPO added successfully!");
        router.push("/admin/tpos"); // Go back to the TPO list
      } else {
        setError(result.error || "An unknown error occurred.");
      }
    });
  };

  return (
    <div className="flex flex-col gap-6 max-w-3xl mx-auto">
      <div className="mb-2">
        <h1 className="text-3xl font-bold text-[#21464E]">Add New TPO</h1>
        <p className="text-gray-500 mt-2">
          Create a new Training and Placement Officer account.
        </p>
      </div>

      <div className="bg-white p-8 rounded-2xl shadow-lg border border-gray-100">
        <form onSubmit={handleSubmit} className="space-y-6">
          {/* --- Basic Info --- */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <FormInput name="firstName" label="First Name" value={formData.firstName} onChange={handleFormChange} />
            <FormInput name="lastName" label="Last Name" value={formData.lastName} onChange={handleFormChange} />
          </div>
          <FormInput name="email" label="Email Address" type="email" value={formData.email} onChange={handleFormChange} />
          <FormInput name="password" label="Password" type="password" value={formData.password} onChange={handleFormChange} />
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <FormInput name="department" label="Department" value={formData.department} onChange={handleFormChange} />
            <FormSelect name="gender" label="Gender" value={formData.gender} onChange={handleFormChange} options={["Male", "Female", "Other"]} />
          </div>

          <div className="border-t border-gray-200 pt-6">
            <h3 className="text-lg font-semibold text-[#21464E] mb-4">Qualifications</h3>
            {qualifications.map((q, index) => (
              <div key={index} className="grid grid-cols-1 md:grid-cols-2 gap-4 items-center mb-4 p-4 rounded-lg bg-gray-50 border">
                <FormInput name="title" label={`Title ${index + 1}`} value={q.title} onChange={(e) => handleQualificationChange(index, e)} />
                <div className="flex items-center">
                  <div className="flex-1">
                    <FormInput name="description" label={`Description ${index + 1}`} value={q.description} onChange={(e) => handleQualificationChange(index, e)} />
                  </div>
                  {qualifications.length > 1 && (
                    <button type="button" onClick={() => removeQualification(index)} className="ml-2 p-2 text-red-500 hover:bg-red-100 rounded-full">
                      <Trash size={18} />
                    </button>
                  )}
                </div>
              </div>
            ))}
            <button
              type="button"
              onClick={addQualification}
              className="flex items-center gap-2 text-sm font-semibold text-[#5D9493] hover:text-[#21464E]"
            >
              <Plus size={16} />
              Add Qualification
            </button>
          </div>

          {/* --- Error & Submit --- */}
          {error && <div className="bg-red-100 border border-red-200 text-red-700 p-3 rounded-lg text-sm">{error}</div>}

          <button
            type="submit"
            disabled={isPending}
            className="w-full flex justify-center items-center gap-2 py-3 px-4 rounded-lg shadow-sm text-lg font-bold text-white bg-[#5D9493] hover:bg-[#21464E] disabled:bg-gray-400 transition-all"
          >
            {isPending ? <Loader2 className="animate-spin" size={24} /> : <UserPlus size={20} />}
            {isPending ? "Adding TPO..." : "Add TPO"}
          </button>
        </form>
      </div>
    </div>
  );
}

// --- Reusable Form Input Components ---
const FormInput = ({ name, label, value, onChange, type = "text" }: any) => (
  <div>
    <label htmlFor={name} className="block text-sm font-semibold text-gray-700 mb-1">
      {label} <span className="text-red-500">*</span>
    </label>
    <input
      type={type}
      name={name}
      id={name}
      required
      value={value}
      onChange={onChange}
      className="block w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#5D9493]"
    />
  </div>
);

const FormSelect = ({ name, label, value, onChange, options }: any) => (
  <div>
    <label htmlFor={name} className="block text-sm font-semibold text-gray-700 mb-1">
      {label}
    </label>
    <select
      name={name}
      id={name}
      value={value}
      onChange={onChange}
      className="block w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#5D9493]"
    >
      {options.map((option: string) => (
        <option key={option} value={option}>{option}</option>
      ))}
    </select>
  </div>
);
