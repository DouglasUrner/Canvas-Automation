#!/usr/bin/env ruby

#require_relative 'lib/modules/casl'
require_relative 'lib/classes/comments'
require_relative 'lib/classes/repository'

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
  comments_file: 'lib/classes/comments.yml',
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
  repo = Repository.new(remote)

  rv, stdout, stderr = repo.clone(repo.remote)
  puts "#{repo.branch}: #{repo.item_count} files"
  rv, stdout, stderr = repo.checkout('lesson-1')
  puts "#{repo.branch}: #{repo.item_count} files"

  #### Git Workflow ####

  # Attempt to clone the repository.

  # Check for .gitignore and check the file/item count.

  # Check for the lesson branch.
  # - If not found, check close matches.
  # - If we fail, adjust score and repeat checks on master.

  # Check for expected directories.

  # Check for expected files.
  # - And for files that should have been deleted.
  # - Expect exact name matches, deduct something for misnamed
  #   files, then store names for other checks. Use a hash of
  #   the cannonical name and the actual name.

  # Check for multiple commits.
  # - Count entries in git log.
  # - Require at least one commit per class, expect more.
  # - Extra credit for commits outside of class hours?

  # Check for merge to master.
  # - Diff master against branch?
  # - Check git log?

  #### Steps in Unity ####

  # Check that scene file has been modified.

  # Parse & examine the scene file.
  # - Simple greps to start with.
  # - Count game objects.
  # - Grep for expected names.
  # - Count components.

  #### Coding Scripts ####

  # Coding conventions
  # - CamelCase
  # - Verify compilation?
  # - Grep for significant code fragments.
  # - File size / lines of code.
  # - Tests
  # - Use MOSS?

end
