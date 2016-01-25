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
LIBS:Driver-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "Stepper Motor Driver Controller"
Date ""
Rev ""
Comp "MENG Flow Project"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text Label 9730 3160 2    60   ~ 0
STEPPER1PHASEA1
Text Label 9730 3260 2    60   ~ 0
STEPPER1PHASEA2
Text Label 9730 3360 2    60   ~ 0
STEPPER1PHASEB1
Text Label 9730 3460 2    60   ~ 0
STEPPER1PHASEB2
Connection ~ 13350 1000
Wire Wire Line
	9730 3160 9280 3160
Wire Wire Line
	9280 3260 9730 3260
Wire Wire Line
	9730 3360 9270 3360
Wire Wire Line
	9270 3460 9730 3460
$Comp
L Q_NMOS_GDS Q1
U 1 1 569D21FC
P 5010 2020
F 0 "Q1" H 5260 1920 50  0000 R CNN
F 1 "FQP20N06" H 5310 1820 50  0000 R CNN
F 2 "TO_SOT_Packages_THT:TO-220_Neutral123_Horizontal_Reverse_LargePads" H 5210 2120 29  0001 C CNN
F 3 "" H 5010 2020 60  0000 C CNN
	1    5010 2020
	1    0    0    -1  
$EndComp
$Comp
L Q_NMOS_GDS Q2
U 1 1 569D21FD
P 6360 2020
F 0 "Q2" H 6310 2170 50  0000 R CNN
F 1 "FQP20N06" H 6510 1820 50  0000 R CNN
F 2 "TO_SOT_Packages_THT:TO-220_Neutral123_Horizontal_Reverse_LargePads" H 6560 2120 29  0001 C CNN
F 3 "" H 6360 2020 60  0000 C CNN
	1    6360 2020
	-1   0    0    -1  
$EndComp
$Comp
L Q_NMOS_GDS Q5
U 1 1 569D21FE
P 5010 2720
F 0 "Q5" H 5260 2620 50  0000 R CNN
F 1 "FQP20N06" H 5310 2520 50  0000 R CNN
F 2 "TO_SOT_Packages_THT:TO-220_Neutral123_Horizontal_Reverse_LargePads" H 5210 2820 29  0001 C CNN
F 3 "" H 5010 2720 60  0000 C CNN
	1    5010 2720
	1    0    0    -1  
$EndComp
$Comp
L Q_NMOS_GDS Q6
U 1 1 569D21FF
P 6360 2720
F 0 "Q6" H 6310 2620 50  0000 R CNN
F 1 "FQP20N06" H 6360 2520 50  0000 R CNN
F 2 "TO_SOT_Packages_THT:TO-220_Neutral123_Horizontal_Reverse_LargePads" H 6560 2820 29  0001 C CNN
F 3 "" H 6360 2720 60  0000 C CNN
	1    6360 2720
	-1   0    0    -1  
$EndComp
$Comp
L +5V #PWR01
U 1 1 569D2200
P 5660 1520
F 0 "#PWR01" H 5660 1370 50  0001 C CNN
F 1 "+5V" H 5660 1660 50  0000 C CNN
F 2 "" H 5660 1520 60  0000 C CNN
F 3 "" H 5660 1520 60  0000 C CNN
	1    5660 1520
	1    0    0    -1  
$EndComp
Wire Wire Line
	5110 1820 5110 1670
Wire Wire Line
	5110 1670 6260 1670
Wire Wire Line
	5660 1670 5660 1520
Wire Wire Line
	6260 1670 6260 1820
Connection ~ 5660 1670
Wire Wire Line
	5110 2220 5110 2520
Wire Wire Line
	6260 2220 6260 2520
$Comp
L CONN_01X02 M1A1
U 1 1 569D2201
P 5610 2520
F 0 "M1A1" H 5560 2670 50  0000 C CNN
F 1 "CONN_01X02" V 5710 2570 50  0000 C CNN
F 2 "Terminal_Blocks:TerminalBlock_Pheonix_MPT-2.54mm_2pol" H 5610 2520 60  0001 C CNN
F 3 "" H 5610 2520 60  0000 C CNN
	1    5610 2520
	0    1    1    0   
