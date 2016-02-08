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
-- Filename:        emc.vhd
-- Version:         v2.1
-- Description:     Common interface for External Memory Controller
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
-- NSK             03/01/08    First Version
-- ^^^^^^^^^^
-- This file is based on version v3_01_c updated to fixed CR #466745: -
--     Added generic C_MEM_DQ_CAPTURE_NEGEDGE. The same generic is mapped to
--     component io_registers from emc_common_v3_03_a.
-- ~~~~~~~~~
-- NSK         03/12/08    Updated
-- ^^^^^^^^
-- Added generic C_MEM_DQ_CAPTURE_NEGEDGE in comment "Definition of Generics"
-- section.
-- ~~~~~~~~
-- NSK         03/03/08    Updated
-- ^^^^^^^^
-- 1. Removed generic C_MEM_DQ_CAPTURE_NEGEDGE.
-- 2. Added the port RdClk used as clock to capture the data from memory.
-- ~~~~~~~~
-- NSK         05/08/08    version v3_00_a
-- ^^^^^^^^
-- 1. This file is same as in version v3_03_a.
-- 2. Upgraded to version v3.00.a to have proper versioning to fix CR #472164.
-- 3. No change in design.
--
-- KSB         05/08/08    version v4_00_a
-- 1. Modified for Page mdoe read
-- 2. Modified for 64 Bit memory address align
-- ~~~~~~~~
--
-- KSB         22/05/10    version v5_00_a
-- 1. Modified for AXI EMC, PSRAM, Byte parity Memory Support
-- 2. Modified for AXI Slave burst interface
-- ~~~~~~~~
-- SK          03/11/10    version v5_01_a
-- ^^^^^^^^
-- 1. Registered the IP2Bus_RdAck and IP2Bus_Data signals.
-- 2. Reduced utilization
-- ~~~~~~~~
-- SK          03/11/11    version v5_03_a
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
    use ieee.std_logic_arith.all;
    use ieee.std_logic_signed.all;
    use ieee.std_logic_misc.all;
    use ieee.numeric_std.all;
    use ieee.std_logic_unsigned.all;

-------------------------------------------------------------------------------
-- emc_common_v3_0 library is used for emc_common component declarations
-------------------------------------------------------------------------------

library emc_common_v3_0;
    use emc_common_v3_0.all;

-------------------------------------------------------------------------------
-- Definition of Generics:
--
--  C_NUM_BANKS_MEM                 -- Number of memory banks
--  C_IPIF_DWIDTH                   -- Width of processor data bus
--  C_IPIF_AWIDTH                   -- Width of processor address bus
--  C_MEM(0:3)_BASEADDR             -- Memory bank (0:3) base address
--  C_MEM(0:3)_HIGHADDR             -- Memory bank (0:3) high address
--  C_INCLUDE_NEGEDGE_IOREGS        -- Include negative edge IO registers
--  C_PAGEMODE_FLASH_(0:3)          -- Whether a PAGE MODE Flash device is used
--  C_MEM(0:3)_WIDTH                -- Width of memory bank's data bus
--  C_MAX_MEM_WIDTH                 -- Maximum width of memory data bus
--  C_INCLUDE_DATAWIDTH_MATCHING_(0:3)  -- Include datawidth matching logic for
--                                  -- memory bank
--  C_BUS_CLOCK_PERIOD_PS           -- Bus clock period to calculate wait
--                                         state pulse widths.
--  C_SYNCH_MEM_(0:3)               -- Memory bank is synchronous
--  C_TCEDV_PS_MEM_(0:3)            -- Chip Enable to Data Valid Time
--                                  -- (Maximum of TCEDV and TAVDV applied
--                                     as read cycle start to first data valid)
--  C_TAVDV_PS_MEM_(0:3)            -- Address Valid to Data Valid Time
--                                  -- (Maximum of TCEDV and TAVDV applied
--                                     as read cycle start to first data valid)
--  C_TPACC_PS_FLASH_(0:3)          -- Address Valid to Data Valid Time
--                                  -- for a PAGE Read for a PAGE MODE Flash
--  C_THZCE_PS_MEM_(0:3)            -- Chip Enable High to Data Bus High
--                                     Impedance (Maximum of THZCE and THZOE
--                                     applied as Read Recovery before Write)
--  C_THZOE_PS_MEM_(0:3)            -- Output Enable High to Data Bus High
--                                     Impedance (Maximum of THZCE and THZOE
--                                     applied as Read Recovery before Write)
--  C_TWC_PS_MEM_(0:3)              -- Write Cycle Time
--                                     (Maximum of TWC and TWP applied as write
--                                     enable pulse width)
--  C_TWP_PS_MEM_(0:3)              -- Write Enable Minimum Pulse Width
--                                     (Maximum of TWC and TWP applied as write
--                                     enable pulse width)
--  C_TLZWE_PS_MEM_(0:3)            -- Write Enable High to Data Bus Low
--                                     Impedance (Applied as Write Recovery
--                                     before Read)
-- C_WR_REC_TIME_MEM_(0:3)          -- Write recovery time between the write
--                                  -- and next consecutive read transaction
-- Definition of Ports:
--
--  Bus2IP_Clk             -- System clock
--  RdClk                  -- Read Clock
--  Bus2IP_Reset           -- System Reset
--
-- Bus and IPIC Interface signals
--  Bus2IP_Addr             -- Processor bus address
--  Bus2IP_BE               -- Processor bus byte enables
--  Bus2IP_Data             -- Processor data
--  Bus2IP_RNW              -- Processor read not write
--  Bus2IP_Burst            -- Processor burst
--  Bus2IP_WrReq            -- Processor write request
--  Bus2IP_RdReq            -- Processor read request
--  Bus2IP_Mem_CS           -- Memory address range is being accessed
--
-- EMC to bus signals
--  IP2Bus_Data             -- Data to processor bus
--  IP2Bus_errAck           -- Error acknowledge
--  IP2Bus_retry            -- Retry indicator
--  IP2Bus_toutSup          -- Suppress watch dog timer
--  IP2Bus_RdAck            -- Read acknowledge
--  IP2Bus_WrAck            -- Write acknowledge
--  IP2Bus_AddrAck          -- Read/Write Address acknowledge
--
-- Memory signals
--  Mem_A                   -- Memory address inputs
--  Mem_DQ_I                -- Memory input data bus
--  Mem_DQ_O                -- Memory output data bus
--  Mem_DQ_T                -- Memory data output enable
--  Mem_CEN                 -- Memory chip select
--  Mem_OEN                 -- Memory output enable
--  Mem_WEN                 -- Memory write enable
--  Mem_QWEN                -- Memory qualified write enable
--  Mem_BEN                 -- Memory byte enables
--  Mem_RPN                 -- Memory reset/power down
--  Mem_CE                  -- Memory chip enable
--  Mem_ADV_LDN             -- Memory counter advance/load (=0)
--  Mem_LBON                -- Memory linear/interleaved burst order (=0)
--  Mem_CKEN                -- Memory clock enable (=0)
--  Mem_RNW                 -- Memory read not write
-------------------------------------------------------------------------------
-- Port declarations
-------------------------------------------------------------------------------

