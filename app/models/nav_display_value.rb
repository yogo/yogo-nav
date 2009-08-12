class NavDisplayValue
  
  include DataMapper::Resource
  
  belongs_to :nav_attribute
  has 1, :nav_database_value
  
  property :id, Serial
  property :value, String
  
end
