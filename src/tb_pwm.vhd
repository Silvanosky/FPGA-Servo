library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
 
entity tb_pwm is
end tb_pwm;
 
architecture TEST of tb_pwm is 
   
  constant Period : time := 100 ns; -- speed up simulation with a 10MHz clock
   
  signal CLK       : std_logic                    := '0';
  signal RST       : std_logic                    := '1';
  signal ena       : STD_LOGIC;
  signal duty      : STD_LOGIC_VECTOR(7 DOWNTO 0); --duty cycle
  signal pwm_out   : STD_LOGIC_VECTOR(0 DOWNTO 0);          --pwm outputs
  signal Done : boolean;
 
   
begin
	 -- System Inputs
CLK <= '0' when Done else not CLK after Period / 2;
RST <= '1', '0' after Period;
	
-- Instantiate PWM
PWM_UUT : entity work.PWM
    generic map (
      freq => 10E6,
      pwm_freq => 50, -- Desired pwm frequency for servomotor
      phases => 1 -- Use 2 output
      )
    port map (
      clk       	=> CLK,
	  rst 		 	=> RST,
	  ena 			=> ena,
	  duty			=> duty,
	  pwm_out 		=> pwm_out
      );
   
process begin
	ena <= '1';
	duty <= x"FF";
	wait for 2000 ms;  -- 203
	ena <= '1';
	duty <= x"01";
	wait for 2000 ms;  -- 207
	ena <= '1';
	duty <= x"0A";
	wait for 2000 ms;  -- 207
	ena <= '1';
	duty <= x"80";
	wait for 2000 ms;  -- 211
	ena <= '0';
	
	report "End of test. Verify that no error was reported.";
	Done <= true;
	wait;
end process;
   
end TEST;