entity EMC is
    generic (
        C_NUM_BANKS_MEM                 : integer range 1 to 4 := 1;

        C_IPIF_DWIDTH                   : integer := 32;
        C_IPIF_AWIDTH                   : integer := 32;

        C_MEM0_BASEADDR                 : std_logic_vector := x"30000000";
        C_MEM0_HIGHADDR                 : std_logic_vector := x"3000ffff";
        C_MEM1_BASEADDR                 : std_logic_vector := x"40000000";
        C_MEM1_HIGHADDR                 : std_logic_vector := x"4000ffff";
        C_MEM2_BASEADDR                 : std_logic_vector := x"50000000";
        C_MEM2_HIGHADDR                 : std_logic_vector := x"5000ffff";
        C_MEM3_BASEADDR                 : std_logic_vector := x"60000000";
        C_MEM3_HIGHADDR                 : std_logic_vector := x"6000ffff";

        C_INCLUDE_NEGEDGE_IOREGS        : integer := 0;
        C_PAGEMODE_FLASH_0              : integer := 0;
        C_PAGEMODE_FLASH_1              : integer := 0;
        C_PAGEMODE_FLASH_2              : integer := 0;
        C_PAGEMODE_FLASH_3              : integer := 0;

        C_MEM0_WIDTH                    : integer range 8 to 64 := 32;
        C_MEM1_WIDTH                    : integer range 8 to 64 := 32;
        C_MEM2_WIDTH                    : integer range 8 to 64 := 32;
        C_MEM3_WIDTH                    : integer range 8 to 64 := 32;
        C_MAX_MEM_WIDTH                 : integer range 8 to 64 := 32;

        C_MEM0_TYPE                    : integer range 0 to 5  := 0;
        C_MEM1_TYPE                    : integer range 0 to 5  := 0;
        C_MEM2_TYPE                    : integer range 0 to 5  := 0;
        C_MEM3_TYPE                    : integer range 0 to 5  := 0;

        C_PARITY_TYPE_0                : integer range 0 to 2  := 0;
        C_PARITY_TYPE_1                : integer range 0 to 2  := 0;
        C_PARITY_TYPE_2                : integer range 0 to 2  := 0;
        C_PARITY_TYPE_3                : integer range 0 to 2  := 0;

        C_INCLUDE_DATAWIDTH_MATCHING_0  : integer := 0;
        C_INCLUDE_DATAWIDTH_MATCHING_1  : integer := 0;
        C_INCLUDE_DATAWIDTH_MATCHING_2  : integer := 0;
        C_INCLUDE_DATAWIDTH_MATCHING_3  : integer := 0;

        C_BUS_CLOCK_PERIOD_PS           : integer := 10000;

        -- Memory Channel 0 Timing Parameters
        C_SYNCH_MEM_0                   : integer := 0;
        --C_SUPPORT_SYNC_RD_0             : integer := 0;
        C_SYNCH_PIPEDELAY_0             : integer := 2;
        C_TCEDV_PS_MEM_0                : integer := 15000;
        C_TAVDV_PS_MEM_0                : integer := 15000;
        C_TPACC_PS_FLASH_0              : integer := 25;
        C_THZCE_PS_MEM_0                : integer := 7000;
        C_THZOE_PS_MEM_0                : integer := 7000;
        C_TWC_PS_MEM_0                  : integer := 15000;
        C_TWP_PS_MEM_0                  : integer := 12000;
        C_TWPH_PS_MEM_0                 : integer := 12000;
        C_TLZWE_PS_MEM_0                : integer := 0;
        C_WR_REC_TIME_MEM_0             : integer := 100000;


        -- Memory Channel 1 Timing Parameters
        C_SYNCH_MEM_1                   : integer := 0;
        --C_SUPPORT_SYNC_RD_1             : integer := 0;
        C_SYNCH_PIPEDELAY_1             : integer := 2;
        C_TCEDV_PS_MEM_1                : integer := 15000;
        C_TAVDV_PS_MEM_1                : integer := 15000;
        C_TPACC_PS_FLASH_1              : integer := 25000;
        C_THZCE_PS_MEM_1                : integer := 7000;
        C_THZOE_PS_MEM_1                : integer := 7000;
        C_TWC_PS_MEM_1                  : integer := 15000;
        C_TWP_PS_MEM_1                  : integer := 12000;
        C_TWPH_PS_MEM_1                 : integer := 12000;
        C_TLZWE_PS_MEM_1                : integer := 0;
        C_WR_REC_TIME_MEM_1             : integer := 100000;

        -- Memory Channel 2 Timing Parameters
        C_SYNCH_MEM_2                   : integer := 0;
        --C_SUPPORT_SYNC_RD_2             : integer := 0;
        C_SYNCH_PIPEDELAY_2             : integer := 2;
        C_TCEDV_PS_MEM_2                : integer := 15000;
        C_TAVDV_PS_MEM_2                : integer := 15000;
        C_TPACC_PS_FLASH_2              : integer := 25000;
        C_THZCE_PS_MEM_2                : integer := 7000;
        C_THZOE_PS_MEM_2                : integer := 7000;
        C_TWC_PS_MEM_2                  : integer := 15000;
        C_TWP_PS_MEM_2                  : integer := 12000;
        C_TWPH_PS_MEM_2                 : integer := 12000;
        C_TLZWE_PS_MEM_2                : integer := 0;
        C_WR_REC_TIME_MEM_2             : integer := 100000;

        -- Memory Channel 3 Timing Parameters
        C_SYNCH_MEM_3                   : integer := 0;
        --C_SUPPORT_SYNC_RD_3             : integer := 0;
        C_SYNCH_PIPEDELAY_3             : integer := 2;
        C_TCEDV_PS_MEM_3                : integer := 15000;
        C_TAVDV_PS_MEM_3                : integer := 15000;
        C_TPACC_PS_FLASH_3              : integer := 25000;
        C_THZCE_PS_MEM_3                : integer := 7000;
        C_THZOE_PS_MEM_3                : integer := 7000;
        C_TWC_PS_MEM_3                  : integer := 15000;
        C_TWP_PS_MEM_3                  : integer := 12000;
        C_TWPH_PS_MEM_3                 : integer := 12000;
        C_TLZWE_PS_MEM_3                : integer := 0    ;
        C_WR_REC_TIME_MEM_3             : integer := 100000
    );
    port (
        Bus2IP_Clk          : in  std_logic;
        RdClk               : in  std_logic;
        Bus2IP_Reset        : in  std_logic;

        -- Bus and IPIC Interface signals
        Bus2IP_Addr         : in  std_logic_vector(0 to C_IPIF_AWIDTH-1);
        Bus2IP_BE           : in  std_logic_vector(0 to C_IPIF_DWIDTH/8-1);
        Bus2IP_Data         : in  std_logic_vector(0 to C_IPIF_DWIDTH-1);
        Bus2IP_RNW          : in  std_logic;
        Bus2IP_Burst        : in  std_logic;
        Bus2IP_WrReq        : in  std_logic;
        Bus2IP_RdReq        : in  std_logic;
        Bus2IP_Mem_CS       : in  std_logic_vector(0 to C_NUM_BANKS_MEM-1);
        Bus2IP_BurstLength  : in  std_logic_vector (0 to 7);
        Linear_flash_brst_rd_flag : in std_logic;
        Linear_flash_rd_data_ack  : in std_logic;
        Bus2IP_RdReq_emc : in  std_logic;
        Bus2IP_WrReq_emc : in  std_logic;

        IP2Bus_Data         : out std_logic_vector(0 to C_IPIF_DWIDTH-1);
        IP2Bus_errAck       : out std_logic;
        IP2Bus_retry        : out std_logic;
        IP2Bus_toutSup      : out std_logic;
        IP2Bus_RdAck        : out std_logic;
        IP2Bus_WrAck        : out std_logic;
        IP2Bus_AddrAck      : out std_logic;

        parity_error_adrss  : out  std_logic_vector(0 to C_IPIF_AWIDTH-1);
        parity_error_mem    : out  std_logic_vector(0 to 1);
        Type_of_xfer        : in  std_logic;
        psram_page_mode     : in  std_logic;
        original_wrce       : in std_logic;

        Mem_DQ_I            : in  std_logic_vector(0 to C_MAX_MEM_WIDTH-1);
        Mem_DQ_O            : out std_logic_vector(0 to C_MAX_MEM_WIDTH-1);
        Mem_DQ_T            : out std_logic_vector(0 to C_MAX_MEM_WIDTH-1);

        Mem_DQ_PRTY_I       : in  std_logic_vector(0 to C_MAX_MEM_WIDTH/8-1);
        Mem_DQ_PRTY_O       : out std_logic_vector(0 to C_MAX_MEM_WIDTH/8-1);
        Mem_DQ_PRTY_T       : out std_logic_vector(0 to C_MAX_MEM_WIDTH/8-1);

        Mem_A               : out std_logic_vector(0 to C_IPIF_AWIDTH-1);
        Mem_RPN             : out std_logic;
        Mem_CEN             : out std_logic_vector(0 to C_NUM_BANKS_MEM-1);
        Mem_OEN             : out std_logic_vector(0 to C_NUM_BANKS_MEM-1);
        Mem_WEN             : out std_logic;
        Mem_QWEN            : out std_logic_vector(0 to C_MAX_MEM_WIDTH/8-1);
        Mem_BEN             : out std_logic_vector(0 to C_MAX_MEM_WIDTH/8-1);
        Mem_CE              : out std_logic_vector(0 to C_NUM_BANKS_MEM-1);
        Mem_ADV_LDN         : out std_logic;
        Mem_LBON            : out std_logic;
        Mem_CKEN            : out std_logic;
        Mem_RNW             : out std_logic;
        Cre_reg_en	    : in  std_logic;
        Mem_WAIT	    : in  std_logic;
        Synch_mem12 : out std_logic;
        last_addr1 : in std_logic;
        pr_idle : out std_logic; -- 11-12-2012
	axi_trans_size_reg : in std_logic_vector(1 downto 0); -- 1/3/2013
   axi_wvalid : in std_logic;
   axi_wlast : in std_logic;
        axi_arsize    : in  std_logic_vector(2 downto 0);
  Parity_err : out std_logic

    );
end entity EMC;

-------------------------------------------------------------------------------
-- Architecture section
-------------------------------------------------------------------------------

architecture imp of EMC is
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
-------------------------------------------------------------------------------
-- Function max2
--
-- This function returns the greater of two numbers.
-------------------------------------------------------------------------------
function max2 (num1, num2 : integer) return integer is
begin
    if num1 >= num2 then
        return num1;
    else
        return num2;
    end if;
end function max2;
----------------------------------------------------------------------------------
-- below attributes are added to reduce the synth warnings in Vivado tool
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of imp : architecture is "yes";
----------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Data Types
-------------------------------------------------------------------------------

type EMC_ARRAY_TYPE is array (0 to 3) of integer;
-- type EMC_ARRAY_TYPE is array (0 to C_NUM_BANKS_MEM-1) of integer;

type INTEGER_ARRAY is array (natural range <>) of integer;

type MEM_ADDR_ARRAY is array (0 to C_NUM_BANKS_MEM-1) of
                                        std_logic_vector(0 to C_IPIF_AWIDTH-1);
-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- not_all_zeros()
-------------------------------------------------------------------------------
function not_all_zeros(input_array          : EMC_ARRAY_TYPE;
                       num_real_elements    : integer)
                       return integer is
    variable sum : integer range 0 to 16 := 0;
    begin
        for i in 0 to num_real_elements -1 loop
            sum := sum + input_array(i);
        end loop;

        if sum = 0 then
            return 0;
        else
            return 1;
        end if;
    end function not_all_zeros;
--------------------------------------------------------------------------------
function check_flash_mem(input_array          : EMC_ARRAY_TYPE; -- 9/7/2011
                         num_real_elements    : integer)
                         return integer is
    variable sum : integer range 0 to 10 := 0;
    begin
	for i in 0 to num_real_elements -1 loop
            if(input_array(i) = 2)or
	      (input_array(i) = 3)or
	      (input_array(i) = 5)or
	      (input_array(i) = 4)then
	    sum := sum + 1;
	    end if;
        end loop;
	if sum = 0 then
	   return 0;
	else
	   return 1;
	end if;
