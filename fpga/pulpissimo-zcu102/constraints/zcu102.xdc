#######################################
#  _______ _           _              #
# |__   __(_)         (_)             #
#    | |   _ _ __ ___  _ _ __   __ _  #
#    | |  | | '_ ` _ \| | '_ \ / _` | #
#    | |  | | | | | | | | | | | (_| | #
#    |_|  |_|_| |_| |_|_|_| |_|\__, | #
#                               __/ | #
#                              |___/  #
#######################################


#Create constraint for the clock input of the zcu102 board
create_clock -period 8.000 -name ref_clk [get_ports ref_clk_p]
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets ref_clk]

#I2S and CAM interface are not used in this FPGA port. Set constraints to
#disable the clock
set_case_analysis 0 i_pulpissimo/safe_domain_i/cam_pclk_o
set_case_analysis 0 i_pulpissimo/safe_domain_i/i2s_slave_sck_o
#set_input_jitter tck 1.000

## JTAG
create_clock -period 100.000 -name tck -waveform {0.000 50.000} [get_ports pad_jtag_tck]
set_input_jitter tck 1.000
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets pad_jtag_tck_IBUF_inst/O]


# minimize routing delay
set_input_delay -clock tck -clock_fall 5.000 [get_ports pad_jtag_tdi]
set_input_delay -clock tck -clock_fall 5.000 [get_ports pad_jtag_tms]
set_output_delay -clock tck 5.000 [get_ports pad_jtag_tdo]

set_max_delay -to [get_ports pad_jtag_tdo] 20.000
set_max_delay -from [get_ports pad_jtag_tms] 20.000
set_max_delay -from [get_ports pad_jtag_tdi] 20.000

set_max_delay -datapath_only -from [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_dmi_jtag/i_dmi_cdc/i_cdc_resp/i_src/data_src_q_reg*/C] -to [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_dmi_jtag/i_dmi_cdc/i_cdc_resp/i_dst/data_dst_q_reg*/D] 20.000
set_max_delay -datapath_only -from [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_dmi_jtag/i_dmi_cdc/i_cdc_resp/i_src/req_src_q_reg/C] -to [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_dmi_jtag/i_dmi_cdc/i_cdc_resp/i_dst/req_dst_q_reg/D] 20.000
set_max_delay -datapath_only -from [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_dmi_jtag/i_dmi_cdc/i_cdc_req/i_dst/ack_dst_q_reg/C] -to [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_dmi_jtag/i_dmi_cdc/i_cdc_req/i_src/ack_src_q_reg/D] 20.000


# reset signal
set_false_path -from [get_ports pad_reset]

# Set ASYNC_REG attribute for ff synchronizers to place them closer together and
# increase MTBF
set_property ASYNC_REG true [get_cells i_pulpissimo/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_apb_adv_timer/u_tim0/u_in_stage/r_ls_clk_sync_reg*]
set_property ASYNC_REG true [get_cells i_pulpissimo/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_apb_adv_timer/u_tim1/u_in_stage/r_ls_clk_sync_reg*]
set_property ASYNC_REG true [get_cells i_pulpissimo/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_apb_adv_timer/u_tim2/u_in_stage/r_ls_clk_sync_reg*]
set_property ASYNC_REG true [get_cells i_pulpissimo/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_apb_adv_timer/u_tim3/u_in_stage/r_ls_clk_sync_reg*]
set_property ASYNC_REG true [get_cells i_pulpissimo/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_apb_timer_unit/s_ref_clk*]
set_property ASYNC_REG true [get_cells i_pulpissimo/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_ref_clk_sync/i_pulp_sync/r_reg_reg*]
set_property ASYNC_REG true [get_cells i_pulpissimo/soc_domain_i/pulp_soc_i/soc_peripherals_i/u_evnt_gen/r_ls_sync_reg*]

# Create asynchronous clock group between slow-clk and SoC clock. Those clocks
# are considered asynchronously and proper synchronization regs are in place
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins i_pulpissimo/safe_domain_i/i_slow_clk_gen/slow_clk_o]] -group [get_clocks -of_objects [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_clk_rst_gen/i_fpga_clk_gen/soc_clk_o]]

# Create asynchronous clock group between Per Clock  and SoC clock. Those clocks
# are considered asynchronously and proper synchronization regs are in place
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_clk_rst_gen/clk_per_o]] -group [get_clocks -of_objects [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_clk_rst_gen/clk_soc_o]]

