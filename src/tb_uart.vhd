library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
 
entity tb_uart is
end tb_uart;
 
architecture TEST of tb_uart is 
   
  constant Period : time := 100 ns; -- speed up simulation with a 10MHz clock
  
  -- Want to interface to 115200 baud UART
  -- 10000000 / 115200 = 8680 ns bit period;
 
  constant c_BIT_PERIOD : time := 8680 ns;
   
  signal CLK    		: std_logic                    := '0';
  signal RST         : std_logic                    := '1';
  signal r_TX_V     : std_logic                    := '0';
  signal r_TX_BYTE   : std_logic_vector(7 downto 0) := (others => '0');
  signal w_TX_SERIAL : std_logic;
  signal w_TX_DONE   : std_logic;
  signal w_RX_V     : std_logic;
  signal w_RX_BYTE   : std_logic_vector(7 downto 0);
  signal r_RX_SERIAL : std_logic := '1';
  signal Done : boolean;
 
   
  -- byte-write
  procedure UART_WRITE_BYTE (
    data_in       : in  std_logic_vector(7 downto 0);
    signal serial : out std_logic) is
  begin
 
    -- Send Start Bit
    serial <= '0';
    wait for c_BIT_PERIOD;
 
    -- Send Data Byte
    for ii in 0 to 7 loop
      serial <= data_in(ii);
      wait for c_BIT_PERIOD;
    end loop;  -- ii
 
    -- Send Stop Bit
    serial <= '1';
    wait for c_BIT_PERIOD;
  end UART_WRITE_BYTE;
 
   
begin
	 -- System Inputs
CLK <= '0' when Done else not CLK after Period / 2;
RST <= '1', '0' after Period;
	
-- Instantiate UART transmitter
UART_TX_UUT : entity work.UART_Tx
    generic map (
      freq => 10E6,
	  baudrate => 115200
      )
    port map (
      clk       	=> CLK,
	  rst 		 	=> RST,
      Tx_Valid     => r_TX_V,
      Tx_Byte   => r_TX_BYTE,
		
      Tx_Active => open,
      Tx_Serial => w_TX_SERIAL,
      Tx_Done   => w_TX_DONE
      );
 
	-- Instantiate UART Receiver
UART_RX_UUT : entity work.UART_Rx
    generic map (
      freq => 10E6,
	  baudrate => 115200
      )
    port map (
		Clk => CLK,
	   rst => RST,
      RX => r_RX_SERIAL,
      IsData => w_RX_V,
      Data_Byte => w_RX_BYTE
      );
   
process begin
 
    -- Tell the UART to send a command.
    wait until rising_edge(CLK);
    wait until rising_edge(CLK);
    r_TX_V   <= '1';
    r_TX_BYTE <= X"AB";
    wait until rising_edge(CLK);
	wait until rising_edge(CLK);
    r_TX_V   <= '0';
    wait until w_TX_DONE = '1';
 
     
    -- Send a command to the UART
    wait until rising_edge(CLK);
    UART_WRITE_BYTE(X"3F", r_RX_SERIAL);
    wait until rising_edge(CLK);
	 
	 -- Check that the correct command was received
    assert w_RX_BYTE=X"3F" report "Error on RECEIVE" severity warning;
    
	report "End of test. Verify that no error was reported.";
	Done <= true;
	wait;
end process;
   
end TEST;