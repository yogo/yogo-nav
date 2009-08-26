require 'yogo_nav'
require 'fileutils'

unless File.exist? "#{RAILS_ROOT}/public/javascripts/showhide.js"
  FileUtils.cp("#{File.dirname(__FILE__)}/../assets/showhide.js", "#{RAILS_ROOT}/public/javascripts/")
end
unless File.exist? "#{RAILS_ROOT}/public/stylesheets/yogo_nav.css"
  FileUtils.cp("#{File.dirname(__FILE__)}/../assets/yogo_nav.css", "#{RAILS_ROOT}/public/stylesheets/")
end