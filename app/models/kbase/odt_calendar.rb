class Kbase::OdtCalendar < ApplicationRecord
  establish_connection :kbase42222
  self.table_name = 'odtcalendar'
  self.primary_keys = 'opdaytmplid','fixeddate'

  attribute :opdaytmplid, :integer
  attribute :fixeddate, :integer
  
  belongs_to :opdaytmpl,
    :class_name => 'Kbase::OpDayTmpl',
    :foreign_key => "opdaytmplid"

end

