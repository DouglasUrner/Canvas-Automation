# Canvas Automation Support Library

module CASL
  require 'json'
  require 'open3'         # Used by clone().
  class << self
    # Per GBS - squelch undefined method `popen3' error that cropped up
    # when creating the module.
    include Open3
  end
  require 'pathname'
  require 'pry'
  require 'yaml'

  def self.done(score, comments, revise)
    debug = OPTS[:debug]
    if (debug)
      puts "done(): resubmit = #{resubmit}; score = #{score};\n"               +
           "comments ="
      comments.each do |c|
        puts "  - #{c}"
      end
    end

    comments.resubmit(score, revise)

    fb = {}
    fb['score'] = score
    fb['comments'] = comments.dump()
    msg = ''

    puts fb.to_json
    # Because we may be called part way through...
    exit
  end

  def self.clone_and_score(url, path = local_from_remote(url))

    # Attempt to clone the repository.
    #
    # Possible results:
    # - Success: the URL clones successfuly.
    # - Failure: the URL "looks" good, but failed to clone - perhaps a private repo.
    # - Failure: the URL does not match the expected pattern.

    if (clone(url, path) == 0)
      # Success
      points = 1
      msg = ''
    else
      # XXX: clean up regexp handling - don't bury it here.
      points = 0
      @comments.dump()
      msg = "I was unable to clone your repository: \'#{url}\'. "
      if (url.match(/\/[Pp]rototype-*[1-5]$/))
        # URL seems plausible
        msg += "Please double check the URL and make sure the repository isn't " +
               "private.\n\nIf it is set to private, you will see a lock icon "  +
               "next to the repository name in GitHub Desktop. If you see the "  +
               "lock icon, go to the repository on the GitHub website, there "   +
               "you can make the repository public on the Settings tab."
      else
        # ...or not.
        msg += "Please double check the URL."
      end
    end
    return points, msg
  end

  def self.local_from_remote(url)
    local = url.gsub(OPTS[:base_url], '')
    local = "#{OPTS[:tmp_dir]}/#{local}" if OPTS[:tmp_dir]
    return local
  end

  def self.check_repo_sanity(path, min, max)
    # Check that the repository looks sane. We expect:
    # - An Assets folder
    # - A .gitignore File
    # - At least min files
    # - No more than max files

    assets = Pathname.new("#{path}/Assets")
    if (assets.directory?)
      points = 1
      msg = ""
    else
      points = 0
      msg = "Your Assets folder appears to be missing. Did you create your Git " +
            "repository inside of your Unity project (do you see a Prototype-4 " +
            "folder inside of your Unity project)? If that is so, Git won't "    +
            "see your changes (there will be nothing to commit & push). If "     +
            "you've just started, the easiest thing to do is probably to "       +
            "delete the repository locally and on GitHub and start over. It is " +
            "also possible to move the Git repository 'up a level' to fix the "  +
            "problem. As long as you fix it promptly it's not a big deal "       +
            "either way."
    end

    gitignore = Pathname.new("#{path}/.gitignore")
    if (gitignore.file? && gitignore.size > OPTS[:gitignore_size])
      # Do nothing, we're either already good or going to fail due to the
      # Assets folder being missing.
    else
      points = 0
      msg = "Your .gitignore is either missing or smaller than expected for "    +
            "Unity - please double check that you have a good .gitignore."
    end

    items = Dir["#{path}/**/*"].length
    if (items >= 20 && items <= 200)
      # Same logic here.
    elsif (items < 20)
      points = 0
      msg = "There don't seem to be enough files is your project - it's likely " +
            "that your Unity project and the Git repository aren't in the same " +
            "the same folder - please ask for help if you don't know how to fix" +
            "this problem."
    else # > 200
      points = 0
      msg = "There are way too many files in your Git repository. This usually " +
            "happens when either the .gitignore file is missing or the first "   +
            "commit was done before adding it. You may also be having trouble "  +
            "pushing to GitHub. If you have a good .gitignore this will be "     +
            "messy to fix - it's probably easiest to start over."
    end

    return points, msg
  end

  def self.checkout_branch_and_score(path, branch)
    if (checkout_branch(path, branch) == 0)
      # Success
      points = 1
    else
      points = 0
      msg = "You don't seem to have a branch for this lesson in your "           +
            "repository. I was looking for a \'#{branch}\' branch. This may be " +
            "because you used a different branch name (or made a typo).\n\nBe "  +
            "sure to create a branch for each lesson (in case you need to go "   +
            "back) it is also worth developing a habit of consistancy (and "     +
            "tracking directions)."
    end
    if (debug)
      puts "checkout_branch_and_score(): #{points.to_s}: #{msg}"
    end
    return points, msg
  end

  def self.clone(url, path)
    cmd = "#{OPTS[:clone]} #{url} #{path}"

    fd0, fd1, fd2, wait = popen3(cmd)
    fd0.close

    stdout = fd1.read ; fd1.close
    stderr = fd2.read ; fd2.close

    return wait.value
  end

  def self.checkout_branch(path, branch)
    # TODO: do a better job with messages from Git.

    cmd = "cd #{path}; git checkout #{branch}"

    fd0, fd1, fd2, wait = popen3(cmd)
    fd0.close

    stdout = fd1.read ; fd1.close
    stderr = fd2.read ; fd2.close

    if (OPTS[:verbose])
      puts stdout
      puts stderr
    end

    return wait.value
  end

  # Find a folder, or one with a closely matching name.
  def find_folder(parent, name)
    # Check that a folder exists. Also check for "close matches" on the name.
    # If a match is found, return the path.
    path = nil
    likely_names = name_variations(name)
    likely_names.each do |n|
      path = "#{parent}/#{n}"
      puts "find_folder(#{name}): trying \'#{path}\'" if OPTS[:debug]
      break if Pathname.new(path).directory?
      path = nil
    end
    puts "find_folder(#{name}): returning path of \'#{path}\'"  if OPTS[:debug]
    return path
  end

  # Generate variations on a file or directory name.
  def name_variations(name)
    variations = []
    variations.push(name)
    variations.push(name.downcase)
    variations.push(name.upcase)
    variations.push(name.gsub(/[ _-]/, ''))
    return variations
  end

  # Find a Git branch that (roughly) matches the expected branch.
  def find_branch(repo, branch)
    name, num = branch.split('-')

    variations = [ branch, "#{name}#{num}", "#{name}_#{num}" ]

    branches = %x( cd #{repo} ; git branch --list ).gsub('*', '').split("\n")
    branches.each do |b|
      b.strip!
      variations.each do |v|
        return b if (b == v)
      end
    end

    return nil
  end

  def self.check_script(path, name, threshold = 3, limit = 'Assets')
    # TODO: take a block to check specifics
    #       check class name for match with file name
    #       check class name for default value
    #       basic parse / compile check?
    #       diff against "likely suspects?"
    #       check in the root of the Assets folder
    #       check for "reasonable" misspellings
    debug = OPTS[:debug]
    script_path = "#{path}/#{name}"

    hits = fuzzy_file_match(script_path, limit, threshold)
    case (hits[0][:distance])
    when -1
      # Nothing promising.
      puts "check_script(#{script_path}): not found" if (debug)
      points = 0
      msg = "I couldn't find your \'#{name}\' script.\n\n"                       +
            "Make sure you've named it correctly (and be sure to change the "    +
            "class name if rename the file), or perhaps you created it "         +
            "in another folder."
    when 0
      # Exact match.
      if (Pathname.new(script_path).size > @opts[:empty_script_size])
        puts "check_script(#{script_path}): found, size = #{script.size}" if (debug)
        points = 1
        msg = ''
      else
        puts "check_script(#{script_path}): found, size = #{script.size} (too small)"  if (debug)
        points = 0
        msg = "Your \'#{name}\' script seems too short. Did you save your  "     +
              "changes before committing?"
      end
    else
      # A possiblity - but misnamed or in the wrong folder.
      points = 0
      possibilities = []
      hits.each do |h|
        possibilities.push(h) if (h[:distance] <= threshold)
      end
      msg = "I didn't find a script called #{name}, but I did find "             +
            "#{possibilities.length} possible match#{"es" if possibilities.length > 1}:\n"
      possibilities.each do |p|
        msg += " #{p[:name]}\n"
      end
      msg += "If #{(possibilities.length == 1) ? 'this' : 'one of these'} is "   +
             "right, it should be renamed to #{name}. You will probabaly need "   +
             "to update the class name in the file to match."
    end

    puts "check_script(#{script_path}): returning - points = #{points}; msg = \'#{msg}\'"  if (debug)
    return points, msg
  end

  # Levenshtein algorithm for calculating the "distance" between two words.
  # Use to identify likely misspellings of file names.
  #
  # Taken from: https://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Levenshtein_distance#Ruby
  #
  def self.levenshtein(first, second)
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
  def self.fuzzy_file_match(name, limit = 'Assets', threshold = 3)
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
    return @distances
  end

  def self.scan_dirs(dir, name, limit)
    dir.each_entry do |e|
      next if (e.fnmatch?('.') || e.fnmatch?('..') || e.fnmatch('*.meta'))
      # Would like to do this, but it fails with the message:
      # No such file or directory @ rb_file_s_ftype - PlayerController.cs (Errno::ENOENT)
      # next if ((e.ftype == 'directory') || e.fnmatch('*.meta'))
      d = levenshtein(name.to_s, e.to_s)
      f = {'directory': dir,'name': e, 'distance': d}
      @distances.push(f)
    end
    scan_dirs(dir.parent, name, limit) if (dir.parent.to_s.match?(limit))
  end

end
