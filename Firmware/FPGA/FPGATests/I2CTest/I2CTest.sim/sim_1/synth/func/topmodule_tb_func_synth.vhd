-- Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
-- Date        : Wed Jan 27 15:15:39 2016
-- Host        : ALI-WORKSTATION running 64-bit major release  (build 9200)
-- Command     : write_vhdl -mode funcsim -nolib -force -file
--               D:/GroupProject/WindTunnelApparatus/Firmware/FPGA/FPGATests/I2CTest/I2CTest.sim/sim_1/synth/func/topmodule_tb_func_synth.vhd
-- Design      : topmodule
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7a100tcsg324-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity STD_FIFO is
  port (
    D : out STD_LOGIC_VECTOR ( 7 downto 0 );
    FIFO_Empty : out STD_LOGIC;
    clk_IBUF_BUFG : in STD_LOGIC;
    Q : in STD_LOGIC_VECTOR ( 7 downto 0 );
    btnCpuReset_IBUF : in STD_LOGIC;
    FIFO_ReadEn : in STD_LOGIC;
    FIFO_WriteEn : in STD_LOGIC
  );
end STD_FIFO;

architecture STRUCTURE of STD_FIFO is
  signal Empty_i_10_n_0 : STD_LOGIC;
  signal Empty_i_1_n_0 : STD_LOGIC;
  signal Empty_i_2_n_0 : STD_LOGIC;
  signal Empty_i_3_n_0 : STD_LOGIC;
  signal Empty_i_4_n_0 : STD_LOGIC;
  signal Empty_i_5_n_0 : STD_LOGIC;
  signal Empty_i_6_n_0 : STD_LOGIC;
  signal Empty_i_7_n_0 : STD_LOGIC;
  signal Empty_i_8_n_0 : STD_LOGIC;
  signal Empty_i_9_n_0 : STD_LOGIC;
  signal \^fifo_empty\ : STD_LOGIC;
  signal Head : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \Head[0]_i_1_n_0\ : STD_LOGIC;
  signal \Head[1]_i_1_n_0\ : STD_LOGIC;
  signal \Head[2]_i_1_n_0\ : STD_LOGIC;
  signal \Head[3]_i_1_n_0\ : STD_LOGIC;
  signal \Head[4]_i_1_n_0\ : STD_LOGIC;
  signal \Head[5]_i_1_n_0\ : STD_LOGIC;
  signal \Head[5]_i_2_n_0\ : STD_LOGIC;
  signal \Head[5]_i_3_n_0\ : STD_LOGIC;
  signal \Head[5]_i_4_n_0\ : STD_LOGIC;
  signal \Head[5]_i_5_n_0\ : STD_LOGIC;
  signal \Head[6]_i_1_n_0\ : STD_LOGIC;
  signal \Head[7]_i_1_n_0\ : STD_LOGIC;
  signal \Head[7]_i_2_n_0\ : STD_LOGIC;
  signal Looped_i_1_n_0 : STD_LOGIC;
  signal Looped_reg_n_0 : STD_LOGIC;
  signal Memory_reg_i_10_n_0 : STD_LOGIC;
  signal Memory_reg_i_11_n_0 : STD_LOGIC;
  signal Memory_reg_i_12_n_0 : STD_LOGIC;
  signal Memory_reg_i_13_n_0 : STD_LOGIC;
  signal Memory_reg_i_14_n_0 : STD_LOGIC;
  signal Memory_reg_i_15_n_0 : STD_LOGIC;
  signal Memory_reg_i_1_n_0 : STD_LOGIC;
  signal Memory_reg_i_2_n_0 : STD_LOGIC;
  signal Memory_reg_i_3_n_0 : STD_LOGIC;
  signal Memory_reg_i_4_n_0 : STD_LOGIC;
  signal Memory_reg_i_5_n_0 : STD_LOGIC;
  signal Memory_reg_i_6_n_0 : STD_LOGIC;
  signal Memory_reg_i_7_n_0 : STD_LOGIC;
  signal Memory_reg_i_8_n_0 : STD_LOGIC;
  signal Memory_reg_i_9_n_0 : STD_LOGIC;
  signal Tail : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \Tail[0]_i_1_n_0\ : STD_LOGIC;
  signal \Tail[1]_i_1_n_0\ : STD_LOGIC;
  signal \Tail[2]_i_1_n_0\ : STD_LOGIC;
  signal \Tail[3]_i_1_n_0\ : STD_LOGIC;
  signal \Tail[4]_i_1_n_0\ : STD_LOGIC;
  signal \Tail[4]_i_2_n_0\ : STD_LOGIC;
  signal \Tail[4]_i_3_n_0\ : STD_LOGIC;
  signal \Tail[4]_i_4_n_0\ : STD_LOGIC;
  signal \Tail[4]_i_5_n_0\ : STD_LOGIC;
  signal \Tail[5]_i_1_n_0\ : STD_LOGIC;
  signal \Tail[5]_i_2_n_0\ : STD_LOGIC;
  signal \Tail[6]_i_1_n_0\ : STD_LOGIC;
  signal \Tail[6]_i_2_n_0\ : STD_LOGIC;
  signal \Tail[7]_i_1_n_0\ : STD_LOGIC;
  signal NLW_Memory_reg_DOADO_UNCONNECTED : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal NLW_Memory_reg_DOBDO_UNCONNECTED : STD_LOGIC_VECTOR ( 15 downto 8 );
  signal NLW_Memory_reg_DOPADOP_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_Memory_reg_DOPBDOP_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of Empty_i_10 : label is "soft_lutpair22";
  attribute SOFT_HLUTNM of Empty_i_4 : label is "soft_lutpair19";
  attribute SOFT_HLUTNM of Empty_i_7 : label is "soft_lutpair23";
  attribute SOFT_HLUTNM of Empty_i_8 : label is "soft_lutpair18";
  attribute SOFT_HLUTNM of \Head[0]_i_1\ : label is "soft_lutpair23";
  attribute SOFT_HLUTNM of \Head[2]_i_1\ : label is "soft_lutpair20";
  attribute SOFT_HLUTNM of \Head[3]_i_1\ : label is "soft_lutpair20";
  attribute SOFT_HLUTNM of \Head[5]_i_1\ : label is "soft_lutpair18";
  attribute SOFT_HLUTNM of \Head[5]_i_2\ : label is "soft_lutpair22";
  attribute SOFT_HLUTNM of \Head[5]_i_5\ : label is "soft_lutpair19";
  attribute SOFT_HLUTNM of \Head[6]_i_1\ : label is "soft_lutpair24";
  attribute SOFT_HLUTNM of \Head[7]_i_1\ : label is "soft_lutpair24";
  attribute CLOCK_DOMAINS : string;
  attribute CLOCK_DOMAINS of Memory_reg : label is "COMMON";
  attribute METHODOLOGY_DRC_VIOS : string;
  attribute METHODOLOGY_DRC_VIOS of Memory_reg : label is "{SYNTH-6 {cell *THIS*}}";
  attribute RTL_RAM_BITS : integer;
  attribute RTL_RAM_BITS of Memory_reg : label is 2048;
  attribute RTL_RAM_NAME : string;
  attribute RTL_RAM_NAME of Memory_reg : label is "Memory";
  attribute bram_addr_begin : integer;
  attribute bram_addr_begin of Memory_reg : label is 0;
  attribute bram_addr_end : integer;
  attribute bram_addr_end of Memory_reg : label is 1023;
  attribute bram_slice_begin : integer;
  attribute bram_slice_begin of Memory_reg : label is 0;
  attribute bram_slice_end : integer;
  attribute bram_slice_end of Memory_reg : label is 17;
  attribute SOFT_HLUTNM of Memory_reg_i_15 : label is "soft_lutpair21";
  attribute SOFT_HLUTNM of Memory_reg_i_7 : label is "soft_lutpair16";
  attribute SOFT_HLUTNM of \Tail[1]_i_1\ : label is "soft_lutpair17";
  attribute SOFT_HLUTNM of \Tail[2]_i_1\ : label is "soft_lutpair17";
  attribute SOFT_HLUTNM of \Tail[4]_i_2\ : label is "soft_lutpair21";
  attribute SOFT_HLUTNM of \Tail[4]_i_3\ : label is "soft_lutpair16";
begin
  FIFO_Empty <= \^fifo_empty\;
Empty_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FF23"
    )
        port map (
      I0 => \^fifo_empty\,
      I1 => Empty_i_2_n_0,
      I2 => Looped_i_1_n_0,
      I3 => btnCpuReset_IBUF,
      O => Empty_i_1_n_0
    );
Empty_i_10: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => Head(2),
      I1 => Head(0),
      I2 => Head(1),
      I3 => Head(3),
      O => Empty_i_10_n_0
    );
Empty_i_2: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFFFFFFFEFF"
    )
        port map (
      I0 => Empty_i_3_n_0,
      I1 => Empty_i_4_n_0,
      I2 => Empty_i_5_n_0,
      I3 => Empty_i_6_n_0,
      I4 => Empty_i_7_n_0,
      I5 => Empty_i_8_n_0,
      O => Empty_i_2_n_0
    );
Empty_i_3: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAE6FF7FFF7FAAE6"
    )
        port map (
      I0 => Empty_i_9_n_0,
      I1 => Memory_reg_i_1_n_0,
      I2 => Head(6),
      I3 => \Head[7]_i_2_n_0\,
      I4 => Head(7),
      I5 => \Tail[7]_i_1_n_0\,
      O => Empty_i_3_n_0
    );
Empty_i_4: unisim.vcomponents.LUT5
    generic map(
      INIT => X"6A95956A"
    )
        port map (
      I0 => Tail(0),
      I1 => FIFO_ReadEn,
      I2 => Memory_reg_i_9_n_0,
      I3 => Memory_reg_i_1_n_0,
      I4 => Head(0),
      O => Empty_i_4_n_0
    );
Empty_i_5: unisim.vcomponents.LUT6
    generic map(
      INIT => X"F6666FFF9FFFF666"
    )
        port map (
      I0 => Head(2),
      I1 => \Tail[2]_i_1_n_0\,
      I2 => Head(0),
      I3 => Memory_reg_i_1_n_0,
      I4 => Head(1),
      I5 => \Tail[1]_i_1_n_0\,
      O => Empty_i_5_n_0
    );
Empty_i_6: unisim.vcomponents.LUT6
    generic map(
      INIT => X"6999999999999999"
    )
        port map (
      I0 => \Tail[3]_i_1_n_0\,
      I1 => Head(3),
      I2 => Memory_reg_i_1_n_0,
      I3 => Head(1),
      I4 => Head(0),
      I5 => Head(2),
      O => Empty_i_6_n_0
    );
Empty_i_7: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9666"
    )
        port map (
      I0 => \Tail[4]_i_1_n_0\,
      I1 => Head(4),
      I2 => Memory_reg_i_1_n_0,
      I3 => Empty_i_10_n_0,
      O => Empty_i_7_n_0
    );
Empty_i_8: unisim.vcomponents.LUT5
    generic map(
      INIT => X"65559AAA"
    )
        port map (
      I0 => \Tail[5]_i_1_n_0\,
      I1 => \Head[5]_i_3_n_0\,
      I2 => \Head[5]_i_2_n_0\,
      I3 => FIFO_WriteEn,
      I4 => Head(5),
      O => Empty_i_8_n_0
    );
Empty_i_9: unisim.vcomponents.LUT6
    generic map(
      INIT => X"6666966666666666"
    )
        port map (
      I0 => Head(6),
      I1 => Tail(6),
      I2 => Memory_reg_i_9_n_0,
      I3 => FIFO_ReadEn,
      I4 => \Tail[6]_i_2_n_0\,
      I5 => Tail(5),
      O => Empty_i_9_n_0
    );
Empty_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '1'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => Empty_i_1_n_0,
      Q => \^fifo_empty\,
      R => '0'
    );
\Head[0]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => Head(0),
      I1 => Memory_reg_i_1_n_0,
      O => \Head[0]_i_1_n_0\
    );
\Head[1]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"78"
    )
        port map (
      I0 => Head(0),
      I1 => Memory_reg_i_1_n_0,
      I2 => Head(1),
      O => \Head[1]_i_1_n_0\
    );
\Head[2]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"7F80"
    )
        port map (
      I0 => Head(1),
      I1 => Head(0),
      I2 => Memory_reg_i_1_n_0,
      I3 => Head(2),
      O => \Head[2]_i_1_n_0\
    );
\Head[3]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"7FFF8000"
    )
        port map (
      I0 => Head(2),
      I1 => Head(0),
      I2 => Head(1),
      I3 => Memory_reg_i_1_n_0,
      I4 => Head(3),
      O => \Head[3]_i_1_n_0\
    );
\Head[4]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"7FFFFFFF80000000"
    )
        port map (
      I0 => Head(3),
      I1 => Head(1),
      I2 => Head(0),
      I3 => Head(2),
      I4 => Memory_reg_i_1_n_0,
      I5 => Head(4),
      O => \Head[4]_i_1_n_0\
    );
\Head[5]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"AA6A"
    )
        port map (
      I0 => Head(5),
      I1 => FIFO_WriteEn,
      I2 => \Head[5]_i_2_n_0\,
      I3 => \Head[5]_i_3_n_0\,
      O => \Head[5]_i_1_n_0\
    );
\Head[5]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => Head(4),
      I1 => Head(3),
      I2 => Head(1),
      I3 => Head(0),
      I4 => Head(2),
      O => \Head[5]_i_2_n_0\
    );
\Head[5]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000000000002"
    )
        port map (
      I0 => Memory_reg_i_8_n_0,
      I1 => Memory_reg_i_7_n_0,
      I2 => Memory_reg_i_6_n_0,
      I3 => Memory_reg_i_5_n_0,
      I4 => \Head[5]_i_4_n_0\,
      I5 => \Head[5]_i_5_n_0\,
      O => \Head[5]_i_3_n_0\
    );
\Head[5]_i_4\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"EAAABFFF7FFFEAAA"
    )
        port map (
      I0 => Memory_reg_i_14_n_0,
      I1 => FIFO_ReadEn,
      I2 => Memory_reg_i_9_n_0,
      I3 => Tail(0),
      I4 => Tail(1),
      I5 => Head(1),
      O => \Head[5]_i_4_n_0\
    );
\Head[5]_i_5\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"956A"
    )
        port map (
      I0 => Head(0),
      I1 => Memory_reg_i_9_n_0,
      I2 => FIFO_ReadEn,
      I3 => Tail(0),
      O => \Head[5]_i_5_n_0\
    );
\Head[6]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"D2"
    )
        port map (
      I0 => Memory_reg_i_1_n_0,
      I1 => \Head[7]_i_2_n_0\,
      I2 => Head(6),
      O => \Head[6]_i_1_n_0\
    );
\Head[7]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"F708"
    )
        port map (
      I0 => Memory_reg_i_1_n_0,
      I1 => Head(6),
      I2 => \Head[7]_i_2_n_0\,
      I3 => Head(7),
      O => \Head[7]_i_1_n_0\
    );
\Head[7]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"7FFFFFFFFFFFFFFF"
    )
        port map (
      I0 => Head(5),
      I1 => Head(2),
      I2 => Head(0),
      I3 => Head(1),
      I4 => Head(3),
      I5 => Head(4),
      O => \Head[7]_i_2_n_0\
    );
\Head_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \Head[0]_i_1_n_0\,
      Q => Head(0),
      R => btnCpuReset_IBUF
    );
\Head_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \Head[1]_i_1_n_0\,
      Q => Head(1),
      R => btnCpuReset_IBUF
    );
\Head_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \Head[2]_i_1_n_0\,
      Q => Head(2),
      R => btnCpuReset_IBUF
    );
\Head_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \Head[3]_i_1_n_0\,
      Q => Head(3),
      R => btnCpuReset_IBUF
    );
\Head_reg[4]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \Head[4]_i_1_n_0\,
      Q => Head(4),
      R => btnCpuReset_IBUF
    );
\Head_reg[5]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \Head[5]_i_1_n_0\,
      Q => Head(5),
      R => btnCpuReset_IBUF
    );
\Head_reg[6]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \Head[6]_i_1_n_0\,
      Q => Head(6),
      R => btnCpuReset_IBUF
    );
\Head_reg[7]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \Head[7]_i_1_n_0\,
      Q => Head(7),
      R => btnCpuReset_IBUF
    );
Looped_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"AEAAAAAA"
    )
        port map (
      I0 => Memory_reg_i_8_n_0,
      I1 => Head(6),
      I2 => \Head[7]_i_2_n_0\,
      I3 => Head(7),
      I4 => FIFO_WriteEn,
      O => Looped_i_1_n_0
    );
Looped_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => Looped_i_1_n_0,
      Q => Looped_reg_n_0,
      R => btnCpuReset_IBUF
    );
