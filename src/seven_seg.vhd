library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;


Entity Seven_seg is
  port ( Data   : in  std_logic_vector(3 downto 0);
         Pol    : in  std_logic;
         Segout : out std_logic_vector(1 to 7));
end entity Seven_seg;

architecture rtl of Seven_seg is

  signal hex : std_logic_vector(1 to 7);

begin

process(Data, Pol)
begin
  case to_integer(unsigned(Data)) is
    when 0 =>
		hex <= "0000001";
    when 1 =>
		hex <= "1001111";
    when 2 =>
		hex <= "0010010";
    when 3 =>
		hex <= "0000110";
    when 4 =>
		hex <= "1001100";
    when 5 =>
		hex <= "0100100";
    when 6 =>
		hex <= "0100000";
    when 7 =>
		hex <= "0001111";
    when 8 =>
		hex <= "0000000";
    when 9 =>
		hex <= "0000100";
    when 10 =>
		hex <= "0001000";
    when 11 =>
		hex <= "0000000";
    when 12 =>
		hex <= "0110001";
    when 13 =>
		hex <= "0000001";
    when 14 =>
		hex <= "0110000";
    when 15 =>
		hex <= "0111000";
	  when others =>
		hex <= "XXXXXXX";
  end case;
  if pol = '1' then
    Segout <= not(hex);
  else
    Segout <= hex;
  end if;
end process;

end architecture rtl;
