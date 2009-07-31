namespace :nav do
  desc "Configure navigation settings."
  task :gen => :environment do
    require 'config/environment.rb'
    persvr = Persevere.new("http://localhost:8080")
    persvr = JSON.parse(persvr.retrieve("/Class?!core").body)
    models = {}
    persvr.each do |mod|
      model_name = mod['instances']['$ref'][0..-2]
      models.update({model_name => []})
      unless mod['properties'] == nil
        mod['properties'].each_pair do |prop, type|
          models[model_name] << prop
        end
      end
    end
    initial_generation(models)
  end
  
  def initial_generation(models)
    models.each_pair do |model_name, attributes|
      temp_mod = NavModel.new(:name => model_name.downcase.singularize, 
                              :included => false,
                              :controller => model_name.downcase,
                              :display_name => model_name,
                              :display_count => false
                              )
      attributes.each do |attrib|
        temp_attrib = NavAttribute.new(:name => attrib,
                                       :included => false,
                                       :display_name => attrib,
                                       :display_count => false,
                                       :range => false 
                                       )
        temp_mod.nav_attributes << temp_attrib
        temp_mod.save
      end
    end
  end
  
end