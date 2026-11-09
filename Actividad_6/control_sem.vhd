library ieee;
use ieee.std_logic_1164.all;

entity control_sem is
    port(
        clk : in std_logic;
        reset : in std_logic;
        Z : in std_logic;
        e_ns : in std_logic;
        e_eo :in std_logic;
        s_ns : in std_logic;
        s_eo : in std_logic;
        
        r_ns : out std_logic;
        a_ns : out std_logic;
        v_ns : out std_logic;

        r_eo : out std_logic;
        a_eo : out std_logic;
        v_eo : out std_logic;

        c : out std_logic;
        q : out integer range 0 to 100;
        res_ns : out std_logic;
        res_eo : out std_logic
    );
    end entity control_sem;

architecture arch4 of control_sem is
    type estado_type is (RV, RVext, RA, RAext, VR, VRext, AR, ARext);
    signal estado_ac, estado_sig : estado_type;
begin

    process(clk, reset)
    begin
        if reset = '1' then
            estado_ac <= RV;
        elsif rising_edge(clk) then
            estado_ac <= estado_sig;
        end if;
    end process;

    process(estado_ac, z, e_ns, e_eo, s_ns, s_eo)
    begin
        estado_sig <= estado_ac;
        c <= '0';
        q <= 50;
        res_ns <= '0';
        res_eo <= '0'; 
        r_ns  <= '0'; 
        a_ns  <= '0'; 
        v_ns  <= '0'; 
        r_eo  <= '0'; 
        a_eo  <= '0'; 
        v_eo  <= '0';

        case estado_ac is
            when RV => 
                r_ns <= '1'; 
                v_eo <= '1'; 
                if ((z = '1' or e_ns = '1') and s_eo = '1' and e_eo = '0') then 
                    estado_sig <= RVext; 
                    c <= '1'; 
                    q <= 50; 
                elsif ((z = '1' or e_ns = '1') and s_eo = '0' and e_eo = '0') then 
                    estado_sig <= RA; 
                    c <= '1'; 
                    q <= 10; 
                end if;

            when RVext => 
                r_ns <= '1'; 
                v_eo <= '1'; 
                if (z = '1' and e_eo = '0') then 
                    estado_sig <= RA; 
                    c <= '1'; 
                    q <= 10; 
                    res_eo <= '1'; 
                end if;

            when RA => 
                r_ns <= '1'; 
                a_eo <= '1'; 
                if z = '1' then 
                    estado_sig <= VR; 
                    c <= '1'; 
                    q <= 50; 
                end if;

            when VR => 
                v_ns <= '1'; 
                r_eo <= '1'; 
                if ((z = '1' or e_eo = '1') and s_ns = '1' and e_ns = '0') then 
                    estado_sig <= VRext; 
                    c <= '1'; 
                    q <= 50; 
                elsif ((z = '1' or e_eo = '1') and s_ns = '0' and e_ns = '0') then 
                    estado_sig <= AR; 
                    c <= '1'; 
                    q <= 10; 
                end if;

            when VRext => 
                v_ns <= '1'; 
                r_eo <= '1'; 
                if (z = '1' and e_ns = '0') then 
                    estado_sig <= AR; 
                    c <= '1'; 
                    q <= 10; 
                    res_ns <= '1'; 
                end if;

            when AR => 
                a_ns <= '1'; 
                r_eo <= '1'; 
                if z = '1' then 
                    estado_sig <= RV; 
                    c <= '1'; 
                    q <= 50; 
                end if;

            when others =>
                null;
        end case;
    end process;

end architecture arch4;
