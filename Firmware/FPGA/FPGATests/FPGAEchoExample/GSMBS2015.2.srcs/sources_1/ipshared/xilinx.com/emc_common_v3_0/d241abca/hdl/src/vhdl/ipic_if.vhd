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
-- Filename:        ipic_if.vhd
-- Description:     IPIC Interface
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
-- ~~~~~~~~
-- ^^^^^^^^
-- KSB         08/08/08    version v4_00_a
-- 1. This file is same as in version v3_00_a.
-- 2. Upgraded to version v4.00.a
-- ~~~~~~~~
-- SK          10/07/10
-- ^^^^^^^^
-- 1. Added "clear_pend_rdreq <= '1' when ((burst_cnt_i = 0) and (Bus2IP_Burst = '0') and
                              --(Mem2Bus_RdAddrAck = '1')) or bus2Mem_CS_i = '0'
                              --  else
                              --'0' ;
-- 2.  condition for "clear_pend_wrreq". This is similar to "clear_pend_rdreq" .
-- ~~~~~~~~
-- SK          25/10/10
-- ^^^^^^^^
-- 1. Registered IP2bus_RdAck and IP2Bus_Data signals.
-- ~~~~~~~~
-- SK          24/11/10
-- ^^^^^^^^
-- 1. Added "Bus2IP_RdReq_emc = '0'" signal to reset the RDREQ_PROCESS.
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

use ieee.std_logic_misc.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
-------------------------------------------------------------------------------
library emc_common_v3_0;

-------------------------------------------------------------------------------
-- vcomponents package of the unisim library is used for the FDR component
-- declaration
-------------------------------------------------------------------------------
library unisim;
use unisim.vcomponents.all;
-------------------------------------------------------------------------------
-- Definition of Generics:
--  C_NUM_BANKS_MEM         -- Number of Memory Banks
--  C_IPIF_DWIDTH           -- Processor Data Bus Width
--
-- Definition of Ports:
--  Bus2IP_RNW              -- Processor read not write (1=Read, 0=Write)
--  Bus2IP_Mem_CS           -- Memory Channel Chip Select
--  Mem2Bus_RdAddrAck       -- Memory Read Cycle Address Acknowledge
--  Mem2Bus_WrAddrAck       -- Memory Write Cycle Address Acknowledge
--  Mem2Bus_RdAck           -- Memory Read Cycle Acknowledge
--  Mem2Bus_WrAck           -- Memory Write Cycle Acknowledge
--  Mem2Bus_Data            -- Memory Read Data
--  Bus2Mem_RdReq           -- Read request was seen by mem_state_machine
--  Bus2Mem_WrReq           -- Write request was seen by mem_state_machine
--  Bus2Mem_CS              -- Memory is being accessed
--  IP2Bus_Data             -- Read data from memory device or register
--  IP2Bus_errAck           -- Error acknowledge
--  IP2Bus_retry            -- Retry indicator
--  IP2Bus_toutSup          -- Suppress watch dog timer
--  IP2Bus_RdAck            -- Read acknowledge
--  IP2Bus_WrAck            -- Write acknowledge
--  IP2Bus_AddrAck          -- Address acknowledge
--  Burst_length            -- Count of current burst length
--  Transaction_done        -- Operation complete indication for current
--                          -- transaction
--  Bus2IP_Clk              -- System clock
--  Bus2IP_Reset            -- System Reset
-------------------------------------------------------------------------------
-- Port declarations
-------------------------------------------------------------------------------

