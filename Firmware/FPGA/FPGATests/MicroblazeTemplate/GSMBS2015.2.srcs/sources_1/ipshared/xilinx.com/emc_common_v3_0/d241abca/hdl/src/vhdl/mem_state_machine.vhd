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
-- Filename:        mem_state_machine.vhd
-- Description:     State machine controller for memory reads and writes
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
-- NSK         05/08/08    version v3_00_a
-- ^^^^^^^^
-- 1. This file is same as in version v3_02_a.
-- 2. Upgraded to version v3.00.a to have proper versioning to fix CR #472164.
-- 3. No change in design.
--
-- KSB         05/08/08    version v4_00_a
-- ^^^^^^^^
-- 1. Modified for Page mdoe read
-- 2. Modified for 64 Bit memory address align
-- ~~~~~~~~
-- KSB         22/05/10    version v5_00_a
-- 1. Modified for AXI EMC, PSRAM, Byte parity Memory Support
-- 2. Modified for AXI Slave burst interface
-- ~~~~~~~~
-- SK          02/11/10    version v5_01_a
-- ^^^^^^^^
-- 1. Removed "elsif Bus2IP_Mem_CS = '1' and ..." and "WAIT_TEMP" from WRITE state.
-- 2. Added write_req_ack_cmb  <= '1';
--    in WAIT_TEMP with (Synch_mem = '0' and single_trans = '0') condition
-- ~~~~~~~~
-- SK          24/11/10
-- ^^^^^^^^
-- 1. Added "ns_idle" signal to reset the address counter in mem_steer.vhd
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
use ieee.std_logic_unsigned.all;

-------------------------------------------------------------------------------
-- vcomponents package of the unisim library is used for the FDR component
-- declaration
-------------------------------------------------------------------------------

library unisim;
use unisim.vcomponents.all;

-------------------------------------------------------------------------------
-- Definition of Generics:
--
-- Definition of Ports:
-- The signal list is aligned as per the port list in entity
-------------------------------------------------------------------------------
--      Bus2IP_RNW                  -- Processor read/write transfer control
--      Bus2IP_RdReq                -- Processor Read Request
--      Bus2IP_WrReq                -- Processor Write Request
--      Synch_mem                   -- Current transaction is for synchronous
--                                     memory
--      Two_pipe_delay              -- Two pipe delay for synchronous memory
--      Cycle_End                   -- Current Cycle Complete

--      Read_data_en                -- Enable for read data registers
--      Read_ack                    -- Read cycle data acknowledge
--
--      Address_strobe              -- Address strobe signal
--      Data_strobe                 -- Data and BEs strobe signal

--      CS_Strobe                   -- Chip select strobe signal to store the
--                                  -- status of Bus2IP_CS

--      Addr_cnt_ce                 -- Address counter count enable
--      Addr_cnt_rst                -- Address counter reset
--      Cycle_cnt_ld                -- Cycle end counter count load
--      Cycle_cnt_en                -- Cycle end counter count enable
--
--      Trd_cnt_en                  -- Read Cycle Count Enable
--      Twr_cnt_en                  -- Write Cycle Count Enable
--      Trd_load                    -- Read Cycle Timer Load
--      Twr_load                    -- Write Cycle Timer Load
--      Thz_load                    -- Read Recovery to Write Timer Load
--      Tlz_load                    -- Write Recovery to Read Timer Load
--      Trd_end                     -- Read Cycle Complete
--      Twr_end                     -- Write Cycle Complete
--      Thz_end                     -- Read Recovery Complete
--      Tlz_end                     -- Write Recovery Complete
--      Tpacc_end                   -- page access read end
--
--      Mem_CEN_cmb                 -- Memory Chip Enable
--      Mem_OEN_cmb                 -- Memory Output Enable
--      Mem_WEN_cmb                 -- Memory Write Enable
--
--      Write_req_ack               -- Write address acknowledge
--      Read_req_ack                -- Read address acknowledge
--      Transaction_done            -- Operation complete indication for
--                                  -- current transaction
--      Mem_Addr_rst                -- Memory address bus reset
--
--      Clk                         -- System Clock
--      Rst                         -- System Read
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Entity section
-----------------------------------------------------------------------------

entity mem_state_machine is
    port (
        Clk                 : in  std_logic;
        Rst                 : in  std_logic;

        Bus2IP_RNW          : in  std_logic;
        Bus2IP_RdReq        : in  std_logic;
        Bus2IP_WrReq        : in  std_logic;
        Synch_mem           : in  std_logic;
        Two_pipe_delay      : in  std_logic;
        Cycle_End           : in  std_logic;
        Bus2IP_Mem_CS       : in  std_logic;
        Bus2IP_Burst        : in  std_logic;
        Read_data_en        : out std_logic;
        Read_ack            : out std_logic;

        Address_strobe      : out std_logic;
        Data_strobe         : out std_logic;
        CS_Strobe           : out std_logic;

        Addr_cnt_ce         : out std_logic;
        Addr_cnt_rst        : out std_logic;
        Cycle_cnt_ld        : out std_logic;
        Cycle_cnt_en        : out std_logic;

        Trd_cnt_en          : out std_logic;
        Twr_cnt_en          : out std_logic;
        Twph_cnt_en         : out std_logic;
        Tpacc_cnt_en        : out std_logic;
        Trd_load            : out std_logic;
        Twr_load            : out std_logic;
        Twph_load           : out std_logic;
        Tpacc_load          : out std_logic;
        Thz_load            : out std_logic;
        Tlz_load            : out std_logic;
        Trd_end             : in  std_logic;
        Twr_end             : in  std_logic;
        Twph_end            : in  std_logic;
        Thz_end             : in  std_logic;
        Tlz_end             : in  std_logic;
        Tpacc_end           : in  std_logic;

        New_page_access     : in  std_logic;
        Linear_flash_brst_rd_flag : in std_logic;
        Linear_flash_rd_data_ack  : in std_logic;
        Bus2IP_RdReq_emc : in std_logic;

        MSM_Mem_CEN         : out std_logic;
        MSM_Mem_OEN         : out std_logic;
        MSM_Mem_WEN         : out std_logic;
        CS_Strobe_par_addr  : out std_logic;

        Write_req_ack       : out std_logic;
        Read_req_ack        : out std_logic;
        Transaction_done    : out std_logic;
        single_trans        : in  std_logic;

        Mem_Addr_rst        : out std_logic;
        Addr_align          : in  std_logic;
        Addr_align_rd       : out std_logic;

        original_wrce       : in std_logic;
        last_burst_cnt      : in std_logic;

        Write_req_data_ack  : out std_logic;
        Write_req_addr_ack  : out std_logic;

        address_strobe_c    : out std_logic;
        be_strobe_c         : out std_logic;
        data_strobe_c       : out std_logic;
        ns_idle             : out std_logic;
        pr_idle             : out std_logic; -- 11-12-2012
        pr_state_wait_temp_cmb : out std_logic;

        Twr_rec_load        : out std_logic;
        Twr_rec_cnt_en      : out std_logic;
        Twr_rec_end         : in std_logic;
        Flash_mem_access    : in std_logic;
        Flash_mem_access_disable : out std_logic;
        Mem_WAIT: in std_logic;
        Adv_L_N : out std_logic := '1';
        last_addr1 : in std_logic;
        stop_oen : in std_logic;
        axi_wvalid : in std_logic;
        axi_wlast : in std_logic;
        bus2ip_ben_all_1 : in std_logic
    );
end entity mem_state_machine;

-------------------------------------------------------------------------------
-- Architecture section
-------------------------------------------------------------------------------

architecture imp of mem_state_machine is

----------------------------------------------------------------------------------
-- below attributes are added to reduce the synth warnings in Vivado tool
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of imp : architecture is "yes";
----------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Signal Declarations
-------------------------------------------------------------------------------

type MEM_SM_TYPE is (IDLE,
                     WRITE,
                     DASSERT_WEN,
                     WAIT_WRITE_ACK,
                     WRITE_WAIT,
                     WAIT_TEMP,
                     WR_REC_PERIOD, -- 9/6/2011
                     READ,
                     LINEAR_FLASH_SYNC_RD,
                     PAGE_READ,
                     WAIT_RDDATA_ACK --,
               --      WRITE_SYNC,
              --       READ_SYNC--,
                     --WRITE_ASYNC,
                     --READ_ASYNC
                     );

signal crnt_state               : MEM_SM_TYPE := IDLE;
signal next_state               : MEM_SM_TYPE;

--signal write_req_ack_cmb        : std_logic;
signal read_req_ack_cmb         : std_logic;
signal read_data_en_cmb         : std_logic;
signal read_data_en_reg         : std_logic;

signal read_ack_cmb             : std_logic;
signal read_ack_reg             : std_logic;

signal addr_cnt_ce_cmb          : std_logic;
signal addr_cnt_rst_cmb         : std_logic;
signal addr_cnt_ce_reg          : std_logic;
signal addr_cnt_rst_reg         : std_logic;


signal addressData_strobe_cmb   : std_logic;
signal cs_strobe_cmb            : std_logic;
signal cs_strobe_reg            : std_logic;
signal cycle_cnt_ld_cmb         : std_logic;
signal cycle_cnt_en_cmb         : std_logic;

signal trd_cnt_en_cmb           : std_logic;
signal twr_cnt_en_cmb           : std_logic;
signal twph_cnt_en_cmb          : std_logic;
signal tpacc_cnt_en_cmb         : std_logic;

signal trd_load_cmb             : std_logic;
signal twr_load_cmb             : std_logic;
signal twph_load_cmb            : std_logic;
signal thz_load_cmb             : std_logic;
signal tlz_load_cmb             : std_logic;
signal tpacc_load_cmb           : std_logic;

