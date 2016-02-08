-------------------------------------------------------------------------------
--  axi_emc_addr_gen - entity/architecture pair
-------------------------------------------------------------------------------
-------------------------------------------------------------------
-- (c) Copyright 1984 - 2012 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Filename:        axi_emc_addr_gen.vhd
-- Version:         v2.0
-- Description:     This file includes the logic for address generataion on
--                  IP interface based upon the AXI transactions.
-------------------------------------------------------------------------------
-- Structure:
--              axi_emc.vhd
--                  -- axi_emc_native_interface.vhd
--                     -- axi_emc_addr_gen.vhd
--                     -- axi_emc_address_decode.vhd
--                  -- emc.vhd
--                      -- ipic_if.vhd
--                      -- addr_counter_mux.vhd
--                      -- counters.vhd
--                      -- select_param.vhd
--                      -- mem_state_machine.vhd
--                      -- mem_steer.vhd
--                      -- io_registers.vhd
-------------------------------------------------------------------------------
-- Author:      SK
--
-- History:
--  SK 10/02/10
-- ~~~~~~
--  -- Created the new version v1.01.a
-- ~~~~~~
-- ~~~~~~
--  Sateesh 2011
-- ^^^^^^
--  -- Added Sync burst support for the Numonyx flash during read
-- ~~~~~~
-- ~~~~~~
--  SK 10/20/12
-- ^^^^^^
--  -- Fixed CR 672770 - BRESP signal is driven X during netlist simulation
--  -- Fixed CR 673491 - Flash transactions generates extra read cycle after the actual reads are over
-- ~~~~~~

-------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x"
--      reset signals:                          "rst", "rst_n"
--      generics:                               "C_*"
--      user defined types:                     "*_TYPE"
--      state machine next state:               "*_ns"
--      state machine current state:            "*_cs"
--      combinatorial signals:                  "*_cmb"
--      pipelined or register delay signals:    "*_d#"
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce"
--      internal version of output port         "*_i"
--      device pins:                            "*_pin"
--      ports:                                  - Names begin with Uppercase
--      processes:                              "*_PROCESS"
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.std_logic_arith.conv_std_logic_vector;
use ieee.numeric_std.all;
use ieee.std_logic_misc.or_reduce;
use ieee.std_logic_misc.and_reduce;
-------------------------------------------------------------------------------
entity axi_emc_addr_gen is
    generic(
    C_S_AXI_MEM_ADDR_WIDTH     : integer range 32 to 32 := 32;
    C_S_AXI_MEM_DATA_WIDTH     : integer range 32 to 64 := 32
    );
    port(
    Bus2IP_Clk           : in std_logic;
    Bus2IP_Resetn        : in std_logic;
    Cre_reg_en           : in std_logic;
    -- combo I/P signals
    stop_addr_incr       : in std_logic;
    Store_addr_info_cmb  : in std_logic;
    Addr_int_cmb         : in std_logic_vector((C_S_AXI_MEM_ADDR_WIDTH-1)downto 0);
    Ip2Bus_Addr_ack      : in std_logic;
    Fifo_full_1          : in std_logic;
    derived_len_reg      : in std_logic_vector(3 downto 0);
    Rst_Rd_CE            : in std_logic;
    -- registered signals
    Derived_burst_reg    : in std_logic_vector(1 downto 0);
    Derived_size_reg     : in std_logic_vector(1 downto 0);
    -- registered O/P signals
    Bus2IP_Addr          : out std_logic_vector((C_S_AXI_MEM_ADDR_WIDTH-1)downto 0)

    );
end entity axi_emc_addr_gen;
-----------------------

------------------------------------
architecture imp of axi_emc_addr_gen is
------------------------------------
--------------------------------------------------------------------------------
-- Function clog2 - returns the integer ceiling of the base 2 logarithm of x,
--                  i.e., the least integer greater than or equal to log2(x).
--------------------------------------------------------------------------------
function clog2(x : positive) return natural is
  variable r  : natural := 0;
  variable rp : natural := 1; -- rp tracks the value 2**r
