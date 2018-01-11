class GblockNode
  # un gbnode a comme successeur possible tous les gbnodes commencant un block sur ses noeuds
  attr_accessor :block, :seq, :node, :distance, :nb_node, :visited, :in_queue, :previous
  INFINITY = 1 << 32

  @@loaded = false
  class << self; attr_accessor :loaded end
  
  def initialize(ha)
    @block = ha[:block]
    @seq = ha[:seq]
    @node = ha[:node]
    @distance = INFINITY
    @nb_node = INFINITY
    @visited = false
    @in_queue = false
    @previous = nil
  end

  def to_s
    nd = self.node
    '#<GblockNode:' + (self.block ? self.block.id.to_s : 'block nil' ) +  
      ',seq:' + self.seq.to_s + ',dist:' + self.distance.to_s + ',nbn:' + self.nb_node.to_s + ',nid:' + (nd ? nd.nodeid.to_s  : ' node null') + '>'
  end
     
  def inspect
    self.to_s
  end

  def xcoord
    self.node.xcoord
  end

  def ycoord
    self.node.ycoord
  end

  ActiveRecord::Base.establish_connection :kbase42222

=begin
 Gblock.gblocks
 GblockNode.loaded
 nds = Kbase::BlockNode.joins("INNER JOIN block on block.id = blocknode.blockid").select('blockid,seq,node').order('blockid,seq asc').where(infraversionid: Kbase::InfraRecord.infraversionid)
=end
  
  def self.load_in_cache(infraversionid)
    unless @@loaded
      start = Time.now
      puts 'Loading GblockNode'
      blknds = Kbase::BlockNode.where(infraversionid: infraversionid).joins("INNER JOIN block on block.id = blocknode.blockid and block.infraversionid = blocknode.infraversionid").order('infraversionid,blockid,seq asc')
      for bn in blknds
        nd = Gnode.find(bn.node)
        blk = Gblock.find(bn.blockid)
        gn = GblockNode.new :block => blk, :seq => bn[:seq], :node => nd
        (nd.gblock_nodes << gn) if nd
        (blk.gblock_nodes << gn) if blk
      end
      puts 'End Loading GblockNode ' + (Time.now - start).to_s
      @@loaded = true
    end
  end

  def forward_blocks
    self.node.forward_blocks
  end
  
  def forward_gnodes
    self.block.forward_gnodes.slice(self.seq, 100)
  end
  
  def self.reset_cache
    Gblock.gblocks.each do |k, blck|
      fisrt_gbn = blck.gblock_nodes.first
      fisrt_gbn.distance = INFINITY
      fisrt_gbn.nb_node = INFINITY
#      
#      for gn in blck.gblock_nodes
#        gn.distance = INFINITY
#        gn.nb_node = INFINITY
#        #gn.visited = false
#        #gn.in_queue = false
#        #gn.previous = nil
#      end
    end
  end

end
