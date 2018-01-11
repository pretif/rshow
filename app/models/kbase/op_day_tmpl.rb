class Kbase::OpDayTmpl < ApplicationRecord
  establish_connection :kbase42222
  self.table_name = 'opdaytmpl'
  self.primary_key = 'id'

  attribute :id, :integer
  attribute :begindate, :integer
  attribute :enddate, :integer
  
  has_many :odtpatterns,
    :class_name => 'Kbase::OdtPattern',
    :foreign_key => "opdaytmplid"

  has_many :odtcalendars,
    :class_name => 'Kbase::OdtCalendar',
    :foreign_key => "opdaytmplid"
  
  has_many :odttimespans,
    :class_name => 'Kbase::OdtTimeSpan',
    :foreign_key => "odtid"

  def compile_week
    vect = [0,0,0,0,0,0,0]
    for pat in self.odtpatterns
      if pat["OPDAYTYPEID"] == 8
        vect = Array.new(7,pat["INCLUDEFLAG"])
      elsif pat["OPDAYTYPEID"] < 8
        vect[pat["OPDAYTYPEID"]] = pat["INCLUDEFLAG"]
      end
    end
    vect
  end

  def compile_pattern
    puts 'Warning 2011'
    vect = Array.new(400, 0)
    st_year = Date.new(2011,01,01)
    start = Date.new(2010,12,13)
    delta = (st_year - start).to_i
    swd = start.wday
    syd = start.yday
    cw = self.compile_week
    0.upto(400) {|i|
      vect[i] = cw[(i + swd).modulo(7)]
    }
    for pat in self.kodtpattern
      if pat["OPDAYTYPEID"] == 15
        if pat.zfixeddate > start
          if pat.zfixeddate < st_year
            vect[pat.zfixeddate.yday - syd] = pat["INCLUDEFLAG"]
          else
            vect[pat.zfixeddate.yday + delta] = pat["INCLUDEFLAG"]
          end
        end
      end
    end
    vect
  end

  def compile_calendar
    vect = Array.new(400, 0)
    st_year = Date.new(2011,01,01)
    start = Date.new(2010,12,13)
    delta = (st_year - start).to_i
    swd = start.wday
    syd = start.yday
    for cal in  self.kodtcalendar

    end
  end

  def self.opdaytmpl_convert_regime
    i = 0
    while ((opdts = Kbase::OpDayTmpl.find :all, :order => '"ID"',
          :limit => 500, :offset => (i * 500)) && opdts && opdts.length > 0 && i == 0)
      i += 1
      for opdt in opdts
        opdt.bit_reg = opdt.compile_pattern
        opdt.save!
      end
    end
  end

=begin
  require 'date'
  now = DateTime.now
  now.yday

  dt = KopDayTmpl.find :first
  cal = dt.kodtcalendar
  pat = dt.kodtpattern
  pat[1]["OPDAYTYPEID"]
  dt.compile_pattern

  KopDayTmpl.opdaytmpl_convert_regime
=end

end