$EndComp
Connection ~ 6260 2320
Wire Wire Line
	5110 2320 5560 2320
Connection ~ 5110 2320
Wire Wire Line
	6260 2970 6260 2920
Wire Wire Line
	5110 2970 6260 2970
Wire Wire Line
	5660 2970 5660 3170
Wire Wire Line
	5110 2920 5110 2970
Connection ~ 5660 2970
$Comp
L R R5
U 1 1 569D2202
P 6010 2320
F 0 "R5" V 6090 2320 50  0000 C CNN
F 1 "0R22 (OPT)" V 5910 2170 50  0000 C CNN
F 2 "Resistors_ThroughHole:Resistor_Cement_KOA-BGR-3N" V 5940 2320 30  0001 C CNN
F 3 "" H 6010 2320 30  0000 C CNN
	1    6010 2320
	0    1    1    0   
$EndComp
$Comp
L GND #PWR02
U 1 1 569D2203
P 5660 3170
F 0 "#PWR02" H 5660 2920 50  0001 C CNN
F 1 "GND" H 5660 3020 50  0000 C CNN
F 2 "" H 5660 3170 60  0000 C CNN
F 3 "" H 5660 3170 60  0000 C CNN
	1    5660 3170
	1    0    0    -1  
$EndComp
Wire Wire Line
	3860 2720 4810 2720
Wire Wire Line
	3960 2170 3960 2720
Connection ~ 3960 2720
$Comp
L R R1
U 1 1 569D2204
P 4660 1720
F 0 "R1" V 4740 1720 50  0000 C CNN
F 1 "820R" V 4660 1720 50  0000 C CNN
F 2 "Resistors_ThroughHole:Resistor_Horizontal_RM10mm" V 4590 1720 30  0001 C CNN
F 3 "" H 4660 1720 30  0000 C CNN
	1    4660 1720
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR03
U 1 1 569D2205
P 4660 2420
F 0 "#PWR03" H 4660 2170 50  0001 C CNN
F 1 "GND" H 4660 2270 50  0000 C CNN
F 2 "" H 4660 2420 60  0000 C CNN
F 3 "" H 4660 2420 60  0000 C CNN
	1    4660 2420
	1    0    0    -1  
$EndComp
Wire Wire Line
	4660 2370 4660 2420
$Comp
L +9V #PWR04
U 1 1 569D2206
P 4660 1520
F 0 "#PWR04" H 4660 1370 50  0001 C CNN
F 1 "+9V" H 4660 1660 50  0000 C CNN
F 2 "" H 4660 1520 60  0000 C CNN
F 3 "" H 4660 1520 60  0000 C CNN
	1    4660 1520
	1    0    0    -1  
$EndComp
Wire Wire Line
	4660 1520 4660 1570
$Comp
L R R3
U 1 1 569D2207
P 4160 2170
F 0 "R3" V 4240 2170 50  0000 C CNN
F 1 "43K" V 4160 2170 50  0000 C CNN
F 2 "Resistors_ThroughHole:Resistor_Horizontal_RM10mm" V 4090 2170 30  0001 C CNN
F 3 "" H 4160 2170 30  0000 C CNN
	1    4160 2170
	0    1    1    0   
$EndComp
Wire Wire Line
	4360 2170 4310 2170
Wire Wire Line
	4010 2170 3960 2170
$Comp
L R R2
U 1 1 569D2208
P 6660 1720
F 0 "R2" V 6740 1720 50  0000 C CNN
F 1 "820R" V 6660 1720 50  0000 C CNN
F 2 "Resistors_ThroughHole:Resistor_Horizontal_RM10mm" V 6590 1720 30  0001 C CNN
F 3 "" H 6660 1720 30  0000 C CNN
	1    6660 1720
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR05
U 1 1 569D2209
P 6660 2420
F 0 "#PWR05" H 6660 2170 50  0001 C CNN
F 1 "GND" H 6660 2270 50  0000 C CNN
F 2 "" H 6660 2420 60  0000 C CNN
F 3 "" H 6660 2420 60  0000 C CNN
	1    6660 2420
	1    0    0    -1  
