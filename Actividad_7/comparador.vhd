library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.textio.all;
use IEEE.std_logic_textio.all;

entity comparador is
    generic (
        W : integer := 32
    );
    port (
        Y_alu : in std_logic_vector(W-1 downto 0);
        Z_alu : in std_logic
    );
end entity comparador;

architecture arc2 of comparador is
begin
    comparacion: process
        file file_vectors : text open read_mode is "vectores_de_prueba.txt";
        variable current_line : line;
        variable v_A_dummy    : std_logic_vector(W-1 downto 0);
        variable v_B_dummy    : std_logic_vector(W-1 downto 0);
        variable v_sel_dummy  : std_logic_vector(3 downto 0);
        variable v_Y_esperado : std_logic_vector(W-1 downto 0);
        variable v_Z_esperado : std_logic;
        variable num_linea    : integer := 0;
        variable error_found  : boolean := false;
    begin
        -- Sincronizado con el inicio del proceso de estímulos
        wait for 20 ns;

        while not endfile(file_vectors) loop
            readline(file_vectors, current_line);
            num_linea := num_linea + 1;

            -- Lee los datos del archivo de texto
            hread(current_line, v_A_dummy);
            hread(current_line, v_B_dummy);
            hread(current_line, v_sel_dummy);
            hread(current_line, v_Y_esperado);
            read(current_line, v_Z_esperado);

            wait for 10 ns;

            -- Comprobación de errores
            if (Y_alu /= v_Y_esperado) or (Z_alu /= v_Z_esperado) then
                error_found := true;
                report "¡ERROR!" & LF &
                       "  - Fila : " & integer'image(num_linea) & LF &
                       "  - Tiempo     : " & time'image(now) & LF &
                       "  - Esperado  (C)    -> Y = " & to_hstring(v_Y_esperado) & ", Z = " & std_logic'image(v_Z_esperado) & LF &
                       "  - Obtenido (ALU VHDL)  -> Y = " & to_hstring(Y_alu) & ", Z = " & std_logic'image(Z_alu)
                    severity error;
            end if;
        end loop;

        file_close(file_vectors);
    
        if not error_found then
            report " FIN DE LA VERIFICACION: No se encontraron errores " severity note;
        else
            report " FIN DE LA VERIFICACION: se encontraron errores durante la simulacion. Revise los reportes " severity warning;
        end if;

        wait;
    end process comparacion;
end architecture arc2;