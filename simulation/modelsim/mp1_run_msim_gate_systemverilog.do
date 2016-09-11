transcript on
if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vlog -sv -work work +incdir+. {mp1_2_1100mv_85c_slow.svo}

vlog -sv -work work +incdir+/home/cmndrsn2/ece411/mp1 {/home/cmndrsn2/ece411/mp1/mp1_tb.sv}
vlog -sv -work work +incdir+/home/cmndrsn2/ece411/mp1 {/home/cmndrsn2/ece411/mp1/memory.sv}

vsim -t 1ps +transport_int_delays +transport_path_delays -L altera_ver -L stratixiii_ver -L gate_work -L work -voptargs="+acc"  mp1_tb

add wave *
view structure
view signals
run 200 ns
