vlib work
vlog -sv +define+SIM_PARAM pack1.sv pack2.sv pack3.sv shared_pack.sv FIFO.sv interface.sv monitor.sv tb.sv top.sv +cover
vsim -voptargs=+acc work.top -cover
add wave *
coverage save FIFO_TB.ucdb  -onexit -du FIFO
run -all
quit -sim
vcover report FIFO_TB.ucdb -details -annotate -all -output coverage_rpt.txt
