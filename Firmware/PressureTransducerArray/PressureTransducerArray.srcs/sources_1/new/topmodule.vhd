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

SCL1       : INOUT  STD_LOGIC;
SDA1       : INOUT  STD_LOGIC;
SCL2       : INOUT  STD_LOGIC;
SDA2       : INOUT  STD_LOGIC;
SCL3       : INOUT  STD_LOGIC;
SDA3       : INOUT  STD_LOGIC;
SCL4       : INOUT  STD_LOGIC;
SDA4       : INOUT  STD_LOGIC;
SCL5       : INOUT  STD_LOGIC;
SDA5       : INOUT  STD_LOGIC;
SCL6       : INOUT  STD_LOGIC;
SDA6       : INOUT  STD_LOGIC;
SCL7       : INOUT  STD_LOGIC;
SDA7       : INOUT  STD_LOGIC;
SCL8       : INOUT  STD_LOGIC;
SDA8       : INOUT  STD_LOGIC;
SCL9       : INOUT  STD_LOGIC;
SDA9       : INOUT  STD_LOGIC;
SCL10       : INOUT  STD_LOGIC;
SDA10       : INOUT  STD_LOGIC;
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
signal Serial_FIFO_Empty, Serial_FIFO_Full, Serial_FIFO_ReadEn, Serial_FIFO_WriteEn: std_logic;
signal Serial_FIFO_DataOut, Serial_FIFO_DataIn: std_logic_vector (7 downto 0);

