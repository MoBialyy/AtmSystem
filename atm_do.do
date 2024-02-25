vlib work
vlog atm.v atm_tb.v +cover 
vsim -voptargs=+acc work.atm_tb -cover 
add wave *
coverage save atm_tb_db.ucdb -onexit -du atm
run -all