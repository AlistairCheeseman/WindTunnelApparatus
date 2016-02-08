-------------------------------------------------------------------
-- (c) Copyright 1984 - 2013 Xilinx, Inc. All rights reserved.
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
-- Filename:        addr_counter_mux.vhd-- Description:
--                  This file contains the addr_counter and mux for the EMC
--                  design.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--                  emc.vhd
--                      -- ipic_if.vhd
--                      -- addr_counter_mux.vhd
--                      -- counters.vhd
--                      -- select_param.vhd
--                      -- mem_state_machine.vhd
--                      -- mem_steer.vhd
--                      -- io_registers.vhd
-------------------------------------------------------------------------------
-- Author:          NSK
-- History:
-- NSK             02/01/08    First Version
-- ^^^^^^^^^^
-- This file is same as in version v3_01_c - no change in the logic of this
-- module. Deleted the history from version v3_01_c.
-- ~~~~~~
-- NSK         02/12/08    Updated
-- ^^^^^^^^
-- Removed the unused part of code (not supporting C_IPIF_DWIDTH = 64): -
-- 1. Deleted the generate block lebelled "CYCLE_END_CNT_64_GEN".
-- 2. In the process "ADDR_SUFFIX_PROCESS" deleted the part of code as
--    C_ADDR_OFFSET = 3 is valid only when C_IPIF_DWIDTH = 64 is supported.
-- ~~~~~~~~
-- NSK         05/08/08    version v3_00_a
-- ^^^^^^^^
-- 1. This file is same as in version v3_02_a.
-- 2. Upgraded to version v3.00.a to have proper versioning to fix CR #472164.
-- 3. No change in design.
--
-- KSB         05/08/08    version v4_00_a
-- 1. Modified for Page mdoe read
-- 2. Modified for 64 Bit memory address align
-- ~~~~~~~~
-- KSB         22/05/10    version v5_00_a
-- 1. Modified for AXI EMC, PSRAM, Byte parity Memory Support
-- 2. Modified for AXI Slave burst interface
-- ~~~~~~~~
-- SK          02/11/11    version v5_02_a
-- ^^^^^^^^
-- 1. Fixed CR#595758 and CR#606038
-- ~~~~~~~~
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
--      combinatorial signals:                  "*_com"
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- vcomponents package of the unisim library is used for the FDR and FDCE
-- component declaration
-------------------------------------------------------------------------------

library unisim;
use unisim.vcomponents.all;

library emc_common_v3_0;
-------------------------------------------------------------------------------
-- Definition of Generics:
--      C_ADDR_CNTR_WIDTH       -- Width of address counter
--      C_IPIF_AWIDTH           -- Width of IPIF address bus
--      C_IPIF_DWIDTH           -- Width of IPIF data bus
--      C_ADDR_OFFSET           -- Unused lower address bits based on data
--                                 width
--      C_GLOBAL_DATAWIDTH_MATCH-- Indicates whether any memory bank is
--                                 supporting data width matching
--
-- Definition of Ports:
--      Bus2IP_Addr             -- Processor address bus
--      Bus2IP_BE               -- Processor bus byte enables
--      Address_strobe          -- Address strobe signal
--      Data_strobe             -- Data and BEs strobe signal
--      Mem_width_bytes         -- Width in bytes of currently addressed
--                                 memory bank
--      Datawidth_match         -- Data width matching for currently addressed
--                                 memory bank
--      Addr_cnt_ce             -- Address counter count enable
--      Addr_cnt_rst            -- Address counter reset
--      Addr_cnt                -- Address count
--      Cycle_cnt_ld            -- Cycle end counter count load
--      Cycle_cnt_en            -- Cycle end counter count enable
--      Cycle_end               -- Current cycle end flag
--      Mem_addr                -- Address out to memory
--      Mem_Ben                 -- Memory byte enables
--      Clk                     -- System Clock
--      Rst                     -- System Reset
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Entity section
-------------------------------------------------------------------------------

