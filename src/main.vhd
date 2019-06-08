library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity main is
  port (
    CLOCK_50 	:  IN  STD_LOGIC;
    KEY			: IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
    GPIO 			:  INOUT  STD_LOGIC_VECTOR(1 DOWNTO 0);
    SW 			:  IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
    HEX0 			:  OUT  STD_LOGIC_VECTOR(0 TO 6);
    HEX1 			:  OUT  STD_LOGIC_VECTOR(0 TO 6);
    HEX2 			:  OUT  STD_LOGIC_VECTOR(0 TO 6);
    HEX3 			:  OUT  STD_LOGIC_VECTOR(0 TO 6);
    LEDR : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
  );
end entity;

architecture rtl of main is

  signal inserial, outserial : std_logic := '0';
  signal rst, clk : std_logic;
  signal data : std_logic_vector(7 downto 0) := (others => '0');
  signal r_TX_V     : std_logic                    := '0';
  signal r_TX_BYTE   : std_logic_vector(7 downto 0) := (others => '0');
  signal w_TX_SERIAL : std_logic;
  signal w_TX_DONE   : std_logic;
  signal w_RX_V     : std_logic;
  signal w_RX_BYTE   : std_logic_vector(7 downto 0);
  signal r_RX_SERIAL : std_logic := '1';

begin

  rst <= not KEY(0);
  clk <= CLOCK_50;
  inserial <= GPIO(0);
  LEDR(0) <= GPIO(0);
  LEDR(1) <= outserial;
  GPIO(1) <= outserial;


  UART_TX : entity work.UART_Tx
    generic map (
      freq     => 50E6,
      baudrate => 115200
    )
    port map (
      clk       => clk,
      rst 		 	=> rst,
      Tx_Valid  => r_TX_V,
      Tx_Byte   => r_TX_BYTE,

      Tx_Active => open,
      Tx_Serial => inserial,
      Tx_Done   => w_TX_DONE
    );

  UART_RX : entity work.UART_Rx
    generic map (
      freq     => 50E6,
    	baudrate => 115200
    )
    port map (
    	Clk       => clk,
    	rst       => rst,
      RX        => outserial,
      IsData    => w_RX_V,
      Data_Byte => w_RX_BYTE
    );

    s0: entity work.Seven_seg port map (Data => data(3 downto 0), Pol=>SW(9), Segout => HEX0);
    s1: entity work.Seven_seg port map (Data => data(7 downto 4), Pol=>SW(9), Segout => HEX1);

    process(w_RX_V, data) begin
      if w_RX_V = '1' then
        data <= w_RX_BYTE;
      end if;
    end process;

    r_TX_BYTE <= "00101000";

    process(rst, clk) begin
      if rst = '1' then
        --data <= "00000000";
      elsif rising_edge(clk) then
        r_TX_V <= '1';
      end if;
    end process;

end architecture;
