library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.env.finish;

entity ALU_tb is
end entity ALU_tb;

architecture arch2 of ALU_tb is

    constant W : integer := 32;

    signal A      : std_logic_vector(W-1 downto 0) := (others => '0');
    signal B      : std_logic_vector(W-1 downto 0) := (others => '0');
    signal sel_fn : std_logic_vector(3 downto 0)   := (others => '0');
    signal Y      : std_logic_vector(W-1 downto 0);
    signal Z      : std_logic;

begin

    -- Instancia de la ALU
    uut: entity work.ALU
        generic map (
            W => W
        )
        port map (
            A      => A,
            B      => B,
            sel_fn => sel_fn,
            Y      => Y,
            Z      => Z
        );

    --estímulos de prueba
    estimulos : process
    begin

        A      <= std_logic_vector(to_unsigned(15, W));
        B      <= std_logic_vector(to_unsigned(10, W));
        sel_fn <= "0000"; -- Suma
        wait for 20 ns;

        A      <= std_logic_vector(to_unsigned(50, W));
        B      <= std_logic_vector(to_unsigned(20, W));
        sel_fn <= "0001"; -- Resta
        wait for 20 ns;

        A      <= std_logic_vector(to_unsigned(25, W));
        B      <= std_logic_vector(to_unsigned(25, W));
        sel_fn <= "0001"; -- Resta
        wait for 20 ns;

        A      <= std_logic_vector(to_unsigned(3, W));
        B      <= std_logic_vector(to_unsigned(2, W));
        sel_fn <= "0010"; -- desplazamiento izquierda
        wait for 20 ns;

        A      <= x"F0F0F0F0";
        B      <= x"FF00FF00";
        sel_fn <= "1110"; -- AND
        wait for 20 ns;
        -- Casos Criticos

        -- Máximo valor positivo en 32 bitS
        A      <= x"7FFFFFFF";
        B      <= std_logic_vector(to_unsigned(1, W));
        sel_fn <= "0000"; -- Suma
        wait for 20 ns;

        -- Resta que da exactamente en Cero
        A      <= x"DEADBEEF";
        B      <= x"DEADBEEF";
        sel_fn <= "0001"; -- Resta
        wait for 20 ns;

        -- Comparación con signos opuestos 
        A      <= x"FFFFFFFF";
        B      <= x"00000005"; 
        sel_fn <= "0100";
        wait for 20 ns;

        -- Desplazamiento extremo a la izquierda
        A      <= x"00000001";
        B      <= std_logic_vector(to_unsigned(31, W));
        sel_fn <= "0010";
        wait for 20 ns;

        -- Desplazamiento aritmético a la derecha con número negativo
        A      <= x"80000000";
        B      <= std_logic_vector(to_unsigned(4, W));
        sel_fn <= "1011";
        wait for 20 ns;
        report "FINDE LAS PRUEBAS" severity note;
        finish;
    end process estimulos;

end architecture arch2;