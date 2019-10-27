// taken from: https://github.com/scluconn/DA_PUF_Library

module ixor_apuf #(parameter N1=16, N2=N1+1, K1=2, K2=2, POS=N1/2)(
	clk,
	tigSig_t,
	tigSig_b,
	c,
	respReady_t,
	respReady_b,
	respBitT,
	respBitB
	);

	input clk;                        // Clock
	input tigSig_t;                   // Trigger signal for upper XOR APUF
	input tigSig_b;                   // Trigger signal for lower XOR APUF
	input [N2-1:0] c;                 // Challenge
	output respReady_t;               // Response ready status signal of top    XOR APUFs
	output respReady_b;               // Response ready status signal of bootom XOR APUFs 
	output respBitT;    			       // Response bit of top    XOR APUFs
	output respBitB;                  // Response bit of bottom XOR APUFs

	
	wire [N1-1:0] c_t;                // Challenge for top xor PUFs
	wire [K1-1:0] respBitA_t;         // Responses of APUFs in uppuer XOR PUF
	wire [K2-1:0] respBitA_b;         // Responses of APUFs in lower XOR PUF
	
	assign c_t = {c[N2-1:POS+2], c[POS:0]}; 	
	
    // UPPER XOR APUF
	(*KEEP_HIERARCHY="TRUE"*)
	xor_apuf #(.N(N1),.K(K1)) XAPUF_T(
	   .clk(clk),
		.tigSignal(tigSig_t),
		.c(c_t),
		.respReady(respReady_t),
		.respBitA(respBitA_t),
		.respBit(respBitT)
	);
	
	// LOWER XOR APUF
	(*KEEP_HIERARCHY="TRUE"*)
	xor_apuf #(.N(N2),.K(K2)) XAPUF_B(
		.clk(clk),
		.tigSignal(tigSig_b),
		.c(c),
		.respReady(respReady_b),
		.respBitA(respBitA_b),
		.respBit(respBitB)
	);
	
		
endmodule
