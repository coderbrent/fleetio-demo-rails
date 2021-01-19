import React from "react"

const ShopPerformanceCard = ({ shopName, letterGrade, averages }) => {
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

export default ShopPerformanceCard;