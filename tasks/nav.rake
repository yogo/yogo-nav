namespace :nav do
  desc "Configure navigation settings."
  task :generate => :environment do
    require 'config/environment.rb'
    include NavHelper
    if File.exist?("#{RAILS_ROOT}/config/nav_config.yml") 
      backup_settings
      settings = append_new_models
    else
      settings = initial_write(File.new("#{RAILS_ROOT}/config/nav_config.yml", 'w'), fetch_models) 
    end
    settings = update_attributes(settings)
    settings.close
  end
  
  def fetch_models
    models = []
    (ActiveRecord::Base.connection.tables - ['schema_migrations']).each do |mod|
      begin
        mod = mod.classify.constantize
        models << mod
      rescue
        puts ":: join table encountered ::"
      end
    end
    models
  end
  
  def fetch_columns(table)
    if table.column_names.empty?
      return []
    else
      columns = (table.column_names - ['id', 'created_at', 'updated_at'])
      columns.map {|col| col.capitalize}
      columns
    end
  end  

  def append_new_models
    settings      = File.open("#{RAILS_ROOT}/config/nav_config.yml", 'a+')
    app_models    = fetch_models
    config_models = YAML.load_file("#{RAILS_ROOT}/config/nav_config.yml")
    app_models.each do |table|
      if !config_models.include?(table.name.downcase)
        settings = append_write(settings, table)
      end
    end
    return settings
  end
  
  def update_attributes(settings)
    settings
  end

  def backup_settings
    copy("#{RAILS_ROOT}/config/nav_config.yml", "#{RAILS_ROOT}/config/nav_config_backup.yml")
  end

  def append_write(settings, model)
    settings.puts
    settings.puts model.name.downcase + ':'
    settings.puts '    searchable: true'
    settings.puts "    controller: #{model.name.downcase}"
    settings.puts "    display_value: #{model.name}"
    settings.puts "    display_count: false"
    settings.puts '    attributes:'
    fetch_columns(model).each do |attribute|
      settings.puts "        #{attribute.downcase}:"
      settings.puts "            include: true"
      settings.puts "            display_value: #{attribute.downcase}"
      settings.puts "            display_count: true"
      settings.puts "            range: false"
      settings.puts "            values:"
      settings.puts "                display_values:  these . are . sample . values"
      settings.puts "                database_values: these . are . sample . values"        
    end
    return settings
  end
  
  def initial_write(settings, models)
    settings.puts '# alpha:                                    <----Name of the model'
    settings.puts '#     searchable: true                      <----Determines if this model will be shown in the nav bar'
    settings.puts "#     controller: alphas                    <----Specifies the name of the controller to display results"
    settings.puts '#     display_value: alpha                  <----This value allows you to change how the model name is displayed'
    settings.puts '#     display_count: false                  <----Gives a current total of entries next to model name'
    settings.puts '#     attributes:'
    settings.puts '#         attribute_n:                      <----The models attribute, only one listed here for the example' 
    settings.puts '#             include:  true                <----Determines whether or not this attribute is searchable'
    settings.puts '#             display_value: attribute_n    <----This value allows you to change how the attribute name is displayed'
    settings.puts '#             display_count: true           <----Shows how many instances are in this container'
    settings.puts '#             range: true                   <----Determines if attribute has a range of values corrolated to it'
    settings.puts '#             values:'
    settings.puts '#                 display_values:           <----These values will be displayed for navigation'
    settings.puts '#                 database_values:          <----These values need to be corrolated with display values, and are the actual database values'
    settings.puts "# Remember, changes to this file require a server restart! Also, values *must* be separated by ' . ' <space><period><space>."
    settings.puts '# For your convinience, anytime this rake task is run, a backup of the current data will be created in the same directory.'
    settings.puts
    fetch_models.each do |table|
      settings.puts table.name.downcase + ':'
      settings.puts '    searchable: true'
      settings.puts "    controller: #{table.name.downcase}"
      settings.puts "    display_value: #{table.name}"
      settings.puts '    display_count: false'
      settings.puts '    attributes:'
      fetch_columns(table).each do |attribute|
        settings.puts "        #{attribute.downcase}:"
        settings.puts "            include: true"
        settings.puts "            display_value: #{attribute.downcase}"
        settings.puts "            display_count: true"
        settings.puts "            range: true"
        settings.puts "            values:"
        settings.puts "                display_values:  these . are . sample . values"
        settings.puts "                database_values: these . are . sample . values"        
      end
    end
    return settings
  end
  
end




