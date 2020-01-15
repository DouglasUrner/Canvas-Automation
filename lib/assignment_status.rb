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
