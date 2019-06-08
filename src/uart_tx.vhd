library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity UART_Tx is
  generic (
    freq : positive := 50E6; -- The input clock frequency
    baudrate : positive := 115200 -- The baudrate to read
  );
  port (
    clk         : in  std_logic; -- The clock
	 rst			 : in  std_logic; -- The reset signal
	 Tx_Valid	 : in  std_logic; -- Is tx sendable
    Tx_Byte     : in  std_logic_vector(7 downto 0); -- The Tx byte to send
    
	Tx_Active : out std_logic;
    Tx_Serial : out std_logic;
    Tx_Done   : out std_logic
    );
end UART_Tx;
 
 
architecture rtl of UART_Tx is
  type EnumState is (Idle, Start, Data, Stop, Clear);
  signal state : EnumState := Idle;
  
  constant clk_per_bit : positive := (freq / baudrate)-1;
  
  signal clk_Count : integer range 0 to clk_per_bit := 0;
  signal index : integer range 0 to 7 := 0;  -- 8 Bits Total
  signal Tx_Data   : std_logic_vector(7 downto 0) := (others => '0');
  signal Done   : std_logic := '0';
   
begin
 
   
  process (clk, rst)
  begin
    if rst = '1' then
		state <= Idle;
	elsif rising_edge(Clk) then
         
      CASE(state) IS
 
        when Idle =>
          Tx_Active <= '0';
          Tx_Serial <= '1';         -- Drive Line High for Idle
          Done   <= '0';
          clk_Count <= 0;
          index <= 0;
 
          if Tx_Valid = '1' then
				Tx_Data <= Tx_Byte;
				state <= Start;
          else
				state <= Idle;
          end if;
           
        -- Send out Start Bit. Start bit = 0
        when Start =>
          Tx_Active <= '1';
          Tx_Serial <= '0';
 
          -- Wait for start bit to finish
          if clk_Count < clk_per_bit then
            clk_Count <= clk_Count + 1;
            state <= Start;
          else
            clk_Count <= 0;
            state <= Data;
          end if;
         
        when Data =>
          Tx_Serial <= Tx_Data(index); -- Let value on output
           
          if clk_Count < clk_per_bit then
            clk_Count <= clk_Count + 1;
            state <= Data;
          else
            clk_Count <= 0;
             
            -- Check if we have sent out all bits
            if index < 7 then
              index <= index + 1;
              state <= Data;
            else
              index <= 0;
              state <= Stop;
            end if;
          end if;
 
 
        -- Send out Stop bit.  Stop bit = 1
        when Stop =>
          Tx_Serial <= '1';
 
          -- Wait for Stop bit to finish
          if clk_Count < clk_per_bit then
            clk_Count <= clk_Count + 1;
            state <= Stop;
          else
            Done <= '1';
            clk_Count <= 0;
            state <= Clear;
          end if;
 
        when Clear =>
          Tx_Active <= '0';
          Done <= '1';
          state <= Idle;
           
        when others =>
          state <= Idle;
 
      END CASE;
    end if;
  end process;
 
  Tx_Done <= Done;
   
end rtl;