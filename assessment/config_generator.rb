#!/usr/bin/env ruby

require 'yaml'

meta_config = YAML.load(File.read(ARGV.pop))

puts meta_config

branch_list = []

def closest_match(word, list = nil, &block)
  # Decide where the list is coming from.
  if ( list.nil? && block_given? )
    list = block.call
  elsif ( !list.nil? && block_given? )
    raise ArgumentError,
      'expected list or block, got both. Too confused, quitting.'
  elsif ( list.nil? && block.nil? )
    raise ArgumentError,
      'need a list or a block to generate one, got neither. Giving up.'
  else
    # Go with the list.
  end
  matches = fuzzy_match(word, list)
  return matches[0][:name]
end

meta_config['expected_branches'].each do |branch|
  puts "#{branch['actual_name']}"
end

meta_config['expected_branches'].each do |branch|
  branch['actual_name'] = closest_match(branch_list, branch['cannonical_name'])
end



puts meta_config.to_yaml