Memory_reg: unisim.vcomponents.RAMB18E1
    generic map(
      DOA_REG => 0,
      DOB_REG => 0,
      INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_10 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_11 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_12 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_13 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_14 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_15 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_16 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_17 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_18 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_19 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_A => X"00000",
      INIT_B => X"00000",
      INIT_FILE => "NONE",
      RAM_MODE => "TDP",
      RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
      READ_WIDTH_A => 18,
      READ_WIDTH_B => 18,
      RSTREG_PRIORITY_A => "RSTREG",
      RSTREG_PRIORITY_B => "RSTREG",
      SIM_COLLISION_CHECK => "ALL",
      SIM_DEVICE => "7SERIES",
      SRVAL_A => X"00000",
      SRVAL_B => X"00000",
      WRITE_MODE_A => "READ_FIRST",
      WRITE_MODE_B => "WRITE_FIRST",
      WRITE_WIDTH_A => 18,
      WRITE_WIDTH_B => 18
    )
        port map (
      ADDRARDADDR(13 downto 12) => B"11",
      ADDRARDADDR(11 downto 4) => Head(7 downto 0),
      ADDRARDADDR(3 downto 0) => B"1111",
      ADDRBWRADDR(13 downto 12) => B"11",
      ADDRBWRADDR(11 downto 4) => Tail(7 downto 0),
      ADDRBWRADDR(3 downto 0) => B"1111",
      CLKARDCLK => clk_IBUF_BUFG,
      CLKBWRCLK => clk_IBUF_BUFG,
      DIADI(15 downto 8) => B"00000000",
      DIADI(7 downto 0) => Q(7 downto 0),
      DIBDI(15 downto 0) => B"0000000011111111",
      DIPADIP(1 downto 0) => B"00",
      DIPBDIP(1 downto 0) => B"00",
      DOADO(15 downto 0) => NLW_Memory_reg_DOADO_UNCONNECTED(15 downto 0),
      DOBDO(15 downto 8) => NLW_Memory_reg_DOBDO_UNCONNECTED(15 downto 8),
      DOBDO(7 downto 0) => D(7 downto 0),
      DOPADOP(1 downto 0) => NLW_Memory_reg_DOPADOP_UNCONNECTED(1 downto 0),
      DOPBDOP(1 downto 0) => NLW_Memory_reg_DOPBDOP_UNCONNECTED(1 downto 0),
      ENARDEN => Memory_reg_i_1_n_0,
      ENBWREN => Memory_reg_i_2_n_0,
      REGCEAREGCE => '0',
      REGCEB => '0',
      RSTRAMARSTRAM => '0',
      RSTRAMB => '0',
      RSTREGARSTREG => '0',
      RSTREGB => '0',
      WEA(1) => Memory_reg_i_3_n_0,
      WEA(0) => Memory_reg_i_3_n_0,
      WEBWE(3 downto 0) => B"0000"
    );
Memory_reg_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAAAAAA8AAAAAAAA"
    )
        port map (
      I0 => FIFO_WriteEn,
      I1 => Memory_reg_i_4_n_0,
      I2 => Memory_reg_i_5_n_0,
      I3 => Memory_reg_i_6_n_0,
      I4 => Memory_reg_i_7_n_0,
      I5 => Memory_reg_i_8_n_0,
      O => Memory_reg_i_1_n_0
    );
Memory_reg_i_10: unisim.vcomponents.LUT5
    generic map(
      INIT => X"55555557"
    )
        port map (
      I0 => FIFO_ReadEn,
      I1 => \Tail[4]_i_5_n_0\,
      I2 => \Tail[4]_i_4_n_0\,
      I3 => \Tail[4]_i_3_n_0\,
      I4 => Looped_reg_n_0,
      O => Memory_reg_i_10_n_0
    );
Memory_reg_i_11: unisim.vcomponents.LUT6
    generic map(
      INIT => X"999999999999999A"
    )
        port map (
      I0 => Memory_reg_i_14_n_0,
      I1 => Memory_reg_i_15_n_0,
      I2 => Looped_reg_n_0,
      I3 => \Tail[4]_i_3_n_0\,
      I4 => \Tail[4]_i_4_n_0\,
      I5 => \Tail[4]_i_5_n_0\,
      O => Memory_reg_i_11_n_0
    );
Memory_reg_i_12: unisim.vcomponents.LUT6
    generic map(
      INIT => X"2222222222222220"
    )
        port map (
      I0 => Tail(5),
      I1 => \Tail[5]_i_2_n_0\,
      I2 => Looped_reg_n_0,
      I3 => \Tail[4]_i_3_n_0\,
      I4 => \Tail[4]_i_4_n_0\,
      I5 => \Tail[4]_i_5_n_0\,
      O => Memory_reg_i_12_n_0
    );
Memory_reg_i_13: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => Tail(6),
      I1 => Head(6),
      O => Memory_reg_i_13_n_0
    );
Memory_reg_i_14: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => Tail(2),
      I1 => Head(2),
      O => Memory_reg_i_14_n_0
    );
Memory_reg_i_15: unisim.vcomponents.LUT3
    generic map(
      INIT => X"7F"
    )
        port map (
      I0 => Tail(1),
      I1 => Tail(0),
      I2 => FIFO_ReadEn,
      O => Memory_reg_i_15_n_0
    );
Memory_reg_i_2: unisim.vcomponents.LUT3
    generic map(
      INIT => X"40"
    )
        port map (
      I0 => btnCpuReset_IBUF,
      I1 => Memory_reg_i_9_n_0,
      I2 => FIFO_ReadEn,
      O => Memory_reg_i_2_n_0
    );
Memory_reg_i_3: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => btnCpuReset_IBUF,
      O => Memory_reg_i_3_n_0
    );
Memory_reg_i_4: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFF7DBEEB7D"
    )
        port map (
      I0 => Head(0),
      I1 => Head(1),
      I2 => Tail(1),
      I3 => Tail(0),
      I4 => Memory_reg_i_10_n_0,
      I5 => Memory_reg_i_11_n_0,
      O => Memory_reg_i_4_n_0
    );
Memory_reg_i_5: unisim.vcomponents.LUT4
    generic map(
      INIT => X"6FF6"
    )
        port map (
      I0 => \Tail[4]_i_1_n_0\,
      I1 => Head(4),
      I2 => \Tail[5]_i_1_n_0\,
      I3 => Head(5),
      O => Memory_reg_i_5_n_0
    );
Memory_reg_i_6: unisim.vcomponents.LUT6
    generic map(
      INIT => X"655555559AAAAAAA"
    )
        port map (
      I0 => Head(3),
      I1 => Memory_reg_i_10_n_0,
      I2 => Tail(1),
      I3 => Tail(0),
      I4 => Tail(2),
      I5 => Tail(3),
      O => Memory_reg_i_6_n_0
    );
Memory_reg_i_7: unisim.vcomponents.LUT5
    generic map(
      INIT => X"F66F9FF6"
    )
        port map (
      I0 => Tail(7),
      I1 => Head(7),
      I2 => Memory_reg_i_12_n_0,
      I3 => Tail(6),
      I4 => Head(6),
      O => Memory_reg_i_7_n_0
    );
Memory_reg_i_8: unisim.vcomponents.LUT6
    generic map(
      INIT => X"8AAAAAAAAAAAAAAA"
    )
        port map (
      I0 => Looped_reg_n_0,
      I1 => \Tail[6]_i_2_n_0\,
      I2 => Tail(6),
      I3 => Tail(5),
      I4 => Tail(7),
      I5 => FIFO_ReadEn,
      O => Memory_reg_i_8_n_0
    );
Memory_reg_i_9: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFFFFFFEFFE"
    )
        port map (
      I0 => Looped_reg_n_0,
      I1 => Memory_reg_i_13_n_0,
      I2 => Head(7),
      I3 => Tail(7),
      I4 => \Tail[4]_i_4_n_0\,
      I5 => \Tail[4]_i_5_n_0\,
      O => Memory_reg_i_9_n_0
    );
\Tail[0]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"6A"
    )
        port map (
      I0 => Tail(0),
      I1 => FIFO_ReadEn,
      I2 => Memory_reg_i_9_n_0,
      O => \Tail[0]_i_1_n_0\
    );
\Tail[1]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"7F80"
    )
        port map (
      I0 => FIFO_ReadEn,
      I1 => Memory_reg_i_9_n_0,
      I2 => Tail(0),
      I3 => Tail(1),
      O => \Tail[1]_i_1_n_0\
    );
\Tail[2]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"6AAAAAAA"
    )
        port map (
      I0 => Tail(2),
      I1 => Tail(1),
      I2 => Tail(0),
      I3 => FIFO_ReadEn,
      I4 => Memory_reg_i_9_n_0,
      O => \Tail[2]_i_1_n_0\
    );
\Tail[3]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"6AAAAAAAAAAAAAAA"
    )
        port map (
      I0 => Tail(3),
      I1 => Tail(2),
      I2 => Tail(0),
      I3 => Tail(1),
      I4 => Memory_reg_i_9_n_0,
      I5 => FIFO_ReadEn,
      O => \Tail[3]_i_1_n_0\
    );
\Tail[4]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"999999999999999A"
    )
        port map (
      I0 => Tail(4),
      I1 => \Tail[4]_i_2_n_0\,
      I2 => Looped_reg_n_0,
      I3 => \Tail[4]_i_3_n_0\,
      I4 => \Tail[4]_i_4_n_0\,
      I5 => \Tail[4]_i_5_n_0\,
      O => \Tail[4]_i_1_n_0\
    );
\Tail[4]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"7FFFFFFF"
    )
        port map (
      I0 => Tail(3),
      I1 => Tail(1),
      I2 => Tail(0),
      I3 => Tail(2),
      I4 => FIFO_ReadEn,
      O => \Tail[4]_i_2_n_0\
    );
\Tail[4]_i_3\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"6FF6"
    )
        port map (
      I0 => Head(6),
      I1 => Tail(6),
      I2 => Head(7),
      I3 => Tail(7),
      O => \Tail[4]_i_3_n_0\
    );
\Tail[4]_i_4\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"6FF6FFFFFFFF6FF6"
    )
        port map (
      I0 => Head(3),
      I1 => Tail(3),
      I2 => Tail(4),
      I3 => Head(4),
      I4 => Tail(5),
      I5 => Head(5),
      O => \Tail[4]_i_4_n_0\
    );
\Tail[4]_i_5\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"6FF6FFFFFFFF6FF6"
    )
        port map (
      I0 => Head(0),
      I1 => Tail(0),
      I2 => Tail(1),
      I3 => Head(1),
      I4 => Tail(2),
      I5 => Head(2),
      O => \Tail[4]_i_5_n_0\
    );
\Tail[5]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"999999999999999A"
    )
        port map (
      I0 => Tail(5),
      I1 => \Tail[5]_i_2_n_0\,
      I2 => Looped_reg_n_0,
      I3 => \Tail[4]_i_3_n_0\,
      I4 => \Tail[4]_i_4_n_0\,
      I5 => \Tail[4]_i_5_n_0\,
      O => \Tail[5]_i_1_n_0\
    );
\Tail[5]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"7FFFFFFFFFFFFFFF"
    )
        port map (
      I0 => Tail(4),
      I1 => Tail(2),
      I2 => Tail(0),
      I3 => Tail(1),
      I4 => Tail(3),
      I5 => FIFO_ReadEn,
      O => \Tail[5]_i_2_n_0\
    );
\Tail[6]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"AA6AAAAA"
    )
        port map (
      I0 => Tail(6),
      I1 => Memory_reg_i_9_n_0,
      I2 => FIFO_ReadEn,
      I3 => \Tail[6]_i_2_n_0\,
      I4 => Tail(5),
      O => \Tail[6]_i_1_n_0\
    );
\Tail[6]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"7FFFFFFF"
    )
        port map (
      I0 => Tail(3),
      I1 => Tail(1),
      I2 => Tail(0),
      I3 => Tail(2),
      I4 => Tail(4),
      O => \Tail[6]_i_2_n_0\
    );
\Tail[7]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AA6AAAAAAAAAAAAA"
    )
        port map (
      I0 => Tail(7),
      I1 => Tail(6),
      I2 => Tail(5),
      I3 => \Tail[6]_i_2_n_0\,
      I4 => FIFO_ReadEn,
      I5 => Memory_reg_i_9_n_0,
      O => \Tail[7]_i_1_n_0\
    );
\Tail_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \Tail[0]_i_1_n_0\,
      Q => Tail(0),
      R => btnCpuReset_IBUF
    );
\Tail_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \Tail[1]_i_1_n_0\,
      Q => Tail(1),
      R => btnCpuReset_IBUF
    );
\Tail_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \Tail[2]_i_1_n_0\,
      Q => Tail(2),
      R => btnCpuReset_IBUF
    );
\Tail_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \Tail[3]_i_1_n_0\,
      Q => Tail(3),
      R => btnCpuReset_IBUF
    );
\Tail_reg[4]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \Tail[4]_i_1_n_0\,
      Q => Tail(4),
      R => btnCpuReset_IBUF
    );
\Tail_reg[5]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \Tail[5]_i_1_n_0\,
      Q => Tail(5),
      R => btnCpuReset_IBUF
    );
\Tail_reg[6]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \Tail[6]_i_1_n_0\,
      Q => Tail(6),
      R => btnCpuReset_IBUF
    );
\Tail_reg[7]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \Tail[7]_i_1_n_0\,
      Q => Tail(7),
      R => btnCpuReset_IBUF
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity UART_TX_CTRL is
  port (
    RsTx_OBUF : out STD_LOGIC;
    \bitTmr_reg[13]_0\ : out STD_LOGIC;
    \bitTmr_reg[13]_1\ : out STD_LOGIC;
    clk_IBUF_BUFG : in STD_LOGIC;
    E : in STD_LOGIC_VECTOR ( 0 to 0 );
    D : in STD_LOGIC_VECTOR ( 7 downto 0 )
  );
end UART_TX_CTRL;