# namespace :nav do
#   desc "Configure navigation settings."
#   task :generate => :environment do
#     require 'config/environment.rb'
#     include NavHelper
#     if File.exist?("#{RAILS_ROOT}/config/nav_config.yml") 
#       backup_settings
#       old_set = YAML.load_file("#{RAILS_ROOT}/config/nav_config.yml")
#       settings = write_settings(File.open("#{RAILS_ROOT}/config/nav_config.yml", 'w'), fetch_models)
#       settings.close
#       new_set = YAML.load_file("#{RAILS_ROOT}/config/nav_config.yml")
#       update_setting_values(old_set, new_set)
#     else
#       settings = write_settings(File.new("#{RAILS_ROOT}/config/nav_config.yml", 'w'), fetch_models) 
#       settings.close
#     end
#   end
#   
#   def update_setting_values(old_set, new_set)
#       settings = File.new("#{RAILS_ROOT}/config/nav_config.yml", 'w')
#       updated_set = new_set.merge(old_set)
#       updated_set.each_pair do |model, table_options|
#         settings.puts "#{model}:"
#         table_options.each_pair do |table_option_name, table_option_value|
#           if table_option_value.is_a?(Hash)
#             settings.puts "#{indent(1)}#{table_option_name}:"
#             table_option_value.each_pair do |attribute_name, attribute_options|
#               settings.puts "#{indent(2)}#{attribute_name}:"
#               attribute_options.each_pair do |option_name, option_value|
#                 if option_value.is_a?(Hash)
#                   settings.puts "#{indent(3)}#{option_name}:"
#                   option_value.each_pair do |key, value|
#                     settings.puts "#{indent(4)}#{key}: '#{value}'"
#                   end
#                 else
#                   settings.puts "#{indent(3)}#{option_name}: '#{option_value}'"
#                 end
#               end
#             end
#           else
#             settings.puts "#{indent(1)}#{table_option_name}: '#{table_option_value}'"
#           end
#         end
#       end
#       settings.close
#     end
#   
#   def backup_settings
#     copy("#{RAILS_ROOT}/config/nav_config.yml", "#{RAILS_ROOT}/config/nav_config_backup.yml")
#   end
#   
#   def indent(i)
#     indent = ''
#     i.times do
#       indent += '    '
#     end
#     return indent
#   end
# 
#   def write_settings(settings, models)
#     settings.puts '# alpha:                                    <----Name of the model'
#     settings.puts "#     controller: alphas                    <----Specifies the name of the controller to display results"
#     settings.puts '#     searchable?: true                     <----Determines if this model will be shown in the nav bar'
#     settings.puts '#     display_value: alpha                  <----This value allows you to change how the model name is displayed'
#     settings.puts '#     display_count?: false                 <----Gives a current total of entries next to model name'
#     settings.puts '#     attributes:'
#     settings.puts '#         attribute_n:                      <----The models attribute, only one listed here for the example' 
#     settings.puts '#             include?: true                <----Determines whether or not this attribute is searchable'
#     settings.puts '#             display_value: attribute_n    <----This value allows you to change how the attribute name is displayed'
#     settings.puts '#             display_count?: true          <----Shows how many instances are in this container'
#     settings.puts '#             range?: true                  <----Determines if attribute has a range of values corrolated to it'
#     settings.puts '#             values:'
#     settings.puts '#                 display_values:           <----These values will be displayed for navigation'
#     settings.puts '#                 database_values:          <----These values need to be corrolated with display values, and are the actual database values'
#     settings.puts "# Remember, changes to this file require a server restart! Also, values *must* be separated by ', ' <comma><space>."
#     settings.puts '# For your convinience, anytime this rake task is run, a backup of the current data will be created in the same directory.'
#     settings.puts
#     fetch_models.each do |table|
#       settings.puts table.name.downcase + ':'
#       settings.puts '    searchable?: true'
#       settings.puts "    controller: #{table.name.downcase}"
#       settings.puts "    display_value: #{table.name}"
#       settings.puts '    display_count?: false'
#       settings.puts '    attributes:'
#       fetch_columns(table).each do |attribute|
#         settings.puts "        #{attribute.downcase}:"
#         settings.puts "            include?: true"
#         settings.puts "            display_value: #{attribute.downcase}"
#         settings.puts "            display_count?: true"
#         settings.puts "            range?: true"
#         settings.puts "            values:"
#         settings.puts "                display_values:  'these, are, sample, values'"
#         settings.puts "                database_values: 'these, are, sample, values'"        
#       end
#     end
#     return settings
#   end
#   
# end