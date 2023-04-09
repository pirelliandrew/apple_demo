require 'rails_helper'

RSpec.describe "Weather", type: :request do
  describe "GET /weather" do
    subject { get "/weather", params: }

    let(:parsed_html_body) { Nokogiri::HTML(response.body).css('body') }
    let(:geocoder_response) { [double(coordinates: %w[latitude longitude])] }
    let(:open_weather_api_response) do
      double(
        code: 200,
        parsed_response: {
          "current" => { "temp" => 53.62 },
          "daily" => [
            { "dt" => 1680980400, "temp" => { "min" => 53.62, "max" => 72.88 } },
            { "dt" => 1681066800, "temp" => { "min" => 59.99, "max" => 75.25 } },
            { "dt" => 1681153200, "temp" => { "min" => 60.62, "max" => 73.38 } },
            { "dt" => 1681239600, "temp" => { "min" => 56.44, "max" => 64.18 } },
            { "dt" => 1681326000, "temp" => { "min" => 51.85, "max" => 56.44 } },
            { "dt" => 1681412400, "temp" => { "min" => 51.3, "max" => 60.13 } },
            { "dt" => 1681498800, "temp" => { "min" => 53.53, "max" => 70.97 } },
            { "dt" => 1681585200, "temp" => { "min" => 59.34, "max" => 74.19 } }
          ]
        }
      )
    end
    let(:expected_current_temperature) { "Current: 53.62F" }
    let(:expected_forecasts) do
      [
        "04/08 High: 72.88F Low: 53.62F",
        "04/09 High: 75.25F Low: 59.99F",
        "04/10 High: 73.38F Low: 60.62F",
        "04/11 High: 64.18F Low: 56.44F",
        "04/12 High: 56.44F Low: 51.85F",
        "04/13 High: 60.13F Low: 51.3F",
        "04/14 High: 70.97F Low: 53.53F",
        "04/15 High: 74.19F Low: 59.34F"
      ]
    end

    before do
      allow(Geocoder)
        .to receive(:search)
        .and_return(geocoder_response)
      allow(HTTParty).to receive(:get).and_return(open_weather_api_response)
    end

    shared_examples "a page with an address form" do
      let(:address_form) do
        parsed_html_body.css('form[action="/weather"][accept-charset="UTF-8"][method="get"]')
      end

      it "has the address form" do
        subject
        expect(address_form).to be_present
      end

      context "in the address form" do
        def expect_required_field(name)
          expect(address_form.css("label[for=\"#{name}\"]")).to be_present
          expect(address_form.css("input[type=\"text\"][name=\"#{name}\"]"\
                                  "[id=\"#{name}\"][required=\"required\"]")).to be_present
        end

        it "has a required field for the address line 1" do
          subject
          expect_required_field("address_line_1")
        end

        it "has a required field for the city" do
          subject
          expect_required_field("city")
        end

        it "has a required field for the state" do
          subject
          expect_required_field("state")
        end

        it "has a required field for the zip code" do
          subject
          expect_required_field("zip_code")
        end

        it "has a required field for the country" do
          subject
          expect_required_field("country")
        end

        it "has a submit" do
          subject
          expect(address_form.css('input[type="submit"][name="commit"]'\
                                  '[value="Search"][data-disable-with="Search"]')).to be_present
        end
      end
    end

    shared_examples "a page with weather forecast details" do
      let(:weather_forecast_details_section) do
        parsed_html_body.css('div[test_id="weather_forecast_details"]')
      end

      it "has the weather forecast details section" do
        subject
        expect(weather_forecast_details_section).to be_present
      end

      context "in the weather forecast details section" do
        it "has the current temperature" do
          subject
          expect(weather_forecast_details_section.text).to include(expected_current_temperature)
        end

        it "has the extended forecast" do
          subject
          expected_forecasts.each do |expected_forecast|
            expect(weather_forecast_details_section.text).to include(expected_forecast)
          end
        end
      end
    end

    shared_examples "a page with an error message" do
      let(:error_message_section) { parsed_html_body.css('div[test_id="error_message"]') }

      it "has the error message section" do
        subject
        expect(error_message_section).to be_present
      end

      context "in the error message section" do
        it "has the expected error message" do
          subject
          expect(error_message_section.text).to include(expected_error_message)
        end
      end
    end

    shared_examples "a request that caches weather forecast details" do
      it "caches the weather forecast details for the given zipcode for 30 minutes" do
        pending "needs to be implemented"
      end
    end

    context "when an address is specified in the params" do
      let(:params) do
        {
          address_line_1: '123 Main St',
          city: 'Santa Ana',
          state: 'CA',
          zip_code: '92701',
          country: 'US'
        }
      end
      let(:expected_address) { "123 Main St, Santa Ana, CA 92701, US" }
      let(:expected_url) { "https://api.openweathermap.org/data/3.0/onecall" }
      let(:expected_query) do
        {
          lat: "latitude",
          lon: "longitude",
          exclude: "minutely,hourly,alerts",
          units: "imperial",
          appid: "a53cfe4549bc0249d5df478de84f0f10"
        }
      end

      before do
        allow(Geocoder)
          .to receive(:search)
          .with(expected_address)
          .and_return(geocoder_response)
        allow(HTTParty).to receive(:get) do |url, args|
          expect(url).to eq(expected_url)
          expect(args[:query]).to include(expected_query)
        end.and_return(open_weather_api_response)
      end

      context "when the weather forecast data is cached for the given zip code" do
        before do
          expect(Geocoder).not_to receive(:search)
          expect(HTTParty).not_to receive(:get)
        end

        it_behaves_like "a page with an address form"
        it_behaves_like "a page with weather forecast details"
      end

      context "when the weather forecast data is not cached for the given zip code" do
        context "when the weather forecast data is retrieved successfully" do
          it_behaves_like "a page with an address form"
          it_behaves_like "a page with weather forecast details"
          it_behaves_like "a request that caches weather forecast details"
        end

        context "when there is an error retrieving the weather forecast data" do
          let(:open_weather_api_error_response) do
            double(
              code: 404,
              parsed_response: {
                "message" => "The weather forecast data could not be found "\
                             "for the specified coordinates."
              }
            )
          end
          let(:expected_error_message) do
            "There was an error retrieving the weather forecast details: "\
            "The weather forecast data could not be found for the specified coordinates."
          end

          before do
            allow(HTTParty).to receive(:get) do |url, args|
              expect(url).to eq(expected_url)
              expect(args[:query]).to include(expected_query)
            end.and_return(open_weather_api_error_response)
          end

          it_behaves_like "a page with an address form"
          it_behaves_like "a page with an error message"
        end
      end
    end

    context "when no address is specified in the params" do
      let(:params) { {} }

      it_behaves_like "a page with an address form"
    end
  end
end
