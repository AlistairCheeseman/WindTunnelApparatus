----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.02.2016 21:28:53
-- Design Name: 
-- Module Name: DataSequencer - Behavioral
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

entity DataSequencer is
  Port (
      clk :in STD_LOGIC;
  reset : in STD_LOGIC;
  S_FIFO_WriteEn : out STD_LOGIC;
  S_FIFO_DataIn : out STD_LOGIC_VECTOR ( 7 downto 0);
  S_FIFO_Full : in STD_LOGIC;
  --sensor 1
  I2C1_FIFO_ReadEn : out STD_LOGIC;
  I2C1_FIFO_DataOut : in STD_LOGIC_VECTOR ( 7 downto 0);
  I2C1_FIFO_Empty : in STD_LOGIC;
  --sensor 2
  I2C2_FIFO_ReadEn : out STD_LOGIC;
  I2C2_FIFO_DataOut : in STD_LOGIC_VECTOR ( 7 downto 0);
  I2C2_FIFO_Empty : in STD_LOGIC;
 --sensor 3
  I2C3_FIFO_ReadEn : out STD_LOGIC;
  I2C3_FIFO_DataOut : in STD_LOGIC_VECTOR ( 7 downto 0);
  I2C3_FIFO_Empty : in STD_LOGIC;
  --sensor 4
  I2C4_FIFO_ReadEn : out STD_LOGIC;
  I2C4_FIFO_DataOut : in STD_LOGIC_VECTOR ( 7 downto 0);
  I2C4_FIFO_Empty : in STD_LOGIC;
  --sensor 5
  I2C5_FIFO_ReadEn : out STD_LOGIC;
  I2C5_FIFO_DataOut : in STD_LOGIC_VECTOR ( 7 downto 0);
  I2C5_FIFO_Empty : in STD_LOGIC;
  --sensor 6
  I2C6_FIFO_ReadEn : out STD_LOGIC;
  I2C6_FIFO_DataOut : in STD_LOGIC_VECTOR ( 7 downto 0);
  I2C6_FIFO_Empty : in STD_LOGIC;
  --sensor 7
  I2C7_FIFO_ReadEn : out STD_LOGIC;
  I2C7_FIFO_DataOut : in STD_LOGIC_VECTOR ( 7 downto 0);
  I2C7_FIFO_Empty : in STD_LOGIC;
  --sensor 8
  I2C8_FIFO_ReadEn : out STD_LOGIC;
  I2C8_FIFO_DataOut : in STD_LOGIC_VECTOR ( 7 downto 0);
  I2C8_FIFO_Empty : in STD_LOGIC;
  --sensor 9
  I2C9_FIFO_ReadEn : out STD_LOGIC;
  I2C9_FIFO_DataOut : in STD_LOGIC_VECTOR ( 7 downto 0);
  I2C9_FIFO_Empty : in STD_LOGIC;
  --sensor 10
  I2C10_FIFO_ReadEn : out STD_LOGIC;
  I2C10_FIFO_DataOut : in STD_LOGIC_VECTOR ( 7 downto 0);
  I2C10_FIFO_Empty : in STD_LOGIC

   );
end DataSequencer;

architecture Behavioral of DataSequencer is
  type state_type is ( STATE_WAIT, STATE_STARTREAD, STATE_ENDREAD, STATE_WAITFULL,  STATE_STARTWRITE, STATE_FINISHWRITE,STATE_CLOCKIN, STATE_UPDATEMUX);
  signal state_reg: state_type := STATE_WAIT;
  
  signal current_FIFO_ReadEn : STD_LOGIC;
  signal current_FIFO_Empty : STD_LOGIC;
  signal current_FIFO_DataOut : STD_LOGIC_VECTOR ( 7 downto 0);
  
  signal multiplexerState : INTEGER RANGE 0 to 9 := 0;
  signal timeoutCount     : INTEGER RANGE 0 to 20000:= 0; -- wait 1ms before a timeout.
  signal currentByteCount : INTEGER RANGE 0 to 6:= 0; --6 bytes of data per sensor.
begin

process (clk, current_FIFO_Empty, S_FIFO_Full, reset) -- process to handle the next state
begin
if (reset = '1') then
    --reset state:
    current_FIFO_ReadEn <= '0';
    S_FIFO_WriteEn <= '0';
    state_reg <= STATE_WAIT;
    multiplexerState <= 0;
    timeoutCount <= 0;
