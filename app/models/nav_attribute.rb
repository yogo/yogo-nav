class NavAttribute
  
  include DataMapper::Resource
  
  # def self.set_default_repository_name
  #   return :nav_data
  # end
  
  belongs_to :nav_model
  has n, :nav_display_values
  has n, :nav_database_values
  
  property :id, Serial
  property :name, String
  property :included, Boolean
  property :display_name, String
  property :display_count, Boolean
  property :range, Boolean
  
end
