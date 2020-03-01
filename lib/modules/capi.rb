require 'json'
require 'rest-client'
require 'yaml'

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
    route += append_includes(includes) if (includes != '')
    route += "#{(includes == '' ? '?' : '&')}per_page=100"
    #puts base_url + route if (OPTS[:debug])
    begin
      response = JSON.parse(RestClient.get(base_url + route, headers))
    rescue => e
      e.response
    end
  end

  def self.put(route, payload, includes = '')
    route += append_includes(includes) if (includes != '')
    #puts base_url + route if (OPTS[:debug])
    begin
      response = JSON.parse(RestClient.put(base_url + route, payload, headers))
    rescue => e
      e.response
    end
  end

  def self.assignment(cid, aid, includes = '')
    route = "/v1/courses/#{cid}/assignments/#{aid}"
    get(route, includes)
  end

  def self.submission(cid, aid, uid, includes = '')
    route = "/v1/courses/#{cid}/assignments/#{aid}/submissions/#{uid}"
    get(route, includes)
  end

  def self.submissions(cid, aid, includes = '')
    route = "/v1/courses/#{cid}/assignments/#{aid}/submissions"
    get(route, includes)
  end

  def self.score_submission(cid, aid, uid, scored_submission, includes = '')
    route = "/v1/courses/#{cid}/assignments/#{aid}/submissions/#{uid}"
    put(route, scored_submission, includes)
  end

  def self.append_includes(list)
    # XXX: Guard against empty list?
    includes = ''
    list.each do |i|
      includes += (includes == '' ? i : ',' + i)
    end
    return "?include[]=#{includes}"
  end

  def self.dump(obj)
    puts obj.to_yaml
  end
end