end function check_flash_mem;
-- --------------------------------------------------------------------------------
-- -- flash_supports_sync_rd: below function is used to check if any of the memories in the assigned
-- --                         memory location is of Linear Flash which supports Sync Burst Read mode
-- --------------------------------------------------------------------------------
-- function flash_supports_sync_rd (input_flash_array    : EMC_ARRAY_TYPE;
--                                  num_of_mem_banks     : integer)
--                                  return integer is
--     variable flash_sync_rd : integer range 0 to 1 := 0;
--     begin
--         for i in 0 to num_of_mem_banks -1 loop
--             flash_sync_rd := flash_sync_rd + input_flash_array(i);
--         end loop;
--
--         if flash_sync_rd = 0 then
--             return 0;
--         else
--             return 1;
--         end if;
-- end function flash_supports_sync_rd;
-- -------------------------------------------------------------------------------
-- Constant Declarations
-------------------------------------------------------------------------------
-- minimum memory data width supported is 8 bits
constant MIN_MEM_WIDTH      : integer := 8;

-- address offset
constant ADDR_OFFSET        : integer range 0 to 4
                            := log2(C_IPIF_DWIDTH/8);

constant ADDR_CNTR_WIDTH    : integer range 1 to 5
                            := max2(1,log2(C_IPIF_DWIDTH/8));

-- create arrays of generics for use in functions
constant SYNCH_MEM_ARRAY : EMC_ARRAY_TYPE :=
       (C_SYNCH_MEM_0,
        C_SYNCH_MEM_1,
        C_SYNCH_MEM_2,
        C_SYNCH_MEM_3);

constant DATAWIDTH_MATCH_ARRAY : EMC_ARRAY_TYPE :=
       (C_INCLUDE_DATAWIDTH_MATCHING_0,
        C_INCLUDE_DATAWIDTH_MATCHING_1,
        C_INCLUDE_DATAWIDTH_MATCHING_2,
        C_INCLUDE_DATAWIDTH_MATCHING_3);

constant C_PAGEMODE_FLASH : EMC_ARRAY_TYPE :=
       (C_PAGEMODE_FLASH_0,
        C_PAGEMODE_FLASH_1,
        C_PAGEMODE_FLASH_2,
        C_PAGEMODE_FLASH_3);

-- constant C_FLASH_SUPPORTS_SYNC_RD : EMC_ARRAY_TYPE :=
--        (
--         C_SUPPORT_SYNC_RD_0,
--         C_SUPPORT_SYNC_RD_1,
--         C_SUPPORT_SYNC_RD_2,
--         C_SUPPORT_SYNC_RD_3
--        );

type MEM_PARITY_ARRAY_TYPE is array (0 to 3) of integer range 0 to 2;

 constant MEM_PARITY_TYPE_ARRAY : EMC_ARRAY_TYPE :=
            (
                C_PARITY_TYPE_0,
                C_PARITY_TYPE_1,
                C_PARITY_TYPE_2,
                C_PARITY_TYPE_3
            );

-- constant C_WRITE_RECOVERY_TIME : EMC_ARRAY_TYPE :=
--             (
--                 C_WR_REC_TIME_MEM_0,
--                 C_WR_REC_TIME_MEM_1,
--                 C_WR_REC_TIME_MEM_2,
--                 C_WR_REC_TIME_MEM_3
--             );
constant C_FLASH_TYPE_MEM : EMC_ARRAY_TYPE :=
       (C_MEM0_TYPE,
        C_MEM1_TYPE,
        C_MEM2_TYPE,
        C_MEM3_TYPE);

-------------------------------------------------------------------------------
-- Create global constants that indicate if any data matching is needed or if
-- any memories are synchronous. These can be used to eliminate un-necessary
-- logic.
-------------------------------------------------------------------------------
-- check for any memory in configuration is SYNC type or not.
constant GLOBAL_SYNC_MEM    : integer range 0 to 1
                            := not_all_zeros(SYNCH_MEM_ARRAY,
                                             C_NUM_BANKS_MEM);

-- check for any memory in configuration needs Data Width Matching or not.
constant GLOBAL_DATAWIDTH_MATCH : integer range 0 to 1
                                := not_all_zeros(DATAWIDTH_MATCH_ARRAY,
                                                 C_NUM_BANKS_MEM);

-- check for any memory in configuration is Page Mode Flash type or not.
constant PAGEMODE_FLASH : integer range 0 to 1
                        := not_all_zeros(C_PAGEMODE_FLASH,
                                         C_NUM_BANKS_MEM);
--constant C_FLASH_SYNC_RD : integer range 0 to 1
--                       := flash_supports_sync_rd(C_FLASH_SUPPORTS_SYNC_RD,
--                                                 C_NUM_BANKS_MEM);
-- check for any memory in configuration is parity enabled or not.
-- 0 - no parity
-- 1 - odd parity
-- 2 - even parity
constant PARITY_TYPE_MEMORY : integer range 0 to 2
                            := not_all_zeros(MEM_PARITY_TYPE_ARRAY,
                                             C_NUM_BANKS_MEM);

constant FLASH_TYP_MEM : integer range 0 to 1
		       := check_flash_mem(C_FLASH_TYPE_MEM,
                                          C_NUM_BANKS_MEM);
-------------------------------------------------------------------------------
-- Memory Cycle Time Calculations
-------------------------------------------------------------------------------
-- Read Cycle (maximum of CE or Address Change to Valid Data)
-- Note: Minimum 1 extra clock is required to interface from the asynchronous
-- environment to a synchronous environment.
-------------------------------------------------------------------------------
-- C_TCEDV_PS_MEM_x:
--          Read cycle chip enable low to data valid duration of memory bank x
-- C_TAVDV_PS_MEM_x:
--          Read cycle address valid to data valid duration of memory bank x
-- CE ----\
--         \-------------
--         _ _ _ _ _ _
-- Addr __/
--        \_ _ _ _ _ _
--
--        TRD_CLKS_x
--        |<------>|
--                   _ _ _ _ _
-- Data _ _ _ _ _ __/
--                  \_ _ _ _ _

constant TRD_CLKS_0 : integer range 0 to 31
                 := ((max2(1,max2(C_TCEDV_PS_MEM_0,
                                  C_TAVDV_PS_MEM_0))-1)/C_BUS_CLOCK_PERIOD_PS);

constant TRD_CLKS_1 : integer range 0 to 31
                 := ((max2(1,max2(C_TCEDV_PS_MEM_1,
                                  C_TAVDV_PS_MEM_1))-1)/C_BUS_CLOCK_PERIOD_PS);

constant TRD_CLKS_2 : integer range 0 to 31
                 := ((max2(1,max2(C_TCEDV_PS_MEM_2,
                                  C_TAVDV_PS_MEM_2))-1)/C_BUS_CLOCK_PERIOD_PS);

constant TRD_CLKS_3 : integer range 0 to 31
                 := ((max2(1,max2(C_TCEDV_PS_MEM_3,
                                  C_TAVDV_PS_MEM_3))-1)/C_BUS_CLOCK_PERIOD_PS);

-- std logic vector counter for rd_clks_x
constant TRDCNT_0 : std_logic_vector(0 to 4)
                  := conv_std_logic_vector(TRD_CLKS_0+1, 5);

constant TRDCNT_1 : std_logic_vector(0 to 4)
                  := conv_std_logic_vector(TRD_CLKS_1+1, 5);

constant TRDCNT_2 : std_logic_vector(0 to 4)
                  := conv_std_logic_vector(TRD_CLKS_2+1, 5);

constant TRDCNT_3 : std_logic_vector(0 to 4)
                  := conv_std_logic_vector(TRD_CLKS_3+1, 5);

-----------------------------------------------------------------------------

-- TRD_TPACC_x: Page access time of memory bank x in page mode flash mode
constant TRD_TPACC_0 :integer range 0 to 31 --:= (0);
                     := (C_TPACC_PS_FLASH_0/C_BUS_CLOCK_PERIOD_PS);

constant TRD_TPACC_1 :integer range 0 to 31       --:= (0);
                     := (C_TPACC_PS_FLASH_1/C_BUS_CLOCK_PERIOD_PS);

constant TRD_TPACC_2 :integer range 0 to 31    --:= (0);
                     := (C_TPACC_PS_FLASH_2/C_BUS_CLOCK_PERIOD_PS);

constant TRD_TPACC_3 :integer range 0 to 31    -- := (0);
                     := (C_TPACC_PS_FLASH_3/C_BUS_CLOCK_PERIOD_PS);

-- TRD_TPACC_x: std logic vector counter for Page Access Time
constant TPACC_0    : std_logic_vector(0 to 4)
                    := conv_std_logic_vector(TRD_TPACC_0+1, 5);

constant TPACC_1    : std_logic_vector(0 to 4)
                    := conv_std_logic_vector(TRD_TPACC_1+1, 5);

constant TPACC_2    : std_logic_vector(0 to 4)
                    := conv_std_logic_vector(TRD_TPACC_2+1, 5);

constant TPACC_3    : std_logic_vector(0 to 4)
                    := conv_std_logic_vector(TRD_TPACC_3+1, 5);


