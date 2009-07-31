class Alpha

  include DataMapper::Resource

  #has n, :betas
  #has_and_belongs_to_many :betas
  
  def self.default_repository_name
    :yogo
  end
  
  property :id, Serial
  property :stringattr, String
  property :integerattr, Integer
  property :dateattr, Date
  property :booleanattr, Boolean
  
  #property :betas, Array
  
  def self.random_string
    ['string1', 'string2', 'string3', 'string4', 'string5'][rand(5)]
  end
  
  def self.create_fixtures(i)
    i.times do |x|
      Alpha.create(:integerattr => rand(100), 
                   :stringattr => Alpha.random_string,
                   :dateattr => nil,
                   :booleanattr => [true, false][rand(2)]
                   ).save
    end
  end

end