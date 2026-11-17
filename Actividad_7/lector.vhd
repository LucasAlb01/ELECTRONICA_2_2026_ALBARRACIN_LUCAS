library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.textio.all;
use IEEE.std_logic_textio.all;

entity lector is
    generic (
        W : integer := 32
    );
    port (
        A      : out std_logic_vector(W-1 downto 0);
        B      : out std_logic_vector(W-1 downto 0);
        sel_fn : out std_logic_vector(3 downto 0);
        fin    : out boolean
    );
end entity lector;

architecture arc of lector is
begin
    proceso_de_estimulos : process
        file file_vectors : text open read_mode is "vectores_de_prueba.txt";
        variable current_line : line;
        variable v_A, v_B     : std_logic_vector(W-1 downto 0);
        variable v_sel        : std_logic_vector(3 downto 0);
        variable v_Y    : std_logic_vector(W-1 downto 0);
        variable v_Z    : std_logic;
    begin
        -- Espera inicial de estabilización
        wait for 20 ns;

        while not endfile(file_vectors) loop
            readline(file_vectors, current_line);
            
            -- Lee los datos del archivo 
            hread(current_line, v_A);
            hread(current_line, v_B);
            hread(current_line, v_sel);
            hread(current_line, v_Y);
            read(current_line, v_Z);

            -- envia datos a la ALU.V
            A      <= v_A;
            B      <= v_B;
            sel_fn <= v_sel;

            -- Ventana de tiempo de propagacion
            wait for 10 ns;
        end loop;

        file_close(file_vectors);
        fin <= true;
        wait;
    end process proceso_de_estimulos;
end architecture arc;