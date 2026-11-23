library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.env.finish;

entity calc_4bit_tb is
end entity calc_4bit_tb;

architecture sim of calc_4bit_tb is
    signal clk_tb     : std_logic := '0';
    signal x_tb       : std_logic_vector(7 downto 0) := (others => '0');
    signal display_tb : std_logic_vector(7 downto 0);

    constant CLK_PERIOD : time := 83.33 ns; -- 12 MHz
begin
    uut : entity work.calc_4bit
        port map (
            clk     => clk_tb,
            x       => x_tb,
            display => display_tb
        );

    -- Generador de reloj 12 MHz
    clk_process : process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD / 2;
        clk_tb <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Estímulos de prueba
    stim_proc : process
    begin
        -- RESET INICIAL
        x_tb(7) <= '1';
        wait for 500 ns;
        x_tb(7) <= '0';
        wait for 500 ns;

        -- EJEMPLO 1: A = 5 (0101), B = 3 (0011) -> Suma (8) y Resta (2)

        -- Cargar A = 5
        x_tb(3 downto 0) <= "0101";
        wait for 300 ns;
        x_tb(6) <= '1';
        wait for 1 us;
        x_tb(6) <= '0';
        wait for 1 us;

        -- Cargar B = 3
        x_tb(3 downto 0) <= "0011";
        wait for 300 ns;
        x_tb(6) <= '1';
        wait for 1 us;
        x_tb(6) <= '0';
        wait for 1 us;

        x_tb(5 downto 4) <= "00"; -- 0000: 5 + 3 = 8 
        wait for 1 us;
        x_tb(5 downto 4) <= "01"; -- 0001: 5 - 3 = 2 
        wait for 1 us;

     
        -- Segundo cálculo 
        -- A = 9 (1001), B = 6 (0110) -> Suma = 15 ('F'), Resta = 3
        x_tb(6) <= '1';
        wait for 1 us;
        x_tb(6) <= '0';
        wait for 1 us;

        -- Cargar nuevo A = 9
        x_tb(3 downto 0) <= "1001";
        wait for 200 ns;
        x_tb(6) <= '1';
        wait for 100 ns; -- Rebote corto
        x_tb(6) <= '0';
        wait for 100 ns;
        x_tb(6) <= '1'; -- Pulso estable válido
        wait for 1 us;
        x_tb(6) <= '0';
        wait for 1 us;

        -- Cargar nuevo B = 6
        x_tb(3 downto 0) <= "0110";
        wait for 300 ns;
        x_tb(6) <= '1';
        wait for 1 us;
        x_tb(6) <= '0';
        wait for 1 us;

        x_tb(5 downto 4) <= "00"; -- 0000: 9 + 6 = 15 -> 'F'
        wait for 1 us;
        x_tb(5 downto 4) <= "01"; -- 0001: 9 - 6 = 3   -> '3'
        wait for 1 us;

        --  Resultado Cero 
        -- A = 4 (0100), B = 4 (0100) -> Resta = 0 (

        x_tb(6) <= '1';
        wait for 1 us;
        x_tb(6) <= '0';
        wait for 1 us;

        -- Cargar A = 4
        x_tb(3 downto 0) <= "0100";
        wait for 300 ns;
        x_tb(6) <= '1';
        wait for 1 us;
        x_tb(6) <= '0';
        wait for 1 us;

        -- Cargar B = 4
        x_tb(3 downto 0) <= "0100";
        wait for 300 ns;
        x_tb(6) <= '1';
        wait for 1 us;
        x_tb(6) <= '0';
        wait for 1 us;

        x_tb(5 downto 4) <= "01"; -- 0001: 4 - 4 = 0
        wait for 1 us;
        x_tb(5 downto 4) <= "10"; -- 0010: 4 << 4 = 0 
        wait for 1 us;

        -- Cargar otro B = 1 para probar Shift Left con resultado distinto de cero
        x_tb(6) <= '1';
        wait for 1 us;
        x_tb(6) <= '0';
        wait for 1 us;

        x_tb(3 downto 0) <= "0011"; -- A = 3
        wait for 300 ns;
        x_tb(6) <= '1';
        wait for 1 us;
        x_tb(6) <= '0';
        wait for 1 us;

        x_tb(3 downto 0) <= "0010"; -- B = 2
        wait for 300 ns;
        x_tb(6) <= '1';
        wait for 1 us;
        x_tb(6) <= '0';
        wait for 1 us;

        x_tb(5 downto 4) <= "10"; -- 0010: 3 << 2 = 12 -> 'C' 
        wait for 1 us;

        finish;
    end process;
end architecture sim;