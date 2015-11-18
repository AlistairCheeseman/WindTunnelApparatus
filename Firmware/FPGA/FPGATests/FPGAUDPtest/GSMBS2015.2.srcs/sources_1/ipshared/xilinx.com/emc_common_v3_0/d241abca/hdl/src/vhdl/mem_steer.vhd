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
-- Filename:        mem_steer.vhd
-- Description:     This file contains the logic for steering the read data,
--                  write data and memory controls to the appropriate memory
--                  and data byte lane.
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
-- Removed the unused part of code (not supporting C_MAX_MEM_WIDTH = 64): -
-- 1. Deleted the generate block lebelled "WRITE_DATABE_MUX_64_GEN".
-- 2. Deleted the generate block lebelled "READ_DATA_64_GEN".
-- Removed the unused part of code (not supporting C_IPIF_DWIDTH = 64): -
-- 1. Deleted the generate block lebelled "READ_DATA_CE_64_GEN".
-- ~~~~~~~~
-- NSK         05/08/08    version v3_00_a
-- ^^^^^^^^
-- 1. This file is same as in version v3_02_a.
-- 2. Upgraded to version v3.00.a to have proper versioning to fix CR #472164.
-- 3. No change in design.

-- KSB         05/08/08    version v4_00_a
-- 1. Modified for Page mdoe read
-- 2. Modified for 64 Bit memory address align
-- ~~~~~~~~
-- KSB         22/05/10    version v5_00_a
-- 1. Modified for AXI EMC, PSRAM, Byte parity Memory Support
-- 2. Modified for AXI Slave burst interface
-- ~~~~~~~~
-- ~~~~~~
-- SK          25/10/10
-- ^^^^^^^^
-- 1. Added "parity_error_mem" in default condition in "MEM_CEN_STEER_PROCESS".
-- 2. In "PARITY_ACK_SYNC",
--    a.added "MEM2BUS_PARITY_ERR_P" by replacing priority logic
--    b.added "MEM2BUS_RD_ACK_P" by replacing priority logic
--    c.added "ADDR_ALIGN_READ_P" by replacing priority logic for addr_align_read
-- ~~~~~~
-- SK          24/11/10
-- ^^^^^^^^
-- 1. Added "ns_idle" signal to reset the address counter in mem_steer.vhd
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

-------------------------------------------------------------------------------
-- vcomponents package of the unisim library is used for the FDS, FDR and FDCE
-- component declarations
-------------------------------------------------------------------------------

library unisim;
use unisim.vcomponents.all;

-------------------------------------------------------------------------------
-- Definition of Generics:

--      C_NUM_BANKS_MEM             -- Number of Memory Banks
--      C_MAX_MEM_WIDTH             -- Maximum memory width of all memory banks
--      C_MIN_MEM_WIDTH             -- Minimum memory width (set to 8 bits)
--      C_IPIF_DWIDTH               -- Width of IPIF data bus
--      C_ADDR_CNTR_WIDTH           -- Width of address counter
--      C_GLOBAL_DATAWIDTH_MATCH    -- Indicates if datawidth matching is
--                                     implemented in any memory bank
--      C_GLOBAL_SYNC_MEM           -- Indicates if any memory bank is
--                                     synchronous
--
-- Definition of Ports:

-- EMC signals
--      Bus2IP_Data                 -- Processor Data Bus
--      Bus2IP_BE                   -- Processor Byte Enable
--      Bus2IP_Mem_CS               -- Memory Channel Chip Select
--
-- Memory state machine signals
--      Write_req_ack               -- Memory Write Acknowledge
--      Read_req_ack                -- Memory Read Address Acknowledge
--      Read_ack                    -- Memory Read Acknowledge
--      Read_data_en                -- Read Data Enable for read registers
--      Data_strobe                 -- Data Strobe signal
--      MSM_Mem_CEN                 -- Memory Chip Enable
--      MSM_Mem_OEN                 -- Memory Output Enable
--      MSM_Mem_WEN                 -- Memory Write Enable
--      Mem2Bus_WrAddrAck           -- Memory Write Address Acknowledge
--      Mem2Bus_WrAck               -- Memory Write Data Acknowledge
--      Mem2Bus_RdAddrAck           -- Memory Read Address Acknowledge
--      Mem2Bus_RdAck               -- Memory Read Data Acknowledge
--      Mem2Bus_Data                -- Memory Read Data

-- Select Param signals
--      Mem_width_bytes             -- Memory Device Width in Bytes
--      Synch_mem                   -- Synchronous Memory Control
--      Two_pipe_delay              -- Synchronous pipeline stages

-- Addr counter mux signals
--      Addr_cnt                    -- Address Count

-- IO Register signals
--      MemSteer_Mem_DQ_I           -- Memory Device Data In
--      MemSteer_Mem_DQ_O           -- Memory Device Data Out
--      MemSteer_Mem_DQ_T           -- Memory Device FPGA Impedance Control
--      MemSteer_Mem_DQ_prty_I      -- Memory Device Parity Input
--      MemSteer_Mem_DQ_prty_O      -- Memory Device Parity Output
--      MemSteer_Mem_DQ_prty_T      -- Memory Device Parity Impedance Control
--      MemSteer_Mem_CEN            -- Memory Device Chip Enable (Active Low)
--      MemSteer_Mem_OEN            -- Memory Device Output Enable
--      MemSteer_Mem_WEN            -- Memory Device Write Enable
--      MemSteer_Mem_QWEN           -- Memory Device Qualified Write Enabled
--      MemSteer_Mem_BEN            -- Memory Device Byte Enable
--      MemSteer_Mem_CE             -- Memory Device Chip Enable (Active High)
--      MemSteer_Mem_RNW            -- Memory Device Read/Write
--
--  Clock and reset
--      Clk                         -- System Clock
--      Rst                         -- System Reset
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Entity section
-------------------------------------------------------------------------------

entity mem_steer is
    generic (
        C_NUM_BANKS_MEM          : integer;
        C_MAX_MEM_WIDTH          : integer;
        C_MIN_MEM_WIDTH          : integer;
        C_IPIF_DWIDTH            : integer;
        C_IPIF_AWIDTH            : integer;
        C_PARITY_TYPE_MEMORY     : integer range 0 to 1;
        C_ADDR_CNTR_WIDTH        : integer range 1 to 5;
        C_GLOBAL_DATAWIDTH_MATCH : integer range 0 to 1;
        C_GLOBAL_SYNC_MEM        : integer range 0 to 1
    );
    port (
        -- Clock and reset
        Clk                      : in  std_logic;
        Rst                      : in  std_logic;

  -- EMC signals
        Bus2IP_Data              : in std_logic_vector(0 to C_IPIF_DWIDTH-1);
        Bus2IP_BE                : in std_logic_vector(0 to C_IPIF_DWIDTH/8-1);
        Bus2IP_Mem_CS            : in std_logic_vector(0 to C_NUM_BANKS_MEM-1);
        Bus2IP_RdReq             : in  std_logic;
        Bus2IP_Burst             : in  std_logic;


        -- Memory state machine signals
        Write_req_ack            : in  std_logic;
        Read_req_ack             : in  std_logic;
        Read_ack                 : in  std_logic;
        Read_data_en             : in  std_logic;
       -- Data_strobe              : in  std_logic;09-12-2012
        MSM_Mem_CEN              : in  std_logic;
        MSM_Mem_OEN              : in  std_logic;
        MSM_Mem_WEN              : in  std_logic;
        Mem2Bus_WrAddrAck        : out std_logic;
        Mem2Bus_WrAck            : out std_logic;
        Mem2Bus_RdAddrAck        : out std_logic;
        Mem2Bus_RdAck            : out std_logic;
        Mem2Bus_Data             : out std_logic_vector(0 to C_IPIF_DWIDTH -1);

        -- Select param signals
        Mem_width_bytes          : in  std_logic_vector(0 to 3);
        Synch_mem                : in  std_logic;
        Two_pipe_delay           : in  std_logic;
        single_transaction       : in  std_logic;

        -- Parity logic
        parity_error_mem         : out std_logic_vector(0 to 1);
        Parity_enable            : in  std_logic;
        Parity_type              : in  std_logic;
        Parity_err               : out std_logic;

        -- Addr counter mux signal
        Addr_cnt                 : in  std_logic_vector(0 to
                                                          C_ADDR_CNTR_WIDTH-1);
        Addr_align               : in  std_logic;
        Addr_align_rd            : in  std_logic;

        -- IO register signals
        MemSteer_Mem_DQ_I        : in  std_logic_vector
                                                (0 to C_MAX_MEM_WIDTH-1);
        MemSteer_Mem_DQ_O        : out std_logic_vector
                                                (0 to C_MAX_MEM_WIDTH-1);
        MemSteer_Mem_DQ_T        : out std_logic_vector
                                                (0 to C_MAX_MEM_WIDTH-1);

        MemSteer_Mem_DQ_prty_I   : in  std_logic_vector
                                                (0 to C_MAX_MEM_WIDTH/8-1);
        MemSteer_Mem_DQ_prty_O   : out std_logic_vector
                                                (0 to C_MAX_MEM_WIDTH/8-1);
        MemSteer_Mem_DQ_prty_T   : out std_logic_vector
                                                (0 to C_MAX_MEM_WIDTH/8-1);

        MemSteer_Mem_CEN         : out std_logic_vector
                                                (0 to C_NUM_BANKS_MEM-1);
        MemSteer_Mem_OEN         : out std_logic_vector
                                                (0 to C_NUM_BANKS_MEM-1);
        MemSteer_Mem_WEN         : out std_logic;
        MemSteer_Mem_QWEN        : out std_logic_vector
                                                (0 to C_MAX_MEM_WIDTH/8-1);
        MemSteer_Mem_BEN         : out std_logic_vector
                                                (0 to C_MAX_MEM_WIDTH/8-1);
        MemSteer_Mem_CE          : out std_logic_vector
                                                (0 to C_NUM_BANKS_MEM-1);
        MemSteer_Mem_RNW         : out std_logic;


        Bus2IP_RdReq_emc         : in std_logic;
        Bus2IP_WrReq_emc         : in std_logic;

  Write_req_data_ack       : in std_logic;
  Write_req_addr_ack       : in std_logic;
  address_strobe_c         : in std_logic;
        be_strobe_c     	 : in std_logic;
        data_strobe_c   	 : in std_logic;
        ns_idle                  : in std_logic;
        Linear_flash_rd_data_ack : in std_logic;
        Linear_flash_brst_rd_flag : in std_logic;
        last_addr : in std_logic; -- stop_oen
        stop_oen : in std_logic;
        cycle_end: in std_logic;
        axi_arsize: in std_logic_vector(2 downto 0);
        axi_trans_size_reg : in std_logic_vector(1 downto 0)
    );
end entity mem_steer;

-------------------------------------------------------------------------------
-- Architecture section
-------------------------------------------------------------------------------

architecture imp of mem_steer is

