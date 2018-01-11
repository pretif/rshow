class Kbase::SchedRecord < ActiveRecord::Base
  self.abstract_class = true
  
  @@schedversionid
  
  class << self; attr_accessor :schedversionid end
  
  Kbase::SchedRecord.schedversionid = 601
  
end
