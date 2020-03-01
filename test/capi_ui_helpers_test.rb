gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/modules/capi'

class CAPIUIHelpersTest < Minitest::Test
  extend MiniTest::Spec::DSL

  let(:course) { 1807744 }
  let(:assignment) { 13501849 }
  let(:student) { 25199930 }

  def test_list_courses_returns_all
    item = "courses"
    result = CAPI::list_courses()
    refute_nil result, "No #{item} found"
    assert_equal 16, result.length if (result.length)
  end

  def test_list_sections_returns_all
    item = "sections"
    result = CAPI::list_sections()
    refute_nil result, "No #{item} found"
    assert_equal 16, result.length if (result.length)
  end
end