signal new_page                 : std_logic;
signal new_page_d1              : std_logic;


signal mem_cen_cmb              : std_logic;
signal mem_oen_cmb              : std_logic;
signal mem_wen_cmb              : std_logic;
signal mem_cen_reg              : std_logic;
signal mem_oen_reg              : std_logic;
signal mem_wen_reg              : std_logic;

signal read_complete_cmb        : std_logic;
signal read_complete_d          : std_logic_vector(0 to 7);
signal read_complete            : std_logic;

signal mem_Addr_rst_cmb         : std_logic;

signal transaction_done_cmb     : std_logic;
signal transaction_done_reg     : std_logic;
signal transaction_complete_reg : std_logic;
signal read_break_reg_d1        : std_logic;

signal addr_align_reg           : std_logic;
signal addr_align_rd_d1         : std_logic;
signal Bus2IP_Mem_CS_d1         : std_logic;
signal Bus2IP_Mem_CS_d2         : std_logic;
signal Bus2IP_RdReq_d1          : std_logic;
signal Bus2IP_RdReq_d2          : std_logic;
signal read_break               : std_logic;
signal transaction_complete     : std_logic;
signal read_break_reg           : std_logic;
signal Load_address             : std_logic;

signal Write_req_data_ack_cmb : std_logic;
signal Write_req_addr_ack_cmb : std_logic;
signal address_strobe_cmb     : std_logic;
signal be_strobe_cmb          : std_logic;
signal data_strobe_cmb        : std_logic;

signal int_Flash_mem_access_en : std_logic;
signal int_Flash_mem_access_dis : std_logic;
signal wlast,wlast_reg : std_logic;
signal wvalid,wvalid_reg : std_logic;

attribute max_fanout                               : string;
attribute max_fanout   of read_req_ack_cmb         : signal is "30";
--attribute max_fanout   of write_req_ack_cmb        : signal is "30";
attribute max_fanout   of Write_req_data_ack_cmb   : signal is "30";
attribute max_fanout   of Write_req_addr_ack_cmb   : signal is "30";

signal twr_rec_cnt_en_cmb : std_logic;
signal twr_rec_load_cmb   : std_logic;
signal last_addr1_d1, last_addr1_d2, last_addr1_d3: std_logic; -- 09-12-2012
constant NEW_LOGIC: integer := 1;
-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------

begin
ns_idle <= '1' when next_state=IDLE
           else
           '0';
pr_idle <= '1' when crnt_state=IDLE
           else
           '0';

--wlast <= '1' when axi_wlast = '1' else wlast;

pr_state_wait_temp_cmb <= '1' when (next_state = WAIT_TEMP)
                          else
                          '0';
Write_req_ack       <= '0';-- write_req_ack_cmb; --
Write_req_data_ack  <= Write_req_data_ack_cmb;
Write_req_addr_ack  <= Write_req_addr_ack_cmb;

Read_req_ack        <= read_req_ack_cmb;
Read_data_en        <= read_data_en_reg;
Read_ack            <= Read_ack_reg ;

Read_ack_cmb        <= (read_data_en_cmb and Cycle_End) or (Linear_flash_brst_rd_flag and Linear_flash_rd_data_ack);

Addr_cnt_ce         <= addr_cnt_ce_cmb;
Addr_cnt_rst        <= addr_cnt_rst_cmb;
Address_strobe      <= addressData_strobe_cmb;
CS_Strobe           <= cs_strobe_reg;
CS_Strobe_par_addr  <= Load_address and Bus2IP_RNW;

Cycle_cnt_ld        <= cycle_cnt_ld_cmb;
Cycle_cnt_en        <= cycle_cnt_en_cmb;

Trd_cnt_en          <= trd_cnt_en_cmb;
Tpacc_cnt_en        <= tpacc_cnt_en_cmb;
Twr_cnt_en          <= twr_cnt_en_cmb;
Twph_cnt_en         <= twph_cnt_en_cmb;
Twr_rec_cnt_en      <= Twr_rec_cnt_en_cmb;--9/6/2011

Trd_load            <= trd_load_cmb;
Tpacc_load          <= tpacc_load_cmb;
Twr_load            <= twr_load_cmb;
Twph_load           <= twph_load_cmb;
Thz_load            <= thz_load_cmb;
Tlz_load            <= tlz_load_cmb;
Twr_rec_load        <= Twr_rec_load_cmb;--9/6/2011

MSM_Mem_CEN         <= mem_cen_cmb;
MSM_Mem_OEN         <= mem_oen_cmb;
MSM_Mem_WEN         <= mem_wen_cmb;

Mem_Addr_rst        <= mem_Addr_rst_cmb;
Transaction_done    <= transaction_done_reg;

