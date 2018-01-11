ActiveAdmin.register Kbase::StationTrack do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  # or
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
  index do
    column("Stt", :sortable => :id) {|stt| link_to "##{stt.id} ", admin_stationtrack_path(stt) }
    column(:stationid) {|sth| link_to "##{sth.id} ", admin_station_path(sth) }
    column :abbreviation
    column :nameforpublishing
    actions
  end

  show title: :id do
    attributes_table do
      row :stationid
      row :abbreviation
      row :nameforpublishing
      row :gx
      row :gy
    end
  end
  
end
