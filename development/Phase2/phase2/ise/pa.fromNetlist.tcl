
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name phase2 -dir "D:/Dropbox/vWorker/coding/ise/phase2/planAhead_run_1" -part xc6slx45csg324-3
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "D:/Dropbox/vWorker/coding/ise/phase2/hdmi2usb.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {D:/Dropbox/vWorker/coding/ise/phase2} {../../../phase2/ipcore_dir} }
add_files [list {../../../phase2/ipcore_dir/bytefifo.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {../../../phase2/ipcore_dir/rgbfifo.ncf}] -fileset [get_property constrset [current_run]]
set_property target_constrs_file "D:/Dropbox/vWorker/phase2/hdmi2usb.ucf" [current_fileset -constrset]
add_files [list {D:/Dropbox/vWorker/phase2/hdmi2usb.ucf}] -fileset [get_property constrset [current_run]]
link_design