--ADDR_CNT_SYNCH_MODE : process(Clk)
--    begin
--       if(Clk'EVENT and Clk = '1')then
--          if(Rst = '1')then
--              addr_cnt_numonyx     <=  '0';
--          elsif(Linear_flash_brst_rd_flag = '1') then
--              if(Linear_flash_rd_data_ack = '1') then
--                      addr_cnt_numonyx <= not(addr_cnt_numonyx);
--                end if;
--           end if;
--     end if;
--    end process ADDR_CNT_SYNCH_MODE;


-- -------------------------------------------------------------------------------
-- -- Controls the flow of Read and write transaction performed based on type of
-- -- memory (synchronous/asynchronous) connected.
-- -------------------------------------------------------------------------------
-- OLD_LOGIC_GEN: if NEW_LOGIC = 0 generate
-- begin
-- 
-- SM_COMB_PROCESS: process (
--               crnt_state,
--               Bus2IP_RdReq,
--               Bus2IP_WrReq,
--               Synch_mem,
--               Cycle_End,
--               Trd_end,
--               Tpacc_end,
--               Twr_end,
--               Twph_end,
--               Thz_end,
--               Bus2IP_Mem_CS_d2,
--               Bus2IP_Mem_CS_d1,
--               read_break,
--               transaction_complete,
--               read_break_reg,
--               Tlz_end,
--               addr_align_rd_d1,
--               new_page_d1,
--               Addr_align,
--               New_page_access,
--               Bus2IP_Mem_CS,
--               single_trans,
--               new_page,
--               read_complete,
--               original_wrce,
--               last_burst_cnt,
--               transaction_complete_reg,
--               read_break_reg_d1,
--               Bus2IP_Burst,
--               Twr_rec_end,
--               Flash_mem_access,
--               Linear_flash_brst_rd_flag,--8/18/2011
--               Linear_flash_rd_data_ack,   --8/18/2011
--               Mem_WAIT                ,   -- CR#662558
--               Bus2IP_RdReq_emc        ,
--               last_addr1
--               )
-- 
--     begin
-- 
--         next_state              <= crnt_state;
--         mem_cen_cmb             <= '1';
--         mem_oen_cmb             <= '1';
--         mem_wen_cmb             <= '1';
-- 
--         write_req_ack_cmb       <= '0';
--         Write_req_data_ack_cmb  <= '0';
--         Write_req_addr_ack_cmb  <= '0';
-- 
--         read_req_ack_cmb        <= '0';
--         read_data_en_cmb        <= '0';
--         addr_cnt_ce_cmb         <= '0';
--         addr_cnt_rst_cmb        <= '0';
-- 
--         addressData_strobe_cmb  <= '0';
--         address_strobe_cmb      <= '0';
--         be_strobe_cmb           <= '0';
--         data_strobe_cmb         <= '0';
-- 
--         cs_strobe_cmb           <= '0';
--         cycle_cnt_ld_cmb        <= '0';
--         cycle_cnt_en_cmb        <= '0';
-- 
--         trd_cnt_en_cmb          <= '0';
--         tpacc_cnt_en_cmb        <= '0';
--         twr_cnt_en_cmb          <= '0';
--         twph_cnt_en_cmb         <= '0';
--         twr_rec_cnt_en_cmb      <= '0';-- 9/6/2011
-- 
--         trd_load_cmb            <= '0';
--         tpacc_load_cmb          <= '0';
--         twr_load_cmb            <= '0';
--         twph_load_cmb           <= '0';
--         thz_load_cmb            <= '0';
--         tlz_load_cmb            <= '0';
--         twr_rec_load_cmb        <= '0'; -- 9/6/2011
-- 
--         read_complete_cmb       <= '0';
--         addr_align_reg          <= addr_align_rd_d1;
--         new_page                <= new_page_d1;
-- 
--         transaction_complete    <= transaction_complete_reg;
--         read_break_reg          <= read_break_reg_d1;
-- 
--         mem_Addr_rst_cmb        <= '0';
--         transaction_done_cmb    <= '0';
--         Flash_mem_access_disable <= '0';
--         Adv_L_N                 <= '1';
--         case crnt_state is
-- 
--             -------------------------------------------------------------------
--             -- IDLE STATE
--             -- Waits in this state untill read and write transaction is
--             -- initiated.
--             -- Loads the counters.
--             -- Generates appropriate gate signal (burst/single) which is used
--             -- to let read transfer ack pass to the IPIF.
--             -------------------------------------------------------------------
-- 
--             when IDLE =>
-- 
--                 transaction_done_cmb    <= '1';
-- 
--                 addressData_strobe_cmb  <= '1';
--                 address_strobe_cmb      <= '1';
--                 be_strobe_cmb           <= '1';
--                 data_strobe_cmb         <= '1';
-- 
--                 addr_cnt_rst_cmb        <= '1';
--                 cycle_cnt_ld_cmb        <= '1';
--                 cs_strobe_cmb           <= '1';
--                 mem_Addr_rst_cmb        <= '1';
--                 new_page                <= '0';
--                 addr_align_reg          <= '0';
--                 read_break_reg          <= '0';
-- 
--                if (Bus2IP_WrReq = '1' and Thz_end = '1') then
--                     if Synch_mem = '0' and single_trans = '0' then
--                        write_req_ack_cmb      <= '1';
--                        Write_req_data_ack_cmb <= '1';
--                        Write_req_addr_ack_cmb <= '1';
--                     end if;
--                     twr_load_cmb       <= '1';
--                     twph_load_cmb      <= '1';
--                     next_state         <= WRITE;
--                     transaction_done_cmb  <= '0';
--                     transaction_complete  <= '0';
--                     addr_align_reg        <= '0';
-- 
--                 elsif (Bus2IP_RdReq = '1' and Tlz_end = '1') then
--                     read_req_ack_cmb   <= '1';
--                     trd_load_cmb       <= '1';
--                     if(Linear_flash_brst_rd_flag = '1')then
--                         next_state         <= LINEAR_FLASH_SYNC_RD;
--                         Adv_L_N                 <= '0';
--                         mem_cen_cmb    <= '0';
--                         mem_oen_cmb    <= '0';
-- 
--                     else
--                         next_state         <= READ;
--                     end if;
--                     transaction_done_cmb    <= '0';
--                     addr_align_reg  <= Addr_align;
--                     transaction_complete    <= '0';
--                 end if;
-- 
--             -------------------------------------------------------------------
--             -- WRITE STATE
--             -- Controls write operation to the memory.
--             -- Generates control signals for write, address, and cycle end
--             -- counters.
--             -------------------------------------------------------------------
-- 
--             when WRITE =>
-- 
-- 
--                 mem_cen_cmb  <= '0';
--                 mem_wen_cmb  <= '0';
-- 
--                 if (Bus2IP_Mem_CS_d2 = '1' and Bus2IP_Mem_CS_d1 = '0') then
--                     transaction_complete   <= '1';
--                 end if;
-- 
-- 
--                 if (Twr_end = '1') then
--                     if Synch_mem = '1' then
--                         if (Cycle_End = '1') then
--                             if (Bus2IP_WrReq = '1')then
--                                 write_req_ack_cmb      <= '1';
--                                 Write_req_data_ack_cmb <= '1';
--                                 Write_req_addr_ack_cmb <= '1';
-- 
--                                 addressData_strobe_cmb <= '1';
--                                 address_strobe_cmb     <= '1';
--                                 be_strobe_cmb          <= '1';
--                                 data_strobe_cmb        <= '1';
-- 
--                                 addr_cnt_rst_cmb       <= '1';
--                                 cycle_cnt_ld_cmb       <= '1';
--                                 twr_load_cmb           <= '1';
-- 
--                                 if(single_trans = '1')then--CR#606038 is fixed
--                                     next_state         <= WAIT_WRITE_ACK;
--                                 else
--                                     next_state         <= WRITE;
--                                 end if;--
--                             else
--                                 twr_rec_load_cmb       <= flash_mem_access;
--                                 next_state             <= WAIT_WRITE_ACK;
--                             end if;
--                         else
--                             twr_load_cmb      <= '1';
--                             cycle_cnt_en_cmb  <= '1';
--                             addr_cnt_ce_cmb   <= '1';
--                         end if;
--                     else
--                         twph_cnt_en_cmb         <= '1';
--                         next_state              <= DASSERT_WEN;
--                         if single_trans = '1' then
--                           write_req_ack_cmb      <= '1';
--                           if(flash_mem_access = '1') then
--                                 Write_req_data_ack_cmb <= '0';
--                           else
--                                 Write_req_data_ack_cmb <= '1';
--                           end if;
--                           Write_req_addr_ack_cmb <= '1';
--                         end if;
--                     end if;
--                 else
--                     twr_cnt_en_cmb  <= '1';
--                 end if;
--             -----------------
--             when WAIT_TEMP =>
--                 if (Bus2IP_WrReq = '1' and Thz_end = '1') then
--                     addressData_strobe_cmb  <= '1';
--                     address_strobe_cmb      <= '1';
--                     be_strobe_cmb           <= '1';
--                     data_strobe_cmb         <= '1';
-- 
--                     addr_cnt_rst_cmb        <= '1';
--                     cycle_cnt_ld_cmb        <= '1';
--                     cs_strobe_cmb           <= '1';
--                     mem_Addr_rst_cmb        <= '1';
--                     addr_align_reg          <= '0';
--                     twr_load_cmb            <= '1';
--                     next_state              <= WRITE;
--                     addr_align_reg          <= '0';
--                      twph_load_cmb     <= '1';
--                      if (last_burst_cnt = '0' and
--                          Synch_mem      = '0' and
--                          single_trans   = '0')then
--                        write_req_ack_cmb      <= '1';
--                        Write_req_data_ack_cmb <= '1';
--                        Write_req_addr_ack_cmb <= '1';
--                     end if;
--                 elsif (transaction_complete = '1') or
--                       (Bus2IP_Mem_CS = '0' and Bus2IP_WrReq = '0') then
--                     twr_rec_load_cmb <= flash_mem_access;
--                     next_state       <= WAIT_WRITE_ACK;
--                 else
--                         next_state              <= WAIT_TEMP;
--                 end if;
--             -------------------------------------------------------------------
--             -- DASSERT_WEN STATE
--             -- Comes to this state only when write operation is performed on
--             -- asynchronous memory.This state performs NOP cycle on memory side.
--             -- Generates control signals for write, address and cycle end
--             -- counters.
--             -------------------------------------------------------------------
-- 
--             when DASSERT_WEN =>
-- 
-- 
--                 if (Cycle_End = '1') then
--                     if (Bus2IP_WrReq = '1') then
--                         if (twph_end = '1') then
--                                 write_req_ack_cmb      <= '1';
--                                 Write_req_data_ack_cmb <= '1';
--                                 Write_req_addr_ack_cmb <= '1';
-- 
--                                 addressData_strobe_cmb <= '1';
--                                 address_strobe_cmb     <= '1';
--                                 be_strobe_cmb          <= '1';
--                                 data_strobe_cmb        <= '1';
-- 
--                                 addr_cnt_rst_cmb       <= '1';
--                                 cycle_cnt_ld_cmb       <= '1';
--                                 twr_load_cmb           <= '1';
--                                 twph_load_cmb           <= '1';
--                                 next_state             <= WRITE;
--                         else
--                                 next_state             <= DASSERT_WEN;
--                                 twph_cnt_en_cmb        <= '1';
--                         end if;
--                     elsif (Bus2IP_Mem_CS = '1' and
--                            Bus2IP_WrReq  = '0' and
--                            Bus2IP_RdReq  = '0')then
--                                 if(last_addr1 = '1') then
--                                     next_state             <= WRITE;
--                                 else
--                                     next_state             <= WAIT_TEMP;
--                                 end if;
--                                 address_strobe_cmb     <= last_addr1;--
--                                 be_strobe_cmb          <= last_addr1;-- '1';
--                                 data_strobe_cmb        <= last_addr1;-- '1';
--                                 twr_rec_load_cmb       <= flash_mem_access;
-- 
--                                 write_req_ack_cmb      <= last_addr1;-- '0';
--                                 Write_req_data_ack_cmb <= last_addr1;-- '0';
--                                 Write_req_addr_ack_cmb <= last_addr1;-- '0';
-- 
--                                 addr_cnt_rst_cmb       <= '0';
--                                 cycle_cnt_ld_cmb       <= '0';
--                                 twr_load_cmb           <= '0';
--                     else
--                         twr_rec_load_cmb       <= flash_mem_access;
--                         next_state             <= WAIT_WRITE_ACK;
--                     end if;
--                 else
--                   if (twph_end = '1') then
--                     twr_load_cmb      <= '1';
--                     cycle_cnt_en_cmb  <= '1';
--                     addr_cnt_ce_cmb   <= '1';
--                     twph_load_cmb     <= '1';
--                     next_state        <= WRITE;
--                   else
--                     twph_cnt_en_cmb   <= '1';
--                   end if;
--                 end if;
-- 
--             -------------------------------------------------------------------
--             -- WAIT_WRITE_ACK STATE
--             -------------------------------------------------------------------
-- 
--             when WAIT_WRITE_ACK =>
--                     if(flash_mem_access = '1') then
--                         twr_rec_cnt_en_cmb <= '1';
--                         next_state       <= WR_REC_PERIOD;
--                     else
--                         next_state    <= IDLE;
--                     end if;
--                     tlz_load_cmb          <= '1';
--                     addr_cnt_rst_cmb      <= '1';
--                     transaction_done_cmb  <= '1';
-- 
--             when WR_REC_PERIOD =>
--                     if(Twr_rec_end = '1')then
--                         Flash_mem_access_disable <= '1';
--                         Write_req_data_ack_cmb <= '1';
--                         next_state    <= IDLE;
--                     else
--                         twr_rec_cnt_en_cmb <= '1';
--                                     next_state         <= WR_REC_PERIOD;
--                     end if;
-- 
-- 
-- 
--             -------------------------------------------------------------------
--             -- READ STATE
--             -- Controls read operation on memory.
--             -- Generates control signals for read, address and cycle end
--             -- counters
--             -------------------------------------------------------------------
-- --             when LINEAR_FLASH_SYNC_RD =>
-- --                 mem_cen_cmb    <= '0';
-- --                 mem_oen_cmb    <= '0';
-- --
-- --                 if (Bus2IP_Mem_CS_d2 = '1' and Bus2IP_Mem_CS_d1 = '0') then
-- --                     transaction_complete   <= '1';
-- --                 end if;
-- --                if (Linear_flash_rd_data_ack = '1') then
-- --                      read_data_en_cmb  <= '1';
-- --                      addr_align_reg  <= Addr_align;
-- --                      if (Cycle_End = '1') then
-- --                              if ((Bus2IP_RdReq='1' or single_trans = '1')and
-- --                                              read_break_reg = '0'                   and
-- --                                              transaction_complete = '0') then
-- --                                              read_req_ack_cmb       <= '1';
-- --                                      addressData_strobe_cmb <= '1';
-- --                                      address_strobe_cmb     <= '1';
-- --                                      be_strobe_cmb          <= '1';
-- --                                      data_strobe_cmb        <= '1';
-- --                                      addr_cnt_rst_cmb       <= '1';
-- --                                      cycle_cnt_ld_cmb       <= '1';
-- --                                              next_state             <= LINEAR_FLASH_SYNC_RD;
-- --                              else
-- --                                              next_state             <= WAIT_RDDATA_ACK;
-- --                                              read_complete_cmb      <= '1';
-- --                                              read_data_en_cmb       <= '0';
-- --                              end if;
-- --                      else
-- --                            trd_load_cmb           <= '1';
-- --                            cycle_cnt_en_cmb       <= '1';
-- --                            addr_cnt_ce_cmb        <= '1';
-- --                    end if;
-- --                end if;
-- 
--          when LINEAR_FLASH_SYNC_RD =>
--                 if (Bus2IP_Mem_CS_d2 = '1' and Bus2IP_Mem_CS_d1 = '0') then
--                     transaction_complete   <= '1';
--                 end if;
-- 
--                 if (read_break= '1' and single_trans = '0') then
--                         read_break_reg <= '1';
--                 end if;
--                 Adv_L_N                 <= '1';
--                 mem_cen_cmb    <= '0';
--                 mem_oen_cmb    <= '0';
--                 new_page       <= '0';
--                 -- added for abort condition
--                 if (Mem_WAIT = '1') then
--                     read_data_en_cmb  <= Linear_flash_rd_data_ack;
--                     addr_align_reg  <= Addr_align;
--                     if (Cycle_End = '1') then
--                         if ((Bus2IP_RdReq='1' or single_trans = '1')and
--                              read_break_reg = '0'                   and
--                              transaction_complete = '0') then
-- 
--                             read_req_ack_cmb       <= '1';
-- 
--                             addressData_strobe_cmb <= '1';
--                             address_strobe_cmb     <= '1';
--                             be_strobe_cmb          <= '1';
--                             data_strobe_cmb        <= '1';
-- 
--                             addr_cnt_rst_cmb       <= '1';
--                             cycle_cnt_ld_cmb       <= '1';
-- 
--                             trd_load_cmb       <= '1';
--                             next_state         <= LINEAR_FLASH_SYNC_RD;
--                         else
--                             next_state             <= WAIT_RDDATA_ACK;
--                             read_complete_cmb      <= '1';
--                             read_data_en_cmb       <= '0';
--                         end if;
--                     else
--                     --        trd_load_cmb           <= '1';
--                             cycle_cnt_en_cmb       <= '1';
--                             addr_cnt_ce_cmb        <= '1';
--                     end if;
--                 else
--                     trd_cnt_en_cmb  <= '1';
--                 end if;
-- 
-- 
-- 
-- 
--             -------------------------------------------------------------------
--             -- READ STATE
--             -- Controls read operation on memory.
--             -- Generates control signals for read, address and cycle end
--             -- counters
--             -------------------------------------------------------------------
-- 
--             when READ =>
--                 if (Bus2IP_Mem_CS_d2 = '1' and Bus2IP_Mem_CS_d1 = '0') then
--                     transaction_complete   <= '1';
--                 end if;
-- 
--                 if (read_break= '1' and single_trans = '0') then
--                         read_break_reg <= '1';
--                 end if;
-- 
--                 mem_cen_cmb    <= '0';
--                 mem_oen_cmb    <= '0';
--                 new_page       <= '0';
--                 -- added for abort condition
--                 if (Trd_end = '1') then
--                     read_data_en_cmb  <= '1';
--                     addr_align_reg  <= Addr_align;
--                     if (Cycle_End = '1') then
--                         if ((Bus2IP_RdReq='1' or single_trans = '1')and
--                              read_break_reg = '0'                   and
--                              transaction_complete = '0') then
-- 
--                             read_req_ack_cmb       <= '1';
-- 
--                             addressData_strobe_cmb <= '1';
--                             address_strobe_cmb     <= '1';
--                             be_strobe_cmb          <= '1';
--                             data_strobe_cmb        <= '1';
-- 
--                             addr_cnt_rst_cmb       <= Bus2IP_RdReq_emc;-- '1';-- Bus2IP_RdReq_emc; -- '1';
--                             cycle_cnt_ld_cmb       <= '1';
-- 
--                             if New_page_access = '0' then
--                                 next_state         <= PAGE_READ;
--                                 tpacc_load_cmb     <= '1';
--                             else
--                                 trd_load_cmb       <= '1';
--                                 next_state         <= READ;
--                             end if;
--                         else
--                             next_state             <= WAIT_RDDATA_ACK;
--                             read_complete_cmb      <= '1';
--                             read_data_en_cmb       <= '1';
--                         end if;
--                     else
--                             trd_load_cmb           <= '1';
--                             cycle_cnt_en_cmb       <= '1';
--                             addr_cnt_ce_cmb        <= '1'; -- Bus2IP_RdReq; -- '1';
--                     end if;
--                 else
--                     trd_cnt_en_cmb  <= '1';
--                 end if;
-- 
--             -------------------------------------------------------------------
--             -- PAGE_READ State =>
--             -- Will do a page read when ever there is a page aligned boundry
--             -------------------------------------------------------------------
--             when PAGE_READ =>
-- 
--                 if (Bus2IP_Mem_CS_d2 = '1' and Bus2IP_Mem_CS_d1 = '0') then
--                     transaction_complete   <= '1';
--                 end if;
-- 
--                 mem_cen_cmb    <= '0';
--                 mem_oen_cmb    <= '0';
-- 
--                 if (read_break= '1' and single_trans = '0') then
--                         read_break_reg <= '1';
--                 end if;
--                 -- added for abort condition
--                 if (Tpacc_end = '1') then
--                     addr_align_reg    <= Addr_align;
--                     read_data_en_cmb  <= '1';
--                     if (Cycle_End = '1') then
--                         if (Bus2IP_RdReq = '1' and
--                             read_break   = '0' and
--                             transaction_complete = '0') then
-- 
--                             read_req_ack_cmb       <= '1';
--                             addressData_strobe_cmb <= '1';
--                             address_strobe_cmb     <= '1';
--                             be_strobe_cmb          <= '1';
--                             data_strobe_cmb        <= '1';
-- 
--                             addr_cnt_rst_cmb       <= '1';
--                             cycle_cnt_ld_cmb       <= '1';
-- 
--                             If new_page = '0' then
--                                 tpacc_load_cmb     <= '1';
--                                 next_state         <= PAGE_READ;
--                             else
--                                 trd_load_cmb       <= '1';
--                                 next_state         <= READ;
--                             end if;
--                         else
--                             next_state             <= WAIT_RDDATA_ACK;
--                             read_complete_cmb      <= '1';
--                             read_data_en_cmb       <= '1';
--                         end if;
--                     else
--                             tpacc_load_cmb         <= '1';
--                             cycle_cnt_en_cmb       <= '1';
--                             addr_cnt_ce_cmb        <= '1';
--                     end if;
--                 else
--                     tpacc_cnt_en_cmb  <= '1';
--                     if New_page_access = '1' then
--                         new_page <= '1';
--                     end if;
--                 end if;
-- 
-- 
-- 
--             -------------------------------------------------------------------
--             -- WAIT_RDDATA_ACK STATE
--             -- Waits in this state till read data is received from memory.
--             -------------------------------------------------------------------
-- 
--             when WAIT_RDDATA_ACK =>
-- 
--                 if read_complete = '1' then
--                     next_state    <= IDLE;
--                     thz_load_cmb  <= '1';
--                     transaction_done_cmb    <= '1';
--                 end if;
--                     addr_align_reg    <= Addr_align;
--                     new_page          <= '0';
--                     addr_cnt_rst_cmb  <= '1';
--                     read_data_en_cmb  <= '0';
--                     read_break_reg    <= '0';
-- 
--                     if (Bus2IP_Mem_CS_d2 = '1' and
--                         Bus2IP_Mem_CS_d1 = '0') then
--                        transaction_complete   <= '1';
--                     end if;
-- 
--         end case;
--     end process SM_COMB_PROCESS;
-- end generate OLD_LOGIC_GEN;

NEW_LOGIC_GEN: if NEW_LOGIC = 1 generate
-----
begin
-----
SM_COMB_PROCESS: process (
              crnt_state,
              Bus2IP_RdReq,
              Bus2IP_WrReq,
              Synch_mem,
              Cycle_End,
              Trd_end,
              Tpacc_end,
              Twr_end,
              Twph_end,
              Thz_end,
              Bus2IP_Mem_CS_d2,
              Bus2IP_Mem_CS_d1,
              read_break,
              transaction_complete,
              read_break_reg,
              Tlz_end,
              addr_align_rd_d1,
              new_page_d1,
              Addr_align,
              New_page_access,
              Bus2IP_Mem_CS,
              single_trans,
              new_page,
              read_complete,
              original_wrce,
              last_burst_cnt,
              transaction_complete_reg,
              read_break_reg_d1,
              Bus2IP_Burst,
              Twr_rec_end,
              Flash_mem_access,
              Linear_flash_brst_rd_flag,--8/18/2011
              Linear_flash_rd_data_ack,   --8/18/2011
              Mem_WAIT                ,   -- CR#662558
              Bus2IP_RdReq_emc        ,
              last_addr1              ,
              last_addr1_d1, -- 09-12-2012
              last_addr1_d2,  -- 09-12-2012
              last_addr1_d3, -- 09-12-2012
              stop_oen,
              bus2ip_ben_all_1,
              axi_wvalid,
              wlast_reg,
              wvalid_reg,
              wlast,
              wvalid,
              axi_wlast
              )

    begin

        next_state              <= crnt_state;
        mem_cen_cmb             <= '1';
        mem_oen_cmb             <= '1';
        mem_wen_cmb             <= '1';

        --write_req_ack_cmb       <= '0';09-12-2012
        Write_req_data_ack_cmb  <= '0';
        Write_req_addr_ack_cmb  <= '0';

        read_req_ack_cmb        <= '0';
        read_data_en_cmb        <= '0';
        addr_cnt_ce_cmb         <= '0';
        addr_cnt_rst_cmb        <= '0';

        --addressData_strobe_cmb  <= '0';09-12-2012   not used in the logic
        address_strobe_cmb      <= '0';
        be_strobe_cmb           <= '0';
        data_strobe_cmb         <= '0';

        cs_strobe_cmb           <= '0';
        cycle_cnt_ld_cmb        <= '0';
        cycle_cnt_en_cmb        <= '0';

        trd_cnt_en_cmb          <= '0';
        tpacc_cnt_en_cmb        <= '0';
        twr_cnt_en_cmb          <= '0';
        twph_cnt_en_cmb         <= '0';
        twr_rec_cnt_en_cmb      <= '0';-- 9/6/2011

        trd_load_cmb            <= '0';
        tpacc_load_cmb          <= '0'; -- '0'; -- 1/4/2013
        twr_load_cmb            <= '0';
        twph_load_cmb           <= '0';
        thz_load_cmb            <= '0';
        tlz_load_cmb            <= '0';
        twr_rec_load_cmb        <= '0'; -- 9/6/2011

        read_complete_cmb       <= '0';
        addr_align_reg          <= addr_align_rd_d1;
        new_page                <= new_page_d1;

        transaction_complete    <= transaction_complete_reg;
        read_break_reg          <= read_break_reg_d1;

        mem_Addr_rst_cmb        <= '0';
        transaction_done_cmb    <= '0';
        Flash_mem_access_disable <= '0';
        Adv_L_N                 <= '1';
        wlast                <= wlast_reg;
        wvalid               <= wvalid_reg;
        case crnt_state is

            -------------------------------------------------------------------
            -- IDLE STATE
            -- Waits in this state untill read and write transaction is
            -- initiated.
            -- Loads the counters.
            -- Generates appropriate gate signal (burst/single) which is used
            -- to let read transfer ack pass to the IPIF.
            -------------------------------------------------------------------

            when IDLE =>

                transaction_done_cmb    <= '1';

                --addressData_strobe_cmb  <= '1';
                address_strobe_cmb      <= '1';
                be_strobe_cmb           <= '1';
                data_strobe_cmb         <= '1';

                addr_cnt_rst_cmb        <= '1';
                cycle_cnt_ld_cmb        <= '1';
                cs_strobe_cmb           <= '1';
                mem_Addr_rst_cmb        <= '1';
                new_page                <= '0';
                addr_align_reg          <= '0';
                read_break_reg          <= '0';

               if (Bus2IP_WrReq = '1' and Thz_end = '1' and Bus2IP_Mem_CS = '1') then
                    --if Synch_mem = '0' and single_trans = '0' then
                    --if single_trans = '0' and Synch_mem = '1' then
                    --   --write_req_ack_cmb      <= '1';-- 09-12-2012
                    --   Write_req_data_ack_cmb <= '1';
                    --   Write_req_addr_ack_cmb <= '1';
                    --end if;
                  if single_trans = '1' and synch_mem = '1' then
                    --next_state         <= WAIT_WRITE_ACK;
                    wlast                 <= '1';
                  else
                    --next_state         <= WRITE;
                    wlast                 <= '0';
                  end if;
                    next_state         <= WRITE;
                    twr_load_cmb       <= '1';
                    twph_load_cmb      <= '1';
                    transaction_done_cmb  <= '0';
                    transaction_complete  <= '0';
                    addr_align_reg        <= '0';
                    wvalid                <= '1';

                elsif (Bus2IP_RdReq = '1' and Tlz_end = '1' and Bus2IP_Mem_CS = '1') then
                    -- read_req_ack_cmb   <= '1';
                    trd_load_cmb       <= '1';

                    mem_cen_cmb    <= not single_trans; -- '0'; -- 1/3/2013
                    mem_oen_cmb    <= not single_trans; -- '0'; -- 1/3/2013

                    if(Linear_flash_brst_rd_flag = '1')then
                        next_state         <= LINEAR_FLASH_SYNC_RD;
                        Adv_L_N            <= '0';
                        read_req_ack_cmb   <= '0';                        
                        --mem_cen_cmb    <= '0';-- 1/3/2013
                        --mem_oen_cmb    <= '0';-- 1/3/2013
                    else
                         read_req_ack_cmb   <= '1';                        
                         next_state         <= READ;
                    end if;
                    transaction_done_cmb    <= '0';
                    addr_align_reg  <= Addr_align;
                    transaction_complete    <= '0';
                end if;

            -------------------------------------------------------------------
            -- WRITE STATE
            -- Controls write operation to the memory.
            -- Generates control signals for write, address, and cycle end
            -- counters.
            -------------------------------------------------------------------

            when WRITE =>

               if axi_wlast = '1' and axi_wvalid = '1' then
                   wlast <= '1';
               end if;
                mem_cen_cmb  <= '0';
                mem_wen_cmb  <= '0';

                if (Bus2IP_Mem_CS_d2 = '1' and Bus2IP_Mem_CS_d1 = '0') then
                    transaction_complete   <= '1';
                end if;

                if (Twr_end = '1') then
                    -- sync mem starts
                    if Synch_mem = '1' then
                        if (Cycle_End = '1') then
                            if (Bus2IP_WrReq = '1' and axi_wvalid = '0' and wlast = '0') then
                                Write_req_data_ack_cmb <= '1';
                                Write_req_addr_ack_cmb <= '1';

                                address_strobe_cmb     <= '1';
                                be_strobe_cmb          <= '1';
                                data_strobe_cmb        <= '1';

                                addr_cnt_rst_cmb       <= '1';
                                cycle_cnt_ld_cmb       <= '1';

                                next_state         <= WRITE_WAIT;
                                wvalid                 <= '0';                            
                            elsif (Bus2IP_WrReq = '1' and (wvalid = '1' or axi_wvalid = '1'))then
                                --write_req_ack_cmb      <= '1';09-12-2012
                                --if axi_wvalid = '1' then
                                Write_req_data_ack_cmb <= '1';
                                Write_req_addr_ack_cmb <= '1';
                                --end if;

                                --addressData_strobe_cmb <= '1';09-12-2012
                                address_strobe_cmb     <= '1';
                                be_strobe_cmb          <= '1';
                                data_strobe_cmb        <= '1';

                                addr_cnt_rst_cmb       <= '1';
                                cycle_cnt_ld_cmb       <= '1';
                                --twr_load_cmb           <= '1'; NOT required in Sync Write mode
                            elsif (Bus2IP_WrReq = '1' and wlast = '1') then
                                Write_req_data_ack_cmb <= '1';
                                Write_req_addr_ack_cmb <= '1';
                                next_state         <= WAIT_WRITE_ACK;

                            elsif (Bus2IP_WrReq = '0') then
                                twr_rec_load_cmb       <= flash_mem_access;-- this can be moved to idle state set to 1
                                next_state             <= WAIT_WRITE_ACK;
                            else
                                next_state         <= WRITE;
                            end if;
                        else
                            --twr_load_cmb      <= '1'; -- not needed in sync write mode
                            cycle_cnt_en_cmb  <= '1';
                            addr_cnt_ce_cmb   <= '1';
                        end if;
                    -- sync mem ends
                    -- async mem starts
                    else
                        -- mem_cen_cmb  <= '1'; -- 1/3/2013
                        -- mem_wen_cmb  <= '1'; -- 1/3/2013
                        twph_cnt_en_cmb         <= '1';
                        next_state              <= DASSERT_WEN;
                        if single_trans = '1' then
                          --write_req_ack_cmb      <= '1';09-12-2012
                          --if(flash_mem_access = '1') then
                          --      Write_req_data_ack_cmb <= '0';
                          --  --elsif (axi_wvalid = '1') then
                          --  --    Write_req_data_ack_cmb <= '1';
                          --  else
                          --      Write_req_data_ack_cmb <= '1';
                          --end if;
                          --  --if axi_wvalid = '1' then
                          --Write_req_addr_ack_cmb <= '1';
                            --end if;
                        end if;
                    end if;
                    -- async mem ends
                else
                    twr_cnt_en_cmb  <= '1';
                end if;
            -----------------
            when WRITE_WAIT =>
                if (Bus2IP_WrReq = '1' and axi_wvalid = '1' ) then
                    next_state              <= WRITE;
                    wvalid                  <= '1';
                    if axi_wlast = '1' and axi_wvalid = '1' then
                        wlast <= '1';
                    end if;                    
                else
                    next_state              <= WRITE_WAIT;
                end if;
            when WAIT_TEMP =>
               if axi_wlast = '1' and axi_wvalid = '1' then
                   wlast <= '1';
               end if;                
                if (Bus2IP_WrReq = '1' and Thz_end = '1' ) then
                    --addressData_strobe_cmb  <= '1'; 09-12-2012
                    address_strobe_cmb      <= '1';
                    be_strobe_cmb           <= '1';
                    data_strobe_cmb         <= '1';

                    addr_cnt_rst_cmb        <= '1';
                    cycle_cnt_ld_cmb        <= '1';
                    cs_strobe_cmb           <= '1';
                    mem_Addr_rst_cmb        <= '1';
                    addr_align_reg          <= '0';
                    twr_load_cmb            <= '1';
                    next_state              <= WRITE;
                    addr_align_reg          <= '0';
                     twph_load_cmb     <= '1';
                     if (last_burst_cnt = '0' and
                         Synch_mem      = '0' and
                         single_trans   = '0') then 
                         --single_trans   = '0' and 
                         --axi_wvalid     = '1')then
                       --write_req_ack_cmb      <= '1';09-12-2012
                       Write_req_data_ack_cmb <= '1';
                       Write_req_addr_ack_cmb <= '1';
                    end if;
                elsif (transaction_complete = '1') or
                      (Bus2IP_Mem_CS = '0' and Bus2IP_WrReq = '0') then
                    twr_rec_load_cmb <= flash_mem_access;
                    next_state       <= WAIT_WRITE_ACK;
                else
                        next_state              <= WAIT_TEMP;
                end if;
            -------------------------------------------------------------------
            -- DASSERT_WEN STATE
            -- Comes to this state only when write operation is performed on
            -- asynchronous memory.This state performs NOP cycle on memory side.
            -- Generates control signals for write, address and cycle end
            -- counters.
            -------------------------------------------------------------------

            when DASSERT_WEN =>
               if axi_wlast = '1' and axi_wvalid = '1' then
                   wlast <= '1';
               end if;

                if (Cycle_End = '1') then
                    if (Bus2IP_WrReq = '1') then
                        if (twph_end = '1') then
                                -- write_req_ack_cmb      <= '1'; 09-12-2012
                                --if axi_wvalid = '1' then
                                Write_req_data_ack_cmb <= '1';
                                Write_req_addr_ack_cmb <= '1';
                                --end if;

                                --addressData_strobe_cmb <= '1';09-12-2012
                                address_strobe_cmb     <= '1';
                                be_strobe_cmb          <= '1';
                                data_strobe_cmb        <= '1';

                                addr_cnt_rst_cmb       <= '1';
                                cycle_cnt_ld_cmb       <= '1';
                                twr_load_cmb           <= '1';
                                twph_load_cmb           <= '1';
                                if (single_trans = '1') then
                                next_state             <= WAIT_WRITE_ACK;
                                twr_rec_load_cmb       <= flash_mem_access;
                                elsif (axi_wvalid = '1' or wlast = '1') then
                                next_state             <= WRITE;
                                else
                                next_state             <= WRITE_WAIT;
                                end if;
                        else
                                next_state             <= DASSERT_WEN;
                                twph_cnt_en_cmb        <= '1';
                        end if;
                    elsif (Bus2IP_Mem_CS = '1' and
                           Bus2IP_WrReq  = '0' and
                           Bus2IP_RdReq  = '0')then
                                if(last_addr1 = '1' and bus2ip_ben_all_1 = '1') then
                                    next_state             <= WRITE;
                                else
                                    next_state             <= WAIT_TEMP;
                                end if;
                                address_strobe_cmb     <= last_addr1;--
                                be_strobe_cmb          <= last_addr1;-- '1';
                                data_strobe_cmb        <= last_addr1;-- '1';
                                twr_rec_load_cmb       <= flash_mem_access;

                                -- write_req_ack_cmb      <= last_addr1;-- '0';09-12-2012
                                --if axi_wvalid = '1' then
                                Write_req_data_ack_cmb <= last_addr1;-- '0';
                                Write_req_addr_ack_cmb <= last_addr1;-- '0';
                                --end if;
                                addr_cnt_rst_cmb       <= '0';
                                cycle_cnt_ld_cmb       <= '0';
                                twr_load_cmb           <= '0';
                    else
                        twr_rec_load_cmb       <= flash_mem_access;
                        next_state             <= WAIT_WRITE_ACK;
                    end if;
                else
                  if (twph_end = '1') then
                    twr_load_cmb      <= '1';
                    cycle_cnt_en_cmb  <= '1';
                    addr_cnt_ce_cmb   <= '1';
                    twph_load_cmb     <= '1';
                    next_state        <= WRITE;
                  else
                    twph_cnt_en_cmb   <= '1';
                  end if;
                end if;

            -------------------------------------------------------------------
            -- WAIT_WRITE_ACK STATE
            -------------------------------------------------------------------

            when WAIT_WRITE_ACK =>
                    --if synch_mem = '1' then
                    --  Write_req_data_ack_cmb <= '1';
                    --  Write_req_addr_ack_cmb <= '1'; 
                    --end if;                        
                    if(flash_mem_access = '1') then
                        twr_rec_cnt_en_cmb <= '1';
                        next_state       <= WR_REC_PERIOD;
                    else
                        next_state    <= IDLE;
                    end if;
                    tlz_load_cmb          <= '1';
                    addr_cnt_rst_cmb      <= '1';
                    transaction_done_cmb  <= '1';
                    wlast  <= '0';

            when WR_REC_PERIOD =>
                    if(Twr_rec_end = '1')then
                        Flash_mem_access_disable <= '1';
                        --Write_req_data_ack_cmb <= '1';
                        next_state    <= IDLE;
                    else
                        twr_rec_cnt_en_cmb <= '1';
                                    next_state         <= WR_REC_PERIOD;
                    end if;



            -------------------------------------------------------------------
            -- READ STATE
            -- Controls read operation on memory.
            -- Generates control signals for read, address and cycle end
            -- counters
            -------------------------------------------------------------------
