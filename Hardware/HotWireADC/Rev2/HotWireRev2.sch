EESchema Schematic File Version 2
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:CustomParts
LIBS:HotWireRev2-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L ADS8331 U5
U 1 1 56E3F3AB
P 4240 2890
F 0 "U5" H 4240 2890 60  0000 C CNN
F 1 "ADS8331" H 4190 2790 60  0000 C CNN
F 2 "Housings_SSOP:TSSOP-24_4.4x7.8mm_Pitch0.65mm" H 4240 2890 60  0001 C CNN
F 3 "" H 4240 2890 60  0000 C CNN
	1    4240 2890
	1    0    0    -1  
$EndComp
$Comp
L JUMPER3 JP1
U 1 1 56E3F43B
P 5930 2290
F 0 "JP1" H 5980 2190 50  0000 L CNN
F 1 "JUMPER3" H 5930 2390 50  0000 C BNN
F 2 "Socket_Strips:Socket_Strip_Straight_1x03" H 5930 2290 50  0001 C CNN
F 3 "" H 5930 2290 50  0000 C CNN
	1    5930 2290
	1    0    0    -1  
$EndComp
Wire Wire Line
	5680 2290 5620 2290
Wire Wire Line
	5620 2290 5620 2640
Wire Wire Line
	5620 2640 5240 2640
Wire Wire Line
	5310 2440 5240 2440
Wire Wire Line
	5310 1680 5310 2440
Wire Wire Line
	6180 2290 6210 2290
Wire Wire Line
	6210 2290 6210 2000
Wire Wire Line
	6210 2000 5310 2000
Connection ~ 5310 2000
Wire Wire Line
	5240 2740 5990 2740
$Comp
L GNDA #PWR14
U 1 1 56E3F601
P 5490 2450
F 0 "#PWR14" H 5490 2200 50  0001 C CNN
F 1 "GNDA" H 5490 2300 50  0000 C CNN
F 2 "" H 5490 2450 50  0000 C CNN
F 3 "" H 5490 2450 50  0000 C CNN
	1    5490 2450
	1    0    0    -1  
$EndComp
$Comp
L MCP6001 U1
U 1 1 56E3FA17
P 1310 1040
F 0 "U1" H 1360 1240 50  0000 C CNN
F 1 "OPA320" H 1510 840 50  0000 C CNN
F 2 "TO_SOT_Packages_SMD:SOT-23-5" H 1260 1140 50  0001 C CNN
F 3 "" H 1360 1240 50  0000 C CNN
	1    1310 1040
	1    0    0    -1  
$EndComp
Wire Wire Line
	2270 1680 5310 1680
$Comp
L MCP6001 U2
U 1 1 56E3FBFC
P 1310 1820
F 0 "U2" H 1360 2020 50  0000 C CNN
F 1 "OPA320" H 1510 1620 50  0000 C CNN
F 2 "TO_SOT_Packages_SMD:SOT-23-5" H 1260 1920 50  0001 C CNN
F 3 "" H 1360 2020 50  0000 C CNN
	1    1310 1820
	1    0    0    -1  
$EndComp
$Comp
L MCP6001 U3
U 1 1 56E3FC6C
P 1310 2500
F 0 "U3" H 1360 2700 50  0000 C CNN
F 1 "OPA320" H 1510 2300 50  0000 C CNN
F 2 "TO_SOT_Packages_SMD:SOT-23-5" H 1260 2600 50  0001 C CNN
F 3 "" H 1360 2700 50  0000 C CNN
	1    1310 2500
	1    0    0    -1  
$EndComp
$Comp
L MCP6001 U4
U 1 1 56E3FC9B
P 1310 3230
F 0 "U4" H 1360 3430 50  0000 C CNN
F 1 "OPA320" H 1510 3030 50  0000 C CNN
F 2 "TO_SOT_Packages_SMD:SOT-23-5" H 1260 3330 50  0001 C CNN
F 3 "" H 1360 3430 50  0000 C CNN
	1    1310 3230
	1    0    0    -1  
$EndComp
Wire Wire Line
	3240 2740 3080 2740
Wire Wire Line
	3240 2840 3080 2840
Wire Wire Line
	3240 2940 3080 2940
Wire Wire Line
	3240 3040 3080 3040
NoConn ~ 3080 2740
NoConn ~ 3080 2840
NoConn ~ 3080 2940
NoConn ~ 3080 3040
Wire Wire Line
	5490 2450 5400 2450
Wire Wire Line
	5400 2450 5400 2540
Wire Wire Line
	5400 2540 5240 2540
Wire Wire Line
	1610 1040 1740 1040
$Comp
L R_Small R4
U 1 1 56E40C36
P 1840 1040
F 0 "R4" H 1870 1060 50  0000 L CNN
F 1 "40R" H 1870 1000 50  0000 L CNN
F 2 "Resistors_SMD:R_1206_HandSoldering" H 1840 1040 50  0001 C CNN
F 3 "" H 1840 1040 50  0000 C CNN
	1    1840 1040
	0    1    1    0   
$EndComp
$Comp
L C_Small C4
U 1 1 56E40CCE
P 2040 1180
F 0 "C4" H 2050 1250 50  0000 L CNN
F 1 "1.5n" H 2050 1100 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206_HandSoldering" H 2040 1180 50  0001 C CNN
F 3 "" H 2040 1180 50  0000 C CNN
	1    2040 1180
	1    0    0    -1  
$EndComp
Wire Wire Line
	1940 1040 2270 1040
Wire Wire Line
	2040 1040 2040 1080
$Comp
L GNDA #PWR8
U 1 1 56E40FF4
P 2040 1310
F 0 "#PWR8" H 2040 1060 50  0001 C CNN
F 1 "GNDA" H 2040 1160 50  0000 C CNN
F 2 "" H 2040 1310 50  0000 C CNN
F 3 "" H 2040 1310 50  0000 C CNN
	1    2040 1310
	1    0    0    -1  
$EndComp
Wire Wire Line
	2040 1280 2040 1310
Wire Wire Line
	2270 1040 2270 1680
Connection ~ 2040 1040
$Comp
L R_Small R3
U 1 1 56E4164C
P 1790 1820
F 0 "R3" H 1820 1840 50  0000 L CNN
F 1 "40R" H 1820 1780 50  0000 L CNN
F 2 "Resistors_SMD:R_1206_HandSoldering" H 1790 1820 50  0001 C CNN
F 3 "" H 1790 1820 50  0000 C CNN
	1    1790 1820
	0    1    1    0   
