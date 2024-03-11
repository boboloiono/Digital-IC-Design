library verilog;
use verilog.vl_types.all;
entity BOE is
    generic(
        read_data       : vl_logic_vector(1 downto 0) := (Hi0, Hi0);
        output_max      : vl_logic_vector(1 downto 0) := (Hi0, Hi1);
        output_sum      : vl_logic_vector(1 downto 0) := (Hi1, Hi0);
        output_sort     : vl_logic_vector(1 downto 0) := (Hi1, Hi1)
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        data_num        : in     vl_logic_vector(2 downto 0);
        data_in         : in     vl_logic_vector(7 downto 0);
        result          : out    vl_logic_vector(10 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of read_data : constant is 2;
    attribute mti_svvh_generic_type of output_max : constant is 2;
    attribute mti_svvh_generic_type of output_sum : constant is 2;
    attribute mti_svvh_generic_type of output_sort : constant is 2;
end BOE;
