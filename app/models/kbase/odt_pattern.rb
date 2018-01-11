class Kbase::OdtPattern < ApplicationRecord
  establish_connection :kbase42222
  self.table_name = 'odtpattern'
  self.primary_keys = :opdaytmplid,:opdaytypeid,:fixeddate

  attribute :opdaytmplid, :integer
  attribute :opdaytypeid, :integer
  attribute :fixeddate, :integer
  attribute :includeflag, :integer

  belongs_to :opdaytmpl,
    :class_name => 'Kbase::OpDayTmpl',
    :foreign_key => "opdaytmplid"

  belongs_to :opdaytype,
    :class_name => 'Kbase::OpDayType',
    :foreign_key => "opdaytypeid"
  
end

