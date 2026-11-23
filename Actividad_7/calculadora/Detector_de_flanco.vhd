library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity detector is
    generic (
        DEBOUNCE_CYCLES : integer := 180000 -- ~15 ms a 12 MHz
    );
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        btn_in   : in  std_logic;
        edge_out : out std_logic
    );
end entity;

architecture dtc of detector is
    signal sync_0, sync_1 : std_logic := '0';
    signal clean_state    : std_logic := '0';
    signal cnt            : integer range 0 to DEBOUNCE_CYCLES := 0;

    type state_t is (S_IDLE, S_PULSE, S_HOLD);
    signal st, next_st : state_t;
begin
    -- Sincronizador de flip-flops y antirrebotes
    process(clk, rst)
    begin
        if rst = '1' then
            sync_0      <= '0';
            sync_1      <= '0';
            clean_state <= '0';
            cnt         <= 0;
        elsif rising_edge(clk) then
            sync_0 <= btn_in;
            sync_1 <= sync_0;

            if sync_1 = clean_state then
                cnt <= 0;
            else
                if cnt = DEBOUNCE_CYCLES then
                    clean_state <= sync_1;
                    cnt         <= 0;
                else
                    cnt <= cnt + 1;
                end if;
            end if;
        end if;
    end process;

    -- Detector de flanco ascendente
    process(clk, rst)
    begin
        if rst = '1' then
            st <= S_IDLE;
        elsif rising_edge(clk) then
            st <= next_st;
        end if;
    end process;

    process(st, clean_state)
    begin
        next_st <= st;
        case st is
            when S_IDLE =>
                if clean_state = '1' then
                    next_st <= S_PULSE;
                end if;
            when S_PULSE =>
                if clean_state = '1' then
                    next_st <= S_HOLD;
                else
                    next_st <= S_IDLE;
                end if;
            when S_HOLD =>
                if clean_state = '0' then
                    next_st <= S_IDLE;
                end if;
        end case;
    end process;

    edge_out <= '1' when st = S_PULSE else '0';
end architecture dtc;