--SENSORS:
-- Global stuff
constant I2C_RW           : std_logic := '1'; -- we will always be reading so we can set this constant
constant I2C_DELIMETER    : std_logic_vector (7 downto 0):= "00000000"; -- the byte that will be between each reading.
constant I2C_ADDR         : std_logic_vector (6 downto 0):= "0101000";  -- the address of the 
--SENSOR1:
constant I2C1_Id : std_Logic_vector (7 downto 0) := "00000001"; -- id for this sensor
-- I2C Signals I2C loader to FIFO signals
signal I2C1_FIFO_Empty, I2C1_FIFO_Full, I2C1_FIFO_ReadEn, I2C1_FIFO_WriteEn: std_logic;
signal I2C1_FIFO_DataOut, I2C1_FIFO_DataIn: std_logic_vector (7 downto 0);
-- I2C control signals
signal I2C1_ENA,I2C1_RW,I2C1_BUSY,I2C1_ACK_ERROR : std_logic;
signal I2C1_DATA_RD  : std_logic_vector (7 downto 0);
signal I2C1_DATA_WR : std_logic_vector (7 downto 0):= "00000000";
--SENSOR2:
constant I2C2_Id : std_Logic_vector (7 downto 0) := "00000010"; -- id for this sensor
-- I2C Signals I2C loader to FIFO signals
signal I2C2_FIFO_Empty, I2C2_FIFO_Full, I2C2_FIFO_ReadEn, I2C2_FIFO_WriteEn: std_logic;
signal I2C2_FIFO_DataOut, I2C2_FIFO_DataIn: std_logic_vector (7 downto 0);
-- I2C control signals
signal I2C2_ENA,I2C2_RW,I2C2_BUSY,I2C2_ACK_ERROR : std_logic;
signal I2C2_DATA_RD  : std_logic_vector (7 downto 0);
signal I2C2_DATA_WR : std_logic_vector (7 downto 0):= "00000000";
--SENSOR3:
constant I2C3_Id : std_Logic_vector (7 downto 0) := "00000011"; -- id for this sensor
-- I2C Signals I2C loader to FIFO signals
signal I2C3_FIFO_Empty, I2C3_FIFO_Full, I2C3_FIFO_ReadEn, I2C3_FIFO_WriteEn: std_logic;
signal I2C3_FIFO_DataOut, I2C3_FIFO_DataIn: std_logic_vector (7 downto 0);
-- I2C control signals
signal I2C3_ENA,I2C3_RW,I2C3_BUSY,I2C3_ACK_ERROR : std_logic;
signal I2C3_DATA_RD  : std_logic_vector (7 downto 0);
signal I2C3_DATA_WR : std_logic_vector (7 downto 0):= "00000000";
--SENSOR4:
constant I2C4_Id : std_Logic_vector (7 downto 0) := "00000100"; -- id for this sensor
-- I2C Signals I2C loader to FIFO signals
signal I2C4_FIFO_Empty, I2C4_FIFO_Full, I2C4_FIFO_ReadEn, I2C4_FIFO_WriteEn: std_logic;
signal I2C4_FIFO_DataOut, I2C4_FIFO_DataIn: std_logic_vector (7 downto 0);
-- I2C control signals
signal I2C4_ENA,I2C4_RW,I2C4_BUSY,I2C4_ACK_ERROR : std_logic;
signal I2C4_DATA_RD  : std_logic_vector (7 downto 0);
signal I2C4_DATA_WR : std_logic_vector (7 downto 0):= "00000000";
--SENSOR5:
constant I2C5_Id : std_Logic_vector (7 downto 0) := "00000101"; -- id for this sensor
-- I2C Signals I2C loader to FIFO signals
signal I2C5_FIFO_Empty, I2C5_FIFO_Full, I2C5_FIFO_ReadEn, I2C5_FIFO_WriteEn: std_logic;
signal I2C5_FIFO_DataOut, I2C5_FIFO_DataIn: std_logic_vector (7 downto 0);
-- I2C control signals
signal I2C5_ENA,I2C5_RW,I2C5_BUSY,I2C5_ACK_ERROR : std_logic;
signal I2C5_DATA_RD  : std_logic_vector (7 downto 0);
signal I2C5_DATA_WR : std_logic_vector (7 downto 0):= "00000000";
--SENSOR6:
constant I2C6_Id : std_Logic_vector (7 downto 0) := "00000110"; -- id for this sensor
-- I2C Signals I2C loader to FIFO signals
signal I2C6_FIFO_Empty, I2C6_FIFO_Full, I2C6_FIFO_ReadEn, I2C6_FIFO_WriteEn: std_logic;
signal I2C6_FIFO_DataOut, I2C6_FIFO_DataIn: std_logic_vector (7 downto 0);
-- I2C control signals
signal I2C6_ENA,I2C6_RW,I2C6_BUSY,I2C6_ACK_ERROR : std_logic;
signal I2C6_DATA_RD  : std_logic_vector (7 downto 0);
signal I2C6_DATA_WR : std_logic_vector (7 downto 0):= "00000000";
--SENSOR7:
constant I2C7_Id : std_Logic_vector (7 downto 0) := "00000111"; -- id for this sensor
-- I2C Signals I2C loader to FIFO signals
signal I2C7_FIFO_Empty, I2C7_FIFO_Full, I2C7_FIFO_ReadEn, I2C7_FIFO_WriteEn: std_logic;
signal I2C7_FIFO_DataOut, I2C7_FIFO_DataIn: std_logic_vector (7 downto 0);
-- I2C control signals
signal I2C7_ENA,I2C7_RW,I2C7_BUSY,I2C7_ACK_ERROR : std_logic;
signal I2C7_DATA_RD  : std_logic_vector (7 downto 0);
signal I2C7_DATA_WR : std_logic_vector (7 downto 0):= "00000000";
--SENSOR8:
constant I2C8_Id : std_Logic_vector (7 downto 0) := "00001000"; -- id for this sensor
-- I2C Signals I2C loader to FIFO signals
signal I2C8_FIFO_Empty, I2C8_FIFO_Full, I2C8_FIFO_ReadEn, I2C8_FIFO_WriteEn: std_logic;
signal I2C8_FIFO_DataOut, I2C8_FIFO_DataIn: std_logic_vector (7 downto 0);
-- I2C control signals
signal I2C8_ENA,I2C8_RW,I2C8_BUSY,I2C8_ACK_ERROR : std_logic;
signal I2C8_DATA_RD  : std_logic_vector (7 downto 0);
signal I2C8_DATA_WR : std_logic_vector (7 downto 0):= "00000000";
--SENSOR9:
constant I2C9_Id : std_Logic_vector (7 downto 0) := "00001001"; -- id for this sensor
-- I2C Signals I2C loader to FIFO signals
signal I2C9_FIFO_Empty, I2C9_FIFO_Full, I2C9_FIFO_ReadEn, I2C9_FIFO_WriteEn: std_logic;
signal I2C9_FIFO_DataOut, I2C9_FIFO_DataIn: std_logic_vector (7 downto 0);
-- I2C control signals
signal I2C9_ENA,I2C9_RW,I2C9_BUSY,I2C9_ACK_ERROR : std_logic;
signal I2C9_DATA_RD  : std_logic_vector (7 downto 0);
signal I2C9_DATA_WR : std_logic_vector (7 downto 0):= "00000000";
--SENSOR10:
constant I2C10_Id : std_Logic_vector (7 downto 0) := "00001010"; -- id for this sensor
-- I2C Signals I2C loader to FIFO signals
signal I2C10_FIFO_Empty, I2C10_FIFO_Full, I2C10_FIFO_ReadEn, I2C10_FIFO_WriteEn: std_logic;
signal I2C10_FIFO_DataOut, I2C10_FIFO_DataIn: std_logic_vector (7 downto 0);
-- I2C control signals
signal I2C10_ENA,I2C10_RW,I2C10_BUSY,I2C10_ACK_ERROR : std_logic;
signal I2C10_DATA_RD  : std_logic_vector (7 downto 0);
signal I2C10_DATA_WR : std_logic_vector (7 downto 0):= "00000000";
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
    FIFO_Empty      =>  Serial_FIFO_Empty,
    FIFO_Data       =>  Serial_FIFO_DataOut, 
    FIFO_ReadEn     =>  Serial_FIFO_ReadEn
    );