$EndComp
$Comp
L +9V #PWR06
U 1 1 569D220A
P 6660 1520
F 0 "#PWR06" H 6660 1370 50  0001 C CNN
F 1 "+9V" H 6660 1660 50  0000 C CNN
F 2 "" H 6660 1520 60  0000 C CNN
F 3 "" H 6660 1520 60  0000 C CNN
	1    6660 1520
	1    0    0    -1  
$EndComp
$Comp
L R R4
U 1 1 569D220B
P 7160 2170
F 0 "R4" V 7240 2170 50  0000 C CNN
F 1 "43K" V 7160 2170 50  0000 C CNN
F 2 "Resistors_ThroughHole:Resistor_Horizontal_RM10mm" V 7090 2170 30  0001 C CNN
F 3 "" H 7160 2170 30  0000 C CNN
	1    7160 2170
	0    1    1    0   
$EndComp
Wire Wire Line
	6660 2370 6660 2420
Wire Wire Line
	6960 2170 7010 2170
Wire Wire Line
	7310 2170 7360 2170
Wire Wire Line
	7360 2170 7360 2720
Wire Wire Line
	4660 1870 4660 1970
Wire Wire Line
	4810 1920 4810 2020
Wire Wire Line
	6560 2020 6560 1920
Wire Wire Line
	6660 1570 6660 1520
Wire Wire Line
	6660 1870 6660 1970
Wire Wire Line
	6560 1920 6660 1920
Connection ~ 6660 1920
Wire Wire Line
	6560 2720 8260 2720
Connection ~ 7360 2720
Wire Wire Line
	5660 2320 5860 2320
Wire Wire Line
	6160 2320 6260 2320
$Comp
L Q_NPN_ECB Q3
U 1 1 569D220C
P 4560 2170
F 0 "Q3" H 4460 2320 50  0000 R CNN
F 1 "2N3704" H 4660 2020 50  0000 R CNN
F 2 "Transistors_OldSowjetAera:OldSowjetaera_Transistor_Type-I_BigPads" H 4760 2270 29  0001 C CNN
F 3 "" H 4560 2170 60  0000 C CNN
	1    4560 2170
	1    0    0    -1  
$EndComp
$Comp
L Q_NPN_ECB Q4
U 1 1 569D220D
P 6760 2170
F 0 "Q4" H 6710 2070 50  0000 R CNN
F 1 "2N3704" H 6760 2320 50  0000 R CNN
F 2 "Transistors_OldSowjetAera:OldSowjetaera_Transistor_Type-I_BigPads" H 6960 2270 29  0001 C CNN
F 3 "" H 6760 2170 60  0000 C CNN
	1    6760 2170
	-1   0    0    -1  
$EndComp
Wire Wire Line
	4810 1920 4660 1920
Connection ~ 4660 1920
$Comp
L D D2
U 1 1 569D220E
P 6060 1970
F 0 "D2" H 6060 2070 50  0000 C CNN
F 1 "SA5.0A" H 6060 1870 50  0000 C CNN
F 2 "Diodes_ThroughHole:Diode_DO-35_SOD27_Horizontal_RM10" H 6060 1970 60  0001 C CNN
F 3 "" H 6060 1970 60  0000 C CNN
	1    6060 1970
	0    1    1    0   
$EndComp
$Comp
L D D1
U 1 1 569D220F
P 5310 1970
F 0 "D1" H 5310 2070 50  0000 C CNN
F 1 "SA5.0A" H 5260 2120 50  0000 C CNN
F 2 "Diodes_ThroughHole:Diode_DO-35_SOD27_Horizontal_RM10" H 5310 1970 60  0001 C CNN
F 3 "" H 5310 1970 60  0000 C CNN
	1    5310 1970
	0    1    1    0   
$EndComp
$Comp
L D D3
U 1 1 569D2210
P 5310 2670
F 0 "D3" H 5360 2770 50  0000 C CNN
F 1 "SA5.0A" H 5460 2820 50  0000 C CNN
F 2 "Diodes_ThroughHole:Diode_DO-35_SOD27_Horizontal_RM10" H 5310 2670 60  0001 C CNN
F 3 "" H 5310 2670 60  0000 C CNN
	1    5310 2670
	0    1    1    0   
