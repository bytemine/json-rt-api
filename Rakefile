require 'bundler/setup'
require 'warbler'

task :default => [:jar]

Warbler::Task.new('jar') do |jar|
  $LOAD_PATH.unshift 'lib'

  require 'rt_api'

  jar.config.jar_name = "rt-api-#{RTAPI::VERSION}"
  jar.config.features = %w(executable)
  jar.config.dirs = %w(bin lib)
end

task :console do
  require 'pry'

  $LOAD_PATH.unshift 'lib'

  Dir['lib/**/*.rb'].each {|f| require f }

  include RTAPI

  Pry.config.pager = false
  Pry.start(binding, :quiet => true)
end