$EndComp
$Comp
L C_Small C3
U 1 1 56E417B9
P 1950 1960
F 0 "C3" H 1960 2030 50  0000 L CNN
F 1 "1.5n" H 1960 1880 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206_HandSoldering" H 1950 1960 50  0001 C CNN
F 3 "" H 1950 1960 50  0000 C CNN
	1    1950 1960
	1    0    0    -1  
$EndComp
$Comp
L R_Small R1
U 1 1 56E4189B
P 1770 2500
F 0 "R1" H 1800 2520 50  0000 L CNN
F 1 "40R" H 1800 2460 50  0000 L CNN
F 2 "Resistors_SMD:R_1206_HandSoldering" H 1770 2500 50  0001 C CNN
F 3 "" H 1770 2500 50  0000 C CNN
	1    1770 2500
	0    1    1    0   
$EndComp
$Comp
L C_Small C1
U 1 1 56E418F2
P 1930 2630
F 0 "C1" H 1940 2700 50  0000 L CNN
F 1 "1.5n" H 1940 2550 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206_HandSoldering" H 1930 2630 50  0001 C CNN
F 3 "" H 1930 2630 50  0000 C CNN
	1    1930 2630
	1    0    0    -1  
$EndComp
$Comp
L GNDA #PWR7
U 1 1 56E41956
P 1950 2140
F 0 "#PWR7" H 1950 1890 50  0001 C CNN
F 1 "GNDA" H 1950 1990 50  0000 C CNN
F 2 "" H 1950 2140 50  0000 C CNN
F 3 "" H 1950 2140 50  0000 C CNN
	1    1950 2140
	1    0    0    -1  
$EndComp
$Comp
L GNDA #PWR5
U 1 1 56E41985
P 1930 2790
F 0 "#PWR5" H 1930 2540 50  0001 C CNN
F 1 "GNDA" H 1930 2640 50  0000 C CNN
F 2 "" H 1930 2790 50  0000 C CNN
F 3 "" H 1930 2790 50  0000 C CNN
	1    1930 2790
	1    0    0    -1  
$EndComp
$Comp
L R_Small R2
U 1 1 56E41C00
P 1780 3230
F 0 "R2" H 1810 3250 50  0000 L CNN
F 1 "40R" H 1810 3190 50  0000 L CNN
F 2 "Resistors_SMD:R_1206_HandSoldering" H 1780 3230 50  0001 C CNN
F 3 "" H 1780 3230 50  0000 C CNN
	1    1780 3230
	0    1    1    0   
$EndComp
$Comp
L C_Small C2
U 1 1 56E41C5F
P 1940 3380
F 0 "C2" H 1950 3450 50  0000 L CNN
F 1 "1.5n" H 1950 3300 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206_HandSoldering" H 1940 3380 50  0001 C CNN
F 3 "" H 1940 3380 50  0000 C CNN
	1    1940 3380
	1    0    0    -1  
$EndComp
$Comp
L GNDA #PWR6
U 1 1 56E41CBD
P 1940 3540
F 0 "#PWR6" H 1940 3290 50  0001 C CNN
F 1 "GNDA" H 1940 3390 50  0000 C CNN
F 2 "" H 1940 3540 50  0000 C CNN
F 3 "" H 1940 3540 50  0000 C CNN
	1    1940 3540
	1    0    0    -1  
$EndComp
Wire Wire Line
	1610 2500 1670 2500
Wire Wire Line
	1610 3230 1680 3230
Wire Wire Line
	1890 1820 2350 1820
Wire Wire Line
	1950 1820 1950 1860
Wire Wire Line
	1870 2500 2310 2500
Wire Wire Line
	1930 2500 1930 2530
Wire Wire Line
	1880 3230 2300 3230
Wire Wire Line
	1940 3230 1940 3280
Wire Wire Line
	1940 3480 1940 3540
Wire Wire Line
	1930 2730 1930 2790
Wire Wire Line
	1950 2060 1950 2140
Wire Wire Line
	2350 2440 3240 2440
Wire Wire Line
	2350 1820 2350 2440
Connection ~ 1950 1820
Wire Wire Line
	3240 2540 2310 2540
Wire Wire Line
	2310 2540 2310 2500
Connection ~ 1930 2500
Wire Wire Line
	3240 2640 2300 2640
Wire Wire Line
	2300 2640 2300 3230
Connection ~ 1940 3230
Wire Wire Line
	650  1520 1210 1520
Wire Wire Line
	650  680  650  2930
Wire Wire Line
	650  740  1210 740 
Wire Wire Line
	650  2200 1210 2200
Connection ~ 650  1520
Wire Wire Line
	650  2930 1210 2930
Connection ~ 650  2200
Wire Wire Line
	1210 1340 730  1340
Wire Wire Line
	730  1340 730  3600
Wire Wire Line
	730  2120 1210 2120
Wire Wire Line
	730  2800 1210 2800
Connection ~ 730  2120
Wire Wire Line
	730  3530 1210 3530
Connection ~ 730  2800
$Comp
L GNDA #PWR2
U 1 1 56E467C4
P 730 3600
F 0 "#PWR2" H 730 3350 50  0001 C CNN
F 1 "GNDA" H 730 3450 50  0000 C CNN
F 2 "" H 730 3600 50  0000 C CNN
F 3 "" H 730 3600 50  0000 C CNN
	1    730  3600
	1    0    0    -1  
$EndComp
Connection ~ 730  3530
Text GLabel 1010 940  0    60   Input ~ 0
IN1
Text GLabel 1010 2400 0    60   Input ~ 0
IN3
Text GLabel 1010 3130 0    60   Input ~ 0
IN4
$Comp
L +5VA #PWR1
U 1 1 56E47E9A
P 650 680
F 0 "#PWR1" H 650 530 50  0001 C CNN
F 1 "+5VA" H 650 820 50  0000 C CNN
F 2 "" H 650 680 50  0000 C CNN
F 3 "" H 650 680 50  0000 C CNN
	1    650  680 
	1    0    0    -1  
$EndComp
Connection ~ 650  740 
$Comp
L GNDA #PWR17
U 1 1 56E4881E
P 5930 2840
F 0 "#PWR17" H 5930 2590 50  0001 C CNN
F 1 "GNDA" H 5930 2690 50  0000 C CNN
F 2 "" H 5930 2840 50  0000 C CNN
F 3 "" H 5930 2840 50  0000 C CNN
	1    5930 2840
	1    0    0    -1  
$EndComp
Wire Wire Line
	5240 2840 6030 2840
Wire Wire Line
	5240 2940 5340 2940
Wire Wire Line
	5340 2940 5340 2840
Connection ~ 5340 2840
Wire Wire Line
	3240 3540 3220 3540
Wire Wire Line
	3220 3540 3220 4090
Wire Wire Line
	3220 4090 5600 4090
Wire Wire Line
	3240 3440 3140 3440
