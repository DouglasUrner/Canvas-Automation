#!/usr/bin/env ruby

require 'open3'
include Open3

require_relative '../modules/ca_util'

class Repository
  extend CAU

  attr_reader :branch, :host, :local, :local_path, :prefix, :remote, :url

  def initialize(url)
    @url = url
    @protocol, rest = @url.split('://', 2)
    @host, @remote = rest.split('/', 2)
    @local = nil
    @local_path = nil
  end

  def branch_list
    cmd = "cd #{@local_path}; git branch --list"
    rv, stdout, stderr = CAU.run_command(cmd)
    if (rv == 0)
      list = stdout
    else
      puts "branch_list(): #{stderr}"
    end
    return list
  end

  def checkout(branch)
    cmd = "cd #{@local_path}; git rev-parse --verify #{branch} && git checkout #{branch}"
    rv, stdout, stderr = CAU.run_command(cmd)
    if (rv == 0)
      @branch = branch
    else
      puts "checkout(#{branch}): #{stderr}"
    end
    return rv, stdout, stderr
  end

  # Clone repository into 'local', prefixing it with 'prefix'.
  def clone(local, prefix = 'tmp')
    git_clone = 'git clone'
    cmd = "#{git_clone} #{@url} #{prefix + '/' if (prefix != '')}#{local}"
    rv, stdout, stderr = CAU.run_command(cmd)
    if (rv == 0)
      @local = local
      @prefix = prefix
      @local_path = "#{prefix + '/' if (prefix != '')}#{local}"
      checkout('master')
    else
      puts "clone(#{local}, #{prefix}): #{stderr}"
    end
    return rv, stdout, stderr
  end

  # Count the 'items' (files & directories) in the repository,
  # starting from @local_path or @local_path/'from' if 'from' is set.
  def item_count(from = '')
    Dir[ "#{@local_path}#{'/' + from if (from != '')}/**/*" ].length
  end

end

if (__FILE__ == $0)
  require 'pry'

  repo_url = ARGV.pop

  repo = Repository.new(repo_url)

  rv, stdout, stderr = repo.clone(repo.remote)

  puts repo.branch_list
  puts repo.checkout('lesson-1')

end
