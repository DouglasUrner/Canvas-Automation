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

  def self.get(route, includes = '')
    route += "?include[]=#{append_includes(includes)}" if (includes != '')
    begin
      response = RestClient.get(base_url + route, headers)
    rescue => e
      e.response
    end
  end

  def self.assignment(cid, aid, includes = '')
    route = "/v1/courses/#{cid}/assignments/#{aid}"
    get(route, includes)
  end

  def self.submission(cid, uid, aid, includes = '')
    route = "/v1/courses/#{cid}/assignments/#{aid}/submissions/#{uid}"
    get(route, includes)
  end

  def self.submissions(cid, uid, includes = '')
    route = "/v1/courses/#{cid}/assignments/#{aid}/submissions"
    get(route, includes)
  end

  def self.append_includes(list)
    # XXX: Guard against empty list?
    includes = ''
    list.each do |i|
      includes += (includes == '' ? i : ',' + i)
    end
    return "?include[]=#{includes}"
  end
end
