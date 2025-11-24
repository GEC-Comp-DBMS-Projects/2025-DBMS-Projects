"use client";

import React, { useState, useTransition } from "react";
import { UploadCloud, FileText, Loader2 } from "lucide-react";
import { uploadCsvAction } from "./action";

export default function UploadCsvPage() {
  const [file, setFile] = useState<File | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [isPending, startTransition] = useTransition();

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const selectedFile = e.target.files?.[0];
    if (selectedFile) {
      if (selectedFile.type !== "text/csv") {
        setError("Invalid file type. Please upload a .csv file.");
        setFile(null);
      } else {
        setFile(selectedFile);
        setError(null);
      }
    }
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!file) {
      setError("Please select a file to upload.");
      return;
    }
    setError(null);
    setSuccess(null);

    startTransition(async () => {
      const formData = new FormData();
      formData.append("file", file);

      const result = await uploadCsvAction(formData);

      if (result.success) {
        setSuccess(result.message || "CSV uploaded and students are being added.");
        setFile(null);
      } else {
        setError(result.error || "An unknown error occurred.");
      }
    });
  };

  return (
    <div className="max-w-3xl mx-auto">
      <div className="bg-white p-8 rounded-2xl shadow-sm border border-gray-100">
        <h1 className="text-2xl font-bold text-[#21464E]">Upload Student CSV</h1>
        <p className="text-gray-500 mt-2 mb-6">
          Upload a CSV file to add a batch of students to the database.
        </p>

        <form onSubmit={handleSubmit} className="space-y-6">
          {/* File Dropzone */}
          <div className="border-2 border-dashed border-gray-300 rounded-xl p-8 text-center">
            <input
              type="file"
              id="csv-upload"
              className="hidden"
              accept=".csv"
              onChange={handleFileChange}
              disabled={isPending}
            />
            <label
              htmlFor="csv-upload"
              className={`flex flex-col items-center gap-2 cursor-pointer ${
                isPending ? "opacity-50" : ""
              }`}
            >
              <div className="p-3 bg-[#5D9493]/10 text-[#5D9493] rounded-full">
                <UploadCloud size={28} />
              </div>
              <span className="font-semibold text-lg text-[#21464E]">
                {file ? file.name : "Click to select a .csv file"}
              </span>
              <p className="text-sm text-gray-500">
                {file ? `(${(file.size / 1024).toFixed(2)} KB)` : "CSV (Max 5MB)"}
              </p>
            </label>
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
            disabled={!file || isPending}
            className="w-full flex justify-center items-center gap-2 py-3 px-4 rounded-lg shadow-sm text-lg font-bold text-white bg-[#5D9493] hover:bg-[#21464E] focus:outline-none disabled:bg-gray-400 transition-all"
          >
            {isPending ? (
              <Loader2 className="animate-spin" size={24} />
            ) : (
              <UploadCloud size={24} />
            )}
            {isPending ? "Uploading..." : "Upload and Process File"}
          </button>
        </form>
      </div>
    </div>
  );
}

