LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity Clock is
  generic (
    freq : positive := 50E6;
    baud : positive := 9600
  );
  port    (
    clk   : In std_logic;
    rst   : In std_logic;
    tick  : Out std_logic
  );
end Clock;

architecture rtl of Clock is

  constant  divisor : positive := freq / baud;
  signal    count   : integer range 0 to divisor;

begin
  process (rst, clk)
  begin

    if rst='1' then

      count <= 0;


    elsif rising_edge(clk) then

      tick <= '0';

      if count < divisor - 1 then
        count <= count + 1;
      else
        count <= 0;
        tick <= '1';
      end if;

    end if;
  end process;
end rtl;
