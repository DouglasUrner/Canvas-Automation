# Local Gems
require_relative 'modules/capi'

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
