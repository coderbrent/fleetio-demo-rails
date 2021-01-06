class VendorsController < ApplicationController
  include HTTParty

  # respond_to :json

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
      
    #the shop_schedule is an array stored as a string on the vendor response.
    #we need to take the string and convert it to a hash so we can grab the hour ranges
    #by their keys(days): ex. Monday => 8:00AM - 8:00PM. we want to be able to determine
    #how many hours are in the workday ex. 8:00AM - 8:00PM = 12 work hours.

    schedule_hash = #convert schedule string to a hash
      Hash[shop_schedule
        .split('\n')
        .map { |date| date
          .split(":", 2)
          .map(&:strip)
        }
      ]

      start_time = Time.parse(service['started_at'])
      end_time = Time.parse(service['completed_at'])

      duration = end_time.to_i - start_time.to_i

      puts duration
    
    render json: service
    
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

    hour_update = HTTParty.patch(
      "#{ENV['BASE_URL']}vendors/#{id}",
      headers: headers,
      body: { 
        custom_fields: {
          operating_hours: weekday_text
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
