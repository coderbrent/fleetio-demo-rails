import React from "react";
import Footer from "./Footer";

export default function Layout({ children }) {
  return (
    <>
    <section className="container mx-auto px-4">
    <div className="mt-4 mb-2">
      <h1 className="text-3xl font-black">fleetio-ruby-demo</h1>
      <p className="mt-4 mb-2 font-light">
        This feature gauges the performance of a shop by determining the rate of efficiency that they operate on your vehicles at.
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
        <p>Using...</p>
        <li>rails 6</li>
        <li>rails-react</li>
        <li>rspec</li>
        <li>sinatra</li>
      <p className="mt-4 mb-2 font-light" aria-details>
        The Vendor Report Card averages out a service locations (RoE%) rate of efficiency by
        comparing the time a vehicle spent in the shop during open working hours versus the manufacturers suggested book hours for a given repair.
        It then renders a "Report Card" component that displays a letter grade ranging from A - F (A being a score of 60 or better).
        Listed below are the data points required to determine this rate, and how I accessed them for this feature.
      </p>
      <div className="mt-4 font-light">
        <h2 className="text-xl font-bold mb-2">The Data Points 📊</h2>
        <a title="link to source for this feature" href="https://github.com/coderbrent/fleetio-demo-rails/blob/189a5831cc81461229a628a4d3133401d5dfd81d/app/controllers/vendors_controller.rb#L142">
        <div className="mb-4 rounded-r-lg bg-green-500 text-white p-4">
          <h4 className="text-lg font-bold">Shop Hours</h4>
          <p className="mt-2 mb-2 font-light">
            The shops hours are crucial to determining an accurate efficiency rate 
            because any gauge of a shops output must consider the time
            they are available to work on your vehicles. There were two ways to obtain and store a shops schedule:
          </p>
            <li className="italic">
              Manual input from the user in the Fleetio UI.
            </li>
            <li className="italic">
              Sourced from an external API (what I did in this demo with the Google Places API).
            </li>
            <p className="mt-2 mb-2">
            This feature uses the Google Places API to request a shops hours and subsequently makes a PATCH request to
            the vendor profiles "shop_hours" custom field (stores as a string). Using custom fields was necessary for this demo
            project as most of the data points are not a part of the Fleetio API.
          </p>
            <p className="p-4 font-bold ">
            👉 In the future, I thought a nice additional feature would be to check whether a schedule exists online for the shop,
              and if it does not, provide a modal for the user to set the schedule manually.
            </p>
        </div>
        </a>
        <a title="link to source for this feature" href="https://github.com/coderbrent/fleetio-demo-rails/blob/189a5831cc81461229a628a4d3133401d5dfd81d/app/controllers/vendors_controller.rb#L12">
          <div className="mb-4 rounded-r-lg bg-blue-500 text-white p-4">
            <h4 className="text-lg font-bold">Book Hours</h4>
              <p>The service entries manufacturers suggested book time (manually input dummy data for now, but it looks like the Motor Driven API has manufacturer suggested book times).</p>
              <p>The book hours for a given service are calculated in the overall performance assessment.</p>
          </div>
        </a>
        <a title="link to source for this feature" href="https://github.com/coderbrent/fleetio-demo-rails/blob/189a5831cc81461229a628a4d3133401d5dfd81d/app/controllers/vendors_controller.rb#L42">
          <div className="mb-4 rounded-r-lg bg-purple-500 text-white p-4">
            <h4 className="text-lg font-bold">Repair Time</h4>
              <p>
                There's really no way to determine exactly how much time a shop is <span className="italic">actually</span> spending repairing your vehicle. 
                So I felt the next closest thing would be to determine the <span className="font-bold">potential time</span>. In other words, how long they're open while they have the vehicle.
            </p>
          </div> 
        </a>
        <h1 className="text-xl font-bold">Summary</h1>
        <p className="pr-4 pb-4">
          While admittedly all of this is a bit imperative, I was of course limited to working with custom fields only! Ideally,
          performance and time calculations would be performed programatically with the appropriate API integrations, leaving the only
          "manual" effort to capturing a shops open hours. I do hope you enjoyed checking out the feature and if you have any questions
          about it, please let me know!! 🙂
        </p>
      </div>
    </div>
    </section>
    <Footer />
  </>
  ) 
}