library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity semaforo is
    generic (
        FREQ_CLK : integer := 12_000_000
    );
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        p_ns     : in  std_logic;
        p_eo     : in  std_logic;
        e_ns     : in  std_logic;
        e_eo     : in  std_logic;
        r_ns    : out std_logic;
        a_ns    : out std_logic;
        v_ns    : out std_logic;
        r_eo    : out std_logic;
        a_eo    : out std_logic;
        v_eo    : out std_logic
    );
end entity semaforo;

architecture arch5 of semaforo is

    signal s_ns, s_eo    : std_logic;
    signal res_ns, res_eo : std_logic;
    signal hab_p         : std_logic;
    signal c, z          : std_logic;
    signal q             : integer range 0 to 100;

begin

    cruce_ns: entity work.cruce_peaton
        port map (
            clk   => clk,
            reset => reset,
            p     => p_ns,
            res   => res_ns,
            s     => s_ns
        );

    cruce_eo: entity work.cruce_peaton
        port map (
            clk   => clk,
            reset => reset,
            p     => p_eo,
            res   => res_eo,
            s     => s_eo
        );

    preescalador: entity work.preescaler
        generic map (
            FREQ_CLK => FREQ_CLK
        )
        port map (
            clk   => clk,
            reset => reset,
            hab_p => hab_p
        );

    temporizador: entity work.temporizador
        port map (
            clk   => clk,
            reset => reset,
            hab_p => hab_p,
            c     => c,
            q_in  => q,
            z     => z
        );

    control: entity work.control_sem
        port map (
            clk    => clk,
            reset  => reset,
            z      => z,
            e_ns   => e_ns,
            e_eo   => e_eo,
            s_ns   => s_ns,
            s_eo   => s_eo,
            r_ns  => r_ns,
            a_ns  => a_ns,
            v_ns  => v_ns,
            r_eo  => r_eo,
            a_eo  => a_eo,
            v_eo  => v_eo,
            c      => c,
            q      => q,
            res_ns => res_ns,
            res_eo => res_eo
        );

end architecture arch5;