Wire Wire Line
	3140 3440 3140 4180
Wire Wire Line
	3140 4180 5600 4180
Wire Wire Line
	3240 3340 3060 3340
Wire Wire Line
	3060 3340 3060 4270
Wire Wire Line
	3060 4270 5600 4270
Wire Wire Line
	2980 3240 3240 3240
Wire Wire Line
	2980 3240 2980 4360
Wire Wire Line
	2980 4360 5590 4360
$Comp
L R_Small R5
U 1 1 56E4954C
P 2680 3110
F 0 "R5" H 2710 3130 50  0000 L CNN
F 1 "10K" H 2710 3070 50  0000 L CNN
F 2 "Resistors_SMD:R_1206_HandSoldering" H 2680 3110 50  0001 C CNN
F 3 "" H 2680 3110 50  0000 C CNN
	1    2680 3110
	-1   0    0    1   
$EndComp
Wire Wire Line
	2680 2890 2680 3010
Wire Wire Line
	2800 3140 3240 3140
Wire Wire Line
	2900 4460 5590 4460
Wire Wire Line
	2900 3140 2900 4460
Connection ~ 2900 3140
Wire Wire Line
	2680 3210 2680 3270
Wire Wire Line
	2680 3270 2800 3270
Wire Wire Line
	2800 3270 2800 3140
Text Label 5590 4460 0    60   ~ 0
~RESET
$Comp
L GNDD #PWR19
U 1 1 56E4A9FC
P 6480 3670
F 0 "#PWR19" H 6480 3420 50  0001 C CNN
F 1 "GNDD" H 6480 3520 50  0000 C CNN
F 2 "" H 6480 3670 50  0000 C CNN
F 3 "" H 6480 3670 50  0000 C CNN
	1    6480 3670
	1    0    0    -1  
$EndComp
Text Label 5590 4360 0    60   ~ 0
EOC/~INT~/CDI
Text Label 5600 4270 0    60   ~ 0
SCLK
Text Label 5600 4180 0    60   ~ 0
FS/~CS
Text Label 5600 4090 0    60   ~ 0
SDI
Text Label 5600 4000 0    60   ~ 0
SDO
Wire Wire Line
	5240 3540 5240 4000
Wire Wire Line
	5240 4000 5600 4000
$Comp
L R_Small R7
U 1 1 56E4E8E6
P 5930 2600
F 0 "R7" H 5960 2620 50  0000 L CNN
F 1 "34.8" H 5960 2560 50  0000 L CNN
F 2 "Resistors_SMD:R_1206_HandSoldering" H 5930 2600 50  0001 C CNN
F 3 "" H 5930 2600 50  0000 C CNN
	1    5930 2600
	-1   0    0    1   
$EndComp
$Comp
L C_Small C5
U 1 1 56E4EA76
P 6150 2790
F 0 "C5" H 6160 2860 50  0000 L CNN
F 1 "750p" H 6160 2710 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206_HandSoldering" H 6150 2790 50  0001 C CNN
F 3 "" H 6150 2790 50  0000 C CNN
	1    6150 2790
	1    0    0    -1  
$EndComp
Wire Wire Line
	5930 2390 5930 2500
Wire Wire Line
	5930 2740 5930 2700
Wire Wire Line
	6150 2690 5990 2690
Wire Wire Line
	5990 2690 5990 2740
Connection ~ 5930 2740
Wire Wire Line
	6150 2890 6030 2890
Wire Wire Line
	6030 2890 6030 2840
Connection ~ 5930 2840
Text Label 5610 3880 0    60   ~ 0
~CONVST
$Comp
L R_Small R6
U 1 1 56E4FCF2
P 5370 3710
F 0 "R6" H 5400 3730 50  0000 L CNN
F 1 "10K" H 5400 3670 50  0000 L CNN
F 2 "Resistors_SMD:R_1206_HandSoldering" H 5370 3710 50  0001 C CNN
F 3 "" H 5370 3710 50  0000 C CNN
	1    5370 3710
	1    0    0    -1  
$EndComp
Wire Wire Line
	5240 3340 5310 3340
$Comp
L SW_PUSH_SMALL SW1
U 1 1 56E50C03
P 5590 4650
F 0 "SW1" H 5740 4760 50  0000 C CNN
F 1 "SW_PUSH_SMALL" H 5590 4571 50  0000 C CNN
F 2 "Buttons_Switches_SMD:SW_SPST_EVPBF" H 5590 4650 50  0000 C CNN
F 3 "" H 5590 4650 50  0000 C CNN
	1    5590 4650
	1    0    0    -1  
$EndComp
$Comp
L GNDD #PWR16
U 1 1 56E51293
P 5690 4820
F 0 "#PWR16" H 5690 4570 50  0001 C CNN
F 1 "GNDD" H 5690 4670 50  0000 C CNN
F 2 "" H 5690 4820 50  0000 C CNN
F 3 "" H 5690 4820 50  0000 C CNN
	1    5690 4820
	1    0    0    -1  
$EndComp
Wire Wire Line
	5690 4750 5690 4820
$Comp
L +3.3V #PWR20
U 1 1 56E51B59
P 6650 3250
F 0 "#PWR20" H 6650 3100 50  0001 C CNN
F 1 "+3.3V" H 6650 3390 50  0000 C CNN
F 2 "" H 6650 3250 50  0000 C CNN
F 3 "" H 6650 3250 50  0000 C CNN
	1    6650 3250
	1    0    0    -1  
$EndComp
$Comp
L +3.3V #PWR10
U 1 1 56E51F06
P 2680 2890
F 0 "#PWR10" H 2680 2740 50  0001 C CNN
F 1 "+3.3V" H 2680 3030 50  0000 C CNN
F 2 "" H 2680 2890 50  0000 C CNN
F 3 "" H 2680 2890 50  0000 C CNN
	1    2680 2890
	1    0    0    -1  
$EndComp
$Comp
L C_Small C8
U 1 1 56E52FA4
P 6650 3460
F 0 "C8" H 6660 3530 50  0000 L CNN
F 1 "0.1u" H 6660 3380 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206_HandSoldering" H 6650 3460 50  0001 C CNN
F 3 "" H 6650 3460 50  0000 C CNN
	1    6650 3460
	1    0    0    -1  
$EndComp
$Comp
L +5VA #PWR18
U 1 1 56E54038
P 6330 3250
F 0 "#PWR18" H 6330 3100 50  0001 C CNN
F 1 "+5VA" H 6330 3390 50  0000 C CNN
F 2 "" H 6330 3250 50  0000 C CNN
F 3 "" H 6330 3250 50  0000 C CNN
	1    6330 3250
	1    0    0    -1  