serialFIFObuffer_unit: entity work.STD_FIFO(Behavioral)
    port map (
    CLK		=> clk,
    RST     => reset,
    WriteEn => Serial_FIFO_WriteEn,
    DataIn  => Serial_FIFO_DataIn,
    ReadEn  => Serial_FIFO_ReadEn,
    DataOut => Serial_FIFO_DataOut,
    Empty   => Serial_FIFO_Empty,
    Full    => Serial_FIFO_Full
     );
     
     
DataSequencer_unit: entity work.DataSequencer(Behavioral)
    port map (
    clk => clk,
    reset => reset,
    S_FIFO_WriteEn => Serial_FIFO_WriteEn,
    S_FIFO_DataIn => Serial_FIFO_DataIn,
    S_FIFO_Full => Serial_FIFO_Full,
    
    I2C1_FIFO_ReadEn    => I2C1_FIFO_ReadEn,
    I2C1_FIFO_DataOut   => I2C1_FIFO_DataOut,
    I2C1_FIFO_Empty     => I2C1_FIFO_Empty,
    
    I2C2_FIFO_ReadEn    => I2C2_FIFO_ReadEn,
    I2C2_FIFO_DataOut   => I2C2_FIFO_DataOut,
    I2C2_FIFO_Empty     => I2C2_FIFO_Empty,
    
    I2C3_FIFO_ReadEn    => I2C3_FIFO_ReadEn,
    I2C3_FIFO_DataOut   => I2C3_FIFO_DataOut,
    I2C3_FIFO_Empty     => I2C3_FIFO_Empty,
    
    I2C4_FIFO_ReadEn    => I2C4_FIFO_ReadEn,
    I2C4_FIFO_DataOut   => I2C4_FIFO_DataOut,
    I2C4_FIFO_Empty     => I2C4_FIFO_Empty,
    
    I2C5_FIFO_ReadEn    => I2C5_FIFO_ReadEn,
    I2C5_FIFO_DataOut   => I2C5_FIFO_DataOut,
    I2C5_FIFO_Empty     => I2C5_FIFO_Empty,
    
    I2C6_FIFO_ReadEn    => I2C6_FIFO_ReadEn,
    I2C6_FIFO_DataOut   => I2C6_FIFO_DataOut,
    I2C6_FIFO_Empty     => I2C6_FIFO_Empty,
    
    I2C7_FIFO_ReadEn    => I2C7_FIFO_ReadEn,
    I2C7_FIFO_DataOut   => I2C7_FIFO_DataOut,
    I2C7_FIFO_Empty     => I2C7_FIFO_Empty,
    
    I2C8_FIFO_ReadEn    => I2C8_FIFO_ReadEn,
    I2C8_FIFO_DataOut   => I2C8_FIFO_DataOut,
    I2C8_FIFO_Empty     => I2C8_FIFO_Empty,
    
    I2C9_FIFO_ReadEn    => I2C9_FIFO_ReadEn,
    I2C9_FIFO_DataOut   => I2C9_FIFO_DataOut,
    I2C9_FIFO_Empty     => I2C9_FIFO_Empty,
    
    I2C10_FIFO_ReadEn   => I2C10_FIFO_ReadEn,
    I2C10_FIFO_DataOut  => I2C10_FIFO_DataOut,
    I2C10_FIFO_Empty    => I2C10_FIFO_Empty
    
    );
