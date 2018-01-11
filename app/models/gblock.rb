class Gblock
  attr_accessor :id, :the_geom, :nodes, :length, :nb_node, :gblock_nodes, :forward_gnodes
  
  ActiveRecord::Base.establish_connection :kbase42222

  puts 'Definig class Gblock'
  INFINITY = 1 << 32 
  @@loaded = false
  @@linked = false
  @@gblocks = {}

  class << self; attr_accessor :loaded end
  
  def Gblock.gblocks
    @@gblocks
  end

  def block
    Kbase::Block.where(infraversionid: Kbase::InfraRecord.infraversionid, id: self.id).first
  end
  
  def inspect
    '#<Gblock:' + self.id.to_s + ',' + self.length.to_s + '>'
  end

  require 'enumerator'

  def compute_length
    res = 0
    self.nodes.each_cons(2) do |vect|
      res += vect[0].fast_dist(vect[1])
    end
    res
  end

  def initialize(ha)
    @id = ha[:id]
    @the_geom = ha[:the_geom]
    @length = INFINITY
    @nb_node = INFINITY 
    @gblock_nodes = []
    @nodes = []
    @forward_gnodes = nil
  end

  def self.reset_cache
    @@gblocks.each  do |k, gblk|
      gblk.gblock_nodes.first.previous = nil
      #gblk.gblock_nodes.each_cons(2) do |va|
      #  va[1].previous = va[0]
      #end
    end
    true
  end

  def cleanup_previous
    # Nécessaire pour les cantons de démarrage
    self.gblock_nodes.each_cons(2) do |va|
      va[1].previous = va[0]
    end
    true
  end
  
  def self.find(id)
    @@gblocks[id]
  end
  
  def Gblock.test
    @@gblocks.length
  end

  def self.load_in_cache(infraversionid)
    unless @@loaded
      start = Time.now
      puts 'Loading Gblock'
      blks = Kbase::Block.select('id,the_geom').where(infraversionid: infraversionid)
      for blk in blks
        #blocknodes = Kbase::BlockNode.find :all, :order => 'seq asc', :conditions => "infraversionid = #{infraversionid} AND blockid = #{blk[:id]}"
        #nodes = blocknodes.collect {|blkn| Gnode.find blkn.node}
        gblk = Gblock.new :id => blk[:id], :the_geom => blk.the_geom #, :nodes => nodes
        @@gblocks[gblk.id] = gblk
      end
      puts 'End Loading Gblock ' + (Time.now - start).to_s
      @@loaded = true
    end
  end


  def forward_gnodes
    # La liste des sorties du block qui n'appartienne pas au block
    @forward_gnodes ||= self._forward_gnodes 
  end

  def _forward_gnodes
    dist = 0
    vres = []
    pgbnd = nil
    for fgbnd in self.gblock_nodes
      unless pgbnd.nil?
        dist += pgbnd.node.fast_dist(fgbnd.node)
        lother = fgbnd.node.forward_blocks.collect {|blk| 
          debugger unless blk
          blk != self ? blk.gblock_nodes.first : nil}
        lother.compact!
        for other in lother
          vres << [dist, other, fgbnd.seq]  # vecteur de distance, extremité, nb de noeud
        end
      end
      pgbnd = fgbnd
    end
    self.gblock_nodes.each_cons(2) do |va|
      va[1].previous = va[0]
    end
    vres
  end

  def self.after_all_class_load(infraversionid)
    unless @@linked
      start = Time.now
      puts 'Linking Gblock'
      @@gblocks.each do |k, gblk|
        gblk.nodes = gblk.gblock_nodes.collect {|bn| bn.node}
        gblk.length = gblk.compute_length
        gblk.nb_node = gblk.nodes.length
        gblk.forward_gnodes
      end
      puts 'End Linking Gblock ' + (Time.now - start).to_s
      @@linked = true
    end
  end

  def self.some_gblocks(default= 100)
    i = 0 ; res = []
    @@gblocks.each do |k, gblk|
      res << gblk
      i += 1
      return res if i > default
    end
    res
  end
  
  def end_node
    @end_node ||= @nodes.last
  end

  def start_node
    @nodes.first
  end

  def end_block_node
    @end_blk_node ||= @gblock_nodes.last
  end

  def start_block_node
    @gblock_nodes.first
  end

  def dist_from_node_to_end(node = nil)
    res = 0 ; bad = false ; todo = false
    self.gblock_nodes.each_cons(2) do |vect|
      if node.nil? || vect[0] == node
        todo = true
      end
      if todo
        d = vect[0].node.fast_dist(vect[1].node)
        if d.is_a?(Fixnum)
          res += d
        else
          bad = true
        end
      end
    end
    bad ? 'n/a' : res
  end

  def dist_start_to_node(node = nil)
    res = 0 ; bad = false ; todo = true
    self.gblock_nodes.each_cons(2) do |vect|
      if node.nil? || vect[0] == node
        todo = false
      end
      if todo
        d = vect[0].node.fast_dist(vect[1].node)
        if d.nil?
          bad = true
        else
          res += d
        end
      end
    end
    bad ? 'n/a' : res
  end

end