$EndComp
$Comp
L C_Small C6
U 1 1 56E541E7
P 6330 3460
F 0 "C6" H 6340 3530 50  0000 L CNN
F 1 "0.1u" H 6340 3380 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206_HandSoldering" H 6330 3460 50  0001 C CNN
F 3 "" H 6330 3460 50  0000 C CNN
	1    6330 3460
	1    0    0    -1  
$EndComp
Wire Wire Line
	5240 3040 7120 3040
Wire Wire Line
	5240 3140 6200 3140
Wire Wire Line
	6200 3140 6200 3300
Wire Wire Line
	6200 3300 6330 3300
Wire Wire Line
	6330 3250 6330 3360
Wire Wire Line
	5310 3880 5610 3880
Wire Wire Line
	5310 3340 5310 3880
$Comp
L GNDD #PWR15
U 1 1 56E56979
P 5580 3460
F 0 "#PWR15" H 5580 3210 50  0001 C CNN
F 1 "GNDD" H 5580 3310 50  0000 C CNN
F 2 "" H 5580 3460 50  0000 C CNN
F 3 "" H 5580 3460 50  0000 C CNN
	1    5580 3460
	1    0    0    -1  
$EndComp
Wire Wire Line
	5490 4550 5490 4460
Connection ~ 5490 4460
Wire Wire Line
	5370 3810 5370 3880
Connection ~ 5370 3880
Wire Wire Line
	5370 3610 5370 3240
Wire Wire Line
	5240 3240 6130 3240
Wire Wire Line
	5240 3440 5580 3440
Wire Wire Line
	5580 3440 5580 3460
Wire Wire Line
	6480 3670 6480 3640
Wire Wire Line
	6330 3640 6650 3640
Wire Wire Line
	6330 3640 6330 3560
Wire Wire Line
	6650 3640 6650 3560
Connection ~ 6480 3640
Wire Wire Line
	6650 3250 6650 3360
Connection ~ 6330 3300
Wire Wire Line
	6650 3330 6130 3330
Wire Wire Line
	6130 3330 6130 3240
Connection ~ 5370 3240
Connection ~ 6650 3330
$Comp
L GNDA #PWR22
U 1 1 56E5B194
P 7020 3570
F 0 "#PWR22" H 7020 3320 50  0001 C CNN
F 1 "GNDA" H 7020 3420 50  0000 C CNN
F 2 "" H 7020 3570 50  0000 C CNN
F 3 "" H 7020 3570 50  0000 C CNN
	1    7020 3570
	1    0    0    -1  
$EndComp
$Comp
L C_Small C10
U 1 1 56E5B1DE
P 6920 3250
F 0 "C10" H 6930 3320 50  0000 L CNN
F 1 "1u" H 6930 3170 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206_HandSoldering" H 6920 3250 50  0001 C CNN
F 3 "" H 6920 3250 50  0000 C CNN
	1    6920 3250
	1    0    0    -1  
$EndComp
$Comp
L C_Small C11
U 1 1 56E5B26F
P 7120 3390
F 0 "C11" H 7130 3460 50  0000 L CNN
F 1 "10u" H 7130 3310 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206_HandSoldering" H 7120 3390 50  0001 C CNN
F 3 "" H 7120 3390 50  0000 C CNN
	1    7120 3390
	1    0    0    -1  
$EndComp
$Comp
L R_Small R8
U 1 1 56E5B2FA
P 7120 3170
F 0 "R8" H 7150 3190 50  0000 L CNN
F 1 "0.5R" H 7150 3130 50  0000 L CNN
F 2 "Resistors_SMD:R_1206_HandSoldering" H 7120 3170 50  0001 C CNN
F 3 "" H 7120 3170 50  0000 C CNN
	1    7120 3170
	1    0    0    -1  
$EndComp
Wire Wire Line
	7120 3270 7120 3290
Wire Wire Line
	7120 3530 7120 3490
Wire Wire Line
	6920 3530 7120 3530
Wire Wire Line
	7020 3530 7020 3570
Wire Wire Line
	6920 3350 6920 3530
Connection ~ 7020 3530
Wire Wire Line
	6920 3040 6920 3150
Wire Wire Line
	7120 3030 7120 3070
Connection ~ 6920 3040
Wire Wire Line
	1010 3330 980  3330
Wire Wire Line
	980  3330 980  3570
Wire Wire Line
	980  3570 1640 3570
Wire Wire Line
	1640 3570 1640 3230
Connection ~ 1640 3230
Wire Wire Line
	1010 2600 980  2600
Wire Wire Line
	980  2600 980  2860
Wire Wire Line
	980  2860 1620 2860
Wire Wire Line
	1620 2860 1620 2500
Connection ~ 1620 2500
Wire Wire Line
	1610 1820 1690 1820
Text GLabel 1010 1720 0    60   Input ~ 0
IN2
Wire Wire Line
	1010 1920 960  1920
Wire Wire Line
	960  1920 960  2160
Wire Wire Line
	960  2160 1640 2160
Wire Wire Line
	1640 2160 1640 1820
Connection ~ 1640 1820
Wire Wire Line
	1010 1140 970  1140
Wire Wire Line
	970  1140 970  1450
Wire Wire Line
	970  1450 1680 1450
Wire Wire Line
	1680 1450 1680 1040
Connection ~ 1680 1040
Wire Wire Line
	7120 3030 7380 3030
Connection ~ 7120 3040
$Comp
L JUMPER3 JP4
U 1 1 56E5FF77
P 9690 3270
F 0 "JP4" H 9740 3170 50  0000 L CNN
F 1 "JUMPER3" H 9690 3370 50  0000 C BNN
F 2 "Socket_Strips:Socket_Strip_Straight_1x03" H 9690 3270 50  0001 C CNN
F 3 "" H 9690 3270 50  0000 C CNN
	1    9690 3270
	0    1    1    0   
$EndComp
$Comp
L JUMPER3 JP3
U 1 1 56E6001D
P 9280 3270
F 0 "JP3" H 9330 3170 50  0000 L CNN
F 1 "JUMPER3" H 9280 3370 50  0000 C BNN
F 2 "Socket_Strips:Socket_Strip_Straight_1x03" H 9280 3270 50  0001 C CNN
F 3 "" H 9280 3270 50  0000 C CNN
	1    9280 3270
	0    -1   -1   0   
$EndComp
Text GLabel 9670 2610 0    60   Input ~ 0
EXT_REF
$Comp
L JUMPER JP2
U 1 1 56E61F87
P 7680 3030
F 0 "JP2" H 7680 3180 50  0000 C CNN
F 1 "JUMPER" H 7680 2950 50  0000 C CNN
F 2 "Socket_Strips:Socket_Strip_Straight_1x02" H 7680 3030 50  0001 C CNN
F 3 "" H 7680 3030 50  0000 C CNN
	1    7680 3030
	1    0    0    -1  
