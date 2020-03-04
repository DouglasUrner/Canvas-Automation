#!/usr/bin/env ruby

require 'liquid'
require 'yaml'

class Comments
  def initialize(file = 'lib/classes/comments.yml')
    msgs = YAML.load(File.read(file))

    @comments  = []
    @templates = {}

    msgs.each do |k, v|
      @templates[k] = Liquid::Template.parse(v)
    end
  end

  def dump
    str = ''
    if ( @comments.length > 1 || @comments[0].length > 0 )
      @comments.each do |c|
        str += "#{c}\n" if (c != nil && c.length > 0)
      end
    end
    str.strip
  end

  def emit(key, value = '')
    @templates[key].render('name' => value)
  end

  def push(key, value)
    @comments.push(self.emit(key, value))
  end

  def resubmit(score, t_or_f = false)
    if (t_or_f || score <= (OPTS[:max_points] * OPTS[:resubmit_threshold]))
      @comments.push(self.emit('resubmit'))
    end
  end
end

if (__FILE__ == $0)
  require 'pry'
end
