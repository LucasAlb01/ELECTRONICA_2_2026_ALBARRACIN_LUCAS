library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity calc_4bit is
    generic (
        DEBOUNCE_CYCLES : natural := 120000; -- ~10 ms a 12 MHz
        ACTIVE_LOW_DISP : boolean := false   -- false = activo en alto 
    );
    port (
        clk     : in  std_logic;                    -- Reloj 12 MHz (pin 94)
        x       : in  std_logic_vector(7 downto 0); -- Panel de 8 interruptores
        display : out std_logic_vector(7 downto 0)  -- 7 segmentos (6 downto 0) + Z (7)
    );
end entity calc_4bit;

architecture arch of calc_4bit is
    type state_t is (ST_LOAD_A, ST_LOAD_B, ST_SHOW_Y);
    signal st : state_t := ST_LOAD_A;

    signal reg_a    : std_logic_vector(3 downto 0) := (others => '0');
    signal reg_b    : std_logic_vector(3 downto 0) := (others => '0');
    signal sel_fn   : std_logic_vector(3 downto 0);
    signal alu_y    : std_logic_vector(3 downto 0);
    signal alu_z    : std_logic;

    signal hex_val  : std_logic_vector(3 downto 0);
    signal dp_val   : std_logic;
    signal seg_7    : std_logic_vector(6 downto 0);
    signal raw_disp : std_logic_vector(7 downto 0);

    -- Sincronizador, antirrebote y detector de flanco para x(6)
    signal sync_0, sync_1 : std_logic := '0';
    signal clean_state    : std_logic := '0';
    signal prev_clean     : std_logic := '0';
    signal step_pls       : std_logic := '0';
    signal deb_cnt        : natural range 0 to DEBOUNCE_CYCLES := 0;
begin

    -- Código de operación 
    sel_fn <= "00" & x(5 downto 4);

    -- Instancia de la ALU de 4 bits
    u_alu : entity work.alu
        generic map (
            W => 4
        )
        port map (
            sel_fn => sel_fn,
            A      => reg_a,
            B      => reg_b,
            Y      => alu_y,
            Z      => alu_z
        );

    -- Sincronizador, antirrebote, pulso de flanco en x(6) y máquina de carga A -> B -> Y
    process(clk)
    begin
        if rising_edge(clk) then
            step_pls <= '0';

            if x(7) = '1' then
                sync_0      <= '0';
                sync_1      <= '0';
                clean_state <= '0';
                prev_clean  <= '0';
                deb_cnt     <= 0;
                st          <= ST_LOAD_A;
                reg_a       <= (others => '0');
                reg_b       <= (others => '0');
            else
                sync_0 <= x(6);
                sync_1 <= sync_0;

                if sync_1 = clean_state then
                    deb_cnt <= 0;
                elsif deb_cnt = DEBOUNCE_CYCLES then
                    clean_state <= sync_1;
                    deb_cnt     <= 0;
                else
                    deb_cnt <= deb_cnt + 1;
                end if;

                prev_clean <= clean_state;

                if clean_state = '1' and prev_clean = '0' then
                    step_pls <= '1';
                    case st is
                        when ST_LOAD_A =>
                            reg_a <= x(3 downto 0);
                            st    <= ST_LOAD_B;
                        when ST_LOAD_B =>
                            reg_b <= x(3 downto 0);
                            st    <= ST_SHOW_Y;
                        when ST_SHOW_Y =>
                            st    <= ST_LOAD_A;
                    end case;
                end if;
            end if;
        end if;
    end process;

    -- Selección de qué mostrar y punto decimal (Z)
    process(st, x, reg_a, reg_b, alu_y, alu_z)
    begin
        dp_val <= '0';
        case st is
            when ST_LOAD_A =>
                hex_val <= reg_a;
            when ST_LOAD_B =>
                hex_val <= reg_b;
            when ST_SHOW_Y =>
                hex_val <= alu_y;
                dp_val  <= alu_z;
        end case;
    end process;

    -- Decodificador hexadecimal a 7 segmentos (gfedcba)
    with hex_val select
        seg_7 <= "0111111" when "0000", -- 0
                 "0000110" when "0001", -- 1
                 "1011011" when "0010", -- 2
                 "1001111" when "0011", -- 3
                 "1100110" when "0100", -- 4
                 "1101101" when "0101", -- 5
                 "1111101" when "0110", -- 6
                 "0000111" when "0111", -- 7
                 "1111111" when "1000", -- 8
                 "1101111" when "1001", -- 9
                 "1110111" when "1010", -- A
                 "1111100" when "1011", -- b
                 "0111001" when "1100", -- C
                 "1011110" when "1101", -- d
                 "1111001" when "1110", -- E
                 "1110001" when others; -- F

    raw_disp <= dp_val & seg_7;
    display  <= not raw_disp when ACTIVE_LOW_DISP else raw_disp;

end architecture arch;