-- LOGIC FOR SENSORS:
--SENSOR1:    
I2C1_FIFOBuffer_unit: entity work.STD_FIFO(Behavioral)
    port map (
        CLK		=> clk,
        RST     => reset,
        WriteEn => I2C1_FIFO_WriteEn,
        DataIn  => I2C1_FIFO_DataIn,
        ReadEn  => I2C1_FIFO_ReadEn,
        DataOut => I2C1_FIFO_DataOut,
        Empty   => I2C1_FIFO_Empty,
        Full    => I2C1_FIFO_Full
    );    
I2C1_Control_unit: entity work.i2c_controller(Behavioral)
   port map (
        clk =>              clk,
        reset_n =>          reset_n,
        FIFO_WriteEn =>     I2C1_FIFO_WriteEn,
        FIFO_DataIn =>      I2C1_FIFO_DataIn,
        FIFO_Full =>        I2C1_FIFO_Full,
        ena  =>             I2C1_ENA,
        busy =>             I2C1_BUSY,  
        data_rd =>          I2C1_DATA_RD,
        ack_error =>        I2C1_ACK_ERROR,
        sensorId =>         I2C1_Id,
        delimeter =>        I2C_DELIMETER
        );  
I2C1_Comms_unit: entity work.i2c_master(logic) 
            port map (
            clk         =>  clk,
            reset_n     =>  reset_n,
            ena         =>  I2C1_ENA,
            addr        =>  I2C_ADDR,
            rw          =>  I2C_RW,
            data_wr     =>  I2C1_DATA_WR,
            busy        =>  I2C1_BUSY,
            data_rd     =>  I2C1_DATA_RD,
            ack_error   =>  I2C1_ACK_ERROR,
            sda  =>         SDA1,-- sda,
            scl  =>         SCL1 --scl
           );
--SENSOR2:    
I2C2_FIFOBuffer_unit: entity work.STD_FIFO(Behavioral)
    port map (
        CLK		=> clk,
        RST     => reset,
        WriteEn => I2C2_FIFO_WriteEn,
        DataIn  => I2C2_FIFO_DataIn,
        ReadEn  => I2C2_FIFO_ReadEn,
        DataOut => I2C2_FIFO_DataOut,
        Empty   => I2C2_FIFO_Empty,
        Full    => I2C2_FIFO_Full
    );    
