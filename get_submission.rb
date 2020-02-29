#!/usr/bin/env ruby

require 'json'

require_relative 'lib/modules/capi'

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
    response = CAPI::submission(@opts[:course], @opts[:assignment], @opts[:student])
    puts response
    response.each do |k, v|
      if (k == 'attachments')
        puts "#{k}:"
        (v[0]).each do |l, w|
          puts "\t#{l}: #{w}"
        end
      else
        puts "#{k}: #{v}"
      end
    end
  end
end
