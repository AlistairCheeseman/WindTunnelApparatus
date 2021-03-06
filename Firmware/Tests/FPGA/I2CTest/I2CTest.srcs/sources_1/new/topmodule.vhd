----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.12.2015 15:39:44
-- Design Name: 
-- Module Name: topmodule - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity topmodule is
Port ( 
clk       : IN     STD_LOGIC; 

JA0       : INOUT  STD_LOGIC;
JA1       : INOUT  STD_LOGIC;
JA2       : OUT  STD_LOGIC;
JA3       : OUT  STD_LOGIC;
--RsRx : IN STD_LOGIC;
RsTx : OUT STD_LOGIC;
--RsCts : 
--RsRts :
btnCpuReset : IN STD_LOGIC
);

end topmodule;

architecture Behavioral of topmodule is
-- internal reset
signal resetin, reset, reset_n: std_logic;
-- serial to serialLoader signals
signal txd, ready, send: std_logic;
signal serialData: std_logic_vector (7 downto 0);
-- FIFO Signals serial loader to FIFO signals
signal FIFO_Empty, FIFO_Full, FIFO_ReadEn, FIFO_WriteEn: std_logic;
signal FIFO_DataOut, FIFO_DataIn: std_logic_vector (7 downto 0);
-- i2c internal signals
signal sda,scl :std_logic;
-- i2c control signal
signal ena,rw,busy,ack_error : std_logic;
signal addr     : std_logic_vector (6 downto 0);
signal data_rd  : std_logic_vector (7 downto 0);
signal  data_wr : std_logic_vector (7 downto 0):= "00000000";
begin



--wire up the global reset
resetDebounce_unit: entity work.debouncer(Behavioral)
    port map(
        resetin => resetin,
        resetout => reset,
        resetout_n => reset_n    
        );
    resetin <= btnCpuReset;

serial_unit: entity work.UART_TX_CTRL(Behavioral)
    port map(
        SEND        => send,
        DATA        => serialData,
        CLK         => clk,
        READY       => ready, 
        UART_TX     => txd
        );
    RsTx <= txd;
serialLoader_unit: entity work.serialLoader(Behavioral)
    port map (
    -- global clock
    clk             => clk, 
    reset =>    reset,
    --serial control signals
    S_Send          =>  send,
    S_DataOut       =>  serialData,
    S_Ready         =>  ready,
    --FIFO DATA
    FIFO_Empty      =>  FIFO_Empty,
    FIFO_Data       =>  FIFO_DataOut, 
    FIFO_ReadEn     =>  FIFO_ReadEn
    );
serialFIFObuffer_unit: entity work.STD_FIFO(Behavioral)
    port map (
    CLK		=> clk,
    RST     => reset,
    WriteEn => FIFO_WriteEn,
    DataIn  => FIFO_DataIn,
    ReadEn  => FIFO_ReadEn,
    DataOut => FIFO_DataOut,
    Empty   => FIFO_Empty,
    Full    => FIFO_Full
     );
i2cControl_unit: entity work.i2c_controller(Behavioral)
   port map (
        clk => clk,
        reset_n => reset_n,
        FIFO_WriteEn => FIFO_WriteEn,
        FIFO_DataIn => FIFO_DataIn,
        FIFO_Full => FIFO_Full,
        
        ena  => ena,
        addr =>  addr,
        rw   =>  rw,
        busy =>  busy,  
        data_rd => data_rd,
        ack_error => ack_error
        );  
i2ccomms_unit: entity work.i2c_master(logic) 
            port map (
            clk         => clk,
            reset_n   => reset_n,
            ena      => ena,
            addr     => addr,
            rw       => rw,
            data_wr   => data_wr,
            busy      => busy,
            data_rd   => data_rd,
            ack_error => ack_error,
            sda  => JA1,-- sda,
            scl  => JA0 --scl
           );
           JA2 <= ack_error;
           JA3 <= ena;
end Behavioral;