I2C2_Control_unit: entity work.i2c_controller(Behavioral)
   port map (
        clk =>              clk,
        reset_n =>          reset_n,
        FIFO_WriteEn =>     I2C2_FIFO_WriteEn,
        FIFO_DataIn =>      I2C2_FIFO_DataIn,
        FIFO_Full =>        I2C2_FIFO_Full,
        ena  =>             I2C2_ENA,
        busy =>             I2C2_BUSY,  
        data_rd =>          I2C2_DATA_RD,
        ack_error =>        I2C2_ACK_ERROR,
        sensorId =>         I2C2_Id,
        delimeter =>        I2C_DELIMETER
        );  
I2C2_Comms_unit: entity work.i2c_master(logic) 
            port map (
            clk         =>  clk,
            reset_n     =>  reset_n,
            ena         =>  I2C2_ENA,
            addr        =>  I2C_ADDR,
            rw          =>  I2C_RW,
            data_wr     =>  I2C2_DATA_WR,
            busy        =>  I2C2_BUSY,
            data_rd     =>  I2C2_DATA_RD,
            ack_error   =>  I2C2_ACK_ERROR,
            sda  =>         SDA2,-- sda,
            scl  =>         SCL2 --scl
           );
--SENSOR3:    
I2C3_FIFOBuffer_unit: entity work.STD_FIFO(Behavioral)
    port map (
        CLK		=> clk,
        RST     => reset,
        WriteEn => I2C3_FIFO_WriteEn,
        DataIn  => I2C3_FIFO_DataIn,
        ReadEn  => I2C3_FIFO_ReadEn,
        DataOut => I2C3_FIFO_DataOut,
        Empty   => I2C3_FIFO_Empty,
        Full    => I2C3_FIFO_Full
    );    
I2C3_Control_unit: entity work.i2c_controller(Behavioral)
   port map (
        clk =>              clk,
        reset_n =>          reset_n,
        FIFO_WriteEn =>     I2C3_FIFO_WriteEn,
        FIFO_DataIn =>      I2C3_FIFO_DataIn,
        FIFO_Full =>        I2C3_FIFO_Full,
        ena  =>             I2C3_ENA,
        busy =>             I2C3_BUSY,  
        data_rd =>          I2C3_DATA_RD,
        ack_error =>        I2C3_ACK_ERROR,
        sensorId =>         I2C3_Id,
        delimeter =>        I2C_DELIMETER
        );  
I2C3_Comms_unit: entity work.i2c_master(logic) 
            port map (
            clk         =>  clk,
            reset_n     =>  reset_n,
            ena         =>  I2C3_ENA,
            addr        =>  I2C_ADDR,
            rw          =>  I2C_RW,
            data_wr     =>  I2C3_DATA_WR,
            busy        =>  I2C3_BUSY,
            data_rd     =>  I2C3_DATA_RD,
            ack_error   =>  I2C3_ACK_ERROR,
            sda  =>         SDA3,-- sda,
            scl  =>         SCL3 --scl
           );
--SENSOR4:    
I2C4_FIFOBuffer_unit: entity work.STD_FIFO(Behavioral)
    port map (
        CLK		=> clk,
        RST     => reset,
        WriteEn => I2C4_FIFO_WriteEn,
        DataIn  => I2C4_FIFO_DataIn,
        ReadEn  => I2C4_FIFO_ReadEn,
        DataOut => I2C4_FIFO_DataOut,
        Empty   => I2C4_FIFO_Empty,
        Full    => I2C4_FIFO_Full
    );    
