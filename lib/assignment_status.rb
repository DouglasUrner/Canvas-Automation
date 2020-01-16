require 'json'
require 'rest-client'

# Local Gems
# require 'secrets'

module Secrets
  class Error < StandardError; end
  def self.source(path)
    # Inspired by user takeccho at http://stackoverflow.com/a/26381374/3849157
    # Sources sh-script or env file and imports resulting environment
    fail(ArgumentError, "File #{path} missing or unreadable.") \
       unless File.exist?(path)

    _env_hash_str = `env -i sh -c 'set -a; source #{path} && ruby -e "p ENV"'`
    fail(ArgumentError, 'Malformed environment in #{path}.') \
       unless _env_hash_str.match(/^\{("[^"]+"=>".*?",\s*)*("[^"]+"=>".*?")\}$/)

    _env_hash = eval(_env_hash_str)
     %w[ SHLVL PWD _ ].each{ |k| _env_hash.delete(k) }
    _env_hash.each{ |k,v| ENV[k] = v }
  end
end

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
      response
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
end

class AssignmentStatus
  attr_accessor :assignment_id, :student_id
  attr_reader :progress, :state

  def initialize(student_id, assignment_id)
    @student_id = student_id
    @assignment_id = assignment_id
    @state = :pending
    @progress = :not_started
  end
end

CAPI::base_url= 'https://canvas.instructure.com/api'

response = CAPI::submission(1807744, 25199930, 13501849)
p response.code
response = CAPI::submission(1807744, 25199930, 1)
p response.code
