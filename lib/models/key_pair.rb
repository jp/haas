class Haas
  class KeyPair < ActiveRecord::Base
    validates_uniqueness_of :name
    before_create :get_private_key

    def get_private_key
      collection = AWS::EC2::KeyPairCollection.new
      key = collection.create self.name
      self.private_key = key.private_key
    end
  end
end