I2C4_Control_unit: entity work.i2c_controller(Behavioral)
   port map (
        clk =>              clk,
        reset_n =>          reset_n,
        FIFO_WriteEn =>     I2C4_FIFO_WriteEn,
        FIFO_DataIn =>      I2C4_FIFO_DataIn,
        FIFO_Full =>        I2C4_FIFO_Full,
        ena  =>             I2C4_ENA,
        busy =>             I2C4_BUSY,  
        data_rd =>          I2C4_DATA_RD,
        ack_error =>        I2C4_ACK_ERROR,
        sensorId =>         I2C4_Id,
        delimeter =>        I2C_DELIMETER
        );  
I2C4_Comms_unit: entity work.i2c_master(logic) 
            port map (
            clk         =>  clk,
            reset_n     =>  reset_n,
            ena         =>  I2C4_ENA,
            addr        =>  I2C_ADDR,
            rw          =>  I2C_RW,
            data_wr     =>  I2C4_DATA_WR,
            busy        =>  I2C4_BUSY,
            data_rd     =>  I2C4_DATA_RD,
            ack_error   =>  I2C4_ACK_ERROR,
            sda  =>         SDA4,-- sda,
            scl  =>         SCL4 --scl
           );
--SENSOR5:    
I2C5_FIFOBuffer_unit: entity work.STD_FIFO(Behavioral)
    port map (
        CLK		=> clk,
        RST     => reset,
        WriteEn => I2C5_FIFO_WriteEn,
        DataIn  => I2C5_FIFO_DataIn,
        ReadEn  => I2C5_FIFO_ReadEn,
        DataOut => I2C5_FIFO_DataOut,
        Empty   => I2C5_FIFO_Empty,
        Full    => I2C5_FIFO_Full
    );   
I2C5_Control_unit: entity work.i2c_controller(Behavioral)
   port map (
        clk =>              clk,
        reset_n =>          reset_n,
        FIFO_WriteEn =>     I2C5_FIFO_WriteEn,
        FIFO_DataIn =>      I2C5_FIFO_DataIn,
        FIFO_Full =>        I2C5_FIFO_Full,
        ena  =>             I2C5_ENA,
        busy =>             I2C5_BUSY,  
        data_rd =>          I2C5_DATA_RD,
        ack_error =>        I2C5_ACK_ERROR,
        sensorId =>         I2C5_Id,
        delimeter =>        I2C_DELIMETER
        );  
I2C5_Comms_unit: entity work.i2c_master(logic) 
            port map (
            clk         =>  clk,
            reset_n     =>  reset_n,
            ena         =>  I2C5_ENA,
            addr        =>  I2C_ADDR,
            rw          =>  I2C_RW,
            data_wr     =>  I2C5_DATA_WR,
            busy        =>  I2C5_BUSY,
            data_rd     =>  I2C5_DATA_RD,
            ack_error   =>  I2C5_ACK_ERROR,
            sda  =>         SDA5,-- sda,
            scl  =>         SCL5 --scl
           );
--SENSOR6:    
I2C6_FIFOBuffer_unit: entity work.STD_FIFO(Behavioral)
    port map (
        CLK		=> clk,
        RST     => reset,
        WriteEn => I2C6_FIFO_WriteEn,
        DataIn  => I2C6_FIFO_DataIn,
        ReadEn  => I2C6_FIFO_ReadEn,
        DataOut => I2C6_FIFO_DataOut,
        Empty   => I2C6_FIFO_Empty,
        Full    => I2C6_FIFO_Full
    );    
I2C6_Control_unit: entity work.i2c_controller(Behavioral)
   port map (
        clk =>              clk,
        reset_n =>          reset_n,
        FIFO_WriteEn =>     I2C6_FIFO_WriteEn,
        FIFO_DataIn =>      I2C6_FIFO_DataIn,
        FIFO_Full =>        I2C6_FIFO_Full,
        ena  =>             I2C6_ENA,
        busy =>             I2C6_BUSY,  
        data_rd =>          I2C6_DATA_RD,
        ack_error =>        I2C6_ACK_ERROR,
        sensorId =>         I2C6_Id,
        delimeter =>        I2C_DELIMETER
        );  
