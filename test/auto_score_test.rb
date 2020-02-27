gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require_relative '../auto_score_submissions'

class AutoScoreTest < Minitest::Test
  extend MiniTest::Spec::DSL

  let(:course) { 1807744 }
  let(:assignment) { 13501849 }
  let(:student) { 25199930 }

  def test_get_scorer_url_parses_generic_url
    url = 'https://org-or-user.example.com/repo-name'
    expected = 'https://raw.githubusercontent.com/org-or-user/repo-name/master/assessment/auto_score.rb'
    scorer = get_scorer_url(url)
    assert_equal expected, scorer
  end

end