architecture STRUCTURE of UART_TX_CTRL is
  signal \bitIndex[0]_i_2_n_0\ : STD_LOGIC;
  signal \bitIndex[0]_i_3_n_0\ : STD_LOGIC;
  signal \bitIndex[0]_i_4_n_0\ : STD_LOGIC;
  signal \bitIndex[0]_i_5_n_0\ : STD_LOGIC;
  signal \bitIndex[12]_i_2_n_0\ : STD_LOGIC;
  signal \bitIndex[12]_i_3_n_0\ : STD_LOGIC;
  signal \bitIndex[12]_i_4_n_0\ : STD_LOGIC;
  signal \bitIndex[12]_i_5_n_0\ : STD_LOGIC;
  signal \bitIndex[16]_i_2_n_0\ : STD_LOGIC;
  signal \bitIndex[16]_i_3_n_0\ : STD_LOGIC;
  signal \bitIndex[16]_i_4_n_0\ : STD_LOGIC;
  signal \bitIndex[16]_i_5_n_0\ : STD_LOGIC;
  signal \bitIndex[20]_i_2_n_0\ : STD_LOGIC;
  signal \bitIndex[20]_i_3_n_0\ : STD_LOGIC;
  signal \bitIndex[20]_i_4_n_0\ : STD_LOGIC;
  signal \bitIndex[20]_i_5_n_0\ : STD_LOGIC;
  signal \bitIndex[24]_i_2_n_0\ : STD_LOGIC;
  signal \bitIndex[24]_i_3_n_0\ : STD_LOGIC;
  signal \bitIndex[24]_i_4_n_0\ : STD_LOGIC;
  signal \bitIndex[24]_i_5_n_0\ : STD_LOGIC;
  signal \bitIndex[28]_i_2_n_0\ : STD_LOGIC;
  signal \bitIndex[28]_i_3_n_0\ : STD_LOGIC;
  signal \bitIndex[28]_i_4_n_0\ : STD_LOGIC;
  signal \bitIndex[4]_i_2_n_0\ : STD_LOGIC;
  signal \bitIndex[4]_i_3_n_0\ : STD_LOGIC;
  signal \bitIndex[4]_i_4_n_0\ : STD_LOGIC;
  signal \bitIndex[4]_i_5_n_0\ : STD_LOGIC;
  signal \bitIndex[8]_i_2_n_0\ : STD_LOGIC;
  signal \bitIndex[8]_i_3_n_0\ : STD_LOGIC;
  signal \bitIndex[8]_i_4_n_0\ : STD_LOGIC;
  signal \bitIndex[8]_i_5_n_0\ : STD_LOGIC;
  signal bitIndex_reg : STD_LOGIC_VECTOR ( 30 downto 0 );
  signal \bitIndex_reg[0]_i_1_n_0\ : STD_LOGIC;
  signal \bitIndex_reg[0]_i_1_n_1\ : STD_LOGIC;
  signal \bitIndex_reg[0]_i_1_n_2\ : STD_LOGIC;
  signal \bitIndex_reg[0]_i_1_n_3\ : STD_LOGIC;
  signal \bitIndex_reg[0]_i_1_n_4\ : STD_LOGIC;
  signal \bitIndex_reg[0]_i_1_n_5\ : STD_LOGIC;
  signal \bitIndex_reg[0]_i_1_n_6\ : STD_LOGIC;
  signal \bitIndex_reg[0]_i_1_n_7\ : STD_LOGIC;
  signal \bitIndex_reg[12]_i_1_n_0\ : STD_LOGIC;
  signal \bitIndex_reg[12]_i_1_n_1\ : STD_LOGIC;
  signal \bitIndex_reg[12]_i_1_n_2\ : STD_LOGIC;
  signal \bitIndex_reg[12]_i_1_n_3\ : STD_LOGIC;
  signal \bitIndex_reg[12]_i_1_n_4\ : STD_LOGIC;
  signal \bitIndex_reg[12]_i_1_n_5\ : STD_LOGIC;
  signal \bitIndex_reg[12]_i_1_n_6\ : STD_LOGIC;
  signal \bitIndex_reg[12]_i_1_n_7\ : STD_LOGIC;
  signal \bitIndex_reg[16]_i_1_n_0\ : STD_LOGIC;
  signal \bitIndex_reg[16]_i_1_n_1\ : STD_LOGIC;
  signal \bitIndex_reg[16]_i_1_n_2\ : STD_LOGIC;
  signal \bitIndex_reg[16]_i_1_n_3\ : STD_LOGIC;
  signal \bitIndex_reg[16]_i_1_n_4\ : STD_LOGIC;
  signal \bitIndex_reg[16]_i_1_n_5\ : STD_LOGIC;
  signal \bitIndex_reg[16]_i_1_n_6\ : STD_LOGIC;
  signal \bitIndex_reg[16]_i_1_n_7\ : STD_LOGIC;
  signal \bitIndex_reg[20]_i_1_n_0\ : STD_LOGIC;
  signal \bitIndex_reg[20]_i_1_n_1\ : STD_LOGIC;
  signal \bitIndex_reg[20]_i_1_n_2\ : STD_LOGIC;
  signal \bitIndex_reg[20]_i_1_n_3\ : STD_LOGIC;
  signal \bitIndex_reg[20]_i_1_n_4\ : STD_LOGIC;
  signal \bitIndex_reg[20]_i_1_n_5\ : STD_LOGIC;
  signal \bitIndex_reg[20]_i_1_n_6\ : STD_LOGIC;
  signal \bitIndex_reg[20]_i_1_n_7\ : STD_LOGIC;
  signal \bitIndex_reg[24]_i_1_n_0\ : STD_LOGIC;
  signal \bitIndex_reg[24]_i_1_n_1\ : STD_LOGIC;
  signal \bitIndex_reg[24]_i_1_n_2\ : STD_LOGIC;
  signal \bitIndex_reg[24]_i_1_n_3\ : STD_LOGIC;
  signal \bitIndex_reg[24]_i_1_n_4\ : STD_LOGIC;
  signal \bitIndex_reg[24]_i_1_n_5\ : STD_LOGIC;
  signal \bitIndex_reg[24]_i_1_n_6\ : STD_LOGIC;
  signal \bitIndex_reg[24]_i_1_n_7\ : STD_LOGIC;
  signal \bitIndex_reg[28]_i_1_n_2\ : STD_LOGIC;
  signal \bitIndex_reg[28]_i_1_n_3\ : STD_LOGIC;
  signal \bitIndex_reg[28]_i_1_n_5\ : STD_LOGIC;
  signal \bitIndex_reg[28]_i_1_n_6\ : STD_LOGIC;
  signal \bitIndex_reg[28]_i_1_n_7\ : STD_LOGIC;
  signal \bitIndex_reg[4]_i_1_n_0\ : STD_LOGIC;
  signal \bitIndex_reg[4]_i_1_n_1\ : STD_LOGIC;
  signal \bitIndex_reg[4]_i_1_n_2\ : STD_LOGIC;
  signal \bitIndex_reg[4]_i_1_n_3\ : STD_LOGIC;
  signal \bitIndex_reg[4]_i_1_n_4\ : STD_LOGIC;
  signal \bitIndex_reg[4]_i_1_n_5\ : STD_LOGIC;
  signal \bitIndex_reg[4]_i_1_n_6\ : STD_LOGIC;
  signal \bitIndex_reg[4]_i_1_n_7\ : STD_LOGIC;
  signal \bitIndex_reg[8]_i_1_n_0\ : STD_LOGIC;
  signal \bitIndex_reg[8]_i_1_n_1\ : STD_LOGIC;
  signal \bitIndex_reg[8]_i_1_n_2\ : STD_LOGIC;
  signal \bitIndex_reg[8]_i_1_n_3\ : STD_LOGIC;
  signal \bitIndex_reg[8]_i_1_n_4\ : STD_LOGIC;
  signal \bitIndex_reg[8]_i_1_n_5\ : STD_LOGIC;
  signal \bitIndex_reg[8]_i_1_n_6\ : STD_LOGIC;
  signal \bitIndex_reg[8]_i_1_n_7\ : STD_LOGIC;
  signal \bitTmr[0]_i_1_n_0\ : STD_LOGIC;
  signal \bitTmr[0]_i_3_n_0\ : STD_LOGIC;
  signal \bitTmr[0]_i_4_n_0\ : STD_LOGIC;
  signal \bitTmr[0]_i_5_n_0\ : STD_LOGIC;
  signal \bitTmr[0]_i_6_n_0\ : STD_LOGIC;
  signal \bitTmr[12]_i_2_n_0\ : STD_LOGIC;
  signal \bitTmr[12]_i_3_n_0\ : STD_LOGIC;
  signal \bitTmr[4]_i_2_n_0\ : STD_LOGIC;
  signal \bitTmr[4]_i_3_n_0\ : STD_LOGIC;
  signal \bitTmr[4]_i_4_n_0\ : STD_LOGIC;
  signal \bitTmr[4]_i_5_n_0\ : STD_LOGIC;
  signal \bitTmr[8]_i_2_n_0\ : STD_LOGIC;
  signal \bitTmr[8]_i_3_n_0\ : STD_LOGIC;
  signal \bitTmr[8]_i_4_n_0\ : STD_LOGIC;
  signal \bitTmr[8]_i_5_n_0\ : STD_LOGIC;
  signal bitTmr_reg : STD_LOGIC_VECTOR ( 13 downto 0 );
  signal \bitTmr_reg[0]_i_2_n_0\ : STD_LOGIC;
  signal \bitTmr_reg[0]_i_2_n_1\ : STD_LOGIC;
  signal \bitTmr_reg[0]_i_2_n_2\ : STD_LOGIC;
  signal \bitTmr_reg[0]_i_2_n_3\ : STD_LOGIC;
  signal \bitTmr_reg[0]_i_2_n_4\ : STD_LOGIC;
  signal \bitTmr_reg[0]_i_2_n_5\ : STD_LOGIC;
  signal \bitTmr_reg[0]_i_2_n_6\ : STD_LOGIC;
  signal \bitTmr_reg[0]_i_2_n_7\ : STD_LOGIC;
  signal \bitTmr_reg[12]_i_1_n_3\ : STD_LOGIC;
  signal \bitTmr_reg[12]_i_1_n_6\ : STD_LOGIC;
  signal \bitTmr_reg[12]_i_1_n_7\ : STD_LOGIC;
  signal \^bittmr_reg[13]_0\ : STD_LOGIC;
  signal \^bittmr_reg[13]_1\ : STD_LOGIC;
  signal \bitTmr_reg[4]_i_1_n_0\ : STD_LOGIC;
  signal \bitTmr_reg[4]_i_1_n_1\ : STD_LOGIC;
  signal \bitTmr_reg[4]_i_1_n_2\ : STD_LOGIC;
  signal \bitTmr_reg[4]_i_1_n_3\ : STD_LOGIC;
  signal \bitTmr_reg[4]_i_1_n_4\ : STD_LOGIC;
  signal \bitTmr_reg[4]_i_1_n_5\ : STD_LOGIC;
  signal \bitTmr_reg[4]_i_1_n_6\ : STD_LOGIC;
  signal \bitTmr_reg[4]_i_1_n_7\ : STD_LOGIC;
  signal \bitTmr_reg[8]_i_1_n_0\ : STD_LOGIC;
  signal \bitTmr_reg[8]_i_1_n_1\ : STD_LOGIC;
  signal \bitTmr_reg[8]_i_1_n_2\ : STD_LOGIC;
  signal \bitTmr_reg[8]_i_1_n_3\ : STD_LOGIC;
  signal \bitTmr_reg[8]_i_1_n_4\ : STD_LOGIC;
  signal \bitTmr_reg[8]_i_1_n_5\ : STD_LOGIC;
  signal \bitTmr_reg[8]_i_1_n_6\ : STD_LOGIC;
  signal \bitTmr_reg[8]_i_1_n_7\ : STD_LOGIC;
  signal ready : STD_LOGIC;
  signal txBit_i_2_n_0 : STD_LOGIC;
  signal txBit_i_3_n_0 : STD_LOGIC;
  signal txBit_i_5_n_0 : STD_LOGIC;
  signal txBit_i_6_n_0 : STD_LOGIC;
  signal txBit_reg_i_4_n_0 : STD_LOGIC;
  signal txData : STD_LOGIC_VECTOR ( 8 downto 1 );
  signal \txState[0]_i_1_n_0\ : STD_LOGIC;
  signal \txState[0]_i_2_n_0\ : STD_LOGIC;
  signal \txState[0]_i_3_n_0\ : STD_LOGIC;
  signal \txState[0]_i_4_n_0\ : STD_LOGIC;
  signal \txState[0]_i_5_n_0\ : STD_LOGIC;
  signal \txState[0]_i_6_n_0\ : STD_LOGIC;
  signal \txState[0]_i_7_n_0\ : STD_LOGIC;
  signal \txState[0]_i_8_n_0\ : STD_LOGIC;
  signal \txState[0]_i_9_n_0\ : STD_LOGIC;
  signal \txState[1]_i_1_n_0\ : STD_LOGIC;
  signal \txState[1]_i_2_n_0\ : STD_LOGIC;
  signal \txState[1]_i_3_n_0\ : STD_LOGIC;
  signal \txState[1]_i_4_n_0\ : STD_LOGIC;
  signal \NLW_bitIndex_reg[28]_i_1_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 2 );
  signal \NLW_bitIndex_reg[28]_i_1_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 to 3 );
  signal \NLW_bitTmr_reg[12]_i_1_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 1 );
  signal \NLW_bitTmr_reg[12]_i_1_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 2 );
begin
  \bitTmr_reg[13]_0\ <= \^bittmr_reg[13]_0\;
  \bitTmr_reg[13]_1\ <= \^bittmr_reg[13]_1\;
\bitIndex[0]_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(3),
      O => \bitIndex[0]_i_2_n_0\
    );
\bitIndex[0]_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(2),
      O => \bitIndex[0]_i_3_n_0\
    );
\bitIndex[0]_i_4\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(1),
      O => \bitIndex[0]_i_4_n_0\
    );
\bitIndex[0]_i_5\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => bitIndex_reg(0),
      O => \bitIndex[0]_i_5_n_0\
    );
\bitIndex[12]_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(15),
      O => \bitIndex[12]_i_2_n_0\
    );
\bitIndex[12]_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(14),
      O => \bitIndex[12]_i_3_n_0\
    );
\bitIndex[12]_i_4\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(13),
      O => \bitIndex[12]_i_4_n_0\
    );
\bitIndex[12]_i_5\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(12),
      O => \bitIndex[12]_i_5_n_0\
    );
\bitIndex[16]_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(19),
      O => \bitIndex[16]_i_2_n_0\
    );
\bitIndex[16]_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(18),
      O => \bitIndex[16]_i_3_n_0\
    );
\bitIndex[16]_i_4\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(17),
      O => \bitIndex[16]_i_4_n_0\
    );
\bitIndex[16]_i_5\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(16),
      O => \bitIndex[16]_i_5_n_0\
    );
\bitIndex[20]_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(23),
      O => \bitIndex[20]_i_2_n_0\
    );
\bitIndex[20]_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(22),
      O => \bitIndex[20]_i_3_n_0\
    );
\bitIndex[20]_i_4\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(21),
      O => \bitIndex[20]_i_4_n_0\
    );
\bitIndex[20]_i_5\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(20),
      O => \bitIndex[20]_i_5_n_0\
    );
\bitIndex[24]_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(27),
      O => \bitIndex[24]_i_2_n_0\
    );
\bitIndex[24]_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(26),
      O => \bitIndex[24]_i_3_n_0\
    );
\bitIndex[24]_i_4\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(25),
      O => \bitIndex[24]_i_4_n_0\
    );
\bitIndex[24]_i_5\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(24),
      O => \bitIndex[24]_i_5_n_0\
    );
\bitIndex[28]_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(30),
      O => \bitIndex[28]_i_2_n_0\
    );
\bitIndex[28]_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(29),
      O => \bitIndex[28]_i_3_n_0\
    );
\bitIndex[28]_i_4\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(28),
      O => \bitIndex[28]_i_4_n_0\
    );
\bitIndex[4]_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(7),
      O => \bitIndex[4]_i_2_n_0\
    );
\bitIndex[4]_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(6),
      O => \bitIndex[4]_i_3_n_0\
    );
\bitIndex[4]_i_4\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(5),
      O => \bitIndex[4]_i_4_n_0\
    );
\bitIndex[4]_i_5\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(4),
      O => \bitIndex[4]_i_5_n_0\
    );
\bitIndex[8]_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(11),
      O => \bitIndex[8]_i_2_n_0\
    );
\bitIndex[8]_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(10),
      O => \bitIndex[8]_i_3_n_0\
    );
\bitIndex[8]_i_4\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(9),
      O => \bitIndex[8]_i_4_n_0\
    );
\bitIndex[8]_i_5\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitIndex_reg(8),
      O => \bitIndex[8]_i_5_n_0\
    );
\bitIndex_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[0]_i_1_n_7\,
      Q => bitIndex_reg(0),
      R => ready
    );
\bitIndex_reg[0]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => \bitIndex_reg[0]_i_1_n_0\,
      CO(2) => \bitIndex_reg[0]_i_1_n_1\,
      CO(1) => \bitIndex_reg[0]_i_1_n_2\,
      CO(0) => \bitIndex_reg[0]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0001",
      O(3) => \bitIndex_reg[0]_i_1_n_4\,
      O(2) => \bitIndex_reg[0]_i_1_n_5\,
      O(1) => \bitIndex_reg[0]_i_1_n_6\,
      O(0) => \bitIndex_reg[0]_i_1_n_7\,
      S(3) => \bitIndex[0]_i_2_n_0\,
      S(2) => \bitIndex[0]_i_3_n_0\,
      S(1) => \bitIndex[0]_i_4_n_0\,
      S(0) => \bitIndex[0]_i_5_n_0\
    );
\bitIndex_reg[10]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[8]_i_1_n_5\,
      Q => bitIndex_reg(10),
      R => ready
    );
\bitIndex_reg[11]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[8]_i_1_n_4\,
      Q => bitIndex_reg(11),
      R => ready
    );
\bitIndex_reg[12]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[12]_i_1_n_7\,
      Q => bitIndex_reg(12),
      R => ready
    );
\bitIndex_reg[12]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \bitIndex_reg[8]_i_1_n_0\,
      CO(3) => \bitIndex_reg[12]_i_1_n_0\,
      CO(2) => \bitIndex_reg[12]_i_1_n_1\,
      CO(1) => \bitIndex_reg[12]_i_1_n_2\,
      CO(0) => \bitIndex_reg[12]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \bitIndex_reg[12]_i_1_n_4\,
      O(2) => \bitIndex_reg[12]_i_1_n_5\,
      O(1) => \bitIndex_reg[12]_i_1_n_6\,
      O(0) => \bitIndex_reg[12]_i_1_n_7\,
      S(3) => \bitIndex[12]_i_2_n_0\,
      S(2) => \bitIndex[12]_i_3_n_0\,
      S(1) => \bitIndex[12]_i_4_n_0\,
      S(0) => \bitIndex[12]_i_5_n_0\
    );
\bitIndex_reg[13]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[12]_i_1_n_6\,
      Q => bitIndex_reg(13),
      R => ready
    );
\bitIndex_reg[14]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[12]_i_1_n_5\,
      Q => bitIndex_reg(14),
      R => ready
    );
\bitIndex_reg[15]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[12]_i_1_n_4\,
      Q => bitIndex_reg(15),
      R => ready
    );
\bitIndex_reg[16]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[16]_i_1_n_7\,
      Q => bitIndex_reg(16),
      R => ready
    );
\bitIndex_reg[16]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \bitIndex_reg[12]_i_1_n_0\,
      CO(3) => \bitIndex_reg[16]_i_1_n_0\,
      CO(2) => \bitIndex_reg[16]_i_1_n_1\,
      CO(1) => \bitIndex_reg[16]_i_1_n_2\,
      CO(0) => \bitIndex_reg[16]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \bitIndex_reg[16]_i_1_n_4\,
      O(2) => \bitIndex_reg[16]_i_1_n_5\,
      O(1) => \bitIndex_reg[16]_i_1_n_6\,
      O(0) => \bitIndex_reg[16]_i_1_n_7\,
      S(3) => \bitIndex[16]_i_2_n_0\,
      S(2) => \bitIndex[16]_i_3_n_0\,
      S(1) => \bitIndex[16]_i_4_n_0\,
      S(0) => \bitIndex[16]_i_5_n_0\
    );
\bitIndex_reg[17]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[16]_i_1_n_6\,
      Q => bitIndex_reg(17),
      R => ready
    );
\bitIndex_reg[18]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[16]_i_1_n_5\,
      Q => bitIndex_reg(18),
      R => ready
    );
\bitIndex_reg[19]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[16]_i_1_n_4\,
      Q => bitIndex_reg(19),
      R => ready
    );
\bitIndex_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[0]_i_1_n_6\,
      Q => bitIndex_reg(1),
      R => ready
    );
\bitIndex_reg[20]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[20]_i_1_n_7\,
      Q => bitIndex_reg(20),
      R => ready
    );
\bitIndex_reg[20]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \bitIndex_reg[16]_i_1_n_0\,
      CO(3) => \bitIndex_reg[20]_i_1_n_0\,
      CO(2) => \bitIndex_reg[20]_i_1_n_1\,
      CO(1) => \bitIndex_reg[20]_i_1_n_2\,
      CO(0) => \bitIndex_reg[20]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \bitIndex_reg[20]_i_1_n_4\,
      O(2) => \bitIndex_reg[20]_i_1_n_5\,
      O(1) => \bitIndex_reg[20]_i_1_n_6\,
      O(0) => \bitIndex_reg[20]_i_1_n_7\,
      S(3) => \bitIndex[20]_i_2_n_0\,
      S(2) => \bitIndex[20]_i_3_n_0\,
      S(1) => \bitIndex[20]_i_4_n_0\,
      S(0) => \bitIndex[20]_i_5_n_0\
    );