$EndComp
$Comp
L MCP6001 U8
U 1 1 56E63918
P 8310 3030
F 0 "U8" H 8360 3230 50  0000 C CNN
F 1 "OPA320" H 8510 2830 50  0000 C CNN
F 2 "TO_SOT_Packages_SMD:SOT-23-5" H 8260 3130 50  0001 C CNN
F 3 "" H 8360 3230 50  0000 C CNN
	1    8310 3030
	-1   0    0    -1  
$EndComp
Wire Wire Line
	7980 3030 8010 3030
Wire Wire Line
	8610 2930 8760 2930
Wire Wire Line
	8760 2930 8760 2630
Wire Wire Line
	8760 2630 7990 2630
Wire Wire Line
	7990 2630 7990 3030
Connection ~ 7990 3030
$Comp
L C_Small C14
U 1 1 56E64B84
P 8680 3330
F 0 "C14" H 8690 3400 50  0000 L CNN
F 1 "10u" H 8690 3250 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206_HandSoldering" H 8680 3330 50  0001 C CNN
F 3 "" H 8680 3330 50  0000 C CNN
	1    8680 3330
	1    0    0    -1  
$EndComp
$Comp
L R_Small R10
U 1 1 56E64C2A
P 8920 3160
F 0 "R10" H 8950 3180 50  0000 L CNN
F 1 "0.5" H 8950 3120 50  0000 L CNN
F 2 "Resistors_SMD:R_1206_HandSoldering" H 8920 3160 50  0001 C CNN
F 3 "" H 8920 3160 50  0000 C CNN
	1    8920 3160
	1    0    0    -1  
$EndComp
$Comp
L C_Small C15
U 1 1 56E64CB1
P 8920 3390
F 0 "C15" H 8930 3460 50  0000 L CNN
F 1 "10u" H 8930 3310 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206_HandSoldering" H 8920 3390 50  0001 C CNN
F 3 "" H 8920 3390 50  0000 C CNN
	1    8920 3390
	1    0    0    -1  
$EndComp
$Comp
L R_Small R9
U 1 1 56E64D37
P 8780 3010
F 0 "R9" H 8810 3030 50  0000 L CNN
F 1 "10k" H 8810 2970 50  0000 L CNN
F 2 "Resistors_SMD:R_1206_HandSoldering" H 8780 3010 50  0001 C CNN
F 3 "" H 8780 3010 50  0000 C CNN
	1    8780 3010
	0    1    1    0   
$EndComp
Wire Wire Line
	8610 3130 8610 3010
Wire Wire Line
	8610 3010 8680 3010
Wire Wire Line
	8880 3010 8920 3010
Wire Wire Line
	8920 3260 8920 3290
Wire Wire Line
	8680 3230 8680 3130
Wire Wire Line
	8680 3130 8610 3130
Connection ~ 8610 3130
Wire Wire Line
	8680 3430 8680 3540
Wire Wire Line
	8680 3540 8920 3540
Wire Wire Line
	8920 3540 8920 3490
$Comp
L GNDA #PWR28
U 1 1 56E66816
P 8800 3580
F 0 "#PWR28" H 8800 3330 50  0001 C CNN
F 1 "GNDA" H 8800 3430 50  0000 C CNN
F 2 "" H 8800 3580 50  0000 C CNN
F 3 "" H 8800 3580 50  0000 C CNN
	1    8800 3580
	1    0    0    -1  
$EndComp
Wire Wire Line
	8800 3580 8800 3540
Connection ~ 8800 3540
Wire Wire Line
	8920 3020 9280 3020
Wire Wire Line
	9280 3520 9280 3790
Wire Wire Line
	9280 3790 7340 3790
Wire Wire Line
	7340 3790 7340 3030
Connection ~ 7340 3030
$Comp
L R_Small R11
U 1 1 56E67816
P 9370 2850
F 0 "R11" H 9400 2870 50  0000 L CNN
F 1 "10K" H 9400 2810 50  0000 L CNN
F 2 "Resistors_SMD:R_1206_HandSoldering" H 9370 2850 50  0001 C CNN
F 3 "" H 9370 2850 50  0000 C CNN
	1    9370 2850
	0    1    1    0   
$EndComp
Wire Wire Line
	9270 2850 9140 2850
Wire Wire Line
	9140 2850 9140 3020
Connection ~ 9140 3020
Wire Wire Line
	9470 2850 9520 2850
Wire Wire Line
	9520 2850 9520 3270
Wire Wire Line
	9380 3270 9590 3270
Connection ~ 9520 3270
Wire Wire Line
	9690 3020 9690 2610
Wire Wire Line
	9690 2610 9670 2610
Wire Wire Line
	8920 3010 8920 3060
Connection ~ 8920 3020
$Comp
L MAX874 U9
U 1 1 56E6D3F2
P 9850 4480
F 0 "U9" H 9950 4730 50  0000 C CNN
F 1 "REF5040" H 9900 4230 50  0000 L CNN
F 2 "SMD_Packages:SOIC-8-N" H 9850 4480 50  0001 C CNN
F 3 "" H 9850 4480 50  0000 C CNN
	1    9850 4480
	1    0    0    -1  
$EndComp
$Comp
L GNDA #PWR33
U 1 1 56E6DC74
P 9850 4860
F 0 "#PWR33" H 9850 4610 50  0001 C CNN
F 1 "GNDA" H 9850 4710 50  0000 C CNN
F 2 "" H 9850 4860 50  0000 C CNN
F 3 "" H 9850 4860 50  0000 C CNN
	1    9850 4860
	1    0    0    -1  
$EndComp
Wire Wire Line
	9850 4780 9850 4860
Wire Wire Line
	10500 4380 10670 4380
Wire Wire Line
	10670 4380 10670 3580
Wire Wire Line
	10670 3580 9690 3580
Wire Wire Line
	9690 3580 9690 3520
$Comp
L C_Small C17
U 1 1 56E6F40B
P 9140 4730
F 0 "C17" H 9150 4800 50  0000 L CNN
F 1 "1u" H 9150 4650 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206_HandSoldering" H 9140 4730 50  0001 C CNN
F 3 "" H 9140 4730 50  0000 C CNN
	1    9140 4730
	1    0    0    -1  
$EndComp
$Comp
L GNDA #PWR32
U 1 1 56E6FEF4
P 9140 4870
F 0 "#PWR32" H 9140 4620 50  0001 C CNN
F 1 "GNDA" H 9140 4720 50  0000 C CNN
F 2 "" H 9140 4870 50  0000 C CNN
F 3 "" H 9140 4870 50  0000 C CNN
	1    9140 4870
	1    0    0    -1  
