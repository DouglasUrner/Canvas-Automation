gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/modules/capi'

class CAPIUtilsTest < Minitest::Test
  extend MiniTest::Spec::DSL

  let(:course) { 1807744 }
  let(:assignment) { 13501849 }
  let(:student) { 25199930 }

  def test_append_includes_with_one_item
    includes = CAPI::append_includes(%w[user])
    assert_equal '?include[]=user', includes
  end

  def test_append_includes_with_multiple_items
    includes = CAPI::append_includes(%w[one two three])
    assert_equal '?include[]=one&include[]=two&include[]=three', includes
  end
end
