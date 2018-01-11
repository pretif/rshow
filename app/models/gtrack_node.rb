class GtrackNode
  attr_accessor :track, :seq, :node
  
  @@loaded = false
  class << self; attr_accessor :loaded end

  def gnode
    Gnode.find(self[:node])
  end

# def self.load_in_cache(infraversionid)
#    unless @@loaded
#      start = Time.now
#      puts 'Loading GtrackNode'
#      tracknodes ||= Kbase::TrackNode.joins("INNER JOIN track on tracknode.infraversionid = tracknode.infraversionid and tracknode.stationtrackid = track.stationtrackid").joins('INNER JOIN stationtrack on stationtrack.id = track..stationtrackid').order('blockid,seq asc').where(infraversionid: infraversionid)
#      for tn in tracknodes
#        nd = Gnode.find(tn.node)
#        sth = tn.track.stationtrack
#        gn = GblockNode.new :block => blk, :seq => bn[:seq], :node => nd
#        (nd.gblock_nodes << gn) if nd
#        (blk.gblock_nodes << gn) if blk
#      end
#      puts 'End Loading GblockNode ' + (Time.now - start).to_s
#      @@loaded = true
#    end
#  end

end