$EndComp
Wire Wire Line
	9140 4830 9140 4870
Wire Wire Line
	8940 4380 9200 4380
Wire Wire Line
	9050 4380 9050 4230
Wire Wire Line
	9200 4580 9140 4580
Wire Wire Line
	9140 4580 9140 4630
$Comp
L C_Small C16
U 1 1 56E7157D
P 8940 4620
F 0 "C16" H 8950 4690 50  0000 L CNN
F 1 "10u" H 8950 4540 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206_HandSoldering" H 8940 4620 50  0001 C CNN
F 3 "" H 8940 4620 50  0000 C CNN
	1    8940 4620
	1    0    0    -1  
$EndComp
Wire Wire Line
	8940 4520 8940 4380
Connection ~ 9050 4380
Wire Wire Line
	8940 4720 8940 4860
Wire Wire Line
	8940 4860 9140 4860
Wire Wire Line
	9140 4860 9140 4850
Connection ~ 9140 4850
$Comp
L VCC #PWR31
U 1 1 56E73E38
P 9050 4230
F 0 "#PWR31" H 9050 4080 50  0001 C CNN
F 1 "VCC" H 9050 4380 50  0000 C CNN
F 2 "" H 9050 4230 50  0000 C CNN
F 3 "" H 9050 4230 50  0000 C CNN
	1    9050 4230
	1    0    0    -1  
$EndComp
$Comp
L +5VA #PWR25
U 1 1 56E766A8
P 8130 4650
F 0 "#PWR25" H 8130 4500 50  0001 C CNN
F 1 "+5VA" H 8130 4790 50  0000 C CNN
F 2 "" H 8130 4650 50  0000 C CNN
F 3 "" H 8130 4650 50  0000 C CNN
	1    8130 4650
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR21
U 1 1 56E76726
P 6670 4640
F 0 "#PWR21" H 6670 4490 50  0001 C CNN
F 1 "VCC" H 6670 4790 50  0000 C CNN
F 2 "" H 6670 4640 50  0000 C CNN
F 3 "" H 6670 4640 50  0000 C CNN
	1    6670 4640
	1    0    0    -1  
$EndComp
$Comp
L CP_Small C9
U 1 1 56E7677B
P 6720 4860
F 0 "C9" H 6730 4930 50  0000 L CNN
F 1 "10u" H 6730 4780 50  0000 L CNN
F 2 "Capacitors_Tantalum_SMD:TantalC_SizeU_EIA-6032" H 6720 4860 50  0001 C CNN
F 3 "" H 6720 4860 50  0000 C CNN
	1    6720 4860
	1    0    0    -1  
$EndComp
$Comp
L CP_Small C12
U 1 1 56E76829
P 7650 4850
F 0 "C12" H 7660 4920 50  0000 L CNN
F 1 "10u tant" H 7660 4770 50  0000 L CNN
F 2 "Capacitors_Tantalum_SMD:TantalC_SizeU_EIA-6032" H 7650 4850 50  0001 C CNN
F 3 "" H 7650 4850 50  0000 C CNN
	1    7650 4850
	1    0    0    -1  
$EndComp
$Comp
L C_Small C13
U 1 1 56E76F68
P 8000 4850
F 0 "C13" H 8010 4920 50  0000 L CNN
F 1 "1u" H 8010 4770 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206_HandSoldering" H 8000 4850 50  0001 C CNN
F 3 "" H 8000 4850 50  0000 C CNN
	1    8000 4850
	1    0    0    -1  
$EndComp
Wire Wire Line
	8130 4690 8130 4650
Wire Wire Line
	7620 4690 8130 4690
Wire Wire Line
	7650 4070 7650 4750
Wire Wire Line
	8000 4750 8000 4690
Connection ~ 8000 4690
$Comp
L GNDA #PWR24
U 1 1 56E77814
P 7220 5080
F 0 "#PWR24" H 7220 4830 50  0001 C CNN
F 1 "GNDA" H 7220 4930 50  0000 C CNN
F 2 "" H 7220 5080 50  0000 C CNN
F 3 "" H 7220 5080 50  0000 C CNN
	1    7220 5080
	1    0    0    -1  
$EndComp
Wire Wire Line
	7650 5020 7650 4950
$Comp
L 78L05 U6
U 1 1 56E7847D
P 7220 4740
F 0 "U6" H 7370 4544 50  0000 C CNN
F 1 "TL750L05" H 7220 4940 50  0000 C CNN
F 2 "TO_SOT_Packages_THT:TO-92_Molded_Wide_Oval" H 7220 4740 50  0001 C CNN
F 3 "" H 7220 4740 50  0000 C CNN
	1    7220 4740
	1    0    0    -1  
$EndComp
Connection ~ 7650 4690
Wire Wire Line
	7220 4990 7220 5080
Wire Wire Line
	6530 5020 8000 5020
Wire Wire Line
	8000 5020 8000 4950
Connection ~ 7650 5020
Connection ~ 7220 5020
Wire Wire Line
	6720 4960 6720 5020
Wire Wire Line
	6720 4070 6720 4760
Wire Wire Line
	6530 4690 6820 4690
Wire Wire Line
	6670 4640 6670 4690
Connection ~ 6720 4690
$Comp
L C_Small C7
U 1 1 56E7B7AF
P 6530 4860
F 0 "C7" H 6540 4930 50  0000 L CNN
F 1 "1u" H 6540 4780 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206_HandSoldering" H 6530 4860 50  0001 C CNN
F 3 "" H 6530 4860 50  0000 C CNN
	1    6530 4860
	1    0    0    -1  
$EndComp
Wire Wire Line
	6530 4960 6530 5020
Connection ~ 6720 5020
Wire Wire Line
	6530 4760 6530 4690
Connection ~ 6670 4690
$Comp
L 78L05 U7
U 1 1 56E7DD25
P 7230 4120
F 0 "U7" H 7380 3924 50  0000 C CNN
F 1 "L78S05" H 7230 4320 50  0000 C CNN
F 2 "TO_SOT_Packages_THT:TO-220_Neutral123_Vertical_LargePads" H 7230 4120 50  0001 C CNN
F 3 "" H 7230 4120 50  0000 C CNN
	1    7230 4120
	1    0    0    -1  
$EndComp
Wire Wire Line
	7630 4070 7650 4070
Wire Wire Line
	6830 4070 6720 4070
$Comp
L GNDA #PWR23
U 1 1 56E7EB42
P 7120 4320
F 0 "#PWR23" H 7120 4070 50  0001 C CNN
F 1 "GNDA" H 7120 4170 50  0000 C CNN
F 2 "" H 7120 4320 50  0000 C CNN
F 3 "" H 7120 4320 50  0000 C CNN
	1    7120 4320
	1    0    0    -1  
