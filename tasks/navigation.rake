namespace :nav do
  desc "Configure navigation settings."
  task :generate => :environment do
    require 'config/environment.rb'
    require 'pp'
    include NavHelper

    host = 'http://cercus.cns.montana.edu:8090'
    host = 'http://localhost:8080'
    persvr = Persevere.new(host)
    persvr = JSON.parse(persvr.retrieve("/Class?!core").body)
    models = {}
    persvr.each do |mod|
      model_name = mod['id'][6..-1]
      models.update({model_name => []})
    end
 
    models.each_pair do |model, properties|
      collection = JSON.load(RestClient.get("#{host}/#{model}", :accept => 'application/json'))
      collection.each do |instance|
        instance.each_pair do |attribute, value|
          update_properties(attribute, value, properties, [attribute])
        end  
      end
    end 
    #print_results(models)
    holy_hand_grenade
    generate(models)
  end
  
  def update_properties(attribute, value, properties, path)
    if value.class == Hash
      value.each_pair do |prime_attribute, prime_value|
        update_properties(prime_attribute, prime_value, properties, path << prime_attribute)
      end
    else
      if !properties.include?(attribute)
        properties << attribute
      end
    end
  end
  
  def generate(models)
    models.each_pair do |model_name, attributes|
      temp_mod = NavModel.new(:name          => model_name.downcase.singularize, 
                              :included      => false,
                              :controller    => model_name.downcase,
                              :display_name  => model_name,
                              :display_count => false
                              )
      attributes.each do |attrib|
        temp_attrib = NavAttribute.new(:name          => attrib,
                                       :included      => false,
                                       :display_name  => attrib,
                                       :display_count => false,
                                       :range         => false 
                                       )
        temp_mod.nav_attributes << temp_attrib
        temp_mod.save
      end
    end
    puts "You have created everything."
    puts "...you must be powerful..."
  end
  
  # Destroys the demons of the world, and some cute rabbits. Everything has its price
  def holy_hand_grenade
    NavModel.all.each do |i|
      i.destroy
    end
    NavAttribute.all.each do |i|
      i.destroy
    end
    NavDisplayValue.all.each do |i|
      i.destroy
    end
    NavDatabaseValue.all.each do |i|
      i.destroy
    end
    puts 'You have destroyed everything.'
  end
  
  def print_results(models)
    models.each_pair do |x, y|
      puts "Model: #{x}"
      y.each do |z|
        puts '--- ' + z
      end
      puts "\n"
    end
  end
  
end
