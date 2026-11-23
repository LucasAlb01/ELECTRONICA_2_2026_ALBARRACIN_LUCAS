library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity calc_4bit is
    port(
        clk     : in  std_logic;
        x       : in  std_logic_vector(7 downto 0);
        display : out std_logic_vector(7 downto 0)
    );
end entity calc_4bit;

architecture struct of calc_4bit is
    signal rst_sig      : std_logic;
    signal step_pulse   : std_logic;
    signal reg_a_s      : std_logic_vector(3 downto 0);
    signal reg_b_s      : std_logic_vector(3 downto 0);
    signal sel_fn_s     : std_logic_vector(3 downto 0);
    signal alu_y_s      : std_logic_vector(3 downto 0);
    signal alu_z_s      : std_logic;
    signal disp_val_s   : std_logic_vector(3 downto 0);
    signal dp_s         : std_logic;
begin
    rst_sig  <= x(7);
    sel_fn_s <= "00" & x(5 downto 4); -- 0000: Suma, 0001: Resta, 0010: Shift L, 0011: Shift L

    u_det_flanco : entity work.detector
        generic map (
            DEBOUNCE_CYCLES => 180000
        )
        port map (
            clk      => clk,
            rst      => rst_sig,
            btn_in   => x(6),
            edge_out => step_pulse
        );

    u_reg : entity work.registros
        port map (
            clk      => clk,
            rst      => rst_sig,
            step_pls => step_pulse,
            data_in  => x(3 downto 0),
            alu_y    => alu_y_s,
            alu_z    => alu_z_s,
            reg_a    => reg_a_s,
            reg_b    => reg_b_s,
            disp_val => disp_val_s,
            dp_out   => dp_s
        );

    u_top : entity work.alu_cal_4bit
        generic map (
            W => 4
        )
        port map (
            A      => reg_a_s,
            B      => reg_b_s,
            sel_fn => sel_fn_s,
            Y      => alu_y_s,
            Z      => alu_z_s
        );

    u_dpy : entity work.display
        generic map (
            ACTIVE_LOW => '1'
        )
        port map (
            hex_in  => disp_val_s,
            dp_in   => dp_s,
            seg_out => display
        );
end architecture struct;