entity addr_counter_mux is
    generic(
        C_ADDR_CNTR_WIDTH           : integer range 1 to 5;
        C_IPIF_AWIDTH               : integer;
        C_IPIF_DWIDTH               : integer;
        C_ADDR_OFFSET               : integer range 0 to 4;
        PARITY_TYPE_MEMORY          : integer range 0 to 1  := 1;
        C_GLOBAL_DATAWIDTH_MATCH    : integer range 0 to 1
    );
    port(
        Clk                   : in  std_logic;
        Rst                   : in  std_logic;

        Bus2IP_Addr           : in  std_logic_vector(0 to C_IPIF_AWIDTH-1);
        Bus2IP_BE             : in  std_logic_vector(0 to C_IPIF_DWIDTH/8-1);
         Address_strobe        : in  std_logic; -- 07-12-2012
        --Data_strobe           : in  std_logic;09-12-2012
        Bus2Mem_CS            : in  std_logic;

        Mem_width_bytes       : in  std_logic_vector(0 to 3);
        Datawidth_match       : in  std_logic;

        Addr_cnt_ce           : in  std_logic;
        Addr_cnt_rst          : in  std_logic;
        Addr_cnt              : out std_logic_vector(0 to C_ADDR_CNTR_WIDTH-1);
        Addr_align            : out std_logic;

        Cycle_cnt_ld          : in  std_logic;
        Cycle_cnt_en          : in  std_logic;
        Cycle_End             : out std_logic;
        CS_par_addr           : in std_logic;

        Mem_addr              : out std_logic_vector(0 to C_IPIF_AWIDTH-1);
        par_error_addr        : out std_logic_vector(0 to C_IPIF_AWIDTH-1);
        Mem_Ben               : out std_logic_vector(0 to C_IPIF_DWIDTH/8-1);

        Bus2IP_RdReq          : in std_logic;
	address_strobe_c      : in  std_logic;
        be_strobe_c           : in  std_logic;
          data_strobe_c         : in  std_logic;
        Cre_reg_en	      : in  std_logic; -- 1/16/2013
	psram_page_mode       : in std_logic;
	axi_trans_size_reg : in std_logic_vector(1 downto 0)
    );
end entity addr_counter_mux;

-------------------------------------------------------------------------------
-- Architecture section
-------------------------------------------------------------------------------

architecture imp of addr_counter_mux is
-------------------------------------------------------------------------------
-- Function log2 -- returns number of bits needed to encode x choices
--   x = 0  returns 0
--   x = 1  returns 0
--   x = 2  returns 1
--   x = 4  returns 2, etc.
-------------------------------------------------------------------------------
--
function log2(x : natural) return integer is
  variable i  : integer := 0; 
  variable val: integer := 1;
begin 
  if x = 0 then return 0;
  else
    for j in 0 to 29 loop -- for loop for XST 
      if val >= x then null; 
      else
        i := i+1;
        val := val*2;
      end if;
    end loop;
  -- Fix per CR520627  XST was ignoring this anyway and printing a  
  -- Warning in SRP file. This will get rid of the warning and not
  -- impact simulation.  
  -- synthesis translate_off
    assert val >= x
      report "Function log2 received argument larger" &
             " than its capability of 2^30. "
      severity failure;
  -- synthesis translate_on
    return i;
  end if;  
end function log2;
----------------------------------------------------------------------------------
-- below attributes are added to reduce the synth warnings in Vivado tool
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of imp : architecture is "yes";
----------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- Constant declarations
-------------------------------------------------------------------------------
-- reset values

constant ZERO_CYCLE_CNT : std_logic_vector(0 to (log2(C_IPIF_DWIDTH/8)-1))
                            := (others => '0');

-------------------------------------------------------------------------------
-- Signal declarations
-------------------------------------------------------------------------------
signal addr_cnt_i       : std_logic_vector(0 to C_ADDR_CNTR_WIDTH-1);
signal addr_suffix      : std_logic_vector(0 to C_ADDR_OFFSET-1)
                        := (others => '0');

signal addr_cnt_val     : std_logic_vector(0 to C_ADDR_CNTR_WIDTH-1);
signal cycle_cnt        : std_logic_vector(0 to (log2(C_IPIF_DWIDTH/8)-1));
signal cycle_end_cnt    : std_logic_vector(0 to (log2(C_IPIF_DWIDTH/8)-1));
signal int_addr         : std_logic_vector(0 to C_IPIF_AWIDTH-1);
signal Mem_Ben_i        : std_logic_vector(0 to C_IPIF_DWIDTH/8-1);

signal mem_addr_cmb     : std_logic_vector(0 to C_IPIF_AWIDTH-1);
signal addr_cnt_cmb     : std_logic_vector(0 to C_ADDR_CNTR_WIDTH-1);

signal addr_align_32_64 : std_logic;

