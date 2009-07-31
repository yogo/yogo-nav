class NavModel
  
  include DataMapper::Resource
  
  # def self.set_default_repository_name
  #   return "nav_data"
  # end
  
  has n, :nav_attributes
  
  property :id, Serial
  property :name, String
  property :included, Boolean
  property :controller, String
  property :display_name, String
  property :display_count, Boolean
  
end