# Create asynchronous clock group between JTAG TCK and SoC clock.
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins i_pulpissimo/pad_jtag_tck]] -group [get_clocks -of_objects [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_clk_rst_gen/clk_soc_o]]
# // Shivam
# Sync Monitor clock and SoC clock
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_clk_rst_gen/clk_monitor_o]] -group [get_clocks -of_objects [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_clk_rst_gen/clk_soc_o]]
#############################################################
#  _____ ____         _____      _   _   _                  #
# |_   _/ __ \       / ____|    | | | | (_)                 #
#   | || |  | |_____| (___   ___| |_| |_ _ _ __   __ _ ___  #
#   | || |  | |______\___ \ / _ \ __| __| | '_ \ / _` / __| #
#  _| || |__| |      ____) |  __/ |_| |_| | | | | (_| \__ \ #
# |_____\____/      |_____/ \___|\__|\__|_|_| |_|\__, |___/ #
#                                                 __/ |     #
#                                                |___/      #
#############################################################

## Sys clock
set_property -dict {PACKAGE_PIN F21 IOSTANDARD LVDS_25} [get_ports ref_clk_n]
set_property -dict {PACKAGE_PIN G21 IOSTANDARD LVDS_25} [get_ports ref_clk_p]

## Reset
set_property -dict {PACKAGE_PIN AM13 IOSTANDARD LVCMOS33} [get_ports pad_reset]

## Buttons
set_property -dict {PACKAGE_PIN AF15 IOSTANDARD LVCMOS33} [get_ports btn0_i]
set_property -dict {PACKAGE_PIN AG13 IOSTANDARD LVCMOS33} [get_ports btn1_i]
set_property -dict {PACKAGE_PIN AE14 IOSTANDARD LVCMOS33} [get_ports btn2_i]
set_property -dict {PACKAGE_PIN AG15 IOSTANDARD LVCMOS33} [get_ports btn3_i]

## PMOD 0
set_property -dict {PACKAGE_PIN A20 IOSTANDARD LVCMOS33} [get_ports pad_jtag_tms]
set_property -dict {PACKAGE_PIN B20 IOSTANDARD LVCMOS33} [get_ports pad_jtag_tdi]
set_property -dict {PACKAGE_PIN A22 IOSTANDARD LVCMOS33} [get_ports pad_jtag_tdo]
set_property -dict {PACKAGE_PIN A21 IOSTANDARD LVCMOS33} [get_ports pad_jtag_tck]
set_property -dict {PACKAGE_PIN B21 IOSTANDARD LVCMOS33} [get_ports pad_pmod0_4]
set_property -dict {PACKAGE_PIN C21 IOSTANDARD LVCMOS33} [get_ports pad_pmod0_5]
set_property -dict {PACKAGE_PIN C22 IOSTANDARD LVCMOS33} [get_ports pad_pmod0_6]
set_property -dict {PACKAGE_PIN D21 IOSTANDARD LVCMOS33} [get_ports pad_pmod0_7]

## PMOD 1
set_property -dict {PACKAGE_PIN D20 IOSTANDARD LVCMOS33} [get_ports pad_pmod1_0]
set_property -dict {PACKAGE_PIN E20 IOSTANDARD LVCMOS33} [get_ports pad_pmod1_1]
set_property -dict {PACKAGE_PIN D22 IOSTANDARD LVCMOS33} [get_ports pad_pmod1_2]
set_property -dict {PACKAGE_PIN E22 IOSTANDARD LVCMOS33} [get_ports pad_pmod1_3]
set_property -dict {PACKAGE_PIN F20 IOSTANDARD LVCMOS33} [get_ports pad_pmod1_4]
set_property -dict {PACKAGE_PIN G20 IOSTANDARD LVCMOS33} [get_ports pad_pmod1_5]
set_property -dict {PACKAGE_PIN J20 IOSTANDARD LVCMOS33} [get_ports pad_pmod1_6]
set_property -dict {PACKAGE_PIN J19 IOSTANDARD LVCMOS33} [get_ports pad_pmod1_7]

## UART
set_property -dict {PACKAGE_PIN E13 IOSTANDARD LVCMOS33} [get_ports pad_uart_rx]
set_property -dict {PACKAGE_PIN F13 IOSTANDARD LVCMOS33} [get_ports pad_uart_tx]
set_property -dict {PACKAGE_PIN D12 IOSTANDARD LVCMOS33} [get_ports pad_uart_rts]
set_property -dict {PACKAGE_PIN E12 IOSTANDARD LVCMOS33} [get_ports pad_uart_cts]

