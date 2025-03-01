module DPLL_top(
	input logic clk_ref,       // Reference clock (10MHz)
	input logic rst_n,         // Active-low reset
	output logic pll_out,      // PLL output clock (100MHz)
	output logic locked        // Lock indicator
);

	// Internal wiring
	logic clk_fb;
	logic signed [15:0] control;
	logic up;
	logic down;
	logic pll_clk;
	logic enable;   //indicator for DCO

	/* Altera PLL IP for 100MHz
 	in case of actual asic implementation, replace it with DCO cell
  
	DCO_0002 u1(
		.refclk(clk_ref),
		.rst(!rst_n),
		.outclk_0(pll_clk),
		.locked()
	);
 
 	This is only for FPGA validation!
 	*/
	
	//Phase Frequency Detector
	PFD u2 (
		.clk(pll_clk),
		.rst_n(rst_n),
		.clk_ref(clk_ref),
		.clk_fb(clk_fb),
		.up(up),
		.down(down)
	);

	// Low Pass Filter
	LPF u3 (
		.clk(pll_clk),
		.rst_n(rst_n),
		.up(up),
		.down(down),
		.filtered_control_signal(control)
	);

	// N-Divide for Feedback Clock
	N_divide u4 (
		.clk_out(pll_out), 
		.rst_n(rst_n), 
		.clk_fb(clk_fb)
	);

	// Lock indicator
	always_ff @(posedge pll_clk or negedge rst_n) begin
		if (!rst_n) begin
			locked <= 1'b0;
		end else if (!up && !down) begin
			locked <= 1'b1;
		end else begin
			locked <= 1'b0;
		end
	end
	
	assign enable = rst_n;

	assign pll_out = pll_clk;
	
endmodule