----------------------------------------------------------------------------------
-- below attributes are added to reduce the synth warnings in Vivado tool
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of imp : architecture is "yes";
----------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Constant declarations
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Signal declarations
-------------------------------------------------------------------------------
signal mem_cen_cmb            : std_logic;
signal mem_oen_cmb            : std_logic;
signal read_ack_d             : std_logic_vector(0 to 5);
signal read_parity_d          : std_logic_vector(0 to 5);
signal addr_align_d           : std_logic_vector(0 to 5);
signal addr_align_read        : std_logic;
signal write_data             : std_logic_vector(0 to C_IPIF_DWIDTH-1);
signal write_data_cmb         : std_logic_vector(0 to C_MAX_MEM_WIDTH-1);
signal write_data_parity      : std_logic_vector(0 to C_MAX_MEM_WIDTH/8-1);
signal write_data_parity_cmb  : std_logic_vector(0 to C_MAX_MEM_WIDTH/8-1);
signal read_data              : std_logic_vector(0 to C_IPIF_DWIDTH-1);
signal read_parity            : std_logic_vector(0 to C_IPIF_DWIDTH/8-1);
signal write_data_d1          : std_logic_vector(0 to C_MAX_MEM_WIDTH-1);
signal write_data_d2          : std_logic_vector(0 to C_MAX_MEM_WIDTH-1);
signal write_data_parity_d1   : std_logic_vector(0 to C_MAX_MEM_WIDTH/8-1);
signal write_data_parity_d2   : std_logic_vector(0 to C_MAX_MEM_WIDTH/8-1);
signal mem_be_i               : std_logic_vector(0 to C_MAX_MEM_WIDTH/8-1);
signal mem_dq_t_cmb           : std_logic_vector(0 to 3);
signal mem_dq_parity_t_cmb    : std_logic_vector(0 to 3);
signal addr_cnt_d1            : std_logic_vector(0 to C_ADDR_CNTR_WIDTH-1);
signal addr_cnt_d2            : std_logic_vector(0 to C_ADDR_CNTR_WIDTH-1);
signal addr_cnt_d3            : std_logic_vector(0 to C_ADDR_CNTR_WIDTH-1);
signal addr_cnt_d4            : std_logic_vector(0 to C_ADDR_CNTR_WIDTH-1);
signal addr_cnt_sel           : std_logic_vector(0 to C_ADDR_CNTR_WIDTH-1);
signal mem_dqt_t_d            : std_logic;
signal mem_dqt_t_async        : std_logic;
signal mem_dqt_parity_t_d     : std_logic;
signal mem_dqt_parity_t_async : std_logic;
signal Read_req_ack_reg       : std_logic;
signal readreq_th_reset       : std_logic;
signal read_data_ce           : std_logic_vector(0 to 7);
signal read_data_en_d         : std_logic_vector(0 to 4);
signal read_data_en_sel       : std_logic;
signal read_data_cmb          : std_logic_vector(0 to C_MAX_MEM_WIDTH-1);
signal read_data_parity       : std_logic_vector(0 to C_MAX_MEM_WIDTH/8-1);
signal read_data_parity_cmb   : std_logic_vector(0 to C_IPIF_DWIDTH/8-1) := (OTHERS => '0');
signal read_data_parity_int   : std_logic_vector(0 to C_IPIF_DWIDTH/8-1) := (OTHERS => '0');
signal Bus2IP_Mem_CS_del      : std_logic_vector(0 to C_NUM_BANKS_MEM-1);
signal single_par_err : std_logic;
signal single_par_err_int : std_logic;
signal Mem2Bus_RdAck_int : std_logic;
signal Parity_err_int : std_logic;
signal cmb_ored,comp_int : std_logic;
signal arsize_int,arsize_int_e,mem_bytes_int: integer range 0 to 64;
-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------
function "and"  ( l : std_logic_vector; r : std_logic )
return std_logic_vector is
    variable rex : std_logic_vector(l'range);
begin
    rex := (others => r);
    return( l and rex );
end function "and";

function calc_parity  ( data_in : std_logic_vector (0 to 7);
                           Parity_type : std_logic
                        )
        return std_logic is
        variable parity_out_temp: std_logic;
begin
     if Parity_type = '0' then
        parity_out_temp := '0';
        for j in 0 to 7 loop
          parity_out_temp := parity_out_temp XOR data_in(j);
        end loop;
     elsif Parity_type = '1' then
        parity_out_temp := '1';
        for j in 0 to 7 loop
          parity_out_temp := NOT(parity_out_temp XOR data_in(j));
        end loop;
     else
        parity_out_temp := '0';
     end if;
     return parity_out_temp;
end function calc_parity;

function check_parity  ( data_in      : std_logic_vector (0 to 7);
                         parity_bit   : std_logic;
                         Parity_type  : std_logic
                        )
        return std_logic is
        variable parity_result   : std_logic;
        variable parity_out_temp : std_logic;
begin
     if Parity_type = '0' then
        parity_out_temp := '0';
        for j in 0 to 7 loop
          parity_out_temp := parity_out_temp XOR data_in(j);
        end loop;
     elsif Parity_type = '1' then
        parity_out_temp := '1';
        for j in 0 to 7 loop
          parity_out_temp := NOT(parity_out_temp XOR data_in(j));
        end loop;
     else
        parity_out_temp := '0';
     end if;

     if parity_bit= parity_out_temp then
          return '0';
     else
          return '1';
     end if;
end function check_parity;


-------------------------------------------------------------------------------
-- Begin Architecture
-------------------------------------------------------------------------------
signal addr_cnt_numonyx : std_logic;
--attribute IOB                          : string;
--attribute IOB of mem_dqt_t_d           : signal is "true";

begin  -- architecture imp

read_ack_d (5) <= '0';
addr_align_d (5) <= '0';
MemSteer_Mem_BEN   <= not mem_be_i;
MemSteer_Mem_RNW   <= MSM_Mem_WEN;
MemSteer_Mem_QWEN  <= not(mem_be_i and (not MSM_Mem_WEN));
MemSteer_Mem_WEN   <= MSM_Mem_WEN;
Mem2Bus_RdAck <= Mem2Bus_RdAck_int;

 ADDR_CNT_SYNCH_MODE : process(Clk)
    begin
       if(Clk'EVENT and Clk = '1')then
          if(Rst = '1')then
              addr_cnt_numonyx     <=  '0';
          elsif(Linear_flash_brst_rd_flag = '1') then
		if(Read_ack = '1') then
			addr_cnt_numonyx <= not(addr_cnt_numonyx);
                end if;
           end if;
     end if;
    end process ADDR_CNT_SYNCH_MODE;



-------------------------------------------------------------------------------
-- Memory chip enable control generation.
-------------------------------------------------------------------------------

mem_cen_cmb  <= MSM_Mem_CEN;

MEM_CEN_SINGLE_BANK_GEN: if C_NUM_BANKS_MEM = 1 generate
begin
     MemSteer_Mem_CEN(0)  <= mem_cen_cmb; -- 10-12-2012
       --CEN_P: process (stop_oen, synch_mem,mem_cen_cmb) is   -- 10-12-2012
       --begin
       --    if(synch_mem = '1') then
       --          MemSteer_Mem_CEN(0)  <= mem_cen_cmb or stop_oen;
       --    else
       --         MemSteer_Mem_CEN(0)  <= mem_cen_cmb;
       --    end if;
       --end process CEN_P;

    MemSteer_Mem_CE(0)   <= not mem_cen_cmb;
    parity_error_mem     <= "00";
end generate MEM_CEN_SINGLE_BANK_GEN;

-------------------------------------------------------------------------------
-- Generate chip enable signals for multiple memory banks.
-------------------------------------------------------------------------------

MEM_CEN_MULTI_BANK_GEN: if C_NUM_BANKS_MEM > 1 generate
begin

-------------------------------------------------------------------------------
-- Chip enable steer process steers the chip enable to the corresponding memory
-- bank.
-------------------------------------------------------------------------------

MEM_CEN_STEER_PROCESS: process(mem_cen_cmb, Bus2IP_Mem_CS)
    begin
        MemSteer_Mem_CEN  <= (others => '1');
        MemSteer_Mem_CE   <= (others => '0');
  parity_error_mem  <= (others => '0');
        for i in 0 to C_NUM_BANKS_MEM -1 loop
            if(Bus2IP_Mem_CS(i) = '1')then
                MemSteer_Mem_CEN(i)  <= mem_cen_cmb;
                MemSteer_Mem_CE(i)   <= not mem_cen_cmb;
                parity_error_mem     <= conv_std_logic_vector
                                                        (i,2);
            end if;
        end loop;
    end process MEM_CEN_STEER_PROCESS;
end generate MEM_CEN_MULTI_BANK_GEN;


-------------------------------------------------------------------------------
-- Memory output enable control generation.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
------------------------- C_GLOBAL_SYNC_MEM = 1 -------------------------------
-------------------------------------------------------------------------------

SYNC_MEM_OEN : if C_GLOBAL_SYNC_MEM = 1 generate
    signal mem_oen_d            : std_logic_vector(0 to 2);
    signal mem_oen_sync         : std_logic;
begin
    mem_oen_d(0)  <= MSM_Mem_OEN;

-------------------------------------------------------------------------------
-- FDS primitive is used for output enable pipe generation.
-------------------------------------------------------------------------------

    OEN_PIPE_GEN : for i in 0 to 1 generate
    begin
        OEN_PIPE: FDS
            port map (
                Q   => mem_oen_d(i+1), --[out]
                C   => Clk,            --[in]
                D   => mem_oen_d(i),   --[in]
                S   => Rst             --[in]
                );
    end generate OEN_PIPE_GEN;
    mem_oen_sync  <= mem_oen_d(2) and mem_oen_d(1) when (Two_pipe_delay = '1') -- 1/3/2013
                     --mem_oen_d(2) when (Two_pipe_delay = '1') -- 1/3/2013
                     else
                     mem_oen_d(1) and mem_oen_d(0);
    mem_oen_cmb   <= mem_oen_d(0) when (Synch_mem = '0')
                     else
         mem_oen_sync;
end generate SYNC_MEM_OEN;

-------------------------------------------------------------------------------
-- Generate output enable signals when C_GLOBAL_STNC_MEM = 0.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
------------------------- C_GLOBAL_SYNC_MEM = 0 -------------------------------
-------------------------------------------------------------------------------

ASYNC_MEM_OEN : if C_GLOBAL_SYNC_MEM = 0 generate
begin
    mem_oen_cmb  <= MSM_Mem_OEN;
end generate ASYNC_MEM_OEN;

-------------------------------------------------------------------------------
-- Generate output enable signals for multiple memory banks.
-------------------------------------------------------------------------------
MEM_OEN_SINGLE_BANK_GEN: if C_NUM_BANKS_MEM = 1 generate
begin
       --OEN_P: process (stop_oen, synch_mem,mem_oen_cmb) is   -- 10-12-2012
       --begin
       --    if(synch_mem = '1') then
       --          MemSteer_Mem_OEN(0)  <= mem_oen_cmb or stop_oen;
       --    else
       --         MemSteer_Mem_OEN(0)  <= mem_oen_cmb;
       --    end if;
       --end process OEN_P;
    MemSteer_Mem_OEN(0)  <= mem_oen_cmb; -- 10-12-2012
end generate MEM_OEN_SINGLE_BANK_GEN;

-------------------------------------------------------------------------------
-- Generate output enable signals for multiple memory banks.
-------------------------------------------------------------------------------

MEM_OEN_MULTI_BANK_GEN: if C_NUM_BANKS_MEM > 1 generate
begin

-------------------------------------------------------------------------------
-- Output enable steer process is used to steer the output enable to the
-- corresponding memory bank.
-------------------------------------------------------------------------------

    MEM_OEN_STEER_PROCESS: process(mem_oen_cmb, Bus2IP_Mem_CS)
    begin
        MemSteer_Mem_OEN  <= (others => '1');
        for i in 0 to C_NUM_BANKS_MEM -1 loop
            if(Bus2IP_Mem_CS(i) = '1')then
                MemSteer_Mem_OEN(i)  <= mem_oen_cmb;
            end if;
        end loop;
    end process MEM_OEN_STEER_PROCESS;

end generate MEM_OEN_MULTI_BANK_GEN;

-------------------------------------------------------------------------------
-- Address and Data ack generation.
-------------------------------------------------------------------------------

--Mem2Bus_WrAddrAck  <= Write_req_ack and (Bus2IP_WrReq_emc or single_transaction);
--Mem2Bus_WrAck      <= Write_req_ack ;
Mem2Bus_WrAddrAck  <= Write_req_addr_ack and
                      (Bus2IP_WrReq_emc or single_transaction or last_addr);
Mem2Bus_WrAck      <= Write_req_data_ack;

Mem2Bus_RdAddrAck  <= Read_req_ack;-- and Bus2IP_RdReq_emc;
read_ack_d(0)      <= Read_ack;
addr_align_d(0)    <= Addr_align_rd;

-------------------------------------------------------------------------------
-- Geneartion of Mem2Bus_RdAck signal when external memory bank has at least
-- one synchronous memory
-------------------------------------------------------------------------------

GSYNC_MEM_RDACK_GEN : if C_GLOBAL_SYNC_MEM = 1 generate
begin

    ---------------------------------------------------------------------------
    -- Read ack pipe generation.
    ---------------------------------------------------------------------------

    RDACK_PIPE_GEN_SYNC : for i in 0 to 3 generate
    begin
        readreq_th_reset <= ((not Bus2IP_RdReq) and ( not single_transaction))
                                                                or Rst;

    ---------------------------------------------------------------------------
    -- FDR primitive is used for read data ack pipe generation.
    ---------------------------------------------------------------------------
        RDACK_PIPE_SYNC: FDR
            port map (
                Q   => read_ack_d(i+1), --[out]
                C   => Clk,             --[in]
                D   => read_ack_d(i),   --[in]
                R   => readreq_th_reset       --[in]
                );
    end generate RDACK_PIPE_GEN_SYNC;

    NO_PARITY_ACK_SYNC : if (C_PARITY_TYPE_MEMORY=0) generate
        Parity_err <= '0';
    end generate NO_PARITY_ACK_SYNC;

   PARITY_ACK_SYNC : if (C_PARITY_TYPE_MEMORY/=0) generate

    ---------------------------------------------------------------------------
    -- ERR ack pipe generation.
    ---------------------------------------------------------------------------

    ERRACK_PIPE_GEN_SYNC : for i in 0 to 3 generate
    begin
    ---------------------------------------------------------------------------
    -- FDR primitive is used for read data ack pipe generation.
    ---------------------------------------------------------------------------
        ERRACK_PIPE_SYNC: FDR
            port map (
                Q   => read_parity_d(i+1), --[out]
                C   => Clk,             --[in]
                D   => read_parity_d(i),   --[in]
                R   => Rst              --[in]
                );
    end generate ERRACK_PIPE_GEN_SYNC;

    --Parity_err_int         <= read_parity_d(2) when (Synch_mem = '0') else
    --                      read_parity_d(3) when (Synch_mem = '1' and
    --                                            Two_pipe_delay = '0') else
    --                      read_parity_d(4) when (Two_pipe_delay = '1')
    --
    --                      else '0';	--10/25/2010

    COMP_INT_S:process (clk)
    begin
      if clk'event and clk = '1' then
        if arsize_int >= mem_bytes_int then
          comp_int <= '0';
        else
          comp_int <= '1';
        end if;
      end if;
    end process COMP_INT_S;

    MEM2BUS_PARITY_ERR_P: process(read_parity_d(1),
                                  read_parity_d(2),--10/25/2010
                                  read_parity_d(3),
                                  read_parity_d(4),
                                  Synch_mem,
                                  comp_int,
                                  Two_pipe_delay) is
    variable parity_sync_mem_pipe_delay: std_logic_vector(2 downto 0);
    begin
    parity_sync_mem_pipe_delay := comp_int & Synch_mem & Two_pipe_delay;
  case parity_sync_mem_pipe_delay is
    when "000" => Parity_err_int <= read_parity_d(2); -- async mem
    when "001" => Parity_err_int <= read_parity_d(2); -- async mem
    when "010" => Parity_err_int <= read_parity_d(2); --  and read_ack_d(3);--(3); -- sync mem + pipe delay
    when "011" => Parity_err_int <= read_parity_d(4); -- sync mem + pipe delay 2
    when "100" => Parity_err_int <= read_parity_d(1); -- async mem
    when "101" => Parity_err_int <= read_parity_d(1); -- async mem
    when "110" => Parity_err_int <= read_parity_d(1); --  and read_ack_d(3);--(3); -- sync mem + pipe delay
    when "111" => Parity_err_int <= read_parity_d(3); -- sync mem + pipe delay 2
    -- coverage off
    when others => Parity_err_int <= '0';
    -- coverage on
      end case;
    end process MEM2BUS_PARITY_ERR_P;

    arsize_int_e <= conv_integer(axi_arsize);
 PARITY_CALC_32 : if (C_IPIF_DWIDTH = 32) generate
    SIZE_SYN_32: process(CLK)
    begin
     if (clk'event and clk = '1') then
       case axi_arsize is
          when "000"  => 
               cmb_ored <= read_data_parity_cmb(0);
          when "001"  => 
               cmb_ored <= or_reduce(read_data_parity_cmb(0 to 1));
          when "010"  => 
               cmb_ored <= or_reduce(read_data_parity_cmb(0 to 3));
          when OTHERS  => 
               cmb_ored <= read_data_parity_cmb(0);
       end case;
     end if;
    end process SIZE_SYN_32;
 end generate PARITY_CALC_32;

 PARITY_CALC_64 : if (C_IPIF_DWIDTH = 64) generate
    SIZE_SYN_64: process(CLK)
    begin
     if (clk'event and clk = '1') then
       case axi_arsize is
          when "000"  => 
               cmb_ored <= read_data_parity_cmb(0);
          when "001"  => 
               cmb_ored <= or_reduce(read_data_parity_cmb(0 to 1));
          when "010"  => 
               cmb_ored <= or_reduce(read_data_parity_cmb(0 to 3));
          when "011"  => 
               cmb_ored <= or_reduce(read_data_parity_cmb(0 to 7));
          when OTHERS  => 
               cmb_ored <= read_data_parity_cmb(0);
       end case;
     end if;
    end process SIZE_SYN_64;
 end generate PARITY_CALC_64;

    --SIZE_CONV: process(arsize_int)
    --begin
    --   case arsize_int is
    --      when 0  => 
    --           arsize_bytes <= 1;
    --      when 1  => 
    --           arsize_bytes <= 2;
    --      when 2  => 
    --           arsize_bytes <= 4;
    --      when 3  => 
    --           arsize_bytes <= 8;
    --      when 4  => 
    --           arsize_bytes <= 16;
    --      when 5  => 
    --           arsize_bytes <= 32;
    --      when 6  => 
    --           arsize_bytes <= 64;
    --      when OTHERS  => 
    --           arsize_bytes <= 1;
    --   end case;
    --end process SIZE_CONV;

    INT_CONV_SIZE: process(arsize_int_e)
    begin
       case arsize_int_e is
          when 0  => 
               arsize_int <= 1;
          when 1  => 
               arsize_int <= 2;
          when 2  => 
               arsize_int <= 4;
          when 3  => 
               arsize_int <= 8;
          when OTHERS  => 
               arsize_int <= 1;
       end case;
    end process INT_CONV_SIZE;

    INT_CONV: process(Mem_width_bytes)
    begin
       case Mem_width_bytes is
          when "0001"  => 
               mem_bytes_int <= 1;
          when "0010"  => 
               mem_bytes_int <= 2;
          when "0100"  => 
               mem_bytes_int <= 4;
          when "1000"  => 
               mem_bytes_int <= 8;
          when OTHERS  => 
               mem_bytes_int <= 1;
       end case;
    end process INT_CONV;

-------------------------
   --process (read_data_parity_cmb)
   --begin
   --   for i in 0 to arsize_int loop       
   --      read_data_parity_int(i) <= read_data_parity_cmb(i);
   --   end loop;
   --end process;

   process (Clk)
   begin
         if (clk'event and clk = '1') then
            if (Rst = '1') then
               single_par_err <= '0';
            else 
              if (arsize_int >= mem_bytes_int) then
               single_par_err <= or_reduce(read_data_parity_cmb) and single_transaction;
              else
               --single_par_err <= or_reduce(read_data_parity_cmb(0 to arsize_int)) and single_transaction;
               single_par_err <= cmb_ored;
              end if; 
            end if; 
         end if; 
    end process;

   process (Clk)
   begin
         if (clk'event and clk = '1') then
            if (Rst = '1') then
               single_par_err_int <= '0';
            else 
               single_par_err_int <= Mem2Bus_RdAck_int and single_par_err;  
            end if; 
         end if; 
    end process;
   Parity_err <= Parity_err_int or single_par_err_int;
---------------------------

   --read_parity_d(0)   <= -- or_reduce(read_data_parity_cmb) and Read_ack;
   --                     (or_reduce(read_data_parity_cmb)) and (or_reduce(read_data_ce)) and (Bus2IP_RdReq) -- read_ack_d(3))
   --                     when Two_pipe_delay = '0'
   --                     else
   --                     (or_reduce(read_data_parity_cmb) and read_ack_d(4));

   --read_parity_d(0) <= 
   --     (or_reduce(read_data_parity_cmb)) and (or_reduce(read_data_ce)) and (Bus2IP_RdReq) when Two_pipe_delay = '0' else (or_reduce(read_data_parity_cmb) and read_ack_d(4)) 
   --       when arsize_int >= mem_bytes_int else 
   --     ((cmb_ored) and (or_reduce(read_data_ce)) and (Bus2IP_RdReq)) when Two_pipe_delay = '0' else ((cmb_ored) and read_ack_d(4));

   read_parity_d(0) <= 
        (or_reduce(read_data_parity_cmb)) and (or_reduce(read_data_ce)) and (Bus2IP_RdReq) when arsize_int >= mem_bytes_int else ((cmb_ored) and (or_reduce(read_data_ce)) and (Read_ack)) 
          when Two_pipe_delay = '0' else 
        (or_reduce(read_data_parity_cmb) and read_ack_d(4)) when arsize_int >= mem_bytes_int else ((cmb_ored) and read_ack_d(4));
   --process (read_data_ce,
   --         read_data_parity_cmb,
   --         Bus2IP_RdReq,
   --         read_ack_d,
   --         Two_pipe_delay,
   --         read_data_parity_int
   --    )
   --begin
   --    if (arsize_int >= mem_bytes_int) then
   --      if (Two_pipe_delay = '0') then 
   --        read_parity_d(0) <= (or_reduce(read_data_parity_cmb)) and (or_reduce(read_data_ce)) and (Bus2IP_RdReq); -- read_ack_d(3))
   --      else
   --        read_parity_d(0) <= (or_reduce(read_data_parity_cmb) and read_ack_d(4));
   --      end if;
   --    else
   --      if (Two_pipe_delay = '0') then 
   --        read_parity_d(0) <= (cmb_ored) and (or_reduce(read_data_ce)) and (Bus2IP_RdReq); -- read_ack_d(3))
   --      else
   --        read_parity_d(0) <= (cmb_ored) and read_ack_d(4);
   --      end if;
   --    end if;
   --end process;

end generate PARITY_ACK_SYNC;

    --Mem2Bus_RdAck  <= -- read_ack_d(2) when (Synch_mem = '0') else
                      -- read_ack_d(3) when (Synch_mem = '1' and
                      --                   Two_pipe_delay = '0') else
                      -- read_ack_d(4) when (Two_pipe_delay = '1')
                      -- else '0';		      -- 10/25/2010
    MEM2BUS_RD_ACK_P: process(read_ack_d(2),	  -- 10/25/2010
                              read_ack_d(3),
                              read_ack_d(4),
                              Synch_mem, 
			      addr_cnt_numonyx, 
			      Read_ack, 
			      Linear_flash_brst_rd_flag,
                              Two_pipe_delay) is
    variable sync_mem_pipe_delay: std_logic_vector(1 downto 0);
    begin
    sync_mem_pipe_delay := Synch_mem & Two_pipe_delay;
    case sync_mem_pipe_delay is
    when "00" => if (Linear_flash_brst_rd_flag = '0') then
			Mem2Bus_RdAck_int <= read_ack_d(2);
		 else
			Mem2Bus_RdAck_int <= addr_cnt_numonyx and Read_ack;
 		 end if;
    when "01" => if (Linear_flash_brst_rd_flag = '0') then
			Mem2Bus_RdAck_int <= read_ack_d(2);
		 else
			Mem2Bus_RdAck_int <= addr_cnt_numonyx and Read_ack;
		 end if;
    when "10" => if (Linear_flash_brst_rd_flag = '0') then
			Mem2Bus_RdAck_int <= read_ack_d(3);
		 else
			Mem2Bus_RdAck_int <= addr_cnt_numonyx and Read_ack;
		 end if;
    when "11" => if (Linear_flash_brst_rd_flag = '0') then
			Mem2Bus_RdAck_int <= read_ack_d(4);
		 else
			Mem2Bus_RdAck_int <= addr_cnt_numonyx and Read_ack;
		 end if;
    -- coverage off
    when others => Mem2Bus_RdAck_int <= '0';
    -- coverage on
      end case;
    end process MEM2BUS_RD_ACK_P;


    ADDR_ALIGN_PIPE_GEN : for i in 0 to 3 generate
    begin
    ---------------------------------------------------------------------------
    -- FDR primitive is used for Address align pipe generation.
    ---------------------------------------------------------------------------
        ALIGN_PIPE: FDR
        port map (
                Q   => addr_align_d(i+1), --[out]
                C   => Clk,               --[in]
                D   => addr_align_d(i),   --[in]
                R   => Rst                --[in]
               );
        end generate ADDR_ALIGN_PIPE_GEN;


    --addr_align_read      <= addr_align_d(0)when Synch_mem = '0'
    --                        else
    --                        addr_align_d(1) when Synch_mem = '1' and Two_pipe_delay = '0'
    --		              else
    --                        addr_align_d(2);--10/25/2010

    ADDR_ALIGN_READ_P: process(addr_align_d(0),	  -- 10/25/2010
                               addr_align_d(1),
             addr_align_d(2),
                               Synch_mem,
             Two_pipe_delay) is
    variable addr_align_syn_pipe_dly: std_logic_vector(1 downto 0);
    begin
    addr_align_syn_pipe_dly := Synch_mem & Two_pipe_delay;
  case addr_align_syn_pipe_dly is
    when "00" => addr_align_read <= addr_align_d(0);
    when "01" => addr_align_read <= addr_align_d(0);
    when "10" => addr_align_read <= addr_align_d(1);
    when "11" => addr_align_read <= addr_align_d(2);
    -- coverage off
    when others => addr_align_read <=addr_align_d(2);
    -- coverage on
  end case;
    end process ADDR_ALIGN_READ_P;
    ------------------------------

end generate GSYNC_MEM_RDACK_GEN;

-------------------------------------------------------------------------------
-- Geneartion of Mem2Bus_RdAck signal when external memory bank has only
-- asynchronous memory
-------------------------------------------------------------------------------

ASYNC_MEM_RDACK_GEN : if (C_GLOBAL_SYNC_MEM = 0) generate
begin
    ---------------------------------------------------------------------------
    -- Read ack pipe generation.
    ---------------------------------------------------------------------------
    RDACK_PIPE_GEN_ASYNC : for i in 0 to 1 generate

    begin
    ---------------------------------------------------------------------------
    -- FDR primitive is used for read data ack pipe generation.
    ---------------------------------------------------------------------------
        readreq_th_reset <= ((not Bus2IP_RdReq) and ( not single_transaction))
                                                                or Rst;
        RDACK_PIPE_ASYNC: FDR
            port map (
                Q   => read_ack_d(i+1), --[out]
                C   => Clk,             --[in]
                D   => read_ack_d(i),   --[in]
                R   => readreq_th_reset --[in]
                );
    end generate RDACK_PIPE_GEN_ASYNC;

    NO_ASYN_PARITY_ACK_SYNC : if (C_PARITY_TYPE_MEMORY=0) generate
        Parity_err <= '0';
    end generate NO_ASYN_PARITY_ACK_SYNC;

   PARITY_ACK : if (C_PARITY_TYPE_MEMORY/=0) generate

    ---------------------------------------------------------------------------
    -- ERR ack pipe generation.
    ---------------------------------------------------------------------------
    ERRACK_PIPE_GEN_ASYNC : for i in 0 to 1 generate
    begin
    ---------------------------------------------------------------------------
    -- FDR primitive is used for read data ack pipe generation.
    ---------------------------------------------------------------------------
        ERRACK_PIPE_ASYNC: FDR
            port map (
                Q   => read_parity_d(i+1), --[out]
                C   => Clk,             --[in]
                D   => read_parity_d(i),   --[in]
                R   => Rst              --[in]
                );
    end generate ERRACK_PIPE_GEN_ASYNC;

    Parity_err         <= read_parity_d(2);
   end generate PARITY_ACK;

--    Mem2Bus_RdAck      <= read_ack_d(2) when (Linear_flash_brst_rd_flag = '0') else (addr_cnt_numonyx and Read_ack) ;
    ASYNC_MEM_MEM2BUS_RDACK_P: process(read_ack_d(2), 
                                       Linear_flash_brst_rd_flag,
                                       cycle_end,
                                       Read_ack,
                                       axi_trans_size_reg,
                                       addr_cnt_numonyx )is 
    begin
     if(Linear_flash_brst_rd_flag = '0')then  
         Mem2Bus_RdAck_int      <= read_ack_d(2);
     else
         if(axi_trans_size_reg(1) = '0')then -- half word access
             Mem2Bus_RdAck_int      <= cycle_end and Read_ack;
         else
             Mem2Bus_RdAck_int      <= addr_cnt_numonyx and Read_ack;
         end if;
   end if; 
  end process ASYNC_MEM_MEM2BUS_RDACK_P;                          


    ---------------------------------------------------------------------------
    -- ADDR ALLIGN pipe generation.
    ---------------------------------------------------------------------------
    AALIGN_PIPE_GEN : for i in 0 to 1 generate
    begin
    ---------------------------------------------------------------------------
    -- FDR primitive is used for Address align pipe generation.
    ---------------------------------------------------------------------------
        AALIGN_PIPE: FDR
            port map (
                Q   => addr_align_d(i+1), --[out]
                C   => Clk,             --[in]
                D   => addr_align_d(i),   --[in]
                R   => Rst              --[in]
                );
    end generate AALIGN_PIPE_GEN;

    addr_align_read      <= addr_align_d(0);
end generate ASYNC_MEM_RDACK_GEN;

-------------------------------------------------------------------------------
-- Store the data coming from bus, as address ack and data ack is issued early,
-- and to make burst appear as continuous on memory side.
-------------------------------------------------------------------------------

DATA_STORE_GEN: for i in 0 to C_IPIF_DWIDTH - 1 generate
begin

-------------------------------------------------------------------------------
-- FDCE primitive is used for latching Bus2IP_Data when Data_strobe = 1.
-------------------------------------------------------------------------------

    WRDATA_REG: FDRE
        port map (
            Q   => write_data(i),     --[out]
            C   => Clk,               --[in]
            CE  => data_strobe_c,--Data_strobe,       --[in]
            D   => Bus2IP_Data(i),    --[in]
            R   => Rst                --[in]
            );

end generate DATA_STORE_GEN;

-------------------------------------------------------------------------------
-- When one of the memory bank has different data width than OPB/MCH data
-- width, data steering logic is required.
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------- C_GLOBAL_DATAWIDTH_MATCH = 1 ------------------------
-------------------------------------------------------------------------------

WRITE_DATABE_MUX_GEN: if C_GLOBAL_DATAWIDTH_MATCH = 1 generate
begin

-------------------------------------------------------------------------------
-- Write data path
-------------------------------------------------------------------------------
-- Write data mux is used to multiplex write_data out to memories. This will
-- vary on whether the max memory data width is 8, 16, 32 or 64. Separate
-- generate statements are used for each of them. If the memory is synchronous,
-- the BEs assert at the same time. However, the write data  goes out one or
-- two clocks later (depending on Two_pipe_delay). Therefore, separate
-- processes are used for the write data and byte enables.
-------------------------------------------------------------------------------
WRITE_DATABE_MUX_64_GEN: if (C_MAX_MEM_WIDTH=64 and C_IPIF_DWIDTH=64) generate
begin

-------------------------------------------------------------------------------
-- Write data path for 64 bit maximum memory width. Write data mux process is
-- used to multiplex the write_data depending on the addr_cnt.
-------------------------------------------------------------------------------

    WRITE_DATA_MUX_PROCESS_64: process(Mem_width_bytes, Addr_cnt, write_data)
    begin
                    write_data_cmb   <= (others => '0');
                    write_data_parity_cmb <= (others => '0');
       case Mem_width_bytes is
          when "0001"  =>
             for i in 0 to C_IPIF_DWIDTH/C_MIN_MEM_WIDTH -1 loop
                if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then

                    write_data_cmb(0 to C_MIN_MEM_WIDTH-1) <=
                       write_data(i*C_MIN_MEM_WIDTH to
                                  i*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1);
                end if;
             end loop;
          when "0010" =>
              for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*2) -1 loop
                if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then

                    write_data_cmb(0 to 2*C_MIN_MEM_WIDTH-1) <=
                       write_data(i*2*C_MIN_MEM_WIDTH to
                                  i*2*C_MIN_MEM_WIDTH + 2*C_MIN_MEM_WIDTH-1);
                end if;
              end loop;
          when "0100" =>
              for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*4) -1 loop
                if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then

                    write_data_cmb(0 to 4*C_MIN_MEM_WIDTH-1) <=
                        write_data(i*4*C_MIN_MEM_WIDTH to
                                   i*4*C_MIN_MEM_WIDTH + 4*C_MIN_MEM_WIDTH-1);
                end if;
              end loop;
          when "1000" =>

                if Addr_cnt = conv_std_logic_vector(0, C_ADDR_CNTR_WIDTH) then

                    write_data_cmb(0 to C_MAX_MEM_WIDTH-1) <=
                                        write_data(0 to C_MAX_MEM_WIDTH-1);
                end if;

          when others =>
                    write_data_cmb <= (others => '0');
       end case;
    end process WRITE_DATA_MUX_PROCESS_64;

-------------------------------------------------------------------------------
-- Write data path for 64 bit maximum memory width. Write byte enable mux
-- process is used to multiplex the byte enable depending on the addr_cnt.
-------------------------------------------------------------------------------

    WRITE_BE_MUX_PROCESS_64: process(Mem_width_bytes, Addr_cnt, Bus2IP_BE)
    begin
                   mem_be_i      <= (others => '0');
       case Mem_width_bytes is
          when "0001"  =>
             for i in 0 to C_IPIF_DWIDTH/C_MIN_MEM_WIDTH -1 loop
               if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
                   mem_be_i(0 to C_MIN_MEM_WIDTH/8-1) <=
                      Bus2IP_BE(i*C_MIN_MEM_WIDTH/8 to
                                i*C_MIN_MEM_WIDTH/8 + C_MIN_MEM_WIDTH/8-1);
               end if;
             end loop;
          when "0010" =>
             for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*2) -1 loop
               if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
                   mem_be_i(0 to 2*C_MIN_MEM_WIDTH/8-1) <=
                      Bus2IP_BE(i*2*C_MIN_MEM_WIDTH/8 to
                                i*2*C_MIN_MEM_WIDTH/8 + 2*C_MIN_MEM_WIDTH/8-1);
               end if;
             end loop;
          when "0100" =>
             for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*4) -1 loop
               if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
                   mem_be_i(0 to 4*C_MIN_MEM_WIDTH/8-1) <=
                      Bus2IP_BE(i*4*C_MIN_MEM_WIDTH/8 to
                                i*4*C_MIN_MEM_WIDTH/8 + 4*C_MIN_MEM_WIDTH/8-1);
               end if;
             end loop;
          when "1000" =>
               if Addr_cnt = conv_std_logic_vector(0, C_ADDR_CNTR_WIDTH) then
                   mem_be_i(0 to C_MIN_MEM_WIDTH-1) <=
                      Bus2IP_BE(0 to C_MIN_MEM_WIDTH-1);
               end if;
          when others =>
                   mem_be_i   <= (others => '0');
       end case;
    end process WRITE_BE_MUX_PROCESS_64;

    WRITE_PARITY_EN_64_MAX : if (C_PARITY_TYPE_MEMORY/=0) generate
    -- 
    -- WRITE_PARITY_MUX_PROCESS_64: process(Parity_type,
    --                                      Addr_cnt,
    --                                      write_data)
    -- begin
    -- 
    --     write_data_parity_cmb   <= (others => '0');
    -- 
    --     for i in 0 to 7 loop
    --        if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
    --            write_data_parity_cmb (i)<=
    --                     calc_parity(write_data(i*C_MIN_MEM_WIDTH to
    --                          i*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1),
    --                          Parity_type);
    --        end if;
    --     end loop;
    -- 
    -- 
    --     end process WRITE_PARITY_MUX_PROCESS_64;
              WRITE_DATA_PARITY_PROCESS_64: process(Mem_width_bytes, 
                                                    Addr_cnt, 
                                                    write_data_parity_cmb,
                                                    Parity_type,
                                                    write_data,
						    write_data_cmb
                                                    ) is
              begin
                    write_data_parity_cmb   <= (others => '0');
                    --------------
              case Mem_width_bytes is
                    when "0001"  => -- 8 bit memory (need only one Parity Enable bit to active)
                       --for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*4) -1 loop
                       --  if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
                       --      write_data_parity_cmb(0) <=
                       --                 calc_parity(write_data_cmb(i*C_MIN_MEM_WIDTH to
                       --                                            i*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1),
                       --                                            Parity_type);                
                       --      end if;
                       --end loop;
                       write_data_parity_cmb(0) <= calc_parity(write_data_cmb(0 to C_MIN_MEM_WIDTH-1),Parity_type);
                    when "0010" => -- 16 bit memory (need only two Parity Enable bits to active)
                       --for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*2) -1 loop
                       --  if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
                       --      write_data_parity_cmb(i) <=
                       --                 calc_parity(write_data_cmb(i*C_MIN_MEM_WIDTH to
                       --                                            i*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1),
                       --                                            Parity_type);
                       --  end if;
                       --end loop;
		      for i in 0 to 1 loop
				write_data_parity_cmb (i)<=                           
  					 calc_parity(write_data_cmb(i*C_MIN_MEM_WIDTH to  
						                    i*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1), 
							            Parity_type);
	  	      end loop;
                    when "0100" => -- 32 bit memory (need four Parity Enable bits to active)
                       --for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*4) -1 loop
                       --  if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
                       --     write_data_parity_cmb(i) <=
                       --                 calc_parity(write_data_cmb(i*C_MIN_MEM_WIDTH to
                       --                                            i*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1),
                       --                                            Parity_type);
                       --  end if;
                       --end loop;
			for i in 0 to 3 loop
				write_data_parity_cmb (i)<=                           
                                 calc_parity(write_data_cmb(i*C_MIN_MEM_WIDTH to  
                                                            i*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1), 
                                                            Parity_type);
			end loop;
                    
                    when "1000" => -- 64 bit memory (need eight Parity Enable bits to active)
                       --for i in 0 to C_IPIF_DWIDTH/C_MIN_MEM_WIDTH -1 loop
                       --  if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
                       --     write_data_parity_cmb(i) <=
                       --                 calc_parity(write_data_cmb(i*C_MIN_MEM_WIDTH to
                       --                                            i*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1),
                       --                                            Parity_type);
                       --  end if;
                       --end loop;
			for i in 0 to 7 loop
				write_data_parity_cmb (i)<=                           
                                 calc_parity(write_data_cmb(i*C_MIN_MEM_WIDTH to  
                                                            i*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1), 
                                                            Parity_type);
			end loop;
                    
                    
                    
                    -- coverage off
              when others =>
                             write_data_parity_cmb <= (others => '0');
                    -- coverage on
                    end case;
              --------------
          end process WRITE_DATA_PARITY_PROCESS_64;

    end generate WRITE_PARITY_EN_64_MAX;

 end generate WRITE_DATABE_MUX_64_GEN;

