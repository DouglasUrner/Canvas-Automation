#!/usr/bin/env ruby

require 'json'

require_relative '../lib/modules/capi'

CAPI::base_url= 'https://canvas.instructure.com/api'

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

  if (@opts[:student])
    c = @opts[:course]
    a = @opts[:assignment]
    s = @opts[:student]
    response = CAPI::submission(c, a, s, %w[ user, submission_comments ])
    CAPI::dump_submission(response)
    payload = {
      'submission[posted_grade]': ARGV.pop
    }
    # response['posted_grade'] =
    # response['text_comment'] = ARGV.pop
    response = CAPI::score_submission(c, a, s, payload)
    puts '========================='
    CAPI::dump_submission(response)
  end
end
