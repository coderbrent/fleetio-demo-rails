class VendorsController < ApplicationController
  include HTTParty

  respond_to :json

  def all
    response = HTTParty.get(
      "#{ENV["BASE_URL"]}vendors",
      headers: headers
    )

    render json: response.body
  end

  def performance
    id = params["id"]

    response = HTTParty.get(
      "#{ENV["BASE_URL"]}service_entries?q[vendor_id_eq]=#{id}",
      headers: headers 
    )

    all_service_entries_by_vendor = JSON.parse(response.body)

    all_efficiency_rates = all_service_entries_by_vendor.map do |service_entry|
      service_entry["custom_fields"]["shop_efficiency_rate"]
    end.compact
  
    overall_avg_efficiency = all_efficiency_rates
      .map(&:to_i)
      .inject(0) { |sum, x| sum + x } / all_service_entries_by_vendor.length
    
    render json: { 
      name: all_service_entries_by_vendor.first["vendor_name"],
      id: id,
      average: overall_avg_efficiency
    }
  end

  private

  def headers
    {
      "Authorization" => "Token token=#{ENV["FLEETIO_API_KEY"]}",
      "Account-Token" => ENV["FLEETIO_TOKEN"],
    }
  end

end
