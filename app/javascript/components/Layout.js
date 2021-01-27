import React from "react";
import Footer from "./Footer";

export default function Layout({ children }) {
  return (
    <>
    <section className="container mx-auto px-4">
    <div className="mt-4 mb-2">
      <h1 className="text-3xl font-black">Hi, Senthil!</h1>
      <p className="mt-4 mb-2 font-light">
        I hope you are doing well! 🙂
        After our last conversation, I made the decision to pick up Rails so as to make a stronger case for myself
        becoming a developer on the Fleetio team. My goal was to learn enough to port my original Node/React project to a Rails/React project.
        So during my free time over the last few weeks I began studying Rails and I've now completed the port!
        I've kept the original overview of the feature below.
      </p>
      <h1 className="text-xl font-bold">About the feature</h1>
      <p className="mt-2 font-light">
        After brainstorming on a few ideas, I decided on a "Vendor Report Card" feature. The criteria I decided on for this feature is as follows:
      </p>
      <div className="mt-4 mb-2 ml-4">
        <li>Something not already implemented in Fleetio</li>
        <li>Something I personally would have loved to see as a fleet manager</li>
        <li>Fits in with the rest of the Fleetio UI</li>
        <span className="mt-4">👇 👇 👇 Click the dropdown and select a vendor to view their Report Card!</span>
      </div>
    </div>
    </section>
    { children }
    <section className="mt-4 container mx-auto">
    <div className="mt-4 mb-2">
      <h1 className="text-xl font-bold">How it works 🔨</h1>
      <p className="mt-4 mb-2 font-light">
        The Vendor Report Card averages out a service locations (RoE%) rate of efficiency by
        comparing the time a vehicle spent in the shop during open working hours versus the manufacturers suggested book hours for a given repair.
        It then renders a "Report Card" component that displays a letter grade ranging from A - F (A being a score of 60 or better).
        Listed below are the data points required to determine this rate, and how I accessed them for this feature.
      </p>
      <div className="mt-4 font-light">
        <h2 className="text-xl font-bold mb-2">The Data Points 📊</h2>
        <div className="mb-4 rounded-r-lg bg-green-500 text-white p-4">
          <h4 className="text-lg font-bold">Shop Hours: </h4>
          <p className="mt-2 mb-2 font-light">
            The shops hours are crucial to determining an accurate efficiency rate 
            because any gauge of a shops output must consider the time
            they are available to work on your vehicles. There were two ways to obtain and store a shops schedule:
          </p>
            <li>
              Manual input from the user in the Fleetio UI.
            </li>
            <li>
              Sourced from an external API (what I did in this demo with the Google Places API).
            </li>
            <p className="mt-2 mb-2">
            This feature leverages the Google Places API to determine a shops hours and makes a PATCH request to
            its vendor profiles "shop_hours" custom field (stores as a string).
          </p>
            <p className="p-4 font-bold ">
            👉 In the future, I thought a nice additional feature would be to check whether a schedule exists online for the shop,
              and if it does not, provide a modal for the user to set the schedule manually.
            </p>
        </div>
        <div className="mb-4 rounded-r-lg bg-blue-500 text-white p-4">
          <h4 className="text-lg font-bold">Book Hours:</h4>
          <p>The service entries manufacturers suggested book time (manually input dummy data for now, but it looks like the Motor Driven API has manufacturer suggested book times)</p>
        </div> 
        <div className="mb-4 rounded-r-lg bg-purple-500 text-white p-4">
          <h4 className="text-lg font-bold">Repair Time:</h4>
          <p>The total time (less the non-workable off hours) that the shop had the vehicle in service.</p>
        </div> 
      </div>
    </div>
    </section>
    <Footer />
  </>
  ) 
}