library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity main is
  port (
    MAX10_CLK1_50 	:  IN  STD_LOGIC;
    KEY			: IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
    GPIO 			:  INOUT  STD_LOGIC_VECTOR(4 DOWNTO 0);
    SW 			:  IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
    HEX0 			:  OUT  STD_LOGIC_VECTOR(0 TO 6);
    HEX1 			:  OUT  STD_LOGIC_VECTOR(0 TO 6);
    HEX2 			:  OUT  STD_LOGIC_VECTOR(0 TO 6);
    HEX3 			:  OUT  STD_LOGIC_VECTOR(0 TO 6);
    LEDR : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
  );
end entity;

architecture rtl of main is

  signal clk : std_logic;
  signal rst : std_logic;
  signal data : std_logic_vector(7 downto 0) := (others => '0');
  signal r_TX_V     : std_logic := '0';
  signal r_TX_BYTE   : std_logic_vector(7 downto 0) := (others => '0');
  signal w_TX_SERIAL : std_logic;
  signal w_TX_DONE   : std_logic;
  signal w_RX_V     : std_logic;
  signal w_RX_BYTE   : std_logic_vector(7 downto 0);
  signal r_RX_SERIAL : std_logic := '1';
  -- PWM
  signal pwm_out : STD_LOGIC_VECTOR(2 DOWNTO 0);          --pwm outputs
  signal ena_pwm : std_logic;
  signal duty_pwm    : STD_LOGIC_VECTOR(7 DOWNTO 0); --duty cycle
begin
  clk <= MAX10_CLK1_50;
  UART_TX : entity work.UART_Tx
    generic map (
      freq     => 50000000,
      baudrate => 115200
    )
    port map (
      clk => clk,
      rst => rst,
      Tx_Valid  => r_TX_V,
      Tx_Byte   => r_TX_BYTE,

      Tx_Active => open,
      Tx_Serial => w_TX_SERIAL,
      Tx_Done   => w_TX_DONE
    );

  UART_RX : entity work.UART_Rx
    generic map (
      freq     => 50E6,
    	baudrate => 115200
    )
    port map (
      clk       => clk,
      rst       => rst,
      RX        => r_RX_SERIAL,
      IsData    => w_RX_V,
      Data_Byte => w_RX_BYTE
    );
	 
  PWM : entity work.PWM
    generic map (
      freq     => 50E6,
		phases => 3
    )
    port map (
      clk       => clk,
      rst       => rst,
      ena        => ena_pwm,
      duty    => duty_pwm,
		pwm_out => pwm_out
    );

	  rst <= '0';
	  r_RX_SERIAL <= GPIO(0);
	  GPIO(1) <= w_TX_SERIAL;
	  GPIO(4 downto 2) <= pwm_out;
	  
	  ena_pwm <= '1';

    s0: entity work.Seven_seg port map (Data => data(3 downto 0), Pol=>SW(9), Segout => HEX0);
    s1: entity work.Seven_seg port map (Data => data(7 downto 4), Pol=>SW(9), Segout => HEX1);
	 
	 duty_pwm <= SW(7 downto 0);
	 data <= SW(7 downto 0);
    process(w_RX_V, w_TX_DONE) begin
      if w_RX_V = '1' then
        --data <= w_RX_BYTE;
		  --duty_pwm <= w_RX_BYTE;
		  r_TX_BYTE <= w_RX_BYTE;
		  r_TX_V <= '1';
		elsif w_TX_DONE = '1' then
		  r_TX_V <= '0';
      end if;
    end process;

end architecture;