$EndComp
$Comp
L D D4
U 1 1 569D2211
P 6060 2720
F 0 "D4" H 6060 2820 50  0000 C CNN
F 1 "SA5.0A" H 6060 2620 50  0000 C CNN
F 2 "Diodes_ThroughHole:Diode_DO-35_SOD27_Horizontal_RM10" H 6060 2720 60  0001 C CNN
F 3 "" H 6060 2720 60  0000 C CNN
	1    6060 2720
	0    1    1    0   
$EndComp
Wire Wire Line
	5310 2120 5310 2520
Connection ~ 5310 2320
Wire Wire Line
	5310 2820 5310 2970
Connection ~ 5310 2970
Wire Wire Line
	5310 1670 5310 1820
Connection ~ 5310 1670
Wire Wire Line
	6060 2870 6060 2970
Connection ~ 6060 2970
Wire Wire Line
	6060 2570 6060 2570
Wire Wire Line
	6210 2420 6060 2570
Connection ~ 6210 2320
Wire Wire Line
	6060 1820 6060 1670
Connection ~ 6060 1670
Wire Wire Line
	6060 2120 6210 2270
Wire Wire Line
	6210 2270 6210 2420
$Comp
L Q_NMOS_GDS Q7
U 1 1 569D2212
P 5060 4320
F 0 "Q7" H 5310 4220 50  0000 R CNN
F 1 "FQP20N06" H 5360 4120 50  0000 R CNN
F 2 "TO_SOT_Packages_THT:TO-220_Neutral123_Horizontal_Reverse_LargePads" H 5260 4420 29  0001 C CNN
F 3 "" H 5060 4320 60  0000 C CNN
	1    5060 4320
	1    0    0    -1  
$EndComp
$Comp
L Q_NMOS_GDS Q8
U 1 1 569D2213
P 6410 4320
F 0 "Q8" H 6360 4470 50  0000 R CNN
F 1 "FQP20N06" H 6560 4120 50  0000 R CNN
F 2 "TO_SOT_Packages_THT:TO-220_Neutral123_Horizontal_Reverse_LargePads" H 6610 4420 29  0001 C CNN
F 3 "" H 6410 4320 60  0000 C CNN
	1    6410 4320
	-1   0    0    -1  
$EndComp
$Comp
L Q_NMOS_GDS Q11
U 1 1 569D2214
P 5060 5020
F 0 "Q11" H 5310 4920 50  0000 R CNN
F 1 "FQP20N06" H 5360 4820 50  0000 R CNN
F 2 "TO_SOT_Packages_THT:TO-220_Neutral123_Horizontal_Reverse_LargePads" H 5260 5120 29  0001 C CNN
F 3 "" H 5060 5020 60  0000 C CNN
	1    5060 5020
	1    0    0    -1  
$EndComp
$Comp
L Q_NMOS_GDS Q12
U 1 1 569D2215
P 6410 5020
F 0 "Q12" H 6360 4920 50  0000 R CNN
F 1 "FQP20N06" H 6410 4820 50  0000 R CNN
F 2 "TO_SOT_Packages_THT:TO-220_Neutral123_Horizontal_Reverse_LargePads" H 6610 5120 29  0001 C CNN
F 3 "" H 6410 5020 60  0000 C CNN
	1    6410 5020
	-1   0    0    -1  
$EndComp
$Comp
L +5V #PWR07
U 1 1 569D2216
P 5710 3820
F 0 "#PWR07" H 5710 3670 50  0001 C CNN
F 1 "+5V" H 5710 3960 50  0000 C CNN
F 2 "" H 5710 3820 60  0000 C CNN
F 3 "" H 5710 3820 60  0000 C CNN
	1    5710 3820
	1    0    0    -1  
$EndComp
Wire Wire Line
	5160 4120 5160 3970
Wire Wire Line
	5160 3970 6310 3970
Wire Wire Line
	5710 3970 5710 3820
Wire Wire Line
	6310 3970 6310 4120
Connection ~ 5710 3970
Wire Wire Line
	5160 4520 5160 4820
