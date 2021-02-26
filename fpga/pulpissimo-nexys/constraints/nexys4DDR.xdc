#    _   _
#   | \ | |
#   |  \| | _____  ___   _ ___
#   | . ` |/ _ \ \/ / | | / __|
#   | |\  |  __/>  <| |_| \__ \
#   |_| \_|\___/_/\_\\__, |___/
#                     __/ |
#                    |___/


### Constraint File for the Nexys 4 DDR and Nexys A7-100T/A7-50T boards


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


#Create constraint for the clock input of the nexys board
create_clock -period 10.000 -name ref_clk [get_ports sys_clk]
#create_clock -period 50.000 -name sp_clk  [get_ports monitor_clk]

#I2S and CAM interface are not used in this FPGA port. Set constraints to
#disable the clock
set_case_analysis 0 i_pulpissimo/safe_domain_i/cam_pclk_o
set_case_analysis 0 i_pulpissimo/safe_domain_i/i2s_slave_sck_o
#set_input_jitter tck 1.000

## JTAG
create_clock -period 100.000 -name tck -waveform {0.000 50.000} [get_ports pad_jtag_tck]
set_input_jitter tck 1.000
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets tck_int]


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
set_false_path -from [get_ports pad_reset_n]

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
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins i_pulpissimo/safe_domain_i/i_slow_clk_gen/i_slow_clk_mngr/inst/mmcm_adv_inst/CLKOUT0]] -group [get_clocks -of_objects [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_clk_rst_gen/i_fpga_clk_gen/i_clk_manager/inst/mmcm_adv_inst/CLKOUT0]]

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
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports sys_clk]

## Buttons
set_property -dict {PACKAGE_PIN C12 IOSTANDARD LVCMOS33} [get_ports pad_reset_n]
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports btnc_i]
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports btnd_i]
set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports btnl_i]
set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS33} [get_ports btnr_i]
set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports btnu_i]

## PMOD A as JTAG
set_property -dict {PACKAGE_PIN C17 IOSTANDARD LVCMOS33} [get_ports pad_jtag_tms]
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports pad_jtag_tdi]
set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVCMOS33} [get_ports pad_jtag_tdo]
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports pad_jtag_tck]

##PMOD B for I2C and I2S
set_property -dict {PACKAGE_PIN D14 IOSTANDARD LVCMOS33} [get_ports pad_i2c0_sda]
set_property -dict {PACKAGE_PIN F16 IOSTANDARD LVCMOS33} [get_ports pad_i2c0_scl]

set_property -dict {PACKAGE_PIN E16 IOSTANDARD LVCMOS33} [get_ports pad_i2s0_sck]
set_property -dict {PACKAGE_PIN F13 IOSTANDARD LVCMOS33} [get_ports pad_i2s0_ws]
set_property -dict {PACKAGE_PIN G13 IOSTANDARD LVCMOS33} [get_ports pad_i2s0_sdi]
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports pad_i2s1_sdi]

## UART
set_property -dict {PACKAGE_PIN C4 IOSTANDARD LVCMOS33} [get_ports pad_uart_rx]
set_property -dict {PACKAGE_PIN D4 IOSTANDARD LVCMOS33} [get_ports pad_uart_tx]
#set_property -dict {PACKAGE_PIN D3 IOSTANDARD LVCMOS33} [get_ports pad_uart_cts]
#set_property -dict {PACKAGE_PIN E5 IOSTANDARD LVCMOS33} [get_ports pad_uart_rts]

## LEDs
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports led0_o]
set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS33} [get_ports led1_o]
set_property -dict {PACKAGE_PIN J13 IOSTANDARD LVCMOS33} [get_ports led2_o]
set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports led3_o]
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports monitor_new_pc_o]
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports hash_match_o]
set_property -dict {PACKAGE_PIN V11 IOSTANDARD LVCMOS33} [get_ports monitor_alert_int_o]


