#!/usr/bin/env ruby

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

    payload = {
        'comment[text_comment]': "#{ARGV.pop}",
        'submission[posted_grade]': "#{ARGV.pop}"
    }

    response = CAPI::score_submission(c, a, s, payload)
    # CAPI::dump(response)
  end
end