Wire Wire Line
	6310 4520 6310 4820
$Comp
L CONN_01X02 M1A2
U 1 1 569D2217
P 5660 4820
F 0 "M1A2" H 5610 4970 50  0000 C CNN
F 1 "CONN_01X02" V 5760 4870 50  0000 C CNN
F 2 "Terminal_Blocks:TerminalBlock_Pheonix_MPT-2.54mm_2pol" H 5660 4820 60  0001 C CNN
F 3 "" H 5660 4820 60  0000 C CNN
	1    5660 4820
	0    1    1    0   
$EndComp
Connection ~ 6310 4620
Wire Wire Line
	5160 4620 5610 4620
Connection ~ 5160 4620
Wire Wire Line
	6310 5270 6310 5220
Wire Wire Line
	5160 5270 6310 5270
Wire Wire Line
	5710 5270 5710 5470
Wire Wire Line
	5160 5220 5160 5270
Connection ~ 5710 5270
$Comp
L R R10
U 1 1 569D2218
P 6060 4620
F 0 "R10" V 6140 4620 50  0000 C CNN
F 1 "0R22 (OPT)" V 5960 4470 50  0000 C CNN
F 2 "Resistors_ThroughHole:Resistor_Cement_KOA-BGR-3N" V 5990 4620 30  0001 C CNN
F 3 "" H 6060 4620 30  0000 C CNN
	1    6060 4620
	0    1    1    0   
$EndComp
$Comp
L GND #PWR08
U 1 1 569D2219
P 5710 5470
F 0 "#PWR08" H 5710 5220 50  0001 C CNN
F 1 "GND" H 5710 5320 50  0000 C CNN
F 2 "" H 5710 5470 60  0000 C CNN
F 3 "" H 5710 5470 60  0000 C CNN
	1    5710 5470
	1    0    0    -1  
$EndComp
Wire Wire Line
	3910 5020 4860 5020
Wire Wire Line
	4010 4470 4010 5020
Connection ~ 4010 5020
$Comp
L R R6
U 1 1 569D221A
P 4710 4020
F 0 "R6" V 4790 4020 50  0000 C CNN
F 1 "820R" V 4710 4020 50  0000 C CNN
F 2 "Resistors_ThroughHole:Resistor_Horizontal_RM10mm" V 4640 4020 30  0001 C CNN
F 3 "" H 4710 4020 30  0000 C CNN
	1    4710 4020
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR09
U 1 1 569D221B
P 4710 4720
F 0 "#PWR09" H 4710 4470 50  0001 C CNN
F 1 "GND" H 4710 4570 50  0000 C CNN
F 2 "" H 4710 4720 60  0000 C CNN
F 3 "" H 4710 4720 60  0000 C CNN
	1    4710 4720
	1    0    0    -1  
$EndComp
Wire Wire Line
	4710 4670 4710 4720
$Comp
L +9V #PWR010
U 1 1 569D221C
P 4710 3820
F 0 "#PWR010" H 4710 3670 50  0001 C CNN
F 1 "+9V" H 4710 3960 50  0000 C CNN
F 2 "" H 4710 3820 60  0000 C CNN
F 3 "" H 4710 3820 60  0000 C CNN
	1    4710 3820
	1    0    0    -1  
$EndComp
Wire Wire Line
	4710 3820 4710 3870
$Comp
L R R8
U 1 1 569D221D
P 4210 4470
F 0 "R8" V 4290 4470 50  0000 C CNN
F 1 "43K" V 4210 4470 50  0000 C CNN
F 2 "Resistors_ThroughHole:Resistor_Horizontal_RM10mm" V 4140 4470 30  0001 C CNN
F 3 "" H 4210 4470 30  0000 C CNN
	1    4210 4470
	0    1    1    0   
$EndComp
Wire Wire Line
	4410 4470 4360 4470
Wire Wire Line
	4060 4470 4010 4470
