-------------------------------------------------------------------------------
-- $Id: axi_emc.vhd
-------------------------------------------------------------------------------
-- axi_emc.vhd - Entity and architecture
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
-- Filename:        axi_emc.vhd
-- Version:         v2.0
-- Description:     This is the top-level design file for the AXI External
--                  Memory Controller.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--
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
--
-- History:
-- ~~~~~~
--  SK 10/02/10  -- created v1.01.a version
-- ^^^^^^
-- 1. Replaced the AXI Lite IPIF interface with AXI4 lite native interface
-- 2. Replaced the AXI Slave Burst interface with AXI4 full native interface
-- 3. Reduced the core utilization to resolve CR 573074
-- ~~~~~~
--  SK 12/02/10
-- ^^^^^^
-- 1. Added NO_REG_EN_GEN section to drive all the output signals in the register
--    interface to '0' when not selected.
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
--  SK 04/14/13
-- ^^^^^^
--  -- Fixed CR 723506 - Fixed issues with the signal driven X when parity is enabled.
--  -- Fixed CR 721840 - Fixed issues in linear sync flash memory mode, parameter ordering is updated
-- ~~~~~~

-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.conv_std_logic_vector;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_misc.all;
-- library unsigned is used for overloading of "=" which allows integer to
-- be compared to std_logic_vector
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

library emc_common_v3_0;
use emc_common_v3_0.all;

library axi_emc_v3_0;
use axi_emc_v3_0.all;
use axi_emc_v3_0.emc_pkg.all;

-------------------------------------------------------------------------------
-- Port Declaration
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Definition of Generics:
--
--  C_NUM_BANKS_MEM                 -- Number of memory banks
--  C_MEM0_TYPE                     -- Type of Memory
--                                      0-> Sync SRAM
--                                      1-> Async SRAM
--                                      2-> Nor Flash
--                                      3-> Page Mode Nor Flash
--                                      4-> Cellar RAM/PSRAM
--  C_PARITY_TYPE_MEM_0             -- Type of Parity
--                                      0-> No Parity
--                                      1-> Odd Parity
--                                      2-> Even Parity
--  C_INCLUDE_NEGEDGE_IOREGS        -- Include negative edge IO registers
--  C_NUM_MASTERS                   -- Number of axi masters
--  C_MEM(0:3)_BASEADDR             -- Memory bank (0:3) base address
--  C_MEM(0:3)_HIGHADDR             -- Memory bank (0:3) high address
--  C_MEM(0:3)_WIDTH                -- Memory bank (0:3) data width
--  C_MAX_MEM_WIDTH                 -- Maximum data width of all memory banks
--
--  C_INCLUDE_DATAWIDTH_MATCHING_(0:3) --  Support data width matching for
--                                          memory bank (0:3)
--  C_SYNCH_MEM_(0:3)               -- Memory bank (0:3) type
--  C_SYNCH_PIPEDELAY_(0:3)         -- Memory bank (0:3) synchronous pipedelay
--  C_TCEDV_PS_MEM_(0:3)            -- Chip Enable to Data Valid Time
--                                  -- (Maximum of TCEDV and TAVDV applied
--                                     as read cycle start to first data valid)
--  C_TAVDV_PS_MEM_(0:3)            -- Address Valid to Data Valid Time
--                                  -- (Maximum of TCEDV and TAVDV applied
--                                     as read cycle start to first data valid)
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
--  C_WR_REC_TIME_MEM_0             -- Write recovery time between the write
--                                  -- and next consecutive read transaction

--  C_S_AXI_MEM_DWIDTH              --  axi Data Bus Width
--  C_S_AXI_MEM_AWIDTH              --  axi Address Width
--  C_AXI_CLK_PERIOD_PS             --  axi clock period to calculate wait
--                                         state pulse widths.
--
--
-- Definition of Ports:
-- Memory Signals
--  mem_a                  -- Memory address inputs
--  mem_dq_i               -- Memory Input Data Bus
--  mem_dq_o               -- Memory Output Data Bus
--  mem_dq_t               -- Memory Data Output Enable
--  mem_dq_parity_i        -- Memory Parity Input Data Bus
--  mem_dq_parity_o        -- Memory Parity Output Data Bus
--  mem_dq_parity_t        -- Memory Parity Output Enable
--  mem_cen                -- Memory Chip Select
--  mem_oen                -- Memory Output Enable
--  mem_wen                -- Memory Write Enable
--  mem_qwen               -- Memory Qualified Write Enable
--  mem_ben                -- Memory Byte Enables
--  mem_rpn                -- Memory Reset/Power Down
--  mem_ce                 -- Memory chip enable
--  mem_adv_ldn            -- Memory counter advance/load (=0)
--  mem_lbon               -- Memory linear/interleaved burst order (=0)
--  mem_cken               -- Memory clock enable (=0)
--  mem_rnw                -- Memory read not write
-------------------------------------------------------------------------------

entity axi_emc is
   -- Generics to be set by user
    generic (

        C_FAMILY                       : string := "virtex6";
        C_INSTANCE                     : string := "axi_emc_inst";
        C_AXI_CLK_PERIOD_PS            : integer := 10000;
        C_LFLASH_PERIOD_PS             : integer := 20000;
        C_LINEAR_FLASH_SYNC_BURST      : integer range 0 to 1   := 0;

        ---- AXI REG Parameters
        C_S_AXI_REG_ADDR_WIDTH         : integer range 5 to 5 := 5;
        C_S_AXI_REG_DATA_WIDTH         : integer range 32 to 32 := 32;

        C_S_AXI_EN_REG                 : integer range 0 to 1   := 0;
        ----C_S_AXI_REG_BASEADDR           : std_logic_vector := x"FFFFFFFF";
        ----C_S_AXI_REG_HIGHADDR           : std_logic_vector := x"00000000";

        ---- AXI MEM Parameters
        C_S_AXI_MEM_ADDR_WIDTH         : integer range 32 to 32 := 32;
        C_S_AXI_MEM_DATA_WIDTH         : integer                := 32;--8,16,32,64
        C_S_AXI_MEM_ID_WIDTH           : integer range 1  to 16 := 4;

        C_S_AXI_MEM0_BASEADDR          : std_logic_vector := x"FFFFFFFF";
        C_S_AXI_MEM0_HIGHADDR          : std_logic_vector := x"00000000";
        C_S_AXI_MEM1_BASEADDR          : std_logic_vector := x"FFFFFFFF";
        C_S_AXI_MEM1_HIGHADDR          : std_logic_vector := x"00000000";
        C_S_AXI_MEM2_BASEADDR          : std_logic_vector := x"FFFFFFFF";
        C_S_AXI_MEM2_HIGHADDR          : std_logic_vector := x"00000000";
        C_S_AXI_MEM3_BASEADDR          : std_logic_vector := x"FFFFFFFF";
        C_S_AXI_MEM3_HIGHADDR          : std_logic_vector := x"00000000";

        -- EMC generics
        C_INCLUDE_NEGEDGE_IOREGS       : integer range 0 to 1   := 0;

        C_NUM_BANKS_MEM                : integer range 1 to 4   := 1;

        C_MEM0_TYPE                    : integer range 0 to 5  := 0;
        C_MEM1_TYPE                    : integer range 0 to 5  := 0;
        C_MEM2_TYPE                    : integer range 0 to 5  := 0;
        C_MEM3_TYPE                    : integer range 0 to 5  := 0;

        C_MEM0_WIDTH                   : integer := 32;--8,16,32,64 allowed
        C_MEM1_WIDTH                   : integer := 32;--8,16,32,64
        C_MEM2_WIDTH                   : integer := 32;--8,16,32,64
        C_MEM3_WIDTH                   : integer := 32;--8,16,32,64

        C_MAX_MEM_WIDTH                : integer := 32;--8,16,32,64

        -- parity type of memory 0-no parity, 1-odd parity, 2-even parity
        C_PARITY_TYPE_MEM_0            : integer range 0 to 2  := 0;
        C_PARITY_TYPE_MEM_1            : integer range 0 to 2  := 0;
        C_PARITY_TYPE_MEM_2            : integer range 0 to 2  := 0;
        C_PARITY_TYPE_MEM_3            : integer range 0 to 2  := 0;

        C_INCLUDE_DATAWIDTH_MATCHING_0 : integer range 0 to 1   := 0;
        C_INCLUDE_DATAWIDTH_MATCHING_1 : integer range 0 to 1   := 0;
        C_INCLUDE_DATAWIDTH_MATCHING_2 : integer range 0 to 1   := 0;
        C_INCLUDE_DATAWIDTH_MATCHING_3 : integer range 0 to 1   := 0;

        -- Memory read and write access times for all memory banks

        C_SYNCH_PIPEDELAY_0            : integer range 1 to 2   := 2;
        C_TCEDV_PS_MEM_0               : integer := 15000;
        C_TAVDV_PS_MEM_0               : integer := 15000;
        C_TPACC_PS_FLASH_0             : integer := 25000;
        C_THZCE_PS_MEM_0               : integer := 7000;
        C_THZOE_PS_MEM_0               : integer := 7000;
        C_TWC_PS_MEM_0                 : integer := 15000;
        C_TWP_PS_MEM_0                 : integer := 12000;
        C_TWPH_PS_MEM_0                : integer := 12000;
        C_TLZWE_PS_MEM_0               : integer := 0;
        C_WR_REC_TIME_MEM_0            : integer := 270000000;

        C_SYNCH_PIPEDELAY_1            : integer range 1 to 2   := 2;
        C_TCEDV_PS_MEM_1               : integer := 15000;
        C_TAVDV_PS_MEM_1               : integer := 15000;
        C_TPACC_PS_FLASH_1             : integer := 25000;
        C_THZCE_PS_MEM_1               : integer := 7000;
        C_THZOE_PS_MEM_1               : integer := 7000;
        C_TWC_PS_MEM_1                 : integer := 15000;
        C_TWP_PS_MEM_1                 : integer := 12000;
        C_TWPH_PS_MEM_1                : integer := 12000;
        C_TLZWE_PS_MEM_1               : integer := 0;
        C_WR_REC_TIME_MEM_1            : integer := 270000000;

        C_SYNCH_PIPEDELAY_2            : integer range 1 to 2   := 2;
        C_TCEDV_PS_MEM_2               : integer := 15000;
        C_TAVDV_PS_MEM_2               : integer := 15000;
        C_TPACC_PS_FLASH_2             : integer := 25000;
        C_THZCE_PS_MEM_2               : integer := 7000;
        C_THZOE_PS_MEM_2               : integer := 7000;
        C_TWC_PS_MEM_2                 : integer := 15000;
        C_TWP_PS_MEM_2                 : integer := 12000;
        C_TWPH_PS_MEM_2                : integer := 12000;
        C_TLZWE_PS_MEM_2               : integer := 0;
        C_WR_REC_TIME_MEM_2            : integer := 270000000;

        C_SYNCH_PIPEDELAY_3            : integer range 1 to 2   := 2;
        C_TCEDV_PS_MEM_3               : integer := 15000;
        C_TAVDV_PS_MEM_3               : integer := 15000;
        C_TPACC_PS_FLASH_3             : integer := 25000;
        C_THZCE_PS_MEM_3               : integer := 7000;
        C_THZOE_PS_MEM_3               : integer := 7000;
        C_TWC_PS_MEM_3                 : integer := 15000;
        C_TWP_PS_MEM_3                 : integer := 12000;
        C_TWPH_PS_MEM_3                : integer := 12000;
        C_TLZWE_PS_MEM_3               : integer := 0    ;
        C_WR_REC_TIME_MEM_3            : integer := 270000000

    );
    port (
--  -- AXI Slave signals ------------------------------------------------------
    -- AXI Global System Signals
    s_axi_aclk          : in  std_logic;
    s_axi_aresetn       : in  std_logic;
    rdclk               : in std_logic;

    -- axi lite interface
--  -- axi write address Channel Signals
    s_axi_reg_awaddr  : in  std_logic_vector
                            (4 downto 0);
    s_axi_reg_awvalid : in  std_logic;
    s_axi_reg_awready : out std_logic;

--  -- axi write channel Signals
    s_axi_reg_wdata   : in  std_logic_vector
                            (31 downto 0);
    s_axi_reg_wstrb   : in  std_logic_vector
                            (3 downto 0);
    s_axi_reg_wvalid  : in  std_logic;
    s_axi_reg_wready  : out std_logic;

--  -- axi write response Channel Signals
    s_axi_reg_bresp   : out std_logic_vector(1 downto 0);
    s_axi_reg_bvalid  : out std_logic;
    s_axi_reg_bready  : in  std_logic;
--  -- axi read address Channel Signals
    s_axi_reg_araddr  : in  std_logic_vector
                            (4 downto 0);
    s_axi_reg_arvalid : in  std_logic;
    s_axi_reg_arready : out std_logic;
--   -- axi read data Channel Signals
    s_axi_reg_rdata   : out std_logic_vector
                            (31 downto 0);
    s_axi_reg_rresp   : out std_logic_vector(1 downto 0);
    s_axi_reg_rvalid  : out std_logic;
    s_axi_reg_rready  : in  std_logic;

--  -- axi full interface
--  -- axi write address Channel Signals
    s_axi_mem_awid    : in  std_logic_vector((C_S_AXI_MEM_ID_WIDTH-1)
                                                                downto 0);
    s_axi_mem_awaddr  : in  std_logic_vector(31 downto 0);
    s_axi_mem_awlen   : in  std_logic_vector(7 downto 0);
    s_axi_mem_awsize  : in  std_logic_vector(2 downto 0);
    s_axi_mem_awburst : in  std_logic_vector(1 downto 0);
    s_axi_mem_awlock  : in  std_logic;
    s_axi_mem_awcache : in  std_logic_vector(3 downto 0);
    s_axi_mem_awprot  : in  std_logic_vector(2 downto 0);
    s_axi_mem_awvalid : in  std_logic;
    s_axi_mem_awready : out std_logic;
--  -- axi write channel Signals
    s_axi_mem_wdata   : in  std_logic_vector((C_S_AXI_MEM_DATA_WIDTH-1)
                                                                downto 0);
    s_axi_mem_wstrb   : in  std_logic_vector
                            (((C_S_AXI_MEM_DATA_WIDTH/8)-1) downto 0);
    s_axi_mem_wlast   : in  std_logic;
    s_axi_mem_wvalid  : in  std_logic;
    s_axi_mem_wready  : out std_logic;
--  -- axi write response Channel Signals
    s_axi_mem_bid     : out std_logic_vector((C_S_AXI_MEM_ID_WIDTH-1)
                                                                downto 0);
    s_axi_mem_bresp   : out std_logic_vector(1 downto 0);
    s_axi_mem_bvalid  : out std_logic;
    s_axi_mem_bready  : in  std_logic;
--  -- axi read address Channel Signals
    s_axi_mem_arid    : in  std_logic_vector((C_S_AXI_MEM_ID_WIDTH-1) downto 0);
    s_axi_mem_araddr  : in  std_logic_vector(31 downto 0);
    s_axi_mem_arlen   : in  std_logic_vector(7 downto 0);
    s_axi_mem_arsize  : in  std_logic_vector(2 downto 0);
    s_axi_mem_arburst : in  std_logic_vector(1 downto 0);
    s_axi_mem_arlock  : in  std_logic;
    s_axi_mem_arcache : in  std_logic_vector(3 downto 0);
    s_axi_mem_arprot  : in  std_logic_vector(2 downto 0);
    s_axi_mem_arvalid : in  std_logic;
    s_axi_mem_arready : out std_logic;

--   -- axi read data Channel Signals
    s_axi_mem_rid     : out std_logic_vector((C_S_AXI_MEM_ID_WIDTH-1)
                                                                downto 0);
    s_axi_mem_rdata   : out std_logic_vector((C_S_AXI_MEM_DATA_WIDTH-1)
                                                                downto 0);
    s_axi_mem_rresp   : out std_logic_vector(1 downto 0);
    s_axi_mem_rlast   : out std_logic;
    s_axi_mem_rvalid  : out std_logic;
    s_axi_mem_rready  : in  std_logic;


    -- memory signals
    mem_dq_i          : in  std_logic_vector((C_MAX_MEM_WIDTH-1) downto 0);
    mem_dq_o          : out std_logic_vector((C_MAX_MEM_WIDTH-1) downto 0);
    mem_dq_t          : out std_logic_vector((C_MAX_MEM_WIDTH-1) downto 0);

    mem_dq_parity_i   : in  std_logic_vector(((C_MAX_MEM_WIDTH/8)-1) downto 0);
    mem_dq_parity_o   : out std_logic_vector(((C_MAX_MEM_WIDTH/8)-1) downto 0);
    mem_dq_parity_t   : out std_logic_vector(((C_MAX_MEM_WIDTH/8)-1) downto 0);

    mem_a             : out std_logic_vector(31 downto 0);
    -- chip selects
    mem_ce            : out std_logic_vector((C_NUM_BANKS_MEM-1) downto 0);
    mem_cen           : out std_logic_vector((C_NUM_BANKS_MEM-1) downto 0);
    -- read enable
    mem_oen           : out std_logic_vector((C_NUM_BANKS_MEM-1) downto 0);
    -- write enable
    mem_wen           : out std_logic;-- write enable
    -- byte enables
    mem_ben           : out std_logic_vector((C_MAX_MEM_WIDTH/8-1) downto 0);
    mem_qwen          : out std_logic_vector((C_MAX_MEM_WIDTH/8-1) downto 0);
    -- reset or power down
    mem_rpn           : out std_logic;
    -- address valid active low
    mem_adv_ldn       : out std_logic;
    -- interleaved burst order
    mem_lbon          : out std_logic;
    -- clock enable
    mem_cken          : out std_logic;
    -- synch mem read not write signal
    mem_rnw           : out std_logic;
    --
    mem_cre           : out std_logic;
    mem_wait          : in std_logic_vector(C_NUM_BANKS_MEM -1 downto 0)
    );

     -- Fan-out attributes for XST
     attribute MAX_FANOUT                             : string;
     attribute MAX_FANOUT of s_axi_aclk               : signal is "10000";
     attribute MAX_FANOUT of s_axi_aresetn            : signal is "10000";
     attribute MAX_FANOUT of rdclk                    : signal is "10000";

     -- Added attribute to FIX CR CR204317. The following attribute prevent
     -- the tools from optimizing the tristate control down to a single
     -- registered signal and to pack input, output, and tri-state registers
     -- into the IOB.

     attribute EQUIVALENT_REGISTER_REMOVAL            : string;
     attribute EQUIVALENT_REGISTER_REMOVAL of Mem_DQ_T: signal is "no";
     attribute EQUIVALENT_REGISTER_REMOVAL of MEM_DQ_PARITY_T: signal is "no";


     -- SIGIS attribute for specifying clocks,interrrupts,resets for EDK
     attribute SIGIS                                  : string;
     attribute SIGIS of s_axi_aclk                    : signal is "Clk" ;
     attribute SIGIS of s_axi_aresetn                 : signal is "Rst" ;
     attribute SIGIS of rdclk                         : signal is "Clk" ;

     -- Minimum size attribute for EDK
     attribute MIN_SIZE                               : string;
     attribute MIN_SIZE of C_S_AXI_MEM0_BASEADDR      : constant is "0x08";
     attribute MIN_SIZE of C_S_AXI_MEM1_BASEADDR      : constant is "0x08";
     attribute MIN_SIZE of C_S_AXI_MEM2_BASEADDR      : constant is "0x08";
     attribute MIN_SIZE of C_S_AXI_MEM3_BASEADDR      : constant is "0x08";

    -- Assignment attribute for EDK
    attribute ASSIGNMENT                             : string;
    attribute ASSIGNMENT of C_S_AXI_MEM0_BASEADDR    : constant is "REQUIRE";
    attribute ASSIGNMENT of C_S_AXI_MEM0_HIGHADDR    : constant is "REQUIRE";
    attribute ASSIGNMENT of C_S_AXI_MEM1_BASEADDR    : constant is "REQUIRE";
    attribute ASSIGNMENT of C_S_AXI_MEM1_HIGHADDR    : constant is "REQUIRE";
    attribute ASSIGNMENT of C_S_AXI_MEM2_BASEADDR    : constant is "REQUIRE";
    attribute ASSIGNMENT of C_S_AXI_MEM2_HIGHADDR    : constant is "REQUIRE";
    attribute ASSIGNMENT of C_S_AXI_MEM3_BASEADDR    : constant is "REQUIRE";
    attribute ASSIGNMENT of C_S_AXI_MEM3_HIGHADDR    : constant is "REQUIRE";
    attribute ASSIGNMENT of C_S_AXI_MEM_ADDR_WIDTH   : constant is "CONSTANT";

    -- ADDR_TYPE attribute for EDK
    attribute ADDR_TYPE                              : string;
    attribute ADDR_TYPE of C_S_AXI_MEM0_BASEADDR     : constant is "MEMORY";
    attribute ADDR_TYPE of C_S_AXI_MEM0_HIGHADDR     : constant is "MEMORY";
    attribute ADDR_TYPE of C_S_AXI_MEM1_BASEADDR     : constant is "MEMORY";
    attribute ADDR_TYPE of C_S_AXI_MEM1_HIGHADDR     : constant is "MEMORY";
    attribute ADDR_TYPE of C_S_AXI_MEM2_BASEADDR     : constant is "MEMORY";
    attribute ADDR_TYPE of C_S_AXI_MEM2_HIGHADDR     : constant is "MEMORY";
    attribute ADDR_TYPE of C_S_AXI_MEM3_BASEADDR     : constant is "MEMORY";
    attribute ADDR_TYPE of C_S_AXI_MEM3_HIGHADDR     : constant is "MEMORY";

 ------------------------------------------------------------------------------
 -- end of PSFUtil MPD attributes
 ------------------------------------------------------------------------------
end axi_emc;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture imp of axi_emc is

----------------------------------------------------------------------------------
-- below attributes are added to reduce the synth warnings in Vivado tool
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of imp : architecture is "yes";
----------------------------------------------------------------------------------