-------------------------------------------------------------------------------
-- Write data path
-------------------------------------------------------------------------------
-- Write data mux is used to multiplex write_data out to memories. This will
-- vary on whether the max memory data width is 8, 16, 32 or 64. Separate
-- generate statements are used for each of them. If the memory is synchronous,
-- the BEs assert at the same time. However, the write data  goes out one or
-- two clocks later (depending on Two_pipe_delay). Therefore, separate
-- processes are used for the write data and byte enables.
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- Write data byte enable generation for 32 bit.
-------------------------------------------------------------------------------

WRITE_DATABE_MUX_32_GEN: if (C_MAX_MEM_WIDTH=32) generate
begin

-------------------------------------------------------------------------------
-- Write data path for 32 bit maximum memory width. Write data mux process is
-- used to multiplex the write_data depending on the addr_cnt.
-------------------------------------------------------------------------------

    WRITE_DATA_MUX_PROCESS_32: process(Mem_width_bytes, Addr_cnt, write_data)
    begin
                   write_data_cmb   <= (others => '0');
          case Mem_width_bytes(1 to 3) is
          when "001"  =>
             for i in 0 to C_IPIF_DWIDTH/C_MIN_MEM_WIDTH -1 loop
               if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
                   write_data_cmb(0 to C_MIN_MEM_WIDTH-1) <=
                      write_data(i*C_MIN_MEM_WIDTH to
                                 i*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1);
               end if;
             end loop;
          when "010" =>
             for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*2) -1 loop
               if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
                   write_data_cmb(0 to 2*C_MIN_MEM_WIDTH-1) <=
                      write_data(i*2*C_MIN_MEM_WIDTH to
                                 i*2*C_MIN_MEM_WIDTH + 2*C_MIN_MEM_WIDTH-1);
               end if;
             end loop;
          when "100" =>
             for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*4) -1 loop
               if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
                   write_data_cmb(0 to 4*C_MIN_MEM_WIDTH-1) <=
                      write_data(i*4*C_MIN_MEM_WIDTH to
                                 i*4*C_MIN_MEM_WIDTH + 4*C_MIN_MEM_WIDTH-1);

               end if;
             end loop;
          when others =>
                   write_data_cmb <= (others => '0');
       end case;
    end process WRITE_DATA_MUX_PROCESS_32;

