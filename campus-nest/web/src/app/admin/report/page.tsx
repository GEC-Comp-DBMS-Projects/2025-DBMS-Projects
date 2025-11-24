import { Download, FileText, Calendar, Users } from "lucide-react";
import ReportDownloader from "@/components/ReportDownloader"; 

export default function ReportPage() {
  return (
    <div className="flex flex-col gap-6 p-6 max-w-5xl mx-auto">
      <div className="mb-2">
        <h1 className="text-3xl font-bold text-[#21464E]">Export Reports</h1>
        <p className="text-gray-500 mt-2">
          Generate and download comprehensive placement reports
        </p>
      </div>

      <div className="bg-white p-8 rounded-2xl shadow-sm border border-gray-100">
        <div className="flex items-start gap-4 mb-6">
          <div className="p-4 rounded-xl bg-[#5D9493]/10 text-[#5D9493]">
            <FileText size={28} />
          </div>
          <div className="flex-1">
            <h2 className="text-2xl font-bold text-gray-800">
              Placement Report
            </h2>
            <p className="text-gray-600 mt-2 leading-relaxed">
              Generate a comprehensive PDF report with complete placement
              statistics, department-wise analysis, and company details.
            </p>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 my-6">
          <div className="bg-gray-50 rounded-xl p-4 border border-gray-100">
            <div className="flex items-center gap-3">
              <div className="p-2 rounded-lg bg-[#5D9493]/10 text-[#5D9493]">
                <Users size={20} />
              </div>
              <div>
                <p className="text-sm text-gray-500">Includes</p>
                <p className="font-semibold text-gray-800">All Departments</p>
              </div>
            </div>
          </div>

          <div className="bg-gray-50 rounded-xl p-4 border border-gray-100">
            <div className="flex items-center gap-3">
              <div className="p-2 rounded-lg bg-[#5D9493]/10 text-[#5D9493]">
                <FileText size={20} />
              </div>
              <div>
                <p className="text-sm text-gray-500">Format</p>
                <p className="font-semibold text-gray-800">PDF Document</p>
              </div>
            </div>
          </div>

          <div className="bg-gray-50 rounded-xl p-4 border border-gray-100">
            <div className="flex items-center gap-3">
              <div className="p-2 rounded-lg bg-[#5D9493]/10 text-[#5D9493]">
                <Calendar size={20} />
              </div>
              <div>
                <p className="text-sm text-gray-500">Period</p>
                <p className="font-semibold text-gray-800">Current Year</p>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-[#5D9493]/10 border border-[#5D9493]/20 rounded-xl p-4 mb-6">
          <h3 className="font-semibold text-gray-800 mb-2">Report Contents</h3>
          <ul className="space-y-2 text-sm text-gray-700">
            <li className="flex items-center gap-2">
              <div className="w-1.5 h-1.5 rounded-full bg-[#5D9493]"></div>
              Department-wise placement statistics and trends
            </li>
            <li className="flex items-center gap-2">
              <div className="w-1.5 h-1.5 rounded-full bg-[#5D9493]"></div>
              Complete list of recruiting companies
            </li>
            <li className="flex items-center gap-2">
              <div className="w-1.5 h-1.5 rounded-full bg-[#5D9493]"></div>
              Student placement details and salary packages
            </li>
            <li className="flex items-center gap-2">
              <div className="w-1.5 h-1.5 rounded-full bg-[#5D9493]"></div>
              Visual charts and comparative analysis
            </li>
          </ul>
        </div>

        <ReportDownloader />

        <p className="text-xs text-gray-500 text-center mt-4">
          The report will be downloaded as a PDF file to your device
        </p>
      </div>
    </div>
  );
}