\bitIndex_reg[21]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[20]_i_1_n_6\,
      Q => bitIndex_reg(21),
      R => ready
    );
\bitIndex_reg[22]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[20]_i_1_n_5\,
      Q => bitIndex_reg(22),
      R => ready
    );
\bitIndex_reg[23]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[20]_i_1_n_4\,
      Q => bitIndex_reg(23),
      R => ready
    );
\bitIndex_reg[24]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[24]_i_1_n_7\,
      Q => bitIndex_reg(24),
      R => ready
    );
\bitIndex_reg[24]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \bitIndex_reg[20]_i_1_n_0\,
      CO(3) => \bitIndex_reg[24]_i_1_n_0\,
      CO(2) => \bitIndex_reg[24]_i_1_n_1\,
      CO(1) => \bitIndex_reg[24]_i_1_n_2\,
      CO(0) => \bitIndex_reg[24]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \bitIndex_reg[24]_i_1_n_4\,
      O(2) => \bitIndex_reg[24]_i_1_n_5\,
      O(1) => \bitIndex_reg[24]_i_1_n_6\,
      O(0) => \bitIndex_reg[24]_i_1_n_7\,
      S(3) => \bitIndex[24]_i_2_n_0\,
      S(2) => \bitIndex[24]_i_3_n_0\,
      S(1) => \bitIndex[24]_i_4_n_0\,
      S(0) => \bitIndex[24]_i_5_n_0\
    );
\bitIndex_reg[25]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[24]_i_1_n_6\,
      Q => bitIndex_reg(25),
      R => ready
    );
\bitIndex_reg[26]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[24]_i_1_n_5\,
      Q => bitIndex_reg(26),
      R => ready
    );
\bitIndex_reg[27]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[24]_i_1_n_4\,
      Q => bitIndex_reg(27),
      R => ready
    );
\bitIndex_reg[28]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[28]_i_1_n_7\,
      Q => bitIndex_reg(28),
      R => ready
    );
\bitIndex_reg[28]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \bitIndex_reg[24]_i_1_n_0\,
      CO(3 downto 2) => \NLW_bitIndex_reg[28]_i_1_CO_UNCONNECTED\(3 downto 2),
      CO(1) => \bitIndex_reg[28]_i_1_n_2\,
      CO(0) => \bitIndex_reg[28]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \NLW_bitIndex_reg[28]_i_1_O_UNCONNECTED\(3),
      O(2) => \bitIndex_reg[28]_i_1_n_5\,
      O(1) => \bitIndex_reg[28]_i_1_n_6\,
      O(0) => \bitIndex_reg[28]_i_1_n_7\,
      S(3) => '0',
      S(2) => \bitIndex[28]_i_2_n_0\,
      S(1) => \bitIndex[28]_i_3_n_0\,
      S(0) => \bitIndex[28]_i_4_n_0\
    );
\bitIndex_reg[29]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[28]_i_1_n_6\,
      Q => bitIndex_reg(29),
      R => ready
    );
\bitIndex_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[0]_i_1_n_5\,
      Q => bitIndex_reg(2),
      R => ready
    );
\bitIndex_reg[30]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[28]_i_1_n_5\,
      Q => bitIndex_reg(30),
      R => ready
    );
\bitIndex_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[0]_i_1_n_4\,
      Q => bitIndex_reg(3),
      R => ready
    );
\bitIndex_reg[4]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[4]_i_1_n_7\,
      Q => bitIndex_reg(4),
      R => ready
    );
\bitIndex_reg[4]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \bitIndex_reg[0]_i_1_n_0\,
      CO(3) => \bitIndex_reg[4]_i_1_n_0\,
      CO(2) => \bitIndex_reg[4]_i_1_n_1\,
      CO(1) => \bitIndex_reg[4]_i_1_n_2\,
      CO(0) => \bitIndex_reg[4]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \bitIndex_reg[4]_i_1_n_4\,
      O(2) => \bitIndex_reg[4]_i_1_n_5\,
      O(1) => \bitIndex_reg[4]_i_1_n_6\,
      O(0) => \bitIndex_reg[4]_i_1_n_7\,
      S(3) => \bitIndex[4]_i_2_n_0\,
      S(2) => \bitIndex[4]_i_3_n_0\,
      S(1) => \bitIndex[4]_i_4_n_0\,
      S(0) => \bitIndex[4]_i_5_n_0\
    );
\bitIndex_reg[5]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[4]_i_1_n_6\,
      Q => bitIndex_reg(5),
      R => ready
    );
\bitIndex_reg[6]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[4]_i_1_n_5\,
      Q => bitIndex_reg(6),
      R => ready
    );
\bitIndex_reg[7]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[4]_i_1_n_4\,
      Q => bitIndex_reg(7),
      R => ready
    );
\bitIndex_reg[8]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[8]_i_1_n_7\,
      Q => bitIndex_reg(8),
      R => ready
    );
\bitIndex_reg[8]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \bitIndex_reg[4]_i_1_n_0\,
      CO(3) => \bitIndex_reg[8]_i_1_n_0\,
      CO(2) => \bitIndex_reg[8]_i_1_n_1\,
      CO(1) => \bitIndex_reg[8]_i_1_n_2\,
      CO(0) => \bitIndex_reg[8]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \bitIndex_reg[8]_i_1_n_4\,
      O(2) => \bitIndex_reg[8]_i_1_n_5\,
      O(1) => \bitIndex_reg[8]_i_1_n_6\,
      O(0) => \bitIndex_reg[8]_i_1_n_7\,
      S(3) => \bitIndex[8]_i_2_n_0\,
      S(2) => \bitIndex[8]_i_3_n_0\,
      S(1) => \bitIndex[8]_i_4_n_0\,
      S(0) => \bitIndex[8]_i_5_n_0\
    );
\bitIndex_reg[9]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => \bitIndex_reg[8]_i_1_n_6\,
      Q => bitIndex_reg(9),
      R => ready
    );
\bitTmr[0]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"1F"
    )
        port map (
      I0 => \^bittmr_reg[13]_0\,
      I1 => \^bittmr_reg[13]_1\,
      I2 => \txState[1]_i_2_n_0\,
      O => \bitTmr[0]_i_1_n_0\
    );
\bitTmr[0]_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitTmr_reg(3),
      O => \bitTmr[0]_i_3_n_0\
    );
\bitTmr[0]_i_4\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitTmr_reg(2),
      O => \bitTmr[0]_i_4_n_0\
    );
\bitTmr[0]_i_5\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitTmr_reg(1),
      O => \bitTmr[0]_i_5_n_0\
    );
\bitTmr[0]_i_6\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => bitTmr_reg(0),
      O => \bitTmr[0]_i_6_n_0\
    );
\bitTmr[12]_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitTmr_reg(13),
      O => \bitTmr[12]_i_2_n_0\
    );
\bitTmr[12]_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitTmr_reg(12),
      O => \bitTmr[12]_i_3_n_0\
    );
\bitTmr[4]_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitTmr_reg(7),
      O => \bitTmr[4]_i_2_n_0\
    );
\bitTmr[4]_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitTmr_reg(6),
      O => \bitTmr[4]_i_3_n_0\
    );
\bitTmr[4]_i_4\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitTmr_reg(5),
      O => \bitTmr[4]_i_4_n_0\
    );
\bitTmr[4]_i_5\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitTmr_reg(4),
      O => \bitTmr[4]_i_5_n_0\
    );
\bitTmr[8]_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitTmr_reg(11),
      O => \bitTmr[8]_i_2_n_0\
    );
\bitTmr[8]_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitTmr_reg(10),
      O => \bitTmr[8]_i_3_n_0\
    );
\bitTmr[8]_i_4\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitTmr_reg(9),
      O => \bitTmr[8]_i_4_n_0\
    );
\bitTmr[8]_i_5\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => bitTmr_reg(8),
      O => \bitTmr[8]_i_5_n_0\
    );
\bitTmr_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \bitTmr_reg[0]_i_2_n_7\,
      Q => bitTmr_reg(0),
      R => \bitTmr[0]_i_1_n_0\
    );
\bitTmr_reg[0]_i_2\: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => \bitTmr_reg[0]_i_2_n_0\,
      CO(2) => \bitTmr_reg[0]_i_2_n_1\,
      CO(1) => \bitTmr_reg[0]_i_2_n_2\,
      CO(0) => \bitTmr_reg[0]_i_2_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0001",
      O(3) => \bitTmr_reg[0]_i_2_n_4\,
      O(2) => \bitTmr_reg[0]_i_2_n_5\,
      O(1) => \bitTmr_reg[0]_i_2_n_6\,
      O(0) => \bitTmr_reg[0]_i_2_n_7\,
      S(3) => \bitTmr[0]_i_3_n_0\,
      S(2) => \bitTmr[0]_i_4_n_0\,
      S(1) => \bitTmr[0]_i_5_n_0\,
      S(0) => \bitTmr[0]_i_6_n_0\
    );
\bitTmr_reg[10]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \bitTmr_reg[8]_i_1_n_5\,
      Q => bitTmr_reg(10),
      R => \bitTmr[0]_i_1_n_0\
    );
\bitTmr_reg[11]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \bitTmr_reg[8]_i_1_n_4\,
      Q => bitTmr_reg(11),
      R => \bitTmr[0]_i_1_n_0\
    );
\bitTmr_reg[12]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \bitTmr_reg[12]_i_1_n_7\,
      Q => bitTmr_reg(12),
      R => \bitTmr[0]_i_1_n_0\
    );
\bitTmr_reg[12]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \bitTmr_reg[8]_i_1_n_0\,
      CO(3 downto 1) => \NLW_bitTmr_reg[12]_i_1_CO_UNCONNECTED\(3 downto 1),
      CO(0) => \bitTmr_reg[12]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3 downto 2) => \NLW_bitTmr_reg[12]_i_1_O_UNCONNECTED\(3 downto 2),
      O(1) => \bitTmr_reg[12]_i_1_n_6\,
      O(0) => \bitTmr_reg[12]_i_1_n_7\,
      S(3 downto 2) => B"00",
      S(1) => \bitTmr[12]_i_2_n_0\,
      S(0) => \bitTmr[12]_i_3_n_0\
    );
\bitTmr_reg[13]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \bitTmr_reg[12]_i_1_n_6\,
      Q => bitTmr_reg(13),
      R => \bitTmr[0]_i_1_n_0\
    );
\bitTmr_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \bitTmr_reg[0]_i_2_n_6\,
      Q => bitTmr_reg(1),
      R => \bitTmr[0]_i_1_n_0\
    );
\bitTmr_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \bitTmr_reg[0]_i_2_n_5\,
      Q => bitTmr_reg(2),
      R => \bitTmr[0]_i_1_n_0\
    );
\bitTmr_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \bitTmr_reg[0]_i_2_n_4\,
      Q => bitTmr_reg(3),
      R => \bitTmr[0]_i_1_n_0\
    );
\bitTmr_reg[4]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \bitTmr_reg[4]_i_1_n_7\,
      Q => bitTmr_reg(4),
      R => \bitTmr[0]_i_1_n_0\
    );
\bitTmr_reg[4]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \bitTmr_reg[0]_i_2_n_0\,
      CO(3) => \bitTmr_reg[4]_i_1_n_0\,
      CO(2) => \bitTmr_reg[4]_i_1_n_1\,
      CO(1) => \bitTmr_reg[4]_i_1_n_2\,
      CO(0) => \bitTmr_reg[4]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \bitTmr_reg[4]_i_1_n_4\,
      O(2) => \bitTmr_reg[4]_i_1_n_5\,
      O(1) => \bitTmr_reg[4]_i_1_n_6\,
      O(0) => \bitTmr_reg[4]_i_1_n_7\,
      S(3) => \bitTmr[4]_i_2_n_0\,
      S(2) => \bitTmr[4]_i_3_n_0\,
      S(1) => \bitTmr[4]_i_4_n_0\,
      S(0) => \bitTmr[4]_i_5_n_0\
    );
\bitTmr_reg[5]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \bitTmr_reg[4]_i_1_n_6\,
      Q => bitTmr_reg(5),
      R => \bitTmr[0]_i_1_n_0\
    );
\bitTmr_reg[6]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \bitTmr_reg[4]_i_1_n_5\,
      Q => bitTmr_reg(6),
      R => \bitTmr[0]_i_1_n_0\
    );
\bitTmr_reg[7]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \bitTmr_reg[4]_i_1_n_4\,
      Q => bitTmr_reg(7),
      R => \bitTmr[0]_i_1_n_0\
    );
\bitTmr_reg[8]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \bitTmr_reg[8]_i_1_n_7\,
      Q => bitTmr_reg(8),
      R => \bitTmr[0]_i_1_n_0\
    );
\bitTmr_reg[8]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \bitTmr_reg[4]_i_1_n_0\,
      CO(3) => \bitTmr_reg[8]_i_1_n_0\,
      CO(2) => \bitTmr_reg[8]_i_1_n_1\,
      CO(1) => \bitTmr_reg[8]_i_1_n_2\,
      CO(0) => \bitTmr_reg[8]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \bitTmr_reg[8]_i_1_n_4\,
      O(2) => \bitTmr_reg[8]_i_1_n_5\,
      O(1) => \bitTmr_reg[8]_i_1_n_6\,
      O(0) => \bitTmr_reg[8]_i_1_n_7\,
      S(3) => \bitTmr[8]_i_2_n_0\,
      S(2) => \bitTmr[8]_i_3_n_0\,
      S(1) => \bitTmr[8]_i_4_n_0\,
      S(0) => \bitTmr[8]_i_5_n_0\
    );
\bitTmr_reg[9]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \bitTmr_reg[8]_i_1_n_6\,
      Q => bitTmr_reg(9),
      R => \bitTmr[0]_i_1_n_0\
    );
txBit_i_1: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \^bittmr_reg[13]_1\,
      I1 => \^bittmr_reg[13]_0\,
      O => ready
    );
txBit_i_2: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => \^bittmr_reg[13]_0\,
      I1 => \^bittmr_reg[13]_1\,
      O => txBit_i_2_n_0
    );
txBit_i_3: unisim.vcomponents.LUT6
    generic map(
      INIT => X"000EFFFF000E0000"
    )
        port map (
      I0 => txData(8),
      I1 => bitIndex_reg(0),
      I2 => bitIndex_reg(2),
      I3 => bitIndex_reg(1),
      I4 => bitIndex_reg(3),
      I5 => txBit_reg_i_4_n_0,
      O => txBit_i_3_n_0
    );
txBit_i_5: unisim.vcomponents.LUT5
    generic map(
      INIT => X"AFC0A0C0"
    )
        port map (
      I0 => txData(3),
      I1 => txData(2),
      I2 => bitIndex_reg(1),
      I3 => bitIndex_reg(0),
      I4 => txData(1),
      O => txBit_i_5_n_0
    );
txBit_i_6: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AFA0CFCFAFA0C0C0"
    )
        port map (
      I0 => txData(7),
      I1 => txData(6),
      I2 => bitIndex_reg(1),
      I3 => txData(5),
      I4 => bitIndex_reg(0),
      I5 => txData(4),
      O => txBit_i_6_n_0
    );
txBit_reg: unisim.vcomponents.FDSE
    generic map(
      INIT => '1'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => txBit_i_2_n_0,
      D => txBit_i_3_n_0,
      Q => RsTx_OBUF,
      S => ready
    );
txBit_reg_i_4: unisim.vcomponents.MUXF7
     port map (
      I0 => txBit_i_5_n_0,
      I1 => txBit_i_6_n_0,
      O => txBit_reg_i_4_n_0,
      S => bitIndex_reg(2)
    );
\txData_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => E(0),
      D => D(0),
      Q => txData(1),
      R => '0'
    );
\txData_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => E(0),
      D => D(1),
      Q => txData(2),
      R => '0'
    );
\txData_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => E(0),
      D => D(2),
      Q => txData(3),
      R => '0'
    );
\txData_reg[4]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => E(0),
      D => D(3),
      Q => txData(4),
      R => '0'
    );
\txData_reg[5]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => E(0),
      D => D(4),
      Q => txData(5),
      R => '0'
    );
\txData_reg[6]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => E(0),
      D => D(5),
      Q => txData(6),
      R => '0'
    );
\txData_reg[7]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => E(0),
      D => D(6),
      Q => txData(7),
      R => '0'
    );
\txData_reg[8]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => E(0),
      D => D(7),
      Q => txData(8),
      R => '0'
    );
\txState[0]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0232023200000232"
    )
        port map (
      I0 => E(0),
      I1 => \^bittmr_reg[13]_0\,
      I2 => \^bittmr_reg[13]_1\,
      I3 => \txState[1]_i_2_n_0\,
      I4 => \txState[0]_i_2_n_0\,
      I5 => \txState[0]_i_3_n_0\,
      O => \txState[0]_i_1_n_0\
    );
\txState[0]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000000000001"
    )
        port map (
      I0 => \txState[0]_i_4_n_0\,
      I1 => bitIndex_reg(13),
      I2 => bitIndex_reg(12),
      I3 => bitIndex_reg(15),
      I4 => bitIndex_reg(0),
      I5 => \txState[0]_i_5_n_0\,
      O => \txState[0]_i_2_n_0\
    );
