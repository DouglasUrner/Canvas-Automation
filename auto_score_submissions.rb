#!/usr/bin/env ruby

require 'json'

require_relative 'lib/modules/capi'

CAPI::base_url= 'https://canvas.instructure.com/api'

# Parse the HTML from the assignment description to generate the URL
# of the auto_score module in the source repo on GitHub.
def get_scorer_url(desc)
  host = 'https://raw.githubusercontent.com'
  branch = 'master'
  path = 'assessment/auto_score.rb'

  pages, repo = desc.gsub(/^.*https:\/\//, '').gsub(/\".*$/, '').split('/')
  org = (pages.split('.'))[0]

  return "#{host}/#{org}/#{repo}/#{branch}/#{path}"
end

def download_scorer(url)
  scorer_name = "score-#{@opts[:assignment]}.rb"
  cmd = "curl #{url} > #{scorer_name}"
  # TODO: check return - execute command method.
  # XXX: There is a potential injection attack here since the scorer URL is
  #      inferred from the assignment repository.
  %x( #{cmd} )
  return scorer_name
end

if (__FILE__ == $0)
  require 'optparse'

  @opts = {
    debug: false,
    verbose: false,
  }

  OptionParser.new do |o|
    o.banner = "Usage: #{$0} [options]"

    o.on('-a ASSIGNMENT') { |v| @opts[:assignment] = v }
    o.on('-c COURSE')     { |v| @opts[:course] = v }
    o.on('-d')            { |v| @opts[:debug] = true }
    o.on('-s STUDENT')    { |v| @opts[:student] = v }
    o.on('-T TMPDIR')     { |v| @opts[:tmp_dir] = v }
    o.on('-v')            { |v| @opts[:verbose] = true }
  end.parse!

  # XXX: need to handle failed requests / bad args.
  response = CAPI::assignment(@opts[:course], @opts[:assignment])

  scorer_url = get_scorer_url(response['description'])
  scorer = download_scorer(scorer_url)

  if (@opts[:student])
    response = CAPI::submission(@opts[:course], @opts[:assignment], @opts[:student])
    puts response
  else
    response = CAPI::submissions(@opts[:course], @opts[:assignment], %w[user])
    response.each do |s|
      if (s['url'] && s['workflow_state'] == 'submitted' &&
            !s['grade_matches_current_assignment'])
        puts "#{s['user']['name']} (#{s['id']}): #{s['workflow_state']} #{s['url']}"
        score_cmd = "ruby #{scorer} #{s['url']}"
        puts score_cmd  if (@opts[:debug])
        score = %x( #{score_cmd} )
        puts score
      end
    end
  end
end