## LEDs
set_property -dict {PACKAGE_PIN AG14 IOSTANDARD LVCMOS33} [get_ports led0_o]
set_property -dict {PACKAGE_PIN AF13 IOSTANDARD LVCMOS33} [get_ports led1_o]
set_property -dict {PACKAGE_PIN AE13 IOSTANDARD LVCMOS33} [get_ports led2_o]
set_property -dict {PACKAGE_PIN AJ14 IOSTANDARD LVCMOS33} [get_ports led3_o]
set_property -dict {PACKAGE_PIN AH13 IOSTANDARD LVCMOS33} [get_ports monitor_new_pc_o]
set_property -dict {PACKAGE_PIN AH14 IOSTANDARD LVCMOS33} [get_ports hash_match_o]
set_property -dict {PACKAGE_PIN AL12 IOSTANDARD LVCMOS33} [get_ports monitor_alert_int_o]

## Switches
set_property -dict {PACKAGE_PIN AN14 IOSTANDARD LVCMOS33} [get_ports switch0_i]
set_property -dict {PACKAGE_PIN AP14 IOSTANDARD LVCMOS33} [get_ports switch1_i]
set_property -dict {PACKAGE_PIN AM14 IOSTANDARD LVCMOS33} [get_ports switch2_i]
set_property -dict {PACKAGE_PIN AN13 IOSTANDARD LVCMOS33} [get_ports switch3_i]
set_property -dict {PACKAGE_PIN AN12 IOSTANDARD LVCMOS33} [get_ports fix_that_bootsel]

## I2C Bus
set_property -dict {PACKAGE_PIN J10 IOSTANDARD LVCMOS33} [get_ports pad_i2c0_scl]
set_property -dict {PACKAGE_PIN J11 IOSTANDARD LVCMOS33} [get_ports pad_i2c0_sda]

## HDMI CTL
set_property -dict {PACKAGE_PIN F15 IOSTANDARD LVCMOS33} [get_ports pad_hdmi_scl]
set_property -dict {PACKAGE_PIN F16 IOSTANDARD LVCMOS33} [get_ports pad_hdmi_sda]

