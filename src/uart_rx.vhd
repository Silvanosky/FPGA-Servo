LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity UART_Rx is
  generic (
    freq : positive := 50E6; -- The input clock frequency
    baudrate : positive := 115200 -- The baudrate to read
  );
  port (
    Clk         : in  std_logic; -- The clock
	 rst			 : in  std_logic; -- The reset signal
    RX  : in  std_logic; -- The input signal
    IsData      : out std_logic; -- Tell of there is a data to read
    Data_Byte   : out std_logic_vector(7 downto 0) -- The Byte read
    );
end UART_Rx;

architecture rtl of UART_Rx is
	 type EnumState is (Idle, Start, Data, Stop, Clear);
    signal state : EnumState := Idle;
	 
	 constant clk_per_bit : positive := (freq / baudrate)-1;
	 
	 signal clk_Count : integer range 0 to clk_per_bit := 0;
	 
	 signal Data_Input_r : std_logic := '0';

    signal Data_Input : std_logic := '0';
	 
	 
	 signal index : integer range 0 to 7 := 0;  -- 8 Bits Total
	 -- Output
	 signal readByte    : std_logic_vector(7 downto 0) := (others => '0');
    signal valid       : std_logic := '0';
begin
  sampler : process (rst, clk)
  begin
    if rst = '1' then
		Data_Input_r <= '1';
		Data_Input   <= '1';
    elsif rising_edge(clk) then
      Data_Input_r <= RX;
      Data_Input   <= Data_Input_r;
    end if;
  end process sampler;

  process (rst, clk)
  begin
    if rst = '1' then
      state <= Idle;
    elsif rising_edge(clk) then
		CASE (state) IS
			when Idle =>
			   clk_Count <= 0;
				valid <= '0';
				index <= 0;
				-- Check start of input byte:
				if Data_Input = '0' then -- Start bit detected
					state <= Start;
				else
					state <= Idle;
				end if;
				
			when Start =>
			   -- Waited for the middle start bit clock time
				if clk_Count = clk_per_bit/2 then
					if Data_Input = '0' then
					  clk_Count <= 0;
					  state <= Data;
					else
					  state <= Idle;
					end if;
				else
					clk_Count <= clk_Count + 1;
					state <= Start;
				end if;
				
			when Data =>
				if clk_Count < clk_per_bit then
					clk_Count <= clk_Count + 1;
					state <= Data;
				else
					clk_Count <= 0;
					readByte(index) <= Data_Input;
             
					-- Check if we have received all bits
					if index < 7 then
						index <= index + 1;
						state <= Data;
					else
						index <= 0;
						state <= Stop;
					end if;
				end if;
				
			when Stop =>
			-- Wait for Stop bit to finish
				if clk_Count < clk_per_bit then
					clk_Count <= clk_Count + 1;
					state <= Stop;
				else
				   clk_Count <= 0;
					valid <= '1';
					state <= Clear;
				end if;

			when Clear =>
				state <= Idle;
				valid <= '0';
				
			when others =>
				state <= Idle;
				
		END CASE;
    end if;
  end process;
  
  IsData <= valid;
  Data_Byte <= readByte;
  
end rtl;