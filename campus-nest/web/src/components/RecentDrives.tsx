// components/admin/RecentDrives.tsx
import React from "react";
import { Briefcase, Users, Check, Star } from "lucide-react";

export default function RecentDrives({ drives }: { drives: any[] }) {
  return (
    <div className="bg-light p-6 rounded-2xl shadow-md">
      <h3 className="text-lg font-bold text-dark mb-4">Recent Job Drives</h3>
      <div className="flex flex-col gap-4">
        {drives.length > 0 ? (
          drives.map((drive) => (
            <div key={drive.jobId} className="flex items-center gap-4 p-4 rounded-lg bg-gray-50 hover:bg-gray-100">
              <div className="p-3 bg-primary/10 text-primary rounded-lg">
                <Briefcase size={20} />
              </div>
              <div className="flex-1">
                <p className="font-semibold text-dark">{drive.title}</p>
                <div className="flex gap-4 text-gray-600 text-sm mt-1">
                  <span className="flex items-center gap-1"><Users size={14} /> {drive.applicants} Applicants</span>
                  <span className="flex items-center gap-1"><Star size={14} /> {drive.shortlisted} Shortlisted</span>
                </div>
              </div>
              <span className="text-sm font-medium text-gray-500">
                {/* Add a date formatter if 'postedAt' is available */}
              </span>
            </div>
          ))
        ) : (
          <p className="text-sm text-gray-500">No recent drives found.</p>
        )}
      </div>
    </div>
  );
}