gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require 'pry'
require_relative '../lib/modules/capi'

class CAPIUIHelpersTest < Minitest::Test
  extend MiniTest::Spec::DSL

  let(:course) { 1807744 }
  let(:assignment) { 13501849 }
  let(:student) { 25199930 }

  CAPI::base_url= 'https://canvas.instructure.com/api'

  def test_list_courses_returns_all
    item = "courses"
    result = CAPI::list_courses()
    refute_nil result, "No #{item} found"
    assert_equal 22, result.length if (result.length)
  end

  def test_list_courses_can_filter
    item = "courses"
    result = CAPI::list_courses('A\\+')
    refute_nil result, "No #{item} found"
    assert_equal 2, result.length if (result.length)
  end

  def test_list_courses_can_filter_to_one_course
    item = "courses"
    result = CAPI::list_courses('A\\+ Certification')
    refute_nil result, "No #{item} found"
    assert_equal 1, result.length if (result.length)
  end

  def test_list_sections_returns_all
    skip
    item = "sections"
    result = CAPI::list_sections()
    refute_nil result, "No #{item} found"
    assert_equal 16, result.length if (result.length)
  end
end