entity ipic_if is
    generic (
        C_NUM_BANKS_MEM     : integer := 2;

        C_IPIF_DWIDTH       : integer := 64
    );
    port (
        Bus2IP_Clk          : in  std_logic;
        Bus2IP_Reset        : in  std_logic;

        Bus2IP_RNW          : in  std_logic;
        Bus2IP_Mem_CS       : in  std_logic_vector(0 to C_NUM_BANKS_MEM-1);

        Mem2Bus_RdAddrAck   : in  std_logic;
        Mem2Bus_WrAddrAck   : in  std_logic;
        Mem2Bus_RdAck       : in  std_logic;
        Mem2Bus_WrAck       : in  std_logic;
        Bus2IP_WrReq        : in  std_logic;
        Bus2IP_RdReq        : in  std_logic;
        Mem2Bus_Data        : in  std_logic_vector(0 to C_IPIF_DWIDTH - 1);
        Bus2IP_Burst        : in  std_logic;

        Bus2IP_RdReq_emc : in  std_logic;
        Bus2IP_WrReq_emc : in  std_logic;

        Bus2Mem_CS          : out std_logic;
        Bus2Mem_RdReq       : out std_logic;
        Bus2Mem_WrReq       : out std_logic;

        Parity_err          : in  std_logic;

        IP2Bus_Data         : out std_logic_vector(0 to C_IPIF_DWIDTH - 1);
        IP2Bus_errAck       : out std_logic;
        IP2Bus_retry        : out std_logic;
        IP2Bus_toutSup      : out std_logic;
        IP2Bus_RdAck        : out std_logic;
        IP2Bus_WrAck        : out std_logic;
        IP2Bus_AddrAck      : out std_logic;
        Type_of_xfer        : in  std_logic;

        Burst_length        : in  std_logic_vector(0 to 7);
        Transaction_done    : in  std_logic;

        single_transaction  : in std_logic ;
        last_burst_cnt      : out std_logic;
	    pr_state_wait_temp_cmb : in std_logic;
        synch_mem              : in std_logic;                     -- 10-12-2012
        mem_width_bytes        : in std_logic_vector(0 to 3);
        stop_oen               : out std_logic;
	    axi_trans_size_reg         : in std_logic_vector(1 downto 0); -- 1/3/2013
	    Linear_flash_brst_rd_flag  : in std_logic -- 1/28/2013
    );
end entity ipic_if;

-------------------------------------------------------------------------------
-- Architecture section
-------------------------------------------------------------------------------

architecture imp of ipic_if is

----------------------------------------------------------------------------------
-- below attributes are added to reduce the synth warnings in Vivado tool
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of imp : architecture is "yes";
----------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Constant Declaration
-------------------------------------------------------------------------------
constant BURST_CNT_WIDTH      : integer := 8;
constant ZERO_CNT             : std_logic_vector(0 to BURST_CNT_WIDTH -1)
                                                             := (others=>'0');
-------------------------------------------------------------------------------
-- Signal Declaration
-------------------------------------------------------------------------------

signal bus2mem_cs_i           : std_logic;
signal burst_cnt_en           : std_logic;
signal burst_cnt_ld_cmb       : std_logic;
signal pend_wrreq             : std_logic;
signal set_pend_wrreq         : std_logic;
signal clear_pend_wrreq       : std_logic;

signal pend_rdreq             : std_logic;
signal set_pend_rdreq         : std_logic;
signal clear_pend_rdreq       : std_logic;

signal burst_cnt_i            : std_logic_vector(0 to BURST_CNT_WIDTH - 1);

signal int_wrreq              : std_logic;
signal int_rdreq              : std_logic;
        ---remove this signal once fix is made to ipif
signal burst_length_i         :std_logic_vector(0 to BURST_CNT_WIDTH - 1);
signal bus2ip_mem_cs_reg      :std_logic;--_vector(0 to C_NUM_BANKS_MEM-1);

signal IP2Bus_AddrAck_d1      :std_logic;
signal burst_rst              :std_logic;
signal stop_init_rd           :std_logic;
signal reload_address         :std_logic;
signal reload_req             :std_logic;

signal IP2Bus_WrAck_i         :std_logic;
signal IP2Bus_AddrAck_i       :std_logic;
signal IP2Bus_RdAck_i         :std_logic;
signal reset_fifo             :std_logic;

signal burst_cnt_i_rdack : std_logic_vector(0 to BURST_CNT_WIDTH - 1);
signal diff_addr_rd_ack  : std_logic;
signal burst_cnt_en_rdack: std_logic;
signal first_rd_ack      : std_logic;
signal rd_ack_d1         : std_logic;
signal Bus2Mem_RdReq_int : std_logic;

signal bus2Mem_CS_reduce_reg : std_logic;
signal pr_state_wait_temp_reg: std_logic;
signal rd_cnt : std_logic_vector(3 downto 0);
signal stop_oen_int : std_logic;
-- signal stop_oen : std_logic;
-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------