$EndComp
Wire Wire Line
	7120 4320 7180 4320
Wire Wire Line
	7180 4320 7180 4370
Wire Wire Line
	7180 4370 7230 4370
Wire Notes Line
	6550 4400 7890 4400
Wire Notes Line
	7890 4400 7890 3870
Wire Notes Line
	7890 3870 6550 3870
Wire Notes Line
	6550 3870 6550 4400
Text Notes 6620 3870 0    60   ~ 0
OPTIONAL - HIGH CURRENT MODE
Wire Notes Line
	510  1490 2410 1490
Wire Notes Line
	2410 1490 2410 3940
Wire Notes Line
	2410 3940 510  3940
Wire Notes Line
	510  3940 510  1490
Text Notes 1950 3940 0    60   ~ 0
OPTIONAL
$Comp
L BNC P3
U 1 1 56E85F9F
P 1210 4390
F 0 "P3" H 1220 4510 50  0000 C CNN
F 1 "BNC" V 1320 4330 50  0000 C CNN
F 2 "Connect:bnc-ci" H 1210 4390 50  0001 C CNN
F 3 "" H 1210 4390 50  0000 C CNN
	1    1210 4390
	1    0    0    -1  
$EndComp
$Comp
L BNC P4
U 1 1 56E8609F
P 1210 4850
F 0 "P4" H 1220 4970 50  0000 C CNN
F 1 "BNC" V 1320 4790 50  0000 C CNN
F 2 "Connect:bnc-ci" H 1210 4850 50  0001 C CNN
F 3 "" H 1210 4850 50  0000 C CNN
	1    1210 4850
	1    0    0    -1  
$EndComp
$Comp
L BNC P1
U 1 1 56E8615F
P 1200 5280
F 0 "P1" H 1210 5400 50  0000 C CNN
F 1 "BNC" V 1310 5220 50  0000 C CNN
F 2 "Connect:bnc-ci" H 1200 5280 50  0001 C CNN
F 3 "" H 1200 5280 50  0000 C CNN
	1    1200 5280
	1    0    0    -1  
$EndComp
$Comp
L BNC P2
U 1 1 56E86236
P 1200 5760
F 0 "P2" H 1210 5880 50  0000 C CNN
F 1 "BNC" V 1310 5700 50  0000 C CNN
F 2 "Connect:bnc-ci" H 1200 5760 50  0001 C CNN
F 3 "" H 1200 5760 50  0000 C CNN
	1    1200 5760
	1    0    0    -1  
$EndComp
Text GLabel 1060 4390 0    60   Input ~ 0
IN4
Text GLabel 1060 4850 0    60   Input ~ 0
IN3
Text GLabel 1050 5280 0    60   Input ~ 0
IN2
Text GLabel 1050 5760 0    60   Input ~ 0
IN1
$Comp
L GNDA #PWR3
U 1 1 56E89E10
P 1400 6040
F 0 "#PWR3" H 1400 5790 50  0001 C CNN
F 1 "GNDA" H 1400 5890 50  0000 C CNN
F 2 "" H 1400 6040 50  0000 C CNN
F 3 "" H 1400 6040 50  0000 C CNN
	1    1400 6040
	1    0    0    -1  
$EndComp
Wire Wire Line
	1210 4590 1400 4590
Wire Wire Line
	1400 4590 1400 6040
Wire Wire Line
	1200 5960 1200 5990
Wire Wire Line
	1200 5990 1400 5990
Connection ~ 1400 5990
Wire Wire Line
	1200 5480 1200 5510
Wire Wire Line
	1200 5510 1400 5510
Connection ~ 1400 5510
Wire Wire Line
	1210 5050 1210 5080
Wire Wire Line
	1210 5080 1400 5080
Connection ~ 1400 5080
$Comp
L CONN_02X06 P5
U 1 1 56E8CF19
P 2850 6030
F 0 "P5" H 2850 6380 50  0000 C CNN
F 1 "CONN_02X06" H 2850 5680 50  0000 C CNN
F 2 "Socket_Strips:Socket_Strip_Straight_2x06" H 2850 4830 50  0001 C CNN
F 3 "" H 2850 4830 50  0000 C CNN
	1    2850 6030
	1    0    0    -1  
$EndComp
Wire Wire Line
	3100 5780 3110 5780
Wire Wire Line
	3100 5880 3110 5880
Wire Wire Line
	3100 6280 4110 6280
Wire Wire Line
	3100 6180 3490 6180
Wire Wire Line
	3490 6180 3490 6540
Wire Wire Line
	2420 6540 2420 6180
Wire Wire Line
	2420 6180 2600 6180
Wire Wire Line
	2600 6280 2490 6280
Wire Wire Line
	2490 6280 2490 6450
Wire Wire Line
	2490 6450 3240 6450
Wire Wire Line
	3240 6450 3240 6280
Connection ~ 3240 6280
$Comp
L GNDA #PWR4
U 1 1 56E8E642
P 1720 7310
F 0 "#PWR4" H 1720 7060 50  0001 C CNN
F 1 "GNDA" H 1720 7160 50  0000 C CNN
F 2 "" H 1720 7310 50  0000 C CNN
F 3 "" H 1720 7310 50  0000 C CNN
	1    1720 7310
	1    0    0    -1  
$EndComp
$Comp
L +3.3V #PWR12
U 1 1 56E902E0
P 3800 6190
F 0 "#PWR12" H 3800 6040 50  0001 C CNN
F 1 "+3.3V" H 3800 6330 50  0000 C CNN
F 2 "" H 3800 6190 50  0000 C CNN
F 3 "" H 3800 6190 50  0000 C CNN
	1    3800 6190
	1    0    0    -1  
$EndComp
Wire Wire Line
	3800 6280 3800 6190
$Comp
L BARREL_JACK CON1
U 1 1 56E9326A
P 8510 5700
F 0 "CON1" H 8510 5950 50  0000 C CNN
F 1 "BARREL_JACK" H 8510 5500 50  0000 C CNN
F 2 "Connect:JACK_ALIM" H 8510 5700 50  0001 C CNN
F 3 "" H 8510 5700 50  0000 C CNN
	1    8510 5700
	1    0    0    -1  
$EndComp
$Comp
L GNDA #PWR29
U 1 1 56E93599
P 8960 5880
F 0 "#PWR29" H 8960 5630 50  0001 C CNN
F 1 "GNDA" H 8960 5730 50  0000 C CNN
F 2 "" H 8960 5880 50  0000 C CNN
F 3 "" H 8960 5880 50  0000 C CNN
	1    8960 5880
	1    0    0    -1  
