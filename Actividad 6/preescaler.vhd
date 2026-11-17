library ieee;
use ieee.std_logic_1164.all;

entity preescaler is
    generic ( 
        FREQ_CLK : integer := 12_000_000 -- 12 MHz 
    ); 
    port ( 
        clk : in std_logic;
        reset : in std_logic;
        hab_p : out std_logic
    ); 
end entity preescaler;

architecture arch2 of preescaler is
    signal cuenta : integer range 0 to FREQ_CLK - 1 := 0;
    begin 
        process(clk, reset) 
        begin 
            if reset = '1' then 
                cuenta <= 0; 
                hab_p <= '0'; 
            elsif rising_edge(clk) then 
                if cuenta = FREQ_CLK - 1 then 
                    cuenta <= 0; 
                    hab_p <= '1'; 
                else 
                    cuenta <= cuenta + 1; 
                    hab_p <= '0'; 
                end if; 
            end if; 
        end process; 
    end architecture arch2;