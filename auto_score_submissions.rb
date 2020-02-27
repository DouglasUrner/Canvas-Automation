#!/usr/bin/env ruby

require 'json'

require_relative 'lib/modules/capi'

CAPI::base_url= 'https://canvas.instructure.com/api'

def get_assignment_repo(desc)
  host = 'https://raw.githubusercontent.com'
  branch = 'master'
  path = 'assessment/auto-score.rb'

  pages, repo = desc.gsub(/^.*https:\/\//, '').gsub(/\".*$/, '').split('/')
  org = (pages.split('.'))[0]

  return "#{host}/#{org}/#{repo}/#{branch}/#{path}"
end

response = JSON.parse(CAPI::assignment(1822662, 13795872))

repo = get_assignment_repo(response['description'])

p repo
