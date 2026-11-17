library ieee;
use ieee.std_logic_1164.all;

entity temporizador is
    port(
        clk   : in  std_logic;
        reset : in  std_logic;
        hab_p : in  std_logic;                    
        c     : in  std_logic;                    
        q_in  : in  integer range 0 to 100;       
        z     : out std_logic
    );
end entity temporizador;

architecture arch3 of temporizador is
   signal cuenta : integer range 0 to 100 := 0;

begin
    process(clk, reset)
    begin
        if reset = '1' then
            cuenta <= 0;
            z      <= '0';
        elsif rising_edge(clk) then
            if c = '1' then
                cuenta <= q_in; 
                z      <= '0';
            elsif hab_p = '1' then
                if cuenta > 1 then
                    cuenta <= cuenta - 1; 
                    z      <= '0';
                elsif cuenta = 1 then
                    cuenta <= 0;
                    z      <= '1'; 
                else
                    z      <= '1'; 
                end if;
            end if;
        end if;
    end process;
end architecture arch3;