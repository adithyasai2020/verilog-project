// Testbanch module for the backend. This is has a module instantiation for
// the FPGA_model and the backend.
`timescale 1ns / 1ps
//==========================================================================
//Change the Verilog filenames approppriately.
`include "FPGA_model.v"
`include "backend.v"
//=========================================================================

module backend_tb();

reg resetbFPGA;
reg main_clk;
reg vco1_clockmodel, vco2_clockmodel; 

wire [2:0]gainA1 ; 
wire [1:0]gainA2 ;
wire resetbAll, resetb1, resetb2, resetbvco1, resetbvco2; 
wire vco1_clk, vco2_clk;
wire sclk, sdin;
wire ready;
wire vco1_fast;


//==========================================================================
//FPGA model instantiation
FPGA_model   FPGA_obj(	.i_resetbFPGA (resetbFPGA),
			.i_ready (ready),
			.o_resetbAll (resetbAll),
			.i_mainclk (main_clk),
			.o_sclk (sclk), 
			.o_sdout (sdin),
			.i_vco1_fast (vco1_fast) );

// Backend instantiation 
backend backend_obj (	.i_resetbAll (resetbAll),
			.i_clk (main_clk),
			.i_sclk (sclk),
			.i_sdin (sdin),
			.i_clk_vco1 (vco1_clk),
			.i_clk_vco2 (vco2_clk),
			.o_ready (ready),
                        .o_vco1_fast (vco1_fast),
			.o_resetb1 (resetb1),
			.o_gainA1 (gainA1),
			.o_resetb2 (resetb2),
			.o_gainA2 (gainA2),
			.o_resetbvco1 (resetbvco1),
			.o_resetbvco2 (resetbvco2)
			);
//============================================================================
// VCO clock model
assign vco1_clk = (resetbvco1)?vco1_clockmodel:0;
assign vco2_clk = (resetbvco2)?vco2_clockmodel:0;

//============================================================================

//Test signal generation
initial
begin
	resetbFPGA <= 0;
	main_clk <= 0;
	vco1_clockmodel <= 0;
	vco2_clockmodel <= 0;

	#4 resetbFPGA <= 1;
	
end

//Generation of main_clk 
always #2.5 main_clk <= ~main_clk;

//Generation of internal clock models for the VCOs
always #1 vco1_clockmodel <= ~vco1_clockmodel;
always #2 vco2_clockmodel <= ~vco2_clockmodel;


//============================================================================
endmodule