$Comp
L R R7
U 1 1 569D221E
P 6710 4020
F 0 "R7" V 6790 4020 50  0000 C CNN
F 1 "820R" V 6710 4020 50  0000 C CNN
F 2 "Resistors_ThroughHole:Resistor_Horizontal_RM10mm" V 6640 4020 30  0001 C CNN
F 3 "" H 6710 4020 30  0000 C CNN
	1    6710 4020
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR011
U 1 1 569D221F
P 6710 4720
F 0 "#PWR011" H 6710 4470 50  0001 C CNN
F 1 "GND" H 6710 4570 50  0000 C CNN
F 2 "" H 6710 4720 60  0000 C CNN
F 3 "" H 6710 4720 60  0000 C CNN
	1    6710 4720
	1    0    0    -1  
$EndComp
$Comp
L +9V #PWR012
U 1 1 569D2220
P 6710 3820
F 0 "#PWR012" H 6710 3670 50  0001 C CNN
F 1 "+9V" H 6710 3960 50  0000 C CNN
F 2 "" H 6710 3820 60  0000 C CNN
F 3 "" H 6710 3820 60  0000 C CNN
	1    6710 3820
	1    0    0    -1  
$EndComp
$Comp
L R R9
U 1 1 569D2221
P 7210 4470
F 0 "R9" V 7290 4470 50  0000 C CNN
F 1 "43K" V 7210 4470 50  0000 C CNN
F 2 "Resistors_ThroughHole:Resistor_Horizontal_RM10mm" V 7140 4470 30  0001 C CNN
F 3 "" H 7210 4470 30  0000 C CNN
	1    7210 4470
	0    1    1    0   
$EndComp
Wire Wire Line
	6710 4670 6710 4720
Wire Wire Line
	7010 4470 7060 4470
Wire Wire Line
	7360 4470 7410 4470
Wire Wire Line
	7410 4470 7410 5020
Wire Wire Line
	4710 4170 4710 4270
Wire Wire Line
	4860 4220 4860 4320
Wire Wire Line
	6610 4320 6610 4220
Wire Wire Line
	6710 3870 6710 3820
Wire Wire Line
	6710 4170 6710 4270
Wire Wire Line
	6610 4220 6710 4220
Connection ~ 6710 4220
Wire Wire Line
	6610 5020 8270 5020
Connection ~ 7410 5020
Wire Wire Line
	5710 4620 5910 4620
Wire Wire Line
	6210 4620 6310 4620
$Comp
L Q_NPN_ECB Q9
U 1 1 569D2222
P 4610 4470
F 0 "Q9" H 4510 4620 50  0000 R CNN
F 1 "2N3704" H 4710 4320 50  0000 R CNN
F 2 "Transistors_OldSowjetAera:OldSowjetaera_Transistor_Type-I_BigPads" H 4810 4570 29  0001 C CNN
F 3 "" H 4610 4470 60  0000 C CNN
	1    4610 4470
	1    0    0    -1  
$EndComp
$Comp
L Q_NPN_ECB Q10
U 1 1 569D2223
P 6810 4470
F 0 "Q10" H 6760 4370 50  0000 R CNN
F 1 "2N3704" H 6810 4620 50  0000 R CNN
F 2 "Transistors_OldSowjetAera:OldSowjetaera_Transistor_Type-I_BigPads" H 7010 4570 29  0001 C CNN
F 3 "" H 6810 4470 60  0000 C CNN
	1    6810 4470
	-1   0    0    -1  
$EndComp
Wire Wire Line
	4860 4220 4710 4220
Connection ~ 4710 4220
$Comp
L D D6
U 1 1 569D2224
P 6110 4270
F 0 "D6" H 6110 4370 50  0000 C CNN
F 1 "SA5.0A" H 6110 4170 50  0000 C CNN
F 2 "Diodes_ThroughHole:Diode_DO-35_SOD27_Horizontal_RM10" H 6110 4270 60  0001 C CNN
F 3 "" H 6110 4270 60  0000 C CNN
	1    6110 4270
	0    1    1    0   
$EndComp
$Comp
L D D5
U 1 1 569D2225
P 5360 4270
F 0 "D5" H 5360 4370 50  0000 C CNN
F 1 "SA5.0A" H 5360 4420 50  0000 C CNN
F 2 "Diodes_ThroughHole:Diode_DO-35_SOD27_Horizontal_RM10" H 5360 4270 60  0001 C CNN
F 3 "" H 5360 4270 60  0000 C CNN
	1    5360 4270
	0    1    1    0   