begin 
  while rp < x loop -- Termination condition T: x <= 2**r
    -- Loop invariant L: 2**(r-1) < x
    r := r + 1;
    if rp > integer'high - rp then exit; end if;  -- If doubling rp overflows
      -- the integer range, the doubled value would exceed x, so safe to exit.
    rp := rp + rp;
  end loop;
  -- L and T  <->  2**(r-1) < x <= 2**r  <->  (r-1) < log2(x) <= r
  return r; --
end clog2;    
----------------------------------------------------------------------------------
-- below attributes are added to reduce the synth warnings in Vivado tool
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of imp : architecture is "yes";
----------------------------------------------------------------------------------

constant ACTIVE_LOW_RESET : integer := 0;

signal bus2ip_addr_i        : std_logic_vector
                              ((C_S_AXI_MEM_ADDR_WIDTH-1) downto ((clog2(C_S_AXI_MEM_DATA_WIDTH/8))-1)) := (OTHERS => '0');
signal int_addr_enable_11_2 : std_logic;
signal addr_sel_0           : std_logic;
signal addr_sel_1           : std_logic;
signal addr_sel_2           : std_logic;
signal addr_sel_3           : std_logic;

signal Bus2IP_Addr_lower_bits_reg_i : std_logic_vector(((clog2(C_S_AXI_MEM_DATA_WIDTH/8))-1) downto 0);
signal Bus2IP_Addr_lower_bits_cmb_i : std_logic_vector(((clog2(C_S_AXI_MEM_DATA_WIDTH/8))-1) downto 0);
signal Bus2IP_Addr_lower_bits       : std_logic_vector(((clog2(C_S_AXI_MEM_DATA_WIDTH/8))-1) downto 0);
-----
begin
-----
---====================---
--*** axi_emc_addr_gen logic ***--
---====================---

