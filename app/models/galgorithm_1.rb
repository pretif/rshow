class Galgorithm
  
  puts 'Galgorithm'
  INFINITY = 1 << 32
  @@loaded = false
  @@loading = false

  def Galgorithm.load_in_cache_old
    if @@loaded
      puts "Loaded"
    else
      puts 'Called while loading' if @@loading
      unless @@loading
        start = Time.now
        @@loading = true
        puts 'Galgorithm.load_in_cache'
        ActiveRecord::Base.establish_connection :kbase42222
        @@infraversionid = '5145'
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
    Gnode.reset_cache
    GblockNode.reset_cache
    Gblock.reset_cache
  end

  def Galgorithm.find_tps_path_a_star(from_stt, to_stt, from_st, to_st, limit = 3000000)
    Galgorithm.load_in_cache unless @@loaded
    Galgorithm.reset_cache
    vn_from = from_st.stationtracks.collect {|tr| (ta = tr.track) && (tn = ta.tracknode) ? tn.gnode : nil} if from_st
    vn_from = [from_stt.gnode] if from_stt
    vn_to = to_st.stationtracks.collect {|tr| (ta = tr.track) && (tn = ta.tracknode) ? tn.gnode : nil} if to_st
    vn_to = [to_stt.gnode] if to_stt
    vn_from.compact!
    vn_to.compact!
    nfrom = vn_from.first
    nto = vn_to.first
    return nil, nil, [], 0 unless nto
    vn_to.each {|n_to| n_to.dist_direct = 0.0}
    vn_from.each {|n_from| n_from.dist_direct = nto.distance_direct(n_from)}
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
          return nfrom, nto, [blk], length
        end
      end
    end
    tos = []
    vn_to.each {|n_to| tos += (n_to.gblock_nodes.collect {|bn| bn.block.end_block_node})}
    tos.uniq!

    previous = {}
    visited = {} ; in_queue = {}
    pq = PQueue.new(proc {|x,y|
        x_dist = x.dist_block + x.node.dist_direct ; y_dist = y.dist_block + y.node.dist_direct
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

    end_block_node = nil
    vn_from.each {|n_from|
      visited[n_from] = true
      n_from.dist_block = 0
      n_from.nb_node = 0
    }
    for blk in from_blocks
      node = blk.end_block_node
      node.dist_block = blk.dist_from_node_to_end(nfrom)
      node.node.dist_direct = vn_to.first.distance_direct(node.node)
      node.nb_node = 1
      #inner_node = blk.gblock_nodes.find :first, :conditions => "node in (#{(vn_from.collect {|nf| nf[:id]}).join(',')})"
      inner_node = blk.gblock_nodes.detect {|n| vn_from.member?(n)}
      previous[node] = inner_node unless inner_node == node
      node.node.dist_direct = nto.distance_direct(node.node)
      pq.push(node)
      in_queue[node] = true
    end
    to_block_node = nil
    nb_visited = 0
    good_length = 0
    catch(:done) do
      while pq.size != 0
        v = pq.pop
        visited[v] = true
        nb_visited += 1
        blocks = v.forward_blocks
        blocks.each do |blk|
          d = blk.length
          end_node = blk.end_block_node
          if !visited[end_node] and blk.dist_block > v.dist_block + d
            end_node.dist_block = v.dist_block + d
            end_node.nb_node = v.nb_node + blk.nb_node
            if nb_visited.modulo(2000) == 0
              puts nb_visited.to_s + ' block ' + end_node.dist_block.to_s + ' direct ' +  end_node.node.dist_direct.to_s
            end
            previous[end_node] = v
            if tos.member?(end_node) && (to_block_node = tos.detect {|bn| bn.block == blk})
              end_block_node = end_node
              if to_block_node
                to_block_node.node.dist_block = 0
                previous[to_block_node] = previous[end_block_node]
                good_length = v.dist_block + to_block_node.block.dist_start_to_node(nto)
                throw :done
              end
            elsif nb_visited > limit
              throw :done
            else
              unless (visited[end_node] or in_queue[end_node])
                end_node.node.dist_direct = nto.distance_direct(end_node.node)
                pq.push(end_node)
                in_queue[end_node] = true
              end
            end
          end
        end
      end
    end
    arr = []
    if previous[to_block_node]
      curr = to_block_node
      while curr
        arr << curr.block if curr.class.name == 'GblockNode'
        curr = previous[curr]
      end
    end
    return previous[to_block_node], to_block_node ? to_block_node.node : nil, arr.reverse, good_length
  end

  def Galgorithm.djikstra(from_stt, to_stt, from_st, to_st, limit = 3000000)
    return nil, nil, [], [], 0 if @@loading
    Galgorithm.load_in_cache unless @@loaded
    Galgorithm.reset_cache
    vn_from = from_st.stationtracks.collect {|tr| (ta = tr.track) && (tn = ta.tracknode) ? tn.gnode : nil} if from_st
    vn_from = [from_stt.gnode] if from_stt
    vn_to = to_st.stationtracks.collect {|tr| (ta = tr.track) && (tn = ta.tracknode) ? tn.gnode : nil} if to_st
    vn_to = [to_stt.gnode] if to_stt
    vn_from.compact!
    vn_to.compact!
    nfrom = vn_from.first
    nto = vn_to.first
    return nil, nil, [], [], 0 unless nto
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

    previous = {}
    visited = {} ; in_queue = {}
    pq = PQueue.new(proc {|x,y|
        x_dist = x.node.dist_direct 
        y_dist = y.node.dist_direct
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

    # pour un gnode, dist_direct va servir à stocker la distance la plus courte depuis l'origine
    vn_from.each {|n_from|
      visited[n_from] = true
      n_from.dist_block = 0
      n_from.nb_node = 0
      n_from.dist_direct = 0
    }
    
    for blk in from_blocks
      detected = false
      pbnode = nil
      for fbnode in blk.gblock_nodes
        if detected
          d = fbnode.node.fast_dist(pbnode.node)
          fbnode.node.dist_direct = pbnode.node.dist_direct + d
          fbnode.nb_node = pbnode.nb_node + 1
          previous[fbnode] = pbnode
          pq.push(fbnode)
          in_queue[fbnode] = true
          pbnode = fbnode
        end
        if fbnode.node == nfrom
          detected = true 
          pbnode = fbnode
          pbnode.nb_node = 0
          pbnode.node.dist_direct = 0
        end
      end  
      #      bnode = blk.end_block_node
      #      bnode.dist_block = blk.dist_from_node_to_end(nfrom)
      #      bnode.node.dist_direct = bnode.dist_block
      #      bnode.nb_node = 1
      #      #inner_node = blk.gblock_nodes.find :first, :conditions => "node in (#{(vn_from.collect {|nf| nf[:id]}).join(',')})"
      #      inner_bnode = blk.gblock_nodes.detect {|n| vn_from.member?(n)}
      #      previous[bnode] = inner_bnode unless inner_bnode == bnode
      #      pq.push(bnode)
      #      in_queue[bnode] = true
    end

    to_block_node = nil
    nb_visited = 0
    good_length = 0
    catch(:done) do
      while pq.size != 0
        v = pq.pop
        visited[v] = true
        nb_visited += 1
        blocks = v.forward_blocks
        blocks.each do |blk|
          tst = v
          pbnode = v
          fbnd = blk.gblock_nodes.first
          puts 'previous' if previous[fbnd].nil?
          puts 'equal' if fbnd == v
          puts 'cut' if v.nil?
          previous[fbnd] = v unless (previous[fbnd] or fbnd == v)
          for fbnode in blk.gblock_nodes
            d = fbnode.node.fast_dist(pbnode.node)
            if !visited[fbnode] and (fbnode.node.dist_direct.nil? or fbnode.node.dist_direct >= pbnode.node.dist_direct + d)
              fbnode.node.dist_direct = pbnode.node.dist_direct + d
              fbnode.nb_node = pbnode.nb_node + 1
              if nb_visited.modulo(1000) == 0
                puts nb_visited.to_s + ' dist_direct ' + fbnode.node.dist_direct.to_s
              end
              debugger if pbnode == fbnode
              previous[fbnode] = pbnode unless pbnode == fbnode
              if tos.member?(fbnode) #&& (to_block_node = tos.detect {|bn| bn.block == blk})
                good_length = fbnode.node.dist_direct
                to_block_node = fbnode
                throw :done
              elsif nb_visited > limit
                throw :done
              else
                unless (visited[fbnode] or in_queue[fbnode])
                  pq.push(fbnode)
                  in_queue[fbnode] = true
                end
              end
            end
            #previous[fbnode] = pbnode unless (previous[fbnode] or pbnode == fbnode)
            pbnode = fbnode
            #debugger unless previous[pbnode]
          end
        end
      end
    end
    arr = []
    nodes = []
    if previous[to_block_node]
      curr = to_block_node
      while curr
        unless arr.member?(curr.block)
          arr << curr.block
        end
        nodes << curr.node
        curr = previous[curr]
      end
    end
    return previous[to_block_node], (to_block_node ? to_block_node.node : nil), arr.reverse, nodes.reverse, good_length
  end

end


=begin

 from_stt = nil
 to_stt = nil
 from_st = Kbase::Station.where("stationabbrev like '444877/BV%' ").first
 to_st = Kbase::Station.where("stationabbrev like '447144/00%' ").first
 previous, tonode, blocks, nodes, length = Galgorithm.djikstra(from_stt, to_stt, from_st, to_st, limit = 3000000)

 nodes.collect {|nd| nd.stationname}

=end
  
