import React from "react";

const gradeColorizer = grade => {
  switch(grade) {
    case 'A': return 'text-green-500 text-6xl';
    case 'B': return 'text-blue-500 text-6xl';
    case 'C': return 'text-yellow-500 text-6xl';
    case 'D': return 'text-pink-500 text-6xl';
    case 'F': return 'text-red-500 text-6xl';
    default: return null;
  }
};

const grader = grade => {
  if(grade <= 20) { 
    return 'F'
  } else if(grade <= 30) {
    return 'D'
  } else if(grade <= 40) {
    return 'C'
  } else if (grade <= 50) {
    return 'B'
  } else if (grade > 60) {
    return 'A'
  }
};

const ReportCard = ({ shopName, letterGrade, averages }) => {
  return (
  <>
    <div className="w-full max-w-md bg-white shadow m-4 p-4">
      <div className="flex flex-row items-center justify-between">
        <span className="text-base font-semibold">Shop Report Card</span>
        <span className="text-base">{shopName}</span>
        <a 
          href="https://fleetio-demo.herokuapp.com"
          className="text-sm text-blue-400"
        >
          Details >
        </a>
      </div>
      <div className="">
        <div 
          id="grade-container" 
          className={`${gradeColorizer(letterGrade)} p-2`}>
            {letterGrade}
        </div>
        <div className="w-full flex items-center justify-between">
          <span className="font-semibold">Avg. repair cost (not implemented)</span>
          <span className="font-semibold">{averages.repair_cost}</span>
        </div>
        <div className="w-full flex items-center justify-between">
          <span className="font-semibold">Avg. downtime (not implemented)</span>
          <span className="font-semibold">{averages.down_time}</span>
        </div>
        <div className="w-full flex items-center justify-between">
          <span className="font-semibold">Avg. issue rate (not implemented)</span>
          <span className="font-semibold">{averages.issues}</span>
        </div>
      </div>
    </div>
  </>
)};

export default ReportCard;