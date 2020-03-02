#!/usr/bin/env ruby

require 'json'
require 'pry'

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

  if (@opts[:course].match?(/[a-zA-Z]/))
    # Match course using @opts[:course] as a regexp. If we get
    # one response use the course ID otherwise print a list of
    # courses that matched the pattern and exit.
    course = CAPI::match_course(@opts[:course])
    case (course)
    when 0
      puts "#{$0}: no course matches #{@opts[:course]}"
      exit -1
    when (2..)
      puts "#{$0}: #{course} courses match \'#{@opts[:course]}\':"
      CAPI::list_courses(@opts[:course]).each do |c|
        puts "  #{c['name']} (#{c['course_code']}): #{c['id']}"
      end
      exit -1
    else
      @opts[:course] = course['id']
      puts "Found #{course['name']} (#{course['id']})"
    end
  end

  if (@opts[:assignment].match?(/\D/))
    # Match assignment using @opts[:assignment] as a regexp. If we get
    # one response use the assignment ID otherwise print a list of
    # assignment that matched the pattern and exit.
    assignment = CAPI::match_assignment(@opts[:course], @opts[:assignment])
    case (assignment)
    when 0
      puts "#{$0}: no assignment matches #{@opts[:assignment]}"
      exit -1
    when (2..)
      puts "#{$0}: #{assignment} assignments match \'#{@opts[:assignment]}\':"
      CAPI::list_assignments(@opts[:assignment]).each do |c|
        puts "  #{c['name']}: #{c['id']}"
      end
      exit -1
    else
      @opts[:assignment] = assignment['id']
      puts "Found #{assignment['name']} (#{assignment['id']})"
    end
  end

  if (@opts[:student])
    response = CAPI::submission(@opts[:course], @opts[:assignment], @opts[:student], %w[user])
    CAPI::dump(response)
  end
end