-------------------------------------------------------------------------------
-- Write data path for 32 Bit maximum memory width. Write byte enable mux
-- process is used to multiplex the byte enable depending on the addr_cnt.
-------------------------------------------------------------------------------

    WRITE_BE_MUX_PROCESS_32: process(Mem_width_bytes, Addr_cnt, Bus2IP_BE)
    begin
                   mem_be_i      <= (others => '0');
          case Mem_width_bytes(1 to 3) is
          when "001"  =>
             for i in 0 to C_IPIF_DWIDTH/C_MIN_MEM_WIDTH -1 loop
               if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
                   mem_be_i(0 to C_MIN_MEM_WIDTH/8-1) <=
                      Bus2IP_BE(i*C_MIN_MEM_WIDTH/8 to
                                i*C_MIN_MEM_WIDTH/8 + C_MIN_MEM_WIDTH/8-1);
               end if;
             end loop;
          when "010" =>
             for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*2) -1 loop
               if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
                   mem_be_i(0 to 2*C_MIN_MEM_WIDTH/8-1) <=
                      Bus2IP_BE(i*2*C_MIN_MEM_WIDTH/8 to
                                i*2*C_MIN_MEM_WIDTH/8 + 2*C_MIN_MEM_WIDTH/8-1);
               end if;
             end loop;
          when "100" =>
             for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*4) -1 loop
               if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
                   mem_be_i(0 to 4*C_MIN_MEM_WIDTH/8-1) <=
                      Bus2IP_BE(i*4*C_MIN_MEM_WIDTH/8 to
                                i*4*C_MIN_MEM_WIDTH/8 + 4*C_MIN_MEM_WIDTH/8-1);
               end if;
             end loop;
          when others =>
                  mem_be_i   <= (others => '0');
       end case;
    end process WRITE_BE_MUX_PROCESS_32;