$EndComp
$Comp
L D D7
U 1 1 569D2226
P 5360 4970
F 0 "D7" H 5410 5070 50  0000 C CNN
F 1 "SA5.0A" H 5460 5120 50  0000 C CNN
F 2 "Diodes_ThroughHole:Diode_DO-35_SOD27_Horizontal_RM10" H 5360 4970 60  0001 C CNN
F 3 "" H 5360 4970 60  0000 C CNN
	1    5360 4970
	0    1    1    0   
$EndComp
$Comp
L D D8
U 1 1 569D2227
P 6110 5020
F 0 "D8" H 6110 5120 50  0000 C CNN
F 1 "SA5.0A" H 6110 4920 50  0000 C CNN
F 2 "Diodes_ThroughHole:Diode_DO-35_SOD27_Horizontal_RM10" H 6110 5020 60  0001 C CNN
F 3 "" H 6110 5020 60  0000 C CNN
	1    6110 5020
	0    1    1    0   
$EndComp
Wire Wire Line
	5360 4420 5360 4820
Connection ~ 5360 4620
Wire Wire Line
	5360 5120 5360 5270
Connection ~ 5360 5270
Wire Wire Line
	5360 3970 5360 4120
Connection ~ 5360 3970
Wire Wire Line
	6110 5170 6110 5270
Connection ~ 6110 5270
Wire Wire Line
	6110 4870 6110 4870
Wire Wire Line
	6260 4720 6110 4870
Connection ~ 6260 4620
Wire Wire Line
	6110 4120 6110 3970
Connection ~ 6110 3970
Wire Wire Line
	6110 4420 6260 4570
Wire Wire Line
	6260 4570 6260 4720
$Comp
L GND #PWR013
U 1 1 569D3382
P 9730 3620
F 0 "#PWR013" H 9730 3370 50  0001 C CNN
F 1 "GND" H 9730 3470 50  0000 C CNN
F 2 "" H 9730 3620 60  0000 C CNN
F 3 "" H 9730 3620 60  0000 C CNN
	1    9730 3620
	1    0    0    -1  
$EndComp
$Comp
L +9V #PWR014
U 1 1 569D33F0
P 9420 2950
F 0 "#PWR014" H 9420 2800 50  0001 C CNN
F 1 "+9V" H 9420 3090 50  0000 C CNN
F 2 "" H 9420 2950 60  0000 C CNN
F 3 "" H 9420 2950 60  0000 C CNN
	1    9420 2950
	1    0    0    -1  
$EndComp
$Comp
L +5V #PWR015
U 1 1 569D345E
P 9620 2950
F 0 "#PWR015" H 9620 2800 50  0001 C CNN
F 1 "+5V" H 9620 3090 50  0000 C CNN
F 2 "" H 9620 2950 60  0000 C CNN
F 3 "" H 9620 2950 60  0000 C CNN
	1    9620 2950
	1    0    0    -1  
$EndComp
$Comp
L CONN_01X07 P1
U 1 1 569D3EE2
P 9930 3260
F 0 "P1" H 9930 3660 50  0000 C CNN
F 1 "CONN_01X07" V 10030 3260 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x07" H 9930 3260 50  0001 C CNN
F 3 "" H 9930 3260 50  0000 C CNN
	1    9930 3260
	1    0    0    -1  
$EndComp
Wire Wire Line
	9730 2960 9620 2960
Wire Wire Line
	9620 2960 9620 2950
Wire Wire Line
	9420 2950 9420 3060
Wire Wire Line
	9420 3060 9730 3060
Wire Wire Line
	9730 3560 9730 3620
Text Label 3860 2720 2    60   ~ 0
STEPPER1PHASEA1
Text Label 8260 2720 2    60   ~ 0
STEPPER1PHASEA2
Text Label 8270 5020 2    60   ~ 0
STEPPER1PHASEB2
Text Label 3910 5020 2    60   ~ 0
STEPPER1PHASEB1
$EndSCHEMATC
