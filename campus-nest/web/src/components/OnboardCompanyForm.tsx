"use client";

import React, { useState, useTransition } from "react";
import { Loader2, Plus, Send, Trash2 } from "lucide-react";
import { onboardCompanyAction } from "@/app/admin/companies/onboard/action";

enum OnboardMode { newCompany, existingCompany }
class RecruiterFormFields {
  readonly id: number;
  firstName: string;
  lastName: string;
  email: string;
  password?: string; 

  constructor() {
    this.id = Date.now();
    this.firstName = "";
    this.lastName = "";
    this.email = "";
  }
}

export default function OnboardCompanyForm({
  allCompanies,
  initialCompanyId,
}: {
  allCompanies: any[];
  initialCompanyId?: string;
}) {
  const [mode, setMode] = useState(
    initialCompanyId ? OnboardMode.existingCompany : OnboardMode.newCompany
  );
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [isPending, startTransition] = useTransition();

  const [recruiters, setRecruiters] = useState([new RecruiterFormFields()]);

  const addRecruiterField = () => {
    setRecruiters([...recruiters, new RecruiterFormFields()]);
  };

  const removeRecruiterField = (id: number) => {
    setRecruiters(recruiters.filter((r) => r.id !== id));
  };

  const handleRecruiterChange = (
    id: number,
    field: "firstName" | "lastName" | "email" | "password",
    value: string
  ) => {
    setRecruiters(
      recruiters.map((r) => (r.id === id ? { ...r, [field]: value } : r))
    );
  };

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setError(null);
    setSuccess(null);

    const formData = new FormData(e.currentTarget);
    formData.append("mode", mode === OnboardMode.newCompany ? "new" : "existing");
    
    formData.append("recruiters", JSON.stringify(recruiters));

    startTransition(async () => {
      const result = await onboardCompanyAction(formData);
      if (result.success) {
        setSuccess(result.message || "Operation successful!");
        (e.target as HTMLFormElement).reset();
        setRecruiters([new RecruiterFormFields()]);
      } else {
        setError(result.error || "An unknown error occurred.");
      }
    });
  };

  return (
    <div className="bg-white p-8 rounded-2xl shadow-sm border border-gray-100">
      <form onSubmit={handleSubmit} className="space-y-6">
        <div className="flex p-1 bg-gray-100 rounded-lg">
          <button
            type="button"
            onClick={() => setMode(OnboardMode.newCompany)}
            className={`flex-1 py-2 rounded-md font-semibold ${
              mode === OnboardMode.newCompany
                ? "bg-[#5D9493] text-white shadow"
                : "text-gray-600"
            }`}
          >
            New Company
          </button>
          <button
            type="button"
            onClick={() => setMode(OnboardMode.existingCompany)}
            className={`flex-1 py-2 rounded-md font-semibold ${
              mode === OnboardMode.existingCompany
                ? "bg-[#5D9493] text-white shadow"
                : "text-gray-600"
            }`}
          >
            Add to Existing
          </button>
        </div>

        {mode === OnboardMode.newCompany ? (
          <div className="space-y-4">
            <FormInput name="companyName" label="Company Name" required />
            <FormInput name="industry" label="Industry (e.g., Tech)" />
            <FormInput name="website" label="Company Website" />
            <FormInput name="description" label="Description" />
          </div>
        ) : (
          <FormSelect
            name="companyId"
            label="Select Company"
            options={allCompanies}
            defaultValue={initialCompanyId}
            required
          />
        )}

        <hr className="my-6 border-gray-200" />

        <h3 className="text-lg font-semibold text-[#21464E]">
          Recruiters to Add
        </h3>
        <div className="space-y-4">
          {recruiters.map((recruiter, index) => (
            <div
              key={recruiter.id}
              className="p-4 border border-gray-200 rounded-lg space-y-4 relative"
            >
              {recruiters.length > 1 && (
                <button
                  type="button"
                  onClick={() => removeRecruiterField(recruiter.id)}
                  className="absolute top-2 right-2 p-1 text-red-400 hover:bg-red-100 rounded-full"
                >
                  <Trash2 size={16} />
                </button>
              )}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <FormInput
                  name={`r_firstName_${index}`}
                  label={`Recruiter ${index + 1} First Name`}
                  value={recruiter.firstName}
                  onChange={(e) =>
                    handleRecruiterChange(recruiter.id, "firstName", e.target.value)
                  }
                  required
                />
                <FormInput
                  name={`r_lastName_${index}`}
                  label={`Recruiter ${index + 1} Last Name`}
                  value={recruiter.lastName}
                  onChange={(e) =>
                    handleRecruiterChange(recruiter.id, "lastName", e.target.value)
                  }
                  required
                />
              </div>
              <FormInput
                name={`r_email_${index}`}
                label={`Recruiter ${index + 1} Email`}
                type="email"
                value={recruiter.email}
                onChange={(e) =>
                  handleRecruiterChange(recruiter.id, "email", e.target.value)
                }
                required
              />
              <FormInput
                name={`r_password_${index}`}
                label={`Recruiter ${index + 1} Password`}
                type="password"
                value={recruiter.password || ""}
                onChange={(e) =>
                  handleRecruiterChange(recruiter.id, "password", e.target.value)
                }
                required
              />
            </div>
          ))}
        </div>
        <button
          type="button"
          onClick={addRecruiterField}
          className="flex items-center gap-2 py-2 px-4 rounded-lg text-sm font-semibold text-[#5D9493] bg-[#5D9493]/10 hover:bg-[#5D9493]/20"
        >
          <Plus size={16} />
          Add Another Recruiter
        </button>

        <hr className="my-6 border-gray-200" />

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
          {isPending ? "Submitting..." : "Submit"}
        </button>
      </form>
    </div>
  );
}

function FormInput({
  name,
  label,
  value,
  onChange,
  type = "text",
  required = false,
}: {
  name: string;
  label: string;
  value?: string;
  onChange?: (e: React.ChangeEvent<HTMLInputElement>) => void;
  type?: string;
  required?: boolean;
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
        value={value}
        onChange={onChange}
        required={required}
        className="block w-full px-3 py-2 text-black bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#5D9493]"
      />
    </div>
  );
}

function FormSelect({
  name,
  label,
  options,
  defaultValue,
  required = false,
}: {
  name: string;
  label: string;
  options: any[];
  defaultValue?: string;
  required?: boolean;
}) {
  return (
    <div>
      <label
        htmlFor={name}
        className="block text-sm font-medium text-gray-700 mb-1"
      >
        {label} {required && <span className="text-red-500">*</span>}
      </label>
      <select
        name={name}
        id={name}
        defaultValue={defaultValue || ""}
        required={required}
        className="block w-full px-3 py-2 text-black bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#5D9493]"
      >
        <option value="" disabled>
          Select a company...
        </option>
        {options.map((option) => (
          <option key={option.ID} value={option.ID} className="text-black">
            {option.Name}
          </option>
        ))}
      </select>
    </div>
  );
}

