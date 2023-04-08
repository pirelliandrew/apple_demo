require 'rails_helper'

RSpec.describe "Weather", type: :request do
  describe "GET /weather" do
    shared_examples "a page with an address form" do
      it "has the address form" do
        pending "needs to be implemented"
      end

      context "in the address form" do
        it "has a required field for a street address" do
          pending "needs to be implemented"
        end

        it "has a required field for a zip code" do
          pending "needs to be implemented"
        end

        it "has a required field for a city" do
          pending "needs to be implemented"
        end

        it "has a required field for a country" do
          pending "needs to be implemented"
        end

        it "has a submit" do
          pending "needs to be implemented"
        end
      end
    end

    shared_examples "a page with weather forecast details" do
      it "has the weather forecast details section" do
        pending "needs to be implemented"
      end

      context "in the weather forecast details section" do
        it "has the current temperature" do
          pending "needs to be implemented"
        end

        it "has the high temperature for the day" do
          pending "needs to be implemented"
        end

        it "has the low temperature for the day" do
          pending "needs to be implemented"
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
      it_behaves_like "a page with an address form"
    end
  end
end