\txState[0]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFFFFFFFFFE"
    )
        port map (
      I0 => \txState[0]_i_6_n_0\,
      I1 => bitIndex_reg(10),
      I2 => bitIndex_reg(7),
      I3 => bitIndex_reg(24),
      I4 => bitIndex_reg(21),
      I5 => \txState[0]_i_7_n_0\,
      O => \txState[0]_i_3_n_0\
    );
\txState[0]_i_4\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FFFE"
    )
        port map (
      I0 => bitIndex_reg(8),
      I1 => bitIndex_reg(4),
      I2 => bitIndex_reg(27),
      I3 => bitIndex_reg(16),
      O => \txState[0]_i_4_n_0\
    );
\txState[0]_i_5\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFFFFEFF"
    )
        port map (
      I0 => bitIndex_reg(20),
      I1 => bitIndex_reg(25),
      I2 => bitIndex_reg(2),
      I3 => bitIndex_reg(1),
      I4 => \txState[0]_i_8_n_0\,
      O => \txState[0]_i_5_n_0\
    );
\txState[0]_i_6\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FFFE"
    )
        port map (
      I0 => bitIndex_reg(14),
      I1 => bitIndex_reg(30),
      I2 => bitIndex_reg(26),
      I3 => bitIndex_reg(22),
      O => \txState[0]_i_6_n_0\
    );
\txState[0]_i_7\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFFFFFFB"
    )
        port map (
      I0 => bitIndex_reg(18),
      I1 => bitIndex_reg(3),
      I2 => bitIndex_reg(28),
      I3 => bitIndex_reg(6),
      I4 => \txState[0]_i_9_n_0\,
      O => \txState[0]_i_7_n_0\
    );
\txState[0]_i_8\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FFFD"
    )
        port map (
      I0 => \^bittmr_reg[13]_1\,
      I1 => bitIndex_reg(11),
      I2 => bitIndex_reg(23),
      I3 => bitIndex_reg(19),
      O => \txState[0]_i_8_n_0\
    );
\txState[0]_i_9\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FFFE"
    )
        port map (
      I0 => bitIndex_reg(9),
      I1 => bitIndex_reg(5),
      I2 => bitIndex_reg(29),
      I3 => bitIndex_reg(17),
      O => \txState[0]_i_9_n_0\
    );
\txState[1]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"62"
    )
        port map (
      I0 => \^bittmr_reg[13]_0\,
      I1 => \^bittmr_reg[13]_1\,
      I2 => \txState[1]_i_2_n_0\,
      O => \txState[1]_i_1_n_0\
    );
\txState[1]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFFFFFFFFEF"
    )
        port map (
      I0 => \txState[1]_i_3_n_0\,
      I1 => \txState[1]_i_4_n_0\,
      I2 => bitTmr_reg(13),
      I3 => bitTmr_reg(12),
      I4 => bitTmr_reg(3),
      I5 => bitTmr_reg(0),
      O => \txState[1]_i_2_n_0\
    );
\txState[1]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFFFFFFFDFF"
    )
        port map (
      I0 => bitTmr_reg(5),
      I1 => bitTmr_reg(10),
      I2 => bitTmr_reg(9),
      I3 => bitTmr_reg(11),
      I4 => bitTmr_reg(8),
      I5 => bitTmr_reg(2),
      O => \txState[1]_i_3_n_0\
    );
\txState[1]_i_4\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FFDF"
    )
        port map (
      I0 => bitTmr_reg(4),
      I1 => bitTmr_reg(6),
      I2 => bitTmr_reg(7),
      I3 => bitTmr_reg(1),
      O => \txState[1]_i_4_n_0\
    );
\txState_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \txState[0]_i_1_n_0\,
      Q => \^bittmr_reg[13]_0\,
      R => '0'
    );
\txState_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \txState[1]_i_1_n_0\,
      Q => \^bittmr_reg[13]_1\,
      R => '0'
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity i2c_controller is
  port (
    FIFO_WriteEn : out STD_LOGIC;
    ena : out STD_LOGIC;
    Q : out STD_LOGIC_VECTOR ( 7 downto 0 );
    \data_rd_reg[7]\ : in STD_LOGIC_VECTOR ( 7 downto 0 );
    CLK : in STD_LOGIC;
    ack_error : in STD_LOGIC;
    busy : in STD_LOGIC;
    busy_reg : in STD_LOGIC
  );
end i2c_controller;

architecture STRUCTURE of i2c_controller is
  signal \FIFO_DataIn_reg[7]_i_1_n_0\ : STD_LOGIC;
  signal FIFO_WriteEn_reg_i_1_n_0 : STD_LOGIC;
  signal FIFO_WriteEn_reg_i_2_n_0 : STD_LOGIC;
  signal \FSM_sequential_state_next[0]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state_next[1]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state_next[1]_i_2_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state_next[2]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state_next[2]_i_2_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state_next[2]_i_3_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state_next[3]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state_next[3]_i_2_n_0\ : STD_LOGIC;
  signal delay : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \delay_reg[0]_i_1_n_0\ : STD_LOGIC;
  signal \delay_reg[1]_i_1_n_0\ : STD_LOGIC;
  signal \delay_reg[2]_i_1_n_0\ : STD_LOGIC;
  signal \delay_reg[3]_i_1_n_0\ : STD_LOGIC;
  signal \delay_reg[4]_i_1_n_0\ : STD_LOGIC;
  signal \delay_reg[4]_i_2_n_0\ : STD_LOGIC;
  signal \delay_reg[5]_i_1_n_0\ : STD_LOGIC;
  signal \delay_reg[5]_i_2_n_0\ : STD_LOGIC;
  signal \delay_reg[6]_i_1_n_0\ : STD_LOGIC;
  signal \delay_reg[7]_i_1_n_0\ : STD_LOGIC;
  signal \delay_reg[7]_i_2_n_0\ : STD_LOGIC;
  signal \delay_reg[7]_i_3_n_0\ : STD_LOGIC;
  signal ena_reg_i_1_n_0 : STD_LOGIC;
  signal ena_reg_i_2_n_0 : STD_LOGIC;
  signal finishFlag : STD_LOGIC;
  signal finishFlag_reg_i_1_n_0 : STD_LOGIC;
  signal finishFlag_reg_i_2_n_0 : STD_LOGIC;
  signal state_next : STD_LOGIC_VECTOR ( 3 downto 0 );
  attribute RTL_KEEP : string;
  attribute RTL_KEEP of state_next : signal is "yes";
  attribute XILINX_LEGACY_PRIM : string;
  attribute XILINX_LEGACY_PRIM of \FIFO_DataIn_reg[0]\ : label is "LD";
  attribute XILINX_LEGACY_PRIM of \FIFO_DataIn_reg[1]\ : label is "LD";
  attribute XILINX_LEGACY_PRIM of \FIFO_DataIn_reg[2]\ : label is "LD";
  attribute XILINX_LEGACY_PRIM of \FIFO_DataIn_reg[3]\ : label is "LD";
  attribute XILINX_LEGACY_PRIM of \FIFO_DataIn_reg[4]\ : label is "LD";
  attribute XILINX_LEGACY_PRIM of \FIFO_DataIn_reg[5]\ : label is "LD";
  attribute XILINX_LEGACY_PRIM of \FIFO_DataIn_reg[6]\ : label is "LD";
  attribute XILINX_LEGACY_PRIM of \FIFO_DataIn_reg[7]\ : label is "LD";
  attribute XILINX_LEGACY_PRIM of FIFO_WriteEn_reg : label is "LD";
  attribute KEEP : string;
  attribute KEEP of \FSM_sequential_state_next_reg[0]\ : label is "yes";
  attribute KEEP of \FSM_sequential_state_next_reg[1]\ : label is "yes";
  attribute KEEP of \FSM_sequential_state_next_reg[2]\ : label is "yes";
  attribute KEEP of \FSM_sequential_state_next_reg[3]\ : label is "yes";
  attribute XILINX_LEGACY_PRIM of \delay_reg[0]\ : label is "LD";
  attribute XILINX_LEGACY_PRIM of \delay_reg[1]\ : label is "LD";
  attribute XILINX_LEGACY_PRIM of \delay_reg[2]\ : label is "LD";
  attribute XILINX_LEGACY_PRIM of \delay_reg[3]\ : label is "LD";
  attribute XILINX_LEGACY_PRIM of \delay_reg[4]\ : label is "LD";
  attribute XILINX_LEGACY_PRIM of \delay_reg[5]\ : label is "LD";
  attribute XILINX_LEGACY_PRIM of \delay_reg[6]\ : label is "LD";
  attribute XILINX_LEGACY_PRIM of \delay_reg[7]\ : label is "LD";
  attribute XILINX_LEGACY_PRIM of ena_reg : label is "LD";
  attribute XILINX_LEGACY_PRIM of finishFlag_reg : label is "LD";
begin
\FIFO_DataIn_reg[0]\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => \data_rd_reg[7]\(0),
      G => \FIFO_DataIn_reg[7]_i_1_n_0\,
      GE => '1',
      Q => Q(0)
    );
\FIFO_DataIn_reg[1]\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => \data_rd_reg[7]\(1),
      G => \FIFO_DataIn_reg[7]_i_1_n_0\,
      GE => '1',
      Q => Q(1)
    );
\FIFO_DataIn_reg[2]\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => \data_rd_reg[7]\(2),
      G => \FIFO_DataIn_reg[7]_i_1_n_0\,
      GE => '1',
      Q => Q(2)
    );
\FIFO_DataIn_reg[3]\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => \data_rd_reg[7]\(3),
      G => \FIFO_DataIn_reg[7]_i_1_n_0\,
      GE => '1',
      Q => Q(3)
    );
\FIFO_DataIn_reg[4]\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => \data_rd_reg[7]\(4),
      G => \FIFO_DataIn_reg[7]_i_1_n_0\,
      GE => '1',
      Q => Q(4)
    );
\FIFO_DataIn_reg[5]\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => \data_rd_reg[7]\(5),
      G => \FIFO_DataIn_reg[7]_i_1_n_0\,
      GE => '1',
      Q => Q(5)
    );
\FIFO_DataIn_reg[6]\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => \data_rd_reg[7]\(6),
      G => \FIFO_DataIn_reg[7]_i_1_n_0\,
      GE => '1',
      Q => Q(6)
    );
\FIFO_DataIn_reg[7]\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => \data_rd_reg[7]\(7),
      G => \FIFO_DataIn_reg[7]_i_1_n_0\,
      GE => '1',
      Q => Q(7)
    );
\FIFO_DataIn_reg[7]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0040"
    )
        port map (
      I0 => state_next(2),
      I1 => state_next(1),
      I2 => state_next(0),
      I3 => state_next(3),
      O => \FIFO_DataIn_reg[7]_i_1_n_0\
    );
FIFO_WriteEn_reg: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => FIFO_WriteEn_reg_i_1_n_0,
      G => FIFO_WriteEn_reg_i_2_n_0,
      GE => '1',
      Q => FIFO_WriteEn
    );
FIFO_WriteEn_reg_i_1: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => state_next(0),
      I1 => state_next(3),
      O => FIFO_WriteEn_reg_i_1_n_0
    );
FIFO_WriteEn_reg_i_2: unisim.vcomponents.LUT3
    generic map(
      INIT => X"04"
    )
        port map (
      I0 => state_next(1),
      I1 => state_next(2),
      I2 => state_next(3),
      O => FIFO_WriteEn_reg_i_2_n_0
    );
\FSM_sequential_state_next[0]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000055450045"
    )
        port map (
      I0 => state_next(0),
      I1 => busy_reg,
      I2 => state_next(1),
      I3 => state_next(2),
      I4 => \FSM_sequential_state_next[2]_i_2_n_0\,
      I5 => state_next(3),
      O => \FSM_sequential_state_next[0]_i_1_n_0\
    );
\FSM_sequential_state_next[1]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"40454040454A454A"
    )
        port map (
      I0 => state_next(3),
      I1 => \FSM_sequential_state_next[1]_i_2_n_0\,
      I2 => state_next(2),
      I3 => state_next(0),
      I4 => busy_reg,
      I5 => state_next(1),
      O => \FSM_sequential_state_next[1]_i_1_n_0\
    );
\FSM_sequential_state_next[1]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFCFFFFF88888888"
    )
        port map (
      I0 => finishFlag,
      I1 => state_next(0),
      I2 => delay(3),
      I3 => \FSM_sequential_state_next[2]_i_3_n_0\,
      I4 => delay(7),
      I5 => state_next(1),
      O => \FSM_sequential_state_next[1]_i_2_n_0\
    );
\FSM_sequential_state_next[2]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"00000000F8A8D888"
    )
        port map (
      I0 => state_next(0),
      I1 => state_next(1),
      I2 => state_next(2),
      I3 => \FSM_sequential_state_next[2]_i_2_n_0\,
      I4 => finishFlag,
      I5 => state_next(3),
      O => \FSM_sequential_state_next[2]_i_1_n_0\
    );
\FSM_sequential_state_next[2]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"DFFF"
    )
        port map (
      I0 => delay(3),
      I1 => \FSM_sequential_state_next[2]_i_3_n_0\,
      I2 => delay(7),
      I3 => state_next(1),
      O => \FSM_sequential_state_next[2]_i_2_n_0\
    );
\FSM_sequential_state_next[2]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFEFFFFFFFF"
    )
        port map (
      I0 => delay(5),
      I1 => delay(2),
      I2 => delay(1),
      I3 => delay(0),
      I4 => delay(4),
      I5 => delay(6),
      O => \FSM_sequential_state_next[2]_i_3_n_0\
    );
\FSM_sequential_state_next[3]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"5555555555446255"
    )
        port map (
      I0 => state_next(3),
      I1 => state_next(1),
      I2 => ack_error,
      I3 => busy,
      I4 => state_next(0),
      I5 => state_next(2),
      O => \FSM_sequential_state_next[3]_i_1_n_0\
    );
\FSM_sequential_state_next[3]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00000200"
    )
        port map (
      I0 => state_next(2),
      I1 => finishFlag,
      I2 => state_next(1),
      I3 => state_next(0),
      I4 => state_next(3),
      O => \FSM_sequential_state_next[3]_i_2_n_0\
    );
\FSM_sequential_state_next_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => \FSM_sequential_state_next[3]_i_1_n_0\,
      D => \FSM_sequential_state_next[0]_i_1_n_0\,
      Q => state_next(0),
      R => '0'
    );
\FSM_sequential_state_next_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => \FSM_sequential_state_next[3]_i_1_n_0\,
      D => \FSM_sequential_state_next[1]_i_1_n_0\,
      Q => state_next(1),
      R => '0'
    );
\FSM_sequential_state_next_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => \FSM_sequential_state_next[3]_i_1_n_0\,
      D => \FSM_sequential_state_next[2]_i_1_n_0\,
      Q => state_next(2),
      R => '0'
    );
\FSM_sequential_state_next_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => \FSM_sequential_state_next[3]_i_1_n_0\,
      D => \FSM_sequential_state_next[3]_i_2_n_0\,
      Q => state_next(3),
      R => '0'
    );
\delay_reg[0]\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => \delay_reg[0]_i_1_n_0\,
      G => \delay_reg[7]_i_2_n_0\,
      GE => '1',
      Q => delay(0)
    );
\delay_reg[0]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"04"
    )
        port map (
      I0 => state_next(3),
      I1 => state_next(2),
      I2 => delay(0),
      O => \delay_reg[0]_i_1_n_0\
    );
\delay_reg[1]\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => \delay_reg[1]_i_1_n_0\,
      G => \delay_reg[7]_i_2_n_0\,
      GE => '1',
      Q => delay(1)
    );
\delay_reg[1]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0440"
    )
        port map (
      I0 => state_next(3),
      I1 => state_next(2),
      I2 => delay(1),
      I3 => delay(0),
      O => \delay_reg[1]_i_1_n_0\
    );
\delay_reg[2]\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => \delay_reg[2]_i_1_n_0\,
      G => \delay_reg[7]_i_2_n_0\,
      GE => '1',
      Q => delay(2)
    );
\delay_reg[2]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"04404040"
    )
        port map (
      I0 => state_next(3),
      I1 => state_next(2),
      I2 => delay(2),
      I3 => delay(1),
      I4 => delay(0),
      O => \delay_reg[2]_i_1_n_0\
    );
\delay_reg[3]\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => \delay_reg[3]_i_1_n_0\,
      G => \delay_reg[7]_i_2_n_0\,
      GE => '1',
      Q => delay(3)
    );
\delay_reg[3]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0440404040404040"
    )
        port map (
      I0 => state_next(3),
      I1 => state_next(2),
      I2 => delay(3),
      I3 => delay(2),
      I4 => delay(0),
      I5 => delay(1),
      O => \delay_reg[3]_i_1_n_0\
    );
\delay_reg[4]\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => \delay_reg[4]_i_1_n_0\,
      G => \delay_reg[7]_i_2_n_0\,
      GE => '1',
      Q => delay(4)
    );
\delay_reg[4]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"2888888888888888"
    )
        port map (
      I0 => \delay_reg[4]_i_2_n_0\,
      I1 => delay(4),
      I2 => delay(3),
      I3 => delay(1),
      I4 => delay(0),
      I5 => delay(2),
      O => \delay_reg[4]_i_1_n_0\
    );
\delay_reg[4]_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => state_next(2),
      I1 => state_next(3),
      O => \delay_reg[4]_i_2_n_0\
    );
