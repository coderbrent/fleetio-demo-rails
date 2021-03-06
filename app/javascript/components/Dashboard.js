import React, { useState, useEffect } from "react";
import ReportCard from "../components/ReportCard";
import Layout from "./Layout";

const averages = {
  down_time: "10 days",
  repair_cost: "$250",
  issues: "2.57 a month"
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
  } else if (grade >= 60) {
    return 'A'
  }
};

function Dashboard() {
  const [score, setScore] = useState([]);
  const [vendors, setVendors] = useState([]);

  const getShopPerformanceCard = shopID => {
    fetch(`/vendors/performance/${shopID}`)
      .then(res => res.json())
      .then(data => { 
        setScore([data])
      });
  };

  useEffect(() => {
    fetch(`/vendors/all`)
      .then(res => res.json())
      .then(data => { 
        setVendors(data) 
      });
  }, []);

  return (
    <>
    <Layout>
        <div className="App flex flex-col flex-wrap items-center justify-center bg-gray-100">
          <div className="container auto-mx">
            <select onChange={e => getShopPerformanceCard(e.target.value)}>
              {vendors.map(vendor => (
                <option value={vendor.id} key={vendor.id}>
                  {vendor.name}
                </option>
              ))}
            </select>
          </div>
          <div>
          {score
            ? score.map(el => (
                <ReportCard
                  key={el.id}
                  shopName={el.name}
                  averages={averages}
                  letterGrade={grader(el.average)}
                />
              ))
            : null}
          </div>
        </div>
      </Layout>
    </>
  );
}

export default Dashboard;
