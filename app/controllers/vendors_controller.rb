class VendorsController < ApplicationController
  include HTTParty

  def all
    response = HTTParty.get("#{ENV['BASE_URL']}vendors", headers: {
      'Authorization' => "Token token=#{ENV['FLEETIO_API_KEY']}",
      'Account-Token' => ENV['FLEETIO_TOKEN']
    })
    render json: response.body
  end

  def performance #loops over all vendors service entries, adds all the efficiency rates and determines an average.
    id = params['id']

    response =
      HTTParty.get(
        "#{ENV['BASE_URL']}service_entries?q[vendor_id_eq]=#{id}",
        headers: {
          'Authorization' => "Token token=#{ENV['FLEETIO_API_KEY']}",
          'Account-Token' => ENV['FLEETIO_TOKEN']
        }
      )

    all_service_entries_by_vendor = JSON.parse(response.body)

    #grabs all efficiency rates (numbers) as an array
    all_efficiency_rates =
      all_service_entries_by_vendor.map do |service_entry|
        service_entry['custom_fields']['shop_efficiency_rate']
      end.compact

    #maps over vendors service entries and averages out the efficiency rates of each.
    overall_avg_efficiency =
      all_efficiency_rates
        .map(&:to_i)
        .inject(0) { |sum, x| sum + x } / all_service_entries_by_vendor.length

    render json: { name: all_service_entries_by_vendor.first['vendor_name'], id: id, average: overall_avg_efficiency }
  
  end

  def calculate_hours #service entry - determines and sets the job efficiency rate for a given service entry
    service_id = params['id'] # our specific service repair id
    
    service = # our service response from fleetio
      HTTParty.get(
        "#{ENV['BASE_URL']}service_entries/#{service_id}", 
        headers: {
          'Authorization' => "Token token=#{ENV['FLEETIO_API_KEY']}",
          'Account-Token' => ENV['FLEETIO_TOKEN']
        }
      )

    vendor =
      HTTParty.get(
        "#{ENV['BASE_URL']}vendors/#{service['vendor_id']}", headers: {
          'Authorization' => "Token token=#{ENV['FLEETIO_API_KEY']}",
          'Account-Token' => ENV['FLEETIO_TOKEN']
        }
      )

    vendor_res = JSON.parse(vendor.body)
    shop_schedule = vendor_res['custom_fields']['operating_hours']
      
    schedule_hash = #convert schedule (stored as a string in fleetio custom field) to a hash
      Hash[shop_schedule
        .split('\n')
        .map { |date| date
          .split(":", 2)
          .map(&:strip)
        }
      ]

      started_at = service['started_at'].to_datetime #ex output: Mon, 18 Jan 2021 11:47:00 -0500
      completed_at = service['completed_at'].to_datetime

      started_at_day = started_at.strftime("%A") #ex output: "Monday"
      completed_at_day = completed_at.strftime("%A")
      
      started_at_hours = schedule_hash[started_at_day] #ex output: 8:00 AM – 6:00 PM"
      completed_at_hours = schedule_hash[completed_at_day]
      total_down_time_hours = ((completed_at.to_time - started_at.to_time) / 1.hour) #ex output: 0.983333333
     
      start_day_open, start_day_close = schedule_hash[Date::DAYNAMES[started_at.wday]]
        .split('–')
        .map { |date| DateTime.parse(date) } #ex output: Tue, 19 Jan 2021 08:00:00 +0000

      total_days_down = (1..(started_at..completed_at).count).to_a #ex output: [1...or more]
  
      #loops over vendor schedule and sums up total shop availability time 
      total_hours_down = total_days_down.map do |day_num| 
        current_day = started_at + day_num.day 
        current_week_day = current_day.strftime("%A")
        current_day_schedule = schedule_hash[current_week_day]

        next if current_day_schedule == "Closed"
        
        open_time, close_time = current_day_schedule
        .split('–')
        .map { |date| DateTime.parse(date) }

        if total_days_down.count > 1
          ((close_time.to_time - open_time.to_time) / 1.hour).ceil
        else
          ((close_time.to_time - open_time.to_time) / 1.day).ceil
        end
      end.compact.inject(:+) #ex output: 1

      shop_book_hours = Float(service["custom_fields"]["book_time_hours"])
      
      if shop_book_hours.to_i < total_hours_down #if it took less time to complete than the book hours time
        job_efficiency_rate = ((Float(shop_book_hours.to_i) / Float(total_hours_down))) * 100
      else #otherwise, we reverse the equation so we're not getting funky numbers
        job_efficiency_rate = ((Float(total_hours_down) / Float(shop_book_hours.to_i))) * 100
      end

      if shop_book_hours.to_i === total_hours_down
        job_efficiency_rate = Float(100)
      end
    
      res = HTTParty.patch(
        "#{ENV["BASE_URL"]}service_entries/#{service_id}",
        headers: {
          'Authorization' => "Token token=#{ENV['FLEETIO_API_KEY']}",
          'Account-Token' => ENV['FLEETIO_TOKEN']
        },
        body: { 
          completed_at: service["completed_at"],
          custom_fields: {
            shop_efficiency_rate: job_efficiency_rate.floor
          }
        }
      )
    render json: res
  end

  def url_encoder(str)
    str.gsub(/ /, '%20')
  end

  #uses Google Places API to fetch shops hours based on stored address (name, lat, lng)
  def get_hours
    id = params['id']

    vendor = HTTParty.get("#{ENV['BASE_URL']}vendors/#{id}", headers: {
      'Authorization' => "Token token=#{ENV['FLEETIO_API_KEY']}",
      'Account-Token' => ENV['FLEETIO_TOKEN']
    })

    this_vendor = JSON.parse(vendor.body)

    vendor_name = this_vendor['name']
    lat = this_vendor['latitude']
    lng = this_vendor['longitude']

    place_id =
      HTTParty.get(
        "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=#{
          url_encoder(vendor_name)
        }&inputtype=textquery&locationbias=point:#{lat},#{lng}&key=#{
          ENV['GOOGLE_API_KEY']
        }",
      )

    place_id_response = JSON.parse(place_id.body)

    #TODO - offer user a choice of shops if there are more than one candidate from location bias

    vendor_place_id = place_id_response['candidates'][0]['place_id']

    open_hours_response = 
      HTTParty.get("https://maps.googleapis.com/maps/api/place/details/json?place_id=#{
      vendor_place_id}&fields=name,opening_hours&key=#{ENV['GOOGLE_API_KEY']}")

    vendors_hours = JSON.parse(open_hours_response.body)
    weekday_text = vendors_hours['result']['opening_hours']['weekday_text']

    puts weekday_text.join('\n')

    hour_update = HTTParty.patch(
      "#{ENV["BASE_URL"]}vendors/#{id}",
      headers: {
        'Authorization' => "Token token=#{ENV['FLEETIO_API_KEY']}",
        'Account-Token' => ENV['FLEETIO_TOKEN']
      },
      body: { 
        custom_fields: {
          operating_hours: weekday_text.join('\n')
        }
      }
    )
    render json: hour_update
  end
  
end
