"use client";

import React, { useTransition, useRef, useState } from "react";
import { Loader2, Download } from "lucide-react";
import { jsPDF } from "jspdf";
import autoTable from "jspdf-autotable";
import { getReportData } from "@/app/admin/report/action";

import {
  BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid, PieChart, Pie, Cell, Legend, LineChart, Line
} from "recharts";
import { toPng } from "html-to-image";

const COLORS = ["#5D9493", "#8CA1A4", "#F39C12", "#8E44AD", "#27AE60", "#3498DB", "#E74C3C"];
const primaryColorHex = "#5D9493";

const chartWrapperStyle: React.CSSProperties = {
  width: '650px', 
  height: '300px',
  backgroundColor: '#ffffff',
  padding: '16px',
  boxSizing: 'border-box'
};

const DeptChart = ({ data }: { data: any[] }) => (
  <div style={chartWrapperStyle}>
    <ResponsiveContainer width="100%" height="100%">
      <BarChart data={data} margin={{ top: 5, right: 0, left: 0, bottom: 40 }}>
        <CartesianGrid strokeDasharray="3 3" strokeOpacity={0.2} />
        <XAxis dataKey="department" fontSize={10} angle={-20} textAnchor="end" height={50} />
        <YAxis tickFormatter={(tick) => `${tick.toFixed(0)}%`} fontSize={10} />
        <Tooltip />
        <Bar dataKey="placementRate" fill={primaryColorHex} radius={[4, 4, 0, 0]} isAnimationActive={false} />
      </BarChart>
    </ResponsiveContainer>
  </div>
);

const GenderChart = ({ data }: { data: any[] }) => (
  <div style={{...chartWrapperStyle, width: '400px', height: '250px'}}>
    <ResponsiveContainer width="100%" height="100%">
      <PieChart>
        <Pie data={data} dataKey="count" nameKey="gender" cx="50%" cy="50%" outerRadius={80} isAnimationActive={false}>
          {data.map((entry, index) => (
            <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
          ))}
        </Pie>
        <Tooltip />
        <Legend />
      </PieChart>
    </ResponsiveContainer>
  </div>
);

const RolesChart = ({ data }: { data: any[] }) => (
  <div style={chartWrapperStyle}>
    <ResponsiveContainer width="100%" height="100%">
      <BarChart data={data.slice(0, 5)} layout="vertical" margin={{ top: 5, right: 10, left: 150, bottom: 0 }}>
        <CartesianGrid strokeDasharray="3 3" strokeOpacity={0.2} />
        <XAxis type="number" fontSize={10} allowDecimals={false} />
        <YAxis dataKey="role" type="category" fontSize={10} width={150} />
        <Tooltip />
        <Bar dataKey="count" fill={primaryColorHex} radius={[0, 4, 4, 0]} isAnimationActive={false} />
      </BarChart>
    </ResponsiveContainer>
  </div>
);

const TrendChart = ({ data }: { data: any[] }) => (
  <div style={chartWrapperStyle}>
    <ResponsiveContainer width="100%" height="100%">
      <LineChart data={data} margin={{ top: 5, right: 10, left: 0, bottom: 20 }}>
        <CartesianGrid strokeDasharray="3 3" strokeOpacity={0.2} />
        <XAxis dataKey="period" fontSize={10} />
        <YAxis tickFormatter={(tick) => `${tick.toFixed(0)}%`} fontSize={10} />
        <Tooltip />
        <Line type="monotone" dataKey="placementRate" stroke={primaryColorHex} strokeWidth={2} isAnimationActive={false} />
      </LineChart>
    </ResponsiveContainer>
  </div>
);