begin -- architecture IMP

    ---------------------------------------------------------------------------
    -- IPIC
    ---------------------------------------------------------------------------
    burst_length_i      <= Burst_length(0 to BURST_CNT_WIDTH - 1);
    bus2Mem_CS_i        <= or_reduce(Bus2IP_Mem_CS); -- (bus2IP_Mem_CS_reg); -- 1/3/2013
    Bus2Mem_CS          <= bus2Mem_CS_i;
    IP2Bus_errAck       <= (Parity_err  or (not Type_of_xfer)) and
                                                        bus2Mem_CS_i;
    IP2Bus_retry        <= '0';
    IP2Bus_toutSup      <= bus2Mem_CS_i;
    --IP2Bus_Data         <= Mem2Bus_Data;
    int_wrreq           <= Bus2IP_WrReq and bus2Mem_CS_i;
    int_rdreq           <= Bus2IP_RdReq and bus2Mem_CS_i;

    ---------------------------------------------------------------------------
    -- Register the Bus2IP_Mem_CS
    ---------------------------------------------------------------------------

    CS_REG_PROCESS : process(Bus2IP_Clk)
    begin
        if(Bus2IP_Clk'EVENT and Bus2IP_Clk = '1') then
            if(Bus2IP_Reset = '1')then
                bus2IP_Mem_CS_reg  <= '0';--(others=>'0');
		pr_state_wait_temp_reg <= '0';
            else
                bus2IP_Mem_CS_reg  <= or_reduce(Bus2IP_Mem_CS);
		pr_state_wait_temp_reg <= pr_state_wait_temp_cmb;
        end if;
        end if;
    end process CS_REG_PROCESS;

    ONE_HOT_CS_PROCESS : process(Bus2IP_Clk)
    begin
        if(Bus2IP_Clk'EVENT and Bus2IP_Clk = '1') then
            if(Bus2IP_Reset = '1')then
                bus2Mem_CS_reduce_reg  <= '0';
            else
                bus2Mem_CS_reduce_reg  <= bus2Mem_CS_i;
            end if;
        end if;
    end process ONE_HOT_CS_PROCESS;
    ---------------------------------------------------------------------------
    -- Register the acks signals
    ---------------------------------------------------------------------------

    ACK_REG_PROCESS : process(Bus2IP_Clk)
    begin
        if(Bus2IP_Clk'EVENT and Bus2IP_Clk = '1') then
            if(Bus2IP_Reset = '1')then
		IP2Bus_Data       <= (others => '0');
                IP2Bus_RdAck      <= '0';
            else
		IP2Bus_Data       <= Mem2Bus_Data;
		IP2Bus_RdAck      <= Mem2Bus_RdAck and (Bus2Mem_RdReq_int or 
                                                single_transaction or 
							                    Linear_flash_brst_rd_flag);
            end if;
        end if;
    end process ACK_REG_PROCESS;

                IP2Bus_WrAck      <= Mem2Bus_WrAck;
                IP2Bus_AddrAck    <= (Mem2Bus_RdAddrAck or Mem2Bus_WrAddrAck) and
                                                (Bus2IP_WrReq or Bus2IP_RdReq);

    ---------------------------------------------------------------------------
    -- Burst length counter instantiation
    ---------------------------------------------------------------------------
        BURST_CNT: entity emc_common_v3_0.ld_arith_reg
            generic map (C_ADD_SUB_NOT  => false,
                         C_REG_WIDTH    => BURST_CNT_WIDTH,
                         C_RESET_VALUE  => ZERO_CNT,
                         C_LD_WIDTH     => BURST_CNT_WIDTH,
                         C_LD_OFFSET    => 0,
                         C_AD_WIDTH     => 1,
                         C_AD_OFFSET    => 0
                        )
            port map (   CK             => Bus2IP_Clk,
                         RST            => reset_fifo,
                         Q              => burst_cnt_i,
                         LD             => burst_length_i,
                         AD             => "1",
                         LOAD           => burst_cnt_ld_cmb,
                         OP             => burst_cnt_en
                         );


       ---------------------------------------------------------------------------
    -- Burst length counter instantiation -- For Read Ack
    ---------------------------------------------------------------------------
        BURST_CNT_RDACK: entity emc_common_v3_0.ld_arith_reg
            generic map (C_ADD_SUB_NOT  => false,
                         C_REG_WIDTH    => BURST_CNT_WIDTH,
                         C_RESET_VALUE  => ZERO_CNT,
                         C_LD_WIDTH     => BURST_CNT_WIDTH,
                         C_LD_OFFSET    => 0,
                         C_AD_WIDTH     => 1,
                         C_AD_OFFSET    => 0
                        )
            port map (   CK             => Bus2IP_Clk,
                         RST            => reset_fifo,
                         Q              => burst_cnt_i_rdack,
                         LD             => burst_length_i,
                         AD             => "1",
                         LOAD           => burst_cnt_ld_cmb,
                         OP             => burst_cnt_en_rdack
                         );
burst_cnt_en_rdack <= (diff_addr_rd_ack and Mem2Bus_RdAck);

diff_addr_rd_ack <= or_reduce(burst_cnt_i xor burst_cnt_i_rdack);

    ---------------------------------------------------------------------------
    -- Burst length counter control signals
    ---------------------------------------------------------------------------
    burst_cnt_en      <= (Mem2Bus_RdAddrAck or Mem2Bus_WrAddrAck) and
                                       (Bus2IP_WrReq or Bus2IP_RdReq);






    burst_cnt_ld_cmb    <= not(bus2Mem_CS_reduce_reg) and bus2Mem_CS_i;

    reset_fifo  <= Bus2IP_Reset or (not bus2Mem_CS_i);
    last_burst_cnt <= not (or_reduce(burst_cnt_i));
    ---------------------------------------------------------------------------
    -- Generation of pend_wrreq
    ---------------------------------------------------------------------------

    set_pend_wrreq   <= (not pend_wrreq) and Transaction_done and int_wrreq;
    clear_pend_wrreq <= '1' when ((burst_cnt_i = 0) and (Bus2IP_Burst = '0') and
                                        (Mem2Bus_WrAddrAck = '1'))or bus2Mem_CS_i = '0' else
                        '0' ;

    WRREQ_PROCESS : process(Bus2IP_Clk)
    begin
        if(Bus2IP_Clk'EVENT and Bus2IP_Clk = '1') then
            if(Bus2IP_Reset = '1')then
                pend_wrreq  <= '0';
            elsif set_pend_wrreq ='1' then
                pend_wrreq  <= '1';
            --elsif clear_pend_wrreq = '1' then
	    elsif(Bus2IP_Burst = '0' and (Mem2Bus_WrAddrAck = '1')) or
	         (bus2Mem_CS_i = '0') then
                pend_wrreq  <= '0';
        end if;
        end if;
    end process WRREQ_PROCESS;

    Bus2Mem_WrReq  <= (pend_wrreq and Bus2IP_WrReq);

    ---------------------------------------------------------------------------
    -- Generation of pend_rdreq
    ---------------------------------------------------------------------------

    set_pend_rdreq   <= (not pend_rdreq) and Transaction_done
                                         and int_rdreq;
    clear_pend_rdreq <= '1' when ((burst_cnt_i = 0) and (Bus2IP_Burst = '0') and
                                (Mem2Bus_RdAddrAck = '1')) or bus2Mem_CS_i = '0'
                                else
                        '0' ;

    RDREQ_PROCESS : process(Bus2IP_Clk)
    begin
        if(Bus2IP_Clk'EVENT and Bus2IP_Clk = '1') then
            if(Bus2IP_Reset = '1')then
                pend_rdreq  <= '0';
            elsif set_pend_rdreq = '1'then
                pend_rdreq  <= '1';
            elsif clear_pend_rdreq = '1' then -- 1/3/2013
	    -- elsif ((Bus2IP_Burst = '0')      and -- 1/3/2013
	    --        (Mem2Bus_RdAddrAck = '1') and -- 1/3/2013
	    --    (Bus2IP_RdReq_emc = '0')) or      -- 1/3/2013
	    --        (bus2Mem_CS_i = '0') then     -- 1/3/2013
                pend_rdreq  <= '0';
        end if;
        end if;
    end process RDREQ_PROCESS;


    Bus2Mem_RdReq_int  <= (pend_rdreq and (Bus2IP_RdReq or (diff_addr_rd_ack and Synch_mem)))
                          when (single_transaction = '0' or Synch_mem = '1')
                          else
                          Bus2IP_RdReq;

    Bus2Mem_RdReq <= Bus2Mem_RdReq_int;

    -- 10-12-2012
    RD_CNT_PROCESS : process(Bus2IP_Clk)
    begin
        if(Bus2IP_Clk'EVENT and Bus2IP_Clk = '1') then
            if(Transaction_done = '1')then
                rd_cnt  <= (others => '0');
            elsif diff_addr_rd_ack ='1' and Bus2IP_RdReq = '0' and stop_oen_int = '0' then
                rd_cnt  <= rd_cnt + 1;
            end if;
        end if;
    end process RD_CNT_PROCESS;

    -- stop_oen_int <= '1' when rd_cnt = "010" and mem_width_bytes = "0001" else -- 8 bit - reduced by 1 here
    --                 '1' when rd_cnt = "001" and mem_width_bytes = "0010" else -- 16 bit - reduced by 1 here
    --                 '1' when rd_cnt = "001" and mem_width_bytes = "0100" else -- 32 bit - reduced by 1 here
    --                 '0';
    
    STOP_OEN_GEN_PROCESS: process(axi_trans_size_reg,
                                  mem_width_bytes,
				  rd_cnt) is
    variable mem_width_and_size : std_logic_vector(5 downto 0);
    -----
    begin
    -----
    mem_width_and_size := mem_width_bytes & axi_trans_size_reg;

    case mem_width_and_size is
         when "000100" => -- axi byte access for 8 bit mem width
	                --if(rd_cnt = "0001")then
			--    stop_oen_int <= '1';
                        --else
			--    stop_oen_int <= '0';
			--end if;
                        stop_oen_int <= rd_cnt(0);
         when "000101" => -- axi HW access for 8 bit mem width
	                --if(rd_cnt = "0010")then
			--    stop_oen_int <= '1';
                        --else
			--    stop_oen_int <= '0';
			--end if;
			stop_oen_int <= rd_cnt(1);
         when "000110" => -- axi WORD access for 8 bit mem width
	                --if(rd_cnt = "0100")then
			--    stop_oen_int <= '1';
                        --else
			--    stop_oen_int <= '0';
			--end if;
			stop_oen_int <= rd_cnt(2);
         when "000111" => -- axi Double WORD access for 8 bit mem width
	                --if(rd_cnt = "1000")then
			--    stop_oen_int <= '1';
                        --else
			--    stop_oen_int <= '0';
			--end if;
			stop_oen_int <= rd_cnt(3);
         --------------- for 16 bit mem width
         when "001000" => -- axi byte access for 16 bit mem width
	                --if(rd_cnt = "0001")then
			--    stop_oen_int <= '1';
                        --else
			--    stop_oen_int <= '0';
			--end if;
			stop_oen_int <= rd_cnt(0);
         when "001001" => -- axi HW access for 16 bit mem width
	                --if(rd_cnt = "0001")then
			--    stop_oen_int <= '1';
                        --else
			--    stop_oen_int <= '0';
			--end if;
			stop_oen_int <= rd_cnt(0);
         when "001010" => -- axi WORD access for 16 bit mem width
	                --if(rd_cnt = "0010")then
			--    stop_oen_int <= '1';
                        --else
			--    stop_oen_int <= '0';
			--end if;
			stop_oen_int <= rd_cnt(1);
         when "001011" => -- axi DOUBLE WORD access for 16 bit mem width
	                --if(rd_cnt = "0100")then
			--    stop_oen_int <= '1';
                        --else
			--    stop_oen_int <= '0';
			--end if;
			stop_oen_int <= rd_cnt(2);
	 --------------- for 32 bit mem width
         when "010000" => -- axi byte access for 32 bit mem width
	                --if(rd_cnt = "0001")then
			--    stop_oen_int <= '1';
                        --else
			--    stop_oen_int <= '0';
			--end if;
			stop_oen_int <= rd_cnt(0);
         when "010001" => -- axi HW access for 32 bit mem width
	                --if(rd_cnt = "0001")then
			--    stop_oen_int <= '1';
                        --else
			--    stop_oen_int <= '0';
			--end if;
			stop_oen_int <= rd_cnt(0);
         when "010010" => -- axi WORD access for 32 bit mem width
	                --if(rd_cnt = "0001")then
			--    stop_oen_int <= '1';
                        --else
			--    stop_oen_int <= '0';
			--end if;
			stop_oen_int <= rd_cnt(0);
         when "010011" => -- axi DPOUBLE WORD access for 32 bit mem width
	                --if(rd_cnt = "0010")then
			--    stop_oen_int <= '1';
                        --else
			--    stop_oen_int <= '0';
			--end if;
			stop_oen_int <= rd_cnt(1);
         --------------- for 64 bit mem width
         when "100000" | -- axi byte access        for 64 bit mem width
	      "100001" | -- axi HW access          for 64 bit mem width
	      "100010" | -- axi WORD access        for 64 bit mem width
	      "100011" =>-- axi DOUBLE WORD access for 64 bit mem width 
	                --if(rd_cnt = "0001")then
			--    stop_oen_int <= '1';
                        --else
			--    stop_oen_int <= '0';
			--end if;
			stop_oen_int <= rd_cnt(0);
         ---------------
	 when others =>    stop_oen_int <= '0';
    end case;   
 
    end process STOP_OEN_GEN_PROCESS;

    stop_oen <= stop_oen_int;
end imp;
-------------------------------------------------------------------------------
-- End of File ipic_if.vhd
-------------------------------------------------------------------------------
