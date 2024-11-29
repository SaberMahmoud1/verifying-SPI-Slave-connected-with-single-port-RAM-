vlib work
vlog -sv +define+SIM_PARAM pack.sv Dp_Sync_RAM.sv RAM_golden_model.sv tb.sv +cover
vsim -voptargs=+acc work.tb -cover
add wave *
coverage save tb.ucdb  -onexit -du Dp_Sync_RAM
run -all
quit -sim
vcover report tb.ucdb -details -annotate -all -output coverage_rpt.txt