--constant C_CORE_GENERATION_INFO : string := C_INSTANCE & ",axi_emc,{"
--      & "c_family="                   & C_FAMILY
--      & ",c_instance="                 & C_INSTANCE
--      & ",c_axi_clk_period_ps="        & integer'image(C_AXI_CLK_PERIOD_PS)
--      & ",c_lflash_period_ps="         & integer'image(C_LFLASH_PERIOD_PS)
--      & ",c_linear_flash_sync_burst="         & integer'image(C_LINEAR_FLASH_SYNC_BURST)
--      & ",c_s_axireg_addr_width="      & integer'image(C_S_AXI_REG_ADDR_WIDTH)
--      & ",c_s_axi_reg_data_width="     & integer'image(C_S_AXI_REG_DATA_WIDTH)
--      & ",c_s_axi_en_reg="             & integer'image(C_S_AXI_EN_REG)
--      & ",c_s_axi_mem_addr_width="     & integer'image(C_S_AXI_MEM_ADDR_WIDTH)
--      & ",c_s_axi_mem_data_width="     & integer'image(C_S_AXI_MEM_DATA_WIDTH)
--      & ",c_s_axi_mem_id_width="       & integer'image(C_S_AXI_MEM_ID_WIDTH)
--      & ",c_include_negedge_ioregs="   & integer'image(C_INCLUDE_NEGEDGE_IOREGS)
--      & ",c_num_banks_mem="            & integer'image(C_NUM_BANKS_MEM)
--      & ",c_mem0_type="                & integer'image(C_MEM0_TYPE)
--      & ",c_mem1_type="                & integer'image(C_MEM1_TYPE)
--      & ",c_mem2_type="                & integer'image(C_MEM2_TYPE)
--      & ",c_mem3_type="                & integer'image(C_MEM3_TYPE)
--      & ",c_mem0_width="               & integer'image(C_MEM0_WIDTH)
--      & ",c_mem1_width="               & integer'image(C_MEM1_WIDTH)
--      & ",c_mem2_width="               & integer'image(C_MEM2_WIDTH)
--      & ",c_mem3_width="               & integer'image(C_MEM3_WIDTH)
--      & ",c_max_mem_width="            & integer'image(C_MAX_MEM_WIDTH)
--      & ",c_parity_type_mem_0="        & integer'image(C_PARITY_TYPE_MEM_0)
--      & ",c_parity_type_mem_1="        & integer'image(C_PARITY_TYPE_MEM_1)
--      & ",c_parity_type_mem_2="        & integer'image(C_PARITY_TYPE_MEM_2)
--      & ",c_parity_type_mem_3="        & integer'image(C_PARITY_TYPE_MEM_3)
--      & ",c_include_datawidth_matching_0="  & integer'image(C_INCLUDE_DATAWIDTH_MATCHING_0)
--      & ",c_include_datawidth_matching_1="  & integer'image(C_INCLUDE_DATAWIDTH_MATCHING_1)
--      & ",c_include_datawidth_matching_2="  & integer'image(C_INCLUDE_DATAWIDTH_MATCHING_2)
--      & ",c_include_datawidth_matching_3="  & integer'image(C_INCLUDE_DATAWIDTH_MATCHING_3)
--      & ",c_synch_pipedelay_0="             & integer'image(C_SYNCH_PIPEDELAY_0)
--      & ",c_synch_pipedelay_1="             & integer'image(C_SYNCH_PIPEDELAY_1)
--      & ",c_synch_pipedelay_2="             & integer'image(C_SYNCH_PIPEDELAY_2)
--      & ",c_synch_pipedelay_3="             & integer'image(C_SYNCH_PIPEDELAY_3)
--      & ",c_tcedv_ps_mem_0="                & integer'image(C_TCEDV_PS_MEM_0)
--      & ",c_tcedv_ps_mem_1="                & integer'image(C_TCEDV_PS_MEM_1)
--      & ",c_tcedv_ps_mem_2="                & integer'image(C_TCEDV_PS_MEM_2)
--      & ",c_tcedv_ps_mem_=3"                & integer'image(C_TCEDV_PS_MEM_3)
--      & ",c_tavdv_ps_mem_0="                & integer'image(C_TAVDV_PS_MEM_0)
--      & ",c_tavdv_ps_mem_1="                & integer'image(C_TAVDV_PS_MEM_1)
--      & ",c_tavdv_ps_mem_2="                & integer'image(C_TAVDV_PS_MEM_2)
--      & ",c_tavdv_ps_mem_3="                & integer'image(C_TAVDV_PS_MEM_3)
--      & ",c_tpacc_ps_flash_0="              & integer'image(C_TPACC_PS_FLASH_0)
--      & ",c_tpacc_ps_flash_1="              & integer'image(C_TPACC_PS_FLASH_1)
--      & ",c_tpacc_ps_flash_2="              & integer'image(C_TPACC_PS_FLASH_2)
--      & ",c_tpacc_ps_flash_3="              & integer'image(C_TPACC_PS_FLASH_3)
--      & ",c_thzce_ps_mem_0="                & integer'image(C_THZCE_PS_MEM_0)
--      & ",c_thzce_ps_mem_1="                & integer'image(C_THZCE_PS_MEM_1)
--      & ",c_thzce_ps_mem_2="                & integer'image(C_THZCE_PS_MEM_2)
--      & ",c_thzce_ps_mem_3="                & integer'image(C_THZCE_PS_MEM_3)
--      & ",c_thzoe_ps_mem_0="                & integer'image(C_THZOE_PS_MEM_0)
--      & ",c_thzoe_ps_mem_1="                & integer'image(C_THZOE_PS_MEM_1)
--      & ",c_thzoe_ps_mem_2="                & integer'image(C_THZOE_PS_MEM_2)
--      & ",c_thzoe_ps_mem_3="                & integer'image(C_THZOE_PS_MEM_3)
--      & ",c_twc_ps_mem_0="                  & integer'image(C_TWC_PS_MEM_0)
--      & ",c_twc_ps_mem_1="                  & integer'image(C_TWC_PS_MEM_1)
--      & ",c_twc_ps_mem_2="                  & integer'image(C_TWC_PS_MEM_2)
--      & ",c_twc_ps_mem_3="                  & integer'image(C_TWC_PS_MEM_3)
--      & ",c_twp_ps_mem_0="                  & integer'image(C_TWP_PS_MEM_0)
--      & ",c_twp_ps_mem_1="                  & integer'image(C_TWP_PS_MEM_1)
--      & ",c_twp_ps_mem_2="                  & integer'image(C_TWP_PS_MEM_2)
--      & ",c_twp_ps_mem_3="                  & integer'image(C_TWP_PS_MEM_3)
--      & ",c_twph_ps_mem_0="                 & integer'image(C_TWPH_PS_MEM_0)
--      & ",c_twph_ps_mem_1="                 & integer'image(C_TWPH_PS_MEM_1)
--      & ",c_twph_ps_mem_2="                 & integer'image(C_TWPH_PS_MEM_2)
--      & ",c_twph_ps_mem_3="                 & integer'image(C_TWPH_PS_MEM_3)
--      & ",c_tlzwe_ps_mem_0="                & integer'image(C_TLZWE_PS_MEM_0)
--      & ",c_tlzwe_ps_mem_1="                & integer'image(C_TLZWE_PS_MEM_1)
--      & ",c_tlzwe_ps_mem_2="                & integer'image(C_TLZWE_PS_MEM_2)
--      & ",c_tlzwe_ps_mem_3="                & integer'image(C_TLZWE_PS_MEM_3)
--      & ",c_wr_rec_time_mem_0="             & integer'image(C_WR_REC_TIME_MEM_0)
--      & ",c_wr_rec_time_mem_1="             & integer'image(C_WR_REC_TIME_MEM_1)
--      & ",c_wr_rec_time_mem_2="             & integer'image(C_WR_REC_TIME_MEM_2)
--      & ",c_wr_rec_time_mem_3="             & integer'image(C_WR_REC_TIME_MEM_3)
--      & "}";
--
--  attribute CORE_GENERATION_INFO : string;
--  attribute CORE_GENERATION_INFO of implementation : architecture is C_CORE_GENERATION_INFO;



-------------------------------------------------------------------------------
-- Constant Declarations
-------------------------------------------------------------------------------

-- addresses for axi_slave_burst are  64-bits wide - create constants to
-- zero the most significant address bits
constant ZERO_ADDR_PAD  : std_logic_vector(0 to 64-C_S_AXI_MEM_ADDR_WIDTH-1)
                        := (others => '0');

-- four banks with SRAM, ASYNC SRAM, PSRAM, Cellular RAM, Flash memory
type MEM_TYPE_ARRAY_TYPE is array (0 to 3) of integer range 0 to 5;

type MEM_PARITY_ARRAY_TYPE is array (0 to 3) of integer range 0 to 2;

-----------------------------------------------------------------------------
-- Function: get_AXI_ARD_ADDR_RANGE_ARRAY
-- Purpose: Fill AXI_ARD_ADDR_RANGE_ARRAY based on input parameters
-----------------------------------------------------------------------------
function get_AXI_ARD_ADDR_RANGE_ARRAY return SLV64_ARRAY_TYPE is
variable axi_ard_addr_range_array_v : SLV64_ARRAY_TYPE
                                        (0 to C_NUM_BANKS_MEM*2-1);
begin
    if (C_NUM_BANKS_MEM = 1) then
       axi_ard_addr_range_array_v(0) := ZERO_ADDR_PAD&C_S_AXI_MEM0_BASEADDR;
       axi_ard_addr_range_array_v(1) := ZERO_ADDR_PAD&C_S_AXI_MEM0_HIGHADDR;
    elsif (C_NUM_BANKS_MEM = 2) then
       axi_ard_addr_range_array_v(0) := ZERO_ADDR_PAD&C_S_AXI_MEM0_BASEADDR;
       axi_ard_addr_range_array_v(1) := ZERO_ADDR_PAD&C_S_AXI_MEM0_HIGHADDR;
       axi_ard_addr_range_array_v(2) := ZERO_ADDR_PAD&C_S_AXI_MEM1_BASEADDR;
       axi_ard_addr_range_array_v(3) := ZERO_ADDR_PAD&C_S_AXI_MEM1_HIGHADDR;
    elsif (C_NUM_BANKS_MEM = 3) then
       axi_ard_addr_range_array_v(0) := ZERO_ADDR_PAD&C_S_AXI_MEM0_BASEADDR;
       axi_ard_addr_range_array_v(1) := ZERO_ADDR_PAD&C_S_AXI_MEM0_HIGHADDR;
       axi_ard_addr_range_array_v(2) := ZERO_ADDR_PAD&C_S_AXI_MEM1_BASEADDR;
       axi_ard_addr_range_array_v(3) := ZERO_ADDR_PAD&C_S_AXI_MEM1_HIGHADDR;
       axi_ard_addr_range_array_v(4) := ZERO_ADDR_PAD&C_S_AXI_MEM2_BASEADDR;
       axi_ard_addr_range_array_v(5) := ZERO_ADDR_PAD&C_S_AXI_MEM2_HIGHADDR;
    else
       axi_ard_addr_range_array_v(0) := ZERO_ADDR_PAD&C_S_AXI_MEM0_BASEADDR;
       axi_ard_addr_range_array_v(1) := ZERO_ADDR_PAD&C_S_AXI_MEM0_HIGHADDR;
       axi_ard_addr_range_array_v(2) := ZERO_ADDR_PAD&C_S_AXI_MEM1_BASEADDR;
       axi_ard_addr_range_array_v(3) := ZERO_ADDR_PAD&C_S_AXI_MEM1_HIGHADDR;
       axi_ard_addr_range_array_v(4) := ZERO_ADDR_PAD&C_S_AXI_MEM2_BASEADDR;
       axi_ard_addr_range_array_v(5) := ZERO_ADDR_PAD&C_S_AXI_MEM2_HIGHADDR;
       axi_ard_addr_range_array_v(6) := ZERO_ADDR_PAD&C_S_AXI_MEM3_BASEADDR;
       axi_ard_addr_range_array_v(7) := ZERO_ADDR_PAD&C_S_AXI_MEM3_HIGHADDR;
    end if;
    return axi_ard_addr_range_array_v;
end function get_AXI_ARD_ADDR_RANGE_ARRAY;

constant AXI_ARD_ADDR_RANGE_ARRAY : SLV64_ARRAY_TYPE
                                  := get_AXI_ARD_ADDR_RANGE_ARRAY;
-----------------------------------------------------------------------------
-- Function: get_axi_ard_num_ce_array
-- Purpose:  Fill AXI_NUM_CE_ARRAY based on input parameters
-----------------------------------------------------------------------------
function get_axi_ard_num_ce_array return INTEGER_ARRAY_TYPE is
variable axi_ard_num_ce_array_v : INTEGER_ARRAY_TYPE(0 to C_NUM_BANKS_MEM-1);
begin
    if (C_NUM_BANKS_MEM = 1) then
        axi_ard_num_ce_array_v(0) := 1;      -- memories have only 1 CE
    elsif (C_NUM_BANKS_MEM = 2) then
        axi_ard_num_ce_array_v(0) := 1;
        axi_ard_num_ce_array_v(1) := 1;
    elsif (C_NUM_BANKS_MEM = 3) then
        axi_ard_num_ce_array_v(0) := 1;
        axi_ard_num_ce_array_v(1) := 1;
        axi_ard_num_ce_array_v(2) := 1;
    else
        axi_ard_num_ce_array_v(0) := 1;
        axi_ard_num_ce_array_v(1) := 1;
        axi_ard_num_ce_array_v(2) := 1;
        axi_ard_num_ce_array_v(3) := 1;
    end if;
    return axi_ard_num_ce_array_v;
end function get_axi_ard_num_ce_array;

-------------------------------------------------------------------------------
-- constant declaration
-----------------------
constant AXI_ARD_NUM_CE_ARRAY             : INTEGER_ARRAY_TYPE
                                          := get_axi_ard_num_ce_array;

-- axi full read/write interconnect related parameters
constant C_S_AXI_MEM_SUPPORTS_WRITE       : integer := 1;
constant C_S_AXI_MEM_SUPPORTS_READ        : integer := 1;

-------------------------------------------------------------------------------
-- Signal and Type Declarations
-------------------------------------------------------------------------------
--IPIC request qualifier signals
signal ip2bus_rdack         : std_logic;
signal ip2bus_wrack         : std_logic;
signal ip2bus_addrack       : std_logic;
signal ip2bus_errack        : std_logic;
-- IPIC address, data signals
signal ip2bus_data          : std_logic_vector(0 to (C_S_AXI_MEM_DATA_WIDTH-1));
signal bus2ip_addr          : std_logic_vector(0 to (C_S_AXI_MEM_ADDR_WIDTH-1));
signal bus2ip_addr_temp     : std_logic_vector(0 to (C_S_AXI_MEM_ADDR_WIDTH-1));
-- lower two bits address to generate the byte level address
signal bus2ip_addr_reg      : std_logic_vector(0 to 2);

