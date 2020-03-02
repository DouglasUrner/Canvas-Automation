require 'json'
require 'pry'
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
    route += set_pagination(route)
    # puts "get(): includes = \'#{includes}\' #{base_url + route}"
    begin
      response = RestClient.get(base_url + route, headers)
    rescue => e
      e.response
    end
    JSON.parse(response)
  end

  def self.put(route, payload, includes = '')
    route += append_includes(includes) if (includes != '')
    # puts "put(): includes = \'#{includes}\' #{base_url + route}"
    begin
      response = RestClient.put(
        base_url + route,
        payload,
        headers
      )
    rescue => e
      e.response
    end
    JSON.parse(response)
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

  # UI helpers

  def self.list_assignments(cid, pat = '', opts = {})
    route = "/v1/courses/#{cid}/assignments"
    includes = ''
    if (opts.empty?)
    else
      # Process opts hash.
    end
    assignments = get(route, includes)
    assignments.sort_by! { |k| k['name'] }
    if (pat)
      # binding.pry
      list = []
      assignments.each do |a|
        list.push(a) if filter?(a, pat)
      end
      assignments = list
    end
    return assignments
  end

  def self.match_assignment(cid, pat, opts = {})
    assignment = list_assignments(cid, pat, opts)
    case (assignment.length)
    when 1 ; return assignment[0]
    else   ; return assignment.length
    end
  end

  def self.list_courses(pat = '', opts = {})
    route = '/v1/courses'
    includes = ''
    if (opts.empty?)
      route += '?enrollment_type=teacher'
    else
      # Process opts hash.
    end
    courses = get(route, includes)
    courses.sort_by! { |k| k['name'] }
    if (pat)
      # binding.pry
      list = []
      courses.each do |c|
        list.push(c) if filter?(c, pat)
      end
      courses = list
    end
    return courses
  end

  def self.match_course(pat, opts = {})
    courses = list_courses(pat, opts)
    case (courses.length)
    when 1 ; return courses[0]
    else   ; return courses.length
    end
  end

  def self.list_sections(pat = '', opts = {})
  end

  def self.match_section(pat, opts = {})
  end

  def self.list_users(pat = '', opts = {})
  end

  def self.match_user(pat, opts = {})
  end

  # Utility methods.

  def self.append_includes(list)
    # XXX: Guard against empty list?
    includes = ''
    list.each do |i|
      includes += ((includes == '') ? '?' : '&') + "include[]=#{i}"
    end
    return includes
  end

  def self.dump(obj)
    puts obj.to_yaml
  end

  def self.filter?(obj, pat)
    # TODO: Handle symbols and strings
    # TODO: Allow regexps or escape them?
    #obj[:name].match(/#{pat}/) || obj['name'].match(/#{pat}/)
    obj['name'].match(/#{pat}/)
  end

  def self.set_pagination(route, items = 100)
    return "#{(route.match?(/\?/)) ? '&' : '?'}per_page=#{items}"
  end
end