## Switches
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports switch0_i]
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports switch1_i]
set_property -dict {PACKAGE_PIN M13 IOSTANDARD LVCMOS33} [get_ports fix_that_bootsel]


## QSPI Flash
## disabled. Have a look at the Readme
#set_property -dict {PACKAGE_PIN L13 IOSTANDARD LVCMOS33} [get_ports pad_spim_csn0]
#set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports pad_spim_sdio0]
#set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports pad_spim_sdio1]
#set_property -dict {PACKAGE_PIN L14 IOSTANDARD LVCMOS33} [get_ports pad_spim_sdio2]
#set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports pad_spim_sdio3]
# not working for now

#Use PMOD C for SPIM0
set_property -dict {PACKAGE_PIN K1 IOSTANDARD LVCMOS33} [get_ports pad_spim_csn0]
set_property -dict {PACKAGE_PIN F6 IOSTANDARD LVCMOS33} [get_ports pad_spim_sdio0]
set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports pad_spim_sdio1]
set_property -dict {PACKAGE_PIN G6 IOSTANDARD LVCMOS33} [get_ports pad_spim_sdio2]
set_property -dict {PACKAGE_PIN E7 IOSTANDARD LVCMOS33} [get_ports pad_spim_sdio3]
set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS33} [get_ports pad_spim_sck]



## SD Card
set_property -dict {PACKAGE_PIN B1 IOSTANDARD LVCMOS33} [get_ports pad_sdio_clk]
#set_property -dict {PACKAGE_PIN A1 IOSTANDARD LVCMOS33} [get_ports { sd_cd }];
set_property -dict {PACKAGE_PIN C1 IOSTANDARD LVCMOS33} [get_ports pad_sdio_cmd]
set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports pad_sdio_data0]
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports pad_sdio_data1]
set_property -dict {PACKAGE_PIN F1 IOSTANDARD LVCMOS33} [get_ports pad_sdio_data2]
set_property -dict {PACKAGE_PIN D2 IOSTANDARD LVCMOS33} [get_ports pad_sdio_data3]
set_property -dict {PACKAGE_PIN E2 IOSTANDARD LVCMOS33} [get_ports sdio_reset_o]

# Nexys 4 has a quad SPI flash
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

# Configuration options, can be used for all designs
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]


set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[15]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[3]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[1]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[5]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[8]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[9]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[11]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[13]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[17]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[19]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[21]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[23]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[25]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[27]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[29]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[31]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[1]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[3]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[5]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[9]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[8]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[11]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[13]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[15]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[17]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[19]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[21]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[23]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[25]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[27]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[29]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[31]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[16]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[7]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[0]}]
set_property MARK_DEBUG true [get_nets i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/first_instruction]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[2]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[4]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[6]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[10]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[12]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[14]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[18]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[20]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[22]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[24]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[26]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[28]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[30]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[0]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[2]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[4]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[6]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[7]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[10]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[12]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[14]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[16]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[18]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[20]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[22]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[24]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[26]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[28]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[30]}]

set_property MARK_DEBUG true [get_nets i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_new_pc]
set_property MARK_DEBUG true [get_nets i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_alert_int]

set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[3]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[1]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[0]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[16]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[22]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[2]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[28]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[4]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[24]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[5]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[12]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[15]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[19]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[29]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[18]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[14]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[20]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[21]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[23]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[27]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[6]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[7]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[25]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[30]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[8]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[11]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[13]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[31]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[9]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[10]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[17]}]
set_property MARK_DEBUG true [get_nets {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[26]}]

connect_debug_port u_ila_0/clk [get_nets [list u_ila_0_clk_out3]]



