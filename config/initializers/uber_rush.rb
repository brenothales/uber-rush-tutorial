module Uber

  # Default pickup location, for single-store implementations
  PICKUP =
    {
      location: {
        address: "40 W 57th Street",
        city: "New York",
        state: "New York",
        postal_code: "10019",
        country: "US"
      },
      contact: {
        company_name: "Instant Kicks",
        email: "admin@instantkicks.com",
        phone: {
          number: "+12129541234",
          sms_enabled: true
        }
      }
    }

  class UberRush
    include HTTParty
    attr_reader :base_path

    # Sandbox URI, Change to Production when Ready
    base_uri 'https://sandbox-api.uber.com/v1/deliveries'

    # Gets OAuth Token on new Instance
    def initialize
      url = "https://login.uber.com/oauth/v2/token"

      token = self.class.post(url,
        body: {
          client_id: ENV['uber_rush_client_id'],
          client_secret: ENV['uber_rush_client_secret'],
          grant_type: 'client_credentials',
          scope: 'delivery'
        }
      )["access_token"]

      @base_path = "?access_token=#{token}"
    end

    # Gets all deliveries on your account
    def all_deliveries
      url = "#{base_path}"
      self.class.get(url)
    end

    # Gets one specified delivery on your account
    def one_delivery(id)
      url = "/#{id}#{base_path}"
      self.class.get(url)
    end

    # Returns a delivery quote
    def delivery_quote(pickup_obj = Uber::PICKUP, dropoff_obj)
      url = "/quote#{base_path}"

      self.class.post(url,
        body: { pickup: pickup_obj, dropoff: dropoff_obj }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
    end

    # Creates a delivery and returns a delivery object
    def create_delivery(items_arr, pickup_obj = Uber::PICKUP, dropoff_obj)
      url = "#{base_path}"

      self.class.post(url,
        body: { items: items_arr, pickup: pickup_obj, dropoff: dropoff_obj }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
    end

    # Changes delivery status to client_canceled
    def cancel_delivery(id)
      url = "/#{id}/cancel#{base_path}"
      self.class.post(url)
    end
  end
end
