require 'rails_helper'

RSpec.describe "Weather", type: :request do
  describe "GET /weather" do
    before { get "/weather", params: }

    let(:parsed_html_body) { Nokogiri::HTML(response.body).css('body') }

    shared_examples "a page with an address form" do
      let(:address_form) do
        parsed_html_body.css('form[action="/weather"][accept-charset="UTF-8"][method="get"]')
      end

      it "has the address form" do
        expect(address_form).to be_present
      end

      context "in the address form" do
        it "has a required field for the address line 1" do
          expect(address_form.css('label[for="address_line_1"]')).to be_present
          expect(address_form.css('input[type="text"][name="address_line_1"]'\
                                  '[id="address_line_1"][required="required"]')).to be_present
        end

        it "has a required field for the city" do
          expect(address_form.css('label[for="city"]')).to be_present
          expect(address_form.css('input[type="text"][name="city"]'\
                                  '[id="city"][required="required"]')).to be_present
        end

        it "has a required field for the state" do
          expect(address_form.css('label[for="state"]')).to be_present
          expect(address_form.css('input[type="text"][name="state"]'\
                                  '[id="state"][required="required"]')).to be_present
        end

        it "has a required field for the zip code" do
          expect(address_form.css('label[for="zip_code"]')).to be_present
          expect(address_form.css('input[type="text"][name="zip_code"]'\
                                  '[id="zip_code"][required="required"]')).to be_present
        end

        it "has a required field for the country" do
          expect(address_form.css('label[for="country"]')).to be_present
          expect(address_form.css('input[type="text"][name="country"]'\
                                  '[id="country"][required="required"]')).to be_present
        end

        it "has a submit" do
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
        expect(weather_forecast_details_section).to be_present
      end

      context "in the weather forecast details section" do
        it "has the current temperature" do
          expect(weather_forecast_details_section.text).to include("Current: 89F")
        end

        it "has the high temperature for the day" do
          expect(weather_forecast_details_section.text).to include("High: 95F")
        end

        it "has the low temperature for the day" do
          expect(weather_forecast_details_section.text).to include("Low: 82F")
        end

        it "has the extended forecast" do
          pending "needs to be implemented"
        end
      end
    end

    shared_examples "a page with an error message" do
      it "has the error message section" do
        pending "needs to be implemented"
      end

      context "in the error message section" do
        it "has the expected error message" do
          pending "needs to be implemented"
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
          address_line1: '123 Main St',
          city: 'Santa Ana',
          state: 'CA',
          zip_code: '92701',
          country: 'US'
        }
      end

      context "when the weather forecast data is cached for the given zip code" do
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