I2C6_Comms_unit: entity work.i2c_master(logic) 
            port map (
            clk         =>  clk,
            reset_n     =>  reset_n,
            ena         =>  I2C6_ENA,
            addr        =>  I2C_ADDR,
            rw          =>  I2C_RW,
            data_wr     =>  I2C6_DATA_WR,
            busy        =>  I2C6_BUSY,
            data_rd     =>  I2C6_DATA_RD,
            ack_error   =>  I2C6_ACK_ERROR,
            sda  =>         SDA6,-- sda,
            scl  =>         SCL6 --scl
           );
--SENSOR7:    
I2C7_FIFOBuffer_unit: entity work.STD_FIFO(Behavioral)
    port map (
        CLK		=> clk,
        RST     => reset,
        WriteEn => I2C7_FIFO_WriteEn,
        DataIn  => I2C7_FIFO_DataIn,
        ReadEn  => I2C7_FIFO_ReadEn,
        DataOut => I2C7_FIFO_DataOut,
        Empty   => I2C7_FIFO_Empty,
        Full    => I2C7_FIFO_Full
    );    
I2C7_Control_unit: entity work.i2c_controller(Behavioral)
   port map (
        clk =>              clk,
        reset_n =>          reset_n,
        FIFO_WriteEn =>     I2C7_FIFO_WriteEn,
        FIFO_DataIn =>      I2C7_FIFO_DataIn,
        FIFO_Full =>        I2C7_FIFO_Full,
        ena  =>             I2C7_ENA,
        busy =>             I2C7_BUSY,  
        data_rd =>          I2C7_DATA_RD,
        ack_error =>        I2C7_ACK_ERROR,
        sensorId =>         I2C7_Id,
        delimeter =>        I2C_DELIMETER
        );  
I2C7_Comms_unit: entity work.i2c_master(logic) 
            port map (
            clk         =>  clk,
            reset_n     =>  reset_n,
            ena         =>  I2C7_ENA,
            addr        =>  I2C_ADDR,
            rw          =>  I2C_RW,
            data_wr     =>  I2C7_DATA_WR,
            busy        =>  I2C7_BUSY,
            data_rd     =>  I2C7_DATA_RD,
            ack_error   =>  I2C7_ACK_ERROR,
            sda  =>         SDA7,-- sda,
            scl  =>         SCL7 --scl
           );
--SENSOR8:    
I2C8_FIFOBuffer_unit: entity work.STD_FIFO(Behavioral)
    port map (
        CLK		=> clk,
        RST     => reset,
        WriteEn => I2C8_FIFO_WriteEn,
        DataIn  => I2C8_FIFO_DataIn,
        ReadEn  => I2C8_FIFO_ReadEn,
        DataOut => I2C8_FIFO_DataOut,
        Empty   => I2C8_FIFO_Empty,
        Full    => I2C8_FIFO_Full
    );    
I2C8_Control_unit: entity work.i2c_controller(Behavioral)
   port map (
        clk =>              clk,
        reset_n =>          reset_n,
        FIFO_WriteEn =>     I2C8_FIFO_WriteEn,
        FIFO_DataIn =>      I2C8_FIFO_DataIn,
        FIFO_Full =>        I2C8_FIFO_Full,
        ena  =>             I2C8_ENA,
        busy =>             I2C8_BUSY,  
        data_rd =>          I2C8_DATA_RD,
        ack_error =>        I2C8_ACK_ERROR,
        sensorId =>         I2C8_Id,
        delimeter =>        I2C_DELIMETER
        );  