-----------------------------------**--
 WRITE_PARITY_EN_32_MAX : if (C_PARITY_TYPE_MEMORY/=0) generate
 -- 
 --    WRITE_PARITY_MUX_PROCESS_32: process(Parity_type, Addr_cnt, write_data)
 --    begin
 -- 
 --        write_data_parity_cmb   <= (others => '0');
 --  ----------
 --        for i in 0 to 3 loop
 --           if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
 --               write_data_parity_cmb (i)<=
 --                        calc_parity(write_data(i*C_MIN_MEM_WIDTH to
 --                             i*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1),
 --                             Parity_type);
 --           end if;
 --        end loop;
 --  ----------
 --        end process WRITE_PARITY_MUX_PROCESS_32;
   
          -- WRITE_DATA_PARITY_PROCESS_32: process(Mem_width_bytes, 
          --                                       Addr_cnt, 
          --                                       write_data_parity_cmb,
          --                                       Parity_type
          --                                       ) is
          -- begin
          --       write_data_parity_cmb   <= (others => '0');
          --       --------------
          -- case Mem_width_bytes(1 to 3) is
          --       when "001"  => -- 8 bit memory (need only one Parity Enable bit to active)
          --          for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*4) -1 loop
          --            if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
          --                write_data_parity_cmb(0) <=
          --                       calc_parity(write_data_cmb(i*C_MIN_MEM_WIDTH to
          --                                                  i*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1),
          --                                                  Parity_type);                
          --            end if;
          --          end loop;
          --       
          --       when "010" => -- 16 bit memory (need only two Parity Enable bits to active)
          --          for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*2) -1 loop
          --            if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
          --                write_data_parity_cmb(i) <=
          --                       calc_parity(write_data_cmb(i*C_MIN_MEM_WIDTH to
          --                                                  i*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1),
          --                                                  Parity_type);
          --            end if;
          --          end loop;
          --       when "100" => -- 32 bit memory (need four Parity Enable bits to active)
          --          for i in 0 to C_IPIF_DWIDTH/C_MIN_MEM_WIDTH -1 loop
          --            if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
          --               write_data_parity_cmb(i) <=
          --                       calc_parity(write_data_cmb(i*C_MIN_MEM_WIDTH to
          --                                                  i*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1),
          --                                                  Parity_type);
          --            end if;
          --          end loop;
          --       -- coverage off
          -- when others =>
          --                write_data_parity_cmb <= (others => '0');
          --       -- coverage on
          --       end case;
          -- --------------
          -- end process WRITE_DATA_PARITY_PROCESS_32;


    WRITE_DATA_PARITY_PROCESS_32: process(Mem_width_bytes, 
                                          Addr_cnt, 
                                          write_data_cmb,
                                          Parity_type,
                                          write_data
                                          ) is
    -----
    begin
    -----
    write_data_parity_cmb   <= (others => '0');
    --------------
    case Mem_width_bytes(1 to 3) is
          ------------
          when "001" => -- 8 bit memory (need only one Parity Enable bit to active)
             --for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*4) -1 loop
             --  if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
             --      for j in 0  to 1 loop
             --      write_data_parity_cmb(0) <=
             --                 calc_parity(write_data((i*C_MIN_MEM_WIDTH*2 + j*C_MIN_MEM_WIDTH) to
             --                                          (i*C_MIN_MEM_WIDTH*2 + j*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1)),
             --                                        Parity_type);                    
             --      end loop;
             --end if;
             --end loop;
             write_data_parity_cmb(0) <= calc_parity(write_data_cmb(0 to C_MIN_MEM_WIDTH-1),Parity_type);
          ------------   
          when "010" => -- 16 bit memory (need only two Parity Enable bits to active)
             --for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*2) -1 loop
             --  if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
             --     for j in 0  to 1 loop
             --      write_data_parity_cmb(j) <=
             --                   calc_parity(write_data((i*C_MIN_MEM_WIDTH*2 + j*C_MIN_MEM_WIDTH) to
             --                                          (i*C_MIN_MEM_WIDTH*2 + j*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1)),
             --                                          Parity_type);
             --  
             --     end loop; 
             --  end if;
             --end loop;
             for i in 0 to 1 loop
			write_data_parity_cmb (i)<=                           
                                 calc_parity(write_data_cmb(i*C_MIN_MEM_WIDTH to  
                                                            i*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1), 
                                                            Parity_type);
	     end loop;
          ------------
          when "100" => -- 32 bit memory (need four Parity Enable bits to active)
             --for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH) -1 loop
             --  if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
             --     --for j in 0  to 3 loop
             --      write_data_parity_cmb(i) <=
             --                   calc_parity(write_data((i*C_MIN_MEM_WIDTH) to
             --                                          (i*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1)),
             --                                          Parity_type);
             --  
             --     --end loop; 
             --  end if;
             --end loop;
             for i in 0 to 3 loop
			write_data_parity_cmb (i)<=                           
                                 calc_parity(write_data_cmb(i*C_MIN_MEM_WIDTH to  
                                                            i*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1), 
                                                            Parity_type);
	     end loop;
          ------------
          -- coverage off
          when others =>
                   write_data_parity_cmb <= (others => '0');
          -- coverage on
          ------------
          end case;
    --------------
    end process WRITE_DATA_PARITY_PROCESS_32;
    --------------------------------------

 end generate WRITE_PARITY_EN_32_MAX;
 -----------------------------------**--
end generate WRITE_DATABE_MUX_32_GEN;

-------------------------------------------------------------------------------
-- Write data byte enable generation for 16 bit.
-------------------------------------------------------------------------------

WRITE_DATABE_MUX_16_GEN: if C_MAX_MEM_WIDTH=16 generate
begin

-------------------------------------------------------------------------------
-- Write data path for 16 bit maximum memory width. Write data mux process is
-- used to multiplex the write_data depending on the addr_cnt.
-------------------------------------------------------------------------------

    WRITE_DATA_MUX_PROCESS_16: process(Mem_width_bytes, Addr_cnt, write_data)
    begin
          write_data_cmb   <= (others => '0');
          --------------
    case Mem_width_bytes(2 to 3) is
          when "01"  =>
             for i in 0 to C_IPIF_DWIDTH/C_MIN_MEM_WIDTH -1 loop
               if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
                   write_data_cmb(0 to C_MIN_MEM_WIDTH-1) <=
                      write_data(i*C_MIN_MEM_WIDTH to
                                 i*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1);
               end if;
             end loop;
          when "10" =>
             for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*2) -1 loop
               if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
                   write_data_cmb(0 to 2*C_MIN_MEM_WIDTH-1) <=
                      write_data(i*2*C_MIN_MEM_WIDTH to
                                 i*2*C_MIN_MEM_WIDTH + 2*C_MIN_MEM_WIDTH-1);
               end if;
             end loop;
          -- coverage off
    when others =>
                   write_data_cmb <= (others => '0');
          -- coverage on
          end case;
    --------------
    end process WRITE_DATA_MUX_PROCESS_16;

-------------------------------------------------------------------------------
-- Write data path for 16 bit maximum memory width. Write byte enable mux
-- process is  used to multiplex the byte enable depending on the addr_cnt.
-------------------------------------------------------------------------------

    WRITE_BE_MUX_PROCESS_16: process(Mem_width_bytes, Addr_cnt, Bus2IP_BE)
    begin
                   mem_be_i      <= (others => '0');
          case Mem_width_bytes(2 to 3) is
          when "01"  =>
             for i in 0 to C_IPIF_DWIDTH/C_MIN_MEM_WIDTH -1 loop
               if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
                   mem_be_i(0 to C_MIN_MEM_WIDTH/8-1) <=
                      Bus2IP_BE(i*C_MIN_MEM_WIDTH/8 to
                                i*C_MIN_MEM_WIDTH/8 + C_MIN_MEM_WIDTH/8-1);
               end if;
             end loop;
          when "10" =>
             for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*2) -1 loop
               if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
                   mem_be_i(0 to 2*C_MIN_MEM_WIDTH/8-1) <=
                      Bus2IP_BE(i*2*C_MIN_MEM_WIDTH/8 to
                                i*2*C_MIN_MEM_WIDTH/8 + 2*C_MIN_MEM_WIDTH/8-1);
               end if;
             end loop;
          -- coverage off
    when others =>
                   mem_be_i   <= (others => '0');
          -- coverage on
          end case;
    end process WRITE_BE_MUX_PROCESS_16;

    WRITE_PARITY_EN_16_MAX : if (C_PARITY_TYPE_MEMORY/=0) generate
    -- WRITE_PARITY_MUX_PROCESS_16: process(Parity_type, Addr_cnt, write_data)
    -- begin
    -- 
    --     write_data_parity_cmb   <= (others => '0');
    --     --------------------
    -- for i in 0 to 1 loop
    --        if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
    --            write_data_parity_cmb (i)<=
    --                     calc_parity(write_data(i*C_MIN_MEM_WIDTH to
    --                          i*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1),
    --                          Parity_type);
    --        end if;
    --     end loop;
  ---- ------------------
    --     end process WRITE_PARITY_MUX_PROCESS_16;
    
    WRITE_DATA_PARITY_PROCESS_16: process(Mem_width_bytes, 
                                          Addr_cnt, 
                                          write_data_cmb,
                                          Parity_type,
                                          write_data
                                          ) is
    begin
          write_data_parity_cmb   <= (others => '0');
          --------------
    case Mem_width_bytes(2 to 3) is
          ------------
          when "01" => -- 8 bit memory (need only one Parity Enable bit to active)
             --for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*4) -1 loop
               --if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
                   --for j in 0  to 1 loop
                   write_data_parity_cmb(0) <=
                                --calc_parity(write_data_cmb((i*C_MIN_MEM_WIDTH*2 + j*C_MIN_MEM_WIDTH) to
                                --                       (i*C_MIN_MEM_WIDTH*2 + j*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1)),
                                --                       Parity_type);                    
                                calc_parity(write_data_cmb(0 to C_MIN_MEM_WIDTH-1),Parity_type); 
                   --end loop;
               --end if;
             --end loop;
          ------------   
          when "10" => -- 16 bit memory (need only two Parity Enable bits to active)
             for i in 0 to 1 loop
               --if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
                  --for j in 0  to 1 loop
                   --write_data_parity_cmb(j) <=
                                --calc_parity(write_data_cmb((i*C_MIN_MEM_WIDTH*2 + j*C_MIN_MEM_WIDTH) to
                                --                       (i*C_MIN_MEM_WIDTH*2 + j*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1)),
                                --                       Parity_type);
               
                  --end loop; 
                        write_data_parity_cmb (i)<=                           
                                 calc_parity(write_data_cmb(i*C_MIN_MEM_WIDTH to  
                                                            i*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1), 
                                                            Parity_type);                           


               --end if;
             end loop;
          ------------
          -- coverage off
          when others =>
                   write_data_parity_cmb <= (others => '0');
          -- coverage on
          ------------
          end case;
    --------------
    end process WRITE_DATA_PARITY_PROCESS_16;
    
            --      for j in 0 to 1 loop
            --        write_data_parity_cmb(j)<=
            --                  calc_parity(write_data(i*C_MIN_MEM_WIDTH*2 + j*C_MIN_MEM_WIDTH to
            --                  i*C_MIN_MEM_WIDTH*2 + j*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1),
            --                  Parity_type);
            --     end loop;
  end generate WRITE_PARITY_EN_16_MAX; 

end generate WRITE_DATABE_MUX_16_GEN;

-------------------------------------------------------------------------------
-- Write data byte enable generation for 8 bit.
-------------------------------------------------------------------------------

WRITE_DATABE_MUX_8_GEN: if C_MAX_MEM_WIDTH=8 generate
begin

-------------------------------------------------------------------------------
-- Write data path for 8 bit maximum memory width. Write data mux process is
-- used to multiplex the write_data depending on the addr_cnt.
-------------------------------------------------------------------------------

    WRITE_DATA_MUX_PROCESS_8: process(Mem_width_bytes, Addr_cnt, write_data)
    begin
                   write_data_cmb   <= (others => '0');
          --------------
    case Mem_width_bytes(3) is
          when '1'  =>
             for i in 0 to C_IPIF_DWIDTH/C_MIN_MEM_WIDTH -1 loop
               if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
                   write_data_cmb(0 to C_MIN_MEM_WIDTH-1) <=
                      write_data(i*C_MIN_MEM_WIDTH to
                                 i*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1);
               end if;
             end loop;
          -- coverage off
    when others =>
                   write_data_cmb <= (others => '0');
          -- coverage on
          end case;
    ---------------
    end process WRITE_DATA_MUX_PROCESS_8;

