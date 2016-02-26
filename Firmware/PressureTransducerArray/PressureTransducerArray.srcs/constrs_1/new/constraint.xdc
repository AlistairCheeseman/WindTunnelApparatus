# apparently need this:
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]






##Pmod Header JA
##Bank = 15, Pin name = IO_L1N_T0_AD0N_15,					Sch name = JA1
set_property PACKAGE_PIN B13 [get_ports {SCL1}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SCL1}]
##Bank = 15, Pin name = IO_L5N_T0_AD9N_15,					Sch name = JA2
set_property PACKAGE_PIN F14 [get_ports {SCL2}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SCL2}]
##Bank = 15, Pin name = IO_L16N_T2_A27_15,					Sch name = JA3
set_property PACKAGE_PIN D17 [get_ports {SCL3}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SCL3}]
##Bank = 15, Pin name = IO_L16P_T2_A28_15,					Sch name = JA4
set_property PACKAGE_PIN E17 [get_ports {SCL4}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SCL4}]
##Bank = 15, Pin name = IO_0_15,								Sch name = JA7
set_property PACKAGE_PIN G13 [get_ports {SDA1}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SDA1}]
##Bank = 15, Pin name = IO_L20N_T3_A19_15,					Sch name = JA8
set_property PACKAGE_PIN C17 [get_ports {SDA2}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SDA2}]
##Bank = 15, Pin name = IO_L21N_T3_A17_15,					Sch name = JA9
set_property PACKAGE_PIN D18 [get_ports {SDA3}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SDA3}]
##Bank = 15, Pin name = IO_L21P_T3_DQS_15,					Sch name = JA10
set_property PACKAGE_PIN E18 [get_ports {SDA4}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SDA4}]


##Pmod Header JB
##Bank = 15, Pin name = IO_L15N_T2_DQS_ADV_B_15,				Sch name = JB1
set_property PACKAGE_PIN G14 [get_ports {SCL5}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SCL5}]
##Bank = 14, Pin name = IO_L13P_T2_MRCC_14,					Sch name = JB2
set_property PACKAGE_PIN P15 [get_ports {SCL6}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SCL6}]
##Bank = 14, Pin name = IO_L21N_T3_DQS_A06_D22_14,			Sch name = JB3
set_property PACKAGE_PIN V11 [get_ports {SCL7}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SCL7}]
##Bank = CONFIG, Pin name = IO_L16P_T2_CSI_B_14,				Sch name = JB4
set_property PACKAGE_PIN V15 [get_ports {SCL8}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SCL8}]
##Bank = 15, Pin name = IO_25_15,							Sch name = JB7
set_property PACKAGE_PIN K16 [get_ports {SDA5}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SDA5}]
##Bank = CONFIG, Pin name = IO_L15P_T2_DQS_RWR_B_14,			Sch name = JB8
set_property PACKAGE_PIN R16 [get_ports {SDA6}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SDA6}]
##Bank = 14, Pin name = IO_L24P_T3_A01_D17_14,				Sch name = JB9
set_property PACKAGE_PIN T9 [get_ports {SDA7}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SDA7}]
##Bank = 14, Pin name = IO_L19N_T3_A09_D25_VREF_14,			Sch name = JB10 
set_property PACKAGE_PIN U11 [get_ports {SDA8}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SDA8}]


##Pmod Header JC
##Bank = 35, Pin name = IO_L23P_T3_35,						Sch name = JC1
set_property PACKAGE_PIN K2 [get_ports {SCL9}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SCL9}]
##Bank = 35, Pin name = IO_L6P_T0_35,						Sch name = JC2
set_property PACKAGE_PIN E7 [get_ports {SCL10}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SCL10}]
##Bank = 35, Pin name = IO_L22P_T3_35,						Sch name = JC3
#set_property PACKAGE_PIN J3 [get_ports {JC[2]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC[2]}]
##Bank = 35, Pin name = IO_L21P_T3_DQS_35,					Sch name = JC4
#set_property PACKAGE_PIN J4 [get_ports {JC[3]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC[3]}]
##Bank = 35, Pin name = IO_L23N_T3_35,						Sch name = JC7
set_property PACKAGE_PIN K1 [get_ports {SDA9}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SDA9}]
##Bank = 35, Pin name = IO_L5P_T0_AD13P_35,					Sch name = JC8
set_property PACKAGE_PIN E6 [get_ports {SDA10}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {SDA10}]
##Bank = 35, Pin name = IO_L22N_T3_35,						Sch name = JC9
#set_property PACKAGE_PIN J2 [get_ports {JC[6]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC[6]}]
##Bank = 35, Pin name = IO_L19P_T3_35,						Sch name = JC10
#set_property PACKAGE_PIN G6 [get_ports {JC[7]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC[7]}]
	
	## Clock signal
    ##Bank = 35, Pin name = IO_L12P_T1_MRCC_35,                    Sch name = CLK100MHZ
    set_property PACKAGE_PIN E3 [get_ports clk]                            
        set_property IOSTANDARD LVCMOS33 [get_ports clk]
        create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

##USB-RS232 Interface
##Bank = 35, Pin name = IO_L7P_T1_AD6P_35,					Sch name = UART_TXD_IN
#set_property PACKAGE_PIN C4 [get_ports RsRx]						
	#set_property IOSTANDARD LVCMOS33 [get_ports RsRx]
##Bank = 35, Pin name = IO_L11N_T1_SRCC_35,					Sch name = UART_RXD_OUT
set_property PACKAGE_PIN D4 [get_ports RsTx]						
	set_property IOSTANDARD LVCMOS33 [get_ports RsTx]
##Bank = 35, Pin name = IO_L12N_T1_MRCC_35,					Sch name = UART_CTS
#set_property PACKAGE_PIN D3 [get_ports RsCts]						
#	set_property IOSTANDARD LVCMOS33 [get_ports RsCts]
##Bank = 35, Pin name = IO_L5N_T0_AD13N_35,					Sch name = UART_RTS
#set_property PACKAGE_PIN E5 [get_ports RsRts]						
#	set_property IOSTANDARD LVCMOS33 [get_ports RsRts]
	
##Bank = 15, Pin name = IO_L3P_T0_DQS_AD1P_15,				Sch name = CPU_RESET
    set_property PACKAGE_PIN C12 [get_ports btnCpuReset]                
        set_property IOSTANDARD LVCMOS33 [get_ports btnCpuReset]