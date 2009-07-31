class NavDisplayValue
  
  include DataMapper::Resource
  
  # def self.set_default_repository_name
  #   return :nav_data
  # end
  
  belongs_to :nav_attribute
  
  property :id, Serial
  property :value, String
  
end