-------------------------------------------------------------------------------
-- Write data path for 8 bit maximum memory width. Write byte enable mux
-- process is  used to multiplex the byte enable depending on the addr_cnt.
-------------------------------------------------------------------------------

    WRITE_BE_MUX_PROCESS_8: process(Mem_width_bytes, Addr_cnt, Bus2IP_BE)
    begin
          mem_be_i      <= (others => '0');
          --------------------------
    case Mem_width_bytes(3) is
          when '1'  =>
             for i in 0 to C_IPIF_DWIDTH/C_MIN_MEM_WIDTH -1 loop
               if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
                   mem_be_i(0 to C_MIN_MEM_WIDTH/8-1) <=
                      Bus2IP_BE(i*C_MIN_MEM_WIDTH/8 to
                                i*C_MIN_MEM_WIDTH/8 + C_MIN_MEM_WIDTH/8-1);
               end if;
             end loop;
          -- coverage off
          when others =>
                   mem_be_i   <= (others => '0');
          -- coverage on
          end case;
    --------------------------
    end process WRITE_BE_MUX_PROCESS_8;

    WRITE_PARITY_EN_8_MAX : if (C_PARITY_TYPE_MEMORY/=0) generate

    WRITE_PARITY_MUX_PROCESS_8: process(Parity_type, 
                                        Addr_cnt, 
                                        write_data_parity_cmb,
					write_data_cmb
                                        ) is
    begin

        write_data_parity_cmb   <= (others => '0');

           --for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*4) -1 loop
           --if Addr_cnt = conv_std_logic_vector(i, C_ADDR_CNTR_WIDTH) then
               write_data_parity_cmb (0) <=
                        calc_parity(write_data_cmb(0 to C_MIN_MEM_WIDTH-1),Parity_type);--(i*C_MIN_MEM_WIDTH to
                                                                                        -- i*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1),
                                                                                        -- Parity_type);

           --end if;
           --end loop;
        end process WRITE_PARITY_MUX_PROCESS_8;
    end generate WRITE_PARITY_EN_8_MAX;

end generate WRITE_DATABE_MUX_8_GEN;
end generate WRITE_DATABE_MUX_GEN;

-------------------------------------------------------------------------------
-- When all the memory banks has same data width as OPB/MCH data width,
-- data steering logic is not required.
-------------------------------------------------------------------------------
------------------------- C_GLOBAL_DATAWIDTH_MATCH = 0 ------------------------
-------------------------------------------------------------------------------

WRITE_DATABE_GEN: if C_GLOBAL_DATAWIDTH_MATCH = 0 generate
begin

    write_data_cmb              <= write_data(0 to C_MAX_MEM_WIDTH-1);
    mem_be_i                    <= Bus2IP_BE(0 to C_MAX_MEM_WIDTH/8-1);

    ---------**--
    WRITE_PARITY_EN : if (C_PARITY_TYPE_MEMORY/=0) generate
    begin
      WRITE_PARITY: process(Parity_type, 
                            write_data_cmb
                            ) is
      begin
        for i in 0 to C_MAX_MEM_WIDTH/8 -1 loop
          write_data_parity_cmb (i)<= calc_parity(write_data_cmb(i*C_MIN_MEM_WIDTH to
                                                                 i*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1),
                                                                 Parity_type);
        end loop;
      end process WRITE_PARITY;
    end generate WRITE_PARITY_EN;
    ---------**--
end generate WRITE_DATABE_GEN;

-------------------------------------------------------------------------------
-- Write data generation for synchronous memory.
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------- C_GLOBAL_SYNC_MEM = 1 -------------------------------
-------------------------------------------------------------------------------

SYNC_MEM_WRITE_DATA : if C_GLOBAL_SYNC_MEM = 1 generate
begin