-------------------------------------------------------------------------------
-- Read Cycle End to Data Bus High Impedance
-------------------------------------------------------------------------------
-- C_THZCE_PS_MEM_x:
--          Read cycle chip enable low to data valid duration of memory bank x
-- C_THZOE_PS_MEM_x:
--          Enable high to data bus high impedance duration of memory bank x
-- CE ----\                      /--------
--         \-----------xx-------/
-- OE ----\                      /--------
--         \-----------xx-------/
--                              THZ_CLKS_x
--                              |<------->|
--                   _ _ _ _ _ _ _ _ _ _ _
-- Data _ _ _ _ _ __/                     \_ _ _ _
--                  \_ _ _ _ _ _ _ _ _ _ _/
constant THZ_CLKS_0 : integer range 0 to 31
                  := ((max2(1,max2(C_THZCE_PS_MEM_0,
                                   C_THZOE_PS_MEM_0))-1)/C_BUS_CLOCK_PERIOD_PS);

constant THZ_CLKS_1 : integer range 0 to 31
                  := ((max2(1,max2(C_THZCE_PS_MEM_1,
                                   C_THZOE_PS_MEM_1))-1)/C_BUS_CLOCK_PERIOD_PS);

constant THZ_CLKS_2 : integer range 0 to 31
                  := ((max2(1,max2(C_THZCE_PS_MEM_2,
                                   C_THZOE_PS_MEM_2))-1)/C_BUS_CLOCK_PERIOD_PS);

constant THZ_CLKS_3 : integer range 0 to 31
                  := ((max2(1,max2(C_THZCE_PS_MEM_3,
                                   C_THZOE_PS_MEM_3))-1)/C_BUS_CLOCK_PERIOD_PS);

-- HZ counter in std logic vector
constant THZCNT_0   : std_logic_vector(0 to 4)
                    := conv_std_logic_vector(THZ_CLKS_0+1, 5);

constant THZCNT_1   : std_logic_vector(0 to 4)
                    := conv_std_logic_vector(THZ_CLKS_1+1, 5);

constant THZCNT_2   : std_logic_vector(0 to 4)
                    := conv_std_logic_vector(THZ_CLKS_2+1, 5);

constant THZCNT_3   : std_logic_vector(0 to 4)
                    := conv_std_logic_vector(THZ_CLKS_3+1, 5);

-------------------------------------------------------------------------------
-- Write Cycle to Data Store
-------------------------------------------------------------------------------
-- C_TWC_PS_MEM_x:
--                Write cycle time of memory bank x
-- C_TWP_PS_MEM_x:
--                Write enable minimum pulse width duration of memory bank x

constant TWR_CLKS_0 : integer range 0 to 31
                    := ((max2(1,max2(C_TWC_PS_MEM_0,
                                     C_TWP_PS_MEM_0))-1)/C_BUS_CLOCK_PERIOD_PS);

constant TWR_CLKS_1 : integer range 0 to 31
                    := ((max2(1,max2(C_TWC_PS_MEM_1,
                                     C_TWP_PS_MEM_1))-1)/C_BUS_CLOCK_PERIOD_PS);

constant TWR_CLKS_2 : integer range 0 to 31
                    := ((max2(1,max2(C_TWC_PS_MEM_2,
                                     C_TWP_PS_MEM_2))-1)/C_BUS_CLOCK_PERIOD_PS);

constant TWR_CLKS_3 : integer range 0 to 31
                    := ((max2(1,max2(C_TWC_PS_MEM_3,
                                     C_TWP_PS_MEM_3))-1)/C_BUS_CLOCK_PERIOD_PS);

-- TWRCNT_x: std logic vector counter for Write cycle Time
constant TWRCNT_0   : std_logic_vector(0 to 4)
                    := conv_std_logic_vector(TWR_CLKS_0, 5);

constant TWRCNT_1   : std_logic_vector(0 to 4)
                    := conv_std_logic_vector(TWR_CLKS_1, 5);

constant TWRCNT_2   : std_logic_vector(0 to 4)
                    := conv_std_logic_vector(TWR_CLKS_2, 5);

constant TWRCNT_3   : std_logic_vector(0 to 4)
                    := conv_std_logic_vector(TWR_CLKS_3, 5);


-------------------------------------------------------------------------------
-- Write Cycle High Period
-------------------------------------------------------------------------------

constant TWPH_CLKS_0 : integer range 0 to 31
                     := (C_TWPH_PS_MEM_0/C_BUS_CLOCK_PERIOD_PS);

constant TWPH_CLKS_1 : integer range 0 to 31
                     := (C_TWPH_PS_MEM_1/C_BUS_CLOCK_PERIOD_PS);

constant TWPH_CLKS_2 : integer range 0 to 31
                     := (C_TWPH_PS_MEM_2/C_BUS_CLOCK_PERIOD_PS);

constant TWPH_CLKS_3 : integer range 0 to 31
                     := (C_TWPH_PS_MEM_3/C_BUS_CLOCK_PERIOD_PS);

-- TWPHCNT_x: std logic vector counter for Write Cycle High Time
constant TWPHCNT_0   : std_logic_vector(0 to 4)
                     := conv_std_logic_vector(TWPH_CLKS_0+1, 5);

constant TWPHCNT_1   : std_logic_vector(0 to 4)
                     := conv_std_logic_vector(TWPH_CLKS_1+1, 5);

constant TWPHCNT_2   : std_logic_vector(0 to 4)
                      := conv_std_logic_vector(TWPH_CLKS_2+1, 5);

constant TWPHCNT_3   : std_logic_vector(0 to 4)
                     := conv_std_logic_vector(TWPH_CLKS_3+1, 5);



------------------------------------------------------------------------------
-- Write Cycle End Data Hold Time
-------------------------------------------------------------------------------
-- C_TLZWE_PS_MEM_x:
--                  Write cycle write enable high to data bus low impedance
--                  duration of memory bank x
-- WE ----\              /--------
--         \------------/
--                      TLZ_CLKS_x
--                      |<----->|
--         _ _ _ _ _ _ _ _ _ _ _
-- Data __/                     \_ _ _ _
--        \_ _ _ _ _ _ _ _ _ _ _/

constant TLZ_CLKS_0 : integer range 0 to 31
                    := ((max2(1,C_TLZWE_PS_MEM_0)-1)/C_BUS_CLOCK_PERIOD_PS);

constant TLZ_CLKS_1 : integer range 0 to 31
                    := ((max2(1,C_TLZWE_PS_MEM_1)-1)/C_BUS_CLOCK_PERIOD_PS);

constant TLZ_CLKS_2 : integer range 0 to 31
                    := ((max2(1,C_TLZWE_PS_MEM_2)-1)/C_BUS_CLOCK_PERIOD_PS);

constant TLZ_CLKS_3 : integer range 0 to 31
                    := ((max2(1,C_TLZWE_PS_MEM_3)-1)/C_BUS_CLOCK_PERIOD_PS);

-- TLZCNT_x: std logic vector counter for Write Cycle End Data Hold Time
constant TLZCNT_0   : std_logic_vector(0 to 4)
                    := conv_std_logic_vector(TLZ_CLKS_0+1, 5);

constant TLZCNT_1   : std_logic_vector(0 to 4)
                    := conv_std_logic_vector(TLZ_CLKS_1+1, 5);

constant TLZCNT_2   : std_logic_vector(0 to 4)
                    := conv_std_logic_vector(TLZ_CLKS_2+1, 5);

constant TLZCNT_3   : std_logic_vector(0 to 4)
                    := conv_std_logic_vector(TLZ_CLKS_3+1, 5);

--------------------------------------------------------------
-- Write recovery time for Flash. some idle time is needed for Flash memories
-- after write and begin of next consecutive read cycle.
-- TWR_REC_TIME_x: Write recovery time of memory bank x in flash mode

constant TWR_REC_TIME_0 :integer range 0 to 65535                      -- 7/4/2011
                     := (C_WR_REC_TIME_MEM_0/C_BUS_CLOCK_PERIOD_PS);

constant TWR_REC_TIME_1 :integer range 0 to 65535
                     := (C_WR_REC_TIME_MEM_1/C_BUS_CLOCK_PERIOD_PS);

constant TWR_REC_TIME_2 :integer range 0 to 65535
                     := (C_WR_REC_TIME_MEM_2/C_BUS_CLOCK_PERIOD_PS);

constant TWR_REC_TIME_3 :integer range 0 to 65535
                     := (C_WR_REC_TIME_MEM_3/C_BUS_CLOCK_PERIOD_PS);

constant TP_WR_REC_CNT_0    : std_logic_vector(0 to 15)
                    := conv_std_logic_vector(TWR_REC_TIME_0+1, 16);

constant TP_WR_REC_CNT_1    : std_logic_vector(0 to 15)
                    := conv_std_logic_vector(TWR_REC_TIME_1+1, 16);

constant TP_WR_REC_CNT_2    : std_logic_vector(0 to 15)
                    := conv_std_logic_vector(TWR_REC_TIME_2+1, 16);

constant TP_WR_REC_CNT_3    : std_logic_vector(0 to 15)
                    := conv_std_logic_vector(TWR_REC_TIME_3+1, 16);

-------------------------------------------------------------------------------
-- Signal Declarations
-------------------------------------------------------------------------------
-- Write Cycle Time
signal twr_data           : std_logic_vector(0 to 4);
signal twr_load           : std_logic;
signal twr_cnt_en         : std_logic;
signal twr_end            : std_logic;

-- Write Cycle High Time
signal twph_data           : std_logic_vector(0 to 4);
signal twph_load           : std_logic;
signal twph_cnt_en         : std_logic;
signal twph_end            : std_logic;

-- Write Cycle End To Data Bus Low-Z
signal tlz_data           : std_logic_vector(0 to 4);
signal tlz_load           : std_logic;
signal Tlz_cnt_en         : std_logic;
signal tlz_end            : std_logic;

-- Read Cycle End To Data Bus High-Z
signal thz_data           : std_logic_vector(0 to 4);
signal thz_load           : std_logic;
signal Thz_cnt_en         : std_logic;
signal thz_end            : std_logic;

