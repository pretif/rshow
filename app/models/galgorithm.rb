class Galgorithm
  
  puts 'Definig class Galgorithm'
  INFINITY = 1 << 32
  @@loaded = false
  @@loading = false

  def Galgorithm.load_in_cache
    if @@loaded
      puts "Cache Loaded"
    else
      puts 'Called while loading' if @@loading
      unless @@loading
        start = Time.now
        @@loading = true
        puts 'Galgorithm.load_in_cache'
        ActiveRecord::Base.establish_connection :kbase42222
        @@infraversionid = Kbase::InfraRecord.infraversionid
        Gblock.load_in_cache(@@infraversionid)
        Gnode.load_in_cache(@@infraversionid)
        GblockNode.load_in_cache(@@infraversionid)
        Gblock.after_all_class_load(@@infraversionid)
        @@loading = false
        @@loaded = true
        puts ' Loading in cache time ' + (Time.now - start).to_s
      end
    end
  end

  #  def Galgorithm.reload_in_cache
  #    @@loaded = false
  #    Gblock.loaded = false
  #    Gnode.loaded = false
  #    GblockNode.loaded = false
  #    self.load_in_cache
  #  end
  
  # Galgorithm.load_in_cache # unless ENV['RAILS_ENV'] == 'production'

  def self.reset_cache
    #start = Time.now
    Gnode.reset_cache
    #puts ' reset_cache time Gnode ' + (Time.now - start).to_s
    #start = Time.now
    GblockNode.reset_cache
    #puts ' reset_cache time GblockNode ' + (Time.now - start).to_s
    #start = Time.now
    Gblock.reset_cache
    #puts ' reset_cache time Gblock ' + (Time.now - start).to_s
  end

  def Galgorithm.djikstra(from_stt, to_stt, from_st, to_st, limit = 3000000)
    Galgorithm.load_in_cache unless @@loaded
    return nil, nil, [], [], 0 if @@loading
    Galgorithm.reset_cache
    # Préparation
    vn_from = from_st.tracknodes.collect {|tn| tn.gnode} if from_st
    vn_from = [from_stt.gnode] if from_stt
    vn_to = to_st.tracknodes.collect {|tn| tn.gnode} if to_st
    vn_to = [to_stt.gnode] if to_stt
    vn_from.compact!
    vn_to.compact!
    nfrom = vn_from.first
    nto = vn_to.first
    #(puts 'nfrom: ' + nfrom.to_s) if nfrom
    #(puts 'nto: ' + nto.to_s) if nto
    return nil, nil, [], [], 0 if (nto.nil? or nfrom.nil?)
    from_blocks = []
    vn_from.each {|n_from| from_blocks += (n_from.gblock_nodes.collect {|bn| bn.block})}
    from_blocks.uniq!
    to_blocks = []
    vn_to.each {|n_to| to_blocks += (n_to.gblock_nodes.collect {|bn| bn.block})}
    to_blocks.uniq!
    # On teste le cas où les deux noeuds sont dans le from_blk
    for blk in from_blocks
      length = 0
      if (blk.nodes).member?(nto)
        todo = false ; done = false
        for bnode in blk.gblock_nodes
          if bnode.node == nfrom
            length = 0
            last_node = bnode
            todo = true
          end
          if todo
            d = last_node.node.fast_dist(bnode.node)
            length += d unless done
            last_node = bnode
            if bnode.node == nto
              done = true
            end
          end
        end
        if done
          return nfrom, nto, [blk], [], length
        end
      end
    end
    tos = []
    vn_to.each {|n_to| tos += (n_to.gblock_nodes.collect {|bn| bn.block.end_block_node})}
    tos.uniq!
    
    time_stamp = (Time.now.to_f * 1000).to_i.to_s
    target_tag = 'target_' + time_stamp
    for gbn in tos
      gbn.node.target = target_tag
    end

    pq = PQueue.new(proc {|x,y|
        x_dist = x.distance
        y_dist = y.distance
        if x_dist < y_dist
          true
        elsif x_dist == y_dist
          if x.nb_node <= y.nb_node
            true
          else
            false
          end
        else
          false
        end
      })
    
    visited_tag = 'visited_' + time_stamp
    in_queue_tag = 'in_queue_' + time_stamp
    
    blocks_will_need_cleanup = []
    vn_from.each do |gnd_from|
      # On passe du gnode au gblocknode
      # ie pour ttous les blocks du gnd_from
      for gbnd in gnd_from.gblock_nodes
        # On va détecter notre point dans le block
        detected = false
        blocks_will_need_cleanup << gbnd.block 
        gbnd.block.gblock_nodes.first.visited = visited_tag
        gbnd.block.gblock_nodes.each_cons(2) do |va|
          if va[0].node == gnd_from
            detected = true
            va[0].distance = 0
            va[0].nb_node = 0
            va[0].previous = nil
          end
          if detected
            dist = va[0].node.fast_dist(va[1].node)
            va[1].distance = va[0].distance + dist
            va[1].nb_node = va[0].nb_node + 1
            for startnd in va[1].node.gblock_nodes
              if startnd.seq == 0
                startnd.distance = va[1].distance
                startnd.nb_node = va[1].nb_node
                startnd.previous = va[1]
                pq.push(startnd) unless (startnd.in_queue == in_queue_tag)
                startnd.in_queue = in_queue_tag
              end
            end
            unless va[1].seq == 0
              va[1].previous = va[0] # en principe inutile
            end
          end
        end
      end
    end
    
    #    for blk in from_blocks
    #      detected = false
    #      pbnode = nil
    #      for fbnode in blk.gblock_nodes
    #        if detected
    #          d = fbnode.node.fast_dist(pbnode.node)
    #          fbnode.node.distance = pbnode.node.distance + d
    #          fbnode.nb_node = pbnode.nb_node + 1
    #          #debugger if (pbnode.nil? or fbnode == pbnode or pbnode.node.distance == 0)
    #          fbnode.previous = pbnode.node
    #          fbnode.in_queue = true
    #          pq.push(fbnode)
    #          pbnode = fbnode
    #        end
    #        if fbnode.node == nfrom
    #          detected = true 
    #          pbnode = fbnode
    #          pbnode.nb_node = 0
    #          pbnode.node.distance = 0
    #        end
    #      end  
    #    end

    nb_visited = 0
    to_block_node = nil
    good_length = 0
    catch(:done) do
      while pq.size != 0
        gbnd = pq.pop
        #puts 'pop ' + gbnd.to_s
        gbnd.visited = visited_tag
        nb_visited += 1
        vgbns = gbnd.block.forward_gnodes # toutes les sorties possibles
        vgbns.each do |vect|
          #puts vect.to_s
          dist = vect[0]
          ngbnd = vect[1]
          seq = vect[2]
          if ngbnd.visited != visited_tag and ngbnd.distance > gbnd.distance + dist
            # On est sur un chemin plus court
            #puts ngbnd.to_s + ' Old:' + ngbnd.distance.to_s + ' New:' + (gbnd.distance + dist).to_s
            ngbnd.distance = gbnd.distance + dist
            ngbnd.nb_node = gbnd.nb_node + seq
            pq.push(ngbnd) unless (ngbnd.in_queue == in_queue_tag)
            ngbnd.in_queue = in_queue_tag
            aux = ngbnd.node.gblock_nodes.detect {|gbn| gbn.block.id == gbnd.block.id }
            #(puts ' aux == nil ' + ngbnd.node.to_s) unless aux
            #puts ' aux ' + aux.to_s
            ngbnd.previous = aux
            if ngbnd.node.target == target_tag
              good_length = ngbnd.distance
              to_block_node = ngbnd
              throw :done
            elsif nb_visited > limit
              puts 'djikstra limit reached'
              throw :done
            end
          end
        end
      end
    end
    # Mise en forme des résultats
    arr = []
    bnodes = []
    count = 0
    unless to_block_node and to_block_node.previous
      puts 'bad routing'
      puts from_st
      puts to_st
    end
    if to_block_node and to_block_node.previous
      curr = to_block_node
      pblkid = -1
      blkid = curr.block.id
      while curr
        count += 1
        puts 'djikstra infinite loop ' + count.to_s if count.modulo(10000) == 0
        return nil, nil, [], [], 0 if count.modulo(50000) == 0
        unless pblkid == blkid
          arr << curr.block
          pblkid = blkid
        end
        bnodes << curr
        curr = curr.previous
      end
    end
    blocks_will_need_cleanup.each {|blk| blk.cleanup_previous }
    if to_block_node and to_block_node.previous
      return to_block_node.previous, to_block_node, arr.reverse, bnodes.reverse, good_length
    else
      return to_block_node, (to_block_node ? to_block_node.node : nil), [], [], 0
    end
  end

  def Galgorithm.profiler_test
    from_stt = nil
    to_stt = nil
    from_st = Kbase::Station.where("stationabbrev like '447243/00%' ").first
    to_st = Kbase::Station.where("stationabbrev like '447185/00%' ").first
    previous, tonode, blocks, nodes, length = Galgorithm.djikstra(from_stt, to_stt, from_st, to_st, limit = 3000000)
  end

end

=begin

Galgorithm.load_in_cache
tst = Gblock.some_gblocks(10)
gblns = tst.collect {|gb| gb.forward_gnodes}
test = gblns.flatten.find_all  {|gbln| gbln.seq == 0}
aux = test.collect {|gbn| gbn.forward_gnodes}
nodes.collect {|nd| nd.stationname}
tst.gblock_nodes.detect {|gbn| gbn.block.id == 66584}


Galgorithm.load_in_cache
from_stt = nil
to_stt = nil
from_st = Kbase::Station.where("stationabbrev like '447243/00%' ").first
to_st = Kbase::Station.where("stationabbrev like '447185/00%' ").first
previous, tonode, blocks, nodes, length = Galgorithm.djikstra(from_stt, to_stt, from_st, to_st, limit = 3000000)


rails profiler 'Galgorithm.profiler_test'

Rack::MiniProfiler.step('Routing') { Galgorithm.profiler_test }


require 'ruby-prof'
RubyProf.start
Galgorithm.profiler_test
result = RubyProf.stop

=end