-------------------------------------------------------------------------------
-- Write data pipeline process is used to pipeline write_data_cmb.
-------------------------------------------------------------------------------

    WRITE_DATA_PIPE_PROCESS : process(Clk)
    begin
       if(Clk'EVENT and Clk = '1')then
          if(Rst = '1')then
              write_data_d1        <= (others => '0');
              write_data_d2        <= (others => '0');
              Read_req_ack_reg     <= '0';
          else
              write_data_d1 <= write_data_cmb;
              write_data_d2 <= write_data_d1;
              Read_req_ack_reg  <= Read_req_ack;
          end if;
     end if;
    end process WRITE_DATA_PIPE_PROCESS;


--    PARITY_GEN: if C_GLOBAL_DATAWIDTH_MATCH = 0 generate
--    begin
    ---------------------------------------------------------------------------
    -- Write Parity pipeline process is used to pipeline write_data_cmb
    ---------------------------------------------------------------------------

    WRITE_PARITY_PIPE_PROCESS : process(Clk)
    begin
       if(Clk'EVENT and Clk = '1')then
          if(Rst = '1')then
              write_data_parity_d1 <= (others => '0');
              write_data_parity_d2 <= (others => '0');
          else
              write_data_parity_d1 <= write_data_parity_cmb;
              write_data_parity_d2 <= write_data_parity_d1;
          end if;
     end if;
    end process WRITE_PARITY_PIPE_PROCESS;
--    end generate PARITY_GEN;

-------------------------------------------------------------------------------
-- Write data process is used to multiplex the write data on the memory
-- depending on the type of memory.
-------------------------------------------------------------------------------

    WRITE_DATA_PROCESS: process(write_data_cmb, Synch_mem, Two_pipe_delay,
                                write_data_parity_cmb, write_data_parity_d2,
                                write_data_parity_d1, write_data_d1,
                                write_data_d2)
    begin
       if Synch_mem = '1' then
          if Two_pipe_delay = '1' then
              MemSteer_Mem_DQ_O       <= write_data_d2;
              MemSteer_Mem_DQ_prty_O  <= write_data_parity_d2;
          else
              MemSteer_Mem_DQ_O       <= write_data_d1;
              MemSteer_Mem_DQ_prty_O  <= write_data_parity_d1;
          end if;
       else
          MemSteer_Mem_DQ_O       <= write_data_cmb;
          MemSteer_Mem_DQ_prty_O  <= write_data_parity_cmb;
       end if;
    end process WRITE_DATA_PROCESS;

end generate SYNC_MEM_WRITE_DATA;

-------------------------------------------------------------------------------
-- Memory write data generation for asynchronous memory.
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------- C_GLOBAL_SYNC_MEM = 0 -------------------------------
-------------------------------------------------------------------------------

ASYNC_MEM_WRITE_DATA : if C_GLOBAL_SYNC_MEM = 0 generate
begin
    MemSteer_Mem_DQ_O       <= write_data_cmb;
    MemSteer_Mem_DQ_prty_O  <= write_data_parity_cmb;
end generate ASYNC_MEM_WRITE_DATA;

-------------------------------------------------------------------------------
-- Memory data bus high impedance buffer control.
-------------------------------------------------------------------------------

mem_dq_t_cmb(0) <= MSM_Mem_WEN;
mem_dqt_t_async <= MSM_Mem_WEN and mem_dqt_t_d;


ASYNC_PARITY_MEM_WRITE: if C_PARITY_TYPE_MEMORY /= 0 generate
begin
        mem_dq_parity_t_cmb(0)  <= MSM_Mem_WEN;
        mem_dqt_parity_t_async  <= MSM_Mem_WEN and mem_dqt_parity_t_d;
end generate ASYNC_PARITY_MEM_WRITE;


-------------------------------------------------------------------------------
-- Asynchronous memory DQT process is used to generate impedance control
-- signal.
-------------------------------------------------------------------------------

MEM_DQT_D_ASYNC_PROCESS: process(Clk)
begin
    if Clk'event and Clk = '1' then
       if Rst = '1' then
          mem_dqt_t_d           <= '1';
          mem_dqt_parity_t_d    <= '1';
       else
          mem_dqt_t_d           <= MSM_Mem_WEN;
          mem_dqt_parity_t_d    <= MSM_Mem_WEN;
       end if;
    end if;
end process MEM_DQT_D_ASYNC_PROCESS;

-------------------------------------------------------------------------------
-- Impedance generation for synchronous memory.
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------- C_GLOBAL_SYNC_MEM = 1 -------------------------------
-------------------------------------------------------------------------------

SYNC_MEM_DQT : if C_GLOBAL_SYNC_MEM = 1 generate
begin

    REG_DQT_GEN : for i in 0 to 2 generate
    begin

-------------------------------------------------------------------------------
-- FDS primitive is used for mem_dq_t_cmb pipe generation.
-------------------------------------------------------------------------------

        DQT_REG: FDS
        port map (
            Q   => mem_dq_t_cmb(i+1), --[out]
            C   => Clk,               --[in]
            D   => mem_dq_t_cmb(i),   --[in]
            S   => Rst                --[in]
            );
    end generate REG_DQT_GEN;

-------------------------------------------------------------------------------
-- Memory dqt process is used to multiplex the impeadance control signal on to
-- the memory depending on the type of memory.
-------------------------------------------------------------------------------

    MEM_DQT_PROCESS_SYNC: process(Synch_mem, Two_pipe_delay, mem_dq_t_cmb,
                             mem_dqt_t_async)
    begin
        MemSteer_Mem_DQ_T <= (others => '1');
        for i in 0 to C_MAX_MEM_WIDTH-1 loop
          if(Synch_mem = '1')then
              if(Two_pipe_delay = '1')then
                  MemSteer_Mem_DQ_T(i) <= mem_dq_t_cmb(2);
              else
                  MemSteer_Mem_DQ_T(i) <= mem_dq_t_cmb(1);
              end if;
          else
              MemSteer_Mem_DQ_T(i) <= mem_dqt_t_async;
          end if;
        end loop;
    end process MEM_DQT_PROCESS_SYNC;


  SYNC_PARITY_MEM_WRITE_DQT: if C_PARITY_TYPE_MEMORY /= 0 generate
  begin
    REG_DQT_PARITY_GEN : for i in 0 to 2 generate
    begin

-------------------------------------------------------------------------------
-- FDS primitive is used for mem_dq_t_cmb pipe generation.
-------------------------------------------------------------------------------

        DQT_REG: FDS
        port map (
            Q   => mem_dq_parity_t_cmb(i+1), --[out]
            C   => Clk,               --[in]
            D   => mem_dq_parity_t_cmb(i),   --[in]
            S   => Rst                --[in]
            );
    end generate REG_DQT_PARITY_GEN;

-------------------------------------------------------------------------------
-- Memory dqt process is used to multiplex the impeadance control signal on to
-- the memory depending on the type of memory.
-------------------------------------------------------------------------------

    MEM_DQT_PARITY_PROCESS_SYNC: process(Synch_mem, 
                                         Two_pipe_delay,
                                         mem_dq_parity_t_cmb,
					 mem_dqt_parity_t_async
					 ) is
    begin
        MemSteer_Mem_DQ_prty_T <= (others => '1');
        for i in 0 to C_MAX_MEM_WIDTH/8-1 loop
          if(Synch_mem = '1')then
              if(Two_pipe_delay = '1')then
                  MemSteer_Mem_DQ_prty_T(i) <= mem_dq_parity_t_cmb(2);
              else
                  MemSteer_Mem_DQ_prty_T(i) <= mem_dq_parity_t_cmb(1);
              end if;
          else
              MemSteer_Mem_DQ_prty_T(i) <= mem_dqt_parity_t_async;
          end if;
        end loop;
    end process MEM_DQT_PARITY_PROCESS_SYNC;
  end generate SYNC_PARITY_MEM_WRITE_DQT;

end generate SYNC_MEM_DQT;

-------------------------------------------------------------------------------
-- Impedance generation for asynchronous memory.
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------- C_GLOBAL_SYNC_MEM = 0 -------------------------------
-------------------------------------------------------------------------------

ASYNC_MEM_DQT : if C_GLOBAL_SYNC_MEM = 0 generate
begin

-------------------------------------------------------------------------------
-- Memory dqt process is used to generate impeadance control signal on to
-- the memory.
-------------------------------------------------------------------------------

    MEM_DQT_PROCESS_ASYNC: process(mem_dqt_t_async)
    begin
        for i in 0 to C_MAX_MEM_WIDTH-1 loop
          MemSteer_Mem_DQ_T(i) <= mem_dqt_t_async;
        end loop;
    end process MEM_DQT_PROCESS_ASYNC;

-------------------------------------------------------------------------------
-- Memory PARITY dqt process is used to generate impeadance control signal on
-- to the memory.
-------------------------------------------------------------------------------

   ASYNC_PARITY_MEM_WRITE_DQT: if C_PARITY_TYPE_MEMORY /= 0 generate
   begin
      MEM_PARITY_DQT_PROCESS_ASYNC: process(mem_dqt_parity_t_async)
      begin
        for i in 0 to C_MAX_MEM_WIDTH/8-1 loop
          MemSteer_Mem_DQ_prty_T(i) <= mem_dqt_parity_t_async;
        end loop;
      end process MEM_PARITY_DQT_PROCESS_ASYNC;
   end generate ASYNC_PARITY_MEM_WRITE_DQT;

end generate ASYNC_MEM_DQT;



-------------------------------------------------------------------------------
-- Read data path.
-- Read data and byte enable generation.
-------------------------------------------------------------------------------

RDDATA_GEN: for j in 0 to C_IPIF_DWIDTH/C_MIN_MEM_WIDTH - 1 generate
begin

    RDDATA_BYTE_GEN:for i in 0 to C_MIN_MEM_WIDTH - 1 generate
    begin

-------------------------------------------------------------------------------
-- FDCE primitive is used for latching read_data when read_data_ce = 1.
-------------------------------------------------------------------------------

        RDDATA_REG: FDRE
        port map (
            Q   => Mem2Bus_Data(C_MIN_MEM_WIDTH*j+i), --[out]
            C   => Clk,                               --[in]
            CE  => read_data_ce(j),                   --[in]
            D   => read_data(C_MIN_MEM_WIDTH*j+i),    --[in]
            R   => RST                            --[in]
            );
    end generate RDDATA_BYTE_GEN;
end generate RDDATA_GEN;


-------------------------------------------------------------------------------
------------------------- C_GLOBAL_DATAWIDTH_MATCH = 0 ------------------------
-------------------------------------------------------------------------------

RDDATA_PATH_GEN : if C_GLOBAL_DATAWIDTH_MATCH = 0 generate
begin
    read_data    <= MemSteer_Mem_DQ_I;
    read_data_ce <= (others=>'1');

    READ_PARITY_EN : if (C_PARITY_TYPE_MEMORY/=0) generate
    begin
      READ_PARITY: process(MemSteer_Mem_DQ_I,
                           Parity_type,
                           read_ack_d,
                           MemSteer_Mem_DQ_prty_I
                           ) is
      begin
        -- default assignment
        --read_parity <= (others => '0');
    if (read_ack_d(2) = '1') then
        for i in 0 to C_MAX_MEM_WIDTH/8 -1 loop

          read_data_parity_cmb (i)<= check_parity(MemSteer_Mem_DQ_I(i*C_MIN_MEM_WIDTH to 
                                                                    i*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1),
                                                                    MemSteer_Mem_DQ_prty_I(i),
                                                                    Parity_type);
        end loop;
    else
        read_data_parity_cmb <= (OTHERS => '0');
    end if;
      end process READ_PARITY;
    end generate READ_PARITY_EN;


end generate RDDATA_PATH_GEN;

-------------------------------------------------------------------------------
------------------------- C_GLOBAL_DATAWIDTH_MATCH = 1 ------------------------
-------------------------------------------------------------------------------

RDDATA_PATH_MUX_GEN : if C_GLOBAL_DATAWIDTH_MATCH = 1 generate
begin

-------------------------------------------------------------------------------
------------------------- C_GLOBAL_SYNC_MEM = 1 -------------------------------
-------------------------------------------------------------------------------

    SYNC_ADDR_CNT_GEN: if C_GLOBAL_SYNC_MEM = 1 generate
    begin

-------------------------------------------------------------------------------
-- Address count pipeline process is used to pipeline address count.
-------------------------------------------------------------------------------

        ADDR_CNT_PIPE_PROCESS_SYN: process(Clk)
        begin
          if Clk'event and Clk = '1' then
              if Rst = '1' then
                  addr_cnt_d1 <= (others => '0');
                  addr_cnt_d2 <= (others => '0');
                  addr_cnt_d3 <= (others => '0');
                  addr_cnt_d4 <= (others => '0');
              else
                if Bus2IP_RdReq = '1' or single_transaction = '1' then
                  addr_cnt_d1 <= Addr_cnt;
                  addr_cnt_d2 <= addr_cnt_d1;
                  addr_cnt_d3 <= addr_cnt_d2;
                  addr_cnt_d4 <= addr_cnt_d3;
                else
                  addr_cnt_d1 <= (others => '0');
                  addr_cnt_d2 <= (others => '0');
                  addr_cnt_d3 <= (others => '0');
                  addr_cnt_d4 <= (others => '0');
                end if;
             end if;
          end if;
        end process ADDR_CNT_PIPE_PROCESS_SYN;

-------------------------------------------------------------------------------
-- Synchonous address counter process is used to multiplex the address counter
-- select signal depending on the type of memory.
-------------------------------------------------------------------------------

        SYNC_ADDR_CNT_PROCESS: process(ns_idle,
                                       Synch_mem,
                                       Two_pipe_delay,
                                       addr_cnt_d2,
                                       addr_cnt_d3,
                                       addr_cnt_d4)
        begin
          if (ns_idle='0') then
             if Synch_mem = '1' then
                if Two_pipe_delay = '1' then
                    addr_cnt_sel <= addr_cnt_d4;
                else
                    addr_cnt_sel <= addr_cnt_d3;
                end if;
             else
                 addr_cnt_sel <= addr_cnt_d2;
             end if;
          else
              addr_cnt_sel <= (others => '0');
          end if;
        end process SYNC_ADDR_CNT_PROCESS;

---------------------------- Read Data Enable Logic ---------------------------

    read_data_en_d(0)  <= Read_data_en;

    RDDATA_EN_GEN_SYNC: for i in 0 to 3 generate
    begin

-------------------------------------------------------------------------------
-- FDR primitive is used for read_data_en_d pipe generation.
-------------------------------------------------------------------------------

        RDDATA_EN_REG_SYNC: FDR
            port map (
                Q   => read_data_en_d(i+1),          --[out]
                C   => Clk,                          --[in]
                D   => read_data_en_d(i),            --[in]
                R   => Rst                           --[in]
                );
    end generate RDDATA_EN_GEN_SYNC;

-------------------------------------------------------------------------------
-- Read data enable select process is used to multiplex the read data enable
-- depending on the type of memory.
-------------------------------------------------------------------------------

        READ_DATA_EN_SEL_PROCESS: process(read_data_en_d, Synch_mem,
                                          Two_pipe_delay)
        begin
          if Synch_mem = '1' then
              if Two_pipe_delay = '1' then
                  read_data_en_sel <= read_data_en_d(3);
              else
                  read_data_en_sel <= read_data_en_d(2);
              end if;
          else
              read_data_en_sel     <= read_data_en_d(1);
          end if;
        end process READ_DATA_EN_SEL_PROCESS;

    end generate SYNC_ADDR_CNT_GEN;

-------------------------------------------------------------------------------
-- Address count select generation for asynchronous memory.
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------- C_GLOBAL_SYNC_MEM = 0 -------------------------------
-------------------------------------------------------------------------------

    ASYNC_ADDR_CNT_GEN: if C_GLOBAL_SYNC_MEM = 0 generate
    begin

-------------------------------------------------------------------------------
-- Address count pipeline process is used to pipeline address count.
-------------------------------------------------------------------------------

        ADDR_CNT_PIPE_PROCESS_ASYNC: process(Clk)
        begin
          if Clk'event and Clk = '1' then
              if ((Rst = '1') or (ns_idle='1')) then
                  addr_cnt_d1 <= (others => '0');
                  addr_cnt_d2 <= (others => '0');
              else
                  addr_cnt_d1 <= Addr_cnt;
                  addr_cnt_d2 <= addr_cnt_d1;
             end if;
          end if;
        end process ADDR_CNT_PIPE_PROCESS_ASYNC;

        addr_cnt_sel      <= addr_cnt_d2;

---------------------------- Read Data Enable Logic ---------------------------

        read_data_en_d(0)  <= Read_data_en;
        read_data_en_sel   <= read_data_en_d(1);

    RDDATA_EN_GEN_ASYNC: for i in 0 to 3 generate
    begin

-------------------------------------------------------------------------------
-- FDR primitive is used for read_data_en_d pipe generation.
-------------------------------------------------------------------------------

            RDDATA_EN_REG_ASYNC: FDR
            port map (
                    Q   => read_data_en_d(i+1),      --[out]
                    C   => Clk,                      --[in]
                    D   => read_data_en_d(i),        --[in]
                    R   => Rst                       --[in]
                    );
    end generate RDDATA_EN_GEN_ASYNC;
    end generate ASYNC_ADDR_CNT_GEN;


-------------------------------------------------------------------------------
-- Read Data CE generation For 64 Bit DWidth.
-------------------------------------------------------------------------------

    READ_DATA_CE_64_GEN: if C_IPIF_DWIDTH = 64 generate
    begin
--signal test :std_logic_vector(0 downto 7);
--test <= read_data_ce(conv_integer(addr_cnt_sel)*4+i);
-------------------------------------------------------------------------------
-- Read data CE process is used to generate read data chip enable for 64 Bit
-- DWidth.
-------------------------------------------------------------------------------

        READ_DATA_CE_PROCESS_64: process(read_data_en_sel,
                                         addr_cnt_sel,
                                         single_transaction,
                                         Bus2IP_RdReq,
                                         Mem_width_bytes,
                                         Linear_flash_brst_rd_flag,
                                         Linear_flash_rd_data_ack,
					                          addr_cnt_numonyx
                                        ) is
        begin
                read_data_ce  <= (others => '0');
         if Bus2IP_RdReq = '1' or single_transaction = '1' then
          case Mem_width_bytes is
             when "0001"  =>
                read_data_ce(conv_integer(addr_cnt_sel))
                   <= read_data_en_sel;
             when "0010" =>
               for i in 0 to 1 loop
                --read_data_ce(conv_integer(addr_cnt_sel)*2+i)
                --   <= read_data_en_sel;
                        if(Linear_flash_brst_rd_flag = '0') then
			            read_data_ce(conv_integer(addr_cnt_sel)*2+i)
                   		           <= read_data_en_sel;
		        else
			            read_data_ce(conv_integer(addr_cnt_numonyx)*2+i)
                   		           <=  Linear_flash_rd_data_ack;--read_data_en_sel;
		        end if;
               end loop;
             when "0100" =>
               for i in 0 to 3 loop
                read_data_ce(conv_integer(addr_cnt_sel)*4+i)
                   <= read_data_en_sel;
               end loop;
             when "1000" =>
               for i in 0 to 7 loop
                read_data_ce(i)  <= read_data_en_sel;
               end loop;
            -- coverage off
            when others =>
                read_data_ce <= (others => '0');
            -- coverage on
          end case;
         end if;
        end process READ_DATA_CE_PROCESS_64;

    end generate READ_DATA_CE_64_GEN;


-------------------------------------------------------------------------------
-- Read data CE generation For 32 Bit DWidth.
-------------------------------------------------------------------------------

    READ_DATA_CE_32_GEN: if C_IPIF_DWIDTH = 32 generate
    begin

-------------------------------------------------------------------------------
-- Read data CE process is used to generate read data chip enable for 32 Bit
-- DWidth.
-------------------------------------------------------------------------------

        READ_DATA_CE_PROCESS_32: process(Mem_width_bytes, 
	                                      addr_cnt_sel, 
					                          addr_cnt_numonyx,
                                         read_data_en_sel, 
					                          Linear_flash_brst_rd_flag, 
					                          Linear_flash_rd_data_ack
					                          ) is
        begin
                read_data_ce  <= (others => '0');
          case Mem_width_bytes is
             when "0001"  =>
                read_data_ce(conv_integer(addr_cnt_sel))
                   <= read_data_en_sel ;  -- and not(Linear_flash_brst_rd_flag)) or (Linear_flash_brst_rd_flag and Linear_flash_rd_data_ack);
             when "0010" =>
               for i in 0 to 1 loop
                if(Linear_flash_brst_rd_flag = '0') then
			            read_data_ce(conv_integer(addr_cnt_sel)*2+i)
                   		           <= read_data_en_sel;
		        else
			            read_data_ce(conv_integer(addr_cnt_numonyx)*2+i)
                   		           <=  Linear_flash_rd_data_ack;--read_data_en_sel;
		        end if;
               end loop;
             when "0100" =>
               for i in 0 to 3 loop
                read_data_ce(i)  <= read_data_en_sel ;--and not(Linear_flash_brst_rd_flag)) or (Linear_flash_brst_rd_flag and Linear_flash_rd_data_ack);--read_data_en_sel;
               end loop;
          -- coverage off
       when others =>
                read_data_ce <= (others => '0');
          -- coverage on
          end case;
        end process READ_DATA_CE_PROCESS_32;

    end generate READ_DATA_CE_32_GEN;


-------------------------------------------------------------------------------
-- Read Data Path For 64 Bit Maximum Memory Width.
-------------------------------------------------------------------------------

    READ_DATA_64_GEN: if (C_MAX_MEM_WIDTH=64 and C_IPIF_DWIDTH=64) generate
    begin

-------------------------------------------------------------------------------
-- Read data process is used to generate read data for 64 Bit DWidth.
-------------------------------------------------------------------------------

       READ_DATA_PROCESS_64_64: process(Mem_width_bytes, MemSteer_Mem_DQ_I )
       begin
                   read_data     <= (others => '0');
          case Mem_width_bytes is
             when "0001"  =>
               -- create the input data
               for i in 0 to C_IPIF_DWIDTH/C_MIN_MEM_WIDTH -1 loop
                   read_data(i*C_MIN_MEM_WIDTH to
                             i*C_MIN_MEM_WIDTH+C_MIN_MEM_WIDTH-1)
                      <= MemSteer_Mem_DQ_I(0 to C_MIN_MEM_WIDTH-1);
               end loop;
             when "0010" =>
               -- create the input data
               for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*2) -1 loop
                   read_data(i*C_MIN_MEM_WIDTH*2 to
                             i*C_MIN_MEM_WIDTH*2+C_MIN_MEM_WIDTH*2-1)
                      <= MemSteer_Mem_DQ_I(0 to C_MIN_MEM_WIDTH*2-1);
               end loop;
             when "0100" =>
               -- create the input data
               for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*4) -1 loop
                   read_data(i*C_MIN_MEM_WIDTH*4 to
                             i*C_MIN_MEM_WIDTH*4+C_MIN_MEM_WIDTH*4-1)
                      <= MemSteer_Mem_DQ_I(0 to C_MIN_MEM_WIDTH*4-1);
               end loop;
             when "1000" =>
                   read_data <= MemSteer_Mem_DQ_I;
          -- coverage off
             when others =>
                   read_data <= (others => '0');
          -- coverage on
          end case;
        end process READ_DATA_PROCESS_64_64;

      READ_PARITY_EN_64_MAX : if (C_PARITY_TYPE_MEMORY/=0) generate

        READ_PRTY_PROCESS_64: process(Mem_width_bytes, MemSteer_Mem_DQ_prty_I)
        begin
                   read_parity <= (others => '0');
          case Mem_width_bytes is
             when "0001"  =>
               -- create the input data
               for i in 0 to C_IPIF_DWIDTH/C_MIN_MEM_WIDTH -1 loop
                   read_parity(i*C_MIN_MEM_WIDTH/8 to
                             i*C_MIN_MEM_WIDTH/8+C_MIN_MEM_WIDTH/8-1)
                      <= MemSteer_Mem_DQ_prty_I(0 to C_MIN_MEM_WIDTH/8-1);
               end loop;
             when "0010" =>
               -- create the input data
               for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*2) -1 loop
                   read_parity(i*C_MIN_MEM_WIDTH*2/8 to
                             i*C_MIN_MEM_WIDTH*2/8+C_MIN_MEM_WIDTH*2/8-1)
                      <= MemSteer_Mem_DQ_prty_I(0 to C_MIN_MEM_WIDTH*2/8-1);
               end loop;
             when "0100" =>
               -- create the input data
               for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*4) -1 loop
                   read_parity(i*C_MIN_MEM_WIDTH*4/8 to
                             i*C_MIN_MEM_WIDTH*4/8+C_MIN_MEM_WIDTH*4/8-1)
                      <= MemSteer_Mem_DQ_prty_I(0 to C_MIN_MEM_WIDTH*4/8-1);
               end loop;
             when "1000" =>
                   read_parity <= MemSteer_Mem_DQ_prty_I;
             when others =>
                   read_parity <= (others => '0');
          end case;

        end process READ_PRTY_PROCESS_64;

        READ_PARITY_MUX_PROCESS_64: process(MemSteer_Mem_DQ_I,
                                            Parity_type,
                                            Bus2IP_BE,
                                            read_ack_d,
                                            MemSteer_Mem_DQ_prty_I)
        begin
            read_data_parity_cmb   <= (others => '0');
    if (read_ack_d(2) = '1') then
                for i in 0 to 7 loop
                  --if Bus2IP_BE(i) = '1' then
                   read_data_parity_cmb (i)<= check_parity(MemSteer_Mem_DQ_I
                                        (i*C_MIN_MEM_WIDTH to i*C_MIN_MEM_WIDTH
                                        + C_MIN_MEM_WIDTH-1),
                                        MemSteer_Mem_DQ_prty_I(i),
                                        Parity_type);
                  --end if;
                end loop;
    else
        read_data_parity_cmb <= (OTHERS => '0');                
    end if;
        end process READ_PARITY_MUX_PROCESS_64;
      end generate READ_PARITY_EN_64_MAX;

    end generate READ_DATA_64_GEN;


