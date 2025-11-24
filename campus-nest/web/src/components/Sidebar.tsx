"use client";
import React from "react";
import Image from "next/image";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import {
  LayoutDashboard,
  Users,
  School,
  Briefcase,
  Megaphone,
  BarChart2,
  Download,
  LogOut,
} from "lucide-react";
import Router from "next/navigation";

const logoSrc = "/campusnest_logo.png";

const navItems = [
  { href: "/admin/dashboard", label: "Dashboard", icon: LayoutDashboard },
  { href: "/admin/students", label: "Students", icon: School },
  { href: "/admin/companies", label: "Companies", icon: Briefcase },
  { href: "/admin/tpos", label: "TPOs", icon: Users },
  { href: "/admin/drives", label: "Job Drives", icon: Briefcase },
  { href: "/admin/announcements", label: "Announce", icon: Megaphone },
  { href: "/admin/report", label: "Export Report", icon: Download },
];

export default function Sidebar() {
  const pathname = usePathname();
  const router = useRouter();

  const handleLogout = async () => {
    try {
      const res = await fetch("/api/logout", { method: "POST" });
      if (!res.ok) {
        console.error("Logout failed", await res.text());
      }
    } catch (err) {
      console.error("Logout error", err);
    } finally {
      router.push("/login");
    }
  };

  return (
    <nav className="w-64 h-full bg-white text-black flex flex-col p-4 shadow-lg border-r border-gray-200">
      <div className="flex items-center gap-3 px-3 py-4 mb-4">
        <Image
          src={logoSrc}
          alt="CampusNest Logo"
          width={40}
          height={40}
          className="rounded-lg"
        />
        <span className="text-xl font-bold text-[#21464E]">CampusNest</span>
      </div>

      <ul className="flex flex-col gap-2 flex-1">
        {navItems.map((item) => {
          const isActive = pathname === item.href;
          return (
            <li key={item.label}>
              <Link
                href={item.href}
                className={`
                  flex items-center gap-3 px-3 py-3 rounded-lg transition-all
                  ${
                    isActive
                      ? "bg-[#5D9493] text-white shadow-md" 
                      : "text-gray-500 hover:bg-gray-100 hover:text-black"
                  }
                `}
              >
                <item.icon size={20} />
                <span className="font-semibold">{item.label}</span>
              </Link>
            </li>
          );
        })}
      </ul>

      <div className="mt-auto" onClick={handleLogout}>
          <LogOut size={20} />
          <span className="font-semibold">Logout</span>
      </div>
    </nav>
  );
}