--             when LINEAR_FLASH_SYNC_RD =>
--                 mem_cen_cmb    <= '0';
--                 mem_oen_cmb    <= '0';
--
--                 if (Bus2IP_Mem_CS_d2 = '1' and Bus2IP_Mem_CS_d1 = '0') then
--                     transaction_complete   <= '1';
--                 end if;
--                if (Linear_flash_rd_data_ack = '1') then
--                      read_data_en_cmb  <= '1';
--                      addr_align_reg  <= Addr_align;
--                      if (Cycle_End = '1') then
--                              if ((Bus2IP_RdReq='1' or single_trans = '1')and
--                                              read_break_reg = '0'                   and
--                                              transaction_complete = '0') then
--                                              read_req_ack_cmb       <= '1';
--                                      addressData_strobe_cmb <= '1';
--                                      address_strobe_cmb     <= '1';
--                                      be_strobe_cmb          <= '1';
--                                      data_strobe_cmb        <= '1';
--                                      addr_cnt_rst_cmb       <= '1';
--                                      cycle_cnt_ld_cmb       <= '1';
--                                              next_state             <= LINEAR_FLASH_SYNC_RD;
--                              else
--                                              next_state             <= WAIT_RDDATA_ACK;
--                                              read_complete_cmb      <= '1';
--                                              read_data_en_cmb       <= '0';
--                              end if;
--                      else
--                            trd_load_cmb           <= '1';
--                            cycle_cnt_en_cmb       <= '1';
--                            addr_cnt_ce_cmb        <= '1';
--                    end if;
--                end if;

         when LINEAR_FLASH_SYNC_RD =>
                if (Bus2IP_Mem_CS_d2 = '1' and Bus2IP_Mem_CS_d1 = '0') then
                    transaction_complete   <= '1';
                end if;

                if (read_break= '1' and single_trans = '0') then
                        read_break_reg <= '1';
                end if;
                Adv_L_N                 <= '1';
                mem_cen_cmb    <= not Bus2IP_RdReq_emc; -- '0';
                mem_oen_cmb    <= not Bus2IP_RdReq_emc; -- '0';
                new_page       <= '0';
                -- added for abort condition
		        if (Mem_WAIT = '1') then                    
                    read_data_en_cmb  <= Linear_flash_rd_data_ack;
                    addr_align_reg  <= Addr_align;
                    if (Cycle_End = '1') then
                        if (Bus2IP_RdReq='1') then -- or single_trans = '1')and
                                                    -- read_break_reg = '0'                   and
                                                    -- transaction_complete = '0') then
                            read_req_ack_cmb       <= '1';

                            --addressData_strobe_cmb <= '1';09-12-2012
                            address_strobe_cmb     <= '1';
                            be_strobe_cmb          <= '1'; 
                            data_strobe_cmb        <= '1';
                            if (single_trans = '0') then
                              addr_cnt_rst_cmb       <= '1';
                            end if;
                            cycle_cnt_ld_cmb       <= '1';

                            trd_load_cmb       <= '1';
                            next_state         <= LINEAR_FLASH_SYNC_RD;
                        else
                            next_state             <= WAIT_RDDATA_ACK;
                            read_complete_cmb      <= '1';
                            read_data_en_cmb       <= '0';
                        end if;
                    else
                            trd_load_cmb           <= '1';
                            cycle_cnt_en_cmb       <= '1';
                            if (Bus2IP_RdReq='1') then
                              addr_cnt_ce_cmb        <= '1';
                            end if;
                            next_state         <= LINEAR_FLASH_SYNC_RD;
		    end if;
                else
                    if(Bus2IP_RdReq = '0') then
		        next_state             <= WAIT_RDDATA_ACK;
                        read_complete_cmb      <= '1';
	            else
		        next_state         <= LINEAR_FLASH_SYNC_RD;
		        trd_cnt_en_cmb  <= '1';
                    end if;
                end if;


            -------------------------------------------------------------------
            -- READ STATE
            -- Controls read operation on memory.
            -- Generates control signals for read, address and cycle end
            -- counters
            -------------------------------------------------------------------

            when READ =>
                --if (Bus2IP_Mem_CS_d2 = '1' and Bus2IP_Mem_CS_d1 = '0') then
                --    transaction_complete   <= '1';
                --end if;

                if (read_break= '1' and single_trans = '0') then
                        read_break_reg <= '1';
                end if;

               -- mem_cen_cmb    <= not (single_trans or Bus2IP_Burst); --'0';
               -- mem_oen_cmb    <= not(single_trans or Bus2IP_Burst); --'0';
                mem_cen_cmb    <= (synch_mem and stop_oen) or ((not synch_mem) and read_break_reg); --'0';
                mem_oen_cmb    <= (synch_mem and stop_oen) or ((not synch_mem) and read_break_reg); --'0';
                new_page       <= '0';

                -- added for abort condition
                if (Trd_end = '1') then
                    read_data_en_cmb  <= '1'; -- generates are read data ack
                    addr_align_reg  <= Addr_align;
                    if (Cycle_End = '1') then
                        if (Bus2IP_RdReq='1') then -- or single_trans = '1')and
                                                   -- read_break_reg = '0'                   and
                                                   -- transaction_complete = '0') then -- or (stop_oen = '0' and synch_mem = '1') then

                            read_req_ack_cmb       <= '1';--not last_addr1_d2; -- '1';

                            --addressData_strobe_cmb <= '1';09-12-2012
                            address_strobe_cmb     <= '1';--not last_addr1_d2; -- '1';
                            be_strobe_cmb          <= '1';
                            data_strobe_cmb        <= '1';
                            if (single_trans='0' or synch_mem = '1') then
                              addr_cnt_rst_cmb       <= '1'; -- Bus2IP_RdReq_emc;-- '1';-- Bus2IP_RdReq_emc; -- '1';
                            end if;
                            cycle_cnt_ld_cmb       <= '1';
                            tpacc_load_cmb <= '1';
                            if New_page_access = '0' then
                                next_state         <= PAGE_READ;
                                -- tpacc_cnt_en_cmb   <= '1';
				-- tpacc_load_cmb     <= '1'; -- 1/4/2013
                                cycle_cnt_en_cmb   <= '1';-- 1/12/2013
				                    addr_cnt_ce_cmb    <= '1';-- 1/12/2013
                            else
                                trd_load_cmb       <= '1';
                                next_state         <= READ;
                            end if;
                        else
                            next_state             <= WAIT_RDDATA_ACK;
                            read_complete_cmb      <= '1'; -- stop_oen; -- '1';
                            read_data_en_cmb       <= '1';
                        end if;
                    else
                               --if(read_break_reg = '1' and synch_mem = '0')then
                               -- next_state             <= WAIT_RDDATA_ACK;
                               -- read_complete_cmb      <= stop_oen;
                               --else
                               -- next_state             <= READ;
                               --end if;
                            if (Bus2IP_RdReq='1' or synch_mem = '1') then
                                addr_cnt_ce_cmb    <= '1';
                            end if;
                            if(New_page_access = '0') then
                                next_state         <= PAGE_READ;
                                tpacc_load_cmb     <= '1';
				                    --tpacc_cnt_en_cmb   <= '1';
				                    cycle_cnt_en_cmb   <= '1';-- 1/11/2013
				                    --addr_cnt_ce_cmb    <= '1';-- 1/11/2013
                            else
                                next_state         <= READ;
				                    trd_load_cmb       <= '1';
                                cycle_cnt_en_cmb   <= '1';
                                --addr_cnt_ce_cmb    <= '1';-- not last_addr1_d3; -- '1'; -- Bus2IP_RdReq; -- '1';
                    --        addr_cnt_rst_cmb       <= not Bus2IP_Burst; -- newly added
                            end if;
                    end if;
                else
                            if(read_break_reg = '1' and synch_mem = '0')then
                                next_state             <= WAIT_RDDATA_ACK;
				                    read_complete_cmb      <= '1';
                               -- read_complete_cmb      <= stop_oen;
                            else
                                next_state             <= READ;
                            end if;
                    --if(read_break = '1')then
                    --else
                    trd_cnt_en_cmb  <= '1';
                    -- end if;
                end if;




                -- added for abort condition
                -- if (Trd_end = '1') then
                --     read_data_en_cmb  <= '1'; -- generates are read data ack
                --     addr_align_reg  <= Addr_align;
                --     if (Cycle_End = '1') then
                --         if ((Bus2IP_RdReq='1' or single_trans = '1')and
                --              read_break_reg = '0'                   and
                --              transaction_complete = '0') then -- or (stop_oen = '0' and synch_mem = '1') then
                --
                --             read_req_ack_cmb       <= '1';--not last_addr1_d2; -- '1';
                --
                --             --addressData_strobe_cmb <= '1';09-12-2012
                --             address_strobe_cmb     <= '1';--not last_addr1_d2; -- '1';
                --             be_strobe_cmb          <= '1';
                --             data_strobe_cmb        <= '1';
                --
                --             addr_cnt_rst_cmb       <= Bus2IP_RdReq_emc;-- '1';-- Bus2IP_RdReq_emc; -- '1';
                --             cycle_cnt_ld_cmb       <= '1';
                --
                --             if New_page_access = '0' then
                --                 next_state         <= PAGE_READ;
                --                 tpacc_load_cmb     <= '1';
                --             else
                --                 trd_load_cmb       <= '1';
                --                 next_state         <= READ;
                --             end if;
                --         else
                --             next_state             <= WAIT_RDDATA_ACK;
                --             read_complete_cmb      <= '1'; -- stop_oen; -- '1';
                --             read_data_en_cmb       <= '1';
                --         end if;
                --     else
                --                --if(read_break_reg = '1' and synch_mem = '0')then
                --                -- next_state             <= WAIT_RDDATA_ACK;
                --                -- read_complete_cmb      <= stop_oen;
                --                --else
                --                -- next_state             <= READ;
                --                --end if;
                --             trd_load_cmb           <= '1';
                --             cycle_cnt_en_cmb       <= '1';
                --             addr_cnt_ce_cmb        <= '1';-- not last_addr1_d3; -- '1'; -- Bus2IP_RdReq; -- '1';
                --     --        addr_cnt_rst_cmb       <= not Bus2IP_Burst; -- newly added
                --     end if;
                -- else
                --             if(read_break_reg = '1' and synch_mem = '0')then
                --              next_state             <= WAIT_RDDATA_ACK;
                --              read_complete_cmb      <= stop_oen;
                --             else
                --              next_state             <= READ;
                --             end if;
                --     --if(read_break = '1')then
                --     --else
                --     trd_cnt_en_cmb  <= '1';
                --     -- end if;
                -- end if;

            -------------------------------------------------------------------
            -- PAGE_READ State =>
            -- Will do a page read when ever there is a page aligned boundry
            -------------------------------------------------------------------
            when PAGE_READ =>

                if (Bus2IP_Mem_CS_d2 = '1' and Bus2IP_Mem_CS_d1 = '0') then
                    transaction_complete   <= '1';
                end if;

                mem_cen_cmb    <= read_break_reg; -- not Bus2IP_Burst;-- read_break_reg; -- '0'; -- 1/4/2013
                mem_oen_cmb    <= read_break_reg; -- not Bus2IP_Burst;-- read_break_reg; -- '0'; -- 1/4/2013

                if (read_break= '1' and single_trans = '0') then
                        read_break_reg <= '1';
                end if;
                -- added for abort condition
                if (Tpacc_end = '1') then
                    addr_align_reg    <= Addr_align;
                    read_data_en_cmb  <= '1'; -- generates are read data ack
                    if (Cycle_End = '1') then
                        if (Bus2IP_RdReq = '1' --and
                            --read_break   = '0' and
                            --transaction_complete = '0'
			    ) then

                            read_req_ack_cmb       <= '1';
                           -- addressData_strobe_cmb <= '1';09-12-2012
                            address_strobe_cmb     <= '1';
                            be_strobe_cmb          <= '1';
                            data_strobe_cmb        <= '1';
                           if (single_trans = '0') then
                            addr_cnt_rst_cmb       <= '1';-- Bus2IP_RdReq_emc;-- '1';
                           end if;
                            cycle_cnt_ld_cmb       <= '1';

                            If new_page = '0' then
                                tpacc_load_cmb     <= '1';
                                next_state         <= PAGE_READ;
                            else
                                trd_load_cmb       <= '1';
                                next_state         <= READ;
                            end if;
                        else
                            next_state             <= WAIT_RDDATA_ACK;
                            read_complete_cmb      <= '1';
                            read_data_en_cmb       <= '0';-- '1'; 09-12-2012
                        end if;
                    else
                            tpacc_load_cmb         <= '1';
                            cycle_cnt_en_cmb       <= '1';
                        if (Bus2IP_RdReq = '1') then
                            addr_cnt_ce_cmb        <= '1';
                        end if;
                    end if;
                else
                    tpacc_cnt_en_cmb  <= '1';
                    if New_page_access = '1' then
                        new_page <= '1';
                    end if;
                end if;



            -------------------------------------------------------------------
            -- WAIT_RDDATA_ACK STATE
            -- Waits in this state till read data is received from memory.
            -------------------------------------------------------------------

            when WAIT_RDDATA_ACK =>

                if read_complete = '1' then
                    next_state    <= IDLE;
                    thz_load_cmb  <= '1';
                    transaction_done_cmb    <= '1';
                end if;
                    addr_align_reg    <= Addr_align;
                    new_page          <= '0';
                    addr_cnt_rst_cmb  <= '1';
                    read_data_en_cmb  <= '0';
                    read_break_reg    <= '0';

                    if (Bus2IP_Mem_CS_d2 = '1' and
                        Bus2IP_Mem_CS_d1 = '0') then
                       transaction_complete   <= '1';
                    end if;

        end case;
    end process SM_COMB_PROCESS;
