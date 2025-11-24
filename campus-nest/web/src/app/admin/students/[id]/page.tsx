import React from "react";

type PageProps = {
  params: { id: string };
};

// This will be a Server Component that fetches data for one student
export default async function StudentDetailPage({ params }: PageProps) {
  
  // TODO: Fetch data for this specific student using params.id
  // const student = await getStudentById(params.id);

  return (
    <div className="bg-white p-8 rounded-2xl shadow-sm border border-gray-100">
      <h1 className="text-2xl font-bold text-[#21464E]">
        Student Profile: {params.id}
      </h1>
      <p className="text-gray-500 mt-2">
        A detailed profile view will be built here, showing the student's skills,
        resumes, and application history.
      </p>
    </div>
  );
}
