import { cookies } from "next/headers";
import StatCard from "@/components/StatCard";
import DepartmentPlacementChart from "@/components/charts/DepartmentPlacementChart";
import TopCompaniesChart from "@/components/charts/TopCompaniesChart";
import RecentDrives from "@/components/RecentDrives";
import { School, Briefcase, TrendingUp, BarChartHorizontal } from "lucide-react";

// --- Live API Data Fetching ---
async function getAdminDashboardData() {
  const cookiesStore = await cookies();
  const token = cookiesStore.get("auth_token")?.value;
  console.log(token)

  if (!token) {
    throw new Error("Authentication token not found.");
  }

  const headers = { Authorization: `Bearer ${token}` };

  const url = "https://campusnest-backend-lkue.onrender.com/api/v1/admin/analytics/companies";

  try {
    const [placementsRes, companiesRes] = await Promise.all([
      fetch("https://campusnest-backend-lkue.onrender.com/api/v1/admin/analytics/placements", { headers, next: { revalidate: 60 } }),
      fetch("https://campusnest-backend-lkue.onrender.com/api/v1/admin/analytics/companies", { headers, next: { revalidate: 60 } }),
    ]);

    if (!placementsRes.ok) throw new Error(await placementsRes.text());
    if (!companiesRes.ok) throw new Error(await companiesRes.text());

    const placementsData = await placementsRes.json();
    const companiesData = await companiesRes.json();

    return { placementsData, companiesData };

  } catch (error) {
    console.error("Failed to fetch admin dashboard data:", error);
    return null;
  }
}

export default async function DashboardPage() {
  const data = await getAdminDashboardData();

  if (!data) {
    return <div className="p-6 text-dark font-semibold">Failed to load dashboard data. Please refresh.</div>;
  }

  // --- Parse all the data ---
  const placementsOverview = data.placementsData?.overview || {};
  const companiesSummary = data.companiesData?.summary || {};
  const placementRate = (placementsOverview.byStatus?.Placed / placementsOverview.totalStudents * 100) || 0;

  const kpis = [
    { title: "Total Students", value: placementsOverview.totalStudents || 0, icon: School, color: "text-orange-500" },
    { title: "Total Companies", value: companiesSummary.totalCompanies || 0, icon: Briefcase, color: "text-purple-500" },
    { title: "Active Drives", value: companiesSummary.activeDrives || 0, icon: BarChartHorizontal, color: "text-primary" },
    { title: "Placement Rate", value: `${placementRate.toFixed(1)}%`, icon: TrendingUp, color: "text-green-500" },
  ];

  return (
    <div className="flex flex-col gap-6">
      {/* 1. KPI Row */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {kpis.map((kpi) => (
          <StatCard
            key={kpi.title}
            title={kpi.title}
            value={kpi.value}
            icon={kpi.icon}
            color={kpi.color}
          />
        ))}
      </div>

      {/* 2. Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2">
          <DepartmentPlacementChart data={data.placementsData?.departments || []} />
        </div>
        <div>
          <TopCompaniesChart data={data.companiesData?.topByDrives || []} />
        </div>
      </div>
      <div>
        <RecentDrives drives={data.placementsData?.recentDrives || []} />
      </div>
    </div>
  );
}