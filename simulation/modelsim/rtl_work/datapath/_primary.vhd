library verilog;
use verilog.vl_types.all;
library work;
entity datapath is
    port(
        clk             : in     vl_logic;
        load_pc         : in     vl_logic;
        load_cc         : in     vl_logic;
        load_ir         : in     vl_logic;
        load_mar        : in     vl_logic;
        load_mdr        : in     vl_logic;
        load_regfile    : in     vl_logic;
        mdrmux_sel      : in     vl_logic;
        pcmux_sel       : in     vl_logic_vector(2 downto 0);
        storemux_sel    : in     vl_logic;
        alumux_sel      : in     vl_logic_vector(2 downto 0);
        marmux_sel      : in     vl_logic_vector(1 downto 0);
        regfilemux_sel  : in     vl_logic_vector(2 downto 0);
        aluop           : in     work.lc3b_types.lc3b_aluop;
        mem_rdata       : in     vl_logic_vector(15 downto 0);
        opcode          : out    work.lc3b_types.lc3b_opcode;
        mem_address     : out    vl_logic_vector(15 downto 0);
        mem_wdata       : out    vl_logic_vector(15 downto 0);
        branch_enable   : out    vl_logic;
        jsrr_enable     : out    vl_logic;
        imm5_enable     : out    vl_logic;
        D_bit           : out    vl_logic;
        A_bit           : out    vl_logic
    );
end datapath;