\delay_reg[5]\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => \delay_reg[5]_i_1_n_0\,
      G => \delay_reg[7]_i_2_n_0\,
      GE => '1',
      Q => delay(5)
    );
\delay_reg[5]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0440"
    )
        port map (
      I0 => state_next(3),
      I1 => state_next(2),
      I2 => delay(5),
      I3 => \delay_reg[5]_i_2_n_0\,
      O => \delay_reg[5]_i_1_n_0\
    );
\delay_reg[5]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => delay(4),
      I1 => delay(2),
      I2 => delay(0),
      I3 => delay(1),
      I4 => delay(3),
      O => \delay_reg[5]_i_2_n_0\
    );
\delay_reg[6]\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => \delay_reg[6]_i_1_n_0\,
      G => \delay_reg[7]_i_2_n_0\,
      GE => '1',
      Q => delay(6)
    );
\delay_reg[6]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0440"
    )
        port map (
      I0 => state_next(3),
      I1 => state_next(2),
      I2 => delay(6),
      I3 => \delay_reg[7]_i_3_n_0\,
      O => \delay_reg[6]_i_1_n_0\
    );
\delay_reg[7]\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => \delay_reg[7]_i_1_n_0\,
      G => \delay_reg[7]_i_2_n_0\,
      GE => '1',
      Q => delay(7)
    );
\delay_reg[7]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"04404040"
    )
        port map (
      I0 => state_next(3),
      I1 => state_next(2),
      I2 => delay(7),
      I3 => delay(6),
      I4 => \delay_reg[7]_i_3_n_0\,
      O => \delay_reg[7]_i_1_n_0\
    );
\delay_reg[7]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0081"
    )
        port map (
      I0 => state_next(0),
      I1 => state_next(1),
      I2 => state_next(2),
      I3 => state_next(3),
      O => \delay_reg[7]_i_2_n_0\
    );
\delay_reg[7]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"8000000000000000"
    )
        port map (
      I0 => delay(5),
      I1 => delay(3),
      I2 => delay(1),
      I3 => delay(0),
      I4 => delay(2),
      I5 => delay(4),
      O => \delay_reg[7]_i_3_n_0\
    );
ena_reg: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => ena_reg_i_1_n_0,
      G => ena_reg_i_2_n_0,
      GE => '1',
      Q => ena
    );
ena_reg_i_1: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => state_next(0),
      I1 => state_next(3),
      O => ena_reg_i_1_n_0
    );
ena_reg_i_2: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0007"
    )
        port map (
      I0 => state_next(0),
      I1 => state_next(3),
      I2 => state_next(1),
      I3 => state_next(2),
      O => ena_reg_i_2_n_0
    );
finishFlag_reg: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => finishFlag_reg_i_1_n_0,
      G => finishFlag_reg_i_2_n_0,
      GE => '1',
      Q => finishFlag
    );
finishFlag_reg_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0100"
    )
        port map (
      I0 => state_next(2),
      I1 => state_next(1),
      I2 => state_next(0),
      I3 => state_next(3),
      O => finishFlag_reg_i_1_n_0
    );
finishFlag_reg_i_2: unisim.vcomponents.LUT3
    generic map(
      INIT => X"01"
    )
        port map (
      I0 => state_next(0),
      I1 => state_next(1),
      I2 => state_next(2),
      O => finishFlag_reg_i_2_n_0
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity i2c_master is
  port (
    busy : out STD_LOGIC;
    ack_error : out STD_LOGIC;
    \JA_TRI[1]\ : out STD_LOGIC;
    \JA_TRI[0]\ : out STD_LOGIC;
    Q : out STD_LOGIC_VECTOR ( 7 downto 0 );
    \FSM_sequential_state_next_reg[1]\ : out STD_LOGIC;
    JA_OBUF : out STD_LOGIC_VECTOR ( 0 to 0 );
    CLK : in STD_LOGIC;
    btnCpuReset_IBUF : in STD_LOGIC;
    scl_ena_reg_0 : in STD_LOGIC;
    JA_IBUF : in STD_LOGIC_VECTOR ( 0 to 0 );
    ena : in STD_LOGIC
  );
end i2c_master;

architecture STRUCTURE of i2c_master is
  signal \FSM_sequential_state[0]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state[0]_i_2_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state[0]_i_3_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state[1]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state[2]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state[3]_i_2_n_0\ : STD_LOGIC;
  signal \JA_IOBUF[0]_inst_i_3_n_0\ : STD_LOGIC;
  signal \JA_IOBUF[1]_inst_i_2_n_0\ : STD_LOGIC;
  signal \^ack_error\ : STD_LOGIC;
  signal ack_error_i_1_n_0 : STD_LOGIC;
  signal ack_error_i_2_n_0 : STD_LOGIC;
  signal ack_error_i_3_n_0 : STD_LOGIC;
  signal ack_error_i_4_n_0 : STD_LOGIC;
  signal \bit_cnt[0]_i_1_n_0\ : STD_LOGIC;
  signal \bit_cnt[1]_i_1_n_0\ : STD_LOGIC;
  signal \bit_cnt[2]_i_1_n_0\ : STD_LOGIC;
  signal \bit_cnt[2]_i_2_n_0\ : STD_LOGIC;
  signal \bit_cnt_reg_n_0_[0]\ : STD_LOGIC;
  signal \bit_cnt_reg_n_0_[1]\ : STD_LOGIC;
  signal \bit_cnt_reg_n_0_[2]\ : STD_LOGIC;
  signal \^busy\ : STD_LOGIC;
  signal busy1 : STD_LOGIC;
  signal busy_i_1_n_0 : STD_LOGIC;
  signal busy_i_2_n_0 : STD_LOGIC;
  signal busy_i_3_n_0 : STD_LOGIC;
  signal count : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \count[2]_i_2_n_0\ : STD_LOGIC;
  signal \count[6]_i_2_n_0\ : STD_LOGIC;
  signal \count[6]_i_3_n_0\ : STD_LOGIC;
  signal \count[7]_i_2_n_0\ : STD_LOGIC;
  signal \count[7]_i_3_n_0\ : STD_LOGIC;
  signal count_0 : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal data_clk : STD_LOGIC;
  signal data_clk_i_1_n_0 : STD_LOGIC;
  signal data_clk_prev : STD_LOGIC;
  signal data_clk_prev_i_1_n_0 : STD_LOGIC;
  signal data_clk_reg_n_0 : STD_LOGIC;
  signal \data_rd[7]_i_1_n_0\ : STD_LOGIC;
  signal \data_rd[7]_i_2_n_0\ : STD_LOGIC;
  signal data_rx : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \data_rx[0]_i_1_n_0\ : STD_LOGIC;
  signal \data_rx[0]_i_2_n_0\ : STD_LOGIC;
  signal \data_rx[1]_i_1_n_0\ : STD_LOGIC;
  signal \data_rx[1]_i_2_n_0\ : STD_LOGIC;
  signal \data_rx[2]_i_1_n_0\ : STD_LOGIC;
  signal \data_rx[2]_i_2_n_0\ : STD_LOGIC;
  signal \data_rx[3]_i_1_n_0\ : STD_LOGIC;
  signal \data_rx[3]_i_2_n_0\ : STD_LOGIC;
  signal \data_rx[4]_i_1_n_0\ : STD_LOGIC;
  signal \data_rx[4]_i_2_n_0\ : STD_LOGIC;
  signal \data_rx[5]_i_1_n_0\ : STD_LOGIC;
  signal \data_rx[5]_i_2_n_0\ : STD_LOGIC;
  signal \data_rx[6]_i_1_n_0\ : STD_LOGIC;
  signal \data_rx[6]_i_2_n_0\ : STD_LOGIC;
  signal \data_rx[7]_i_1_n_0\ : STD_LOGIC;
  signal \data_rx[7]_i_2_n_0\ : STD_LOGIC;
  signal \data_rx[7]_i_3_n_0\ : STD_LOGIC;
  signal scl_clk_i_1_n_0 : STD_LOGIC;
  signal scl_clk_i_2_n_0 : STD_LOGIC;
  signal scl_clk_reg_n_0 : STD_LOGIC;
  signal scl_ena_i_1_n_0 : STD_LOGIC;
  signal scl_ena_reg_n_0 : STD_LOGIC;
  signal sda_int_i_1_n_0 : STD_LOGIC;
  signal sda_int_i_2_n_0 : STD_LOGIC;
  signal sda_int_i_3_n_0 : STD_LOGIC;
  signal sda_int_i_4_n_0 : STD_LOGIC;
  signal sda_int_i_5_n_0 : STD_LOGIC;
  signal sda_int_i_6_n_0 : STD_LOGIC;
  signal sda_int_reg_n_0 : STD_LOGIC;
  signal state : STD_LOGIC_VECTOR ( 3 downto 0 );
  attribute RTL_KEEP : string;
  attribute RTL_KEEP of state : signal is "yes";
  signal stretch : STD_LOGIC;
  signal stretch_i_1_n_0 : STD_LOGIC;
  signal stretch_i_3_n_0 : STD_LOGIC;
  signal stretch_i_4_n_0 : STD_LOGIC;
  signal stretch_i_5_n_0 : STD_LOGIC;
  signal stretch_i_6_n_0 : STD_LOGIC;
  signal stretch_i_7_n_0 : STD_LOGIC;
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \FSM_sequential_state_next[1]_i_3\ : label is "soft_lutpair15";
  attribute KEEP : string;
  attribute KEEP of \FSM_sequential_state_reg[0]\ : label is "yes";
  attribute KEEP of \FSM_sequential_state_reg[1]\ : label is "yes";
  attribute KEEP of \FSM_sequential_state_reg[2]\ : label is "yes";
  attribute KEEP of \FSM_sequential_state_reg[3]\ : label is "yes";
  attribute SOFT_HLUTNM of ack_error_i_2 : label is "soft_lutpair15";
  attribute SOFT_HLUTNM of ack_error_i_4 : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \bit_cnt[0]_i_1\ : label is "soft_lutpair14";
  attribute SOFT_HLUTNM of \bit_cnt[1]_i_1\ : label is "soft_lutpair6";
  attribute SOFT_HLUTNM of \bit_cnt[2]_i_1\ : label is "soft_lutpair6";
  attribute SOFT_HLUTNM of busy_i_1 : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \count[2]_i_2\ : label is "soft_lutpair5";
  attribute SOFT_HLUTNM of \count[6]_i_2\ : label is "soft_lutpair7";
  attribute SOFT_HLUTNM of \count[7]_i_2\ : label is "soft_lutpair12";
  attribute SOFT_HLUTNM of data_clk_prev_i_1 : label is "soft_lutpair13";
  attribute SOFT_HLUTNM of \data_rx[0]_i_1\ : label is "soft_lutpair11";
  attribute SOFT_HLUTNM of \data_rx[0]_i_2\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \data_rx[1]_i_1\ : label is "soft_lutpair10";
  attribute SOFT_HLUTNM of \data_rx[1]_i_2\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \data_rx[2]_i_1\ : label is "soft_lutpair8";
  attribute SOFT_HLUTNM of \data_rx[2]_i_2\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \data_rx[3]_i_1\ : label is "soft_lutpair11";
  attribute SOFT_HLUTNM of \data_rx[3]_i_2\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \data_rx[4]_i_1\ : label is "soft_lutpair10";
  attribute SOFT_HLUTNM of \data_rx[4]_i_2\ : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \data_rx[5]_i_1\ : label is "soft_lutpair9";
  attribute SOFT_HLUTNM of \data_rx[5]_i_2\ : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \data_rx[6]_i_1\ : label is "soft_lutpair9";
  attribute SOFT_HLUTNM of \data_rx[6]_i_2\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \data_rx[7]_i_1\ : label is "soft_lutpair8";
  attribute SOFT_HLUTNM of \data_rx[7]_i_2\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \data_rx[7]_i_3\ : label is "soft_lutpair13";
  attribute SOFT_HLUTNM of sda_int_i_6 : label is "soft_lutpair14";
  attribute SOFT_HLUTNM of stretch_i_3 : label is "soft_lutpair7";
  attribute SOFT_HLUTNM of stretch_i_5 : label is "soft_lutpair5";
  attribute SOFT_HLUTNM of stretch_i_6 : label is "soft_lutpair12";
begin
  ack_error <= \^ack_error\;
  busy <= \^busy\;
\FSM_sequential_state[0]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"01FF000001000000"
    )
        port map (
      I0 => \bit_cnt_reg_n_0_[2]\,
      I1 => \bit_cnt_reg_n_0_[1]\,
      I2 => \bit_cnt_reg_n_0_[0]\,
      I3 => \FSM_sequential_state[0]_i_2_n_0\,
      I4 => \FSM_sequential_state[0]_i_3_n_0\,
      I5 => ena,
      O => \FSM_sequential_state[0]_i_1_n_0\
    );
\FSM_sequential_state[0]_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => state(1),
      I1 => state(2),
      O => \FSM_sequential_state[0]_i_2_n_0\
    );
\FSM_sequential_state[0]_i_3\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => state(0),
      I1 => state(3),
      O => \FSM_sequential_state[0]_i_3_n_0\
    );
\FSM_sequential_state[1]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"0000F272"
    )
        port map (
      I0 => state(0),
      I1 => state(2),
      I2 => state(1),
      I3 => ena,
      I4 => state(3),
      O => \FSM_sequential_state[1]_i_1_n_0\
    );
\FSM_sequential_state[2]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"33200320"
    )
        port map (
      I0 => state(1),
      I1 => state(3),
      I2 => state(0),
      I3 => state(2),
      I4 => ena,
      O => \FSM_sequential_state[2]_i_1_n_0\
    );
\FSM_sequential_state[3]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => data_clk_reg_n_0,
      I1 => data_clk_prev,
      O => busy1
    );
\FSM_sequential_state[3]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0400"
    )
        port map (
      I0 => ena,
      I1 => state(2),
      I2 => state(3),
      I3 => state(0),
      O => \FSM_sequential_state[3]_i_2_n_0\
    );
\FSM_sequential_state_next[1]_i_3\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \^busy\,
      I1 => \^ack_error\,
      O => \FSM_sequential_state_next_reg[1]\
    );
\FSM_sequential_state_reg[0]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => busy1,
      CLR => btnCpuReset_IBUF,
      D => \FSM_sequential_state[0]_i_1_n_0\,
      Q => state(0)
    );
\FSM_sequential_state_reg[1]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => busy1,
      CLR => btnCpuReset_IBUF,
      D => \FSM_sequential_state[1]_i_1_n_0\,
      Q => state(1)
    );
\FSM_sequential_state_reg[2]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => busy1,
      CLR => btnCpuReset_IBUF,
      D => \FSM_sequential_state[2]_i_1_n_0\,
      Q => state(2)
    );
\FSM_sequential_state_reg[3]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => busy1,
      CLR => btnCpuReset_IBUF,
      D => \FSM_sequential_state[3]_i_2_n_0\,
      Q => state(3)
    );
\JA_IOBUF[0]_inst_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCCCCCCACCC5CCCC"
    )
        port map (
      I0 => data_clk_prev,
      I1 => sda_int_reg_n_0,
      I2 => state(2),
      I3 => state(1),
      I4 => state(3),
      I5 => state(0),
      O => JA_OBUF(0)
    );
\JA_IOBUF[0]_inst_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \JA_IOBUF[0]_inst_i_3_n_0\,
      O => \JA_TRI[0]\
    );
\JA_IOBUF[0]_inst_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0004FFFD0002FFFB"
    )
        port map (
      I0 => state(0),
      I1 => state(3),
      I2 => state(1),
      I3 => state(2),
      I4 => sda_int_reg_n_0,
      I5 => data_clk_prev,
      O => \JA_IOBUF[0]_inst_i_3_n_0\
    );
\JA_IOBUF[1]_inst_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \JA_IOBUF[1]_inst_i_2_n_0\,
      O => \JA_TRI[1]\
    );
\JA_IOBUF[1]_inst_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => scl_ena_reg_n_0,
      I1 => scl_clk_reg_n_0,
      O => \JA_IOBUF[1]_inst_i_2_n_0\
    );
ack_error_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFB8FF0000B800"
    )
        port map (
      I0 => ack_error_i_2_n_0,
      I1 => \FSM_sequential_state[0]_i_2_n_0\,
      I2 => scl_ena_reg_n_0,
      I3 => ack_error_i_3_n_0,
      I4 => ack_error_i_4_n_0,
      I5 => \^ack_error\,
      O => ack_error_i_1_n_0
    );
ack_error_i_2: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => JA_IBUF(0),
      I1 => \^ack_error\,
      O => ack_error_i_2_n_0
    );
ack_error_i_3: unisim.vcomponents.LUT6
    generic map(
      INIT => X"00000CC500000000"
    )
        port map (
      I0 => scl_ena_reg_n_0,
      I1 => ack_error_i_2_n_0,
      I2 => state(2),
      I3 => state(1),
      I4 => state(3),
      I5 => state(0),
      O => ack_error_i_3_n_0
    );
ack_error_i_4: unisim.vcomponents.LUT2
    generic map(
      INIT => X"B"
    )
        port map (
      I0 => data_clk_reg_n_0,
      I1 => data_clk_prev,
      O => ack_error_i_4_n_0
    );
ack_error_reg: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => '1',
      CLR => btnCpuReset_IBUF,
      D => ack_error_i_1_n_0,
      Q => \^ack_error\
    );