I2C8_Comms_unit: entity work.i2c_master(logic) 
            port map (
            clk         =>  clk,
            reset_n     =>  reset_n,
            ena         =>  I2C8_ENA,
            addr        =>  I2C_ADDR,
            rw          =>  I2C_RW,
            data_wr     =>  I2C8_DATA_WR,
            busy        =>  I2C8_BUSY,
            data_rd     =>  I2C8_DATA_RD,
            ack_error   =>  I2C8_ACK_ERROR,
            sda  =>         SDA8,-- sda,
            scl  =>         SCL8 --scl
           );
--SENSOR9:    
I2C9_FIFOBuffer_unit: entity work.STD_FIFO(Behavioral)
    port map (
        CLK		=> clk,
        RST     => reset,
        WriteEn => I2C9_FIFO_WriteEn,
        DataIn  => I2C9_FIFO_DataIn,
        ReadEn  => I2C9_FIFO_ReadEn,
        DataOut => I2C9_FIFO_DataOut,
        Empty   => I2C9_FIFO_Empty,
        Full    => I2C9_FIFO_Full
    );    
I2C9_Control_unit: entity work.i2c_controller(Behavioral)
   port map (
        clk =>              clk,
        reset_n =>          reset_n,
        FIFO_WriteEn =>     I2C9_FIFO_WriteEn,
        FIFO_DataIn =>      I2C9_FIFO_DataIn,
        FIFO_Full =>        I2C9_FIFO_Full,
        ena  =>             I2C9_ENA,
        busy =>             I2C9_BUSY,  
        data_rd =>          I2C9_DATA_RD,
        ack_error =>        I2C9_ACK_ERROR,
        sensorId =>         I2C9_Id,
        delimeter =>        I2C_DELIMETER
        );  
I2C9_Comms_unit: entity work.i2c_master(logic) 
            port map (
            clk         =>  clk,
            reset_n     =>  reset_n,
            ena         =>  I2C9_ENA,
            addr        =>  I2C_ADDR,
            rw          =>  I2C_RW,
            data_wr     =>  I2C9_DATA_WR,
            busy        =>  I2C9_BUSY,
            data_rd     =>  I2C9_DATA_RD,
            ack_error   =>  I2C9_ACK_ERROR,
            sda  =>         SDA9,-- sda,
            scl  =>         SCL9 --scl
           );
--SENSOR10:    
I2C10_FIFOBuffer_unit: entity work.STD_FIFO(Behavioral)
    port map (
        CLK		=> clk,
        RST     => reset,
        WriteEn => I2C10_FIFO_WriteEn,
        DataIn  => I2C10_FIFO_DataIn,
        ReadEn  => I2C10_FIFO_ReadEn,
        DataOut => I2C10_FIFO_DataOut,
        Empty   => I2C10_FIFO_Empty,
        Full    => I2C10_FIFO_Full
    );    
I2C10_Control_unit: entity work.i2c_controller(Behavioral)
   port map (
        clk =>              clk,
        reset_n =>          reset_n,
        FIFO_WriteEn =>     I2C10_FIFO_WriteEn,
        FIFO_DataIn =>      I2C10_FIFO_DataIn,
        FIFO_Full =>        I2C10_FIFO_Full,
        ena  =>             I2C10_ENA,
        busy =>             I2C10_BUSY,  
        data_rd =>          I2C10_DATA_RD,
        ack_error =>        I2C10_ACK_ERROR,
        sensorId =>         I2C10_Id,
        delimeter =>        I2C_DELIMETER
        );  
I2C10_Comms_unit: entity work.i2c_master(logic) 
            port map (
            clk         =>  clk,
            reset_n     =>  reset_n,
            ena         =>  I2C10_ENA,
            addr        =>  I2C_ADDR,
            rw          =>  I2C_RW,
            data_wr     =>  I2C10_DATA_WR,
            busy        =>  I2C10_BUSY,
            data_rd     =>  I2C10_DATA_RD,
            ack_error   =>  I2C10_ACK_ERROR,
            sda  =>         SDA10,-- sda,
            scl  =>         SCL10 --scl
           );
    
end Behavioral;