-- Read Cycle Address Change to Valid Data
signal trd_data           : std_logic_vector(0 to 4);
signal trd_load           : std_logic;
signal trd_cnt_en         : std_logic;
signal trd_end            : std_logic;

-- Read Cycle Address Change to Valid Data
signal tpacc_data         : std_logic_vector(0 to 4);
signal tpacc_load         : std_logic;
signal tpacc_cnt_en       : std_logic;
signal tpacc_end          : std_logic;

-- Write recovery time for flash

-- signal twr_rec_data       : std_logic_vector(0 to 4);--7/4/2011
-- signal twr_rec_load       : std_logic;
-- signal twr_rec_cnt_en     : std_logic;
-- signal twr_rec_end        : std_logic;
signal twr_rec_data_int   : std_logic_vector(0 to 15);--7/4/2011
signal twr_rec_load_int   : std_logic;
signal twr_rec_cnt_en_int : std_logic;
signal twr_rec_end_int    : std_logic;

-- Memory Access IPIC Signals
signal bus2ip_cs_reg      : std_logic_vector(0 to C_NUM_BANKS_MEM-1);
signal bus2ip_cs_reg_d1   : std_logic_vector(0 to C_NUM_BANKS_MEM-1);
signal cs_Strobe          : std_logic;
signal new_page_access    : std_logic;
signal Parity_enable      : std_logic;
signal Parity_type        : std_logic;
signal Parity_err_i       : std_logic;
signal bus2Mem_CS         : std_logic;
signal bus2Mem_RdReq      : std_logic;
signal bus2Mem_WrReq      : std_logic;
signal mem2Bus_RdAck      : std_logic;
signal mem2Bus_WrAck      : std_logic;

signal mem2Bus_RdAddrAck  : std_logic;
signal mem2Bus_WrAddrAck  : std_logic;
signal mem2Bus_Data       : std_logic_vector(0 to C_IPIF_DWIDTH - 1);

signal write_req_ack      : std_logic;
signal read_req_ack       : std_logic;
signal read_data_en       : std_logic;
signal read_ack           : std_logic;

-- Memory Control Internal Signals
signal mem_CEN_cmb        : std_logic;
signal mem_OEN_cmb        : std_logic;
signal mem_WEN_cmb        : std_logic;

signal bus2ip_ben_int     : std_logic_vector(0 to C_IPIF_DWIDTH/8-1);
signal bus2ip_ben_fixed   : std_logic_vector(0 to C_IPIF_DWIDTH/8-1);
signal mem_a_int          : std_logic_vector(0 to C_IPIF_AWIDTH-1);
signal par_error_addr     : std_logic_vector(0 to C_IPIF_AWIDTH-1);

signal mem_dq_i_int       : std_logic_vector(0 to C_MAX_MEM_WIDTH-1);
signal mem_dq_o_int       : std_logic_vector(0 to C_MAX_MEM_WIDTH-1);
signal mem_dq_t_int       : std_logic_vector(0 to C_MAX_MEM_WIDTH-1);

signal mem_dq_parity_i_int : std_logic_vector(0 to C_MAX_MEM_WIDTH/8-1);
signal mem_dq_parity_o_int : std_logic_vector(0 to C_MAX_MEM_WIDTH/8-1);
signal mem_dq_parity_t_int : std_logic_vector(0 to C_MAX_MEM_WIDTH/8-1);

signal mem_cen_int        : std_logic_vector(0 to C_NUM_BANKS_MEM-1);
signal mem_oen_int        : std_logic_vector(0 to C_NUM_BANKS_MEM-1);
signal mem_wen_int        : std_logic;
signal mem_qwen_int       : std_logic_vector(0 to C_MAX_MEM_WIDTH/8-1);
signal mem_ben_int        : std_logic_vector(0 to C_MAX_MEM_WIDTH/8-1);
signal mem_rpn_int        : std_logic;
signal mem_ce_int         : std_logic_vector(0 to C_NUM_BANKS_MEM-1);
signal mem_adv_ldn_int    : std_logic;
signal mem_lbon_int       : std_logic;
signal mem_cken_int       : std_logic;
signal mem_rnw_int        : std_logic;
signal mem_be_int         : std_logic_vector(0 to C_MAX_MEM_WIDTH/8-1);

-- Data Width Matching Address Management
signal addr_cnt_ce        : std_logic;
signal addr_cnt_rst       : std_logic;
signal addr_cnt           : std_logic_vector(0 to ADDR_CNTR_WIDTH-1);
signal addr_align         : std_logic;
signal addr_align_rd      : std_logic;
signal addr_align_write   : std_logic;

signal CS_par_addr        : std_logic;


signal cycle_cnt_en       : std_logic;
signal cycle_cnt_ld       : std_logic;
signal cycle_End          : std_logic;
signal address_strobe     : std_logic;
signal data_strobe        : std_logic;

-- Access Parameters
signal mem_width_bytes    : std_logic_vector(0 to 3);
signal datawidth_match    : std_logic;
signal synch_mem1          : std_logic;
signal two_pipe_delay     : std_logic;
signal ip2Bus_RdAck_i     : std_logic;
signal IP2Bus_errAck_i : std_logic;

signal Mem_Addr_rst       : std_logic;
signal transaction_done_i : std_logic;
signal Bus2IP_Mem_CS_i    : std_logic;
signal single_transaction : std_logic;

signal  temp_parity_error_adrss: std_logic_vector(0 to C_IPIF_AWIDTH-1);
signal last_burst_cnt          : std_logic;

signal Write_req_data_ack : std_logic;
signal Write_req_addr_ack : std_logic;
signal address_strobe_c   : std_logic;
signal be_strobe_c        : std_logic;
signal data_strobe_c      : std_logic;
signal pr_state_wait_temp_cmb : std_logic;
signal ns_idle            : std_logic;

signal flash_mem_access_int : std_logic;
signal flash_mem_access_int_1 : std_logic;
signal int_Flash_mem_access_dis : std_logic;
signal Adv_L_N : std_logic;
signal stop_oen : std_logic;
signal bus2ip_ben_all_1 : std_logic;-- 12-12-2012

--signal Linear_flash_brst_rd_flag : std_logic;
--signal Linear_flash_rd_data_ack  : std_logic;
-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------

begin