end generate NEW_LOGIC_GEN;

    ---------------------------------------------------------------------------
    -- Read complete generation logic.
    -- 2 pipe stages = read command delay from State machine to IO reg.
    -- Delay require to get the data from memory.
    -- 1 pipe stage = Data coming from memory is registered first in IO reg and
    -- then goes to data steering logic.
    -- 2 pipe stage = Async memory, 3 pipe stage = sync memory (PipeDelay=1),
    -- 4 pipe stage = sync memory (PipeDelay=2).
    ---------------------------------------------------------------------------

    read_complete       <= read_complete_d(3) when Synch_mem = '0'
                           else
                           --read_complete_d(6) when (Synch_mem = '1' and  --10-12-2012
                           --                         Two_pipe_delay = '0')--10-12-2012
                           read_complete_d(4) when (Synch_mem = '1' and  --10-12-2012
                                                    Two_pipe_delay = '0')--10-12-2012
                           else
                           read_complete_d(6); -- read_complete_d(7);
    read_complete_d(0)  <= read_complete_cmb or (stop_oen and synch_mem);


    READ_COMPLETE_PIPE_GEN : for i in 0 to 6 generate

        READ_COMPLETE_PIPE: FDR
            port map (
                Q   => read_complete_d(i+1), --[out]
                C   => Clk,                  --[in]
                D   => read_complete_d(i),   --[in]
                R   => Rst                   --[in]
              );
    end generate READ_COMPLETE_PIPE_GEN;

    ---------------------------------------------------------------------------
    -- Register state_machine states.
    ---------------------------------------------------------------------------

    REG_STATES_PROCESS : process (Clk)
        begin
            if(Clk'EVENT and Clk = '1')then
                if(Rst = '1')then
                    crnt_state <= IDLE;
                else
                    crnt_state <= next_state;
                end if;
            end if;
        end process REG_STATES_PROCESS;

    REG_SIG_PROCESS : process (Clk)
        begin
            if(Clk'EVENT and Clk = '1')then
                if(Rst = '1')then
                    wlast_reg <= '0';
                    wvalid_reg <= '0';
                else
                    wlast_reg <= wlast;
                    wvalid_reg <= wvalid;
                end if;
            end if;
        end process REG_SIG_PROCESS;

    ADDR_ALLIGN_PROCESS : process (Clk)
        begin
            if(Clk'EVENT and Clk = '1')then
                if(Rst = '1')then
                    Addr_align_rd    <= '0';
                    addr_align_rd_d1 <= '0';
                    new_page_d1      <= '0';
                    transaction_complete_reg <= '0';
                    read_break_reg_d1    <= '0';

                else
                    new_page_d1      <= new_page;
                    addr_align_rd_d1 <= addr_align_reg;
                    Addr_align_rd    <= addr_align_rd_d1;
                    transaction_complete_reg <= transaction_complete;
                    read_break_reg_d1    <= read_break_reg;
                end if;
            end if;
        end process ADDR_ALLIGN_PROCESS ;

    ---------------------------------------------------------------------------
    -- Register memory control signals.
    ---------------------------------------------------------------------------

    MEM_SIGNALS_REG_PROCESS :process(Clk)
        begin
            if(Clk'EVENT and Clk = '1')then
                if (Rst = '1') then
                    mem_cen_reg  <='1';
                    mem_oen_reg  <='1';
                    mem_wen_reg  <='1';
                else
                    mem_cen_reg  <=mem_cen_cmb;
                    mem_oen_reg  <=mem_oen_cmb;
                    mem_wen_reg  <=mem_wen_cmb;
                end if;
            end if;
        end process MEM_SIGNALS_REG_PROCESS;

    ---------------------------------------------------------------------------
    -- Data strobe creation process. Used as strobe signal for Bus2Ip_Data and
    -- Bus2IP_BE.
    ---------------------------------------------------------------------------

    --DATA_STROBE_PROCESS :process(Clk)
    --    begin
    --        if(Clk'EVENT and Clk = '1')then
    --            if (Rst = '1') then
    --               -- Data_strobe  <='0';
    --            else
    --               -- Data_strobe  <= addressData_strobe_cmb;
    --            end if;
    --        end if;
    --    end process DATA_STROBE_PROCESS;

    --Data_strobe  <= addressData_strobe_cmb;09-12-2012
    Data_strobe <= '0';
    address_strobe_c    <= address_strobe_cmb;
    be_strobe_c         <= be_strobe_cmb     ;
    data_strobe_c       <= data_strobe_cmb   ;

    ---------------------------------------------------------------------------
    -- Register Addr_cnt control signals.
    ---------------------------------------------------------------------------

    ADDR_CNT_REG_PROCESS : process (Clk)
        begin
            if(Clk'EVENT and Clk = '1')then
                if(Rst = '1')then
                    addr_cnt_ce_reg <= '0';
                    addr_cnt_rst_reg<= '0';
                else
                    addr_cnt_ce_reg <= addr_cnt_ce_cmb;
                    addr_cnt_rst_reg<= addr_cnt_rst_cmb;
                end if;
            end if;
        end process ADDR_CNT_REG_PROCESS;

    ---------------------------------------------------------------------------
    -- Register cs_strobe_cmb signal.
    ---------------------------------------------------------------------------

    CS_STROBE_REG_PROCESS : process (Clk)
        begin
            if(Clk'EVENT and Clk = '1')then
                if(Rst = '1')then
                    cs_strobe_reg <= '0';
                else
                    cs_strobe_reg <= cs_strobe_cmb;
                end if;
            end if;
        end process CS_STROBE_REG_PROCESS;

    ---------------------------------------------------------------------------
    -- Register read_data_en_cmb signal.
    ---------------------------------------------------------------------------

    READ_DATA_EN_REG_PROCESS : process (Clk)
        begin
            if(Clk'EVENT and Clk = '1')then
                if(Rst = '1')then
                    read_data_en_reg <= '0';
                else
                    read_data_en_reg <= read_data_en_cmb;
                end if;
            end if;
        end process READ_DATA_EN_REG_PROCESS;

    ---------------------------------------------------------------------------
    -- Register Bus2IP_Mem_CS signal.
    ---------------------------------------------------------------------------

    CS_REG_PROCESS : process (Clk)
        begin
            if(Clk'EVENT and Clk = '1')then
                if(Rst = '1')then
                    Bus2IP_Mem_CS_d1 <= '0';
                    Bus2IP_Mem_CS_d2 <= '0';
                    Bus2IP_RdReq_d1 <= '0';
                    Bus2IP_RdReq_d2 <= '0';
                else
                    Bus2IP_Mem_CS_d1 <= Bus2IP_Mem_CS;
                    Bus2IP_Mem_CS_d2 <= Bus2IP_Mem_CS_d1;
                    Bus2IP_RdReq_d1 <= Bus2IP_RdReq;
                    Bus2IP_RdReq_d2 <= Bus2IP_RdReq_d1;
                end if;
            end if;
        end process CS_REG_PROCESS;

        read_break   <= (Bus2IP_RdReq_d1 and (not Bus2IP_RdReq));--(Bus2IP_RdReq_d2 and (not Bus2IP_RdReq_d1));
        Load_address <= (Bus2IP_Mem_CS_d1 and (not Bus2IP_Mem_CS_d2));

    ---------------------------------------------------------------------------
    -- Register transaction_done_cmb signal.
    ---------------------------------------------------------------------------

    TRAN_DONE_REG_PROCESS : process (Clk)
        begin
            if(Clk'EVENT and Clk = '1')then
                if(Rst = '1')then
                    transaction_done_reg <= '0';
                else
                    transaction_done_reg <= transaction_done_cmb;
                end if;
            end if;
        end process TRAN_DONE_REG_PROCESS;

    ---------------------------------------------------------------------------
    -- Register read_ack_cmb signal.
    ---------------------------------------------------------------------------

    READ_ACK_REG_PROCESS : process (Clk)
        begin
            if(Clk'EVENT and Clk = '1')then
                if(Rst = '1')then
                    read_ack_reg <= '0';
                else
                    read_ack_reg <= read_ack_cmb;
                end if;
            end if;
        end process READ_ACK_REG_PROCESS;
    LAST_ADDR_PROCESS : process (Clk)  -- 09-12-2012 added to make sure that sync read doesnt generate extra read address ack
        begin
            if(Clk'EVENT and Clk = '1')then
                if(Rst = '1')then
                    last_addr1_d1 <= '0';
                    last_addr1_d2 <= '0';
                    last_addr1_d3 <= '0';
                else
                    last_addr1_d1 <= last_addr1;
                    last_addr1_d2 <= last_addr1_d1;
                    last_addr1_d3 <= last_addr1_d2;
                end if;
            end if;
        end process LAST_ADDR_PROCESS;

    end architecture imp;

-------------------------------------------------------------------------------
-- End of File mem_state_machine.vhd
-------------------------------------------------------------------------------
