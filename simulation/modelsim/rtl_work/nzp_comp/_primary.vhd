library verilog;
use verilog.vl_types.all;
entity nzp_comp is
    port(
        cc              : in     vl_logic_vector(2 downto 0);
        dest            : in     vl_logic_vector(2 downto 0);
        \out\           : out    vl_logic
    );
end nzp_comp;
