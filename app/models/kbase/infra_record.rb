class Kbase::InfraRecord < ActiveRecord::Base
  self.abstract_class = true
  
  @@infraversionid
  
  class << self; attr_accessor :infraversionid end
  
  Kbase::InfraRecord.infraversionid = 281
  
end
