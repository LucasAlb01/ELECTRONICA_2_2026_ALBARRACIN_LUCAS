library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity codigo_top is
end entity codigo_top;

architecture arch1 of codigo_top is
    constant W : integer := 32;

    signal s_A      : std_logic_vector(W-1 downto 0);
    signal s_B      : std_logic_vector(W-1 downto 0);
    signal s_sel_fn : std_logic_vector(3 downto 0);
    signal s_Y      : std_logic_vector(W-1 downto 0);
    signal s_Z      : std_logic;
    signal s_fin    : boolean;
begin

    LECTOR : entity work.lector
        generic map (W => W)
        port map (
            A      => s_A,
            B      => s_B,
            sel_fn => s_sel_fn,
            fin    => s_fin
        );

    ALU: entity work.ALU
        generic map (W => W)
        port map (
            A      => s_A,
            B      => s_B,
            sel_fn => s_sel_fn,
            Y      => s_Y,
            Z      => s_Z
        );

    comparacion : entity work.comparador
        generic map (W => W)
        port map (
            Y_alu => s_Y,
            Z_alu => s_Z
        );

end architecture arch1;