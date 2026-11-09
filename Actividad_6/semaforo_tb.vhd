library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.env.finish;

entity semaforo_tb is
end entity semaforo_tb;

architecture sim of semaforo_tb is

    constant FREQ_SIM   : integer := 10; 
    constant periodo : time    := 10 ns;

    signal clk, reset          : std_logic := '0';
    signal p_ns, p_eo          : std_logic := '0';
    signal e_ns, e_eo          : std_logic := '0';
    signal r_ns, a_ns, v_ns : std_logic;
    signal r_eo, a_eo, v_eo : std_logic;

begin

   semaf : entity work.semaforo
        generic map (
            FREQ_CLK => FREQ_SIM
        )
        port map (
            clk   => clk,
            reset => reset,
            p_ns  => p_ns,
            p_eo  => p_eo,
            e_ns  => e_ns,
            e_eo  => e_eo,
            r_ns => r_ns,
            a_ns => a_ns,
            v_ns => v_ns,
            r_eo => r_eo,
            a_eo => a_eo,
            v_eo => v_eo
        );

    reloj : process
    begin
        while true loop
            clk <= '0';
            wait for periodo / 2;
            clk <= '1';
            wait for periodo / 2;
        end loop;
    end process;

    estimulos : process
    begin

        reset <= '1';
        wait for 20 ns;
        reset <= '0';

        wait for 1500 ns;

        p_eo <= '1';
        wait for 20 ns;
        p_eo <= '0';
        wait for 1500 ns;

        e_ns <= '1';
        wait for 300 ns;
        e_ns <= '0';
        wait for 1000 ns;

        finish;
    end process;

end architecture sim;