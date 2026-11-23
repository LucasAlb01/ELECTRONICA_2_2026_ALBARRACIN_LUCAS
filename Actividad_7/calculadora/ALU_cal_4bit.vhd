library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_cal_4bit is
    generic (
        W : integer := 32 
    );
    port (
        A      : in  std_logic_vector(W-1 downto 0);
        B      : in  std_logic_vector(W-1 downto 0); 
        sel_fn : in  std_logic_vector(3 downto 0);   
        Y      : out std_logic_vector(W-1 downto 0); 
        Z      : out std_logic                       
    );
end entity alu_cal_4bit;

architecture arc1 of alu_cal_4bit is
    signal y_reg : std_logic_vector(W-1 downto 0);
begin

    process(A, B, sel_fn)
        variable shift_amount : integer;
        variable res_var      : std_logic_vector(W-1 downto 0);
    begin
        -- Toma los bits menos significativos de B sin exceder W-1
        shift_amount := to_integer(unsigned(B(minimum(4, W-1) downto 0)));
        res_var      := (others => '0');

        case sel_fn is
            -- 0000: Suma (Y = A + B)
            when "0000" =>
                res_var := std_logic_vector(unsigned(A) + unsigned(B));

            -- 0001: Resta (Y = A - B)
            when "0001" =>
                res_var := std_logic_vector(unsigned(A) - unsigned(B));

            -- 001-: Desplazamiento a la Izquierda (Y = A << B)
            when "0010" | "0011" =>
                res_var := std_logic_vector(shift_left(unsigned(A), shift_amount));

            -- 010-: Comparación Menor Que en Complemento a 2 (Signed: Y = A < B)
            when "0100" | "0101" =>
                if signed(A) < signed(B) then
                    res_var(0) := '1';
                else
                    res_var(0) := '0';
                end if;

            -- 011-: Comparación Menor Que en Binario Natural (Unsigned: Y = A < B)
            when "0110" | "0111" =>
                if unsigned(A) < unsigned(B) then
                    res_var(0) := '1';
                else
                    res_var(0) := '0';
                end if;

            -- 100-: Operación XOR bit a bit (Y = A ⊕ B)
            when "1000" | "1001" =>
                res_var := A xor B;

            -- 1010: Desplazamiento a la Derecha Lógico (Y = A >> B)
            when "1010" =>
                res_var := std_logic_vector(shift_right(unsigned(A), shift_amount));

            -- 1011: Desplazamiento a la Derecha Aritmético (Y = A >> B)
            when "1011" =>
                res_var := std_logic_vector(shift_right(signed(A), shift_amount));

            -- 110-: Operación OR bit a bit (Y = A ∨ B)
            when "1100" | "1101" =>
                res_var := A or B;

            -- 111-: Operación AND bit a bit (Y = A ∧ B)
            when "1110" | "1111" =>
                res_var := A and B;

            when others =>
                res_var := (others => '0');
        end case;

        y_reg <= res_var;
    end process;

    Y <= y_reg;
    Z <= '1' when unsigned(y_reg) = 0 else '0';

end architecture arc1;