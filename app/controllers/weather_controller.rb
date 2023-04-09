require 'httparty'

class WeatherController < ApplicationController
  def index
    populate_weather_forecast_details
  rescue => e
    @error_message = e.message
  end

  private

  def populate_weather_forecast_details
    return @weather_forecast_details if defined?(@weather_forecast_details)
    return @weather_forecast_details = {} unless address.present?
    if (@weather_forecast_details = Rails.cache.read(params[:zip_code]))
      @from_cache = true
      return @weather_forecast_details
    end

    parsed_response = query_open_weather_api

    @weather_forecast_details = {
      current: "#{parsed_response["current"]["temp"]}F",
      forecasts: parsed_response["daily"].map do |forecast|
        {
          date: Time.at(forecast["dt"]).strftime('%m/%d'),
          high: "#{forecast["temp"]["max"]}F",
          low: "#{forecast["temp"]["min"]}F"
        }
      end
    }

    Rails.cache.write(params[:zip_code], @weather_forecast_details, expires_in: 30.minutes)
  end

  def query_open_weather_api
    weather_forecast_url = "https://api.openweathermap.org/data/3.0/onecall"

    query = {
      lat: address_coordinates[:latitude],
      lon: address_coordinates[:longitude],
      exclude: "minutely,hourly,alerts",
      units: "imperial",
      appid: "a53cfe4549bc0249d5df478de84f0f10"
    }

    response = HTTParty.get(weather_forecast_url, query:)

    raise response.parsed_response["message"] if response.code != 200

    response.parsed_response
  end

  def address
    @address ||= [
      params[:address_line_1],
      params[:city],
      "#{params[:state]} #{params[:zip_code]}",
      params[:country]
    ].compact.join(', ').strip
  end

  def address_coordinates
    return @address_coordinates if defined?(@address_coordinates)

    results = Geocoder.search(address)

    @address_coordinates = {
      latitude: results.first.coordinates[0],
      longitude: results.first.coordinates[1]
    }
  end
end