-------------------------------------------------------------------------------
-- Read data path For 32 bit maximum memory width.
-------------------------------------------------------------------------------

    READ_DATA_32_GEN: if (C_MAX_MEM_WIDTH=32) generate
    begin

-------------------------------------------------------------------------------
-- Read data process is used to generate read data for 32 bit DWidth.
-------------------------------------------------------------------------------

        READ_DATA_PROCESS_32: process(Mem_width_bytes, MemSteer_Mem_DQ_I)
        begin
                   read_data <= (others => '0');
          case Mem_width_bytes(1 to 3) is
             when "001"  =>
               -- create the input data
               for i in 0 to C_IPIF_DWIDTH/C_MIN_MEM_WIDTH -1 loop
                   read_data(i*C_MIN_MEM_WIDTH to
                             i*C_MIN_MEM_WIDTH+C_MIN_MEM_WIDTH-1)
                      <= MemSteer_Mem_DQ_I(0 to C_MIN_MEM_WIDTH-1);
               end loop;
             when "010" =>
               -- create the input data
               for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*2)-1 loop
                   read_data(i*C_MIN_MEM_WIDTH*2 to
                             i*C_MIN_MEM_WIDTH*2+C_MIN_MEM_WIDTH*2-1)
                      <= MemSteer_Mem_DQ_I(0 to C_MIN_MEM_WIDTH*2-1);
               end loop;
             when "100" =>
               -- create the input data
               for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*4)-1 loop
                   read_data(i*C_MIN_MEM_WIDTH*4 to
                             i*C_MIN_MEM_WIDTH*4+C_MIN_MEM_WIDTH*4-1)
                      <= MemSteer_Mem_DQ_I(0 to C_MIN_MEM_WIDTH*4-1);
               end loop;
          -- coverage off
             when others =>
                   read_data <= (others => '0');
          -- coverage on
          end case;
        end process READ_DATA_PROCESS_32;

      READ_PARITY_EN_32_MAX : if (C_PARITY_TYPE_MEMORY/=0) generate

        READ_PRTY_PROCESS_32: process(Mem_width_bytes, MemSteer_Mem_DQ_prty_I)
        begin
                   read_parity <= (others => '0');
          case Mem_width_bytes(1 to 3) is
             when "001"  =>
               -- create the input data
               for i in 0 to C_IPIF_DWIDTH/C_MIN_MEM_WIDTH -1 loop
                   read_parity(i*C_MIN_MEM_WIDTH/8 to
                             i*C_MIN_MEM_WIDTH/8+C_MIN_MEM_WIDTH/8-1)
                      <= MemSteer_Mem_DQ_prty_I(0 to C_MIN_MEM_WIDTH/8-1);
               end loop;
             when "010" =>
               -- create the input data
               for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*2)-1 loop
                   read_parity(i*C_MIN_MEM_WIDTH*2/8 to
                             i*C_MIN_MEM_WIDTH*2/8+C_MIN_MEM_WIDTH*2/8-1)
                      <= MemSteer_Mem_DQ_prty_I(0 to C_MIN_MEM_WIDTH*2/8-1);
               end loop;
             when "100" =>
               -- create the input data
               for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*4)-1 loop
                   read_parity(i*C_MIN_MEM_WIDTH*4/8 to
                             i*C_MIN_MEM_WIDTH*4/8+C_MIN_MEM_WIDTH*4/8-1)
                      <= MemSteer_Mem_DQ_prty_I(0 to C_MIN_MEM_WIDTH*4/8-1);
               end loop;
          -- coverage off
             when others =>
                   read_parity <= (others => '0');
          -- coverage on
          end case;
        end process READ_PRTY_PROCESS_32;

        READ_PARITY_MUX_PROCESS_32: process(MemSteer_Mem_DQ_I,
                                            Parity_type,
                                            MemSteer_Mem_DQ_prty_I,
                                            read_ack_d,
                                            Bus2IP_BE)
        begin

            read_data_parity_cmb   <= (others => '0');
    if (read_ack_d(2) = '1') then
                for i in 0 to 3 loop
                  --if Bus2IP_BE(i) = '1' then
                   read_data_parity_cmb (i)<= check_parity(MemSteer_Mem_DQ_I
                                        (i*C_MIN_MEM_WIDTH to i*C_MIN_MEM_WIDTH
                                        + C_MIN_MEM_WIDTH-1),
                                        MemSteer_Mem_DQ_prty_I(i),
                                        Parity_type);
                  --end if;
                end loop;
    else
        read_data_parity_cmb <= (OTHERS => '0');                
     end if;
        end process READ_PARITY_MUX_PROCESS_32;
      end generate READ_PARITY_EN_32_MAX;

    end generate READ_DATA_32_GEN;

-------------------------------------------------------------------------------
-- Read data path for 16 bit maximum memory width.
-------------------------------------------------------------------------------

    READ_DATA_16_GEN: if C_MAX_MEM_WIDTH=16 generate
    begin

-------------------------------------------------------------------------------
-- Read data process is used to generate read data for 16 bit DWidth.
-------------------------------------------------------------------------------

        READ_DATA_PROCESS_16: process(Mem_width_bytes, MemSteer_Mem_DQ_I)
        begin
                   read_data <= (others => '0');
          case Mem_width_bytes(2 to 3) is
             when "01"  =>
               -- create the input data
               for i in 0 to C_IPIF_DWIDTH/C_MIN_MEM_WIDTH -1 loop
                   read_data(i*C_MIN_MEM_WIDTH to
                             i*C_MIN_MEM_WIDTH+C_MIN_MEM_WIDTH-1)
                      <= MemSteer_Mem_DQ_I(0 to C_MIN_MEM_WIDTH-1);
               end loop;
             when "10" =>
               -- create the input data
               for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*2)-1 loop
                   read_data(i*C_MIN_MEM_WIDTH*2 to
                             i*C_MIN_MEM_WIDTH*2+C_MIN_MEM_WIDTH*2-1)
                      <= MemSteer_Mem_DQ_I(0 to C_MIN_MEM_WIDTH*2-1);
               end loop;
          -- coverage off
       when others =>
                   read_data <= (others => '0');
          -- coverage on
          end case;
        end process READ_DATA_PROCESS_16;

      READ_PARITY_EN_16_MAX : if (C_PARITY_TYPE_MEMORY/=0) generate

        READ_DATA_PROCESS_16: process(Mem_width_bytes, MemSteer_Mem_DQ_prty_I)
        begin
                   read_parity <= (others => '0');
          case Mem_width_bytes(2 to 3) is
             when "01"  =>
               -- create the input data
               for i in 0 to C_IPIF_DWIDTH/C_MIN_MEM_WIDTH -1 loop
                   read_parity(i*C_MIN_MEM_WIDTH/8 to
                             i*C_MIN_MEM_WIDTH/8+C_MIN_MEM_WIDTH/8-1)
                      <= MemSteer_Mem_DQ_prty_I(0 to C_MIN_MEM_WIDTH/8-1);
               end loop;
             when "10" =>
               -- create the input data
               for i in 0 to C_IPIF_DWIDTH/(C_MIN_MEM_WIDTH*2)-1 loop
                   read_parity(i*C_MIN_MEM_WIDTH*2/8 to
                             i*C_MIN_MEM_WIDTH*2/8+C_MIN_MEM_WIDTH*2/8-1)
                      <= MemSteer_Mem_DQ_prty_I(0 to C_MIN_MEM_WIDTH*2/8-1);
               end loop;
          -- coverage off
             when others =>
                   read_parity <= (others => '0');
          -- coverage on
          end case;
        end process READ_DATA_PROCESS_16;

        READ_PARITY_MUX_PROCESS_16: process(MemSteer_Mem_DQ_I,
                                            Parity_type,
                                            MemSteer_Mem_DQ_prty_I,
                                            read_ack_d,
                                            Bus2IP_BE)
        begin

            read_data_parity_cmb   <= (others => '0');
    if (read_ack_d(2) = '1') then

                for i in 0 to 1 loop
                  --if Bus2IP_BE(i) = '1' then
                   read_data_parity_cmb (i)<= check_parity(MemSteer_Mem_DQ_I(i*C_MIN_MEM_WIDTH to i*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1),
                                                           MemSteer_Mem_DQ_prty_I(i),
                                                           Parity_type);
                  --end if;
                end loop;
    else
        read_data_parity_cmb <= (OTHERS => '0');                
    end if;
        end process READ_PARITY_MUX_PROCESS_16;
      end generate READ_PARITY_EN_16_MAX;


    end generate READ_DATA_16_GEN;
-------------------------------------------------------------------------------
-- Read data path for 8 bit maximum memory width.
-------------------------------------------------------------------------------

    READ_DATA_8_GEN: if C_MAX_MEM_WIDTH=8 generate
    begin
-------------------------------------------------------------------------------
-- Read data process is used to generate read data for 8 bit DWidth.
-------------------------------------------------------------------------------

        READ_DATA_PROCESS_8: process(Mem_width_bytes,
                               MemSteer_Mem_DQ_I)
        begin
                   read_data <= (others => '0');
          case Mem_width_bytes(3) is
             when '1'  =>
               -- create the input data
               for i in 0 to C_IPIF_DWIDTH/C_MIN_MEM_WIDTH -1 loop
                   read_data(i*C_MIN_MEM_WIDTH to
                             i*C_MIN_MEM_WIDTH+C_MIN_MEM_WIDTH-1)
                      <= MemSteer_Mem_DQ_I(0 to C_MIN_MEM_WIDTH-1);
               end loop;
          -- coverage off
             when others =>
                   read_data <= (others => '0');
          -- coverage on
          end case;
        end process READ_DATA_PROCESS_8;

      READ_PARITY_EN_8_MAX : if (C_PARITY_TYPE_MEMORY/=0) generate

        READ_DATA_PROCESS_8: process(Mem_width_bytes, MemSteer_Mem_DQ_prty_I)
        begin
                   read_parity <= (others => '0');
          case Mem_width_bytes(3) is
             when '1'  =>
               -- create the input data
               for i in 0 to C_IPIF_DWIDTH/C_MIN_MEM_WIDTH -1 loop
                   read_parity(i*C_MIN_MEM_WIDTH/8 to
                             i*C_MIN_MEM_WIDTH/8+C_MIN_MEM_WIDTH/8-1)
                      <= MemSteer_Mem_DQ_prty_I(0 to C_MIN_MEM_WIDTH/8-1);
               end loop;
             when others =>
                   read_parity <= (others => '0');
          end case;
        end process READ_DATA_PROCESS_8;

        READ_PARITY_MUX_PROCESS_8: process(MemSteer_Mem_DQ_I,
                                           Parity_type,
                                           Bus2IP_BE,
                                           read_ack_d,
                                           MemSteer_Mem_DQ_prty_I)
        begin

            read_data_parity_cmb   <= (others => '0');
    if (read_ack_d(2) = '1') then

                for i in 0 to 0 loop
                  --if Bus2IP_BE(i) = '1' then
                   read_data_parity_cmb (i)<= check_parity(MemSteer_Mem_DQ_I(i*C_MIN_MEM_WIDTH to i*C_MIN_MEM_WIDTH + C_MIN_MEM_WIDTH-1),
                                                           MemSteer_Mem_DQ_prty_I(i),
                                                           Parity_type);
                  --end if;
                end loop;
    else
        read_data_parity_cmb <= (OTHERS => '0');                
    end if;
        end process READ_PARITY_MUX_PROCESS_8;
      end generate READ_PARITY_EN_8_MAX;

    end generate READ_DATA_8_GEN;
end generate RDDATA_PATH_MUX_GEN;
end imp;
-------------------------------------------------------------------------------
-- End of file mem_steer.vhd.
-------------------------------------------------------------------------------
