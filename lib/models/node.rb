class Haas
  class Node < ActiveRecord::Base
    belongs_to :cluster
  end
end
