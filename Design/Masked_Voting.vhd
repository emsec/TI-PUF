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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.Numeric_Std.ALL;
use IEEE.math_real.all;

entity Masked_Voting is
Generic (Max : integer := 1000);
Port (  
	clk          : in  STD_LOGIC;
	rst      	 : in  STD_LOGIC;
	en 			 : in  STD_LOGIC;
	input        : in  STD_LOGIC_VECTOR (2 downto 0);
	output       : out STD_LOGIC_VECTOR (2 downto 0);
	done		    : out STD_LOGIC);
end Masked_Voting;

architecture dfl of Masked_Voting is

	constant CounterSize	: INTEGER := integer(ceil(log2(real(Max))));

	signal V0, S0, O0, W0: UNSIGNED (CounterSize-1 downto 0); -- INTEGER RANGE 0 to Max-1;
	signal V1, S1, O1, W1: UNSIGNED (CounterSize-1 downto 0); -- INTEGER RANGE 0 to Max-1;

	signal r,  r_update	: STD_LOGIC_VECTOR(1 downto 0);
	signal r0, r0Not		: STD_LOGIC;
	signal swap				: STD_LOGIC_VECTOR(1 downto 0);
	signal swapReg			: STD_LOGIC_VECTOR(1 downto 0);
	signal en2				: STD_LOGIC;
	signal en3				: STD_LOGIC;
	signal en4				: STD_LOGIC;

begin
		
	enableRegInst1: ENTITY work.FlipFlop
	Port Map (clk, en, en2);

	enableRegInst2: ENTITY work.FlipFlop
	Port Map (clk, en2, en3);
	
	enableRegInst3: ENTITY work.FlipFlop
	Port Map (clk, en3, en4);

	enableRegInst4: ENTITY work.FlipFlop
	Port Map (clk, en4, done);

	--------
	
	RegSwapInst: ENTITY work.Reg_en
	Generic Map (2)
	Port Map ( clk, en, swap, swapReg);
		
	CounterSub0: ENTITY work.Masked_Counter_Sub
	Generic Map (CounterSize)
	Port Map ( clk, rst, en2, en3, en4, r0Not, S0, O0, W0, V0);
	
	CounterSub1: ENTITY work.Masked_Counter_Sub
	Generic Map (CounterSize)
	Port Map ( clk, rst, en2, en3, en4, r0,    S1, O1, W1, V1);
 	
	RegInst: ENTITY work.Reg_en_clr
	Generic Map (2)
	Port Map ( clk, rst, en4, r_update, r);
		
	--------
	
	MuxInst0: ENTITY work.Mux_Counter
	Generic Map (CounterSize)
	Port Map ( V0, V1, swapReg(0), S0);
	
	MuxInst1: ENTITY work.Mux_Counter
	Generic Map (CounterSize)
	Port Map ( V1, V0, swapReg(0), S1);
	
	--------
	
	MuxInst2: ENTITY work.Mux_Counter
	Generic Map (CounterSize)
	Port Map ( O0, O1, swapReg(1), W0);
	
	MuxInst3: ENTITY work.Mux_Counter
	Generic Map (CounterSize)
	Port Map ( O1, O0, swapReg(1), W1);	
	
	--------
	
	ComparatorInst: ENTITY work.Comparator
	Generic Map (CounterSize)
	Port Map ( V0, V1, output(0));

	-------------------------------------------------

	r_update(0)	<= input(1);
	r_update(1)	<= input(2);
	
	r0				<=      input(0);
	r0Not			<= NOT  input(0);
	
	swap(0)		<= input(1) XOR r(0);
	swap(1)		<= input(2) XOR r(1);	
	
	output(1)	<= r(0);
	output(2)	<= r(1);
	
end dfl;

