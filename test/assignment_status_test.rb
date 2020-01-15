gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/assignment_status'

class AssignmentStatusTest < Minitest::Test
  def test_that_an_assignment_status_object_is_created
    expected = AssignmentStatus.new(1, 42)
    assert_instance_of AssignmentStatus, expected
  end

  def test_that_assignment_status_has_assignment_id
    as = AssignmentStatus.new(16, 28)
    expected = as.assignment_id
    assert_equal expected, 28
  end

  def test_that_assignment_status_has_student_id
    as = AssignmentStatus.new(16, 28)
    expected = as.student_id
    assert_equal expected, 16
  end

  def test_that_a_canvas_submission_is_returned
    skip
  end

  def test_that_a_404_error_is_returned
    skip
  end
end
