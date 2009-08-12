class NavAttribute
  
  include DataMapper::Resource
  
  belongs_to :nav_model
  has n, :nav_display_values
  
  property :id, Serial
  property :name, String
  property :included, Boolean
  property :display_name, String
  property :display_count, Boolean
  property :range, Boolean
  
end