$EndComp
Wire Wire Line
	8810 5800 8960 5800
Wire Wire Line
	8960 5700 8960 5880
Wire Wire Line
	8810 5700 9220 5700
Connection ~ 8960 5800
$Comp
L VCC #PWR30
U 1 1 56E941B0
P 8970 5530
F 0 "#PWR30" H 8970 5380 50  0001 C CNN
F 1 "VCC" H 8970 5680 50  0000 C CNN
F 2 "" H 8970 5530 50  0000 C CNN
F 3 "" H 8970 5530 50  0000 C CNN
	1    8970 5530
	1    0    0    -1  
$EndComp
Wire Wire Line
	8810 5600 8970 5600
Wire Wire Line
	8970 5600 8970 5530
$Comp
L PWR_FLAG #FLG2
U 1 1 56E94ED5
P 8810 5450
F 0 "#FLG2" H 8810 5545 50  0001 C CNN
F 1 "PWR_FLAG" H 8810 5630 50  0000 C CNN
F 2 "" H 8810 5450 50  0000 C CNN
F 3 "" H 8810 5450 50  0000 C CNN
	1    8810 5450
	1    0    0    -1  
$EndComp
$Comp
L PWR_FLAG #FLG3
U 1 1 56E95487
P 9220 5700
F 0 "#FLG3" H 9220 5795 50  0001 C CNN
F 1 "PWR_FLAG" H 9220 5880 50  0000 C CNN
F 2 "" H 9220 5700 50  0000 C CNN
F 3 "" H 9220 5700 50  0000 C CNN
	1    9220 5700
	1    0    0    -1  
$EndComp
$Comp
L PWR_FLAG #FLG1
U 1 1 56E957F2
P 4110 6240
F 0 "#FLG1" H 4110 6335 50  0001 C CNN
F 1 "PWR_FLAG" H 4110 6420 50  0000 C CNN
F 2 "" H 4110 6240 50  0000 C CNN
F 3 "" H 4110 6240 50  0000 C CNN
	1    4110 6240
	1    0    0    -1  
$EndComp
Wire Wire Line
	4110 6280 4110 6240
Connection ~ 3800 6280
Connection ~ 8960 5700
Wire Wire Line
	8810 5450 8810 5520
Wire Wire Line
	8810 5520 8890 5520
Wire Wire Line
	8890 5520 8890 5600
Connection ~ 8890 5600
$Comp
L GNDD #PWR11
U 1 1 56E9B38E
P 3150 6620
F 0 "#PWR11" H 3150 6370 50  0001 C CNN
F 1 "GNDD" H 3150 6470 50  0000 C CNN
F 2 "" H 3150 6620 50  0000 C CNN
F 3 "" H 3150 6620 50  0000 C CNN
	1    3150 6620
	1    0    0    -1  
$EndComp
Wire Wire Line
	3150 6620 3150 6540
Connection ~ 3150 6540
$Comp
L GNDD #PWR9
U 1 1 56E9D5EC
P 2080 7320
F 0 "#PWR9" H 2080 7070 50  0001 C CNN
F 1 "GNDD" H 2080 7170 50  0000 C CNN
F 2 "" H 2080 7320 50  0000 C CNN
F 3 "" H 2080 7320 50  0000 C CNN
	1    2080 7320
	1    0    0    -1  
$EndComp
Wire Wire Line
	1720 7310 1720 7220
Wire Wire Line
	1720 7220 2080 7220
Wire Wire Line
	2080 7220 2080 7320
Wire Wire Line
	3490 6540 2420 6540
Text Label 2580 6080 2    60   ~ 0
~CONVST
Text Label 3110 5980 0    60   ~ 0
~RESET
Text Label 2580 5980 2    60   ~ 0
SDO
Text Label 2580 5780 2    60   ~ 0
SDI
Text Label 2580 5880 2    60   ~ 0
FS/~CS
Text Label 3110 5780 0    60   ~ 0
SCLK
Text Label 3110 5880 0    60   ~ 0
EOC/~INT~/CDI
Wire Wire Line
	3100 5980 3110 5980
Wire Wire Line
	3100 6080 3110 6080
Wire Wire Line
	10500 4580 10600 4580
NoConn ~ 10600 4580
Text GLabel 4800 5920 0    60   Input ~ 0
EXT_REF
$Comp
L GNDA #PWR27
U 1 1 56EAC6C3
P 8410 3420
F 0 "#PWR27" H 8410 3170 50  0001 C CNN
F 1 "GNDA" H 8410 3270 50  0000 C CNN
F 2 "" H 8410 3420 50  0000 C CNN
F 3 "" H 8410 3420 50  0000 C CNN
	1    8410 3420
	1    0    0    -1  
$EndComp
Wire Wire Line
	8410 3330 8410 3420
$Comp
L +5VA #PWR26
U 1 1 56EAD0BF
P 8410 2510
F 0 "#PWR26" H 8410 2360 50  0001 C CNN
F 1 "+5VA" H 8410 2650 50  0000 C CNN
F 2 "" H 8410 2510 50  0000 C CNN
F 3 "" H 8410 2510 50  0000 C CNN
	1    8410 2510
	1    0    0    -1  
$EndComp
Wire Wire Line
	8410 2510 8410 2730
Wire Notes Line
	6870 4500 7510 4500
Wire Notes Line
	6870 4500 6870 5330
Wire Notes Line
	6870 5330 7510 5330
Wire Notes Line
	7510 5330 7510 4500
Text Notes 6760 5420 0    60   ~ 0
LOW CURRENT MODE
Wire Wire Line
	2600 5880 2580 5880
Wire Wire Line
	2580 5980 2600 5980
Wire Wire Line
	2600 6080 2580 6080
Wire Wire Line
	2600 5780 2580 5780
$Comp
L BNC P6
U 1 1 56E5B816
P 4950 5920
F 0 "P6" H 4960 6040 50  0000 C CNN
F 1 "BNC" V 5060 5860 50  0000 C CNN
F 2 "Connect:bnc-ci" H 4950 5920 50  0001 C CNN
F 3 "" H 4950 5920 50  0000 C CNN
	1    4950 5920
	1    0    0    -1  
$EndComp
$Comp
L GNDA #PWR13
U 1 1 56E5C590
P 4950 6120
F 0 "#PWR13" H 4950 5870 50  0001 C CNN
F 1 "GNDA" H 4950 5970 50  0000 C CNN
F 2 "" H 4950 6120 50  0000 C CNN
F 3 "" H 4950 6120 50  0000 C CNN
	1    4950 6120
	1    0    0    -1  
$EndComp
$EndSCHEMATC