--bus2ip_addr_i (0) <= '0';
--bus2ip_addr_i (1) <= '0';

 Bus2IP_Addr <= bus2ip_addr_i((C_S_AXI_MEM_ADDR_WIDTH-1) downto (clog2(C_S_AXI_MEM_DATA_WIDTH/8))) & Bus2IP_Addr_lower_bits;


 Bus2IP_Addr_lower_bits   <= Bus2IP_Addr_lower_bits_cmb_i(((clog2(C_S_AXI_MEM_DATA_WIDTH/8))-1) downto 0)
                             when Cre_reg_en = '0'
                             else
                             Bus2IP_Addr_lower_bits_reg_i(((clog2(C_S_AXI_MEM_DATA_WIDTH/8))-1) downto 0);


 ----------- all addresses are word/dword aligned addresses, only the BE decide
 --          which byte lane to be accessed


 Bus2IP_Addr_lower_bits_cmb_i(((clog2(C_S_AXI_MEM_DATA_WIDTH/8))-1) downto 0) <= (others => '0');
 ---------------------------------------------------------------------------------

 -- ADDR_BITS_LAST_3_OR_3_BITS_REG_P: Address registering for lower 3 or 2 bits
 ---------------------
 ADDR_BITS_LAST_3_OR_3_BITS_REG_P:process(Bus2IP_Clk)
 ---------------------
 begin
     if (Bus2IP_Clk'event and Bus2IP_Clk='1') then
        if((Bus2IP_Resetn = '0')) then
           Bus2IP_Addr_lower_bits_reg_i(((clog2(C_S_AXI_MEM_DATA_WIDTH/8))-1) downto 0) <= (others => '0');
        elsif(Store_addr_info_cmb = '1')then
           Bus2IP_Addr_lower_bits_reg_i(((clog2(C_S_AXI_MEM_DATA_WIDTH/8))-1) downto 0) <= Addr_int_cmb(((clog2(C_S_AXI_MEM_DATA_WIDTH/8))-1) downto 0);
        end if;
     end if;
 end process ADDR_BITS_LAST_3_OR_3_BITS_REG_P;
 ----------------------------------

 -- ADDR_BITS_31_12_REG_P: Address registering for upper order address bits
 ---------------------
 ADDR_BITS_31_12_REG_P:process(Bus2IP_Clk)
 ---------------------
 begin
     if (Bus2IP_Clk'event and Bus2IP_Clk='1') then
        if((Bus2IP_Resetn = '0')) then
           bus2ip_addr_i(31 downto 12) <= (others => '0');
        elsif(Store_addr_info_cmb = '1')then
           bus2ip_addr_i(31 downto 12) <= Addr_int_cmb(31 downto 12);
        end if;
     end if;
 end process ADDR_BITS_31_12_REG_P;
 ----------------------------------
 int_addr_enable_11_2     <= ( Store_addr_info_cmb
                               or
                               (Ip2Bus_Addr_ack and
                                (not Fifo_full_1) and (not stop_addr_incr)
                                )
                              );
----------- Below are the select line for MUX operation
addr_sel_0 <= (derived_len_reg(0) and Derived_burst_reg(1))
              or
              Derived_burst_reg(0);
addr_sel_1 <= (derived_len_reg(1) and Derived_burst_reg(1))
              or
              Derived_burst_reg(0);
addr_sel_2 <= (derived_len_reg(2) and Derived_burst_reg(1))
              or
              Derived_burst_reg(0);
addr_sel_3 <= (derived_len_reg(3) and Derived_burst_reg(1))
              or
              Derived_burst_reg(0);
-----------
 --------------------------------------
--BUS2IP_ADDR_GEN_DATA_WDTH_32:Address geenration for logic for 32 bit data bus
-- ============================
BUS2IP_ADDR_GEN_DATA_WDTH_32: if C_S_AXI_MEM_DATA_WIDTH = 32 generate
----------------------------
 -- address(2) calculation
 signal calc_addr_2: std_logic_vector(1 downto 0);
 signal addr_2_int : std_logic;
 signal addr_2_cmb : std_logic;
 -- address(3) calculation
 signal calc_addr_3: std_logic_vector(1 downto 0);
 signal addr_3_int : std_logic;
 signal addr_3_cmb : std_logic;
 -- address(4) calculation
 signal calc_addr_4: std_logic_vector(1 downto 0);
 signal addr_4_int : std_logic;
 signal addr_4_cmb : std_logic;
 -- address(5) calculation
 signal calc_addr_5: std_logic_vector(1 downto 0);
 signal addr_5_int : std_logic;
 signal addr_5_cmb : std_logic;
 -- address(11:6) calculation
 signal calc_addr_11_6: std_logic_vector(6 downto 0);
 signal addr_11_6_int : std_logic_vector(5 downto 0);
 signal addr_11_6_cmb : std_logic_vector(5 downto 0);
 -- address(6) calculation
 signal calc_addr_6: std_logic_vector(1 downto 0);
 signal addr_6_int : std_logic_vector(1 downto 0);
 signal addr_6_cmb : std_logic_vector(1 downto 0);
 signal address_carry : std_logic;
 signal internal_count : std_logic_vector(2 downto 0)    :=(others => '0');
 -----
 begin
 -----

 -------------------
 -- INT_COUNTER_P32: to store the the internal address lower bits
 -------------------
 INT_COUNTER_P32: process(Bus2IP_Clk) is
 begin
    if (Bus2IP_Clk'event and Bus2IP_Clk='1') then
        if (Store_addr_info_cmb='1') then
                internal_count <= '0' & Addr_int_cmb(1 downto 0);
        elsif(
               (Ip2Bus_Addr_ack='1') and
               (Fifo_full_1='0')
              )then
                internal_count <= internal_count + Derived_size_reg + '1';
        end if;
    end if;
 end process INT_COUNTER_P32;
-------------------

 address_Carry <= Derived_size_reg(1) or
                 (Derived_size_reg(0) and internal_count(1))or
                 (internal_count(0) and internal_count(1));

 calc_addr_2 <= ('0' & bus2ip_addr_i(2)) + ('0' & address_Carry);

 addr_2_int  <= calc_addr_2(0) when (addr_sel_0='1') else bus2ip_addr_i(2);

 addr_2_cmb  <= Addr_int_cmb(2) when (Store_addr_info_cmb='1') else addr_2_int;

--  ADDR_BITS_2_REG_P: store the 2nd address bit
 ------------------
 ADDR_BITS_2_REG_P:process(Bus2IP_Clk)
 ------------------
 begin
     if (Bus2IP_Clk'event and Bus2IP_Clk='1') then
        if((Bus2IP_Resetn = '0')) then
           bus2ip_addr_i(2) <= '0';
        elsif(int_addr_enable_11_2 = '1')then
           bus2ip_addr_i(2) <= addr_2_cmb;
        end if;
     end if;
 end process ADDR_BITS_2_REG_P;
 ------------------

 calc_addr_3 <= ('0' & bus2ip_addr_i(3)) + ('0' & calc_addr_2(1));

 addr_3_int  <= calc_addr_3(0) when (addr_sel_1='1') else bus2ip_addr_i(3);

 addr_3_cmb  <= Addr_int_cmb(3) when (Store_addr_info_cmb='1') else addr_3_int;

--  ADDR_BITS_3_REG_P: store the third address bit
 ------------------
 ADDR_BITS_3_REG_P:process(Bus2IP_Clk)
 ------------------
 begin
     if (Bus2IP_Clk'event and Bus2IP_Clk='1') then
        if((Bus2IP_Resetn = '0')) then
           bus2ip_addr_i(3) <= '0';
        elsif(int_addr_enable_11_2 = '1')then
           bus2ip_addr_i(3) <= addr_3_cmb;
        end if;
     end if;
 end process ADDR_BITS_3_REG_P;
 ------------------

 calc_addr_4 <= ('0' & bus2ip_addr_i(4)) + ('0' & calc_addr_3(1));

 addr_4_int  <= calc_addr_4(0) when (addr_sel_2='1') else bus2ip_addr_i(4);

 addr_4_cmb  <= Addr_int_cmb(4) when (Store_addr_info_cmb='1') else addr_4_int;

--  ADDR_BITS_4_REG_P: store the 4th address bit
 ------------------
 ADDR_BITS_4_REG_P:process(Bus2IP_Clk)
 ------------------
 begin
     if (Bus2IP_Clk'event and Bus2IP_Clk='1') then
        if((Bus2IP_Resetn = '0')) then
           bus2ip_addr_i(4) <= '0';
        elsif(int_addr_enable_11_2 = '1')then
           bus2ip_addr_i(4) <= addr_4_cmb;
        end if;
     end if;
 end process ADDR_BITS_4_REG_P;
 ------------------

 calc_addr_5 <= ('0' & bus2ip_addr_i(5)) + ('0' & calc_addr_4(1));

 addr_5_int <= calc_addr_5(0) when (addr_sel_3='1') else bus2ip_addr_i(5);

 addr_5_cmb <= Addr_int_cmb(5) when (Store_addr_info_cmb='1') else addr_5_int;

--  ADDR_BITS_5_REG_P:store the 5th address bit
 ------------------
 ADDR_BITS_5_REG_P:process(Bus2IP_Clk)
 ------------------
 begin
     if (Bus2IP_Clk'event and Bus2IP_Clk='1') then
        if((Bus2IP_Resetn = '0')) then
           bus2ip_addr_i(5) <= '0';
        elsif(int_addr_enable_11_2 = '1')then
           bus2ip_addr_i(5) <= addr_5_cmb;
        end if;
     end if;
 end process ADDR_BITS_5_REG_P;
 ------------------

 calc_addr_11_6 <= ('0'& bus2ip_addr_i(11 downto 6)) +
                                                   ("000000" & calc_addr_5(1));

 addr_11_6_int  <= calc_addr_11_6(5 downto 0) when (Derived_burst_reg(0)='1')
                   else
                   bus2ip_addr_i(11 downto 6);

 addr_11_6_cmb  <= Addr_int_cmb(11 downto 6) when(Store_addr_info_cmb='1')
                   else
                   addr_11_6_int(5 downto 0);

--  ADDR_BITS_11_6_REG_P: store the 11 to 6 address bits
 --------------------
 ADDR_BITS_11_6_REG_P:process(Bus2IP_Clk)
 --------------------
 begin
     if (Bus2IP_Clk'event and Bus2IP_Clk='1') then
        if((Bus2IP_Resetn = '0')) then
           bus2ip_addr_i(11 downto 6) <= (others => '0');
        elsif(int_addr_enable_11_2 = '1')then
           bus2ip_addr_i(11 downto 6) <= addr_11_6_cmb(5 downto 0);
        end if;
     end if;
 end process ADDR_BITS_11_6_REG_P;
 ---------------------------------

------------------------------------------
end generate BUS2IP_ADDR_GEN_DATA_WDTH_32;
------------------------------------------
-- BUS2IP_ADDR_GEN_DATA_WDTH_64: below address logic is used for 64 bit dbus
-- ============================
BUS2IP_ADDR_GEN_DATA_WDTH_64: if C_S_AXI_MEM_DATA_WIDTH = 64 generate
 -- address(3) calculation
 signal calc_addr_3: std_logic_vector(1 downto 0);
 signal addr_3_int : std_logic;
 signal addr_3_cmb : std_logic;
 -- address(4) calculation
 signal calc_addr_4: std_logic_vector(1 downto 0);
 signal addr_4_int : std_logic;
 signal addr_4_cmb : std_logic;
 -- address(5) calculation
 signal calc_addr_5: std_logic_vector(1 downto 0);
 signal addr_5_int : std_logic;
 signal addr_5_cmb : std_logic;
 -- address(6) calculation
 signal calc_addr_6: std_logic_vector(1 downto 0);
 signal addr_6_int : std_logic;
 signal addr_6_cmb : std_logic;
 -- address(7) calculation
 signal calc_addr_7: std_logic_vector(1 downto 0);
 signal addr_7_int : std_logic;
 signal addr_7_cmb : std_logic;
 -- address(11:7) calculation
 signal calc_addr_11_7: std_logic_vector(5 downto 0);
 signal addr_11_7_int : std_logic_vector(4 downto 0);
 signal addr_11_7_cmb : std_logic_vector(4 downto 0);

 signal address_carry : std_logic;
 signal internal_count: std_logic_vector(3 downto 0):=(others => '0');
 -----
 begin
 -----

 --------------------
 --  INT_COUNTER_P64: to store the internal address bits
 --------------------
 INT_COUNTER_P64: process(Bus2IP_Clk)
 begin
    if (Bus2IP_Clk'event and Bus2IP_Clk='1') then
        if (Store_addr_info_cmb = '1') then
                internal_count <= '0' & Addr_int_cmb(2 downto 0);
        elsif(
              (Ip2Bus_Addr_ack='1') and
               (Fifo_full_1='0')
              )then
                 if(Derived_size_reg(1) = '1') then
                    internal_count <= internal_count + "100";
                 else
                    internal_count <= internal_count + Derived_size_reg + '1';
                 end if;
        end if;
    end if;
 end process INT_COUNTER_P64;
 ----------------------------

 address_Carry<=(Derived_size_reg(1) and Derived_size_reg(0))   or -- for double word
                (Derived_size_reg(1) and internal_count(2)  )   or -- for word
                (Derived_size_reg(0) and
                 internal_count(2)   and
                 internal_count(1)
                 )or -- for half word
                (internal_count(2) and
                 internal_count(1) and
                 internal_count(0)
                 ); -- for byte

 calc_addr_3 <= ('0' & Bus2IP_Addr_i(3)) + ('0' & address_Carry);

 addr_3_int  <= calc_addr_3(0) when (addr_sel_0='1') else bus2ip_addr_i(3);

 addr_3_cmb  <= Addr_int_cmb(3) when (Store_addr_info_cmb='1') else addr_3_int;

--  ADDR_BITS_3_REG_P: store the 3rd address bit
 ------------------
 ADDR_BITS_3_REG_P:process(Bus2IP_Clk)
 ------------------
 begin
     if (Bus2IP_Clk'event and Bus2IP_Clk='1') then
        if(((Bus2IP_Resetn = '0'))) then
           bus2ip_addr_i(3) <= '0';
        elsif(int_addr_enable_11_2 = '1')then
           bus2ip_addr_i(3) <= addr_3_cmb;
        end if;
     end if;
 end process ADDR_BITS_3_REG_P;
 ------------------
 calc_addr_4 <= ('0' & bus2ip_addr_i(4)) + ('0' & calc_addr_3(1));

 addr_4_int  <= calc_addr_4(0) when (addr_sel_1='1') else bus2ip_addr_i(4);

 addr_4_cmb  <= Addr_int_cmb(4) when (Store_addr_info_cmb='1') else addr_4_int;

--  ADDR_BITS_4_REG_P: store teh 4th address bit
 ------------------
 ADDR_BITS_4_REG_P:process(Bus2IP_Clk)
 ------------------
 begin
     if (Bus2IP_Clk'event and Bus2IP_Clk='1') then
        if(((Bus2IP_Resetn = '0')) ) then
           bus2ip_addr_i(4) <= '0';
        elsif(int_addr_enable_11_2 = '1')then
           bus2ip_addr_i(4) <= addr_4_cmb;
        end if;
     end if;
 end process ADDR_BITS_4_REG_P;
 ------------------

 calc_addr_5 <= ('0' & Bus2IP_Addr_i(5)) + ('0' & calc_addr_4(1));

 addr_5_int  <= calc_addr_5(0) when (addr_sel_2='1') else Bus2IP_Addr_i(5);

 addr_5_cmb  <= Addr_int_cmb(5) when (Store_addr_info_cmb='1') else addr_5_int;

--  ADDR_BITS_5_REG_P: store the 5th address bit
 ------------------
 ADDR_BITS_5_REG_P:process(Bus2IP_Clk)
 ------------------
 begin
     if (Bus2IP_Clk'event and Bus2IP_Clk='1') then
        if(((Bus2IP_Resetn = '0')) ) then
           bus2ip_addr_i(5) <= '0';
        elsif(int_addr_enable_11_2 = '1')then
           bus2ip_addr_i(5) <= addr_5_cmb;
        end if;
     end if;
 end process ADDR_BITS_5_REG_P;
 ------------------

 calc_addr_6 <= ('0' & Bus2IP_Addr_i(6)) + ('0' & calc_addr_5(1));

 addr_6_int <= calc_addr_6(0) when (addr_sel_3='1') else Bus2IP_Addr_i(6);

 addr_6_cmb <= Addr_int_cmb(6) when (Store_addr_info_cmb='1') else addr_6_int;

--  ADDR_BITS_6_REG_P: store the 6th address bit
 ------------------
 ADDR_BITS_6_REG_P:process(Bus2IP_Clk)
 ------------------
 begin
     if (Bus2IP_Clk'event and Bus2IP_Clk='1') then
        if(((Bus2IP_Resetn = '0')) ) then
           bus2ip_addr_i(6) <= '0';
        elsif(int_addr_enable_11_2 = '1')then
           bus2ip_addr_i(6) <= addr_6_cmb;
        end if;
     end if;
 end process ADDR_BITS_6_REG_P;
 ------------------

 calc_addr_11_7 <= ('0' & Bus2IP_Addr_i(11 downto 7))
                                                  + ("00000" & calc_addr_6(1));

 addr_11_7_int  <= calc_addr_11_7(4 downto 0) when (Derived_burst_reg(0)='1')
                   else
                   Bus2IP_Addr_i(11 downto 7);

 addr_11_7_cmb  <= Addr_int_cmb(11 downto 7) when(Store_addr_info_cmb='1')
                   else
                   addr_11_7_int(4 downto 0);

--  ADDR_BITS_11_7_REG_P: store the 11 to 7 address bits
 --------------------
 ADDR_BITS_11_7_REG_P:process(Bus2IP_Clk)
 --------------------
 begin
     if (Bus2IP_Clk'event and Bus2IP_Clk='1') then
        if(((Bus2IP_Resetn = '0')) ) then
           bus2ip_addr_i(11 downto 7) <= (others => '0');
        elsif(int_addr_enable_11_2 = '1')then
           bus2ip_addr_i(11 downto 7) <= addr_11_7_cmb(4 downto 0);
        end if;
     end if;
 end process ADDR_BITS_11_7_REG_P;
 ---------------------------------
end generate BUS2IP_ADDR_GEN_DATA_WDTH_64;
-------------------------------------------------------------------------------

end imp;