# create_debug_core u_ila_0 ila
# set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
# set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
# set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
# set_property C_DATA_DEPTH 4096 [get_debug_cores u_ila_0]
# set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
# set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
# set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
# set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
# set_property port_width 1 [get_debug_ports u_ila_0/clk]
# connect_debug_port u_ila_0/clk [get_nets [list i_pulpissimo/soc_domain_i/pulp_soc_i/i_clk_rst_gen/i_fpga_clk_gen/i_clk_manager/inst/clk_out3]]
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
# set_property port_width 16 [get_debug_ports u_ila_0/probe0]
# connect_debug_port u_ila_0/probe0 [get_nets [list {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[0]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[1]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[2]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[3]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[4]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[5]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[6]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[7]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[8]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[9]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[10]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[11]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[12]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[13]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[14]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[15]}]]
# create_debug_port u_ila_0 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
# set_property port_width 4 [get_debug_ports u_ila_0/probe1]
# connect_debug_port u_ila_0/probe1 [get_nets [list {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/k[0]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/k[1]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/k[2]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/k[3]}]]
# create_debug_port u_ila_0 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
# set_property port_width 8 [get_debug_ports u_ila_0/probe2]
# connect_debug_port u_ila_0/probe2 [get_nets [list {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_addr[0]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_addr[1]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_addr[2]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_addr[3]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_addr[4]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_addr[5]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_addr[6]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_addr[7]}]]
# create_debug_port u_ila_0 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
# set_property port_width 37 [get_debug_ports u_ila_0/probe3]
# connect_debug_port u_ila_0/probe3 [get_nets [list {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[0]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[1]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[2]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[3]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[4]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[5]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[6]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[7]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[8]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[9]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[10]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[11]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[12]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[13]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[14]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[15]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[16]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[17]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[18]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[19]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[20]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[21]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[22]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[23]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[24]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[25]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[26]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[27]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[28]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[29]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[30]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[31]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[32]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[33]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[34]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[35]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[36]}]]
# create_debug_port u_ila_0 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
# set_property port_width 5 [get_debug_ports u_ila_0/probe4]
# connect_debug_port u_ila_0/probe4 [get_nets [list {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_addr[0]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_addr[1]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_addr[2]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_addr[3]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_addr[4]}]]
# create_debug_port u_ila_0 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
# set_property port_width 10 [get_debug_ports u_ila_0/probe5]
# connect_debug_port u_ila_0/probe5 [get_nets [list {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_out[0]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_out[1]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_out[2]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_out[3]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_out[4]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_out[5]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_out[6]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_out[7]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_out[8]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_out[9]}]]
# create_debug_port u_ila_0 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
# set_property port_width 8 [get_debug_ports u_ila_0/probe6]
# connect_debug_port u_ila_0/probe6 [get_nets [list {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/next_addr[0]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/next_addr[1]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/next_addr[2]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/next_addr[3]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/next_addr[4]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/next_addr[5]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/next_addr[6]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/next_addr[7]}]]
# create_debug_port u_ila_0 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
# set_property port_width 32 [get_debug_ports u_ila_0/probe7]
# connect_debug_port u_ila_0/probe7 [get_nets [list {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[0]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[1]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[2]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[3]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[4]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[5]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[6]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[7]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[8]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[9]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[10]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[11]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[12]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[13]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[14]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[15]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[16]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[17]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[18]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[19]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[20]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[21]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[22]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[23]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[24]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[25]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[26]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[27]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[28]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[29]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[30]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[31]}]]
# create_debug_port u_ila_0 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
# set_property port_width 1 [get_debug_ports u_ila_0/probe8]
# connect_debug_port u_ila_0/probe8 [get_nets [list i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_match]]
# create_debug_port u_ila_0 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
# set_property port_width 1 [get_debug_ports u_ila_0/probe9]
# connect_debug_port u_ila_0/probe9 [get_nets [list i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_alert_int]]
# create_debug_port u_ila_0 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
# set_property port_width 1 [get_debug_ports u_ila_0/probe10]
# connect_debug_port u_ila_0/probe10 [get_nets [list i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_alert_int_o]]
# create_debug_port u_ila_0 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
# set_property port_width 1 [get_debug_ports u_ila_0/probe11]
# connect_debug_port u_ila_0/probe11 [get_nets [list i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start]]
# create_debug_core u_ila_1 ila
# set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_1]
# set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_1]
# set_property C_ADV_TRIGGER false [get_debug_cores u_ila_1]
# set_property C_DATA_DEPTH 4096 [get_debug_cores u_ila_1]
# set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_1]
# set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_1]
# set_property C_TRIGIN_EN false [get_debug_cores u_ila_1]
# set_property C_TRIGOUT_EN false [get_debug_cores u_ila_1]
# set_property port_width 1 [get_debug_ports u_ila_1/clk]
# connect_debug_port u_ila_1/clk [get_nets [list i_pulpissimo/soc_domain_i/pulp_soc_i/i_clk_rst_gen/i_fpga_clk_gen/i_clk_manager/inst/clk_out1]]
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe0]
# set_property port_width 4 [get_debug_ports u_ila_1/probe0]
# connect_debug_port u_ila_1/probe0 [get_nets [list {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/i_monitor_logic/hash_value[0]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/i_monitor_logic/hash_value[1]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/i_monitor_logic/hash_value[2]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/i_monitor_logic/hash_value[3]}]]
# create_debug_port u_ila_1 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe1]
# set_property port_width 32 [get_debug_ports u_ila_1/probe1]
# connect_debug_port u_ila_1/probe1 [get_nets [list {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[0]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[1]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[2]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[3]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[4]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[5]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[6]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[7]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[8]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[9]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[10]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[11]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[12]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[13]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[14]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[15]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[16]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[17]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[18]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[19]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[20]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[21]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[22]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[23]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[24]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[25]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[26]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[27]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[28]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[29]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[30]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_instr_rdata[31]}]]
# create_debug_port u_ila_1 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe2]
# set_property port_width 32 [get_debug_ports u_ila_1/probe2]
# connect_debug_port u_ila_1/probe2 [get_nets [list {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[0]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[1]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[2]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[3]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[4]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[5]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[6]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[7]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[8]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[9]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[10]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[11]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[12]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[13]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[14]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[15]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[16]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[17]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[18]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[19]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[20]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[21]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[22]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[23]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[24]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[25]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[26]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[27]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[28]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[29]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[30]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[31]}]]
# create_debug_port u_ila_1 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe3]
# set_property port_width 1 [get_debug_ports u_ila_1/probe3]
# connect_debug_port u_ila_1/probe3 [get_nets [list i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_new_pc]]
# # create_debug_port u_ila_1 probe
# # set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe4]
# # set_property port_width 1 [get_debug_ports u_ila_1/probe4]
# # connect_debug_port u_ila_1/probe4 [get_nets [list i_pulpissimo/soc_domain_i/pulp_soc_i/s_monitor_clk]]
# # create_debug_port u_ila_1 probe
# # set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe5]
# # set_property port_width 1 [get_debug_ports u_ila_1/probe5]
# # connect_debug_port u_ila_1/probe5 [get_nets [list i_pulpissimo/soc_domain_i/pulp_soc_i/s_soc_clk]]
# set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
# set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
# set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
# connect_debug_port dbg_hub/clk [get_nets u_ila_1_clk_out1]
