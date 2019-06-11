library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
 
entity PWM is
  generic (
    freq : positive := 50E6; -- The input clock frequency
    pwm_freq        : positive := 50;    --PWM switching frequency in Hz
    bits_resolution : INTEGER := 8;          --bits of resolution setting the duty cycle
    phases          : INTEGER := 1
  );
  port (
    clk       : IN  STD_LOGIC; -- The clock
    rst	      : IN  STD_LOGIC; -- The reset signal
    ena       : IN  STD_LOGIC; -- enable latches in new duty cycle
    duty      : IN  STD_LOGIC_VECTOR(bits_resolution-1 DOWNTO 0); --duty cycle
    pwm_out   : OUT STD_LOGIC_VECTOR(phases-1 DOWNTO 0)          --pwm outputs
    );
end PWM;
 
architecture rtl of PWM is
	CONSTANT period : integer := freq/pwm_freq; --number of clocks tick in one pwm period
	
	CONSTANT maxvalue : integer := 2**bits_resolution;

	SIGNAL count : INTEGER RANGE 0 TO period - 1 := 0; --array of period counters
	
	TYPE half_duties IS ARRAY (0 TO phases-1) OF INTEGER RANGE 0 TO period/2; --data type for array of half duty values
	
	SIGNAL half_duty : half_duties := (OTHERS => 0); --array of half duty values (for each phase)
begin
	process (clk, rst)
	begin
		if rst = '1' then
			count <= 0; --clear counter
			pwm_out <= (OTHERS => '0'); --clear pwm outputs
		elsif rising_edge(clk) then
			IF(ena = '1') THEN --latch in new duty cycle
				FOR i IN 0 to phases-1 LOOP --apply new duty to each phase
					half_duty(i) <= conv_integer(duty)*period/maxvalue/2 + 1; --determine clocks in 1/2 duty cycle
				END LOOP;
			END IF;

			IF (count = period - 1) THEN --end of period reached
				count <= 0; --reset counter
		--		half_duty(i) <= half_duty_new(i); --set most recent duty cycle value
			ELSE --end of period not reached
				count <= count + 1; --increment counter
			END IF;
			
			FOR i IN 0 to phases-1 LOOP --control outputs for each phase
				IF(count < half_duty(i)) THEN --phase's falling edge reached
					pwm_out(i) <= '1'; --deassert the pwm output
				ELSIF(count > period - half_duty(i)) THEN
					pwm_out(i) <= '1'; --assert the pwm output
				ELSE
					pwm_out(i) <= '0';
				END IF;
			END LOOP;
		end if;
	end process;
end rtl;

