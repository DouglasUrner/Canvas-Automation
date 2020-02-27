module Secrets
  class Error < StandardError; end
  def self.source(path)
    # Inspired by user takeccho at http://stackoverflow.com/a/26381374/3849157
    # Sources sh-script or env file and imports resulting environment
    fail(ArgumentError, "File #{path} missing or unreadable.") \
       unless File.exist?(path)

    _env_hash_str = `env -i sh -c 'set -a; source #{path} && ruby -e "p ENV"'`
    fail(ArgumentError, 'Malformed environment in #{path}.') \
       unless _env_hash_str.match(/^\{("[^"]+"=>".*?",\s*)*("[^"]+"=>".*?")\}$/)

    _env_hash = eval(_env_hash_str)
     %w[ SHLVL PWD _ ].each{ |k| _env_hash.delete(k) }
    _env_hash.each{ |k,v| ENV[k] = v }
  end
end