create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list u_ila_0_clk_out3]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 4 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/k[0]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/k[1]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/k[2]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/k[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 5 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_addr[0]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_addr[1]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_addr[2]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_addr[3]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_addr[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 8 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_addr[0]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_addr[1]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_addr[2]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_addr[3]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_addr[4]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_addr[5]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_addr[6]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_addr[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 32 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[0]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[1]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[2]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[3]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[4]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[5]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[6]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[7]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[8]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[9]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[10]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[11]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[12]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[13]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[14]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[15]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[16]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[17]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[18]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[19]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[20]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[21]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[22]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[23]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[24]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[25]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[26]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[27]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[28]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[29]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[30]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_pc_id_i[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 10 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_out[0]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_out[1]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_out[2]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_out[3]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_out[4]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_out[5]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_out[6]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_out[7]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_out[8]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_grp_out[9]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 32 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[0]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[1]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[2]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[3]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[4]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[5]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[6]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[7]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[8]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[9]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[10]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[11]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[12]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[13]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[14]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[15]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[16]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[17]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[18]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[19]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[20]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[21]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[22]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[23]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[24]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[25]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[26]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[27]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[28]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[29]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[30]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start_pc_reg[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 32 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[0]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[1]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[2]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[3]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[4]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[5]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[6]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[7]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[8]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[9]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[10]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[11]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[12]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[13]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[14]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[15]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[16]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[17]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[18]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[19]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[20]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[21]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[22]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[23]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[24]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[25]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[26]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[27]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[28]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[29]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[30]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_instr_rdata_i[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 8 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/next_addr[0]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/next_addr[1]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/next_addr[2]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/next_addr[3]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/next_addr[4]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/next_addr[5]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/next_addr[6]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/next_addr[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 16 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[0]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[1]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[2]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[3]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[4]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[5]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[6]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[7]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[8]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[9]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[10]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[11]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[12]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[13]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[14]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_of_memory[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 37 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[0]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[1]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[2]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[3]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[4]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[5]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[6]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[7]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[8]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[9]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[10]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[11]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[12]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[13]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[14]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[15]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[16]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[17]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[18]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[19]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[20]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[21]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[22]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[23]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[24]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[25]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[26]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[27]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[28]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[29]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[30]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[31]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[32]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[33]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[34]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[35]} {i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/mem_ful_out[36]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/first_instruction]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/hash_match]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_alert_int]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 1 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/monitor_new_pc]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 1 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list i_pulpissimo/soc_domain_i/pulp_soc_i/i_monitor_top/start]]
create_debug_core u_ila_1 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_1]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_1]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_1]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_1]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_1]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_1]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_1]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_1]
set_property port_width 1 [get_debug_ports u_ila_1/clk]
connect_debug_port u_ila_1/clk [get_nets [list i_pulpissimo/soc_domain_i/pulp_soc_i/i_clk_rst_gen/i_fpga_clk_gen/i_clk_manager/inst/clk_out1]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe0]
set_property port_width 32 [get_debug_ports u_ila_1/probe0]
connect_debug_port u_ila_1/probe0 [get_nets [list {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[0]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[1]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[2]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[3]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[4]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[5]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[6]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[7]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[8]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[9]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[10]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[11]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[12]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[13]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[14]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[15]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[16]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[17]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[18]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[19]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[20]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[21]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[22]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[23]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[24]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[25]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[26]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[27]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[28]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[29]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[30]} {i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_pc_id[31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe1]
set_property port_width 1 [get_debug_ports u_ila_1/probe1]
connect_debug_port u_ila_1/probe1 [get_nets [list i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_alert_int_o]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe2]
set_property port_width 1 [get_debug_ports u_ila_1/probe2]
connect_debug_port u_ila_1/probe2 [get_nets [list i_pulpissimo/soc_domain_i/pulp_soc_i/monitor_new_pc]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe3]
set_property port_width 1 [get_debug_ports u_ila_1/probe3]
connect_debug_port u_ila_1/probe3 [get_nets [list i_pulpissimo/soc_domain_i/pulp_soc_i/s_monitor_clk]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets u_ila_1_clk_out1]
