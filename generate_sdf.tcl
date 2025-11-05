# ====================================================================
# OpenSTA TCL Script to generate counter_timing.sdf
# ====================================================================

# 1. Read the liberty file (characterization)
read_liberty /workspace/NanGate_15nm_OCL_v0.1_2014_06.A/front_end/timing_power_noise/NLDM/NanGate_15nm_OCL_typical_conditional_nldm.lib

# 2. Read synthesized gate-level netlist
read_verilog /workspace/sim_output/counter_netlist.v

# 3. Set top design
link_design counter

# 4. Define clock
create_clock -period 50 clk

# 5. Update timing (for OpenSTA 2.0.x)
update_timing_graph

# 6. Write the SDF file
write_sdf /workspace/sim_output/counter_timing.sdf

# 7. Reports
report_checks -path_delay min_max -fields {slew cap input_pins nets fanout} -digits 4
report_tns
report_wns

exit
