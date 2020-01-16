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

  def self.assignment(cid, aid)
    route = "/v1/courses/#{cid}/assignments/#{aid}"
    get(route)
  end
end

class AssignmentStatus
  attr_accessor :assignment_id, :course_id, :student_id
  attr_reader :progress, :state

  # State:
  # - :pending (exists, but students are not expected to be working on it)
  # - :open (past the the "available from" date)
  # - :due (within X of due date - due today, due by next class)
  # - :closed (submissions are no longer accepted)

  # Progress Flags:
  # - :not_started (no page views & no commits on assignment branch on GH) (0x0000)
  # - :assignment_viewed () (0x0001)
  # - :progressing () (0x0002)
  # - :on_track () (0x0004)
  # - :submitted_ontime (initial submission) (0x0008)
  # - :submitted_late (initial submission) (0x0010)
  # - :graded (clear on resubmission) (0x0020)
  # - :pending_revisions (0x0040)
  # - :resubmitted (0x0080)
  # - :grade_posted (to gradebook of record) (0x0100)
  # - :teacher_comments_pending () (0x1000)
  # - :teacher_comments_read () (0x2000)
  # - :student_comments_pending () (0x4000)
  # - :student_comments_read () (0x8000)

  def initialize(course_id, student_id, assignment_id)
    @course_id = course_id
    @student_id = student_id
    @assignment_id = assignment_id
    @state = :pending
    @progress = :not_started
  end

  def update_state
    a = CAPI::assignment(@course_id, @assignment_id)
  end
end

CAPI::base_url= 'https://canvas.instructure.com/api'

# response = CAPI::submission(1807744, 25199930, 13501849)
# p response.code
# p s = JSON.parse(response.body)
# # p response.headers
# response = CAPI::submission(1807744, 25199930, 1)
# p response.code
#
# response = CAPI::assignment(1807744, 13501849)
# p response.code
# p s = JSON.parse(response.body)
# # p response.headers
# response = CAPI::assignment(1807744, 1)
# p response.code
