# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version
Ruby 2.7.2 Rails 6.10


<h3>How does it help Fleetio?</h3>

- I’m assuming a large portion of Fleetio's client base are small fleets (10 - 30 units). Generally, smaller outfits tend to outsource their maintenance and repair work to local shops and chains. That makes this feature attractive to the majority of existing Fleetio customers. 

- A feature like this would be very attractive to potential customers, making it a strong selling point to add to the already wide array of features that make Fleetio such an incredible piece of software.

<h3>KPIs</h3>
I've identified some KPIs for *vendor service shops*. This type of vendor (in Fleetio) performs work on site (as opposed to fueling only/parts only). These are your Tire shops, Transmission shops, general mechanic shops, etc.

- Efficiency - A service vendor's efficiency can either make or break a fleet based business. Many fleet managers will compare one shop to another, ie. "Joe's Auto Body always seems to get us back on the road faster than the local Maaco". I think a more accurate way is to compare a shops actual time vs. book time performance on a job by job basis. That will be the metric this demo focuses on.

    Edge cases I considered in this demo:
    
    - Off hours: A shop's efficiency rating should *not* be penalized for not performing work when they are closed. I created a sub-feature in Node that, with the help of the Google Places API and some existing Fleetio data, fetches the shops operating hours and stores them as a custom text field on the vendor. With this feature, the vendors "hours" can then be checked to properly determine when they **can** actually work on vehicles!

    - Book hours: For the purposes of this demo, I simply created dummy service entries and added a custom "book hours" field for the given job. This "book hours" number is compared to the "actual" time (aka. the "workable" hours a shop had your car starting from the day it went in to the day it was completed), a rate is determined and later averaged out over all the given shops service entries. I did notice that Fleetio uses Motor Driven for OEM maintenance schedules - I thought this would make for a really cool use of their API. 