export default function ReportDownloader() {
  const [isPending, startTransition] = useTransition();
  const [reportData, setReportData] = useState<any>(null);

  const deptChartRef = useRef<HTMLDivElement>(null);
  const genderChartRef = useRef<HTMLDivElement>(null);
  const rolesChartRef = useRef<HTMLDivElement>(null);
  const trendChartRef = useRef<HTMLDivElement>(null);

  const checkAddPage = (doc: jsPDF, startY: number, requiredSpace = 0): number => {
    const pageBottomLimit = 270;
    if (startY + requiredSpace > pageBottomLimit) {
      doc.addPage();
      return 20; 
    }
    return startY;
  };

  const addSectionDivider = (doc: jsPDF, y: number): number => {
    doc.setDrawColor(93, 148, 147);
    doc.setLineWidth(0.5);
    doc.line(14, y, 196, y);
    return y + 10;
  };

  const addSectionTitle = (doc: jsPDF, title: string, y: number): number => {
    y = checkAddPage(doc, y, 20); 
    doc.setFontSize(18);
    doc.setFont("helvetica", "bold");
    doc.setTextColor(33, 70, 78);
    doc.text(title, 14, y);
    return y + 3;
  };

  const addChart = async (doc: jsPDF, ref: React.RefObject<HTMLDivElement>, y: number): Promise<number> => {
    y = checkAddPage(doc, y, 100);
    try {
      if (ref.current) {
        const img = await toPng(ref.current, { backgroundColor: '#ffffff', pixelRatio: 2 });
        doc.addImage(img, "PNG", 14, y, 180, 90);
        return y + 95;
      }
    } catch (e) {
      console.error("Chart conversion failed:", e);
      doc.setFontSize(10);
      doc.setTextColor(150, 150, 150);
      doc.text("Chart not available", 105, y + 40, { align: "center" });
      return y + 80;
    }
    return y;
  };

  const generatePdf = async (data: any) => {
    const doc = new jsPDF();
    const today = new Date(data.generatedAt || new Date()).toLocaleDateString();
    
    const primaryColor: [number, number, number] = [93, 148, 147];
    const darkColor: [number, number, number] = [33, 70, 78];

    const [deptChartImg, genderChartImg, rolesChartImg, trendChartImg] = await Promise.all([
      toPng(deptChartRef.current!, { backgroundColor: "#ffffff", pixelRatio: 2 }).catch(e => { console.error(e); return null; }),
      toPng(genderChartRef.current!, { backgroundColor: "#ffffff", pixelRatio: 2 }).catch(e => { console.error(e); return null; }),
      toPng(rolesChartRef.current!, { backgroundColor: "#ffffff", pixelRatio: 2 }).catch(e => { console.error(e); return null; }),
      toPng(trendChartRef.current!, { backgroundColor: "#ffffff", pixelRatio: 2 }).catch(e => { console.error(e); return null; }),
    ]);
    console.log("Chart images captured.");

    doc.setFillColor(darkColor[0], darkColor[1], darkColor[2]);
    doc.rect(0, 0, 210, 100, 'F');
    doc.setTextColor(255, 255, 255);
    doc.setFont("helvetica", "bold");
    doc.setFontSize(28);
    doc.text("CAMPUSNEST", 105, 40, { align: "center" });
    doc.setFontSize(20);
    doc.setFont("helvetica", "normal");
    doc.text(data.reportTitle || "Placement Report", 105, 55, { align: "center" });
    doc.setFontSize(12);
    doc.setTextColor(200, 200, 200);
    doc.text(`Generated on: ${today}`, 105, 70, { align: "center" });
    doc.setFillColor(primaryColor[0], primaryColor[1], primaryColor[2]);
    doc.rect(0, 95, 210, 5, 'F');

    const summary = data.summary || {};
    let startY = 115;
    startY = addSectionTitle(doc, "Key Metrics", 115);
    startY = addSectionDivider(doc, startY);
    
    const metrics = [
      { label: "Total Students", value: summary.totalStudents || 0 },
      { label: "Placed Students", value: summary.placed || 0 },
      { label: "Unplaced Students", value: summary.unplaced || 0 },
      { label: "Job Postings", value: summary.totalJobPostings || 0 },
      { label: "Placement Rate", value: `${(summary.placementRate || 0).toFixed(1)}%` },
      { label: "Average CGPA", value: (summary.averageCGPA || 0).toFixed(2) },
    ];
    autoTable(doc, {
      startY: startY,
      theme: "striped",
      headStyles: { fillColor: primaryColor },
      body: metrics.map(m => [m.label, m.value])
    });
    startY = (doc as any).lastAutoTable.finalY + 15;

    doc.addPage();
    startY = 20;
    startY = addSectionTitle(doc, "Department-wise Analysis", startY);
    startY = addSectionDivider(doc, startY);

    if (deptChartImg) {
      doc.addImage(deptChartImg, "PNG", 14, startY, 180, 90);
      startY += 95;
    }

    const departmentSummary = data.departmentSummary || [];
    autoTable(doc, {
      startY: startY,
      theme: "grid",
      headStyles: { fillColor: primaryColor, fontSize: 10, fontStyle: "bold" },
      bodyStyles: { fontSize: 9, halign: "center" },
      head: [["Dept", "Total", "Placed", "Unplaced", "Rate (%)", "Avg. CGPA"]],
      body: departmentSummary.map((dept: any) => [
        dept.department,
        dept.totalStudents,
        dept.placed,
        dept.unplaced,
        (dept.placementRate || 0).toFixed(1),
        (dept.averageCGPA || 0).toFixed(2),
      ]),
    });

    // --- DEMOGRAPHICS & ROLE ANALYSIS ---
    startY = (doc as any).lastAutoTable.finalY + 15;
    startY = checkAddPage(doc, startY, 120);
    startY = addSectionTitle(doc, "Gender Distribution & Role Analysis", startY);
    startY = addSectionDivider(doc, startY);

    // layout two charts side-by-side to avoid overlap
    const leftX = 14;
    const rightX = 105;
    const imgW = 88;
    const imgH = 70;
    const imgTop = startY + 5;

    // Gender chart (left)
    if (genderChartImg) {
      doc.addImage(genderChartImg, "PNG", leftX, imgTop, imgW, imgH);
    } else {
      doc.setFontSize(10);
      doc.setTextColor(150, 150, 150);
      doc.text("Gender chart not available", leftX + imgW / 2, imgTop + imgH / 2, { align: "center" });
    }

    // Roles chart (right)
    if (rolesChartImg) {
      doc.addImage(rolesChartImg, "PNG", rightX, imgTop, imgW, imgH);
    } else {
      doc.setFontSize(10);
      doc.setTextColor(150, 150, 150);
      doc.text("Roles chart not available", rightX + imgW / 2, imgTop + imgH / 2, { align: "center" });
    }

    // Advance Y to below the charts so following content won't overlap
    startY = imgTop + imgH + 12;
    
    const roleGap = data.roleAnalysis?.roleGap || {};
    doc.setFontSize(14);
    doc.setFont("helvetica", "bold");
    doc.text("Role Statistics", 130, startY);
    autoTable(doc, {
      startY: startY + 5,
      startX: 125,
      theme: "plain",
      styles: { cellPadding: 2, fontSize: 10 },
      body: [
        ["Roles Offered:", roleGap.rolesOffered || 0],
        ["Roles Placed:", roleGap.rolesPlaced || 0],
      ],
    });
    startY += 80;

    // --- COMPANY ANALYTICS ---
    startY = checkAddPage(doc, startY, 80);
    startY = addSectionTitle(doc, "Company Analytics", startY);
    startY = addSectionDivider(doc, startY);

    const topCompaniesDrives = data.companyAnalytics?.topByDrives || [];
    autoTable(doc, {
      startY: startY,
      theme: "grid",
      headStyles: { fillColor: primaryColor, fontSize: 10, fontStyle: "bold" },
      bodyStyles: { fontSize: 9 },
      head: [["Top Companies (by Drives)", "Drive Count"]],
      body: topCompaniesDrives.map((company: any) => [company.companyName, company.jobDriveCount]),
    });
    
    const topCompaniesHires = data.companyAnalytics?.topByHires || [];
    if(topCompaniesHires) {
      autoTable(doc, {
        startY: (doc as any).lastAutoTable.finalY + 5,
        theme: "grid",
        headStyles: { fillColor: darkColor, fontSize: 10, fontStyle: "bold" },
        bodyStyles: { fontSize: 9 },
        head: [["Top Companies (by Hires)", "Hire Count"]],
        body: topCompaniesHires.map((company: any) => [company.companyName, company.hires]),
      });
    }

    // --- JOB ROLES ---
    const rolesOffered = data.charts?.jobRolesOffered || [];
    startY = (doc as any).lastAutoTable.finalY + 15;
    startY = checkAddPage(doc, startY, 100);
    
    startY = addSectionTitle(doc, "Most Demanded Job Roles", startY);
    startY = addSectionDivider(doc, startY);

    if (rolesChartImg) {
      doc.addImage(rolesChartImg, "PNG", 14, startY, 180, 90);
      startY += 95;
    }
    
    // Force the roles table to start on a new page
    doc.addPage();
    startY = 20;
    autoTable(doc, {
      startY,
      theme: "striped",
      headStyles: { fillColor: primaryColor, fontSize: 10, fontStyle: "bold" },
      bodyStyles: { fontSize: 9, halign: "left" },
      columnStyles: { 1: { halign: "center" } },
      head: [["Job Role", "Number of Openings"]],
      body: rolesOffered.map((role: any) => [role.role, role.count]),
    });
    startY = (doc as any).lastAutoTable.finalY + 15;
    
    // --- PLACEMENT TREND ---
    const trendData = data.placementStats?.trend?.data || [];
    if (trendData.length > 0) {
      startY = (doc as any).lastAutoTable.finalY + 15;
      startY = checkAddPage(doc, startY, 100);
      
      startY = addSectionTitle(doc, "Placement Trend", startY);
      startY = addSectionDivider(doc, startY);
      
      if (trendChartImg) {
        doc.addImage(trendChartImg, "PNG", 14, startY, 180, 90);
      }
    }

    // --- FOOTER ON EVERY PAGE ---
    const pageCount = doc.getNumberOfPages();
    for (let i = 1; i <= pageCount; i++) {
      doc.setPage(i);
      doc.setFontSize(8);
      doc.setTextColor(150, 150, 150);
      doc.text(`Page ${i} of ${pageCount}`, 105, 287, { align: "center" });
      doc.text("© 2025 CampusNest - Confidential", 14, 287);
    }

    // --- Save the PDF ---
    doc.save(`CampusNest_Placement_Report_${today.replace(/\//g, "-")}.pdf`);
  };

  // --- Data Fetching & Button Click Handler (FIXED) ---
  const handleDownloadClick = () => {
    startTransition(async () => {
      try {
        const result = await getReportData(); // Fetch live data
        
        if (!result.success || !result.data) {
          throw new Error(result.error || "Failed to get data");
        }
        
        const data = result.data;
        console.log("Report data fetched:", data);
        
        // Set state to render hidden charts
        setReportData(data);

        // Give React a moment to render
        await new Promise(resolve => setTimeout(resolve, 1000)); 
        
        await generatePdf(data);
        setReportData(null); // Clear data

      } catch (error) {
        console.error(error);
        if (error instanceof Error) {
          alert(`Failed to download report: ${error.message}`);
        } else {
          alert("An unknown error occurred. Check console for details.");
        }
      }
    });
  };

  return (
    <>
      {/* This div is hidden and is only used to render the charts */}
      {reportData && (
        <div className="fixed -z-10 -left-[2000px] top-0 opacity-0 pointer-events-none">
          <div ref={deptChartRef}>
            <DeptChart data={reportData.departmentSummary || []} />
          </div>
          <div ref={genderChartRef}>
            <GenderChart data={reportData.charts?.genderDistribution || []} />
          </div>
          <div ref={rolesChartRef}>
            <RolesChart data={reportData.charts?.jobRolesOffered || []} />
          </div>
          <div ref={trendChartRef}>
            <TrendChart data={reportData.placementStats?.trend?.data || []} />
          </div>
        </div>
      )}
    
      {/* This is the visible button */}
      <button
        onClick={handleDownloadClick}
        disabled={isPending}
        className="w-full bg-[#5D9493] hover:bg-[#21464E] text-white font-semibold py-3 px-6 rounded-xl transition-colors duration-200 flex items-center justify-center gap-2 shadow-lg hover:shadow-xl"
      >
        {isPending ? (
          <Loader2 className="animate-spin" size={20} />
        ) : (
          <Download size={20} />
        )}
        {isPending ? "Generating..." : "Download Report"}
      </button>
    </>
  );
}

