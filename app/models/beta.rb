class Beta
    
    
    include DataMapper::Resource

    # has_and_belongs_to_many :alphas
    #has :alphas
    # has_many :omegas
    #has n, :omegas
    
    def self.default_repository_name
      :yogo
    end

    property :id, Serial
    property :stringattr, String
    property :integerattr, Integer
    property :dateattr, Date
    property :booleanattr, Boolean

    def self.random_string
      ['string1', 'string2', 'string3', 'string4', 'string5'][rand(5)]
    end

    def self.create_fixtures(i)
      i.times do |x|
        Beta.create(:integerattr => rand(100), 
                     :stringattr => Beta.random_string,
                     :dateattr => nil,
                     :booleanattr => [true, false][rand(2)]
                     ).save
      end
    end
    
end
