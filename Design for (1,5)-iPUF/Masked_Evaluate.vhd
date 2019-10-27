----------------------------------------------------------------------------------
-- COMPANY:		Ruhr University Bochum, Embedded Security
-- AUTHOR:		Anita Aghaie, Amir Moradi
-- TOIPC:               TI-PUF: Toward Side-Channel Resistant Physical Unclonable Functions
----------------------------------------------------------------------------------
-- Copyright (c) 2019, Anita Aghaie, Amir Moradi
-- All rights reserved.

-- BSD-3-Clause License
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--     * Redistributions of source code must retain the above copyright
--       notice, this list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
--     * Neither the name of the copyright holder, their organization nor the
--       names of its contributors may be used to endorse or promote products
--       derived from this software without specific prior written permission.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTERS BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Masked_Evaluate is
Port (  
	clk           : in  STD_LOGIC;
	rst      	  : in  STD_LOGIC;
	Bottom		  : in  STD_LOGIC;
	Mask_128Bits  : in  STD_LOGIC_VECTOR (0 to 127);
	challenge     : in  STD_LOGIC_VECTOR (0 to 63);
	pos_challenge : in  STD_LOGIC_VECTOR (0 to 2);
	pos           : in  STD_LOGIC_VECTOR (0 to 63);
	PUF_done		  : in  STD_LOGIC;
	PUF_input     : out STD_LOGIC_VECTOR (0 to 64);
	PUF_trigger	  : out STD_LOGIC;
	done          : out STD_LOGIC);
end Masked_Evaluate;

architecture dfl of Masked_Evaluate is
	
	signal Mask1			 		: STD_LOGIC_VECTOR (0 to 63);
	signal Mask2			 		: STD_LOGIC_VECTOR (0 to 63);
	
	signal S0						: STD_LOGIC_VECTOR(0 to 63);
	signal S1						: STD_LOGIC_VECTOR(0 to 63);
	signal S2						: STD_LOGIC_VECTOR(0 to 63);
	
	signal a							: STD_LOGIC_VECTOR(0 to 64);
	signal b							: STD_LOGIC_VECTOR(0 to 64);
	signal f							: STD_LOGIC_VECTOR(0 to 64);
	signal p							: STD_LOGIC_VECTOR(0 to 64);
	
	signal c							: STD_LOGIC_VECTOR(0 to 64);
		
	type sel_array is array (64 downto 0) of STD_LOGIC_VECTOR(1 downto 0);
	signal sel						: sel_array;	
		
	signal LFSR2bit_en			: STD_LOGIC_VECTOR(0 to 65);
	signal LFSR2bit_en_port		: STD_LOGIC_VECTOR(0 to 64);
	signal LFSR2bit_ndone		: STD_LOGIC_VECTOR(0 to 64);

begin

	Gen_MUX: FOR i in 0 to 64 GENERATE
		MUXInst: entity work.MUX3to1
		Port Map (
			a(i),
			b(i),
			f(i),
			sel(i),
			c(i));
			
		LFSR2bitInst: entity work.LFSR2bit
		Port Map (
			clk,
			rst,
			LFSR2bit_en_port(i),
			LFSR2bit_ndone(i),
			sel(i));		
		
		LFSR2bit_en_port(i) 	<= LFSR2bit_en(i) AND p(i);
		LFSR2bit_en(i+1)		<= LFSR2bit_en(i) AND (LFSR2bit_ndone(i) NAND p(i));
	END GENERATE;


	ControllerInst: entity work.Controller_Eval
	Port Map (	
		clk,
		rst,
		PUF_done,
		LFSR2bit_en(65),
		LFSR2bit_en(0),
		PUF_trigger,
		done);

	------------------------------------
	
	Mask1						<= Mask_128Bits(0 to  63);
	Mask2						<= Mask_128Bits(64 to 127);
		
	S0 						<= challenge XOR Mask1 XOR Mask2;
	S1							<= Mask1 and pos;
	S2							<= Mask2 and pos;
	
	a                    <= S0(0 to 31) & pos_challenge(0) & S0(32 to 63);
	b                    <= S1(0 to 31) & pos_challenge(1) & S1(32 to 63);
	f                    <= S2(0 to 31) & pos_challenge(2) & S2(32 to 63);

	p                    <= pos(0 to 31) & Bottom & pos(32 to 63);

	PUF_input				<= c;
	
end dfl;

