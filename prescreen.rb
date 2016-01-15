require 'net/http'
require 'json'
require 'uri'

module HPS
  class Prescreen
    attr_accessor :data, :url, :headers

    def initialize
      self.url = "http://hps-dev-prescreen.azurewebsites.net/api/v1/applicants"
      self.data = {
        fullName: 'Matt Vasquez',
        email: 'mattvasquez@gmail.com',
        phoneNumber: '214-502-6766'
      }
      self.headers = {
        'Content-Type' => "application/json",
        'X-HPS'=> "apply",
        'Accept' => "application/json"
      }
    end

    def submit
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = data.to_json
      response = http.request(request)

      if response.kind_of?(Net::HTTPRedirection)
        handle_redirect(response['location'])
      else
        puts "STATUS: #{response.code}"
        puts JSON.pretty_generate(JSON.parse(response.body))
      end
    end

    def handle_redirect(loc)
      puts "Getting applicant info..."
      puts loc

      red_uri = URI.parse(loc)
      red_http = Net::HTTP.new(red_uri.host, red_uri.port)
      red_request = Net::HTTP::Get.new(red_uri.request_uri, headers)
      red_response = red_http.request(red_request)

      puts "STATUS: #{red_response.code}"
      puts JSON.pretty_generate(JSON.parse(red_response.body))
    end
  end
end

app = HPS::Prescreen.new
app.submit
