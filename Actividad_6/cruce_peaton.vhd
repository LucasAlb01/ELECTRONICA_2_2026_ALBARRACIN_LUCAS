library ieee;
use ieee.std_logic_1164.all;

entity cruce_peaton is
    port(
        
        clk : in std_logic;
        reset : in std_logic; 
        p : in std_logic; 
        res : in std_logic;  
        s : out std_logic 
    );
    end entity cruce_peaton;

architecture arch1 of cruce_peaton is
    signal s_reg : std_logic := '0';
begin
    process(clk, reset)
    begin
        if reset = '1' then 
            s_reg <= '0'; 
        elsif rising_edge(clk) then 
            if res = '1' then
                 s_reg <= '0'; 
                elsif p = '1' then 
                    s_reg <= '1'; 
                end if; 
            end if; 
        end process; 
        
        s <= s_reg; 

end architecture arch1;
