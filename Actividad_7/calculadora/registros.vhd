library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity registros is
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        step_pls : in  std_logic;
        data_in  : in  std_logic_vector(3 downto 0);
        alu_y    : in  std_logic_vector(3 downto 0);
        alu_z    : in  std_logic;
        reg_a    : out std_logic_vector(3 downto 0);
        reg_b    : out std_logic_vector(3 downto 0);
        disp_val : out std_logic_vector(3 downto 0);
        dp_out   : out std_logic
    );
end entity;

architecture rgt of registros is
    type state_t is (ST_LOAD_A, ST_LOAD_B, ST_SHOW_Y);
    signal st : state_t := ST_LOAD_A;
    signal a_q, b_q : std_logic_vector(3 downto 0) := (others => '0');
begin
    process(clk, rst)
    begin
        if rst = '1' then
            st  <= ST_LOAD_A;
            a_q <= (others => '0');
            b_q <= (others => '0');
        elsif rising_edge(clk) then
            if step_pls = '1' then
                case st is
                    when ST_LOAD_A =>
                        a_q <= data_in;
                        st  <= ST_LOAD_B;
                    when ST_LOAD_B =>
                        b_q <= data_in;
                        st  <= ST_SHOW_Y;
                    when ST_SHOW_Y =>
                        st  <= ST_LOAD_A;
                end case;
            end if;
        end if;
    end process;

    reg_a <= a_q;
    reg_b <= b_q;

    -- En carga muestra el switch en vivo; en resultado muestra Y y enciende el punto si Z='1'
    process(st, data_in, alu_y, alu_z)
    begin
        dp_out <= '0';
        case st is
            when ST_LOAD_A | ST_LOAD_B =>
                disp_val <= data_in;
            when ST_SHOW_Y =>
                disp_val <= alu_y;
                dp_out   <= alu_z;
        end case;
    end process;
end architecture rgt;