\bit_cnt[0]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => \bit_cnt[2]_i_2_n_0\,
      I1 => \bit_cnt_reg_n_0_[0]\,
      O => \bit_cnt[0]_i_1_n_0\
    );
\bit_cnt[1]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B4"
    )
        port map (
      I0 => \bit_cnt_reg_n_0_[0]\,
      I1 => \bit_cnt[2]_i_2_n_0\,
      I2 => \bit_cnt_reg_n_0_[1]\,
      O => \bit_cnt[1]_i_1_n_0\
    );
\bit_cnt[2]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"EF10"
    )
        port map (
      I0 => \bit_cnt_reg_n_0_[0]\,
      I1 => \bit_cnt_reg_n_0_[1]\,
      I2 => \bit_cnt[2]_i_2_n_0\,
      I3 => \bit_cnt_reg_n_0_[2]\,
      O => \bit_cnt[2]_i_1_n_0\
    );
\bit_cnt[2]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000E00000000"
    )
        port map (
      I0 => state(1),
      I1 => state(2),
      I2 => state(0),
      I3 => state(3),
      I4 => data_clk_prev,
      I5 => data_clk_reg_n_0,
      O => \bit_cnt[2]_i_2_n_0\
    );
\bit_cnt_reg[0]\: unisim.vcomponents.FDPE
    generic map(
      INIT => '1'
    )
        port map (
      C => CLK,
      CE => '1',
      D => \bit_cnt[0]_i_1_n_0\,
      PRE => btnCpuReset_IBUF,
      Q => \bit_cnt_reg_n_0_[0]\
    );
\bit_cnt_reg[1]\: unisim.vcomponents.FDPE
    generic map(
      INIT => '1'
    )
        port map (
      C => CLK,
      CE => '1',
      D => \bit_cnt[1]_i_1_n_0\,
      PRE => btnCpuReset_IBUF,
      Q => \bit_cnt_reg_n_0_[1]\
    );
\bit_cnt_reg[2]\: unisim.vcomponents.FDPE
    generic map(
      INIT => '1'
    )
        port map (
      C => CLK,
      CE => '1',
      D => \bit_cnt[2]_i_1_n_0\,
      PRE => btnCpuReset_IBUF,
      Q => \bit_cnt_reg_n_0_[2]\
    );
busy_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FBFF0800"
    )
        port map (
      I0 => busy_i_2_n_0,
      I1 => busy_i_3_n_0,
      I2 => data_clk_prev,
      I3 => data_clk_reg_n_0,
      I4 => \^busy\,
      O => busy_i_1_n_0
    );
busy_i_2: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00000BFE"
    )
        port map (
      I0 => ena,
      I1 => state(1),
      I2 => state(2),
      I3 => state(0),
      I4 => state(3),
      O => busy_i_2_n_0
    );
busy_i_3: unisim.vcomponents.LUT5
    generic map(
      INIT => X"0B0B003F"
    )
        port map (
      I0 => ena,
      I1 => state(0),
      I2 => state(3),
      I3 => state(1),
      I4 => state(2),
      O => busy_i_3_n_0
    );
busy_reg: unisim.vcomponents.FDPE
    generic map(
      INIT => '1'
    )
        port map (
      C => CLK,
      CE => '1',
      D => busy_i_1_n_0,
      PRE => btnCpuReset_IBUF,
      Q => \^busy\
    );
\count[0]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFBF00000000FFFF"
    )
        port map (
      I0 => count(3),
      I1 => count(1),
      I2 => count(2),
      I3 => \count[2]_i_2_n_0\,
      I4 => stretch,
      I5 => count(0),
      O => count_0(0)
    );
\count[1]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCCCC4CC33CC33CC"
    )
        port map (
      I0 => count(2),
      I1 => count(1),
      I2 => \count[2]_i_2_n_0\,
      I3 => count(0),
      I4 => count(3),
      I5 => stretch,
      O => count_0(1)
    );
\count[2]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCCCC4CC66CC66CC"
    )
        port map (
      I0 => count(1),
      I1 => count(2),
      I2 => \count[2]_i_2_n_0\,
      I3 => count(0),
      I4 => count(3),
      I5 => stretch,
      O => count_0(2)
    );
\count[2]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"7FFF"
    )
        port map (
      I0 => count(6),
      I1 => count(4),
      I2 => count(5),
      I3 => count(7),
      O => \count[2]_i_2_n_0\
    );
\count[3]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFF000000007FFF"
    )
        port map (
      I0 => count(6),
      I1 => count(4),
      I2 => count(5),
      I3 => count(7),
      I4 => \count[6]_i_2_n_0\,
      I5 => count(3),
      O => count_0(3)
    );
\count[4]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"F5F5F0F0050530F0"
    )
        port map (
      I0 => \count[6]_i_2_n_0\,
      I1 => count(5),
      I2 => count(4),
      I3 => count(6),
      I4 => count(3),
      I5 => \count[6]_i_3_n_0\,
      O => count_0(4)
    );
\count[5]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"F2F2F0F0525250F0"
    )
        port map (
      I0 => count(4),
      I1 => \count[6]_i_2_n_0\,
      I2 => count(5),
      I3 => count(6),
      I4 => count(3),
      I5 => \count[6]_i_3_n_0\,
      O => count_0(5)
    );
\count[6]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"F044FF00FF00FF00"
    )
        port map (
      I0 => \count[6]_i_2_n_0\,
      I1 => count(3),
      I2 => \count[6]_i_3_n_0\,
      I3 => count(6),
      I4 => count(4),
      I5 => count(5),
      O => count_0(6)
    );
\count[6]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FF7F"
    )
        port map (
      I0 => count(2),
      I1 => count(1),
      I2 => count(0),
      I3 => stretch,
      O => \count[6]_i_2_n_0\
    );
\count[6]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FF3F7F7FFFFFFFFF"
    )
        port map (
      I0 => count(7),
      I1 => count(1),
      I2 => count(2),
      I3 => stretch,
      I4 => count(3),
      I5 => count(0),
      O => \count[6]_i_3_n_0\
    );
\count[7]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCCCCCCCCC8C9C8C"
    )
        port map (
      I0 => \count[7]_i_2_n_0\,
      I1 => count(7),
      I2 => count(0),
      I3 => count(3),
      I4 => stretch,
      I5 => \count[7]_i_3_n_0\,
      O => count_0(7)
    );
\count[7]_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"7F"
    )
        port map (
      I0 => count(5),
      I1 => count(4),
      I2 => count(6),
      O => \count[7]_i_2_n_0\
    );
\count[7]_i_3\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"7"
    )
        port map (
      I0 => count(1),
      I1 => count(2),
      O => \count[7]_i_3_n_0\
    );
\count_reg[0]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => '1',
      CLR => btnCpuReset_IBUF,
      D => count_0(0),
      Q => count(0)
    );
\count_reg[1]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => '1',
      CLR => btnCpuReset_IBUF,
      D => count_0(1),
      Q => count(1)
    );
\count_reg[2]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => '1',
      CLR => btnCpuReset_IBUF,
      D => count_0(2),
      Q => count(2)
    );
\count_reg[3]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => '1',
      CLR => btnCpuReset_IBUF,
      D => count_0(3),
      Q => count(3)
    );
\count_reg[4]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => '1',
      CLR => btnCpuReset_IBUF,
      D => count_0(4),
      Q => count(4)
    );
\count_reg[5]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => '1',
      CLR => btnCpuReset_IBUF,
      D => count_0(5),
      Q => count(5)
    );
\count_reg[6]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => '1',
      CLR => btnCpuReset_IBUF,
      D => count_0(6),
      Q => count(6)
    );
\count_reg[7]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => '1',
      CLR => btnCpuReset_IBUF,
      D => count_0(7),
      Q => count(7)
    );
data_clk_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"E2"
    )
        port map (
      I0 => data_clk,
      I1 => btnCpuReset_IBUF,
      I2 => data_clk_reg_n_0,
      O => data_clk_i_1_n_0
    );
data_clk_i_2: unisim.vcomponents.LUT6
    generic map(
      INIT => X"55550004AAAAFABA"
    )
        port map (
      I0 => count(6),
      I1 => stretch_i_7_n_0,
      I2 => count(2),
      I3 => count(1),
      I4 => stretch_i_6_n_0,
      I5 => count(7),
      O => data_clk
    );
data_clk_prev_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"E2"
    )
        port map (
      I0 => data_clk_reg_n_0,
      I1 => btnCpuReset_IBUF,
      I2 => data_clk_prev,
      O => data_clk_prev_i_1_n_0
    );
data_clk_prev_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => '1',
      D => data_clk_prev_i_1_n_0,
      Q => data_clk_prev,
      R => '0'
    );
data_clk_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => '1',
      D => data_clk_i_1_n_0,
      Q => data_clk_reg_n_0,
      R => '0'
    );
\data_rd[7]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000010000000000"
    )
        port map (
      I0 => \bit_cnt_reg_n_0_[1]\,
      I1 => \bit_cnt_reg_n_0_[0]\,
      I2 => \bit_cnt_reg_n_0_[2]\,
      I3 => \data_rd[7]_i_2_n_0\,
      I4 => data_clk_prev,
      I5 => data_clk_reg_n_0,
      O => \data_rd[7]_i_1_n_0\
    );
\data_rd[7]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0200"
    )
        port map (
      I0 => state(2),
      I1 => state(0),
      I2 => state(3),
      I3 => state(1),
      O => \data_rd[7]_i_2_n_0\
    );
\data_rd_reg[0]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => \data_rd[7]_i_1_n_0\,
      CLR => btnCpuReset_IBUF,
      D => data_rx(0),
      Q => Q(0)
    );
\data_rd_reg[1]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => \data_rd[7]_i_1_n_0\,
      CLR => btnCpuReset_IBUF,
      D => data_rx(1),
      Q => Q(1)
    );
\data_rd_reg[2]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => \data_rd[7]_i_1_n_0\,
      CLR => btnCpuReset_IBUF,
      D => data_rx(2),
      Q => Q(2)
    );
\data_rd_reg[3]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => \data_rd[7]_i_1_n_0\,
      CLR => btnCpuReset_IBUF,
      D => data_rx(3),
      Q => Q(3)
    );
\data_rd_reg[4]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => \data_rd[7]_i_1_n_0\,
      CLR => btnCpuReset_IBUF,
      D => data_rx(4),
      Q => Q(4)
    );
\data_rd_reg[5]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => \data_rd[7]_i_1_n_0\,
      CLR => btnCpuReset_IBUF,
      D => data_rx(5),
      Q => Q(5)
    );
\data_rd_reg[6]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => \data_rd[7]_i_1_n_0\,
      CLR => btnCpuReset_IBUF,
      D => data_rx(6),
      Q => Q(6)
    );
\data_rd_reg[7]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => \data_rd[7]_i_1_n_0\,
      CLR => btnCpuReset_IBUF,
      D => data_rx(7),
      Q => Q(7)
    );
\data_rx[0]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"E4"
    )
        port map (
      I0 => \data_rx[0]_i_2_n_0\,
      I1 => data_rx(0),
      I2 => JA_IBUF(0),
      O => \data_rx[0]_i_1_n_0\
    );
\data_rx[0]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00000100"
    )
        port map (
      I0 => \bit_cnt_reg_n_0_[0]\,
      I1 => \bit_cnt_reg_n_0_[1]\,
      I2 => \bit_cnt_reg_n_0_[2]\,
      I3 => \data_rd[7]_i_2_n_0\,
      I4 => \data_rx[7]_i_3_n_0\,
      O => \data_rx[0]_i_2_n_0\
    );
\data_rx[1]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"E4"
    )
        port map (
      I0 => \data_rx[1]_i_2_n_0\,
      I1 => data_rx(1),
      I2 => JA_IBUF(0),
      O => \data_rx[1]_i_1_n_0\
    );
\data_rx[1]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00000400"
    )
        port map (
      I0 => \bit_cnt_reg_n_0_[2]\,
      I1 => \bit_cnt_reg_n_0_[0]\,
      I2 => \bit_cnt_reg_n_0_[1]\,
      I3 => \data_rd[7]_i_2_n_0\,
      I4 => \data_rx[7]_i_3_n_0\,
      O => \data_rx[1]_i_2_n_0\
    );
\data_rx[2]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"E4"
    )
        port map (
      I0 => \data_rx[2]_i_2_n_0\,
      I1 => data_rx(2),
      I2 => JA_IBUF(0),
      O => \data_rx[2]_i_1_n_0\
    );
\data_rx[2]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00000400"
    )
        port map (
      I0 => \bit_cnt_reg_n_0_[2]\,
      I1 => \bit_cnt_reg_n_0_[1]\,
      I2 => \bit_cnt_reg_n_0_[0]\,
      I3 => \data_rd[7]_i_2_n_0\,
      I4 => \data_rx[7]_i_3_n_0\,
      O => \data_rx[2]_i_2_n_0\
    );
\data_rx[3]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"E4"
    )
        port map (
      I0 => \data_rx[3]_i_2_n_0\,
      I1 => data_rx(3),
      I2 => JA_IBUF(0),
      O => \data_rx[3]_i_1_n_0\
    );
\data_rx[3]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00004000"
    )
        port map (
      I0 => \bit_cnt_reg_n_0_[2]\,
      I1 => \bit_cnt_reg_n_0_[0]\,
      I2 => \bit_cnt_reg_n_0_[1]\,
      I3 => \data_rd[7]_i_2_n_0\,
      I4 => \data_rx[7]_i_3_n_0\,
      O => \data_rx[3]_i_2_n_0\
    );
\data_rx[4]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"E4"
    )
        port map (
      I0 => \data_rx[4]_i_2_n_0\,
      I1 => data_rx(4),
      I2 => JA_IBUF(0),
      O => \data_rx[4]_i_1_n_0\
    );
\data_rx[4]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00000200"
    )
        port map (
      I0 => \bit_cnt_reg_n_0_[2]\,
      I1 => \bit_cnt_reg_n_0_[0]\,
      I2 => \bit_cnt_reg_n_0_[1]\,
      I3 => \data_rd[7]_i_2_n_0\,
      I4 => \data_rx[7]_i_3_n_0\,
      O => \data_rx[4]_i_2_n_0\
    );
\data_rx[5]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"E4"
    )
        port map (
      I0 => \data_rx[5]_i_2_n_0\,
      I1 => data_rx(5),
      I2 => JA_IBUF(0),
      O => \data_rx[5]_i_1_n_0\
    );
\data_rx[5]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00000800"
    )
        port map (
      I0 => \bit_cnt_reg_n_0_[2]\,
      I1 => \bit_cnt_reg_n_0_[0]\,
      I2 => \bit_cnt_reg_n_0_[1]\,
      I3 => \data_rd[7]_i_2_n_0\,
      I4 => \data_rx[7]_i_3_n_0\,
      O => \data_rx[5]_i_2_n_0\
    );
\data_rx[6]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"E4"
    )
        port map (
      I0 => \data_rx[6]_i_2_n_0\,
      I1 => data_rx(6),
      I2 => JA_IBUF(0),
      O => \data_rx[6]_i_1_n_0\
    );
\data_rx[6]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00000800"
    )
        port map (
      I0 => \bit_cnt_reg_n_0_[2]\,
      I1 => \bit_cnt_reg_n_0_[1]\,
      I2 => \bit_cnt_reg_n_0_[0]\,
      I3 => \data_rd[7]_i_2_n_0\,
      I4 => \data_rx[7]_i_3_n_0\,
      O => \data_rx[6]_i_2_n_0\
    );
\data_rx[7]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"E4"
    )
        port map (
      I0 => \data_rx[7]_i_2_n_0\,
      I1 => data_rx(7),
      I2 => JA_IBUF(0),
      O => \data_rx[7]_i_1_n_0\
    );
\data_rx[7]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00008000"
    )
        port map (
      I0 => \bit_cnt_reg_n_0_[2]\,
      I1 => \bit_cnt_reg_n_0_[0]\,
      I2 => \bit_cnt_reg_n_0_[1]\,
      I3 => \data_rd[7]_i_2_n_0\,
      I4 => \data_rx[7]_i_3_n_0\,
      O => \data_rx[7]_i_2_n_0\
    );
\data_rx[7]_i_3\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"FB"
    )
        port map (
      I0 => btnCpuReset_IBUF,
      I1 => data_clk_prev,
      I2 => data_clk_reg_n_0,
      O => \data_rx[7]_i_3_n_0\
    );
\data_rx_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => '1',
      D => \data_rx[0]_i_1_n_0\,
      Q => data_rx(0),
      R => '0'
    );
\data_rx_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => '1',
      D => \data_rx[1]_i_1_n_0\,
      Q => data_rx(1),
      R => '0'
    );
\data_rx_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => '1',
      D => \data_rx[2]_i_1_n_0\,
      Q => data_rx(2),
      R => '0'
    );
\data_rx_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => '1',
      D => \data_rx[3]_i_1_n_0\,
      Q => data_rx(3),
      R => '0'
    );
\data_rx_reg[4]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => '1',
      D => \data_rx[4]_i_1_n_0\,
      Q => data_rx(4),
      R => '0'
    );
\data_rx_reg[5]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => '1',
      D => \data_rx[5]_i_1_n_0\,
      Q => data_rx(5),
      R => '0'
    );
\data_rx_reg[6]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => '1',
      D => \data_rx[6]_i_1_n_0\,
      Q => data_rx(6),
      R => '0'
    );