mem_rpn_int     <= not Bus2IP_Reset;
mem_adv_ldn_int <= '0';
mem_lbon_int    <= '0';
mem_cken_int    <= '0';
IP2Bus_RdAck    <= ip2Bus_RdAck_i;
IP2Bus_errAck <= IP2Bus_errAck_i;
Parity_err <= Parity_err_i;
Bus2IP_Mem_CS_i <= or_reduce(Bus2IP_Mem_CS);

    ---------------------------------------------------------------------------
    -- Store the Chip Select Coming from IPIF in case C_NUM_BANKS_MEM > 1
    ---------------------------------------------------------------------------

    CS_STORE_GEN: if (C_NUM_BANKS_MEM > 1) generate
    begin
        CS_STORE_PROCESS:process(Bus2IP_Clk)
        begin

            if (Bus2IP_Clk'event and Bus2IP_Clk = '1') then
                if Bus2IP_Reset = '1' then
                    bus2ip_cs_reg_d1  <= (others=>'0');
                else
                    bus2ip_cs_reg_d1  <= bus2ip_cs_reg;
                end if;
           end if;
        end process CS_STORE_PROCESS;


       bus2ip_cs_reg  <= Bus2IP_Mem_CS when (cs_Strobe = '1')
                         else
                         bus2ip_cs_reg_d1;

    end generate CS_STORE_GEN;

    ---------------------------------------------------------------------------
    -- Pass on the Chip Select Coming from IPIF in case C_NUM_BANKS_MEM = 1
    ---------------------------------------------------------------------------

    CS_PASS_GEN: if (C_NUM_BANKS_MEM = 1) generate
    -----
    function int_to_std (flash_type: integer) return std_logic is
    begin
    if (flash_type = 1) then
    	return '1';
    else
    	return '0';
    end if;

    end function;
 ------------------------------------------------------------------------------

    begin
    -----
        bus2ip_cs_reg  <= Bus2IP_Mem_CS;

        flash_mem_access_int_1 <= int_to_std(FLASH_TYP_MEM);

     end generate CS_PASS_GEN;
 ------------------------------------------------------------------------------
  -- Generate single transaction signals for multiple memory banks.
  ------------------------------------------------------------------------------
        SINGLE_BURST_GEN_PROCESS: process(Bus2IP_Mem_CS,
                                          bus2ip_burst,
                                          Bus2IP_BurstLength)is
        -----
        begin
        -----
             single_transaction  <= '0';
             for i in 0 to C_NUM_BANKS_MEM -1 loop
                 if(Bus2IP_Mem_CS(i) = '1' and
                    --bus2ip_burst= '0'      and
                    or_reduce(Bus2IP_BurstLength) = '0') then -- = "00000000") then
                        single_transaction  <= '1';
                 end if;
             end loop;
        end process SINGLE_BURST_GEN_PROCESS;

    ----------------------------------------------------------------
    MULTIPLE_MEM_FLASH_ACCESS_GEN: if (C_NUM_BANKS_MEM > 1) generate
    -----
    begin
    -----
	REG_FLASH_ACCESS: process(Bus2IP_Clk)is
	begin
	if (Bus2IP_Clk'event and Bus2IP_Clk = '1') then
	   if(flash_mem_access_int = '1') then
	      flash_mem_access_int_1 <= '1';
	   elsif(Bus2IP_Reset = '1' or int_Flash_mem_access_dis = '1')then
	      flash_mem_access_int_1 <= '0';
	   end if;

	end if;

	end process REG_FLASH_ACCESS;

	FLASH_ACCESS_PROCESS: process (Bus2IP_Mem_CS) is
	-----
	begin
	-----
	     flash_mem_access_int <= '0';
	     for i in 0 to C_NUM_BANKS_MEM -1 loop
	         if((Bus2IP_Mem_CS(i) = '1') and
	            ((C_FLASH_TYPE_MEM(i) = 2)or -- check if the memory is flash,page mode flash
		     (C_FLASH_TYPE_MEM(i) = 3)or
		     (C_FLASH_TYPE_MEM(i) = 4)or
                     (C_FLASH_TYPE_MEM(i) = 5)
		    )) then
	                flash_mem_access_int <= '1';
	         --else
	         --     flash_mem_access_int <= '0';
	         end if;
	     end loop;
	end process FLASH_ACCESS_PROCESS;
    	---------------------------------

    end generate MULTIPLE_MEM_FLASH_ACCESS_GEN;
    -------------------------------------------
-------------------------------------------------------------------------------
-- IPIC Interface
-------------------------------------------------------------------------------

IPIC_IF_I : entity emc_common_v3_0.ipic_if
    generic map (
        C_NUM_BANKS_MEM   => C_NUM_BANKS_MEM,

        C_IPIF_DWIDTH     => C_IPIF_DWIDTH
    )
    port map (
        Bus2IP_Clk        => Bus2IP_Clk              ,
        Bus2IP_Reset      => Bus2IP_Reset            ,

        Bus2IP_RNW        => Bus2IP_RNW              ,--  in  std_logic;
        Bus2IP_Mem_CS     => Bus2IP_Mem_CS           ,--  in  std_logic_vector

        Mem2Bus_RdAddrAck => mem2Bus_RdAddrAck       ,--  in  std_logic;
        Mem2Bus_WrAddrAck => mem2Bus_WrAddrAck       ,--  in  std_logic;
        Mem2Bus_RdAck     => mem2Bus_RdAck           ,--  in  std_logic;
        Mem2Bus_WrAck     => mem2Bus_WrAck           ,--  in  std_logic;
        Mem2Bus_Data      => mem2Bus_Data            ,--  in  std_logic;
        Bus2IP_WrReq      => Bus2IP_WrReq            ,--  in  std_logic;
        Bus2IP_RdReq      => Bus2IP_RdReq            ,--  in  std_logic_vector
        Bus2IP_Burst      => bus2ip_burst            ,--  in  std_logic;
        
        Bus2IP_RdReq_emc  => Bus2IP_RdReq_emc        ,--  in  std_logic;
        Bus2IP_WrReq_emc  => Bus2IP_WrReq_emc        ,--  in  std_logic;

        Bus2Mem_CS        => bus2Mem_CS              ,--  out std_logic;
        Bus2Mem_RdReq     => bus2Mem_RdReq           ,--  out std_logic;
        Bus2Mem_WrReq     => bus2Mem_WrReq           ,--  out std_logic;

        Parity_err        => Parity_err_i            ,--  in  std_logic;

        IP2Bus_Data       => IP2Bus_Data             ,--  out std_logic_vector
        IP2Bus_errAck     => IP2Bus_errAck_i         ,--  out std_logic;
        IP2Bus_retry      => IP2Bus_retry            ,--  out std_logic;
        IP2Bus_toutSup    => IP2Bus_toutSup          ,--  out std_logic;
        IP2Bus_RdAck      => ip2Bus_RdAck_i          ,--  out std_logic;
        IP2Bus_WrAck      => IP2Bus_WrAck            ,--  out std_logic;
        IP2Bus_AddrAck    => IP2Bus_AddrAck          ,--  out std_logic;
        Type_of_xfer      => Type_of_xfer            ,--  in  std_logic;

        Burst_length      => Bus2IP_BurstLength      ,--  in  std_logic_vector(
        Transaction_done  => transaction_done_i      ,--  in  std_logic;


        single_transaction=> single_transaction      ,--  in  std_logic;
        last_burst_cnt    => last_burst_cnt          ,--  out std_logic;


        pr_state_wait_temp_cmb   => pr_state_wait_temp_cmb   ,
        Synch_mem                => synch_mem1               ,
        
        Mem_width_bytes          => mem_width_bytes          , -- 10-12-2012
        stop_oen                 => stop_oen                 , -- 10-12-2012
	    
        axi_trans_size_reg       => axi_trans_size_reg       ,-- 1/3/2013
	    Linear_flash_brst_rd_flag=> Linear_flash_brst_rd_flag -- 1/28/2013
    );

-------------------------------------------------------------------------------
-- Memory State Machine
-------------------------------------------------------------------------------

MEM_STATE_MACHINE_I : entity emc_common_v3_0.mem_state_machine
    port map (
        Clk              => Bus2IP_Clk,
        Rst              => Bus2IP_Reset,

        Bus2IP_RNW       => Bus2IP_RNW,
        Bus2IP_RdReq     => bus2Mem_RdReq,
        Bus2IP_WrReq     => Bus2Mem_WrReq,
        original_wrce    => original_wrce,
--flash_mem_access => flash_mem_access_int,

        Synch_mem        => synch_mem1,
        Two_pipe_delay   => two_pipe_delay,
        Cycle_End        => cycle_End,
        Bus2IP_Mem_CS    => Bus2IP_Mem_CS_i,

        Bus2IP_Burst     => bus2ip_burst,

        Read_data_en     => read_data_en,
        Read_ack         => read_ack,

        Address_strobe   => address_strobe,
       -- Data_strobe      => data_strobe,09-12-2012
        CS_Strobe        => cs_Strobe,
        axi_wvalid       => axi_wvalid,
        axi_wlast        => axi_wlast,

        Addr_cnt_ce      => addr_cnt_ce,
        Addr_cnt_rst     => addr_cnt_rst,
        Cycle_cnt_ld     => cycle_cnt_ld,
        Cycle_cnt_en     => cycle_cnt_en,

        single_trans     => single_transaction,

        Trd_cnt_en       => trd_cnt_en,
        Twr_cnt_en       => twr_cnt_en,
        Twph_cnt_en      => twph_cnt_en,
        Tpacc_cnt_en     => tpacc_cnt_en,
        Trd_load         => trd_load,
        Twr_load         => twr_load,
        Twph_load        => twph_load,
        Tpacc_load       => tpacc_load,

        Thz_load         => thz_load,
        Tlz_load         => tlz_load,
        Trd_end          => trd_end,
        Twr_end          => twr_end,
        Twph_end         => twph_end,
        Thz_end          => thz_end,
        Tlz_end          => tlz_end,
        Tpacc_end        => Tpacc_end,

        New_page_access  => new_page_access,
        Linear_flash_brst_rd_flag => Linear_flash_brst_rd_flag,
        Linear_flash_rd_data_ack => Linear_flash_rd_data_ack,

        MSM_Mem_CEN      => mem_CEN_cmb,
        MSM_Mem_OEN      => mem_OEN_cmb,
        MSM_Mem_WEN      => mem_WEN_cmb,
        CS_Strobe_par_addr => CS_par_addr,

        Addr_align       => addr_align_write,
        Addr_align_rd    => addr_align_rd,

        Write_req_ack    => write_req_ack,
        Read_req_ack     => read_req_ack,
        Transaction_done => transaction_done_i,
        Mem_Addr_rst     => Mem_Addr_rst,

        last_burst_cnt     => last_burst_cnt,

        Write_req_data_ack => Write_req_data_ack,
        Write_req_addr_ack => Write_req_addr_ack,

        address_strobe_c   => address_strobe_c,
        be_strobe_c        => be_strobe_c,
        data_strobe_c      => data_strobe_c,
        ns_idle            => ns_idle      ,
        pr_state_wait_temp_cmb => pr_state_wait_temp_cmb,

        Twr_rec_load       => twr_rec_load_int  ,
        Twr_rec_cnt_en     => twr_rec_cnt_en_int,
        Twr_rec_end        => twr_rec_end_int,

	Flash_mem_access_disable => int_Flash_mem_access_dis, --
	Flash_mem_access   => flash_mem_access_int_1, --Flash_mem_access_int
	Mem_WAIT	       => Mem_WAIT,
  	Adv_L_N			=> Adv_L_N,
         Bus2IP_RdReq_emc  => Bus2IP_RdReq_emc, -- 17-10-2012
         last_addr1 => last_addr1,
         stop_oen => stop_oen,
         pr_idle => pr_idle, -- 11-12-2012
         bus2ip_ben_all_1 => bus2ip_ben_all_1
        --Linear_flash_brst_rd_flag  => Linear_flash_brst_rd_flag,
        --Linear_flash_rd_data_ack   => Linear_flash_rd_data_ack
    );


bus2ip_ben_fixed <= (others=>'0') when Type_of_xfer = '0'
                    else
                    Bus2IP_BE;
                    
bus2ip_ben_all_1 <= and_reduce(Bus2IP_BE);-- 13-12-2012 

parity_error_adrss <= temp_parity_error_adrss when (ip2Bus_RdAck_i = '1' and IP2Bus_errAck_i = '1') else (others => '0');


-------------------------------------------------------------------------------
-- Datawidth Matching Address Counter
-------------------------------------------------------------------------------

ADDR_COUNTER_MUX_I : entity emc_common_v3_0.addr_counter_mux
    generic map (
        C_ADDR_CNTR_WIDTH        => ADDR_CNTR_WIDTH,
        C_IPIF_DWIDTH            => C_IPIF_DWIDTH,
        C_IPIF_AWIDTH            => C_IPIF_AWIDTH,
        C_ADDR_OFFSET            => ADDR_OFFSET,
        PARITY_TYPE_MEMORY       => PARITY_TYPE_MEMORY,
        C_GLOBAL_DATAWIDTH_MATCH => GLOBAL_DATAWIDTH_MATCH
    )
    port map (
        Clk                      => Bus2IP_Clk,
        Rst                      => Bus2IP_Reset,

        Bus2IP_Addr              => Bus2IP_Addr,
        Bus2IP_BE                => bus2ip_ben_fixed,
        Address_strobe           => address_strobe,
        --Data_strobe              => data_strobe,09-12-2012

        Mem_width_bytes          => mem_width_bytes,
        Datawidth_match          => datawidth_match,
        Bus2Mem_CS               => bus2Mem_CS,

        Addr_cnt_ce              => addr_cnt_ce,
        Addr_cnt_rst             => addr_cnt_rst,
        Addr_cnt                 => addr_cnt,
        Addr_align               => addr_align_write,
        CS_par_addr              => CS_par_addr,
        par_error_addr           => temp_parity_error_adrss,

        Cycle_cnt_ld             => cycle_cnt_ld,
        Cycle_cnt_en             => cycle_cnt_en,
        Cycle_End                => cycle_End,
        Mem_addr                 => Mem_A_int,
        Mem_Ben                  => bus2ip_ben_int,

        address_strobe_c         => address_strobe_c,
        be_strobe_c              => be_strobe_c     ,
        data_strobe_c            => data_strobe_c,
        Cre_reg_en		 => Cre_reg_en,
         Bus2IP_RdReq  => bus2Mem_RdReq, -- 17-10-2012
psram_page_mode                 => psram_page_mode,
axi_trans_size_reg       => axi_trans_size_reg -- 1/17/2013
    );

-------------------------------------------------------------------------------
-- Asynchronous Memory Cycle Timers
-------------------------------------------------------------------------------

COUNTERS_I: entity emc_common_v3_0.counters
    port map (
        Synch_mem    => synch_mem1,

        Twr_data     => twr_data,
        Twr_load     => twr_load,
        Twr_cnt_en   => twr_cnt_en,
        twph_data    => twph_data,
        twph_load    => twph_load,
        twph_cnt_en  => twph_cnt_en,
        Tlz_data     => tlz_data,
        Tlz_load     => tlz_load,
        Trd_data     => trd_data,
        Trd_load     => trd_load,
        Trd_cnt_en   => trd_cnt_en,
        Tpacc_data   => tpacc_data,
        Tpacc_load   => tpacc_load,
        Tpacc_cnt_en => tpacc_cnt_en,


        Thz_data     => thz_data,
        Thz_load     => thz_load,
        Twr_end      => twr_end,
        Twph_end     => twph_end,
        Tlz_end      => tlz_end,
        Trd_end      => trd_end,
        Thz_end      => thz_end,
        Tpacc_end    => Tpacc_end,
        --------------------------
        Twr_rec_data   => twr_rec_data_int  ,
        Twr_rec_load   => twr_rec_load_int  ,
        Twr_rec_cnt_en => twr_rec_cnt_en_int,
        Twr_rec_end    => twr_rec_end_int   ,
	--------------------------
        Clk          => Bus2IP_Clk,
        Rst          => Bus2IP_Reset
    );

-------------------------------------------------------------------------------
-- Memory Paramter Selector
-------------------------------------------------------------------------------

SELECT_PARAM_I: entity emc_common_v3_0.select_param
    generic map (
        C_NUM_BANKS_MEM                 => C_NUM_BANKS_MEM,
        C_GLOBAL_SYNC_MEM               => GLOBAL_SYNC_MEM,
        C_SYNCH_MEM_0                   => C_SYNCH_MEM_0,
        C_SYNCH_MEM_1                   => C_SYNCH_MEM_1,
        C_SYNCH_MEM_2                   => C_SYNCH_MEM_2,
        C_SYNCH_MEM_3                   => C_SYNCH_MEM_3,

        C_MEM0_WIDTH                    => C_MEM0_WIDTH,
        C_MEM1_WIDTH                    => C_MEM1_WIDTH,
        C_MEM2_WIDTH                    => C_MEM2_WIDTH,
        C_MEM3_WIDTH                    => C_MEM3_WIDTH,

        C_PAGEMODE_FLASH                => PAGEMODE_FLASH,
        C_PAGEMODE_FLASH_0              => C_PAGEMODE_FLASH_0,
        C_PAGEMODE_FLASH_1              => C_PAGEMODE_FLASH_1,
        C_PAGEMODE_FLASH_2              => C_PAGEMODE_FLASH_2,
        C_PAGEMODE_FLASH_3              => C_PAGEMODE_FLASH_3,

        PARITY_TYPE_MEMORY              => PARITY_TYPE_MEMORY,
        C_PARITY_TYPE_0                 => C_PARITY_TYPE_0,
        C_PARITY_TYPE_1                 => C_PARITY_TYPE_1,
        C_PARITY_TYPE_2                 => C_PARITY_TYPE_2,
        C_PARITY_TYPE_3                 => C_PARITY_TYPE_3,

        C_SYNCH_PIPEDELAY_0             => C_SYNCH_PIPEDELAY_0,
        C_SYNCH_PIPEDELAY_1             => C_SYNCH_PIPEDELAY_1,
        C_SYNCH_PIPEDELAY_2             => C_SYNCH_PIPEDELAY_2,
        C_SYNCH_PIPEDELAY_3             => C_SYNCH_PIPEDELAY_3,

        C_GLOBAL_DATAWIDTH_MATCH        => GLOBAL_DATAWIDTH_MATCH,
        C_INCLUDE_DATAWIDTH_MATCHING_0  => C_INCLUDE_DATAWIDTH_MATCHING_0,
        C_INCLUDE_DATAWIDTH_MATCHING_1  => C_INCLUDE_DATAWIDTH_MATCHING_1,
        C_INCLUDE_DATAWIDTH_MATCHING_2  => C_INCLUDE_DATAWIDTH_MATCHING_2,
        C_INCLUDE_DATAWIDTH_MATCHING_3  => C_INCLUDE_DATAWIDTH_MATCHING_3,

        TRDCNT_0                        => TRDCNT_0,
        TRDCNT_1                        => TRDCNT_1,
        TRDCNT_2                        => TRDCNT_2,
        TRDCNT_3                        => TRDCNT_3,

        THZCNT_0                        => THZCNT_0,
        THZCNT_1                        => THZCNT_1,
        THZCNT_2                        => THZCNT_2,
        THZCNT_3                        => THZCNT_3,

        TWRCNT_0                        => TWRCNT_0,
        TWRCNT_1                        => TWRCNT_1,
        TWRCNT_2                        => TWRCNT_2,
        TWRCNT_3                        => TWRCNT_3,

        TWPHCNT_0                       => TWPHCNT_0,
        TWPHCNT_1                       => TWPHCNT_1,
        TWPHCNT_2                       => TWPHCNT_2,
        TWPHCNT_3                       => TWPHCNT_3,


        C_IPIF_AWIDTH                   => C_IPIF_AWIDTH,
        C_IPIF_DWIDTH                   => C_IPIF_DWIDTH,


        TPACC_0                         => TPACC_0,
        TPACC_1                         => TPACC_1,
        TPACC_2                         => TPACC_2,
        TPACC_3                         => TPACC_3,

        TLZCNT_0                        => TLZCNT_0,
        TLZCNT_1                        => TLZCNT_1,
        TLZCNT_2                        => TLZCNT_2,
        TLZCNT_3                        => TLZCNT_3,

        TP_WR_REC_CNT_0                 => TP_WR_REC_CNT_0,--7/4/2011
        TP_WR_REC_CNT_1                 => TP_WR_REC_CNT_1,
        TP_WR_REC_CNT_2                 => TP_WR_REC_CNT_2,
        TP_WR_REC_CNT_3                 => TP_WR_REC_CNT_3
    )
    port map (
        Bus2IP_Mem_CS                   => bus2ip_cs_reg,
        Bus2IP_Addr                     => Bus2IP_Addr,
        Bus2IP_Clk                      => Bus2IP_Clk,
        Bus2IP_Reset                    => Bus2IP_Reset,
        Bus2IP_RNW                      => Bus2IP_RNW,
        psram_page_mode                 => psram_page_mode,

        New_page_access                 => new_page_access,
        Parity_enable                   => Parity_enable,
        Parity_type                     => Parity_type,


        Twr_data                        => twr_data,
        Twph_data                       => twph_data,
        Tlz_data                        => tlz_data,
        Trd_data                        => trd_data,
        Thz_data                        => thz_data,
        Tpacc_data                      => tpacc_data,
        Twr_rec_data                    => twr_rec_data_int,-- 9/6/2011

	Synch_mem                       => synch_mem1,
        Mem_width_bytes                 => mem_width_bytes,
        Two_pipe_delay                  => two_pipe_delay,
        Datawidth_match                 => datawidth_match
    );

-------------------------------------------------------------------------------
-- Memory Data/Control Steering Logic
-------------------------------------------------------------------------------

MEM_STEER_I : entity emc_common_v3_0.mem_steer
    generic map(
        C_NUM_BANKS_MEM          => C_NUM_BANKS_MEM,
        C_MAX_MEM_WIDTH          => C_MAX_MEM_WIDTH,
        C_MIN_MEM_WIDTH          => MIN_MEM_WIDTH,
        C_IPIF_DWIDTH            => C_IPIF_DWIDTH,
        C_IPIF_AWIDTH            => C_IPIF_AWIDTH,
        C_ADDR_CNTR_WIDTH        => ADDR_CNTR_WIDTH,
        C_PARITY_TYPE_MEMORY     => PARITY_TYPE_MEMORY,
        C_GLOBAL_SYNC_MEM        => GLOBAL_SYNC_MEM,
        C_GLOBAL_DATAWIDTH_MATCH => GLOBAL_DATAWIDTH_MATCH
    )
    port map(
        --
        --Clk                      => Bus2IP_Clk,
        --Rst                      => Bus2IP_Reset
        Clk                      => Bus2IP_Clk,
        Rst                      => Bus2IP_Reset,

        Bus2IP_Data              => Bus2IP_Data,     -- in std_logic_vector
        Bus2IP_BE                => bus2ip_ben_int,  -- in std_logic_vector
        Bus2IP_Mem_CS            => bus2ip_cs_reg,   -- in std_logic_vector
        Bus2IP_RdReq             => bus2Mem_RdReq,   -- in  std_logic;
        Bus2IP_Burst             => bus2ip_burst,    -- in  std_logic;

        Write_req_ack            => write_req_ack,    -- in  std_logic;
        Read_req_ack             => read_req_ack,     -- in  std_logic;
        Read_ack                 => read_ack,         -- in  std_logic;
        Read_data_en             => read_data_en,     -- in  std_logic;
        --Data_strobe              => data_strobe,      -- in  std_logic;09-12-2012
        MSM_Mem_CEN              => mem_CEN_cmb,      -- in  std_logic;
        MSM_Mem_OEN              => mem_OEN_cmb,      -- in  std_logic;
        MSM_Mem_WEN              => mem_WEN_cmb,      -- in  std_logic;
        Mem2Bus_WrAddrAck        => mem2Bus_WrAddrAck,-- out std_logic;
        Mem2Bus_WrAck            => mem2Bus_WrAck,    -- out std_logic;
        Mem2Bus_RdAddrAck        => mem2Bus_RdAddrAck,-- out std_logic;
        Mem2Bus_RdAck            => mem2Bus_RdAck,    -- out std_logic;
        Mem2Bus_Data             => mem2Bus_Data,     -- out std_logic_vector

        Mem_width_bytes          => mem_width_bytes,   -- in  std_logic_vector
        Synch_mem                => synch_mem1,         -- in  std_logic;
        Two_pipe_delay           => two_pipe_delay,    -- in  std_logic;
        single_transaction       => single_transaction,-- in  std_logic;

        Parity_enable            => Parity_enable,     -- out std_logic_vector
        Parity_type              => Parity_type,       -- in  std_logic;
        parity_error_mem         => parity_error_mem,  -- in  std_logic;
        Parity_err               => Parity_err_i,      -- out std_logic;

        Addr_cnt                 => addr_cnt,          -- in  std_logic_vector
        Addr_align               => addr_align_write,  -- in  std_logic
        Addr_align_rd            => addr_align_rd,     -- in  std_logic

        MemSteer_Mem_DQ_I        => mem_dq_i_int,      -- in  std_logic_vector
        MemSteer_Mem_DQ_O        => mem_dq_o_int,      -- out  std_logic_vector
        MemSteer_Mem_DQ_T        => mem_dq_t_int,      -- out  std_logic_vector

        MemSteer_Mem_DQ_prty_I   => mem_dq_parity_i_int,-- in  std_logic_vector
        MemSteer_Mem_DQ_prty_O   => mem_dq_parity_o_int,-- out  std_logic_vector
        MemSteer_Mem_DQ_prty_T   => mem_dq_parity_t_int,-- out  std_logic_vector

        MemSteer_Mem_CEN         => mem_cen_int,     -- out  std_logic_vector
        MemSteer_Mem_OEN         => mem_oen_int,     -- out  std_logic_vector
        MemSteer_Mem_WEN         => mem_wen_int,     -- out  std_logic
        MemSteer_Mem_QWEN        => mem_qwen_int,    -- out  std_logic_vector
        MemSteer_Mem_BEN         => mem_ben_int,     -- out  std_logic_vector
        MemSteer_Mem_CE          => mem_ce_int,      -- out  std_logic_vector
        MemSteer_Mem_RNW         => mem_rnw_int,     -- out  std_logic

        Bus2IP_RdReq_emc         => Bus2IP_RdReq_emc, -- in  std_logic;
        Bus2IP_WrReq_emc         => Bus2IP_WrReq_emc,  -- in  std_logic;

        Write_req_data_ack       => Write_req_data_ack,
        Write_req_addr_ack       => Write_req_addr_ack,

        address_strobe_c         => address_strobe_c, --- in
        be_strobe_c              => be_strobe_c     ,  -- in
        data_strobe_c            => data_strobe_c,     -- in
        ns_idle                  => ns_idle   ,         -- in
        Linear_flash_brst_rd_flag  => Linear_flash_brst_rd_flag,
        Linear_flash_rd_data_ack   => Linear_flash_rd_data_ack,
        last_addr => last_addr1, -- 10-12-2012
        stop_oen => stop_oen ,-- 10-12-2012
        cycle_end        => cycle_End ,
        axi_arsize       => axi_arsize,
        axi_trans_size_reg       => axi_trans_size_reg

    );

-------------------------------------------------------------------------------
-- Instantiate the IO register block to memory
-- IO registers will be instantiated based on the parameter settings
-------------------------------------------------------------------------------

IO_REGISTERS_I: entity emc_common_v3_0.io_registers
    generic map (
        --C_FLASH_SYNC_RD          => C_FLASH_SYNC_RD,
        C_INCLUDE_NEGEDGE_IOREGS => C_INCLUDE_NEGEDGE_IOREGS,
        C_IPIF_AWIDTH            => C_IPIF_AWIDTH,
        C_MAX_MEM_WIDTH          => C_MAX_MEM_WIDTH,
        C_NUM_BANKS_MEM          => C_NUM_BANKS_MEM
    )
    port map (
	     Linear_flash_brst_rd_flag=> Linear_flash_brst_rd_flag, -- 1/28/2013
        Clk                      => Bus2IP_Clk,     --in  std_logic
        RdClk                    => RdClk,          --in  std_logic
        Rst                      => Bus2IP_Reset,   --in  std_logic

        Mem_A_int                => mem_a_int,      --in  std_logic_vector

        Mem_DQ_I_int             => mem_dq_i_int,   --out std_logic_vector
        Mem_DQ_O_int             => mem_dq_o_int,   --in  std_logic_vector
        Mem_DQ_T_int             => mem_dq_t_int,   --in  std_logic_vector

        Mem_DQ_PARITY_I_int      => mem_dq_parity_i_int, --out std_logic_vector
        Mem_DQ_PARITY_O_int      => mem_dq_parity_o_int, --in  std_logic_vector
        Mem_DQ_PARITY_T_int      => mem_dq_parity_t_int, --in  std_logic_vector

        Mem_CEN_int              => mem_cen_int,     --in  std_logic_vector
        Mem_OEN_int              => mem_oen_int,     --in  std_logic_vector
        Mem_WEN_int              => mem_wen_int,     --in  std_logic;
        Mem_QWEN_int             => mem_qwen_int,    --in  std_logic_vector
        Mem_BEN_int              => mem_ben_int,     --in  std_logic_vector
        Mem_RPN_int              => mem_rpn_int,     --in  std_logic;
        Mem_CE_int               => mem_ce_int,      --in  std_logic_vector
        Mem_ADV_LDN_int          => mem_adv_ldn_int, --in  std_logic;
        Mem_LBON_int             => mem_lbon_int,    --in  std_logic;
        Mem_CKEN_int             => mem_cken_int,    --in  std_logic;
        Mem_RNW_int              => mem_rnw_int,     --in  std_logic;

        Mem_Addr_rst             => Mem_Addr_rst,    --in  std_logic
        --Linear_flash_rd_data_ack => Linear_flash_rd_data_ack, -- out std_logic;
        Mem_A                    => Mem_A,           --out std_logic_vector
        Mem_DQ_I                 => Mem_DQ_I,        --in  std_logic_vector
        Mem_DQ_O                 => Mem_DQ_O,        --out std_logic_vector
        Mem_DQ_T                 => Mem_DQ_T,        --out std_logic_vector

        Mem_DQ_PRTY_I            => Mem_DQ_PRTY_I,   --in  std_logic_vector
        Mem_DQ_PRTY_O            => Mem_DQ_PRTY_O,   --out std_logic_vector
        Mem_DQ_PRTY_T            => Mem_DQ_PRTY_T,   --out std_logic_vector

        Mem_CEN                  => Mem_CEN,         --out std_logic_vector
        Mem_OEN                  => Mem_OEN,         --out std_logic_vector
        Mem_WEN                  => Mem_WEN,         --out std_logic;
        Mem_QWEN                 => Mem_QWEN,        --out std_logic_vector
        Mem_BEN                  => Mem_BEN,         --out std_logic_vector
        Mem_RPN                  => Mem_RPN,         --out std_logic;
        Mem_CE                   => Mem_CE,          --out std_logic_vector
        Mem_ADV_LDN              => Mem_ADV_LDN,     --out std_logic;
        Mem_LBON                 => Mem_LBON,        --out std_logic;
        Mem_CKEN                 => Mem_CKEN,        --out std_logic;
        Mem_RNW                  => Mem_RNW          --out std_logic
        --Mem_WAIT                 => Mem_WAIT,        --in std_logic
        --Mem_Flash_clk            => Mem_Flash_clk    --in std_logic
    );
synch_mem12 <= synch_mem1;
end architecture imp;
-------------------------------------------------------------------------------
-- End of File emc.vhd
-------------------------------------------------------------------------------