else
    if rising_edge (clk) then
    case state_reg is
            when STATE_UPDATEMUX =>
                -- when a read has just completed or a timeout has occured.
                timeoutCount <= 0; -- reset the timeout counter
                if (currentByteCount = 5) then
                    currentByteCount <= 0;
                    if (multiplexerState = 9) then -- update multiplexer to next sensor.
                        multiplexerState <= 0;
                    else
                        multiplexerState <= multiplexerState +1;
                    end if;
                else
                    currentByteCount <= currentByteCount +1;
                end if;
                state_reg <= STATE_WAIT;
            when STATE_WAIT =>
                    if (current_FIFO_Empty = '1') then
                        timeoutCount <= timeoutCount + 1; -- increase the timeout count.
                        if (timeoutCount = 2000) then
                            state_reg <= STATE_UPDATEMUX; -- timeout has occured, move to the next sensor.
                        else
                            state_reg <= STATE_WAIT; -- else carry on waiting.
                        end if;
                    else
                        state_reg <= STATE_STARTREAD;
                    end if;
            when STATE_STARTREAD =>
                -- request the data
                current_FIFO_ReadEn <= '1';
                state_reg <= STATE_ENDREAD;
            when STATE_ENDREAD =>
                current_FIFO_ReadEn <= '0';
                state_reg <= STATE_CLOCKIN;
            when STATE_CLOCKIN =>
                --clock the data out
                S_FIFO_DataIn <= current_FIFO_DataOut;
                if ('0' = S_FIFO_Full) then 
                    state_reg <= STATE_STARTWRITE;
                else
                    state_reg <= STATE_WAITFULL;
                end if;
            when STATE_WAITFULL =>
                if (S_FIFO_Full = '0') then
                    state_reg <= STATE_STARTWRITE;
                else
                    state_reg <= STATE_WAITFULL;
                end if;
            when STATE_STARTWRITE =>
                S_FIFO_WriteEn <= '1';
                state_reg <= STATE_FINISHWRITE;
            when STATE_FINISHWRITE => 
                S_FIFO_WriteEn <= '0';
                state_reg <= STATE_UPDATEMUX;
            when others =>
                state_reg <= STATE_WAIT;
    end case;
    end if;
end if;    
end process;


-- select the correct signal according to the multiplexer value.
process (multiplexerState, 
I2C1_FIFO_Empty, I2C1_FIFO_DataOut,
I2C2_FIFO_Empty, I2C2_FIFO_DataOut,
I2C3_FIFO_Empty, I2C3_FIFO_DataOut,
I2C4_FIFO_Empty, I2C4_FIFO_DataOut,
I2C5_FIFO_Empty, I2C5_FIFO_DataOut,
I2C6_FIFO_Empty, I2C6_FIFO_DataOut,
I2C7_FIFO_Empty, I2C7_FIFO_DataOut,
I2C8_FIFO_Empty, I2C8_FIFO_DataOut,
I2C9_FIFO_Empty, I2C9_FIFO_DataOut,
I2C10_FIFO_Empty, I2C10_FIFO_DataOut,
current_FIFO_ReadEn
) is
begin    
    case multiplexerState is
        when 0 =>
            I2C1_FIFO_ReadEn <= current_FIFO_ReadEn;
            current_FIFO_Empty <= I2C1_FIFO_Empty;
            current_FIFO_DataOut <= I2C1_FIFO_DataOut;
        when 1 =>
            I2C2_FIFO_ReadEn <= current_FIFO_ReadEn;
            current_FIFO_Empty <= I2C2_FIFO_Empty;
            current_FIFO_DataOut <= I2C2_FIFO_DataOut;
        when 2 =>
            I2C3_FIFO_ReadEn <= current_FIFO_ReadEn;
            current_FIFO_Empty <= I2C3_FIFO_Empty;
            current_FIFO_DataOut <= I2C3_FIFO_DataOut;
        when 3 =>
            I2C4_FIFO_ReadEn <= current_FIFO_ReadEn;
            current_FIFO_Empty <= I2C4_FIFO_Empty;
            current_FIFO_DataOut <= I2C4_FIFO_DataOut;
        when 4 =>
            I2C5_FIFO_ReadEn <= current_FIFO_ReadEn;
            current_FIFO_Empty <= I2C5_FIFO_Empty;
            current_FIFO_DataOut <= I2C5_FIFO_DataOut;
        when 5 =>
            I2C6_FIFO_ReadEn <= current_FIFO_ReadEn;
            current_FIFO_Empty <= I2C6_FIFO_Empty;
            current_FIFO_DataOut <= I2C6_FIFO_DataOut;
        when 6 =>
            I2C7_FIFO_ReadEn <= current_FIFO_ReadEn;
            current_FIFO_Empty <= I2C7_FIFO_Empty;
            current_FIFO_DataOut <= I2C7_FIFO_DataOut;
        when 7 =>
            I2C8_FIFO_ReadEn <= current_FIFO_ReadEn;
            current_FIFO_Empty <= I2C8_FIFO_Empty;
            current_FIFO_DataOut <= I2C8_FIFO_DataOut;
        when 8 =>
            I2C9_FIFO_ReadEn <= current_FIFO_ReadEn;
            current_FIFO_Empty <= I2C9_FIFO_Empty;
            current_FIFO_DataOut <= I2C9_FIFO_DataOut;
        when 9 =>
            I2C10_FIFO_ReadEn <= current_FIFO_ReadEn;
            current_FIFO_Empty <= I2C10_FIFO_Empty;
            current_FIFO_DataOut <= I2C10_FIFO_DataOut;
        when others =>        
    end case;
end process;


end Behavioral;