-- Bus2IP_* Signals
signal bus2ip_data          : std_logic_vector(0 to (C_S_AXI_MEM_DATA_WIDTH-1));
-- below little endian signals are for data & BE swapping
signal temp_bus2ip_data     : std_logic_vector((C_S_AXI_MEM_DATA_WIDTH-1) downto 0);
signal temp_ip2bus_data     : std_logic_vector((C_S_AXI_MEM_DATA_WIDTH-1) downto 0);
signal temp_bus2ip_be       : std_logic_vector(((C_S_AXI_MEM_DATA_WIDTH/8)-1) downto 0);
--
signal bus2ip_rnw           : std_logic;
signal bus2ip_rdreq_i       : std_logic;
signal bus2ip_wrreq_i       : std_logic;
--
signal bus2ip_cs_i          : std_logic;
----
signal bus2ip_cs            : std_logic_vector
                              (0 to ((AXI_ARD_ADDR_RANGE_ARRAY'LENGTH)/2)-1);
-- big endian bus2ip_cs is used for EMC to maintain its big-endian structure
----
signal temp_bus2ip_cs       : std_logic_vector
                              (((AXI_ARD_ADDR_RANGE_ARRAY'LENGTH)/2)-1 downto 0);
----
signal bus2ip_rdce          : std_logic_vector
                              (0 to calc_num_ce(AXI_ARD_NUM_CE_ARRAY)-1);
signal bus2ip_wrce          : std_logic_vector
                              (0 to calc_num_ce(AXI_ARD_NUM_CE_ARRAY)-1);
--
signal bus2ip_be            : std_logic_vector(0 to (C_S_AXI_MEM_DATA_WIDTH/8)-1);
signal bus2ip_burst         : std_logic;
-- External memory signals
signal mem_dq_o_i           : std_logic_vector(0 to (C_MAX_MEM_WIDTH-1));
signal mem_dq_i_i           : std_logic_vector(0 to (C_MAX_MEM_WIDTH-1));
signal mem_dq_t_i           : std_logic_vector(0 to (C_MAX_MEM_WIDTH-1));

signal mem_dq_parity_o_i    : std_logic_vector(0 to (C_MAX_MEM_WIDTH/8-1));
signal mem_dq_parity_t_i    : std_logic_vector(0 to (C_MAX_MEM_WIDTH/8-1));
signal mem_dq_parity_i_i    : std_logic_vector(0 to (C_MAX_MEM_WIDTH/8-1));
--
signal parity_error_adrss   : std_logic_vector(0 to (C_S_AXI_MEM_ADDR_WIDTH-1));
signal parity_error_MEM     : std_logic_vector(1 downto 0);
signal err_parity_bits      : std_logic_vector(2 downto 0);
--
signal mem_cen_i            : std_logic_vector(0 to (C_NUM_BANKS_MEM-1));
signal mem_oen_i            : std_logic_vector(0 to (C_NUM_BANKS_MEM-1));
signal mem_wen_i            : std_logic;
signal mem_qwen_i           : std_logic_vector(0 to (C_MAX_MEM_WIDTH/8-1));
signal mem_ben_i            : std_logic_vector(0 to (C_MAX_MEM_WIDTH/8-1));
signal mem_adv_ldn_i        : std_logic;
signal mem_cken_i           : std_logic;
signal mem_ce_i             : std_logic_vector(0 to (C_NUM_BANKS_MEM-1));

signal mem_a_i              : std_logic_vector(0 to (C_S_AXI_MEM_ADDR_WIDTH-1));
signal bus2ip_burstlength   : std_logic_vector(0 to 7);

signal Type_of_xfer         : std_logic;
signal psram_page_mode      : std_logic;
signal bus2ip_reset         : std_logic;
signal temp_single_0        : std_logic;
signal temp_single_1        : std_logic;
signal temp_single_2        : std_logic;

signal or_reduced_rdce_d1 : std_logic;
signal or_reduced_wrce    : std_logic;
signal bus2ip_wrreq_reg   : std_logic;
signal original_wrce      : std_logic;

signal Bus2IP_RdReq_emc : std_logic;
signal Bus2IP_WrReq_emc : std_logic;
signal synch_mem, last_addr1 : std_logic;
signal axi_trans_size_reg_int : std_logic_vector(1 downto 0); -- 1/3/2013
    signal   axi_lite_ip2bus_wrack_d1: std_logic;
signal axi_arsize : std_logic_vector(2 downto 0) := (OTHERS => '0');
--*

--**
-------------------------------------------------------------------------------
-- not_all_psram: checks if any of the memory is of PSRAM type. PSRAM is assigned
----------------  with value 4, so check if MEM_TYPE = 4 and return 0 or 1.
function not_all_psram(input_array          : MEM_TYPE_ARRAY_TYPE;
                       num_real_elements    : integer)
                       return integer is
    variable sum : integer range 0 to 4 := 0;
    begin
        for i in 0 to num_real_elements -1 loop
           if input_array(i) = 4 then
             sum := sum + 1;
           end if;
        end loop;

        if sum = 0 then
            return 0;
        else
            return 1;
        end if;
end function not_all_psram;
-------------------------------------------------------------------------------
-- not_all_parity : check if any of the memory is assigned with PARITY bit
------------------ if any of the memory is assigned with parity, return 1.
function not_all_parity(input_array        : MEM_PARITY_ARRAY_TYPE;
                       num_real_elements   : integer)
                       return integer is
    variable sum : integer range 0 to 4 := 0;
    begin
        for i in 0 to num_real_elements -1 loop
           if input_array(i) /= 0 then
             sum := sum + 1;
           end if;
        end loop;

        if sum = 0 then
            return 0;
        else
            return 1;
        end if;
end function not_all_parity;
-------------------------------------------------------------------------------
-- sync_get_val: Check if the memory is SYNC memory type, if yes return 1.
---------------
function sync_get_val(x: integer; y: integer) return integer is
begin
    if x = 0   then
      return 1;
    else
      return 0;
     end if;
end function sync_get_val;
-------------------------------------------------------------------------------
-- page_get_val: If Page Mode Flash or PSRAM, then return 1.
---------------
function page_get_val(x: integer) return integer is
begin
    if x = 3 or x = 4 then
      return 1;
    else
      return 0;
     end if;
end function page_get_val;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- psram_or_lflash_sync: If PSRAM or Linear Flash  sync burst, then return 1.
---------------
function psram_or_lflash_sync(x: integer; y: integer) return integer is
begin
    if ((x = 1) or (y = 1)) then
      return 1;
    else
      return 0;
     end if;
end function psram_or_lflash_sync;
-------------------------------------------------------------------------------




constant MEM_TYPE_ARRAY : MEM_TYPE_ARRAY_TYPE :=
        (
            C_MEM0_TYPE,
            C_MEM1_TYPE,
            C_MEM2_TYPE,
            C_MEM3_TYPE
        );



constant MEM_PARITY_ARRAY : MEM_PARITY_ARRAY_TYPE :=
        (
            C_PARITY_TYPE_MEM_0,
            C_PARITY_TYPE_MEM_1,
            C_PARITY_TYPE_MEM_2,
            C_PARITY_TYPE_MEM_3
        );


constant GLOBAL_PSRAM_MEM    : integer range 0 to 1
                             := not_all_psram(MEM_TYPE_ARRAY,
                                              C_NUM_BANKS_MEM);

constant GLOBAL_PSRAM_FLASH_MEM : integer range 0 to 1
                                := psram_or_lflash_sync(C_LINEAR_FLASH_SYNC_BURST,
                                                        GLOBAL_PSRAM_MEM);


constant GLOBAL_PARITY_MEM   : integer range 0 to 1
                             := not_all_parity(MEM_PARITY_ARRAY,
                                               C_NUM_BANKS_MEM);
-- if SYNC memories are configured, then below parameter will be = 1
constant C_SYNCH_MEM_0          : integer :=sync_get_val(C_MEM0_TYPE, C_LINEAR_FLASH_SYNC_BURST);
constant C_SYNCH_MEM_1          : integer :=sync_get_val(C_MEM1_TYPE, C_LINEAR_FLASH_SYNC_BURST);
constant C_SYNCH_MEM_2          : integer :=sync_get_val(C_MEM2_TYPE, C_LINEAR_FLASH_SYNC_BURST);
constant C_SYNCH_MEM_3          : integer :=sync_get_val(C_MEM3_TYPE, C_LINEAR_FLASH_SYNC_BURST);
-- if Page Mode or PSRAM memories are configured,then below parameter will be= 1
constant C_PAGEMODE_FLASH_0     : integer :=page_get_val(C_MEM0_TYPE);
constant C_PAGEMODE_FLASH_1     : integer :=page_get_val(C_MEM1_TYPE);
constant C_PAGEMODE_FLASH_2     : integer :=page_get_val(C_MEM2_TYPE);
constant C_PAGEMODE_FLASH_3     : integer :=page_get_val(C_MEM3_TYPE);
--signal Mem_CRE_i : std_logic;
-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
   signal bus2ip_ce_lite_cmb    : std_logic_vector(7 downto 0);
   signal sync_mode             : std_logic_vector(C_NUM_BANKS_MEM-1 downto 0):= (others => '0');
   signal Cre_reg_en            : std_logic_vector(C_NUM_BANKS_MEM-1 downto 0):= (others => '0');-- := '0';
   signal Cre_reg_en_reduced    : std_logic:= '0';
   signal CTRL_REG : std_logic_vector((C_S_AXI_REG_DATA_WIDTH-1)
                                                       downto 0);
   signal Linear_flash_brst_rd_flag : std_logic := '0';
   signal Linear_flash_rd_data_ack: std_logic := '0';
   signal mem_a_io     : std_logic_vector(31 downto 0);
   signal mem_wait_io  : std_logic_vector(C_NUM_BANKS_MEM -1 downto 0);
   signal Mem_WAIT_reg : std_logic := '0';
   signal Mem_WAIT_reg_d1,
          Mem_WAIT_reg_d2,
          Mem_WAIT_reg_one_hot  : std_logic := '0';


   signal CTRL_REG_DATA: std_logic_vector(15 downto 0);
   signal CTRL_REG_ADDR: std_logic_vector((C_S_AXI_MEM_ADDR_WIDTH-1) downto 0) := (others => '0');
   signal sync_burst_data_ack : std_logic;
   signal sync_data_select : std_logic;

   constant FREQ_FACT_INT : integer range 0 to 15
                 := (C_LFLASH_PERIOD_PS/C_AXI_CLK_PERIOD_PS);
    constant FLASH_FREQ_FACTOR : std_logic_vector(3 downto 0)
                  := conv_std_logic_vector(FREQ_FACT_INT - 1, 4);

signal test_rd : std_logic;
signal ADDR_PROGRAM : std_logic_vector((C_S_AXI_MEM_ADDR_WIDTH-1)  downto 0);
signal ADDR_PROGRAM_D : std_logic_vector((C_S_AXI_MEM_ADDR_WIDTH-1)  downto 0);
signal ADDR_SYNCH_BURST_RD : std_logic_vector((C_S_AXI_MEM_ADDR_WIDTH-1)  downto 0);
signal ADDR_SYNCH_BURST_RD_D : std_logic_vector((C_S_AXI_MEM_ADDR_WIDTH-1)  downto 0);
signal Addr_select : std_logic :=  '0';
signal S_AXI_MEM_BVALID1 : std_logic;
signal S_AXI_MEM_WREADY1 : std_logic;
signal S_AXI_MEM_ARREADY1 : std_logic;

signal temp_strb : std_logic_vector(((C_S_AXI_MEM_DATA_WIDTH/8)-1) downto 0) := (others => '1');
signal temp_prog_cmd_data : std_logic_vector(15 downto 0) := X"0040";

signal Mem_WAIT_temp0 : std_logic := '0';
        signal Mem_WAIT_temp1 : std_logic := '0';
        signal Mem_WAIT_temp2 : std_logic := '0';
        signal Mem_WAIT_temp3 : std_logic := '0';
signal Mem_WAIT_cmb_delay: std_logic := '0';
signal Parity_err_i : std_logic;
signal s_axi_reg_bvalid_i : std_logic;
signal s_axi_reg_awready_i : std_logic;
signal pr_idle, axi_sm_ns_IDLE : std_logic; -- 11-12-2012
signal mem_cre_int : std_logic;
signal mem_a_int   : std_logic_vector(0 to (C_S_AXI_MEM_ADDR_WIDTH-1));

attribute IOB                 : string;
attribute IOB of Mem_WAIT_io  : signal is "true";
attribute IOB of Mem_cre_int  : signal is "true";
attribute IOB of Mem_a_int    : signal is "true";
-----
begin -- architecture IMP
-----

s_axi_mem_bvalid <= S_AXI_MEM_BVALID1;
s_axi_mem_wready <= S_AXI_MEM_WREADY1;
s_axi_mem_arready <= S_AXI_MEM_ARREADY1;
-- EMC memory read/write access times assignments
   -- CMD_ADDR_LOGIC_LFLASH : if (C_LINEAR_FLASH_SYNC_BURST = 1) generate
   --   Mem_A       <= mem_a_i    when  Cre_reg_en = '0' else  CTRL_REG_ADDR   ;
   -- end generate CMD_ADDR_LOGIC_LFLASH;
   -- ADDR_LOGIC_NO_LFLASH : if (C_LINEAR_FLASH_SYNC_BURST = 0) generate
        mem_a_io      <= ADDR_PROGRAM   when Addr_select = '1' else
                        ADDR_SYNCH_BURST_RD when Linear_flash_brst_rd_flag = '1' else mem_a_i ;
   -- end generate ADDR_LOGIC_NO_LFLASH;

    mem_wen     <= mem_wen_i    ;
    mem_adv_ldn <= mem_adv_ldn_i;
    mem_cken    <= mem_cken_i   ;
    err_parity_bits <= parity_error_MEM & Parity_err_i;
    --axi_arsize <= S_AXI_MEM_ARSIZE when (S_AXI_MEM_ARVALID = '1' and S_AXI_MEM_ARREADY1 = '1') else axi_arsize;

    mem_a <= mem_a_int;
    mem_cre <= mem_cre_int;
INPUT_MEM_A_REG_PROCESS: process(RdClk)
begin
  if RdClk'event and RdClk = '1' then
    mem_a_int <= mem_a_io;
  end if;
end process INPUT_MEM_A_REG_PROCESS;

INPUT_MEM_WAIT_REG_PROCESS: process(RdClk)
begin
  if RdClk'event and RdClk = '1' then
    Mem_WAIT_io(C_NUM_BANKS_MEM -1 downto 0) <= Mem_WAIT(C_NUM_BANKS_MEM -1 downto 0);
  end if;
end process INPUT_MEM_WAIT_REG_PROCESS;

process (s_axi_aclk) begin
  if s_axi_aclk'event and s_axi_aclk = '1' then
    if S_AXI_MEM_ARVALID = '1' and S_AXI_MEM_ARREADY1 = '1' then
        axi_arsize <= S_AXI_MEM_ARSIZE;
    else
        axi_arsize <= axi_arsize;
    end if;
  end if;
end process;

    ---------------------------------------------------------------------------
     -- AXI EMC is little endian and EMC COMMON is still big endian, to make
     -- this interface work normally, we need to swap the Write and read data
     -- bytes comming from and going to external memory interface
    ---------------------------------------------------------------------------

    ENDIAN_CEN_BANKS_1 : if (C_NUM_BANKS_MEM = 1) generate
        mem_cen(0)     <= mem_cen_i(0);
        mem_ce(0)      <= mem_ce_i(0);
    end generate ENDIAN_CEN_BANKS_1;

    ENDIAN_CEN_BANKS_2 : if (C_NUM_BANKS_MEM = 2) generate
        mem_cen(0)     <= mem_cen_i(0);
        mem_cen(1)     <= mem_cen_i(1);

        mem_ce(0)      <= mem_ce_i(0);
        mem_ce(1)      <= mem_ce_i(1);
    end generate ENDIAN_CEN_BANKS_2;

    ENDIAN_CEN_BANKS_3 : if (C_NUM_BANKS_MEM = 3) generate
        mem_cen(0)     <= mem_cen_i(0);
        mem_cen(1)     <= mem_cen_i(1);
        mem_cen(2)     <= mem_cen_i(2);

        mem_ce(0)      <= mem_ce_i(0);
        mem_ce(1)      <= mem_ce_i(1);
        mem_ce(2)      <= mem_ce_i(2);
    end generate ENDIAN_CEN_BANKS_3;

    ENDIAN_CEN_BANKS_4 : if (C_NUM_BANKS_MEM = 4) generate
        mem_cen(0)     <= mem_cen_i(0);
        mem_cen(1)     <= mem_cen_i(1);
        mem_cen(2)     <= mem_cen_i(2);
        mem_cen(3)     <= mem_cen_i(3);

        mem_ce(0)      <= mem_ce_i(0);
        mem_ce(1)      <= mem_ce_i(1);
        mem_ce(2)      <= mem_ce_i(2);
        mem_ce(3)      <= mem_ce_i(3);
    end generate ENDIAN_CEN_BANKS_4;

    -- assign OutPut Enable signals (Read Enable Signals)
    ENDIAN_OEN_BANKS_1 : if (C_NUM_BANKS_MEM = 1) generate
        mem_oen(0)     <= mem_oen_i(0);
    end generate ENDIAN_OEN_BANKS_1;

    ENDIAN_OEN_BANKS_2 : if (C_NUM_BANKS_MEM = 2) generate
        mem_oen(0)     <= mem_oen_i(0);
        mem_oen(1)     <= mem_oen_i(1);
    end generate ENDIAN_OEN_BANKS_2;

    ENDIAN_OEN_BANKS_3 : if (C_NUM_BANKS_MEM = 3) generate
        mem_oen(0)     <= mem_oen_i(0);
        mem_oen(1)     <= mem_oen_i(1);
        mem_oen(2)     <= mem_oen_i(2);
    end generate ENDIAN_OEN_BANKS_3;

    ENDIAN_OEN_BANKS_4 : if (C_NUM_BANKS_MEM = 4) generate
        mem_oen(0)     <= mem_oen_i(0);
        mem_oen(1)     <= mem_oen_i(1);
        mem_oen(2)     <= mem_oen_i(2);
        mem_oen(3)     <= mem_oen_i(3);
    end generate ENDIAN_OEN_BANKS_4;

    -- data byte swapping for 8 bit memory
    ENDIAN_MEM_CONVERSION_8 : if (C_MAX_MEM_WIDTH = 8) generate
        -- output from memory core
        mem_dq_o(7 downto 0)  <= mem_dq_o_i (0 to 7);
        mem_dq_t(7 downto 0)  <= mem_dq_t_i (0 to 7);
        -- input to memory core
        mem_dq_i_i (0 to 7)   <= Mem_DQ_I (7 downto 0);

        mem_qwen              <= mem_qwen_i;
        mem_ben               <= mem_ben_i;

        -- o/p from memory
        mem_dq_parity_o       <= mem_dq_parity_o_i;
        mem_dq_parity_t       <= mem_dq_parity_t_i;
        -- i/p to memory
        mem_dq_parity_i_i     <= MEM_DQ_PARITY_I;

    end generate ENDIAN_MEM_CONVERSION_8;

    -- data byte swapping for 16 bit memory
    -- ENDIAN_MEM_CONVERSION_16: byte -by -byte swapping for 16 bit memory
    ---------------------------
    ENDIAN_MEM_CONVERSION_16 : if (C_MAX_MEM_WIDTH = 16) generate
        -- o/p to memory
        mem_dq_o(7 downto 0)  <= mem_dq_o_i (0 to 7);
        mem_dq_o(15 downto 8) <= mem_dq_o_i (8 to 15);

        mem_dq_t(7 downto 0)  <= mem_dq_t_i (0 to 7);
        mem_dq_t(15 downto 8) <= mem_dq_t_i (8 to 15);
        -- i/p from memory
        mem_dq_i_i (0 to 7)   <= Mem_DQ_I (7 downto 0);
        mem_dq_i_i (8 to 15)  <= Mem_DQ_I (15 downto 8);

        -- qualified write enabls
        mem_qwen(0)           <= mem_qwen_i(0);
        mem_qwen(1)           <= mem_qwen_i(1);
        -- byte enabls
        mem_ben(0)            <= mem_ben_i(0);
        mem_ben(1)            <= mem_ben_i(1);
        -- parity bits to memory
        mem_dq_parity_o(0)    <= mem_dq_parity_o_i(0);
        mem_dq_parity_o(1)    <= mem_dq_parity_o_i(1);

        mem_dq_parity_t(0)    <= mem_dq_parity_t_i(0);
        mem_dq_parity_t(1)    <= mem_dq_parity_t_i(1);
        -- parity bits from memory
        mem_dq_parity_i_i(0)  <= MEM_DQ_PARITY_I(0);
        mem_dq_parity_i_i(1)  <= MEM_DQ_PARITY_I(1);

     end generate ENDIAN_MEM_CONVERSION_16;

   -- data byte swapping for 32 bit memory
   -- ENDIAN_MEM_CONVERSION_32: byte -by -byte swapping for 32 bit memory
    ENDIAN_MEM_CONVERSION_32 : if (C_MAX_MEM_WIDTH = 32) generate
        -- o/p to memory
        mem_dq_o(7 downto 0)   <= mem_dq_o_i (0 to 7);
        mem_dq_o(15 downto 8)  <= mem_dq_o_i (8 to 15);
        mem_dq_o(23 downto 16) <= mem_dq_o_i (16 to 23);
        mem_dq_o(31 downto 24) <= mem_dq_o_i (24 to 31);

        mem_dq_t(7 downto 0)   <= mem_dq_t_i (0 to 7);
        mem_dq_t(15 downto 8)  <= mem_dq_t_i (8 to 15);
        mem_dq_t(23 downto 16) <= mem_dq_t_i (16 to 23);
        mem_dq_t(31 downto 24) <= mem_dq_t_i (24 to 31);
        -- i/p from memory
        mem_dq_i_i (0 to 7)    <= Mem_DQ_I (7 downto 0);
        mem_dq_i_i (8 to 15)   <= Mem_DQ_I (15 downto 8);
        mem_dq_i_i (16 to 23)  <= Mem_DQ_I (23 downto 16);
        mem_dq_i_i (24 to 31)  <= Mem_DQ_I (31 downto 24);
        -- qualified write enabls
        mem_qwen(0)    <= mem_qwen_i(0);
        mem_qwen(1)    <= mem_qwen_i(1);
        mem_qwen(2)    <= mem_qwen_i(2);
        mem_qwen(3)    <= mem_qwen_i(3);
        -- byte enabls
        mem_ben(0)    <= mem_ben_i(0);
        mem_ben(1)    <= mem_ben_i(1);
        mem_ben(2)    <= mem_ben_i(2);
        mem_ben(3)    <= mem_ben_i(3);
        -- parity bits to memory
        mem_dq_parity_o(0) <= mem_dq_parity_o_i(0);
        mem_dq_parity_o(1) <= mem_dq_parity_o_i(1);
        mem_dq_parity_o(2) <= mem_dq_parity_o_i(2);
        mem_dq_parity_o(3) <= mem_dq_parity_o_i(3);

        mem_dq_parity_t(0) <= mem_dq_parity_t_i(0);
        mem_dq_parity_t(1) <= mem_dq_parity_t_i(1);
        mem_dq_parity_t(2) <= mem_dq_parity_t_i(2);
        mem_dq_parity_t(3) <= mem_dq_parity_t_i(3);
        -- parity bits from memory
        mem_dq_parity_i_i(0) <= mem_dq_parity_i(0);
        mem_dq_parity_i_i(1) <= mem_dq_parity_i(1);
        mem_dq_parity_i_i(2) <= mem_dq_parity_i(2);
        mem_dq_parity_i_i(3) <= mem_dq_parity_i(3);

     end generate ENDIAN_MEM_CONVERSION_32;

   -- data byte swapping for 64 bit memory
   -- ENDIAN_MEM_CONVERSION_64: byte -by -byte swapping for 64 bit memory
    ENDIAN_MEM_CONVERSION_64 : if (C_MAX_MEM_WIDTH = 64) generate
        -- o/p to memory
        mem_dq_o(7 downto 0)   <= mem_dq_o_i (0 to 7);
        mem_dq_o(15 downto 8)  <= mem_dq_o_i (8 to 15);
        mem_dq_o(23 downto 16) <= mem_dq_o_i (16 to 23);
        mem_dq_o(31 downto 24) <= mem_dq_o_i (24 to 31);
        mem_dq_o(39 downto 32) <= mem_dq_o_i (32 to 39);
        mem_dq_o(47 downto 40) <= mem_dq_o_i (40 to 47);
        mem_dq_o(55 downto 48) <= mem_dq_o_i (48 to 55);
        mem_dq_o(63 downto 56) <= mem_dq_o_i (56 to 63);

        mem_dq_t(7 downto 0)   <= mem_dq_t_i (0 to 7);
        mem_dq_t(15 downto 8)  <= mem_dq_t_i (8 to 15);
        mem_dq_t(23 downto 16) <= mem_dq_t_i (16 to 23);
        mem_dq_t(31 downto 24) <= mem_dq_t_i (24 to 31);
        mem_dq_t(39 downto 32) <= mem_dq_t_i (32 to 39);
        mem_dq_t(47 downto 40) <= mem_dq_t_i (40 to 47);
        mem_dq_t(55 downto 48) <= mem_dq_t_i (48 to 55);
        mem_dq_t(63 downto 56) <= mem_dq_t_i (56 to 63);
        -- o/p from memory
        mem_dq_i_i (0 to 7)    <= mem_dq_i (7 downto 0);
        mem_dq_i_i (8 to 15)   <= mem_dq_i (15 downto 8);
        mem_dq_i_i (16 to 23)  <= mem_dq_i (23 downto 16);
        mem_dq_i_i (24 to 31)  <= mem_dq_i (31 downto 24);
        mem_dq_i_i (32 to 39)  <= mem_dq_i (39 downto 32);
        mem_dq_i_i (40 to 47)  <= mem_dq_i (47 downto 40);
        mem_dq_i_i (48 to 55)  <= mem_dq_i (55 downto 48);
        mem_dq_i_i (56 to 63)  <= mem_dq_i (63 downto 56);

        -- qualified write enabls
        mem_qwen(0)    <= mem_qwen_i(0);
        mem_qwen(1)    <= mem_qwen_i(1);
        mem_qwen(2)    <= mem_qwen_i(2);
        mem_qwen(3)    <= mem_qwen_i(3);
        mem_qwen(4)    <= mem_qwen_i(4);
        mem_qwen(5)    <= mem_qwen_i(5);
        mem_qwen(6)    <= mem_qwen_i(6);
        mem_qwen(7)    <= mem_qwen_i(7);
        -- byte enabls
        mem_ben(0)    <= mem_ben_i(0);
        mem_ben(1)    <= mem_ben_i(1);
        mem_ben(2)    <= mem_ben_i(2);
        mem_ben(3)    <= mem_ben_i(3);
        mem_ben(4)    <= mem_ben_i(4);
        mem_ben(5)    <= mem_ben_i(5);
        mem_ben(6)    <= mem_ben_i(6);
        mem_ben(7)    <= mem_ben_i(7);
        -- parity bits to memory
        mem_dq_parity_o(0) <= mem_dq_parity_o_i(0);
        mem_dq_parity_o(1) <= mem_dq_parity_o_i(1);
        mem_dq_parity_o(2) <= mem_dq_parity_o_i(2);
        mem_dq_parity_o(3) <= mem_dq_parity_o_i(3);
        mem_dq_parity_o(4) <= mem_dq_parity_o_i(4);
        mem_dq_parity_o(5) <= mem_dq_parity_o_i(5);
        mem_dq_parity_o(6) <= mem_dq_parity_o_i(6);
        mem_dq_parity_o(7) <= mem_dq_parity_o_i(7);

        mem_dq_parity_t(0) <= mem_dq_parity_t_i(0);
        mem_dq_parity_t(1) <= mem_dq_parity_t_i(1);
        mem_dq_parity_t(2) <= mem_dq_parity_t_i(2);
        mem_dq_parity_t(3) <= mem_dq_parity_t_i(3);
        mem_dq_parity_t(4) <= mem_dq_parity_t_i(4);
        mem_dq_parity_t(5) <= mem_dq_parity_t_i(5);
        mem_dq_parity_t(6) <= mem_dq_parity_t_i(6);
        mem_dq_parity_t(7) <= mem_dq_parity_t_i(7);

        -- parity bits from memory
        mem_dq_parity_i_i(0) <= mem_dq_parity_i(0);
        mem_dq_parity_i_i(1) <= mem_dq_parity_i(1);
        mem_dq_parity_i_i(2) <= mem_dq_parity_i(2);
        mem_dq_parity_i_i(3) <= mem_dq_parity_i(3);
        mem_dq_parity_i_i(4) <= mem_dq_parity_i(4);
        mem_dq_parity_i_i(5) <= mem_dq_parity_i(5);
        mem_dq_parity_i_i(6) <= mem_dq_parity_i(6);
        mem_dq_parity_i_i(7) <= mem_dq_parity_i(7);

   end generate ENDIAN_MEM_CONVERSION_64;

-------------------------------------------------------------------------------
-- NO_REG_EN_GEN: the below instantion is to make the output signals for
--                register interface driving '0'.
--------------
NO_REG_EN_GEN : if (C_S_AXI_EN_REG = 0) generate
-------------
begin
        -------------------------------------
        s_axi_reg_awready <= '0';
        s_axi_reg_wready  <= '0';
        s_axi_reg_bresp   <= (others => '0');
        s_axi_reg_bvalid  <= '0';
        s_axi_reg_arready <= '0';
        s_axi_reg_rdata   <= (others => '0');
        s_axi_reg_rresp   <= (others => '0');
        s_axi_reg_rvalid  <= '0';

-- PSRAM_CONFIG_REG_DIS: if (GLOBAL_PSRAM_FLASH_MEM = 0) generate
        psram_page_mode   <= '0';-- Default value is psram in async mode
-- end generate PSRAM_CONFIG_REG_DIS;
        -------------------------------------
end generate NO_REG_EN_GEN;
-------------------------------------------------------------------------------
-- EMC REGISTER  MODULE Instantiations
-------------------------------------------------------------------------------
-- REG_EN_GEN: Include the AXI Lite IPIF and register module
--------------
REG_EN_GEN : if (C_S_AXI_EN_REG = 1) generate
-------------

-- IPIC Used Sgnals
   constant RST_ACTIVE  : std_logic := '0';

   type MEM_PARITY_REG_ARRAY_TYPE is array(3 downto 0) of
                        std_logic_vector((C_S_AXI_REG_DATA_WIDTH -1) downto 0);

   type MEM_PSRAM_REG_ARRAY_TYPE is array(3 downto 0) of
                        std_logic_vector((C_S_AXI_REG_DATA_WIDTH -1) downto 0);

   signal PEAR_REG : MEM_PARITY_REG_ARRAY_TYPE;-- 4 parity regs of each 32 bit
   signal PCR_REG  : MEM_PSRAM_REG_ARRAY_TYPE ; -- 4 psram regs of each 32 bit


   signal axi_lite_ip2bus_data_i    : std_logic_vector((C_S_AXI_REG_DATA_WIDTH-1)
                                                       downto 0);

   signal axi_lite_ip2bus_data1    : std_logic_vector((C_S_AXI_REG_DATA_WIDTH-1)
                                                       downto 0);
   signal axi_lite_ip2bus_data2    : std_logic_vector((C_S_AXI_REG_DATA_WIDTH-1)
                                                       downto 0);
   signal bus2ip_addr_lite_reg     : std_logic_vector(4 downto 2);--((3+GLOBAL_PSRAM_FLASH_MEM)
                                                                  -- downto 2);

   signal arready_i : std_logic;
   signal awready_i : std_logic;
   signal rvalid    : std_logic;

   signal axi_lite_ip2bus_wrack_i : std_logic;
   signal axi_lite_ip2bus_rdack_i : std_logic;
   signal axi_lite_ip2bus_rdack1  : std_logic;
   signal axi_lite_ip2bus_rdack2  : std_logic;

   signal axi_lite_ip2bus_wrack1  : std_logic;
   signal axi_lite_ip2bus_wrack2  : std_logic;

   signal read_reg_req  : std_logic;
   signal write_reg_req : std_logic;

   signal bus2ip_rdce_lite_cmb  : std_logic_vector(7 downto 0);-- (((C_NUM_BANKS_MEM-1)+(4*GLOBAL_PSRAM_FLASH_MEM)) downto 0);
   signal bus2ip_wrce_lite_cmb  : std_logic_vector(7 downto 0);-- (((C_NUM_BANKS_MEM-1)+(4*GLOBAL_PSRAM_FLASH_MEM)) downto 0);
   signal s_axi_reg_rresp_reg: std_logic_vector(1 downto 0);
   signal s_axi_reg_bresp_reg: std_logic_vector(1 downto 0);
   signal s_axi_reg_bvalid_i : std_logic;
   ------------------------
-----
begin
-------------------------------------------------------------------------------

-- *
-------------------------------------------------------------------------------
PSRAM_FLASH_PARITY_CE_LOCAL_REG_GEN : if (GLOBAL_PSRAM_FLASH_MEM = 1)generate
-------------------------------
--signal bus2ip_ce_lite_cmb    : std_logic_vector(7 downto 0);
-----
begin-- *
-----
--* to generate the WRCE and RDCE for register access.
      PSRAM_PARITY_NUM_BANKS_4_GEN: if (C_NUM_BANKS_MEM=4) generate
      begin
        
        BUS2IP_CE_GEN_P: process(
                                 bus2ip_addr_lite_reg(4 downto 2)
                                 )is
        --------
        variable bus2ip_addr_reg_4_2 : std_logic_vector(2 downto 0);
        --------
        begin
        --
        bus2ip_addr_reg_4_2 := bus2ip_addr_lite_reg;
        --
                case bus2ip_addr_reg_4_2 is
                        when "000" => bus2ip_ce_lite_cmb <= "00000001";
                        when "001" => bus2ip_ce_lite_cmb <= "00000010";
                        when "010" => bus2ip_ce_lite_cmb <= "00000100";
                        when "011" => bus2ip_ce_lite_cmb <= "00001000";
                        when "100" => bus2ip_ce_lite_cmb <= "00010000";
                        when "101" => bus2ip_ce_lite_cmb <= "00100000";
                        when "110" => bus2ip_ce_lite_cmb <= "01000000";
                        when "111" => bus2ip_ce_lite_cmb <= "10000000";
                        -- coverage off
                        when others => bus2ip_ce_lite_cmb <= (others=> '0');
                        -- coverage on
                end case;
        end process BUS2IP_CE_GEN_P;
        --------------------------------------
        RDCE_GEN: for i in 7 downto 0 generate
        -----
        begin
        -----
            bus2ip_rdce_lite_cmb(i) <= read_reg_req and bus2ip_ce_lite_cmb(i);
        end generate RDCE_GEN;
        --------------------------------------
        WRCE_GEN: for i in 7 downto 0 generate
        -----
        begin
        -----
            bus2ip_wrce_lite_cmb(i) <= s_axi_reg_wvalid and
                                       write_reg_req    and
                                       bus2ip_ce_lite_cmb(i);
        end generate WRCE_GEN;
        ----------------------------------------
      end generate PSRAM_PARITY_NUM_BANKS_4_GEN;
      ------------------------------------------

      PSRAM_PARITY_NUM_BANKS_3_GEN: if (C_NUM_BANKS_MEM=3) generate
      begin
      BUS2IP_CE_GEN_P: process(
                               bus2ip_addr_lite_reg(4 downto 2)
                               )is
        --------
        variable bus2ip_addr_reg_4_2 : std_logic_vector(2 downto 0);
        --------
        begin
        --
        bus2ip_addr_reg_4_2 := bus2ip_addr_lite_reg;
        --
                case bus2ip_addr_reg_4_2 is
                        -- when "000" => bus2ip_ce_lite_cmb <= "00000001";
                        -- when "001" => bus2ip_ce_lite_cmb <= "00000010";
                        -- when "010" => bus2ip_ce_lite_cmb <= "00000100";
                        -- when "011" => bus2ip_ce_lite_cmb <= "00001000"; -- this will complete the transaction without any updates
                        -- -- psram configuration registers
                        -- when "100" => bus2ip_ce_lite_cmb <= "00010000";
                        -- when "101" => bus2ip_ce_lite_cmb <= "00100000";
                        -- when "110" => bus2ip_ce_lite_cmb <= "01000000";
                       -- -- coverage off
                       -- when others => bus2ip_ce_lite_cmb <= (others=> '0');
                       -- -- coverage on
                          when "000" => bus2ip_ce_lite_cmb <= "00000001";-- bank 0 present if SRAM is chosen
                          when "001" => bus2ip_ce_lite_cmb <= "00000010";-- bank 1 present if SRAM is chosen
                          when "010" => bus2ip_ce_lite_cmb <= "00000100";-- bank 2 present if SRAM is chosen
                          when "011" => bus2ip_ce_lite_cmb <= "00001000";-- REGISTER HOLE - provide only ack
                          when "100" => bus2ip_ce_lite_cmb <= "00010000";-- bank 0 present if PSRAM/Flash is chosen
                          when "101" => bus2ip_ce_lite_cmb <= "00100000";-- bank 1 present if PSRAM/Flash is chosen
                          when "110" => bus2ip_ce_lite_cmb <= "01000000";-- bank 2 present if PSRAM/Flash is chosen
                          when "111" => bus2ip_ce_lite_cmb <= "10000000";-- REGISTER HOLE - provide only ack                   
                          -- coverage off
                          when others => bus2ip_ce_lite_cmb <= (others=> '0');
                          -- coverage on
                end case;
        --    end if;
        -- end if;
        end process BUS2IP_CE_GEN_P;
        --------------------------------------
        RDCE_GEN: for i in 7 downto 0  generate -- (((C_NUM_BANKS_MEM-1)+(4*GLOBAL_PSRAM_FLASH_MEM))) downto 0 generate
        -----
        begin
        -----
            bus2ip_rdce_lite_cmb(i) <= read_reg_req and bus2ip_ce_lite_cmb(i);
        end generate RDCE_GEN;
        --------------------------------------
        WRCE_GEN: for i in 7 downto 0  generate -- (((C_NUM_BANKS_MEM-1)+(4*GLOBAL_PSRAM_FLASH_MEM))) downto 0 generate
        -----
        begin
        -----
            bus2ip_wrce_lite_cmb(i) <= s_axi_reg_wvalid and
                                       write_reg_req    and
                                       bus2ip_ce_lite_cmb(i);
        end generate WRCE_GEN;
        ----------------------------------------
      end generate PSRAM_PARITY_NUM_BANKS_3_GEN;
      ------------------------------------------


      PSRAM_PARITY_NUM_BANKS_2_GEN: if (C_NUM_BANKS_MEM=2) generate
      begin
      BUS2IP_CE_GEN_P: process(
                                 bus2ip_addr_lite_reg(4 downto 2)
                               )is
        --------
        variable bus2ip_addr_reg_4_2 : std_logic_vector(2 downto 0);
        --------
        begin
        --
        bus2ip_addr_reg_4_2 := bus2ip_addr_lite_reg;
        --
                case bus2ip_addr_reg_4_2 is
                        --when "000" => bus2ip_ce_lite_cmb <= "00000001";
                        --when "001" => bus2ip_ce_lite_cmb <= "00000010";
                        --when "010" => bus2ip_ce_lite_cmb <= "00000100"; -- this will complete the transaction without any updates
                        --when "011" => bus2ip_ce_lite_cmb <= "00001000"; -- this will complete the transaction without any updates
                        ---- psram configuration registers
                        --when "100" => bus2ip_ce_lite_cmb <= "00010000";
                        --when "101" => bus2ip_ce_lite_cmb <= "00100000";
                        --when "110" => bus2ip_ce_lite_cmb <= "01000000"; -- this will complete the transaction without any updates
                        --when "111" => bus2ip_ce_lite_cmb <= "10000000"; -- this will complete the transaction without any updates
                        ---- coverage off
                        --when others => bus2ip_ce_lite_cmb <= (others=> '0');
                        ---- coverage on
                        when "000" => bus2ip_ce_lite_cmb <= "00000001";-- bank 0 present if SRAM is chosen
                        when "001" => bus2ip_ce_lite_cmb <= "00000010";-- bank 1 present if SRAM is chosen
                        when "010" => bus2ip_ce_lite_cmb <= "00000100";-- REGISTER HOLE - provide only ack
                        when "011" => bus2ip_ce_lite_cmb <= "00001000";-- REGISTER HOLE - provide only ack
                        when "100" => bus2ip_ce_lite_cmb <= "00010000";-- bank 0 present if PSRAM/Flash is chosen
                        when "101" => bus2ip_ce_lite_cmb <= "00100000";-- bank 1 present if PSRAM/Flash is chosen
                        when "110" => bus2ip_ce_lite_cmb <= "01000000";-- REGISTER HOLE - provide only ack 
                        when "111" => bus2ip_ce_lite_cmb <= "10000000";-- REGISTER HOLE - provide only ack                   
                        -- coverage off
                        when others => bus2ip_ce_lite_cmb <= (others=> '0');
                        -- coverage on
                end case;
        end process BUS2IP_CE_GEN_P;
        --------------------------------------
        --------------------------------------
        RDCE_GEN: for i in 7 downto 0 generate -- (((C_NUM_BANKS_MEM-1)+(4*GLOBAL_PSRAM_FLASH_MEM))) downto 0 generate
        -----
        begin
        -----
            bus2ip_rdce_lite_cmb(i) <= read_reg_req and bus2ip_ce_lite_cmb(i);
        end generate RDCE_GEN;
        --------------------------------------
        WRCE_GEN: for i in 7 downto 0 generate -- (((C_NUM_BANKS_MEM-1)+(4*GLOBAL_PSRAM_FLASH_MEM))) downto 0 generate
        -----
        begin
        -----
            bus2ip_wrce_lite_cmb(i) <= s_axi_reg_wvalid and
                                       write_reg_req    and
                                       bus2ip_ce_lite_cmb(i);
        end generate WRCE_GEN;
        ----------------------------------------
        end generate PSRAM_PARITY_NUM_BANKS_2_GEN;

      PSRAM_PARITY_NUM_BANKS_1_GEN: if (C_NUM_BANKS_MEM=1) generate
      begin
      BUS2IP_CE_GEN_P: process--(s_axi_aclk) is
                                (
                                 bus2ip_addr_lite_reg(4 downto 2)
                                 )is
        --------
        variable bus2ip_addr_reg_4_2 : std_logic_vector(2 downto 0);
        --------
        begin
        --
        bus2ip_addr_reg_4_2 := bus2ip_addr_lite_reg;
        --
                case bus2ip_addr_reg_4_2 is
                        --when "000" => bus2ip_ce_lite_cmb <= "00000001";
 			            --when "001" => bus2ip_ce_lite_cmb <= "00000010";-- this will complete the transaction without any updates
                        --when "010" => bus2ip_ce_lite_cmb <= "00000100";-- this will complete the transaction without any updates
                        --when "011" => bus2ip_ce_lite_cmb <= "00001000"; -- this will complete the transaction without any updates
                        -- psram configuration registers
                        --when "100" => bus2ip_ce_lite_cmb <= "00010000";
                        --when "101" => bus2ip_ce_lite_cmb <= "00100000"; -- this will complete the transaction without any updates
                        --when "110" => bus2ip_ce_lite_cmb <= "01000000"; -- this will complete the transaction without any updates
                        --when "111" => bus2ip_ce_lite_cmb <= "10000000"; -- this will complete the transaction without any updates
                        -- coverage off
                        --when others => bus2ip_ce_lite_cmb <= (others=> '0');
                        -- coverage on
                        when "000" => bus2ip_ce_lite_cmb <= "00000001";-- bank 0 present if SRAM is chosen
                        when "001" => bus2ip_ce_lite_cmb <= "00000010";-- REGISTER HOLE - provide only ack
                        when "010" => bus2ip_ce_lite_cmb <= "00000100";-- REGISTER HOLE - provide only ack
                        when "011" => bus2ip_ce_lite_cmb <= "00001000";-- REGISTER HOLE - provide only ack
                        when "100" => bus2ip_ce_lite_cmb <= "00010000";-- bank 0 present if PSRAM/Flash is chosen
                        when "101" => bus2ip_ce_lite_cmb <= "00100000";-- REGISTER HOLE - provide only ack 
                        when "110" => bus2ip_ce_lite_cmb <= "01000000";-- REGISTER HOLE - provide only ack 
                        when "111" => bus2ip_ce_lite_cmb <= "10000000";-- REGISTER HOLE - provide only ack                   
                        -- coverage off
                        when others => bus2ip_ce_lite_cmb <= (others=> '0');
                        -- coverage on
                end case;
        end process BUS2IP_CE_GEN_P;
        --------------------------------------
        --------------------------------------
        RDCE_GEN: for i in 7 downto 0 generate -- (((C_NUM_BANKS_MEM-1)+(4*GLOBAL_PSRAM_FLASH_MEM))) downto 0 generate
        -----
        begin
        -----
            bus2ip_rdce_lite_cmb(i) <= read_reg_req and bus2ip_ce_lite_cmb(i);
        end generate RDCE_GEN;
        --------------------------------------
        WRCE_GEN: for i in 7 downto 0 generate -- (((C_NUM_BANKS_MEM-1)+(4*GLOBAL_PSRAM_FLASH_MEM))) downto 0 generate
        -----
        begin
        -----
            bus2ip_wrce_lite_cmb(i) <= s_axi_reg_wvalid and
                                       write_reg_req    and
                                       bus2ip_ce_lite_cmb(i);
        end generate WRCE_GEN;
        ----------------------------------------
      end generate PSRAM_PARITY_NUM_BANKS_1_GEN;

end generate PSRAM_FLASH_PARITY_CE_LOCAL_REG_GEN;
-------------------------------------------------------------------------------


NO_LFLASH_PSRAM_CE_LOCAL_REG_GEN: if (GLOBAL_PSRAM_FLASH_MEM = 0)generate

-----
begin-- *

-----
--* to generate the WRCE and RDCE for register access.
    NUM_BANKS_4_GEN: if (C_NUM_BANKS_MEM=4) generate
    --signal bus2ip_ce_lite_cmb : std_logic_vector((C_NUM_BANKS_MEM-1) downto 0);--9/14/2013
    -----
    begin
    -----
        BUS2IP_CE_GEN_P: process
                                (
                                 bus2ip_addr_lite_reg(4 downto 2) -- (3 downto 2)
                                 ) is
        --------
        --variable bus2ip_addr_reg_3_2 : std_logic_vector(1 downto 0);
        --------
        begin
        --
                case bus2ip_addr_lite_reg(4 downto 2) is -- (3 downto 2) is
                        --when "00" => bus2ip_ce_lite_cmb <= "0001";
                        --when "01" => bus2ip_ce_lite_cmb <= "0010";
                        --when "10" => bus2ip_ce_lite_cmb <= "0100";
                        --when "11" => bus2ip_ce_lite_cmb <= "1000";
                        ---- coverage off
                        --when others => bus2ip_ce_lite_cmb <= "0001";--(others => '0');
                        ---- coverage on
                         when "000" => bus2ip_ce_lite_cmb <= "00000001";-- bank 0 present if SRAM is chosen, else hole
                        when "001" => bus2ip_ce_lite_cmb <= "00000010";-- bank 1 present if SRAM is chosen, else hole
                        when "010" => bus2ip_ce_lite_cmb <= "00000100";-- bank 2 present if SRAM is chosen, else hole
                        when "011" => bus2ip_ce_lite_cmb <= "00001000";-- bank 3 present if SRAM is chosen, else hole
                        when "100" => bus2ip_ce_lite_cmb <= "00010000";-- bank 0 present if PSRAM/Flash is chosen, else hole
                        when "101" => bus2ip_ce_lite_cmb <= "00100000";-- bank 1 present if PSRAM/Flash is chosen, else hole 
                        when "110" => bus2ip_ce_lite_cmb <= "01000000";-- bank 2 present if PSRAM/Flash is chosen, else hole 
                        when "111" => bus2ip_ce_lite_cmb <= "10000000";-- bank 3 present if PSRAM/Flash is chosen, else hole                   
                        -- coverage off
                        when others => bus2ip_ce_lite_cmb <= (others=> '0');
                        -- coverage on
               end case;
        end process BUS2IP_CE_GEN_P;

        --------------------------------------
        RDCE_GEN: for i in 7 downto 0 generate -- C_NUM_BANKS_MEM-1 downto 0 generate
        -----
        begin
        -----
            bus2ip_rdce_lite_cmb(i) <= read_reg_req and
                                       bus2ip_ce_lite_cmb(i);
        end generate RDCE_GEN;
        --------------------------------------
        WRCE_GEN: for i in 7 downto 0 generate --C_NUM_BANKS_MEM-1 downto 0 generate
        -----
        begin
        -----
            bus2ip_wrce_lite_cmb(i) <= s_axi_reg_wvalid and
                                       write_reg_req    and
                                       bus2ip_ce_lite_cmb(i);
        end generate WRCE_GEN;
        --------------------------------------

    end generate NUM_BANKS_4_GEN;
    ------------------------------------------

    NUM_BANKS_3_GEN: if (C_NUM_BANKS_MEM=3) generate
    --signal bus2ip_ce_lite_cmb : std_logic_vector((C_NUM_BANKS_MEM-1) downto 0);
    -----
    begin
    -----
        BUS2IP_CE_GEN_P: process(
                                 bus2ip_addr_lite_reg(4 downto 2)-- (3 downto 2)
                                 ) is
        --------
        begin
        --
                case bus2ip_addr_lite_reg(4 downto 2) is
                        --when "00" => bus2ip_ce_lite_cmb <= "001";
                        --when "01" => bus2ip_ce_lite_cmb <= "010";
                        --when "10" => bus2ip_ce_lite_cmb <= "100";
                        --when "11" => bus2ip_ce_lite_cmb <= "001"; -- this will complete the transaction without any updates
                        ---- coverage off
                        --when others => bus2ip_ce_lite_cmb <=  "001";--(others=>'0');
                        ---- coverage on
                        when "000" => bus2ip_ce_lite_cmb <= "00000001";-- bank 0 present if SRAM is chosen, else hole
                        when "001" => bus2ip_ce_lite_cmb <= "00000010";-- bank 1 present if SRAM is chosen, else hole
                        when "010" => bus2ip_ce_lite_cmb <= "00000100";-- bank 2 present if SRAM is chosen, else hole
                        when "011" => bus2ip_ce_lite_cmb <= "00001000";-- hole, provide ack in any case
                        when "100" => bus2ip_ce_lite_cmb <= "00010000";-- bank 0 present if PSRAM/Flash is chosen, else hole
                        when "101" => bus2ip_ce_lite_cmb <= "00100000";-- bank 1 present if PSRAM/Flash is chosen, else hole 
                        when "110" => bus2ip_ce_lite_cmb <= "01000000";-- bank 2 present if PSRAM/Flash is chosen, else hole 
                        when "111" => bus2ip_ce_lite_cmb <= "10000000";-- hole, provide ack in any case                   
                        -- coverage off
                        when others => bus2ip_ce_lite_cmb <= (others=> '0');
                        -- coverage on
                end case;
        end process BUS2IP_CE_GEN_P;
        --------------------------------------
        RDCE_GEN: for i in 7 downto 0 generate -- C_NUM_BANKS_MEM-1 downto 0 generate
        -----
        begin
        -----
            bus2ip_rdce_lite_cmb(i) <= read_reg_req and
                                       bus2ip_ce_lite_cmb(i);
        end generate RDCE_GEN;
        --------------------------------------
        WRCE_GEN: for i in 7 downto 0 generate -- C_NUM_BANKS_MEM-1 downto 0 generate
        -----
        begin
        -----
            bus2ip_wrce_lite_cmb(i) <= s_axi_reg_wvalid and
                                       write_reg_req    and
                                       bus2ip_ce_lite_cmb(i);
        end generate WRCE_GEN;
        --------------------------------------

    end generate NUM_BANKS_3_GEN;
    ------------------------------------------

    NUM_BANKS_2_GEN: if (C_NUM_BANKS_MEM=2) generate
    --signal bus2ip_ce_lite_cmb : std_logic_vector((C_NUM_BANKS_MEM-1) downto 0);
    -----
    begin
    -----
        BUS2IP_CE_GEN_P: process(
                                 bus2ip_addr_lite_reg(4 downto 2)-- (3 downto 2)
                                 ) is
        --------
        begin
        --
                case bus2ip_addr_lite_reg(4 downto 2) is -- (3 downto 2) is
                        --when "00" => bus2ip_ce_lite_cmb <= "01";
                        --when "01" => bus2ip_ce_lite_cmb <= "10";
                        --when "10" => bus2ip_ce_lite_cmb <= "01"; -- this will complete the transaction without any updates
                        --when "11" => bus2ip_ce_lite_cmb <= "01"; -- this will complete the transaction without any updates
                        ---- coverage off
                        --when others => bus2ip_ce_lite_cmb <=  "01";-- (others=>'0');
                        ---- coverage on
                        when "000" => bus2ip_ce_lite_cmb <= "00000001";-- bank 0 present if SRAM is chosen, else hole
                        when "001" => bus2ip_ce_lite_cmb <= "00000010";-- bank 1 present if SRAM is chosen, else hole
                        when "010" => bus2ip_ce_lite_cmb <= "00000100";-- hole, provide ack in any case
                        when "011" => bus2ip_ce_lite_cmb <= "00001000";-- hole, provide ack in any case
                        when "100" => bus2ip_ce_lite_cmb <= "00010000";-- bank 0 present if PSRAM/Flash is chosen, else hole
                        when "101" => bus2ip_ce_lite_cmb <= "00100000";-- bank 1 present if PSRAM/Flash is chosen, else hole 
                        when "110" => bus2ip_ce_lite_cmb <= "01000000";-- hole, provide ack in any case 
                        when "111" => bus2ip_ce_lite_cmb <= "10000000";-- hole, provide ack in any case                   
                        -- coverage off
                        when others => bus2ip_ce_lite_cmb <= (others=> '0');
                        -- coverage on
                end case;
        end process BUS2IP_CE_GEN_P;
        --------------------------------------
        RDCE_GEN: for i in 7 downto 0 generate -- C_NUM_BANKS_MEM-1 downto 0 generate
        -----
        begin
        -----
            bus2ip_rdce_lite_cmb(i) <= read_reg_req and
                                       bus2ip_ce_lite_cmb(i);
        end generate RDCE_GEN;
        --------------------------------------
        WRCE_GEN: for i in 7 downto 0 generate -- C_NUM_BANKS_MEM-1 downto 0 generate
        -----
        begin
        -----
            bus2ip_wrce_lite_cmb(i) <= s_axi_reg_wvalid and
                                       write_reg_req    and
                                       bus2ip_ce_lite_cmb(i);
        end generate WRCE_GEN;
        --------------------------------------

    end generate NUM_BANKS_2_GEN;
    ------------------------------------------

    NUM_BANKS_1_GEN: if (C_NUM_BANKS_MEM=1) generate
    --signal bus2ip_ce_lite_cmb : std_logic;
    -----
    begin
    -----
        BUS2IP_CE_GEN_P: process(
                                 bus2ip_addr_lite_reg(4 downto 2) -- (3 downto 2)
                                 ) is
        --------
        begin
        --
                case bus2ip_addr_lite_reg(4 downto 2) is -- (3 downto 2) is
                        --when "00" => bus2ip_ce_lite_cmb <= '1';
                        --when "01" => bus2ip_ce_lite_cmb <= '1'; -- this will complete the transaction without any updates
                        --when "10" => bus2ip_ce_lite_cmb <= '1'; -- this will complete the transaction without any updates
                        --when "11" => bus2ip_ce_lite_cmb <= '1'; -- this will complete the transaction without any updates
                        ---- coverage off
                        --when others => bus2ip_ce_lite_cmb <= '1';-- '0';
                        ---- coverage on
                        when "000" => bus2ip_ce_lite_cmb <= "00000001";-- bank 0 present if SRAM is chosen, else hole
                        when "001" => bus2ip_ce_lite_cmb <= "00000010";-- hole, provide ack in any case
                        when "010" => bus2ip_ce_lite_cmb <= "00000100";-- hole, provide ack in any case
                        when "011" => bus2ip_ce_lite_cmb <= "00001000";-- hole, provide ack in any case
                        when "100" => bus2ip_ce_lite_cmb <= "00010000";-- bank 0 present if PSRAM/Flash is chosen, else hole
                        when "101" => bus2ip_ce_lite_cmb <= "00100000";-- hole, provide ack in any case 
                        when "110" => bus2ip_ce_lite_cmb <= "01000000";-- hole, provide ack in any case 
                        when "111" => bus2ip_ce_lite_cmb <= "10000000";-- hole, provide ack in any case                   
                        -- coverage off
                        when others => bus2ip_ce_lite_cmb <= (others=> '0');
                        -- coverage on
                end case;
        end process BUS2IP_CE_GEN_P;
        --------------------------------------
        RDCE_GEN: for i in 7 downto 0 generate -- C_NUM_BANKS_MEM-1 downto 0 generate
        -----
        begin
        -----
            bus2ip_rdce_lite_cmb(i) <= read_reg_req and
                                       bus2ip_ce_lite_cmb(i);
        end generate RDCE_GEN;
        --------------------------------------
        WRCE_GEN: for i in 7 downto 0 generate -- C_NUM_BANKS_MEM-1 downto 0 generate
        -----
        begin
        -----
            bus2ip_wrce_lite_cmb(i) <= s_axi_reg_wvalid and
                                       write_reg_req    and
                                       bus2ip_ce_lite_cmb(i);
        end generate WRCE_GEN;
        --------------------------------------

    end generate NUM_BANKS_1_GEN;
    --------------------------------------

end generate NO_LFLASH_PSRAM_CE_LOCAL_REG_GEN;
--*
 s_axi_reg_awready <= axi_lite_ip2bus_wrack_i; -- awready_i;
 s_axi_reg_wready  <= axi_lite_ip2bus_wrack_i; -- write_reg_req;
 s_axi_reg_bresp   <= s_axi_reg_bresp_reg;

 s_axi_reg_arready <= arready_i;
 s_axi_reg_rvalid  <= rvalid;
 s_axi_reg_rresp   <= s_axi_reg_rresp_reg;

 -- AWREADY is enabled only if valid write request and no read request
 awready_i <= (not write_reg_req) and
               not ( s_axi_reg_arvalid or read_reg_req or rvalid ) and
               s_axi_aresetn;

 -- ARREADY is enabled only if valid read request and no current write request
 arready_i <= not(rvalid or read_reg_req) and
              not (write_reg_req)
              and s_axi_aresetn;

--       WRITE_AWREADY_P: process (s_axi_aclk) is
--       begin
--           if (s_axi_aclk'event and s_axi_aclk = '1') then
--               if (s_axi_aresetn=RST_ACTIVE) then
--                   s_axi_reg_awready_i  <= '0';
--               --elsif (s_axi_reg_awvalid = '0') and (axi_lite_ip2bus_wrack_i = '1') then
--               --    s_axi_reg_awready_i  <= '1';
--               elsif (s_axi_reg_awvalid = '1') and (s_axi_reg_awready_i = '1') then
--                   s_axi_reg_awready_i  <= '0';
--               else
--                   s_axi_reg_awready_i  <= axi_lite_ip2bus_wrack_i;
--               end if;
--           end if;
--       end process WRITE_AWREADY_P;
-- ---------------------------------------------------------------------------------
-- s_axi_reg_awready <= s_axi_reg_awready_i;

-------------------------------------------------------------------------------
-- Process READ_REQUEST_P to generate read request
-------------------------------------------------------------------------------
      READ_REQUEST_P: process (s_axi_aclk) is
      begin
          if (s_axi_aclk'event and s_axi_aclk = '1') then
              if (s_axi_aresetn=RST_ACTIVE) then
                  read_reg_req <= '0';
              elsif (s_axi_reg_arvalid = '1' and arready_i = '1') then
                  read_reg_req <= '1';
              elsif (axi_lite_ip2bus_rdack_i = '1') then
                  read_reg_req <= '0';
              end if;
          end if;
      end process READ_REQUEST_P;
-------------------------------------------------------------------------------
-- Process WRITE_REQUEST_P to generate Write request on the IPIC
-------------------------------------------------------------------------------
      WRITE_REQUEST_P: process (s_axi_aclk) is
      begin
          if (s_axi_aclk'event and s_axi_aclk = '1') then
              if (s_axi_aresetn=RST_ACTIVE) then
                  write_reg_req <= '0';
              elsif (s_axi_reg_awvalid = '1' and awready_i = '1') then
                  write_reg_req <= '1';
              elsif (axi_lite_ip2bus_wrack_i = '1') then
                  write_reg_req <= '0';
              end if;
          end if;
      end process WRITE_REQUEST_P;
-------------------------------------------------------------------------------
-- Process ADDR_GEN_P to generate bus2ip_addr for read/write
-------------------------------------------------------------------------------
   PSRAM_PARITY_ADDR_REG_GEN : if (GLOBAL_PSRAM_FLASH_MEM = 1) generate
   ------------------------
   -----
   begin-- *
   -----
      ADDR_GEN_P: process (s_axi_aclk) is
      begin
          if (s_axi_aclk'event and s_axi_aclk = '1') then
              if (s_axi_aresetn=RST_ACTIVE) then
                  bus2ip_addr_lite_reg(4 downto 2) <= (others=>'0');
              elsif (s_axi_reg_arvalid = '1' and arready_i = '1') then
                  bus2ip_addr_lite_reg(4 downto 2) <= s_axi_reg_araddr(4 downto 2);
              elsif (s_axi_reg_awvalid = '1' and awready_i = '1') then
                  bus2ip_addr_lite_reg(4 downto 2) <= s_axi_reg_awaddr(4 downto 2);
              end if;
          end if;
      end process ADDR_GEN_P;

   end generate PSRAM_PARITY_ADDR_REG_GEN;
   ---------------------------------------
   NO_PSRAM_PARITY_ADDR_REG_GEN : if (GLOBAL_PSRAM_FLASH_MEM = 0) generate
   ------------------------
   -----
   begin-- *
   -----
      ADDR_GEN_P: process (s_axi_aclk) is
      begin
          if (s_axi_aclk'event and s_axi_aclk = '1') then
              if (s_axi_aresetn=RST_ACTIVE) then
                  bus2ip_addr_lite_reg(4 downto 2) <= (others=>'0');
              elsif (s_axi_reg_arvalid = '1' and arready_i = '1') then
                  bus2ip_addr_lite_reg(4 downto 2) <= s_axi_reg_araddr(4 downto 2);
              elsif (s_axi_reg_awvalid = '1' and awready_i = '1') then
                  bus2ip_addr_lite_reg(4 downto 2) <= s_axi_reg_awaddr(4 downto 2);
              end if;
          end if;
      end process ADDR_GEN_P;

   end generate NO_PSRAM_PARITY_ADDR_REG_GEN;
   ---------------------------------------
  --  -----------------------------------------------------------------------
  --  Process AXI_READ_OUTPUT_P to generate Write request on the IPIC
  --  -----------------------------------------------------------------------
      AXI_READ_OUTPUT_P: process (s_axi_aclk) is
      begin
          if (s_axi_aclk'event and s_axi_aclk = '1') then
              if (s_axi_aresetn=RST_ACTIVE) then
                  s_axi_reg_rdata  <= (others =>'0');
              elsif (axi_lite_ip2bus_rdack_i = '1') then
                  s_axi_reg_rdata  <= axi_lite_ip2bus_data_i;
              elsif(rvalid='0')then
                  s_axi_reg_rdata  <= (others =>'0');
              end if;
          end if;
      end process AXI_READ_OUTPUT_P;

  --  -----------------------------------------------------------------------
  --  Process READ_RVALID_P to generate Read valid
  --  -----------------------------------------------------------------------
      READ_RVALID_P: process (s_axi_aclk) is
      begin
          if (s_axi_aclk'event and s_axi_aclk = '1') then

              s_axi_reg_rresp_reg <= "00";

              if (s_axi_aresetn=RST_ACTIVE) then
                  rvalid <= '0';
              elsif (axi_lite_ip2bus_rdack_i = '1') then
                  rvalid <= '1';
              elsif (s_axi_reg_rready='1') then
                  rvalid <= '0';
              end if;
          end if;
      end process READ_RVALID_P;
--  -----------------------------------------------------------------------
  --  Process WRITE_BVALID_P to generate Write valid
  --  -----------------------------------------------------------------------
      WRITE_BVALID_P: process (s_axi_aclk) is
      begin
          if (s_axi_aclk'event and s_axi_aclk = '1') then
                 s_axi_reg_bresp_reg   <= "00";
              if (s_axi_aresetn=RST_ACTIVE) then
                  s_axi_reg_bvalid_i  <= '0';
              --elsif (axi_lite_ip2bus_wrack_i = '1') then
              --    s_axi_reg_bvalid  <= '1';
              --elsif (s_axi_reg_bready='1') then
              --    s_axi_reg_bvalid  <= '0';
              --elsif(s_axi_reg_bready='1')then
              --else
                  --s_axi_reg_bvalid  <= axi_lite_ip2bus_wrack_i;
              elsif ((axi_lite_ip2bus_wrack_i and (not axi_lite_ip2bus_wrack_d1)) = '1') then    
                  s_axi_reg_bvalid_i  <= '1';
              elsif (s_axi_reg_bready = '0') and (s_axi_reg_bvalid_i = '1') then
                  s_axi_reg_bvalid_i  <= '1';
              elsif (s_axi_reg_bready = '1') and (s_axi_reg_bvalid_i = '1') then
                  s_axi_reg_bvalid_i  <= '0';
              end if;
          end if;
      end process WRITE_BVALID_P;
      
      LOCK_BVALID_P: process (s_axi_aclk) is
      begin
          if (s_axi_aclk'event and s_axi_aclk = '1') then
              if (s_axi_aresetn=RST_ACTIVE) then
                  axi_lite_ip2bus_wrack_d1  <= '0';
              else   -- if (axi_lite_ip2bus_wrack_i = '1') then
                  axi_lite_ip2bus_wrack_d1  <= axi_lite_ip2bus_wrack_i;
              end if;
          end if;
      end process LOCK_BVALID_P;
      
      
      
      
      
      
      
      
---------------------------------------------------------------------------------
s_axi_reg_bvalid <= s_axi_reg_bvalid_i;
 -----------------------------------------------------------------------------
                axi_lite_ip2bus_data_i  <= axi_lite_ip2bus_data1  or
                                           axi_lite_ip2bus_data2;

                axi_lite_ip2bus_rdack_i <= axi_lite_ip2bus_rdack1 or
                                           axi_lite_ip2bus_rdack2;

                axi_lite_ip2bus_wrack_i <= axi_lite_ip2bus_wrack1 or
                                           axi_lite_ip2bus_wrack2;

-----------------------------------------------------------------------------
-- PEAR_X_RD, Byte Parity Register Read Process
-----------------------------------------------------------------------------
-- Generation of Transfer Ack signal for one clock pulse
-----------------------------------------------------------------------------

NO_PARITY_ENABLED_REG_GEN : if (MEM_PARITY_ARRAY(0) = 0 and -- if all mentioned meories are not having
                                MEM_PARITY_ARRAY(1) = 0 and -- parity included, then there wont be any
                                MEM_PARITY_ARRAY(2) = 0 and -- local registers
                                MEM_PARITY_ARRAY(3) = 0) generate
-----
begin
------
             axi_lite_ip2bus_data1        <= (others => '0');
             axi_lite_ip2bus_rdack1       <= '0';
             axi_lite_ip2bus_wrack1       <= '0';

end generate NO_PARITY_ENABLED_REG_GEN;
---------------------------------------

-- PEAR_X_RD : If any of the memories are having parity enabled then local register may be
--             needed. 1-odd parity, 2-even parity
--------------
PARITY_ENABLED_REG_GEN : if  ( MEM_PARITY_ARRAY(0) /= 0 or -- if any of the memories are of
                               MEM_PARITY_ARRAY(1) /= 0 or -- having parity enables, then there
                               MEM_PARITY_ARRAY(2) /= 0 or -- is need of local registers
                               MEM_PARITY_ARRAY(3) /= 0
                             ) generate
 -----
 begin
 -----
   -- PARITY_REG_DUMMY_WR_ACK_P : Parity registers are read only registers. write to these registers is not allowed or should come
   --                             out safely. Below logic generates ACK and write transactions are come out safely.
   PARITY_REG_DUMMY_WR_ACK_P :process(s_axi_aclk)is 
   begin
      if (s_axi_aclk'EVENT and s_axi_aclk = '1') then
        if (s_axi_aresetn = '0') then
                axi_lite_ip2bus_wrack1 <= '0';
        else--if(or_reduce(bus2ip_wrce_lite_cmb) = '1') then
                axi_lite_ip2bus_wrack1 <= or_reduce(bus2ip_wrce_lite_cmb); -- '1';
        end if;
      end if;
   end process PARITY_REG_DUMMY_WR_ACK_P;
   ----------------------------------------------------------------------------
   ------------------------------------------------------
   PERR_NUM_MEM_4_GEN: if C_NUM_BANKS_MEM = 4 generate
   ------------------
   begin
   -----

      FOUR_BANKS_PARITY_REG_RD_P : process (bus2ip_rdce_lite_cmb,
                                            PEAR_REG(0),
                                            PEAR_REG(1),
                                            PEAR_REG(2),
                                            PEAR_REG(3)
                                            ) is
      variable internal_bus2ip_rdack : std_logic_vector(7 downto 0); -- 9/14/2013
           --(((C_NUM_BANKS_MEM-1)+(4*GLOBAL_PSRAM_MEM)) downto 0);--(3 downto 0);
      -----
      begin
      -----
           internal_bus2ip_rdack := bus2ip_rdce_lite_cmb;
            -- defaults
           axi_lite_ip2bus_data1     <= (others => '0');
           axi_lite_ip2bus_rdack1    <= or_reduce(bus2ip_rdce_lite_cmb);

            case internal_bus2ip_rdack(7 downto 0) is -- (3 downto 0) is
               --when "0001" => axi_lite_ip2bus_data1 <= PEAR_REG(0);
               --when "0010" => axi_lite_ip2bus_data1 <= PEAR_REG(1);
               --when "0100" => axi_lite_ip2bus_data1 <= PEAR_REG(2);
               --when "1000" => axi_lite_ip2bus_data1 <= PEAR_REG(3);
 	           
               when "00000001" => axi_lite_ip2bus_data1 <= PEAR_REG(0);
               when "00000010" => axi_lite_ip2bus_data1 <= PEAR_REG(1);
               when "00000100" => axi_lite_ip2bus_data1 <= PEAR_REG(2);
               when "00001000" => axi_lite_ip2bus_data1 <= PEAR_REG(3);
               -- hole returns data 0
               when "00010000" => axi_lite_ip2bus_data1 <= (others => '0');
               when "00100000" => axi_lite_ip2bus_data1 <= (others => '0');
               when "01000000" => axi_lite_ip2bus_data1 <= (others => '0');
               when "10000000" => axi_lite_ip2bus_data1 <= (others => '0');
               -- coverage off
               when others =>  axi_lite_ip2bus_data1 <= (others=> '0');
               -- coverage on
            end case;
      end process FOUR_BANKS_PARITY_REG_RD_P;
      ----------------------------------

      PARITY_ERR_REG_STORE_P: process (s_axi_aclk) is
      -----------------------
      --variable err_parity_bits : std_logic_vector(2 downto 0);
      -----
      begin
      -----

      --err_parity_bits := parity_error_MEM & Parity_err_i;

      --err_parity_bits := ip2bus_errack & parity_error_MEM;
      if (s_axi_aclk'EVENT and s_axi_aclk = '1') then
         if (s_axi_aresetn = '0') then
              for i in C_NUM_BANKS_MEM-1 downto 0 loop
                 PEAR_REG (i) <= (others => '0');
              end loop;
         else
            if (ip2bus_errack = '1') then
              case err_parity_bits is -- (parity_error_MEM & Parity_err_i) is
                when "001"     => PEAR_REG(0) <= parity_error_adrss;
                when "011"     => PEAR_REG(1) <= parity_error_adrss;
                when "101"     => PEAR_REG(2) <= parity_error_adrss;
                when "111"     => PEAR_REG(3) <= parity_error_adrss;
               -- coverage off
                when others   => NULL;
               -- coverage on
              end case;
            else
                PEAR_REG(0) <= PEAR_REG(0);
                PEAR_REG(1) <= PEAR_REG(1);
                PEAR_REG(2) <= PEAR_REG(2);
                PEAR_REG(3) <= PEAR_REG(3);
            end if;
          end if;
      end if;
      end process PARITY_ERR_REG_STORE_P;
   end generate PERR_NUM_MEM_4_GEN;
   ------------------------------------------------------

   ------------------------------------------------------
   PERR_NUM_MEM_3_GEN: if C_NUM_BANKS_MEM = 3 generate
   ------------------
   begin
   -----
      THREE_BANKS_PARITY_REG_RD_P : process (bus2ip_rdce_lite_cmb,
                                             PEAR_REG(0),
                                             PEAR_REG(1),
                                             PEAR_REG(2)
                                             ) is
      variable internal_bus2ip_rdack : std_logic_vector(7 downto 0);--9/14/2013
           --(((C_NUM_BANKS_MEM-1)+(4*GLOBAL_PSRAM_MEM)) downto 0);--(3 downto 0);
      -----
      begin
      -----
            internal_bus2ip_rdack := bus2ip_rdce_lite_cmb;
            -- defaults
            axi_lite_ip2bus_rdack1    <= or_reduce(bus2ip_rdce_lite_cmb);
            -- axi_lite_ip2bus_data1     <= (others => '0');
            
            case internal_bus2ip_rdack(7 downto 0) is -- (2 downto 0) is
               --when "001" => axi_lite_ip2bus_data1 <= PEAR_REG(0);
               --when "010" => axi_lite_ip2bus_data1 <= PEAR_REG(1);
               --when "100" => axi_lite_ip2bus_data1 <= PEAR_REG(2);
               ---- coverage off
               --when others =>  null;
               ---- coverage on
	       when "00000001" => axi_lite_ip2bus_data1 <= PEAR_REG(0);
               when "00000010" => axi_lite_ip2bus_data1 <= PEAR_REG(1);
               when "00000100" => axi_lite_ip2bus_data1 <= PEAR_REG(2);
               -- hole returns data 0
               when "00010000" => axi_lite_ip2bus_data1 <= (others => '0');
               when "00100000" => axi_lite_ip2bus_data1 <= (others => '0');
               when "01000000" => axi_lite_ip2bus_data1 <= (others => '0');
               when "10000000" => axi_lite_ip2bus_data1 <= (others => '0');
               ---- coverage off
               when others => axi_lite_ip2bus_data1 <= (others => '0');
               ---- coverage on
            end case;
      end process THREE_BANKS_PARITY_REG_RD_P;
      ----------------------------------------

      PARITY_ERR_REG_STORE_P: process (s_axi_aclk) is
      -----------------------
      --variable err_parity_bits : std_logic_vector(2 downto 0);
      -----
      begin
      -----
      --err_parity_bits := parity_error_MEM & Parity_err_i;
      
      if (s_axi_aclk'EVENT and s_axi_aclk = '1') then
         if (s_axi_aresetn = '0') then
              for i in C_NUM_BANKS_MEM-1 downto 0 loop
                 PEAR_REG (i) <= (others => '0');
              end loop;
         else
            if (ip2bus_errack = '1') then
              case err_parity_bits is -- (parity_error_MEM & Parity_err_i ) is
                when "001"     => PEAR_REG(0) <= parity_error_adrss;
                when "011"     => PEAR_REG(1) <= parity_error_adrss;
                when "101"     => PEAR_REG(2) <= parity_error_adrss;
               -- coverage off
                when others   => null; -- axi_lite_ip2bus_data1 <= (others => '0');
               -- coverage on
              end case;
            else
                PEAR_REG(0) <= PEAR_REG(0);
                PEAR_REG(1) <= PEAR_REG(1);
                PEAR_REG(2) <= PEAR_REG(2);
            end if;
          end if;
      end if;
      end process PARITY_ERR_REG_STORE_P;
   end generate PERR_NUM_MEM_3_GEN;
   ------------------------------------------------------

   ------------------------------------------------------
   PERR_NUM_MEM_2_GEN: if C_NUM_BANKS_MEM = 2 generate
   ------------------
   begin
   -----
      TWO_BANKS_PARITY_REG_RD_P : process (bus2ip_rdce_lite_cmb,
                                           PEAR_REG(0),
                                           PEAR_REG(1)
                                           ) is
      variable internal_bus2ip_rdack : std_logic_vector(7 downto 0); -- 9/14/2013
           --(((C_NUM_BANKS_MEM-1)+(4*GLOBAL_PSRAM_MEM)) downto 0);--(3 downto 0);
      -----
      begin
      -----
            internal_bus2ip_rdack := bus2ip_rdce_lite_cmb;
            -- defaults
            axi_lite_ip2bus_data1 <= (others => '0');
            axi_lite_ip2bus_rdack1    <= or_reduce(bus2ip_rdce_lite_cmb);
            
            case internal_bus2ip_rdack(7 downto 0) is -- (1 downto 0) is
               --when "01" => axi_lite_ip2bus_data1 <= PEAR_REG(0);
               --when "10" => axi_lite_ip2bus_data1 <= PEAR_REG(1);
               ---- coverage off
               --when others => axi_lite_ip2bus_data1 <= (others => '0');
               ---- coverage on
	           when "00000001" => axi_lite_ip2bus_data1 <= PEAR_REG(0);
               when "00000010" => axi_lite_ip2bus_data1 <= PEAR_REG(1);
               -- hole returns data 0
               when "00000100" => axi_lite_ip2bus_data1 <= (others => '0');
               when "00001000" => axi_lite_ip2bus_data1 <= (others => '0');
               when "00010000" => axi_lite_ip2bus_data1 <= (others => '0');
               when "00100000" => axi_lite_ip2bus_data1 <= (others => '0');
               when "01000000" => axi_lite_ip2bus_data1 <= (others => '0');
               when "10000000" => axi_lite_ip2bus_data1 <= (others => '0');
               ---- coverage off
               when others => axi_lite_ip2bus_data1 <= (others => '0');
               ---- coverage on
            end case;
      end process TWO_BANKS_PARITY_REG_RD_P;
      ----------------------------------------

      PARITY_ERR_REG_STORE_P: process (s_axi_aclk) is
      -----------------------
      --variable err_parity_bits : std_logic_vector(2 downto 0);
      --variable err_parity_bits : std_logic_vector(2 downto 0);
      -----
      begin
      -----
      --err_parity_bits := parity_error_MEM & Parity_err_i;
      
      if (s_axi_aclk'EVENT and s_axi_aclk = '1') then
         if (s_axi_aresetn = '0') then
              for i in C_NUM_BANKS_MEM-1 downto 0 loop
                 PEAR_REG (i) <= (others => '0');
              end loop;
         else
            if (ip2bus_errack = '1') then
              case err_parity_bits is -- (parity_error_MEM & Parity_err_i) is
                when "001"     => PEAR_REG(0) <= parity_error_adrss;
                when "011"     => PEAR_REG(1) <= parity_error_adrss;
               -- coverage off
                when others   => NULL;
               -- coverage on
              end case;
            else
                PEAR_REG(0) <= PEAR_REG(0);
                PEAR_REG(1) <= PEAR_REG(1);
            end if;
          end if;
      end if;
      end process PARITY_ERR_REG_STORE_P;
   end generate PERR_NUM_MEM_2_GEN;
   ------------------------------------------------------

   ------------------------------------------------------
   PERR_NUM_MEM_1_GEN: if C_NUM_BANKS_MEM = 1 generate
   ------------------
      begin
      -----
      ONE_BANKS_PARITY_REG_RD_P : process (bus2ip_rdce_lite_cmb,
                                           PEAR_REG(0)
                                           ) is
      variable internal_bus2ip_rdack : std_logic_vector(7 downto 0);
      -----
      begin
      -----
            internal_bus2ip_rdack := bus2ip_rdce_lite_cmb;-- or_reduce(bus2ip_rdce_lite_cmb);
            -- defaults
            axi_lite_ip2bus_data1     <= (others => '0');
            axi_lite_ip2bus_rdack1    <= or_reduce(bus2ip_rdce_lite_cmb);
            
            case internal_bus2ip_rdack is
               --when '1' => axi_lite_ip2bus_data1 <= PEAR_REG(0);
               ---- coverage off
               --when others => axi_lite_ip2bus_data1 <= (others=> '0'); -- null;
               ---- coverage on
	       when "00000001" => axi_lite_ip2bus_data1 <= PEAR_REG(0);
               -- hole returns data 0
               when "00000010" => axi_lite_ip2bus_data1 <= (others => '0');
               when "00000100" => axi_lite_ip2bus_data1 <= (others => '0');
               when "00001000" => axi_lite_ip2bus_data1 <= (others => '0');
               when "00010000" => axi_lite_ip2bus_data1 <= (others => '0');
               when "00100000" => axi_lite_ip2bus_data1 <= (others => '0');
               when "01000000" => axi_lite_ip2bus_data1 <= (others => '0');
               when "10000000" => axi_lite_ip2bus_data1 <= (others => '0');
               ---- coverage off
               when others => axi_lite_ip2bus_data1 <= (others => '0');
               ---- coverage on
            end case;
      end process ONE_BANKS_PARITY_REG_RD_P;
      ----------------------------------------

      PARITY_ERR_REG_STORE_P: process (s_axi_aclk) is
      -----------------------
      --variable err_parity_bits : std_logic_vector(2 downto 0);
      -----
      begin
      -----
      --err_parity_bits := parity_error_MEM & Parity_err_i;

      if (s_axi_aclk'EVENT and s_axi_aclk = '1') then
         if (s_axi_aresetn = '0') then
              for i in C_NUM_BANKS_MEM-1 downto 0 loop
                 PEAR_REG (i) <= (others => '0');
              end loop;
         else
            if (ip2bus_errack = '1') then
              case err_parity_bits is -- (parity_error_MEM & Parity_err_i) is
                when "001"     => PEAR_REG(0) <= parity_error_adrss;
               -- coverage off
                when others   => NULL;
               -- coverage on
              end case;
            else
                PEAR_REG(0) <= PEAR_REG(0);
            end if;
          end if;
      end if;
      end process PARITY_ERR_REG_STORE_P;
   end generate PERR_NUM_MEM_1_GEN;
   ------------------------------------------------------

end generate PARITY_ENABLED_REG_GEN;
------------------------------------

  -----------------------------------------------------------------------------
  -- PCR_X_RD, Byte Parity Register Read Process
  -----------------------------------------------------------------------------




LINEAR_FLASH_CONFIG_REG_GEN: if (C_LINEAR_FLASH_SYNC_BURST = 1) generate
--------------------
begin
-----
PCR_FOUR_GEN: if C_NUM_BANKS_MEM = 4 generate
        LFLASH_CONFIG_REG_RD_PROCESS_4 : process (bus2ip_rdce_lite_cmb,
                                                 PCR_REG
                                               --MEM_TYPE_ARRAY
                                               ) is
        variable j : integer := 0;
        begin
        -- defaults
        axi_lite_ip2bus_data2   <= (others => '0');
        axi_lite_ip2bus_rdack2  <= or_reduce(bus2ip_rdce_lite_cmb);-- ( ( (C_NUM_BANKS_MEM-1)+(4*C_LINEAR_FLASH_SYNC_BURST)) downto 0));

           case bus2ip_rdce_lite_cmb is
             when "00000001" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00000010" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00000100" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00001000" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00010000" => axi_lite_ip2bus_data2 <= PCR_REG(0);
             when "00100000" => axi_lite_ip2bus_data2 <= PCR_REG(1);
             when "01000000" => axi_lite_ip2bus_data2 <= PCR_REG(2);
             when "10000000" => axi_lite_ip2bus_data2 <= PCR_REG(3);
             when others => axi_lite_ip2bus_data2 <= (others => '0');
           end case;
        end process LFLASH_CONFIG_REG_RD_PROCESS_4;
end generate PCR_FOUR_GEN;

PCR_THREE_GEN: if C_NUM_BANKS_MEM = 3 generate
        LFLASH_CONFIG_REG_RD_PROCESS_3 : process (bus2ip_rdce_lite_cmb,
                                                 PCR_REG
                                               --MEM_TYPE_ARRAY
                                               ) is
        variable j : integer := 0;
        begin
        -- defaults
        axi_lite_ip2bus_data2   <= (others => '0');
        axi_lite_ip2bus_rdack2  <= or_reduce(bus2ip_rdce_lite_cmb);-- ( ( (C_NUM_BANKS_MEM-1)+(4*C_LINEAR_FLASH_SYNC_BURST)) downto 0));

           case bus2ip_rdce_lite_cmb is
             when "00000001" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00000010" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00000100" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00001000" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00010000" => axi_lite_ip2bus_data2 <= PCR_REG(0);
             when "00100000" => axi_lite_ip2bus_data2 <= PCR_REG(1);
             when "01000000" => axi_lite_ip2bus_data2 <= PCR_REG(2);
             when "10000000" => axi_lite_ip2bus_data2 <= (others => '0');
             when others => axi_lite_ip2bus_data2 <= (others => '0');
           end case;
        end process LFLASH_CONFIG_REG_RD_PROCESS_3;
end generate PCR_THREE_GEN;

PCR_TWO_GEN: if C_NUM_BANKS_MEM = 2 generate
        LFLASH_CONFIG_REG_RD_PROCESS_2 : process (bus2ip_rdce_lite_cmb,
                                                 PCR_REG
                                               --MEM_TYPE_ARRAY
                                               ) is
        variable j : integer := 0;
        begin
        -- defaults
        axi_lite_ip2bus_data2   <= (others => '0');
        axi_lite_ip2bus_rdack2  <= or_reduce(bus2ip_rdce_lite_cmb);-- ( ( (C_NUM_BANKS_MEM-1)+(4*C_LINEAR_FLASH_SYNC_BURST)) downto 0));

           case bus2ip_rdce_lite_cmb is
             when "00000001" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00000010" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00000100" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00001000" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00010000" => axi_lite_ip2bus_data2 <= PCR_REG(0);
             when "00100000" => axi_lite_ip2bus_data2 <= PCR_REG(1);
             when "01000000" => axi_lite_ip2bus_data2 <= (others => '0');
             when "10000000" => axi_lite_ip2bus_data2 <= (others => '0');
             when others => axi_lite_ip2bus_data2 <= (others => '0');
           end case;
        end process LFLASH_CONFIG_REG_RD_PROCESS_2;
end generate PCR_TWO_GEN;

PCR_ONE_GEN: if C_NUM_BANKS_MEM = 1 generate
        LFLASH_CONFIG_REG_RD_PROCESS_1 : process (bus2ip_rdce_lite_cmb,
                                                 PCR_REG
                                               --MEM_TYPE_ARRAY
                                               ) is
        variable j : integer := 0;
        begin
        -- defaults
        axi_lite_ip2bus_data2   <= (others => '0');
        axi_lite_ip2bus_rdack2  <= or_reduce(bus2ip_rdce_lite_cmb);-- ( ( (C_NUM_BANKS_MEM-1)+(4*C_LINEAR_FLASH_SYNC_BURST)) downto 0));

           case bus2ip_rdce_lite_cmb is
             when "00000001" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00000010" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00000100" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00001000" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00010000" => axi_lite_ip2bus_data2 <= PCR_REG(0);
             when "00100000" => axi_lite_ip2bus_data2 <= (others => '0');
             when "01000000" => axi_lite_ip2bus_data2 <= (others => '0');
             when "10000000" => axi_lite_ip2bus_data2 <= (others => '0');
             when others => axi_lite_ip2bus_data2 <= (others => '0');
           end case;
        end process LFLASH_CONFIG_REG_RD_PROCESS_1;
end generate PCR_ONE_GEN;

        -----------------------------------------
        axi_lite_ip2bus_wrack2 <= or_reduce(bus2ip_wrce_lite_cmb);-- ((C_NUM_BANKS_MEM-1)+(4*C_LINEAR_FLASH_SYNC_BURST)) downto 0));
        -----------------------------------------
        LFLASH_CONFIG_REG_WR_PROCESS : process (s_axi_aclk) is
        begin
        if (s_axi_aclk'EVENT and s_axi_aclk = '1') then
           if (s_axi_aresetn = '0') then
                for i in C_NUM_BANKS_MEM-1 downto 0 loop
                   PCR_REG (i) <= X"0000_0024";
                end loop;
           else
              for i in C_NUM_BANKS_MEM-1 downto 0 loop
                 if((bus2ip_wrce_lite_cmb(4+i)='1') and
                    (MEM_TYPE_ARRAY(i) = 2    or MEM_TYPE_ARRAY(i) = 5   )

                    )then

                                PCR_REG(i)(31 downto 30) <= s_axi_reg_wdata(31 downto 30);
                                PCR_REG(i)(6 downto 0) <= s_axi_reg_wdata(6 downto 0);

                 else
                   PCR_REG(i) <= PCR_REG(i);
                 end if;
              end loop;
           end if;
        end if;
        end process LFLASH_CONFIG_REG_WR_PROCESS;
        ----------------------------------------

        MEM_WAIT_TEMP_1_GEN: if C_NUM_BANKS_MEM = 1 generate
        ------------------
        begin


					  -------------------------------------------------------------------------------
                 -- Registers the input memory wait signal.
                 -------------------------------------------------------------------------------
                 INPUT_MEM_WAIT_REGS_PROCESS: process(RdClk)
                 begin
                     if RdClk'event and RdClk = '1' then
			     if(Mem_WAIT_reg_one_hot = '1') then
                                 Mem_WAIT_reg_d1 <= '0';
			     elsif(Mem_WAIT_io(0) = '1')then
			         Mem_WAIT_reg_d1 <= '1';


			     end if;
                     end if;
                 end process INPUT_MEM_WAIT_REGS_PROCESS;
                 ----------------------------------------
                 DUAL_REG_MEM_WAIT_PROCESS: process(RdClk)
                 begin
                     if RdClk'event and RdClk = '1' then
			     Mem_WAIT_reg_d2 <= Mem_WAIT_reg_d1;
                     end if;
                 end process DUAL_REG_MEM_WAIT_PROCESS;
                 ----------------------------------------                
                 Mem_WAIT_reg_one_hot <= Mem_WAIT_reg_d1 and (not Mem_WAIT_reg_d2);
                 Mem_WAIT_reg         <= Mem_WAIT_reg_d1;

                 Linear_flash_brst_rd_flag <= sync_mode(0)       and 
		                              (not Cre_reg_en(0))and 
					      temp_bus2ip_cs(0); -- 4/2/2013
                 Cre_reg_en_reduced   <= or_reduce(Cre_reg_en);
                 -----------------------------------------


        end generate MEM_WAIT_TEMP_1_GEN;
 
        MEM_WAIT_TEMP_2_GEN: if C_NUM_BANKS_MEM = 2 generate
        ------------------
        begin



                 INPUT_MEM_WAIT_REGS_PROCESS: process(RdClk)is
                 begin
                     if RdClk'event and RdClk = '1' then

			     if(Mem_WAIT_reg_one_hot = '1') then
                                 Mem_WAIT_reg_d1 <= '0';
			     elsif(Mem_WAIT_io(0) = '1' or Mem_WAIT_io(1) = '1')then
			         Mem_WAIT_reg_d1 <= '1';
			     end if;
                     end if;
                 end process INPUT_MEM_WAIT_REGS_PROCESS;
                 ----------------------------------------
                 DUAL_REG_MEM_WAIT_PROCESS: process(RdClk) is
                 begin
                     if RdClk'event and RdClk = '1' then
			     Mem_WAIT_reg_d2 <= Mem_WAIT_reg_d1;
                     end if;
                 end process DUAL_REG_MEM_WAIT_PROCESS;
                 ----------------------------------------
                 Mem_WAIT_reg_one_hot <= Mem_WAIT_reg_d1 and (not Mem_WAIT_reg_d2);
                 Mem_WAIT_reg <= Mem_WAIT_reg_d1;

		 Linear_flash_brst_rd_flag <= (sync_mode(0) and (not Cre_reg_en(0)))
                                               when (temp_bus2ip_cs(0) = '1')
                                               else
                                               (sync_mode(1) and (not Cre_reg_en(1)))
                                               when (temp_bus2ip_cs(1) = '1')
                                               else
                                               '0';
                 Cre_reg_en_reduced   <= or_reduce(Cre_reg_en);
                 ----------------------------------------
        end generate MEM_WAIT_TEMP_2_GEN;
 
       MEM_WAIT_TEMP_3_GEN: if C_NUM_BANKS_MEM = 3 generate
        ------------------
        begin




                 INPUT_MEM_WAIT_REGS_PROCESS: process(RdClk)is
                 begin
                     if RdClk'event and RdClk = '1' then

     			          if(Mem_WAIT_reg_one_hot = '1') then
                                 Mem_WAIT_reg_d1 <= '0';
			              elsif(Mem_WAIT_io(0) = '1' or Mem_WAIT_io(1) = '1' or Mem_WAIT_io(2) = '1')then
			                     Mem_WAIT_reg_d1 <= '1';
			              end if;
                     end if;
                 end process INPUT_MEM_WAIT_REGS_PROCESS;
                 -----------------------------------------
		         DUAL_REG_MEM_WAIT_PROCESS: process(RdClk)is
                 begin
                     if RdClk'event and RdClk = '1' then
			              Mem_WAIT_reg_d2 <= Mem_WAIT_reg_d1;
                     end if;
                 end process DUAL_REG_MEM_WAIT_PROCESS;
                 -----------------------------------------
                 Mem_WAIT_reg_one_hot <= Mem_WAIT_reg_d1 and (not Mem_WAIT_reg_d2);
                 Mem_WAIT_reg         <= Mem_WAIT_reg_d1;

		 Linear_flash_brst_rd_flag <= (sync_mode(0) and (not Cre_reg_en(0)))
                                               when (temp_bus2ip_cs(0) = '1')
                                               else
                                               (sync_mode(1) and (not Cre_reg_en(1)))
                                               when (temp_bus2ip_cs(1) = '1')
                                               else
                                               (sync_mode(2) and (not Cre_reg_en(2)))
                                               when (temp_bus2ip_cs(2) = '1')
                                               else
                                               '0';
                 Cre_reg_en_reduced   <= or_reduce(Cre_reg_en);
                 -----------------------------------------
        
        end generate MEM_WAIT_TEMP_3_GEN;
        
        MEM_WAIT_TEMP_4_GEN: if C_NUM_BANKS_MEM = 4 generate
        ------------------
        begin





                 INPUT_MEM_WAIT_REGS_PROCESS: process(RdClk)is
                 begin
                     if RdClk'event and RdClk = '1' then
                             if(Mem_WAIT_reg_one_hot = '1') then
                                 Mem_WAIT_reg_d1 <= '0';
                             elsif(Mem_WAIT_io(0) = '1' or
                                   Mem_WAIT_io(1) = '1' or
                                   Mem_WAIT_io(2) = '1' or
                                   Mem_WAIT_io(3) = '1'
                                   )then
			                       Mem_WAIT_reg_d1 <= '1';
			                 end if;
                    end if;
                 end process INPUT_MEM_WAIT_REGS_PROCESS;
                 ----------------------------------------
                 DUAL_REG_MEM_WAIT_PROCESS: process(RdClk)
                 begin
                     if RdClk'event and RdClk = '1' then
			     Mem_WAIT_reg_d2 <= Mem_WAIT_reg_d1;
                     end if;
                 end process DUAL_REG_MEM_WAIT_PROCESS;
                 ----------------------------------------
                 Mem_WAIT_reg_one_hot <= Mem_WAIT_reg_d1 and (not Mem_WAIT_reg_d2);
                 Mem_WAIT_reg <= Mem_WAIT_reg_d1;
 
 		 Linear_flash_brst_rd_flag <= (sync_mode(0) and (not Cre_reg_en(0)))
                                               when (temp_bus2ip_cs(0) = '1')
                                               else
                                               (sync_mode(1) and (not Cre_reg_en(1)))
                                               when (temp_bus2ip_cs(1) = '1')
                                               else
                                               (sync_mode(2) and (not Cre_reg_en(2)))
                                               when (temp_bus2ip_cs(2) = '1')
                                               else
                                               (sync_mode(3) and (not Cre_reg_en(3)))
                                               when (temp_bus2ip_cs(3) = '1')
                                               else
                                               '0';
                 Cre_reg_en_reduced   <= or_reduce(Cre_reg_en);
		 ----------------------------------------
        end generate MEM_WAIT_TEMP_4_GEN;


                        Linear_flash_rd_data_ack <= Mem_WAIT_reg;

                        WR_PROGRAM_PROCESS : process (s_axi_aclk) is
                        begin
                        -----
                                if (s_axi_aclk'EVENT and s_axi_aclk = '1') then
                                        if (s_axi_aresetn = '0') then
                                                ADDR_select <= '0';
                                                --ADDR_PROGRAM <= (others => '0');
                                        elsif(S_AXI_MEM_WREADY1 = '1' and S_AXI_MEM_WVALID = '1') then
                                                if(signed(S_AXI_MEM_WDATA(15 downto 0)) = signed(temp_prog_cmd_data)) then
                                                        ADDR_select <= '1';
                                                  --      ADDR_PROGRAM <= S_AXI_MEM_AWADDR;
                                                end if;
                                        elsif(S_AXI_MEM_BREADY = '1' and S_AXI_MEM_BVALID1 = '1') then
                                                ADDR_select <= '0';
                                                --ADDR_PROGRAM <= (others => '0');
                                        end if;
                                end if;
                        end process WR_PROGRAM_PROCESS;


                        WR_PROGRAM_PROCESS_N : process (s_axi_aclk) is
                        begin
                        -----
                                if (s_axi_aclk'EVENT and s_axi_aclk = '1') then
                                        if (s_axi_aresetn = '0') then
                                                ADDR_PROGRAM_D <= (others => '0');                        
                                        else
                                                ADDR_PROGRAM_D <= ADDR_PROGRAM;  
                                        end if;
                                end if;
                        end process WR_PROGRAM_PROCESS_N;
                        ADDR_PROGRAM <= (others => '0') when (s_axi_aresetn = '0') 
                            else S_AXI_MEM_AWADDR when ((S_AXI_MEM_WREADY1 = '1' and S_AXI_MEM_WVALID = '1') and (signed(S_AXI_MEM_WDATA(15 downto 0)) = signed(temp_prog_cmd_data))) 
                            else (others => '0') when (S_AXI_MEM_BREADY = '1' and S_AXI_MEM_BVALID1 = '1') 
                            else ADDR_PROGRAM_D;
        -------------------------------
                        BURST_RD_ADDR_PROCESS : process (s_axi_aclk) is
                        begin
                        -----
                                if (s_axi_aclk'EVENT and s_axi_aclk = '1') then
                                        if (s_axi_aresetn = '0') then
                                                ADDR_SYNCH_BURST_RD_D <= (others => '0');
                                        elsif(S_AXI_MEM_ARREADY1 = '1' and S_AXI_MEM_ARVALID = '1') then
                                                ADDR_SYNCH_BURST_RD_D <= ADDR_SYNCH_BURST_RD;
                                        end if;                                    
                                        --if (s_axi_aresetn = '0') then
                                        --        ADDR_SYNCH_BURST_RD <= (others => '0');
                                        --elsif(S_AXI_MEM_ARREADY1 = '1' and S_AXI_MEM_ARVALID = '1') then
                                        --                ADDR_SYNCH_BURST_RD <= S_AXI_MEM_ARADDR;
                                        --end if;
                                end if;
                        end process BURST_RD_ADDR_PROCESS;

                        ADDR_SYNCH_BURST_RD <= (others => '0') when (s_axi_aresetn = '0') 
                                               else S_AXI_MEM_ARADDR when (S_AXI_MEM_ARREADY1 = '1' and S_AXI_MEM_ARVALID = '1') 
                                               else ADDR_SYNCH_BURST_RD_D;
                        --CTRL_REG_ADDR(16 downto 1) <= CTRL_REG_DATA;
                        -- Linear_flash_rd_data_ack <= sync_data_select;
                        --Linear_flash_brst_rd_flag <= sync_mode and (not Cre_reg_en);
                        
                        FLASH_SYNCH_CRE_WR_PROCESS : process (s_axi_aclk) is
                        begin
                        -----
                                if (s_axi_aclk'EVENT and s_axi_aclk = '1') then
                                        if (s_axi_aresetn = '0') then
                                                Cre_reg_en <= (others => '0');
                                                sync_mode  <= (others => '0');
                                        else
                                                Cre_reg_en <= (others => '0');
                                                sync_mode  <= (others => '0');
                                                for i in C_NUM_BANKS_MEM-1 downto 0 loop
                                                        if(bus2ip_ce_lite_cmb(4+i) = '1' ) then
                                                                sync_mode(i)     <= ( PCR_REG(i)(30));
                                                                Cre_reg_en(i)    <= PCR_REG(i)(31);
                                                        end if;
                                                end loop;
                                        end if;
                                end if;
                        end process FLASH_SYNCH_CRE_WR_PROCESS;


      end generate LINEAR_FLASH_CONFIG_REG_GEN;
--------------------------------------------------------------------------------



NO_LFLASH_PSRAM_CONFIG_REG_GEN: if (GLOBAL_PSRAM_FLASH_MEM = 0) generate
--------------------
begin
-----
            axi_lite_ip2bus_data2        <= (others => '0');
            axi_lite_ip2bus_rdack2       <= '0';
            axi_lite_ip2bus_wrack2       <= '0'; -- 6/6/2013
            psram_page_mode              <= '1';-- DONT change this value
      CRE_WR_PROCESS_G : process (s_axi_aclk) is
        begin
        if (s_axi_aclk'EVENT and s_axi_aclk = '1') then
            Mem_CRE_int        <= '0';
        end if;
      end process CRE_WR_PROCESS_G;

end generate NO_LFLASH_PSRAM_CONFIG_REG_GEN;

-------------------------------------

-- NO_PSRAM_CONFIG_REG_GEN : If any of the memories are defined with PSRAM, then there will
--               local register in the core.
----------------
PSRAM_CONFIG_REG_GEN: if (GLOBAL_PSRAM_MEM = 1) generate
--------------------
begin
-----

        --SRAM_CONFIG_REG_RD_PROCESS : process (bus2ip_rdce_lite_cmb,
        --                                      PCR_REG) is
        --egin
        --- defaults
        --xi_lite_ip2bus_data2   <= (others => '0');
        --xi_lite_ip2bus_rdack2  <= or_reduce(bus2ip_rdce_lite_cmb); -- 9/14/2013 -- (((C_NUM_BANKS_MEM-1)+(4*GLOBAL_PSRAM_MEM)) downto 0));

        --or i in C_NUM_BANKS_MEM-1 downto 0 loop
        --     if( (bus2ip_rdce_lite_cmb(4+i)='1') and
        --         (MEM_TYPE_ARRAY(i)=4          )
        --        )then
        --        axi_lite_ip2bus_data2 <= PCR_REG(i);
        --     else -- 9/14/2013
        --        axi_lite_ip2bus_data2 <= (others => '0'); 
        --     end if;
        --nd loop;
        --nd process PSRAM_CONFIG_REG_RD_PROCESS;

PSRAM_ONE_GEN: if C_NUM_BANKS_MEM = 1 generate
        PSRAM_CONFIG_REG_RD_PROCESS_1 : process (bus2ip_rdce_lite_cmb,
                                                 PCR_REG
                                               --MEM_TYPE_ARRAY
                                               ) is
        variable j : integer := 0;
        begin
        -- defaults
        axi_lite_ip2bus_data2   <= (others => '0');
        axi_lite_ip2bus_rdack2  <= or_reduce(bus2ip_rdce_lite_cmb);-- ( ( (C_NUM_BANKS_MEM-1)+(4*C_LINEAR_FLASH_SYNC_BURST)) downto 0));

           case bus2ip_rdce_lite_cmb is
             when "00000001" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00000010" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00000100" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00001000" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00010000" => axi_lite_ip2bus_data2 <= PCR_REG(0);
             when "00100000" => axi_lite_ip2bus_data2 <= (others => '0');
             when "01000000" => axi_lite_ip2bus_data2 <= (others => '0');
             when "10000000" => axi_lite_ip2bus_data2 <= (others => '0');
             when others => axi_lite_ip2bus_data2 <= (others => '0');
           end case;
        end process PSRAM_CONFIG_REG_RD_PROCESS_1;
end generate PSRAM_ONE_GEN;

PSRAM_TWO_GEN: if C_NUM_BANKS_MEM = 2 generate
        PSRAM_CONFIG_REG_RD_PROCESS_2 : process (bus2ip_rdce_lite_cmb,
                                                 PCR_REG
                                               --MEM_TYPE_ARRAY
                                               ) is
        variable j : integer := 0;
        begin
        -- defaults
        axi_lite_ip2bus_data2   <= (others => '0');
        axi_lite_ip2bus_rdack2  <= or_reduce(bus2ip_rdce_lite_cmb);-- ( ( (C_NUM_BANKS_MEM-1)+(4*C_LINEAR_FLASH_SYNC_BURST)) downto 0));

           case bus2ip_rdce_lite_cmb is
             when "00000001" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00000010" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00000100" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00001000" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00010000" => axi_lite_ip2bus_data2 <= PCR_REG(0);
             when "00100000" => axi_lite_ip2bus_data2 <= PCR_REG(1);
             when "01000000" => axi_lite_ip2bus_data2 <= (others => '0');
             when "10000000" => axi_lite_ip2bus_data2 <= (others => '0');
             when others => axi_lite_ip2bus_data2 <= (others => '0');
           end case;
        end process PSRAM_CONFIG_REG_RD_PROCESS_2;
end generate PSRAM_TWO_GEN;


PSRAM_THREE_GEN: if C_NUM_BANKS_MEM = 3 generate
        PSRAM_CONFIG_REG_RD_PROCESS_3 : process (bus2ip_rdce_lite_cmb,
                                                 PCR_REG
                                               --MEM_TYPE_ARRAY
                                               ) is
        variable j : integer := 0;
        begin
        -- defaults
        axi_lite_ip2bus_data2   <= (others => '0');
        axi_lite_ip2bus_rdack2  <= or_reduce(bus2ip_rdce_lite_cmb);-- ( ( (C_NUM_BANKS_MEM-1)+(4*C_LINEAR_FLASH_SYNC_BURST)) downto 0));

           case bus2ip_rdce_lite_cmb is
             when "00000001" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00000010" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00000100" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00001000" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00010000" => axi_lite_ip2bus_data2 <= PCR_REG(0);
             when "00100000" => axi_lite_ip2bus_data2 <= PCR_REG(1);
             when "01000000" => axi_lite_ip2bus_data2 <= PCR_REG(2);
             when "10000000" => axi_lite_ip2bus_data2 <= (others => '0');
             when others => axi_lite_ip2bus_data2 <= (others => '0');
           end case;
        end process PSRAM_CONFIG_REG_RD_PROCESS_3;
end generate PSRAM_THREE_GEN;



PSRAM_FOUR_GEN: if C_NUM_BANKS_MEM = 4 generate
        PSRAM_CONFIG_REG_RD_PROCESS_4 : process (bus2ip_rdce_lite_cmb,
                                                 PCR_REG
                                               --MEM_TYPE_ARRAY
                                               ) is
        variable j : integer := 0;
        begin
        -- defaults
        axi_lite_ip2bus_data2   <= (others => '0');
        axi_lite_ip2bus_rdack2  <= or_reduce(bus2ip_rdce_lite_cmb);-- ( ( (C_NUM_BANKS_MEM-1)+(4*C_LINEAR_FLASH_SYNC_BURST)) downto 0));

           case bus2ip_rdce_lite_cmb is
             when "00000001" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00000010" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00000100" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00001000" => axi_lite_ip2bus_data2 <= (others => '0');
             when "00010000" => axi_lite_ip2bus_data2 <= PCR_REG(0);
             when "00100000" => axi_lite_ip2bus_data2 <= PCR_REG(1);
             when "01000000" => axi_lite_ip2bus_data2 <= PCR_REG(2);
             when "10000000" => axi_lite_ip2bus_data2 <= PCR_REG(3);
             when others => axi_lite_ip2bus_data2 <= (others => '0');
           end case;
        end process PSRAM_CONFIG_REG_RD_PROCESS_4;
end generate PSRAM_FOUR_GEN;

        axi_lite_ip2bus_wrack2 <= or_reduce(bus2ip_wrce_lite_cmb); -- 9/14/2013 -- (((C_NUM_BANKS_MEM-1)+(4*GLOBAL_PSRAM_MEM)) downto 0));

        PSRAM_CONFIG_REG_WR_PROCESS : process (s_axi_aclk) is
        begin
        if (s_axi_aclk'EVENT and s_axi_aclk = '1') then
           if (s_axi_aresetn = '0') then
                for i in C_NUM_BANKS_MEM-1 downto 0 loop
                   PCR_REG (i) <= X"0000_0024";
                end loop;
           else
              for i in C_NUM_BANKS_MEM-1 downto 0 loop
                 if((bus2ip_wrce_lite_cmb(4+i)='1') and
                    (MEM_TYPE_ARRAY(i) = 4   )
                    )then
                   --PCR_REG(i) <= s_axi_reg_wdata;
                                PCR_REG(i)(31 downto 30) <= s_axi_reg_wdata(31 downto 30);
                                PCR_REG(i)(6 downto 0) <= s_axi_reg_wdata(6 downto 0);
                   
                 else
                   PCR_REG(i) <= PCR_REG(i);
                 end if;
              end loop;
           end if;
        end if;
        end process PSRAM_CONFIG_REG_WR_PROCESS;
        ----------------------------------------

      CRE_WR_PROCESS : process (s_axi_aclk) is
        begin
        -----
        if (s_axi_aclk'EVENT and s_axi_aclk = '1') then
                if (s_axi_aresetn = '0') then
                    Mem_CRE_int     <= '0';
                    psram_page_mode <= '1';
                else
        -- defaults
                    Mem_CRE_int     <= '0';
                    psram_page_mode <= '0';
                    for i in C_NUM_BANKS_MEM-1 downto 0 loop
                        if (temp_bus2ip_cs(i) = '1' ) then
                            Mem_CRE_int     <= PCR_REG(i)(6);-- (25);
                            psram_page_mode <= PCR_REG(i)(0); -- (31);
                        end if;
                    end loop;
                end if;
        end if;
      end process CRE_WR_PROCESS;
      ---------------------------
end generate PSRAM_CONFIG_REG_GEN;








-------------------------
end generate REG_EN_GEN;
-------------------------------------------------------------------------------

AXI_EMC_NATIVE_INTERFACE_I: entity axi_emc_v3_0.axi_emc_native_interface
   -- Generics to be set by user
    generic map(

        C_FAMILY                 => C_FAMILY                ,
        C_S_AXI_MEM_ADDR_WIDTH   => C_S_AXI_MEM_ADDR_WIDTH  ,
        C_S_AXI_MEM_DATA_WIDTH   => C_S_AXI_MEM_DATA_WIDTH  ,
        C_S_AXI_MEM_ID_WIDTH     => C_S_AXI_MEM_ID_WIDTH    ,

        C_S_AXI_MEM0_BASEADDR    => C_S_AXI_MEM0_BASEADDR   ,
        C_S_AXI_MEM0_HIGHADDR    => C_S_AXI_MEM0_HIGHADDR   ,
        C_S_AXI_MEM1_BASEADDR    => C_S_AXI_MEM1_BASEADDR   ,
        C_S_AXI_MEM1_HIGHADDR    => C_S_AXI_MEM1_HIGHADDR   ,
        C_S_AXI_MEM2_BASEADDR    => C_S_AXI_MEM2_BASEADDR   ,
        C_S_AXI_MEM2_HIGHADDR    => C_S_AXI_MEM2_HIGHADDR   ,
        C_S_AXI_MEM3_BASEADDR    => C_S_AXI_MEM3_BASEADDR   ,
        C_S_AXI_MEM3_HIGHADDR    => C_S_AXI_MEM3_HIGHADDR   ,
        AXI_ARD_ADDR_RANGE_ARRAY => AXI_ARD_ADDR_RANGE_ARRAY,
        AXI_ARD_NUM_CE_ARRAY     => AXI_ARD_NUM_CE_ARRAY    ,
        C_NUM_BANKS_MEM          => C_NUM_BANKS_MEM
        )
   port map(
    s_axi_aclk                   => s_axi_aclk             ,
    s_axi_aresetn                => s_axi_aresetn          ,
--   -- AXI Write Address Channel Signals
    S_AXI_MEM_AWID               => s_axi_mem_awid         ,
    S_AXI_MEM_AWADDR             => s_axi_mem_awaddr       ,
    S_AXI_MEM_AWLEN              => s_axi_mem_awlen        ,
    S_AXI_MEM_AWSIZE             => s_axi_mem_awsize       ,
    S_AXI_MEM_AWBURST            => s_axi_mem_awburst      ,
    S_AXI_MEM_AWLOCK             => s_axi_mem_awlock       ,
    S_AXI_MEM_AWCACHE            => s_axi_mem_awcache      ,
    S_AXI_MEM_AWPROT             => s_axi_mem_awprot       ,
    S_AXI_MEM_AWVALID            => s_axi_mem_awvalid      ,
    S_AXI_MEM_AWREADY            => s_axi_mem_awready      ,
--   -- AXI Write Channel Signals
    S_AXI_MEM_WDATA              => s_axi_mem_wdata        ,
    S_AXI_MEM_WSTRB              => s_axi_mem_wstrb        ,
    S_AXI_MEM_WLAST              => s_axi_mem_wlast        ,
    S_AXI_MEM_WVALID             => s_axi_mem_wvalid       ,
    S_AXI_MEM_WREADY             => s_axi_mem_wready1       ,
--   -- AXI Write Response Channel Signals
    S_AXI_MEM_BID                => s_axi_mem_bid          ,
    S_AXI_MEM_BRESP              => s_axi_mem_bresp        ,
    S_AXI_MEM_BVALID             => s_axi_mem_bvalid1       ,
    S_AXI_MEM_BREADY             => s_axi_mem_bready       ,
--   -- AXI Read Address Channel Signals
    S_AXI_MEM_ARID               => s_axi_mem_arid         ,
    S_AXI_MEM_ARADDR             => s_axi_mem_araddr       ,
    S_AXI_MEM_ARLEN              => s_axi_mem_arlen        ,
    S_AXI_MEM_ARSIZE             => s_axi_mem_arsize       ,
    S_AXI_MEM_ARBURST            => s_axi_mem_arburst      ,
    S_AXI_MEM_ARLOCK             => s_axi_mem_arlock       ,
    S_AXI_MEM_ARCACHE            => s_axi_mem_arcache      ,
    S_AXI_MEM_ARPROT             => s_axi_mem_arprot       ,
    S_AXI_MEM_ARVALID            => s_axi_mem_arvalid      ,
    S_AXI_MEM_ARREADY            => s_axi_mem_arready1      ,
--   -- AXI Read Data Channel Signals
    S_AXI_MEM_RID                => s_axi_mem_rid          ,
    S_AXI_MEM_RDATA              => s_axi_mem_rdata        ,
    S_AXI_MEM_RRESP              => s_axi_mem_rresp        ,
    S_AXI_MEM_RLAST              => s_axi_mem_rlast        ,
    S_AXI_MEM_RVALID             => s_axi_mem_rvalid       ,
    S_AXI_MEM_RREADY             => s_axi_mem_rready       ,
-- IP Interconnect (IPIC) port signals ------------------------------------
      -- Controls to the IP/IPIF modules
    -- IP Interconnect (IPIC) port signals
    IP2Bus_Data                  => temp_ip2bus_data       ,
    IP2Bus_WrAck                 => IP2Bus_WrAck           ,
    IP2Bus_RdAck                 => IP2Bus_RdAck           ,
    IP2Bus_AddrAck               => IP2Bus_AddrAck         ,
    IP2Bus_Error                 => ip2bus_errack          ,

    Bus2IP_Addr                  => bus2ip_addr_temp       ,
    Bus2IP_Data                  => temp_bus2ip_data       ,
    Bus2IP_RNW                   => Bus2IP_RNW             ,
    Bus2IP_BE                    => temp_bus2ip_be         ,
    Bus2IP_Burst                 => Bus2IP_Burst           ,

    Bus2IP_BurstLength           => bus2ip_burstlength     ,
    Bus2IP_RdReq                 => Bus2IP_RdReq_emc       ,
    Bus2IP_WrReq                 => Bus2IP_WrReq_emc       ,
    Bus2IP_CS                    => temp_bus2ip_cs         ,

    Bus2IP_RdCE                  => bus2ip_rdce            ,
    Bus2IP_WrCE                  => bus2ip_wrce            ,
    Type_of_xfer                 => Type_of_xfer           ,
    Cre_reg_en                   => Cre_reg_en_reduced     , -- newly added
    synch_mem                    => synch_mem              ,
    last_addr1                   => last_addr1             ,
    pr_idle                      => pr_idle                ,
    axi_trans_size_reg           => axi_trans_size_reg_int 
    );

    ---------------------------------------------------------------------------
     -- Miscellaneous assignments to match EMC controller to IPIC
    ---------------------------------------------------------------------------
    or_reduced_wrce <= or_reduce(bus2ip_wrce);
    ------------------------------------------
    RD_CE_PIPE_PROCESS : process(s_axi_aclk)is
    begin
        if(s_axi_aclk'EVENT and s_axi_aclk = '1') then
                or_reduced_rdce_d1    <= or_reduce(bus2ip_rdce);
                bus2ip_wrreq_reg      <= or_reduced_wrce;
        end if;
    end process RD_CE_PIPE_PROCESS;
    ------------------------------------------
    original_wrce   <= or_reduced_wrce;

    bus2ip_wrreq_i  <= Bus2IP_WrReq_emc;--or_reduce(bus2ip_wrce);

    --bus2ip_rdreq_i  <= or_reduce(bus2ip_rdce); -- Bus2IP_RdReq_emc;--or_reduce(bus2ip_rdce);
    bus2ip_rdreq_i  <=  Bus2IP_RdReq_emc when synch_mem = '1' else or_reduce(bus2ip_rdce);--or_reduce(bus2ip_rdce);
    bus2ip_cs_i     <= or_reduce(temp_bus2ip_cs);

    ---------------------------------------------------------------------------
     -- AXI EMC is little endian and EMC COMMON is still big endian, to make
     -- this interface work normally, we need to swap the Write and read data
     -- comming from and going to slave burst interface
    ---------------------------------------------------------------------------

    ENDIAN_BANKS_0 : if (C_NUM_BANKS_MEM = 1) generate
        bus2ip_cs(0)<= temp_bus2ip_cs(0);
    end generate ENDIAN_BANKS_0;

    ENDIAN_BANKS_1 : if (C_NUM_BANKS_MEM = 2) generate
        bus2ip_cs(0)<= temp_bus2ip_cs(0);
        bus2ip_cs(1)<= temp_bus2ip_cs(1);
    end generate ENDIAN_BANKS_1;

    ENDIAN_BANKS_2 : if (C_NUM_BANKS_MEM = 3) generate
        bus2ip_cs(0)<= temp_bus2ip_cs(0);
        bus2ip_cs(1)<= temp_bus2ip_cs(1);
        bus2ip_cs(2)<= temp_bus2ip_cs(2);
    end generate ENDIAN_BANKS_2;

    ENDIAN_BANKS_3 : if (C_NUM_BANKS_MEM = 4) generate
        bus2ip_cs(0)<= temp_bus2ip_cs(0);
        bus2ip_cs(1)<= temp_bus2ip_cs(1);
        bus2ip_cs(2)<= temp_bus2ip_cs(2);
        bus2ip_cs(3)<= temp_bus2ip_cs(3);
    end generate ENDIAN_BANKS_3;



    ENDIAN_CONVERSION_32 : if (C_S_AXI_MEM_DATA_WIDTH = 32) generate

        bus2ip_data(0 to 7)   <= temp_bus2ip_data(7 downto 0);
        bus2ip_data(8 to 15)  <= temp_bus2ip_data(15 downto 8);
        bus2ip_data(16 to 23) <= temp_bus2ip_data(23 downto 16);
        bus2ip_data(24 to 31) <= temp_bus2ip_data(31 downto 24);

        temp_ip2bus_data(7 downto 0)   <= ip2bus_data(0 to 7) ;
        temp_ip2bus_data(15 downto 8)  <= ip2bus_data(8 to 15) ;
        temp_ip2bus_data(23 downto 16) <= ip2bus_data(16 to 23);
        temp_ip2bus_data(31 downto 24) <= ip2bus_data(24 to 31);


        bus2ip_be(0) <= temp_bus2ip_be(0);
        bus2ip_be(1) <= temp_bus2ip_be(1);
        bus2ip_be(2) <= temp_bus2ip_be(2);
        bus2ip_be(3) <= temp_bus2ip_be(3);

        -- the below logic is to generate the lower 2 bits of address for 32
        -- bit data width
        temp_single_0 <= or_reduce(temp_bus2ip_be(1 downto 0));
        temp_single_1 <= or_reduce(temp_bus2ip_be(3 downto 0));


        bus2ip_addr_reg(2) <= ((not temp_bus2ip_be(0)) and
                               (temp_bus2ip_be(1)
                                 OR
                                 ((NOT temp_bus2ip_be(2)) and
                                     temp_bus2ip_be(3)    and
                                  (NOT temp_single_0)
                                 )
                               )
                              ) and Type_of_xfer;

        bus2ip_addr_reg(1) <= (((not temp_bus2ip_be(0)) and (not
                                temp_bus2ip_be(1))) and (temp_bus2ip_be(2) OR
                                temp_bus2ip_be(3)))and Type_of_xfer;

        bus2ip_addr <= (bus2ip_addr_temp (0 to 29) & bus2ip_addr_reg (1 to 2)) 
                       when (Cre_reg_en_reduced = '0')
                       else 
                       bus2ip_addr_temp ;

        bus2ip_addr_reg(0) <= '0';

     end generate ENDIAN_CONVERSION_32;


    ENDIAN_CONVERSION_64 : if (C_S_AXI_MEM_DATA_WIDTH = 64) generate


        bus2ip_data(0 to 7)   <= temp_bus2ip_data(7 downto 0);
        bus2ip_data(8 to 15)  <= temp_bus2ip_data(15 downto 8);
        bus2ip_data(16 to 23) <= temp_bus2ip_data(23 downto 16);
        bus2ip_data(24 to 31) <= temp_bus2ip_data(31 downto 24);

        bus2ip_data(32 to 39) <= temp_bus2ip_data(39 downto 32);
        bus2ip_data(40 to 47) <= temp_bus2ip_data(47 downto 40);
        bus2ip_data(48 to 55) <= temp_bus2ip_data(55 downto 48);
        bus2ip_data(56 to 63) <= temp_bus2ip_data(63 downto 56);

        temp_ip2bus_data(7 downto 0)   <= ip2bus_data(0 to 7) ;
        temp_ip2bus_data(15 downto 8)  <= ip2bus_data(8 to 15) ;
        temp_ip2bus_data(23 downto 16) <= ip2bus_data(16 to 23);
        temp_ip2bus_data(31 downto 24) <= ip2bus_data(24 to 31);

        temp_ip2bus_data(39 downto 32) <= ip2bus_data(32 to 39);
        temp_ip2bus_data(47 downto 40) <= ip2bus_data(40 to 47);
        temp_ip2bus_data(55 downto 48) <= ip2bus_data(48 to 55);
        temp_ip2bus_data(63 downto 56) <= ip2bus_data(56 to 63);


        bus2ip_be(0) <= temp_bus2ip_be(0);
        bus2ip_be(1) <= temp_bus2ip_be(1);
        bus2ip_be(2) <= temp_bus2ip_be(2);
        bus2ip_be(3) <= temp_bus2ip_be(3);
        bus2ip_be(4) <= temp_bus2ip_be(4);
        bus2ip_be(5) <= temp_bus2ip_be(5);
        bus2ip_be(6) <= temp_bus2ip_be(6);
        bus2ip_be(7) <= temp_bus2ip_be(7);

        -- the below logic is to generate the lower 3 bits of address for 64 bit
        -- data width
        temp_single_0 <= or_reduce(temp_bus2ip_be(1 downto 0));
        temp_single_1 <= or_reduce(temp_bus2ip_be(3 downto 0));
        temp_single_2 <= or_reduce(temp_bus2ip_be(5 downto 0));


        bus2ip_addr_reg(2) <=((not temp_bus2ip_be(0)) and (temp_bus2ip_be(1)
                                OR ((NOT temp_bus2ip_be(2)) and
                                     temp_bus2ip_be(3)      and
                                     (NOT temp_single_0))
                                OR ((NOT temp_bus2ip_be(4)) and
                                     temp_bus2ip_be(5)      and
                                     (NOT temp_single_1))
                                OR ((NOT temp_bus2ip_be(6)) and
                                     temp_bus2ip_be(7)      and
                                     (NOT temp_single_2)))) and Type_of_xfer;

        bus2ip_addr_reg(1) <=((((not temp_bus2ip_be(0)) and
                               (not temp_bus2ip_be(1))) and (temp_bus2ip_be(2)
                               OR temp_bus2ip_be(3))) OR
                               (((not temp_bus2ip_be(4)) and
                               (not temp_bus2ip_be(5))) and (temp_bus2ip_be(6)
                               OR temp_bus2ip_be(7)) and (NOT temp_single_0)))
                               and Type_of_xfer;


        bus2ip_addr_reg(0) <= (not (temp_bus2ip_be(0) or temp_bus2ip_be(1) or
                                   temp_bus2ip_be(2) or temp_bus2ip_be(3)))
                                   and Type_of_xfer;

        bus2ip_addr <= bus2ip_addr_temp (0 to 28) &
                                                bus2ip_addr_reg (0 to 2)
                                                when bus2ip_cs_i = '1' else
                                                (others => '0');

     end generate ENDIAN_CONVERSION_64;



  -----------------------------------------------------------------------------
  --RESET_TOGGLE: convert active low to active hig reset to rest of the core.
  -----------------------------------------------------------------------------
  RESET_TOGGLE: process (s_axi_aclk) is
  begin
       if(s_axi_aclk'event and s_axi_aclk = '1') then
           bus2ip_reset <= not(s_axi_aresetn);
       end if;
  end process RESET_TOGGLE;



   EMC_CTRL_I: entity emc_common_v3_0.emc
        generic map(
            C_NUM_BANKS_MEM                => C_NUM_BANKS_MEM,
            C_IPIF_DWIDTH                  => C_S_AXI_MEM_DATA_WIDTH,
            C_IPIF_AWIDTH                  => C_S_AXI_MEM_ADDR_WIDTH,

            C_MEM0_BASEADDR                => C_S_AXI_MEM0_BASEADDR,
            C_MEM0_HIGHADDR                => C_S_AXI_MEM0_HIGHADDR,
            C_MEM1_BASEADDR                => C_S_AXI_MEM1_BASEADDR,
            C_MEM1_HIGHADDR                => C_S_AXI_MEM1_HIGHADDR,
            C_MEM2_BASEADDR                => C_S_AXI_MEM2_BASEADDR,
            C_MEM2_HIGHADDR                => C_S_AXI_MEM2_HIGHADDR,
            C_MEM3_BASEADDR                => C_S_AXI_MEM3_BASEADDR,
            C_MEM3_HIGHADDR                => C_S_AXI_MEM3_HIGHADDR,

            C_PAGEMODE_FLASH_0             => C_PAGEMODE_FLASH_0,
            C_PAGEMODE_FLASH_1             => C_PAGEMODE_FLASH_1,
            C_PAGEMODE_FLASH_2             => C_PAGEMODE_FLASH_2,
            C_PAGEMODE_FLASH_3             => C_PAGEMODE_FLASH_3,

            C_INCLUDE_NEGEDGE_IOREGS       => C_INCLUDE_NEGEDGE_IOREGS,

            C_MEM0_WIDTH                   => C_MEM0_WIDTH,
            C_MEM1_WIDTH                   => C_MEM1_WIDTH,
            C_MEM2_WIDTH                   => C_MEM2_WIDTH,
            C_MEM3_WIDTH                   => C_MEM3_WIDTH,
            C_MAX_MEM_WIDTH                => C_MAX_MEM_WIDTH,

            C_MEM0_TYPE                    => C_MEM0_TYPE,
            C_MEM1_TYPE                    => C_MEM1_TYPE,
            C_MEM2_TYPE                    => C_MEM2_TYPE,
            C_MEM3_TYPE                    => C_MEM3_TYPE,

            C_PARITY_TYPE_0                => C_PARITY_TYPE_MEM_0,
            C_PARITY_TYPE_1                => C_PARITY_TYPE_MEM_1,
            C_PARITY_TYPE_2                => C_PARITY_TYPE_MEM_2,
            C_PARITY_TYPE_3                => C_PARITY_TYPE_MEM_3,

            C_INCLUDE_DATAWIDTH_MATCHING_0 => C_INCLUDE_DATAWIDTH_MATCHING_0,
            C_INCLUDE_DATAWIDTH_MATCHING_1 => C_INCLUDE_DATAWIDTH_MATCHING_1,
            C_INCLUDE_DATAWIDTH_MATCHING_2 => C_INCLUDE_DATAWIDTH_MATCHING_2,
            C_INCLUDE_DATAWIDTH_MATCHING_3 => C_INCLUDE_DATAWIDTH_MATCHING_3,

            -- Memory read and write access times for all memory banks
            C_BUS_CLOCK_PERIOD_PS          => C_AXI_CLK_PERIOD_PS,

            C_SYNCH_MEM_0                  => C_SYNCH_MEM_0,
            C_SYNCH_PIPEDELAY_0            => C_SYNCH_PIPEDELAY_0,
            C_TCEDV_PS_MEM_0               => C_TCEDV_PS_MEM_0,
            C_TAVDV_PS_MEM_0               => C_TAVDV_PS_MEM_0,
            C_TPACC_PS_FLASH_0             => C_TPACC_PS_FLASH_0,
            C_THZCE_PS_MEM_0               => C_THZCE_PS_MEM_0,
            C_THZOE_PS_MEM_0               => C_THZOE_PS_MEM_0,
            C_TWC_PS_MEM_0                 => C_TWC_PS_MEM_0,
            C_TWP_PS_MEM_0                 => C_TWP_PS_MEM_0,
            C_TWPH_PS_MEM_0                => C_TWPH_PS_MEM_0,
            C_TLZWE_PS_MEM_0               => C_TLZWE_PS_MEM_0,
            C_WR_REC_TIME_MEM_0            => C_WR_REC_TIME_MEM_0,

            C_SYNCH_MEM_1                  => C_SYNCH_MEM_1,
            C_SYNCH_PIPEDELAY_1            => C_SYNCH_PIPEDELAY_1,
            C_TCEDV_PS_MEM_1               => C_TCEDV_PS_MEM_1,
            C_TAVDV_PS_MEM_1               => C_TAVDV_PS_MEM_1,
            C_TPACC_PS_FLASH_1             => C_TPACC_PS_FLASH_1,
            C_THZCE_PS_MEM_1               => C_THZCE_PS_MEM_1,
            C_THZOE_PS_MEM_1               => C_THZOE_PS_MEM_1,
            C_TWC_PS_MEM_1                 => C_TWC_PS_MEM_1,
            C_TWP_PS_MEM_1                 => C_TWP_PS_MEM_1,
            C_TWPH_PS_MEM_1                => C_TWPH_PS_MEM_1,
            C_TLZWE_PS_MEM_1               => C_TLZWE_PS_MEM_1,
            C_WR_REC_TIME_MEM_1            => C_WR_REC_TIME_MEM_1,

            C_SYNCH_MEM_2                  => C_SYNCH_MEM_2,
            C_SYNCH_PIPEDELAY_2            => C_SYNCH_PIPEDELAY_2,
            C_TCEDV_PS_MEM_2               => C_TCEDV_PS_MEM_2,
            C_TAVDV_PS_MEM_2               => C_TAVDV_PS_MEM_2,
            C_TPACC_PS_FLASH_2             => C_TPACC_PS_FLASH_2,
            C_THZCE_PS_MEM_2               => C_THZCE_PS_MEM_2,
            C_THZOE_PS_MEM_2               => C_THZOE_PS_MEM_2,
            C_TWC_PS_MEM_2                 => C_TWC_PS_MEM_2,
            C_TWP_PS_MEM_2                 => C_TWP_PS_MEM_2,
            C_TWPH_PS_MEM_2                => C_TWPH_PS_MEM_2,
            C_TLZWE_PS_MEM_2               => C_TLZWE_PS_MEM_2,
            C_WR_REC_TIME_MEM_2            => C_WR_REC_TIME_MEM_2,

            C_SYNCH_MEM_3                  => C_SYNCH_MEM_3,
            C_SYNCH_PIPEDELAY_3            => C_SYNCH_PIPEDELAY_3,
            C_TCEDV_PS_MEM_3               => C_TCEDV_PS_MEM_3,
            C_TAVDV_PS_MEM_3               => C_TAVDV_PS_MEM_3,
            C_TPACC_PS_FLASH_3             => C_TPACC_PS_FLASH_3,
            C_THZCE_PS_MEM_3               => C_THZCE_PS_MEM_3,
            C_THZOE_PS_MEM_3               => C_THZOE_PS_MEM_3,
            C_TWC_PS_MEM_3                 => C_TWC_PS_MEM_3,
            C_TWP_PS_MEM_3                 => C_TWP_PS_MEM_3,
            C_TWPH_PS_MEM_3                => C_TWPH_PS_MEM_3,
            C_TLZWE_PS_MEM_3               => C_TLZWE_PS_MEM_3,
            C_WR_REC_TIME_MEM_3            => C_WR_REC_TIME_MEM_3
        )
        port map (
            Bus2IP_Clk         => s_axi_aclk           ,
            RdClk              => RdClk                ,
            Bus2IP_Reset       => Bus2IP_Reset         ,

            -- Bus and IPIC Interface signals
            Bus2IP_Addr        => bus2ip_addr          ,
            Bus2IP_BE          => bus2ip_be            ,
            Bus2IP_Data        => bus2ip_data          ,
            Bus2IP_RNW         => bus2ip_rnw           ,
            Bus2IP_Burst       => bus2ip_burst         ,
            Bus2IP_WrReq       => bus2ip_wrreq_i       ,
            Bus2IP_RdReq       => bus2ip_rdreq_i       ,
            Linear_flash_brst_rd_flag => Linear_flash_brst_rd_flag ,
            Linear_flash_rd_data_ack  => Linear_flash_rd_data_ack  ,
            Bus2IP_RdReq_emc   => Bus2IP_RdReq_emc     ,
            Bus2IP_WrReq_emc   => Bus2IP_WrReq_emc     ,

            Bus2IP_Mem_CS      => bus2ip_cs            ,
            Bus2IP_BurstLength => bus2ip_burstlength   ,

            IP2Bus_Data        => ip2bus_data          ,
            IP2Bus_errAck      => ip2bus_errack        ,
            IP2Bus_retry       => open                 ,
            IP2Bus_toutSup     => open                 ,
            IP2Bus_RdAck       => ip2bus_rdack         ,
            IP2Bus_WrAck       => ip2bus_wrack         ,
            IP2Bus_AddrAck     => ip2bus_addrack       ,

            parity_error_adrss => parity_error_adrss   , -- 32 bit
            parity_error_mem   => parity_error_MEM     , -- 2 bit
            Type_of_xfer       => Type_of_xfer         ,
            psram_page_mode    => psram_page_mode      ,

            original_wrce           => original_wrce   ,
            -- Memory signals
            Mem_A              => mem_a_i              ,
            Mem_DQ_I           => mem_dq_i_i           ,
            Mem_DQ_O           => mem_dq_o_i           ,
            Mem_DQ_T           => mem_dq_t_i           ,
            Mem_DQ_PRTY_I      => mem_dq_parity_i_i    ,
            Mem_DQ_PRTY_O      => mem_dq_parity_o_i    ,
            Mem_DQ_PRTY_T      => mem_dq_parity_t_i    ,
            Mem_CEN            => mem_cen_i            ,
            Mem_OEN            => mem_oen_i            ,
            Mem_WEN            => mem_wen_i            ,
            Mem_QWEN           => mem_qwen_i           ,
            Mem_BEN            => mem_ben_i            ,
            Mem_RPN            => Mem_RPN              ,
            Mem_CE             => mem_ce_i             ,
            Mem_ADV_LDN        => mem_adv_ldn_i        ,
            Mem_LBON           => Mem_LBON             ,
            Mem_CKEN           => mem_cken_i           ,
            Mem_RNW            => Mem_RNW              ,

            Cre_reg_en         => Cre_reg_en_reduced   ,
            MEM_WAIT           => Mem_WAIT_reg         ,
            synch_mem12        => synch_mem            ,
            last_addr1         => last_addr1           ,
            pr_idle            => pr_idle              ,
            axi_trans_size_reg => axi_trans_size_reg_int,
            axi_arsize         => axi_arsize,
            axi_wvalid         => S_AXI_MEM_WVALID,
            axi_wlast          => S_AXI_MEM_WLAST,
            Parity_err         => Parity_err_i
        );
end imp;
