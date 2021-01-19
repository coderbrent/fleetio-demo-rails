class VendorsController < ApplicationController
  include HTTParty

  def all
    response = HTTParty.get("#{ENV['BASE_URL']}vendors", headers: headers)
    render component: 'Dashboard', props: { state: response.body }
  end

  def performance
    id = params['id']

    response =
      HTTParty.get(
        "#{ENV['BASE_URL']}service_entries?q[vendor_id_eq]=#{id}",
        headers: headers
      )

    all_service_entries_by_vendor = JSON.parse(response.body)

    all_efficiency_rates =
      all_service_entries_by_vendor.map do |service_entry|
        service_entry['custom_fields']['shop_efficiency_rate']
      end.compact

    overall_avg_efficiency =
      all_efficiency_rates
        .map(&:to_i)
        .inject(0) { |sum, x| sum + x } / all_service_entries_by_vendor.length

    render json: {
      name: all_service_entries_by_vendor.first['vendor_name'],
      id: id,
      average: overall_avg_efficiency
    }
  
  end

  def calculate_hours
    service_id = params['id'] # our specific service repair id
    
    service = # our service response from fleetio
      HTTParty.get(
        "#{ENV['BASE_URL']}service_entries/#{service_id}", 
        headers: headers
      )

    vendor = # the shop that performed the service 
      HTTParty.get(
        "#{ENV['BASE_URL']}vendors/#{service['vendor_id']}", headers: headers
      )

    vendor_res = JSON.parse(vendor.body) # parsed vendor api response
    shop_schedule = vendor_res['custom_fields']['operating_hours'] # vendors operating schedule
      
    schedule_hash = #convert schedule string to a hash
      Hash[shop_schedule
        .split('\n')
        .map { |date| date
          .split(":", 2)
          .map(&:strip)
        }
      ]

      started_at = service['started_at'].to_datetime
      completed_at = service['completed_at'].to_datetime

      started_at_day = started_at.strftime("%A")
      completed_at_day = completed_at.strftime("%A")

      started_at_hours = schedule_hash[started_at_day]
      completed_at_hours = schedule_hash[completed_at_day]
      
      total_down_time_hours = ((completed_at.to_time - started_at.to_time) / 1.hour).ceil
     
      start_day_open, start_day_close = schedule_hash[Date::DAYNAMES[started_at.wday]]
        .split('–')
        .map { |date| DateTime.parse(date) }

      day_downtime_hours = ((start_day_close.to_time - start_day_open.to_time) / 1.hour).ceil

      total_days_down = (0..(started_at..completed_at).count).to_a #2
  
      #workable hours shop is open for during repair range - loops through vendor schedule and adds total workable time
      total_hours_down = total_days_down.map do |day_num| 
        current_day = started_at + day_num.day 
        current_week_day = current_day.strftime("%A")
        current_day_schedule = schedule_hash[current_week_day]

        next if current_day_schedule == "Closed"
        
        open_time, close_time = current_day_schedule
        .split('–')
        .map { |date| DateTime.parse(date) }

        ((close_time.to_time - open_time.to_time) / 1.hour).ceil
      end.compact.inject(:+)
      ##

      shop_book_hours = service["custom_fields"]["book_time_hours"]

      job_efficiency_rate = ((Float(shop_book_hours.to_i) / total_hours_down) * 100).ceil
    
      res = HTTParty.patch(
        "#{ENV["BASE_URL"]}service_entries/#{service_id}",
        headers: headers,
        body: { 
          completed_at: service["completed_at"],
          custom_fields: {
            shop_efficiency_rate: job_efficiency_rate
          }
        }
      )
      
    render json: res
  end

  def url_encoder(str)
    str.gsub(/ /, '%20')
  end

  #ROUTE - uses Google Places API to fetch shops hours based on stored address (name, lat, lng)
  def get_hours
    id = params['id']

    vendor = HTTParty.get("#{ENV['BASE_URL']}vendors/#{id}", headers: headers)

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

    #TODO - offer user a choice of shops if there are more than one candidate because of location bias

    vendor_place_id = place_id_response['candidates'][0]['place_id']

    open_hours_response = 
      HTTParty.get("https://maps.googleapis.com/maps/api/place/details/json?place_id=#{
      vendor_place_id}&fields=name,opening_hours&key=#{ENV['GOOGLE_API_KEY']}")

    vendors_hours = JSON.parse(open_hours_response.body)
    weekday_text = vendors_hours['result']['opening_hours']['weekday_text']

    puts weekday_text.join('\n')

    hour_update = HTTParty.patch(
      "#{ENV["BASE_URL"]}vendors/#{id}",
      headers: headers,
      body: { 
        custom_fields: {
          operating_hours: weekday_text.join('\n')
        }
      }
    )
    render json: hour_update
  end

  private

  def headers
    {
      'Authorization' => "Token token=#{ENV['FLEETIO_API_KEY']}",
      'Account-Token' => ENV['FLEETIO_TOKEN']
    }
  end
end
