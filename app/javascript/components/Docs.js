import React from "react";

export const Docs = () => {
  return (
    <section className="container mx-auto px-4">
    <div className="mt-4 mb-2">
      <h1 className="text-3xl font-black">Hi, Senthil!</h1>
      <p className="mt-4 mb-2 font-light">
        It's me again! 🙂
        After our last conversation, I made the decision to pick up Ruby/Rails so as to make a stronger case for myself
        as a Fleetio developer. My goal was to learn enough to port my original Node/React project to a Rails/React project.
        So during my free time over the last few weeks I began studying Rails and I've now completed the port.
        I've kept the original overview of the feature below.
        
      </p>
      <h1 className="text-xl font-bold">About the feature</h1>
      <p className="mt-2 font-light">
        After brainstorming on a few ideas, I decided on a "Vendor Report Card" feature. The criteria for my
        decision to do this was:
      </p>
      <div className="mt-4 mb-2 ml-4">
        <li>Not already implemented in Fleetio</li>
        <li>Something I personally would have loved to see as a fleet manager</li>
        <li>Fit in with the rest of the Fleetio UI</li>
      </div>
     
    </div>
    <div className="mt-4 mb-2">
      <h1 className="text-xl font-bold">How it works</h1>
      <p className="mt-4 mb-2 font-light">
        In a nutshell, the Vendor Report Card will average out a service locations (RoE%) rate of efficiency
        by determining the following:
      </p>
      <div className="mt-4 mb-2 ml-4 font-light">
        <li><b>Shop Hours:</b> When they can work on your vehicle (src: Google Places API/GMB Hours)</li>
        <li><b>Book Hours:</b> The service entries manufacturers suggested book time (manually input dummy data for now, but it looks like the Motor Driven API has manufacturer suggested book times)</li>
        <li><b>Actual Time Repair Took:</b> The total time (less the non-workable off hours) that the shop had the vehicle in service</li>
      </div>
      <p className="mt-4 font-light">
        The Letter Grade on the component is calculated on real repairs sourced from my Fleetio account. The book hours(service entries) and shop hours(vendors) data are stored as custom fields on there respective entities.
      </p>
      <p className="mt-4 font-light">To see the feature in action, select a vendor from the dropdown below.</p>
    </div>
    </section>
  )
};