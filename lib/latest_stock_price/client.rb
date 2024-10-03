module LatestStockPrice
  class Client
    include HTTParty
    base_uri 'https://latest-stock-price.p.rapidapi.com'

    def initialize(api_key)
      @headers = {
        "x-rapidapi-key" => api_key,
        "x-rapidapi-host" => "latest-stock-price.p.rapidapi.com"
      }
    end

    def price_all
      self.class.get("/any", headers: @headers)
    end
  end
end