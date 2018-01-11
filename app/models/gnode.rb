class Gnode
  # à cause des rebroussements, la distance et le nb de node ne peut-être portée par le gnode
  attr_accessor :nodeid, :xcoord, :ycoord, :kmvalue, :kmregionid, :secondkmvalue, :secondkmregionid, 
                :gblock_nodes, :stationid, :stationname, :trackname, :target

  INFINITY = 1 << 32
  ActiveRecord::Base.establish_connection :kbase42222
  @@gnodes = {}
  @@loaded = false
  class << self; attr_accessor :loaded end
  
  def Gnode.gnodes
    @@gnodes
  end

  def to_s
    '#<Gnode:' + self.nodeid.to_s + ',' + self.stationname.to_s + self.trackname.to_s + '>'
  end

  def inspect
    self.to_s
  end

  def initialize(ha)
    @nodeid = ha[:nodeid]
    @xcoord = ha[:xcoord]
    @ycoord = ha[:ycoord]
    @kmvalue = ha[:kmvalue]
    @kmregionid = ha[:kmregionid]
    @secondkmvalue = ha[:secondkmvalue]
    @secondkmregionid = ha[:secondkmregionid]
    @gblock_nodes = []
    @target = false
  end

  # nd = Kbase::Node.select("id, xcoord as gx, -1 * ycoord as gy, kmvalue, kmregionid, secondkmvalue, secondkmregionid").where(infraversionid: Kbase::InfraRecord.infraversionid).limit(1).first
  
  def self.load_in_cache(infraversionid)
    # ATTENTION : On renverse la coordonnée y pour les gnodes
    unless @@loaded
      start = Time.now
      puts 'Loading Gnode'
      #knodes = Kbase::Node.select("id, xcoord, ycoord, kmvalue, kmregionid, secondkmvalue, secondkmregionid").where(infraversionid: infraversionid)
      knodes = Kbase::Node.joins(:blocknodes).where(infraversionid: infraversionid).select("id, xcoord, ycoord, kmvalue, kmregionid, secondkmvalue, secondkmregionid").distinct
      for node in knodes
        @@gnodes[node[:id]] = Gnode.new :nodeid => node[:id],
          :xcoord => node[:xcoord], :ycoord => -1 * node.ycoord, :kmvalue => node.kmvalue,
          :kmregionid => node.kmregionid,
          :secondkmvalue => node.secondkmvalue, :secondkmregionid => node.secondkmregionid
      end
      trnds = Kbase::TrackNode.where(infraversionid: infraversionid).select("tracknode.node,stationtrack.id,stationheader.name,stationtrack.stationid,stationtrack.abbreviation,stationtrack.nameforpublishing").joins(track: [{stationtrack: :station}]).where('tracknode.seq = 0')
      for trnd in trnds
        gn = @@gnodes[trnd[:node]]
        if gn
         gn.stationid = trnd.stationid
         gn.stationname = trnd.name
         gn.trackname = trnd.abbreviation.rstrip + '#' + trnd.nameforpublishing.rstrip
        end
      end
      puts 'End Loading Gnode ' + (Time.now - start).to_s
      @@loaded = true
    end
  end
  

=begin
trnds = Kbase::TrackNode.select("tracknode.node,stationtrack.id").joins(track: [{stationtrack: :station}])
nds = nodes.collect {|nd| [nd.nodeid, nd.stationid, nd.stationname, nd.trackname, nd.xcoord, nd.ycoord]}
=end

  def Gnode.test
    @@gnodes.length
  end

  def Gnode.some_gnodes
    res = [] ; i = 0
    @@gnodes.each do |k, node|
      res << node
      i += 1
      if i > 10
        return res
      end
    end
    res
  end
 
  def Gnode.some_gnodes_with_stationtracks
    Galgorithm.load_in_cache
    res = [] ; i = 0
    @@gnodes.each do |k, node|
      if node.stationid
      res << node
      i += 1
      if i > 10
        return res
      end
      end
    end
    res
  end

  def Gnode.reset_cache
#    @@gnodes.each do |k, node|
#      node.target = false
#    end
    true
  end

  def Gnode.find(nodeid)
    @@gnodes[nodeid]
  end

  def Gnode.find_or_load(nodeid)
    # Le pb est que les travaux peuvent-être sur des noeuds qui ne sont pas liés à des block_nodes
    # Donc on les charge à la demande
    if aux = @@gnodes[nodeid]
      aux
    else
      node = Kbase::Node.where(infraversionid: Kbase::InfraRecord.infraversionid, id: nodeid).select("id, xcoord, ycoord, kmvalue, kmregionid, secondkmvalue, secondkmregionid").take
      @@gnodes[node[:id]] = Gnode.new :nodeid => node[:id],
          :xcoord => node[:xcoord], :ycoord => -1 * node.ycoord, :kmvalue => node.kmvalue,
          :kmregionid => node.kmregionid,
          :secondkmvalue => node.secondkmvalue, :secondkmregionid => node.secondkmregionid
    end
  end

  def forward_blocks
    # tous les blocks demarrant de ce noeud
    if @forward_blocks
      @forward_blocks 
    else
      @forward_blocks = []
      for blkn in self.gblock_nodes
        @forward_blocks << blkn.block if blkn.seq == 0 # blkn == blkn.block.gblock_nodes.first
      end
      @forward_blocks
    end
  end
  
  def km(kmrid)
    if self.kmregionid == kmrid
      self.kmvalue
    elsif self.secondkmregionid == kmrid
      self.secondkmvalue
    else
      nil
    end
  end

  def name
    self.id.to_s + ' ' + self.kmvalue.to_s + ' ' + (self.kmregion ? self.kmregion.name : 'n/a')
  end

  def fast_dist(other)
    case
    when self.kmregionid == other.kmregionid
      (self.kmvalue - other.kmvalue).abs
    when self.kmregionid == other.secondkmregionid
      (self.kmvalue - other.secondkmvalue).abs
    when self.secondkmregionid == other.kmregionid
      (self.secondkmvalue - other.kmvalue).abs
    when self.secondkmregionid == other.secondkmregionid
      (self.secondkmvalue - other.secondkmvalue).abs
    else
      nil
    end
  end

  def km_dist(kmregionid,pk)
    if self.kmregionid == kmregionid
      (self.kmvalue - pk).abs
    elsif self.secondkmregionid == kmregionid
      (self.secondkmvalue - pk).abs
    else
      'n/a'
    end
  end

  def distance_direct(other)
    other.dist_direct ||= (if self.xcoord && other.xcoord
        diffx = (self.xcoord - other.xcoord) * 7.78
       diffy = (self.ycoord - other.ycoord) * 8.569
       Math.sqrt( diffx * diffx + diffy * diffy)
      else
        false
      end)
  end
end