\data_rx_reg[7]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => '1',
      D => \data_rx[7]_i_1_n_0\,
      Q => data_rx(7),
      R => '0'
    );
scl_clk_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBA00BA"
    )
        port map (
      I0 => scl_clk_i_2_n_0,
      I1 => count(0),
      I2 => count(7),
      I3 => btnCpuReset_IBUF,
      I4 => scl_clk_reg_n_0,
      O => scl_clk_i_1_n_0
    );
scl_clk_i_2: unisim.vcomponents.LUT6
    generic map(
      INIT => X"ACAEA4AEAAAAAEAA"
    )
        port map (
      I0 => count(7),
      I1 => count(3),
      I2 => \count[7]_i_2_n_0\,
      I3 => count(1),
      I4 => stretch_i_7_n_0,
      I5 => count(2),
      O => scl_clk_i_2_n_0
    );
scl_clk_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => '1',
      D => scl_clk_i_1_n_0,
      Q => scl_clk_reg_n_0,
      R => '0'
    );
scl_ena_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FF00FF00EF04FF00"
    )
        port map (
      I0 => \FSM_sequential_state[0]_i_2_n_0\,
      I1 => state(0),
      I2 => state(3),
      I3 => scl_ena_reg_n_0,
      I4 => data_clk_prev,
      I5 => data_clk_reg_n_0,
      O => scl_ena_i_1_n_0
    );
scl_ena_reg: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => '1',
      CLR => btnCpuReset_IBUF,
      D => scl_ena_i_1_n_0,
      Q => scl_ena_reg_n_0
    );
sda_int_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFEFFFFF00E00000"
    )
        port map (
      I0 => sda_int_i_2_n_0,
      I1 => sda_int_i_3_n_0,
      I2 => sda_int_i_4_n_0,
      I3 => data_clk_prev,
      I4 => data_clk_reg_n_0,
      I5 => sda_int_reg_n_0,
      O => sda_int_i_1_n_0
    );
sda_int_i_2: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFF0B0A0000"
    )
        port map (
      I0 => state(0),
      I1 => ena,
      I2 => state(3),
      I3 => state(2),
      I4 => state(1),
      I5 => sda_int_i_5_n_0,
      O => sda_int_i_2_n_0
    );
sda_int_i_3: unisim.vcomponents.LUT6
    generic map(
      INIT => X"00000004CC000C0C"
    )
        port map (
      I0 => state(1),
      I1 => \FSM_sequential_state[0]_i_3_n_0\,
      I2 => \bit_cnt_reg_n_0_[1]\,
      I3 => \bit_cnt_reg_n_0_[0]\,
      I4 => \bit_cnt_reg_n_0_[2]\,
      I5 => state(2),
      O => sda_int_i_3_n_0
    );
sda_int_i_4: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000AFFC0000AF3C"
    )
        port map (
      I0 => ena,
      I1 => state(1),
      I2 => state(2),
      I3 => state(0),
      I4 => state(3),
      I5 => sda_int_i_6_n_0,
      O => sda_int_i_4_n_0
    );
sda_int_i_5: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000000000045"
    )
        port map (
      I0 => state(3),
      I1 => \bit_cnt_reg_n_0_[2]\,
      I2 => \bit_cnt_reg_n_0_[1]\,
      I3 => \bit_cnt_reg_n_0_[0]\,
      I4 => state(2),
      I5 => state(1),
      O => sda_int_i_5_n_0
    );
sda_int_i_6: unisim.vcomponents.LUT3
    generic map(
      INIT => X"01"
    )
        port map (
      I0 => \bit_cnt_reg_n_0_[1]\,
      I1 => \bit_cnt_reg_n_0_[0]\,
      I2 => \bit_cnt_reg_n_0_[2]\,
      O => sda_int_i_6_n_0
    );
sda_int_reg: unisim.vcomponents.FDPE
    generic map(
      INIT => '1'
    )
        port map (
      C => CLK,
      CE => '1',
      D => sda_int_i_1_n_0,
      PRE => btnCpuReset_IBUF,
      Q => sda_int_reg_n_0
    );
stretch_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAAEAFAFAAA2A0A0"
    )
        port map (
      I0 => scl_ena_reg_0,
      I1 => stretch_i_3_n_0,
      I2 => stretch_i_4_n_0,
      I3 => count(2),
      I4 => stretch_i_5_n_0,
      I5 => stretch,
      O => stretch_i_1_n_0
    );
stretch_i_3: unisim.vcomponents.LUT3
    generic map(
      INIT => X"DF"
    )
        port map (
      I0 => count(0),
      I1 => stretch,
      I2 => count(1),
      O => stretch_i_3_n_0
    );
stretch_i_4: unisim.vcomponents.LUT6
    generic map(
      INIT => X"4040404440404040"
    )
        port map (
      I0 => count(6),
      I1 => count(7),
      I2 => stretch_i_6_n_0,
      I3 => count(2),
      I4 => count(1),
      I5 => stretch_i_7_n_0,
      O => stretch_i_4_n_0
    );
stretch_i_5: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00008000"
    )
        port map (
      I0 => count(5),
      I1 => count(4),
      I2 => count(6),
      I3 => count(3),
      I4 => count(7),
      O => stretch_i_5_n_0
    );
stretch_i_6: unisim.vcomponents.LUT3
    generic map(
      INIT => X"7F"
    )
        port map (
      I0 => count(5),
      I1 => count(4),
      I2 => count(3),
      O => stretch_i_6_n_0
    );
stretch_i_7: unisim.vcomponents.LUT2
    generic map(
      INIT => X"B"
    )
        port map (
      I0 => stretch,
      I1 => count(0),
      O => stretch_i_7_n_0
    );
stretch_reg: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => CLK,
      CE => '1',
      CLR => btnCpuReset_IBUF,
      D => stretch_i_1_n_0,
      Q => stretch
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity serialLoader is
  port (
    E : out STD_LOGIC_VECTOR ( 0 to 0 );
    FIFO_ReadEn : out STD_LOGIC;
    Q : out STD_LOGIC_VECTOR ( 7 downto 0 );
    D : in STD_LOGIC_VECTOR ( 7 downto 0 );
    clk_IBUF_BUFG : in STD_LOGIC;
    \txState_reg[0]\ : in STD_LOGIC;
    \txState_reg[1]\ : in STD_LOGIC;
    FIFO_Empty : in STD_LOGIC
  );
end serialLoader;

architecture STRUCTURE of serialLoader is
  signal FIFO_ReadEn_reg_i_1_n_0 : STD_LOGIC;
  signal \FSM_sequential_state_next[0]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state_next[1]_i_1__0_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state_next[2]_i_1_n_0\ : STD_LOGIC;
  signal \S_DataOut_reg[7]_i_1_n_0\ : STD_LOGIC;
  signal S_Send_reg_i_1_n_0 : STD_LOGIC;
  signal S_Send_reg_i_2_n_0 : STD_LOGIC;
  signal state_next : STD_LOGIC_VECTOR ( 2 downto 0 );
  attribute RTL_KEEP : string;
  attribute RTL_KEEP of state_next : signal is "yes";
  attribute XILINX_LEGACY_PRIM : string;
  attribute XILINX_LEGACY_PRIM of FIFO_ReadEn_reg : label is "LD";
  attribute KEEP : string;
  attribute KEEP of \FSM_sequential_state_next_reg[0]\ : label is "yes";
  attribute KEEP of \FSM_sequential_state_next_reg[1]\ : label is "yes";
  attribute KEEP of \FSM_sequential_state_next_reg[2]\ : label is "yes";
  attribute XILINX_LEGACY_PRIM of \S_DataOut_reg[0]\ : label is "LD";
  attribute XILINX_LEGACY_PRIM of \S_DataOut_reg[1]\ : label is "LD";
  attribute XILINX_LEGACY_PRIM of \S_DataOut_reg[2]\ : label is "LD";
  attribute XILINX_LEGACY_PRIM of \S_DataOut_reg[3]\ : label is "LD";
  attribute XILINX_LEGACY_PRIM of \S_DataOut_reg[4]\ : label is "LD";
  attribute XILINX_LEGACY_PRIM of \S_DataOut_reg[5]\ : label is "LD";
  attribute XILINX_LEGACY_PRIM of \S_DataOut_reg[6]\ : label is "LD";
  attribute XILINX_LEGACY_PRIM of \S_DataOut_reg[7]\ : label is "LD";
  attribute XILINX_LEGACY_PRIM of S_Send_reg : label is "LD";
begin
FIFO_ReadEn_reg: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => FIFO_ReadEn_reg_i_1_n_0,
      G => \FSM_sequential_state_next[1]_i_1__0_n_0\,
      GE => '1',
      Q => FIFO_ReadEn
    );
FIFO_ReadEn_reg_i_1: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => state_next(1),
      I1 => state_next(2),
      O => FIFO_ReadEn_reg_i_1_n_0
    );
\FSM_sequential_state_next[0]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000144444445"
    )
        port map (
      I0 => state_next(0),
      I1 => state_next(1),
      I2 => \txState_reg[0]\,
      I3 => \txState_reg[1]\,
      I4 => FIFO_Empty,
      I5 => state_next(2),
      O => \FSM_sequential_state_next[0]_i_1_n_0\
    );
\FSM_sequential_state_next[1]_i_1__0\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"06"
    )
        port map (
      I0 => state_next(1),
      I1 => state_next(0),
      I2 => state_next(2),
      O => \FSM_sequential_state_next[1]_i_1__0_n_0\
    );
\FSM_sequential_state_next[2]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"40"
    )
        port map (
      I0 => state_next(2),
      I1 => state_next(0),
      I2 => state_next(1),
      O => \FSM_sequential_state_next[2]_i_1_n_0\
    );
\FSM_sequential_state_next_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \FSM_sequential_state_next[0]_i_1_n_0\,
      Q => state_next(0),
      R => '0'
    );
\FSM_sequential_state_next_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \FSM_sequential_state_next[1]_i_1__0_n_0\,
      Q => state_next(1),
      R => '0'
    );
\FSM_sequential_state_next_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_IBUF_BUFG,
      CE => '1',
      D => \FSM_sequential_state_next[2]_i_1_n_0\,
      Q => state_next(2),
      R => '0'
    );
\S_DataOut_reg[0]\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => D(0),
      G => \S_DataOut_reg[7]_i_1_n_0\,
      GE => '1',
      Q => Q(0)
    );
\S_DataOut_reg[1]\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => D(1),
      G => \S_DataOut_reg[7]_i_1_n_0\,
      GE => '1',
      Q => Q(1)
    );
\S_DataOut_reg[2]\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => D(2),
      G => \S_DataOut_reg[7]_i_1_n_0\,
      GE => '1',
      Q => Q(2)
    );
\S_DataOut_reg[3]\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => D(3),
      G => \S_DataOut_reg[7]_i_1_n_0\,
      GE => '1',
      Q => Q(3)
    );
\S_DataOut_reg[4]\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => D(4),
      G => \S_DataOut_reg[7]_i_1_n_0\,
      GE => '1',
      Q => Q(4)
    );
\S_DataOut_reg[5]\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => D(5),
      G => \S_DataOut_reg[7]_i_1_n_0\,
      GE => '1',
      Q => Q(5)
    );
\S_DataOut_reg[6]\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => D(6),
      G => \S_DataOut_reg[7]_i_1_n_0\,
      GE => '1',
      Q => Q(6)
    );
\S_DataOut_reg[7]\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => D(7),
      G => \S_DataOut_reg[7]_i_1_n_0\,
      GE => '1',
      Q => Q(7)
    );
\S_DataOut_reg[7]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"02"
    )
        port map (
      I0 => state_next(1),
      I1 => state_next(2),
      I2 => state_next(0),
      O => \S_DataOut_reg[7]_i_1_n_0\
    );
S_Send_reg: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => '0',
      D => S_Send_reg_i_1_n_0,
      G => S_Send_reg_i_2_n_0,
      GE => '1',
      Q => E(0)
    );
S_Send_reg_i_1: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => state_next(2),
      O => S_Send_reg_i_1_n_0
    );
S_Send_reg_i_2: unisim.vcomponents.LUT3
    generic map(
      INIT => X"24"
    )
        port map (
      I0 => state_next(0),
      I1 => state_next(2),
      I2 => state_next(1),
      O => S_Send_reg_i_2_n_0
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity topmodule is
  port (
    clk : in STD_LOGIC;
    JA : inout STD_LOGIC_VECTOR ( 1 downto 0 );
    RsTx : out STD_LOGIC;
    btnCpuReset : in STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of topmodule : entity is true;
end topmodule;

architecture STRUCTURE of topmodule is
  signal FIFO_DataIn : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal FIFO_DataOut : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal FIFO_Empty : STD_LOGIC;
  signal FIFO_ReadEn : STD_LOGIC;
  signal FIFO_WriteEn : STD_LOGIC;
  signal JA_IBUF : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal JA_OBUF : STD_LOGIC_VECTOR ( 0 to 0 );
  signal \JA_TRI[0]\ : STD_LOGIC;
  signal \JA_TRI[1]\ : STD_LOGIC;
  signal RsTx_OBUF : STD_LOGIC;
  signal ack_error : STD_LOGIC;
  signal btnCpuReset_IBUF : STD_LOGIC;
  signal busy : STD_LOGIC;
  signal clk_IBUF : STD_LOGIC;
  signal clk_IBUF_BUFG : STD_LOGIC;
  signal data_rd : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal ena : STD_LOGIC;
  signal i2ccomms_unit_n_12 : STD_LOGIC;
  signal send : STD_LOGIC;
  signal serialData : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal serial_unit_n_1 : STD_LOGIC;
  signal serial_unit_n_2 : STD_LOGIC;
  signal stretch_reg_i_2_n_0 : STD_LOGIC;
begin
\JA_IOBUF[0]_inst\: unisim.vcomponents.IOBUF
     port map (
      I => JA_OBUF(0),
      IO => JA(0),
      O => JA_IBUF(0),
      T => \JA_TRI[0]\
    );
\JA_IOBUF[1]_inst\: unisim.vcomponents.IOBUF
     port map (
      I => '0',
      IO => JA(1),
      O => JA_IBUF(1),
      T => \JA_TRI[1]\
    );
RsTx_OBUF_inst: unisim.vcomponents.OBUF
     port map (
      I => RsTx_OBUF,
      O => RsTx
    );
btnCpuReset_IBUF_inst: unisim.vcomponents.IBUF
     port map (
      I => btnCpuReset,
      O => btnCpuReset_IBUF
    );
clk_IBUF_BUFG_inst: unisim.vcomponents.BUFG
     port map (
      I => clk_IBUF,
      O => clk_IBUF_BUFG
    );
clk_IBUF_inst: unisim.vcomponents.IBUF
     port map (
      I => clk,
      O => clk_IBUF
    );
i2cControl_unit: entity work.i2c_controller
     port map (
      CLK => clk_IBUF_BUFG,
      FIFO_WriteEn => FIFO_WriteEn,
      Q(7 downto 0) => FIFO_DataIn(7 downto 0),
      ack_error => ack_error,
      busy => busy,
      busy_reg => i2ccomms_unit_n_12,
      \data_rd_reg[7]\(7 downto 0) => data_rd(7 downto 0),
      ena => ena
    );
i2ccomms_unit: entity work.i2c_master
     port map (
      CLK => clk_IBUF_BUFG,
      \FSM_sequential_state_next_reg[1]\ => i2ccomms_unit_n_12,
      JA_IBUF(0) => JA_IBUF(0),
      JA_OBUF(0) => JA_OBUF(0),
      \JA_TRI[0]\ => \JA_TRI[0]\,
      \JA_TRI[1]\ => \JA_TRI[1]\,
      Q(7 downto 0) => data_rd(7 downto 0),
      ack_error => ack_error,
      btnCpuReset_IBUF => btnCpuReset_IBUF,
      busy => busy,
      ena => ena,
      scl_ena_reg_0 => stretch_reg_i_2_n_0
    );
serialFIFObuffer_unit: entity work.STD_FIFO
     port map (
      D(7 downto 0) => FIFO_DataOut(7 downto 0),
      FIFO_Empty => FIFO_Empty,
      FIFO_ReadEn => FIFO_ReadEn,
      FIFO_WriteEn => FIFO_WriteEn,
      Q(7 downto 0) => FIFO_DataIn(7 downto 0),
      btnCpuReset_IBUF => btnCpuReset_IBUF,
      clk_IBUF_BUFG => clk_IBUF_BUFG
    );
serialLoader_unit: entity work.serialLoader
     port map (
      D(7 downto 0) => FIFO_DataOut(7 downto 0),
      E(0) => send,
      FIFO_Empty => FIFO_Empty,
      FIFO_ReadEn => FIFO_ReadEn,
      Q(7 downto 0) => serialData(7 downto 0),
      clk_IBUF_BUFG => clk_IBUF_BUFG,
      \txState_reg[0]\ => serial_unit_n_1,
      \txState_reg[1]\ => serial_unit_n_2
    );
serial_unit: entity work.UART_TX_CTRL
     port map (
      D(7 downto 0) => serialData(7 downto 0),
      E(0) => send,
      RsTx_OBUF => RsTx_OBUF,
      \bitTmr_reg[13]_0\ => serial_unit_n_1,
      \bitTmr_reg[13]_1\ => serial_unit_n_2,
      clk_IBUF_BUFG => clk_IBUF_BUFG
    );
stretch_reg_i_2: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => JA_IBUF(1),
      O => stretch_reg_i_2_n_0
    );
end STRUCTURE;
