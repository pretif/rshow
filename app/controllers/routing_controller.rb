class RoutingController < ApplicationController

  #641217_00  -576306_00  -576132_00
  def dev1
    @obj = TestObject.new
    @obj.date = Date.today
    @obj
  end
  
  def dev
    @obj = TestObject.new
    @obj.date = Date.today
    @obj
  end
 
  def possessions1t
    @obj = TestObject.new
    @obj.date = Date.today
    @obj
  end

  def possessions2g
    @obj = TestObject.new
    @obj.date = Date.today
    @obj
  end

  def route
  end
  
  def rails
    unless params[:id]
      render json: %{{"message":"Not Found"}} 
      return
    end
    start = Time.now
    # les legs
    wps = params[:id]
    vwps = wps.split('L').collect {|data| data.split(',')}
    sts = []
    for wp in vwps
      sts << Kbase::Station.find_by_lat_lon(wp[0],wp[1]).first
    end
    legs = [] ; waypoints = [] ; distance = 0
    st_from = sts.first
    first_wp = true
    for st in sts.slice(1,(sts.length - 1)) do
      st_to  = st
      if st_from && st_to
        previous, tonode, blocks, nodes, length = Galgorithm.djikstra(nil, nil,st_from, st_to)
        distance += length
      end
      if previous.nil?
        steps = []
        if first_wp
          waypoints << %{{"name": "CICH#{st_from.stationabbrev.rstrip}", "location": [#{st_from.xcoord}, #{st_from.ycoord}]}}
        end
        waypoints << %{{"name": "CICH#{st_to.stationabbrev.rstrip}", "location": [#{st_to.xcoord}, #{st_to.ycoord}]}}
        step_geometry = [[st_from.xcoord, st_from.ycoord], [st_to.xcoord, st_to.ycoord]]
        steps << %{{"geometry": {"type": "LineString", "coordinates": #{step_geometry} }, "maneuver": {"modifier": "straigth", "type": "depart", "bearing_after": 0, "duration": 0}, "distance": -1 }}
        step_geometry = [[st_to.xcoord, st_to.ycoord]]
        steps << %{{"geometry": {"type": "Point", "coordinates": #{step_geometry} }, "maneuver": {"modifier": "straigth", "type": "arrive", "bearing_after": 0, "duration": 0}, "distance": -1 }}
      else
        if first_wp
          waypoints << %{{"name": "CICH#{st_from.stationabbrev.rstrip}", "location": [#{nodes.first.xcoord}, #{nodes.first.ycoord}]}}
        end
        waypoints << %{{"name": "CICH#{st_to.stationabbrev.rstrip}", "location": [#{tonode.xcoord}, #{tonode.ycoord}]}}
        step_geometry = [[nodes.first.xcoord, nodes.first.ycoord], [nodes.first.xcoord + 10, nodes.first.ycoord]]
        start_step = %{{"geometry": {"type": "LineString", "coordinates": #{step_geometry} }, "maneuver": {"modifier": "straigth", "type": "depart", "bearing_after": 0, "duration": 0}, "distance": 0 }}
        steps = [start_step]
        i = 1
        dist = 0
        while i < nodes.length
          step_geometry = []
          while (i < nodes.length && nodes[i].node.stationname.nil?)
            step_geometry << [nodes[i].node.xcoord, nodes[i].node.ycoord]
            i += 1
          end
          if i < nodes.length
            name = nodes[i].node.stationname + ' ' + nodes[i].node.trackname 
            dist = nodes[i].distance
          end
          if step_geometry.length > 0
            steps << %{{"name": "#{name}", "geometry": {"type": "LineString", "coordinates": #{step_geometry} }, "maneuver": {"modifier": "straigth", "type": "merge", "bearing_after": 0, "duration": 0}, "distance": 100 }}
          end
          i += 1
        end
        step_geometry = [[nodes.last.node.xcoord, nodes.last.node.ycoord],[nodes.last.node.xcoord, nodes.last.node.ycoord + 10]]
        end_step = %{ {"geometry": {"type": "LineString", "coordinates": #{step_geometry} }, "maneuver": {"modifier": "straigth", "type": "arrive", "bearing_after": 0, "duration": 0}, "distance": 0 } }
        steps << end_step
      end
      steps_str = steps.join(',')
      leg = %{ {"summary": "#{st_from.stationabbrev.rstrip} a #{st_to.stationabbrev.rstrip}", "distance": #{length}, "duration": #{length}, "steps": [#{steps_str}]} }
      legs << leg
      first_wp = false
      st_from = st_to
    end
    legs_str = legs.join(',')
    waypoints_str = waypoints.join(',')
    duration = Time.now - start
    route_str = %{ {"legs":[#{legs_str}], "distance": #{distance}, "duration": #{duration} } }
    header_str = %{ {"routes": [#{route_str}], "waypoints": [#{waypoints_str}], "code": "Ok"} }
    puts 'Routing time ' + (Time.now - start).to_s
    render json: header_str, status: :ok, content_type: "application/javascript; charset=UTF-8"  
  end

  
  def rails_block
    unless params[:id]
      render json: %{{"message":"Not Found"}} 
      return
    end
    # Le cache
    start = Time.now
    Galgorithm.load_in_cache
    puts ' Loading in cache time ' + (Time.now - start).to_s
    start = Time.now
    # les legs
    wps = params[:id]
    vwps = wps.split('L').collect {|data| data.split(',')}
    sts = []
    for wp in vwps
      sts << Kbase::Station.find_by_lat_lon(wp[0],wp[1]).first
    end
    legs = [] ; waypoints = [] ; distance = 0
    st_from = sts.first
    first_wp = true
    for st in sts.slice(1,(sts.length - 1)) do
      st_to  = st
      if st_from && st_to
        previous, tonode, blocks, nodes, length = Galgorithm.djikstra(nil, nil,st_from, st_to)
        distance += length
      end
      if previous.nil?
        steps = []
        if first_wp
          waypoints << %{{"name": "CICH#{st_from.stationabbrev.rstrip}", "location": [#{st_from.xcoord}, #{st_from.ycoord}]}}
        end
        waypoints << %{{"name": "CICH#{st_to.stationabbrev.rstrip}", "location": [#{st_to.xcoord}, #{st_to.ycoord}]}}
        step_geometry = [[st_from.xcoord, st_from.ycoord], [st_to.xcoord, st_to.ycoord]]
        steps << %{{"geometry": {"type": "LineString", "coordinates": #{step_geometry} }, "maneuver": {"modifier": "straigth", "type": "depart", "bearing_after": 0, "duration": 0}, "distance": -1 }}
        step_geometry = [st_to.xcoord, st_to.ycoord]
        steps << %{{"geometry": {"type": "Point", "coordinates": #{step_geometry} }, "maneuver": {"modifier": "straigth", "type": "arrive", "bearing_after": 0, "duration": 0}, "distance": -1 }}
      else
        if first_wp
          waypoints << %{{"name": "CICH#{st_from.stationabbrev.rstrip}", "location": [#{blocks.first.start_block_node.xcoord}, #{blocks.first.start_block_node.ycoord}]}}
        end
        waypoints << %{{"name": "CICH#{st_to.stationabbrev.rstrip}", "location": [#{tonode.xcoord}, #{tonode.ycoord}]}}
        step_geometry = blocks.first.the_geom.points.collect {|pt| [pt.x, pt.y]}
        start_step = %{{"geometry": {"type": "LineString", "coordinates": #{step_geometry} }, "maneuver": {"modifier": "straigth", "type": "depart", "bearing_after": 0, "duration": 0}, "distance": #{blocks.first.length} }}
        steps = [start_step]
        for i in 1..(blocks.length-1)
          step_geometry = blocks[i].the_geom.points.collect {|pt| [pt.x, pt.y]}
          steps << %{{"geometry": {"type": "LineString", "coordinates": #{step_geometry} }, "maneuver": {"modifier": "straigth", "type": "turn", "bearing_after": 0, "duration": 0}, "distance": #{blocks[i].length} }}
        end
        step_geometry = blocks.last.the_geom.points.reverse.collect {|pt| [pt.x, pt.y]}
        end_step = %{ {"geometry": {"type": "LineString", "coordinates": #{step_geometry} }, "maneuver": {"modifier": "straigth", "type": "arrive", "bearing_after": 0, "duration": 0}, "distance": #{blocks.last.length} } }
        steps << end_step
      end
      steps_str = steps.join(',')
      leg = %{ {"summary": "#{st_from.stationabbrev.rstrip} a #{st_to.stationabbrev.rstrip}", "distance": #{length}, "duration": #{length}, "steps": [#{steps_str}]} }
      legs << leg
      first_wp = false
      st_from = st_to
    end
    legs_str = legs.join(',')
    waypoints_str = waypoints.join(',')
    duration = Time.now - start
    route_str = %{ {"legs":[#{legs_str}], "distance": #{distance}, "duration": #{duration} } }
    header_str = %{ {"routes": [#{route_str}], "waypoints": [#{waypoints_str}], "code": "Ok"} }

    render json: header_str, status: :ok, content_type: "application/javascript; charset=UTF-8"  
  end
  
  
  
  
  def rails_protected
    unless params[:id]
      render json: %{{"message":"Not Found"}} 
      return
    end
    # Le cache
    start = Time.now
    Galgorithm.load_in_cache
    puts ' Loading in cache time ' + (Time.now - start).to_s
    start = Time.now
    # les legs
    wps = params[:id]
    vwps = wps.split('-').collect {|data| data.sub!('_','/')}
    legs = [] ; waypoints = [] ; distance = 0
    st_from = Kbase::Station.where("stationabbrev like '#{vwps.first}%' ").first
    first_wp = true
    for wp in vwps.slice(1,(vwps.length - 1)) do
      st_to  = Kbase::Station.where("stationabbrev like '#{wp}%' ").first
      if st_from && st_to
        previous, tonode, blocks, length = Galgorithm.find_tps_path_a_star(nil, nil,st_from, st_to)
        distance += length
      end
      if previous.nil?
        steps = []
        if first_wp
          waypoints << %{{"name": "CICH#{st_from.stationabbrev.rstrip}", "location": [#{st_from.xcoord}, #{st_from.ycoord}]}}
        end
        waypoints << %{{"name": "CICH#{st_to.stationabbrev.rstrip}", "location": [#{st_to.xcoord}, #{st_to.ycoord}]}}
        step_geometry = [[st_from.xcoord, st_from.ycoord], [st_to.xcoord, st_to.ycoord]]
        steps << %{{"geometry": {"type": "LineString", "coordinates": #{step_geometry} }, "maneuver": {"modifier": "straigth", "type": "depart", "bearing_after": 0, "duration": 0}, "distance": -1 }}
        step_geometry = [st_to.xcoord, st_to.ycoord]
        steps << %{{"geometry": {"type": "Point", "coordinates": #{step_geometry} }, "maneuver": {"modifier": "straigth", "type": "arrive", "bearing_after": 0, "duration": 0}, "distance": -1 }}
      else
        if first_wp
          waypoints << %{{"name": "CICH#{st_from.stationabbrev.rstrip}", "location": [#{blocks.first.start_block_node.xcoord}, #{blocks.first.start_block_node.ycoord}]}}
        end
        waypoints << %{{"name": "CICH#{st_to.stationabbrev.rstrip}", "location": [#{tonode.xcoord}, #{tonode.ycoord}]}}
        step_geometry = blocks.first.the_geom.points.collect {|pt| [pt.x, pt.y]}
        start_step = %{{"geometry": {"type": "LineString", "coordinates": #{step_geometry} }, "maneuver": {"modifier": "straigth", "type": "depart", "bearing_after": 0, "duration": 0}, "distance": 1 }}
        steps = [start_step]
        for i in 1..(blocks.length-1)
          step_geometry = blocks[i].the_geom.points.collect {|pt| [pt.x, pt.y]}
          steps << %{{"geometry": {"type": "LineString", "coordinates": #{step_geometry} }, "maneuver": {"modifier": "straigth", "type": "turn", "bearing_after": 0, "duration": 0}, "distance": 2 }}
        end
        step_geometry = blocks.last.the_geom.points.collect {|pt| [pt.x, pt.y]}
        end_step = %{ {"geometry": {"type": "LineString", "coordinates": #{step_geometry} }, "maneuver": {"modifier": "straigth", "type": "arrive", "bearing_after": 0, "duration": 0}, "distance": 3 } }
        steps << end_step
      end
      steps_str = steps.join(',')
      leg = %{ {"summary": "#{st_from.stationabbrev.rstrip} a #{st_to.stationabbrev.rstrip}", "distance": #{length}, "duration": 100.0, "steps": [#{steps_str}]} }
      legs << leg
      first_wp = false
      st_from = st_to
    end
    legs_str = legs.join(',')
    waypoints_str = waypoints.join(',')
    duration = Time.now - start
    route_str = %{ {"legs":[#{legs_str}], "distance": #{distance}, "duration": #{duration} } }
    header_str = %{ {"routes": [#{route_str}], "waypoints": [#{waypoints_str}], "code": "Ok"} }

    render json: header_str, status: :ok, content_type: "application/javascript; charset=UTF-8"  
  end

  
=begin  
"distance": 90.0,
  "duration": 300.0,
  "geometry": {"type": "LineString", "coordinates": [[120.0, 10.0], [120.1, 10.0], [120.2, 10.0], [120.3, 10.0]]},

 from_st = Kbase::Station.where("stationabbrev like '447243/00%' ").first
 to_st = Kbase::Station.where("stationabbrev like '447185/00%' ").first



block = Kbase::Block.where(infraversionid: 281, id: 23257).first

http://localhost:3000/routing/rails/51796.671386835165,-54523.79877091665L50688.001937216846,-40959.99760505324?overview=false&alternatives=true&steps=true&hints=;


=end
  
  def find_tps_path
=begin
    start = Time.now
    Galgorithm.load_in_cache
    puts ' Loading in cache ' + (Time.now - start).to_s
    start = Time.now
    session[self.class.name + '_d']['st_from'] = params[:st_from][:st_id] if params[:st_from] && params[:st_from][:st_id] != ''
    session[self.class.name + '_d']['st_to'] = params[:st_to][:st_id] if params[:st_to] && params[:st_to][:st_id] != ''
    session[self.class.name + '_d']['from'] = params[:from][:stt_id] if params[:from] && params[:from][:stt_id] != ''
    session[self.class.name + '_d']['to'] = params[:to][:stt_id] if params[:to] && params[:to][:stt_id] != ''
    @st_from = Kbase::StationHeader.find params[:st_from][:st_id].to_i if params[:st_from] && params[:st_from][:st_id] != ''
    @st_to = Kbase::StationHeader.find params[:st_to][:st_id].to_i if params[:st_to] && params[:st_to][:st_id] != ''
    @stt_from = Kbase::StationTrack.find params[:from][:stt_id].to_i if params[:from] && params[:from][:stt_id] != ''
    @stt_to = Kbase::StationTrack.find params[:to][:stt_id].to_i if params[:to] && params[:to][:stt_id] != ''
    @st_from = @stt_from.header if @stt_from
    @st_to = @stt_to.header if @stt_to
    para1 = params['a']
    @velo = KveloProfileName.find(:first, :conditions => " shortdescription = '#{para1[:velo]}' ") if para1[:velo] != ''
    @elec = para1[:elecpro] if para1[:elecpro] != ''
    @pwr = para1[:pwr] if para1[:pwr] != ''
    if (@stt_from || @st_from) && (@stt_to || @st_to)
      @previous, @tonode, @blocks, @length = Galgorithm.find_tps_path_a_star(@stt_from, @stt_to,@st_from, @st_to)
      for blk in @blocks
        GisBlock.find_or_create(blk)
      end
    end
    @time = Time.now - start
    @data = "<wfs:GetFeature service='WFS' version='1.0.0' "
    @data += "  outputFormat='GML2' "
    @data += "  xmlns:topp='http://www.openplans.org/topp' "
    @data += "  xmlns:wfs='http://www.opengis.net/wfs' "
    @data += "  xmlns:ogc='http://www.opengis.net/ogc' "
    @data += "  xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' "
    @data += "  xsi:schemaLocation='http://www.opengis.net/wfs "
    @data += "                      http://schemas.opengis.net/wfs/1.0.0/WFS-basic.xsd'>"
    @data += "  <wfs:Query typeName='topp:blocks'> "
    @data += "<ogc:Filter> "
    #    blocks = GisBlock.find :all, :select => 'gid', :conditions => "tps_id in (#{@blocks.collect {|blk| "'" + blk.id.to_s.gsub(/2182/,'1622').ljust(12) + "'"}.join(',')})"
    blocks = GisBlock.find :all, :select => 'gid', :conditions => "tps_id in (#{@blocks.collect {|blk| "'2182," + blk.id.to_s.ljust(12) + "'"}.join(',')})"
    for block in blocks
      @data += "<ogc:FeatureId fid='blocks.#{block.gid}'/>"
    end
    @data += "</ogc:Filter> "
    @data += "</wfs:Query> "
    @data += "</wfs:GetFeature> "
    render :update do |page|
      page << "var tps_data = \"#{@data}\"; tpsQuery(tps_data);"
  end
=end
  end

end
