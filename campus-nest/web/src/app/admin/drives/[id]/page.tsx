import React from "react";
import { cookies } from "next/headers";
import Link from "next/link";
import { ArrowLeft, Briefcase, Building, Calendar, Check, Mail, MapPin, School, Star, Users } from "lucide-react";
import { format } from "date-fns";

// --- Data Fetching ---

// 1. Fetches the main job drive details
async function getDriveDetails(id: string, token: string) {
  const url = `https://campusnest-backend-lkue.onrender.com/api/v1/admin/drives/${id}`;
  try {
    const res = await fetch(url, {
      headers: { Authorization: `Bearer ${token}` },
      next: { revalidate: 60 },
    });
    if (!res.ok) throw new Error(await res.text());
    return res.json();
  } catch (error) {
    console.error(`Error fetching drive ${id}:`, error);
    return null;
  }
}

// 2. Fetches the list of applicants for that drive
async function getDriveApplications(id: string, token: string) {
  const url = `https://campusnest-backend-lkue.onrender.com/api/v1/admin/drives/${id}/applications`;
  try {
    const res = await fetch(url, {
      headers: { Authorization: `Bearer ${token}` },
      next: { revalidate: 60 },
    });
    if (!res.ok) throw new Error(await res.text());
    return res.json();
  } catch (error) {
    console.error(`Error fetching applications for ${id}:`, error);
    return null;
  }
}

// --- Helper Functions ---

// Helper to format the date string
const formatDate = (dateString?: string) => {
  if (!dateString || dateString.startsWith("0001")) {
    return "Not specified";
  }
  try {
    return format(new Date(dateString), "do MMMM, yyyy");
  } catch (error) {
    return "Invalid Date";
  }
};

// Helper for the status badge
const StatusBadge = ({ status }: { status: string }) => {
  let color = "bg-gray-100 text-gray-600";
  if (status.toLowerCase() === "open") {
    color = "bg-green-100 text-green-700";
  } else if (status.toLowerCase() === "closed") {
    color = "bg-red-100 text-red-700";
  }
  return (
    <span className={`px-3 py-1 rounded-full text-sm font-semibold ${color}`}>
      {status}
    </span>
  );
};

// --- Main Page Component ---
export default async function DriveDetailPage({
  params,
}: {
  params: { id: string };
}) {
  const token = (await cookies()).get("auth_token")?.value;
  if (!token) return <div className="p-6">Error: Not Authenticated</div>;

  const [driveData, applicationsData] = await Promise.all([
    getDriveDetails(params.id, token),
    getDriveApplications(params.id, token),
  ]);

  if (!driveData) {
    return <div className="p-6">Error: Job Drive not found.</div>;
  }

  const drive = driveData.drive || {}; // Assuming data is nested
  const applicants = applicationsData?.applications || []; // Assuming data is nested

  return (
    <div className="flex flex-col gap-6">
      {/* --- Back Button Header --- */}
      <div className="flex items-center gap-3">
        <Link
          href="/admin/drives"
          className="p-2 rounded-lg bg-white shadow-sm border border-gray-100 text-gray-600 hover:bg-gray-50"
        >
          <ArrowLeft size={20} />
        </Link>
        <div>
          <h1 className="text-3xl font-bold text-[#21464E]">{drive.position}</h1>
          <p className="text-gray-500">{drive.company_name?.name}</p>
        </div>
      </div>

      <div className="bg-white p-8 rounded-2xl shadow-sm border border-gray-100">
        <div className="flex justify-between items-start">
          <h2 className="text-2xl font-bold text-[#21464E]">Job Details</h2>
          <StatusBadge status={drive.status || "Unknown"} />
        </div>
        
        <p className="text-gray-600 mt-4 leading-relaxed">
          {drive.description || "No description provided."}
        </p>
        
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6 border-t border-gray-100 pt-6">
          <InfoItem icon={Briefcase} label="Salary" value={drive.salary_range || "N/A"} />
          <InfoItem icon={MapPin} label="Location" value={drive.location || "N/A"} />
          <InfoItem icon={Calendar} label="Deadline" value={formatDate(drive.application_deadline)} />
          <InfoItem icon={Star} label="Min CGPA" value={drive.eligibility?.min_cgpa?.toString() || "N/A"} />
          <InfoItem icon={School} label="Grad Year" value={drive.eligibility?.graduation_year?.toString() || "N/A"} />
          <InfoItem icon={Users} label="Applicants" value={applicants.length.toString()} />
        </div>
      </div>

      <div className="bg-white p-8 rounded-2xl shadow-sm border border-gray-100">
        <h2 className="text-2xl font-bold text-[#21464E] mb-6">
          {applicants.length} Applicant(s)
        </h2>
        
        <div className="flex flex-col gap-4">
          {applicants.length > 0 ? (
            applicants.map((app: any) => (
              <ApplicantCard key={app.student_id} application={app} />
            ))
          ) : (
            <p className="text-gray-500 text-center py-4">
              There are no applications for this job drive yet.
            </p>
          )}
        </div>
      </div>
    </div>
  );
}

function InfoItem({ icon: Icon, label, value }: { icon: any; label: string; value: string }) {
  return (
    <div className="flex items-center gap-3">
      <div className="p-3 rounded-lg bg-[#5D9493]/10 text-[#5D9493]">
        <Icon size={20} />
      </div>
      <div>
        <p className="text-sm text-gray-500">{label}</p>
        <p className="font-semibold text-[#21464E]">{value}</p>
      </div>
    </div>
  );
}

function CircleAvatar({
  radius = 20,
  className = "",
  children,
}: {
  radius?: number;
  className?: string;
  children: React.ReactNode;
}) {
  const size = radius * 2;
  return (
    <div
      style={{ width: `${size}px`, height: `${size}px`, borderRadius: "50%" }}
      className={`flex items-center justify-center overflow-hidden ${className}`}
    >
      {children}
    </div>
  );
}

function ApplicantCard({ application }: { application: any }) {
  const getStatusColor = (status: string) => {
    switch (status.toLowerCase()) {
      case 'shortlisted': return "text-orange-600 bg-orange-50";
      case 'selected': return "text-green-600 bg-green-50";
      case 'rejected': return "text-red-600 bg-red-50";
      default: return "text-blue-600 bg-blue-50";
    }
  };

  return (
    <div className="border border-gray-200 rounded-xl p-4 flex items-center justify-between">
      <div className="flex items-center gap-3">
        <CircleAvatar
          radius={20}
          className="bg-gray-100 text-gray-600 font-semibold"
        >
          {application.student_name?.charAt(0) || "U"}
        </CircleAvatar>
        <div>
          <p className="font-semibold text-[#21464E]">{application.student_name || "Unknown Student"}</p>
          <p className="text-sm text-gray-500 flex items-center gap-1">
            <Mail size={14} /> {application.student_email || "No Email"}
          </p>
        </div>
      </div>
      <span className={`px-3 py-1 rounded-full text-xs font-bold ${getStatusColor(application.status)}`}>
        {application.status}
      </span>
    </div>
  );
}

