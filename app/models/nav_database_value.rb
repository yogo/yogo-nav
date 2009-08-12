class NavDatabaseValue
  
  include DataMapper::Resource
  
  belongs_to :nav_display_value

  property :id, Serial
  property :value, String
  
end