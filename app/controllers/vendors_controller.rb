class VendorsController < ApplicationController
  include HTTParty

  respond_to :json

  def all
    response = HTTParty.get("#{ENV['BASE_URL']}vendors", headers: headers)

    puts ENV['BASE_URL']
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

  def calculate_performance
    service_id = params['id']
    
    all_vendor_service_entries = HTTParty.get("#{ENV['BASE_URL']}service_entries/#{service_id}", headers: headers)
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
    #TODO offer user a choice of shops if there are more than one candidate because of location bias

    vendor_place_id = place_id_response['candidates'][0]['place_id']

    details_url =
      "https://maps.googleapis.com/maps/api/place/details/json?place_id=#{
        vendor_place_id
      }&fields=name,opening_hours&key=#{ENV['GOOGLE_API_KEY']}"

    operating_hours_response = HTTParty.get(details_url)
    vendor_operating_hours = JSON.parse(operating_hours_response.body)

    hour_update = HTTParty.patch(
      "#{ENV['BASE_URL']}vendors/#{id}",
      headers: headers,
      body: { 
        custom_fields: {
          operating_hours: vendor_operating_hours
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