signal reduced_low_be   : std_logic;
signal reduced_high_be  : std_logic;

signal reduced_16_0_be   : std_logic;
signal reduced_16_1_be   : std_logic;
signal reduced_16_2_be   : std_logic;
signal reduced_16_3_be   : std_logic;

signal par_error_addr_reg: std_logic_vector(0 to C_IPIF_AWIDTH-1);

signal Cycle_End_reg     : std_logic;
signal Cycle_cnt_en_int  : std_logic;

-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------

begin

    ---------------------------------------------------------------------------
    -- Store the address coming from bus as address ack and data ack are issued
    -- early to make burst appear as continuous on memory side.
    ---------------------------------------------------------------------------

    Mem_Ben  <= Mem_Ben_i;

    ADDRESS_STORE_GEN: for i in 0 to C_IPIF_AWIDTH - 1 generate
    begin
        ADDRESS_REG: FDRE
        port map (
            Q   => int_addr(i),       --[out]
            C   => Clk,               --[in]
            CE  => address_strobe_c,--Data_strobe,       --[in]
            D   => Bus2IP_Addr(i),    --[in]
            R   => Rst                --[in]
            );
    end generate ADDRESS_STORE_GEN;

    ---------------------------------------------------------------------------
    -- Store the Byte Enables coming from bus as address ack and data ack are
    -- issued early to make burst appear as continuous one on memory side.
    ---------------------------------------------------------------------------

    BEN_STORE_GEN: for i in 0 to C_IPIF_DWIDTH/8-1 generate
    begin
      BEN_REG: FDRE
        port map (
            Q   => Mem_Ben_i(i),      --[out]
            C   => Clk,               --[in]
            CE  => be_strobe_c,--Data_strobe,       --[in]
            D   => Bus2IP_BE(i),      --[in]
            R   => Rst                --[in]
            );
    end generate BEN_STORE_GEN;

    ---------------------------------------------------------------------------
    -- Address and address count generation logic.
    ---------------------------------------------------------------------------

    Mem_addr            <= mem_addr_cmb  ;
    Addr_cnt            <= addr_cnt_cmb;

    PARITY_ERROR_GEN: if PARITY_TYPE_MEMORY = 1 generate

        par_error_addr     <= Bus2IP_Addr when CS_par_addr='1'
	                      else
                              par_error_addr_reg;
        PARITY_ERROR_PROCESS : process(Clk)
        begin
            if(Clk'EVENT and Clk = '1') then
                if(Rst = '1')then
                    par_error_addr_reg  <= (others=>'0');
                elsif CS_par_addr = '1' then
                    par_error_addr_reg <= Bus2IP_Addr;
                end if;
            end if;
        end process PARITY_ERROR_PROCESS;
    end generate PARITY_ERROR_GEN;
    ---------------------------------------------------------------------------
    ---------------------------- NO DATAWIDTH MATCHING ------------------------
    -- If datawidth matching has not been turned on for any memory banks,
    -- simplify the logic.
    ---------------------------------------------------------------------------

    NO_DATAWIDTH_MATCH_GEN: if C_GLOBAL_DATAWIDTH_MATCH = 0 generate
    begin
        addr_cnt_cmb <= (others => '0');
        mem_addr_cmb <= int_addr;
        Cycle_End    <= '1';
    end generate NO_DATAWIDTH_MATCH_GEN;

    ---------------------------------------------------------------------------
    ---------------------------- DATAWIDTH MATCHING ---------------------------
    -- If datawidth matching has been turned on at least 1 memory bank,
    -- implement the data width matching logic. Note that an individual bank
    -- with datawidth matching turned off will still use this logic.
    ---------------------------------------------------------------------------

    DATAWIDTH_MATCH_GEN: if C_GLOBAL_DATAWIDTH_MATCH = 1 generate
    begin

        -----------------------------------------------------------------------
        -- Assign output signals
        -----------------------------------------------------------------------
        addr_cnt_cmb <= (others => '0') when Datawidth_match = '0' else
                        addr_cnt_i;

        ADDR_CNT_PROCESS : process(Clk)
        begin
            if(Clk'EVENT and Clk = '1') then
                if(Rst = '1')then
                    addr_cnt_i  <= (others=>'0');
                elsif Addr_cnt_rst = '1' then
                    if(Cre_reg_en = '0') then
			addr_cnt_i  <= addr_cnt_val;
		    else
			addr_cnt_i  <= (others => '0');
		    end if;
                elsif Addr_cnt_ce = '1' then
                    addr_cnt_i  <= addr_cnt_i + 1;
                end if;
            end if;
        end process ADDR_CNT_PROCESS;

        -----------------------------------------------------------------------
        -- Create cycle termination logic for C_IPIF_DWIDTH  = 64.
        -----------------------------------------------------------------------

        CYCLE_END_CNT_64_GEN : if C_IPIF_DWIDTH  = 64 generate
        begin
            mem_addr_cmb <= int_addr when Datawidth_match = '0' or Cre_reg_en = '1' else
                            int_addr(0 to C_IPIF_AWIDTH-C_ADDR_OFFSET-1)
                            & addr_suffix;
            Addr_align   <= '0';

            reduced_high_be <= or_reduce (Bus2IP_BE(0 to 3));
            reduced_low_be  <= or_reduce (Bus2IP_BE(4 to 7));

            reduced_16_0_be <= or_reduce (Bus2IP_BE(6 to 7));
            reduced_16_1_be <= or_reduce (Bus2IP_BE(4 to 5));
            reduced_16_2_be <= or_reduce (Bus2IP_BE(2 to 3));
            reduced_16_3_be <= or_reduce (Bus2IP_BE(0 to 1));

            ---------------------------------------------------------------------
            -- Create the address suffix.
            ---------------------------------------------------------------------

            ADDR_SUFFIX_PROCESS_64: process(Mem_width_bytes,
                                            Bus2IP_Addr,
                                            addr_cnt_i)
            begin
                addr_suffix <= (others => '0');
                addr_cnt_val<= (others => '0');
                case Mem_width_bytes is
                  when "0001" =>
                      addr_suffix    <= addr_cnt_i;
                      addr_cnt_val   <= Bus2IP_Addr(C_IPIF_AWIDTH-C_ADDR_OFFSET
                                                    to C_IPIF_AWIDTH - 1);
                  when "0010" =>
                      addr_suffix    <= addr_cnt_i(1 to C_ADDR_CNTR_WIDTH-1)
                                                                       & '0';
                      addr_cnt_val   <= '0' & Bus2IP_Addr(C_IPIF_AWIDTH-
                                        C_ADDR_OFFSET to C_IPIF_AWIDTH - 2);
                  when "0100" =>
                      addr_suffix <= addr_cnt_i(2 to C_ADDR_CNTR_WIDTH-1)
                                                                       & "00";
                      addr_cnt_val<= "00" & Bus2IP_Addr(C_IPIF_AWIDTH-
                                                        C_ADDR_OFFSET
                                                        to C_IPIF_AWIDTH - 3);
                  when "1000" =>
                      addr_suffix <= (others => '0');
                      addr_cnt_val<= (others => '0');
                  -- coverage off
		  when others=>
                      addr_suffix <= (others => '0');
                      addr_cnt_val<= (others => '0');
		  -- coverage on
                end case;
            end process ADDR_SUFFIX_PROCESS_64;
            ---------------------------------------------------------------------
            -- Create the  cycle_end_cnt
            ---------------------------------------------------------------------
            CYCLE_END_CNT_PROCESS_64 : process(Mem_width_bytes,
                                                reduced_low_be,
                                                reduced_high_be,
                                                reduced_16_0_be,
                                                reduced_16_1_be,
                                                reduced_16_2_be,
                                                reduced_16_3_be,
                                                Bus2IP_BE,
						Bus2IP_RdReq,
						Cycle_cnt_en,
						axi_trans_size_reg)
            variable Mem_width_bytes_rd_req : std_logic_vector(4 downto 0);
	    begin
                Mem_width_bytes_rd_req := Mem_width_bytes & Bus2IP_RdReq ;
		case Mem_width_bytes_rd_req is
                  when "00010" => -- 8 bit memory write access
		    Cycle_cnt_en_int <= Cycle_cnt_en;
                    if (Bus2IP_BE(0) = '1' and Bus2IP_BE(7)='1')then                    
                        cycle_end_cnt <= "111";
                    elsif (
                          (Bus2IP_BE(0) = '1' and Bus2IP_BE(6)='1') or
                          (Bus2IP_BE(1) = '1' and Bus2IP_BE(7)='1'))
                            then
                        cycle_end_cnt <= "110";
                    elsif (

                          (Bus2IP_BE(2) = '1' and Bus2IP_BE(7)='1') or
                          (Bus2IP_BE(1) = '1' and Bus2IP_BE(6)='1') or
                          (Bus2IP_BE(0) = '1' and Bus2IP_BE(5)='1')) then
                        cycle_end_cnt <= "101";
                    elsif (

                          (Bus2IP_BE(3) = '1' and Bus2IP_BE(7)='1') or
                          (Bus2IP_BE(2) = '1' and Bus2IP_BE(6)='1') or
                          (Bus2IP_BE(1) = '1' and Bus2IP_BE(5)='1') or
                          (Bus2IP_BE(0) = '1' and Bus2IP_BE(4)='1'))
                            then
                        cycle_end_cnt <= "100";
                    elsif (
                          (Bus2IP_BE(4) = '1' and Bus2IP_BE(7)='1') or
                          (Bus2IP_BE(3) = '1' and Bus2IP_BE(6)='1') or
                          (Bus2IP_BE(2) = '1' and Bus2IP_BE(5)='1') or
                          (Bus2IP_BE(1) = '1' and Bus2IP_BE(4)='1') or
                          (Bus2IP_BE(0) = '1' and Bus2IP_BE(3)='1'))
                           then
                        cycle_end_cnt <= "011";
                    elsif (
                          (Bus2IP_BE(5) = '1' and Bus2IP_BE(7)='1') or
                          (Bus2IP_BE(4) = '1' and Bus2IP_BE(6)='1') or
                          (Bus2IP_BE(3) = '1' and Bus2IP_BE(5)='1') or
                          (Bus2IP_BE(2) = '1' and Bus2IP_BE(4)='1') or
                          (Bus2IP_BE(1) = '1' and Bus2IP_BE(3)='1') or
                          (Bus2IP_BE(0) = '1' and Bus2IP_BE(2)='1'))
                          then
                        cycle_end_cnt <= "010";
                    elsif (Bus2IP_BE = "00000011" or Bus2IP_BE = "00001100" or
                           Bus2IP_BE = "00110000" or Bus2IP_BE = "11000000" or
                           Bus2IP_BE = "01100000" or Bus2IP_BE = "00011000" or
                           Bus2IP_BE = "00000110") then
                        cycle_end_cnt <= "001";
                    else
                        cycle_end_cnt <= "000";
                    end if;
                  when "00100" => -- 16 bit memory write access
                    Cycle_cnt_en_int <= Cycle_cnt_en;
		    if (
                        (reduced_16_0_be = '1' and reduced_16_3_be = '1')) then
                        cycle_end_cnt <= "011";
                    elsif (
                           (reduced_16_0_be = '1' and reduced_16_2_be = '1') or
                           (reduced_16_1_be = '1' and reduced_16_3_be = '1'))
                           then
                        cycle_end_cnt <= "010";
                    elsif (
                           (reduced_16_0_be = '1' and reduced_16_1_be = '1') or
                           (reduced_16_1_be = '1' and reduced_16_2_be = '1') or
                           (reduced_16_2_be = '1' and reduced_16_3_be = '1'))
                            then
                        cycle_end_cnt <= "001";
                    else
                        cycle_end_cnt <= "000";
                    end if;
                  when "01000" => -- 32 bit memory write access
                    Cycle_cnt_en_int <= Cycle_cnt_en;
		    if (
                        (reduced_low_be = '1' and reduced_high_be = '1')) then
                        cycle_end_cnt <= "001";
                    else
                        cycle_end_cnt <= "000";
                    end if;

                  when "00011" => -- 8 bit memory read access
            		  Cycle_cnt_en_int <= Cycle_cnt_en and or_reduce(axi_trans_size_reg);
			  if (axi_trans_size_reg = "01") then   -- size Half word
			      cycle_end_cnt <= "001";
                          elsif(axi_trans_size_reg = "10")then	-- size word
			      cycle_end_cnt <= "011";
			  elsif(axi_trans_size_reg = "11")then	-- size double word	
			      cycle_end_cnt <= "111"; 
			  else				        -- size byte - Default	
 			      cycle_end_cnt <= "000";
			  end if;
                  when "00101" => -- 16 bit memory read access - can be 16 bit, 32 bit or 64 bit
		          Cycle_cnt_en_int <= Cycle_cnt_en and axi_trans_size_reg(1);
			      
                  if (axi_trans_size_reg = "00" or 
			          axi_trans_size_reg = "01") then    -- Byte or HW word
            		      cycle_end_cnt <= "000";
		          elsif (axi_trans_size_reg = "10") then -- Word
            		      cycle_end_cnt <= "001";
		          else --if (axi_trans_size_reg = "11") then -- DWord
            		      cycle_end_cnt <= "011";
                  end if;
                  when "01001" => -- 32 bit memory read access - can be 16 bit, 32 bit or 64 bit
		          Cycle_cnt_en_int <= Cycle_cnt_en and axi_trans_size_reg(1);
			  if (axi_trans_size_reg = "00") then    -- Byte word
            		      cycle_end_cnt <= "000";
			  elsif (axi_trans_size_reg = "01") then -- HW word
            		      cycle_end_cnt <= "000";
		          elsif (axi_trans_size_reg = "10") then -- Word
            		      cycle_end_cnt <= "000";
		          else -- if (axi_trans_size_reg = "11") then -- DWord
            		      cycle_end_cnt <= "001";
                          end if;
                  -- coverage off
                  when others =>
                          Cycle_cnt_en_int <= '0'; -- 1/21/2013
              cycle_end_cnt <= "000" ;
                  -- coverage on
                end case;
            end process CYCLE_END_CNT_PROCESS_64;
        end generate CYCLE_END_CNT_64_GEN;

        -----------------------------------------------------------------------
        -- Create cycle termination logic for C_IPIF_DWIDTH  = 32.
        -----------------------------------------------------------------------

        CYCLE_END_CNT_32_GEN : if C_IPIF_DWIDTH  = 32 generate
        begin
            reduced_16_1_be <= or_reduce (Bus2IP_BE(2 to 3));
            reduced_16_0_be <= or_reduce (Bus2IP_BE(0 to 1));
            -------------------------------------------------------------------
            -- Create the address suffix.
            -------------------------------------------------------------------
            ADDR_SUFFIX_PROCESS_32: process(Mem_width_bytes,
                                            Bus2IP_Addr,
                                            addr_cnt_i)
            begin
                  --addr_suffix      <= (others => '0');
                  --addr_cnt_val     <= (others => '0');
                  case Mem_width_bytes is
                    when "0001" =>
                        addr_suffix  <= addr_cnt_i;
                        addr_cnt_val <= Bus2IP_Addr(C_IPIF_AWIDTH-C_ADDR_OFFSET
                                                      to C_IPIF_AWIDTH - 1);
                    when "0010" =>
                        addr_suffix  <= addr_cnt_i(1 to C_ADDR_CNTR_WIDTH-1) & '0';
                        addr_cnt_val <= '0' & Bus2IP_Addr(C_IPIF_AWIDTH-
                                          C_ADDR_OFFSET to C_IPIF_AWIDTH - 2);
                    -- coverage off
                    when others=>
                        addr_suffix  <= (others => '0');
                        addr_cnt_val <= (others => '0');
                    -- coverage on
                  end case;
            end process ADDR_SUFFIX_PROCESS_32;
            ---------------------------------------------------------------------
            -- Create the  cycle_end_cnt
            ---------------------------------------------------------------------
            MEM_ADDR_PROCESS: process(int_addr, Datawidth_match, addr_suffix, Cre_reg_en)
            begin

                  if (Datawidth_match = '0') or (Cre_reg_en = '1')then
                    mem_addr_cmb <= int_addr;
                  else
                    mem_addr_cmb <= int_addr(0 to C_IPIF_AWIDTH-
                                            C_ADDR_OFFSET-1) & addr_suffix ;
                 end if;
            end process MEM_ADDR_PROCESS;
          ---------------------------------------------------------------------
          -- Create the  cycle_end_cnt
          ---------------------------------------------------------------------
            CYCLE_END_CNT_PROCESS_32 : process(Mem_width_bytes,
                                               reduced_16_1_be,
                                               reduced_16_0_be,
                                               Bus2IP_BE,
					       Cycle_cnt_en,
					       Bus2IP_RdReq,
					       axi_trans_size_reg)
            variable Mem_width_bytes_rd_req : std_logic_vector(4 downto 0);
            begin
		Mem_width_bytes_rd_req := Mem_width_bytes & Bus2IP_RdReq ;
		case Mem_width_bytes_rd_req is
                    when "00010" => -- 8 bit memory width write
               		Cycle_cnt_en_int <= Cycle_cnt_en; -- 1/18/2013
                        if
                           (Bus2IP_BE(0) = '1' and Bus2IP_BE(3)='1')then
                            cycle_end_cnt <= "11";
                        elsif (
                               (Bus2IP_BE(0) = '1' and Bus2IP_BE(2)='1')  or
                               (Bus2IP_BE(1) = '1' and Bus2IP_BE(3)='1')) then
                            cycle_end_cnt <= "10";
                        elsif (Bus2IP_BE = "0011" or Bus2IP_BE = "1100" or
                               Bus2IP_BE = "0110") then
                            cycle_end_cnt <= "01";
                        else
                            cycle_end_cnt <= "00";
                        end if;
                    when "00100" => -- 16 bit memory width write
               		Cycle_cnt_en_int <= Cycle_cnt_en; -- 1/18/2013
			if (
                            (reduced_16_0_be = '1' and reduced_16_1_be= '1'))
                            then
                            cycle_end_cnt <= "01";
                        else
                            cycle_end_cnt <= "00";
                        end if;

                  when "00011" => -- 8 bit memory read access
            		  Cycle_cnt_en_int <= Cycle_cnt_en and or_reduce(axi_trans_size_reg);
			  if (axi_trans_size_reg = "01") then   -- size Half word
			      cycle_end_cnt <= "01";
                          elsif(axi_trans_size_reg = "10")then	-- size word
			      cycle_end_cnt <= "11";
			  else				        -- size byte - Default	
 			      cycle_end_cnt <= "00";
			  end if;
                  when "00101" => -- 16 bit memory read access - can be 8 bit, 16 bit, 32 bit
		          Cycle_cnt_en_int <= Cycle_cnt_en and axi_trans_size_reg(1);

			  --if (axi_trans_size_reg = "00" or 
			  --    axi_trans_size_reg = "01") then    -- Byte or HW word
            		  --    cycle_end_cnt <= "00";
		          --elsif (axi_trans_size_reg = "10") then -- Word
            		  --    cycle_end_cnt <= "01";
                          --end if;
			  if(axi_trans_size_reg = "10") then -- Word
			      cycle_end_cnt <= "01";
			  else
			      cycle_end_cnt <= "00";
			  end if;
                  when "01001" => -- 32 bit memory read access - can be 8 bit, 16 bit, 32 bit
		          Cycle_cnt_en_int <= Cycle_cnt_en and axi_trans_size_reg(1);
			  if (axi_trans_size_reg = "00") then    -- Byte word
            		      cycle_end_cnt <= "00";
			  elsif (axi_trans_size_reg = "01") then -- HW word
            		      cycle_end_cnt <= "00";
		          elsif (axi_trans_size_reg = "10") then -- Word
            		      cycle_end_cnt <= "00";
		          else -- if (axi_trans_size_reg = "11") then -- DWord
            		      cycle_end_cnt <= "01";
                          end if;

                    -- coverage off
                    when others =>
                            Cycle_cnt_en_int <= '0'; -- 1/21/2013
			    cycle_end_cnt <= "00" ;
                    -- coverage on
                end case;
            end process CYCLE_END_CNT_PROCESS_32;
        end generate CYCLE_END_CNT_32_GEN;

        -----------------------------------------------------------------------
        -- Instantiate the cycle_end_counter.
        -----------------------------------------------------------------------

        CYCLE_END_CNTR_I:entity emc_common_v3_0.ld_arith_reg
        generic map (
             C_ADD_SUB_NOT  => false,
             C_REG_WIDTH    => C_ADDR_CNTR_WIDTH,
             C_RESET_VALUE  => ZERO_CYCLE_CNT,
             C_LD_WIDTH     => C_ADDR_CNTR_WIDTH,
             C_LD_OFFSET    => 0,
             C_AD_WIDTH     => 1,
             C_AD_OFFSET    => 0
            )
        port map (
             CK             => Clk,
             RST            => Rst,
             Q              => cycle_cnt,
             LD             => cycle_end_cnt,
             AD             => "1",
             LOAD           => Cycle_cnt_ld, -- Cycle_cnt_ld,
             OP             => Cycle_cnt_en_int
             );

        Cycle_End <=  '1'  when (conv_integer(cycle_cnt) = 0) 
	              -- else
	              -- '1'  when psram_page_mode = '1'
		      else
                      '0';


    end generate DATAWIDTH_MATCH_GEN;
end imp;
-------------------------------------------------------------------------------
-- End of File addr_counter_mux.vhd.
-------------------------------------------------------------------------------
