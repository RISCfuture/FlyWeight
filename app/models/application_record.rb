# @abstract
#
# Abstract superclass for all FlyWeight models.

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
