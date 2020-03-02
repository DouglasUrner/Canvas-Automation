require 'find'
require 'pathname'
require 'pry'

# Levenshtein algorithm for calculating the "distance" between two words.
# Use to identify likely misspellings of file names.
#
# Taken from: https://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Levenshtein_distance#Ruby
#
def levenshtein(first, second)
  m, n = first.length, second.length
  return m if n == 0
  return n if m == 0

  # Create our distance matrix
  d = Array.new(m+1) {Array.new(n+1)}
  0.upto(m) { |i| d[i][0] = i }
  0.upto(n) { |j| d[0][j] = j }

  1.upto(n) do |j|
    1.upto(m) do |i|
      d[i][j] = first[i-1] == second[j-1] ? d[i-1][j-1] : [d[i-1][j]+1,d[i][j-1]+1,d[i-1][j-1]+1,].min
    end
  end
  d[m][n]
end

# Check for the existance of a file - with allowances for misspellings and
# being in the wrong directory. Returns an array of hashes, ordered by the
# "fuzziness" of the file name and then by the "fuzziness" of the directory
# if a file with a Levenshtein distance of <= "threshold" is found. Else, we
# return an arry with a single entry with a distance of -1.
#
# TODO: Use relative_path_from() to report a better path, perhaps by popping
#       up the path with parent() until we reach the directory above the limit
#       and reporting the relative path from there.
def fuzzy_file_match(name, limit = 'Assets', threshold = 3)
  @distances = []
  path = Pathname.new(name)

  # See if the file exists as specified
  if path.exist?
    @distances.push({'directory': path.parent, 'name': path.basename, 'distance': 0})
    return @distances
  end

  # Check if the folder that should hold 'name' exists
  # and if there is a close match to the name.
  scan_dirs(path.parent, path.basename, limit)
  @distances.sort_by! { |k| k[:distance] }
  # puts @distances
  return @distances if (@distances[0][:distance] <= threshold)

  # Nothing seems to match
  @distances = []
  @distances.push({'directory': nil, 'name': nil, 'distance': -1})
  return
end

def scan_dirs(dir, name, limit)
  dir.each_entry do |e|
    next if (e.fnmatch?('.') || e.fnmatch?('..') || e.fnmatch('*.meta'))
    # Would like to do this, but it fails with the message:
    # No such file or directory @ rb_file_s_ftype - PlayerController.cs (Errno::ENOENT)
    # next if ((e.ftype == 'directory') || e.fnmatch('*.meta'))
    d = levenshtein(name.to_s, e.to_s)
    f = {'directory': dir,'name': e, 'distance': d}
    @distances.push(f)
  end
  # binding.pry
  scan_dirs(dir.parent, name, limit) if (dir.parent.to_s.match?(limit))
end

name = ARGV.pop

possibilities = fuzzy_file_match(name)
puts possibilities

possibilities.each do |p|
  puts "#{p[:directory]}/#{p[:name]}: #{p[:distance]}" if (p[:distance] <= 3)
end
