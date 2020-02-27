require 'json'
require 'rest-client'

# Local Gems
require_relative './secrets'

module CAPI
  # Canvas API interface.
  class Error < StandardError; end

  if (ENV['ACCESS_TOKEN'] == nil)
    Secrets::source('private/ENV')
  end

  def self.base_url=(base); @base_url = base; end
  def self.base_url; @base_url; end

  def self.headers
    {
      Authorization: "Bearer #{ENV['ACCESS_TOKEN']}"
    }
  end

  def self.get(route)
    begin
      response = RestClient.get(base_url + route, headers)
    rescue => e
      # //p e.response.code
      # //e.response
      e.response
    end
  end

  def self.submission(cid, uid, aid)
    route = "/v1/courses/#{cid}/assignments/#{aid}/submissions/#{uid}"
    get(route)
  end

  def self.assignment(cid, aid)
    route = "/v1/courses/#{cid}/assignments/#{aid}"
    get(route)
  end
end
