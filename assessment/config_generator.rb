#!/usr/bin/env ruby

# require 'json'
require 'yaml'

meta_config = YAML.load(File.read(ARGV.pop))

puts meta_config

branch_list = []

def closest_match(word, list = nil, &block)
  puts 'list given' unless list.nil?
  puts 'block given' unless block.nil?

  if ( list.nil? && block_given? )
    list = block.call
  elsif ( !list.nil? && block_given? )
    raise ArgumentError,
      'expected list or block, got both. Too confused, quitting.'
  elsif ( list.nil? && block.nil? )
    raise ArgumentError,
      'need a list or a block to generate one, got neither. Giving up.'
  end
  # Go with the list.
  return list
end

meta_config['expected_branches'].each do |branch|
  puts "#{branch['actual_name']}"
end

meta_config['expected_branches'].each do |branch|
  branch['actual_name'] = closest_match(branch_list, branch['cannonical_name'])
end



puts meta_config.to_yaml
