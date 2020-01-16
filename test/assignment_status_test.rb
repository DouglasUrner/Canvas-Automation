gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/assignment_status'

class AssignmentStatusTest < Minitest::Test
  extend MiniTest::Spec::DSL

  let(:course) { 1807744 }
  let(:assignment) { 13501849 }
  let(:student) { 25199930 }

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

  def test_that_a_response_code_of_200_is_returned_for_submitted_assignment
    response = CAPI::submission(course, student, assignment)
    assert_equal 200, response.code
  end

  def test_that_a_response_code_of_404_is_returned_for_missing_assignment
    #let(:assignment) { 1 }
    response = CAPI::submission(course, student, 1)
    assert_equal 404, response.code
  end

  def test_that_a_canvas_submission_is_returned
    skip
    response = CAPA::submission(course, student, assignment)
  end
end
