library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

entity calc_4bit_tb is
end entity calc_4bit_tb;

architecture sim of calc_4bit_tb is

    constant TB_DEBOUNCE : natural := 2;
    constant CLK_PERIOD  : time    := 83.333 ns; -- ~12 MHz

    signal clk_tb     : std_logic := '0';
    signal x_tb       : std_logic_vector(7 downto 0) := (others => '0');
    signal display_tb : std_logic_vector(7 downto 0);

    -- Espera N flancos ascendentes de reloj
    procedure wait_clks(signal c : in std_logic; constant n : in natural) is
    begin
        for i in 1 to n loop
            wait until rising_edge(c);
        end loop;
    end procedure;

    -- Pulsa x_tb(6) con antirrebote 
    procedure pulse_step(
        signal c   : in std_logic;
        signal x_s : inout std_logic_vector(7 downto 0)
    ) is
    begin
        x_s(6) <= '1';
        wait_clks(c, 8);
        x_s(6) <= '0';
        wait_clks(c, 8);
    end procedure;
begin

    uut : entity work.calc_4bit
        generic map (
            DEBOUNCE_CYCLES => TB_DEBOUNCE,
            ACTIVE_LOW_DISP => false
        )
        port map (
            clk     => clk_tb,
            x       => x_tb,
            display => display_tb
        );

    -- Generador de reloj de 12 MHz
    clk_gen : process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD / 2;
        clk_tb <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    stim_proc : process
    begin
        -- 1. Reset inicial vía x(7) = '1'
        x_tb <= (others => '0');
        x_tb(7) <= '1';
        wait_clks(clk_tb, 6);
        x_tb(7) <= '0';
        wait_clks(clk_tb, 4);

        -- 2. Cargar A = 5 ("0101") y luego B = 3 ("0011")
        x_tb(3 downto 0) <= "0101";
        pulse_step(clk_tb, x_tb);
        x_tb(3 downto 0) <= "0011";
        pulse_step(clk_tb, x_tb);

        -- Probar operaciones 
        x_tb(5 downto 4) <= "00"; -- 5 + 3 = 8 ('8'), Z = '0'
        wait_clks(clk_tb, 4);

        x_tb(5 downto 4) <= "01"; -- 5 - 3 = 2 ('2'), Z = '0'
        wait_clks(clk_tb, 4);

        -- 3. Volver a ST_LOAD_A y probar rebote corto en x(6)
        pulse_step(clk_tb, x_tb); 

        x_tb(3 downto 0) <= "0100"; -- A = 4
        x_tb(6) <= '1';
        wait_clks(clk_tb, 1); -- Rebote más corto que TB_DEBOUNCE: no deberia avanzar
        x_tb(6) <= '0';
        wait_clks(clk_tb, 1);
        pulse_step(clk_tb, x_tb); -- Pulso estable: carga A = 4 y pasa a ST_LOAD_B

        x_tb(3 downto 0) <= "0100"; -- B = 4
        pulse_step(clk_tb, x_tb); -- Carga B = 4 y pasa a ST_SHOW_Y

        -- 4. Caso con resultado cero (Z = '1' -> display_tb(7) = '1' cuando ACTIVE_LOW_DISP = false)
        x_tb(5 downto 4) <= "01"; -- 4 - 4 = 0 ('0') y punto decimal activo
        wait_clks(clk_tb, 6);

        -- 5. Probar desplazamiento lógico a la izquierda: 4 << 1 = 8
        pulse_step(clk_tb, x_tb); -- ST_SHOW_Y -> ST_LOAD_A
        x_tb(3 downto 0) <= "0100"; -- A = 4
        pulse_step(clk_tb, x_tb); -- A = 4 -> ST_LOAD_B

        x_tb(3 downto 0) <= "0001"; -- B = 1
        pulse_step(clk_tb, x_tb); -- B = 1 -> ST_SHOW_Y

        x_tb(5 downto 4) <= "10"; -- sel_fn = "0010" -> 4 << 1 = 8
        wait_clks(clk_tb, 6);

        finish;
    end process;

end architecture sim;