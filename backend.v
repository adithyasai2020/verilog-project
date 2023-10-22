module backend( i_resetbAll,
		i_clk,
		i_sclk,
		i_sdin,
		i_clk_vco1,
		i_clk_vco2,
		o_ready,
		o_vco1_fast,
		o_resetb1,
		o_gainA1,
		o_resetb2,
		o_gainA2,
		o_resetbvco1,
		o_resetbvco2);

input i_resetbAll, i_clk, i_sclk, i_sdin, i_clk_vco1, i_clk_vco2;
output reg o_ready, o_vco1_fast, o_resetb1, o_resetb2, o_resetbvco1, o_resetbvco2;
output reg [2:0] o_gainA1;
output reg [1:0] o_gainA2;

endmodule

