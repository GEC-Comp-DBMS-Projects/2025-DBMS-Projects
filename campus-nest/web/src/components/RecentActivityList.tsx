// components/admin/RecentActivityList.tsx
import React from "react";
import { Briefcase, UserPlus, Megaphone } from "lucide-react";

// Helper to get icon based on activity type
const ActivityIcon = ({ type }: { type: string }) => {
  let icon = <Megaphone size={18} />;
  if (type === "company") icon = <Briefcase size={18} />;
  if (type === "student") icon = <UserPlus size={18} />;
  return <div className="p-2 bg-primary/10 text-primary rounded-lg">{icon}</div>;
};

export default function RecentActivityList({ activities }: { activities: any[] }) {
  return (
    <div className="bg-light p-6 rounded-2xl shadow-md h-full">
      <h3 className="text-lg font-bold text-dark mb-4">Recent Activity</h3>
      <div className="flex flex-col gap-4">
        {activities.length > 0 ? (
          activities.map((activity, index) => (
            <div key={index} className="flex items-center gap-3">
              <ActivityIcon type={activity.type} />
              <p className="text-sm text-dark/80">{activity.text}</p>
            </div>
          ))
        ) : (
          <p className="text-sm text-gray-500">No recent activities found.</p>
        )}
      </div>
    </div>
  );
}