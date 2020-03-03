#!/usr/bin/env ruby

require_relative 'lib/modules/casl'
require_relative 'lib/comments'

# Clone a GitHub repository holding a Unity project and do mechanical checks
# for completion of the assignment and for correctness. This file is the
# boilerplate for the test and is deployed in the assignment repository. The
# assessment process is driven by the driver script in the Canvas-Automation
# repository. The require of the supporting library assumes that we are run in
# the context of the Canvas-Automation repository. This script will be
# downloaded from GitHub and run for each student repository being scored.

OPTS = {
  base_url: 'https://github.com/',
  branch: '',
  clone: 'git clone',
  comments_file: 'lib/comments.yml',
  debug: false,
  empty_script_size: 323,
  gitignore_size: 500,
  max_points: 9,
  resubmit_threshold: 0.7,
  scene: '',
  tmp_dir: 'tmp',
  verbose: false
}

@score = 0
@resubmit = false

if (__FILE__ == $0)
  require 'optparse'

  OptionParser.new do |o|
    o.banner = "Usage: #{$0} [options]"

    o.on('-b BRANCH')   { |v| OPTS[:branch] = v }
    o.on('-d')          { |v| OPTS[:debug] = true }
    o.on('-M COMMENTS') { |v| OPTS[:comments_file] = v }
    o.on('-T TMPDIR')   { |v| OPTS[:tmp_dir] = v }
    o.on('-v')          { |v| OPTS[:verbose] = true }
  end.parse!

  remote = ARGV.pop

  @comments = Comments.new(OPTS[:comments_file])
  # comments.push('unable_to_clone', 'oops!')
  # puts comments.dump()

  # Clone the project repository.
  points, comment = CASL::clone_and_score(remote)
  CASL::done(@score, @comments, true) if (points == 0) # Clone failed, quit
  @score += points

  CASL::done(@score, @comments, @resubmit)
end
