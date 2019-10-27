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

entity Masked_Response is
Port (  
	clk      	: in  STD_LOGIC;
	rst        	: in  STD_LOGIC;
	en		  		: in  STD_LOGIC;
	PUF_output	: in  STD_LOGIC;
	fresh_mask	: in  STD_LOGIC_VECTOR (0 to 1);
	response   	: out STD_LOGIC_VECTOR (0 to 2));
end Masked_Response;

architecture dfl of Masked_Response is
	
	signal responseReg_Input	: STD_LOGIC_VECTOR(0 to 2);
	signal responseReg_Output	: STD_LOGIC_VECTOR(0 to 2);

begin

	responseRegInst: entity work.Reg_en_clr
	Generic Map (3)
	Port Map (
		clk,
		rst,
		en,
		responseReg_Input,
		responseReg_Output);

	XO3Inst1: entity work.XOR_3
	Port Map (PUF_output,  fresh_mask(0), 		responseReg_Output(0), responseReg_Input(0));
	
	XO3Inst2: entity work.XOR_3
	Port Map (fresh_mask(1), fresh_mask(0), 	responseReg_Output(1), responseReg_Input(1));

	XO3Inst3: entity work.XOR_2
	Port Map (fresh_mask(1),  		          	responseReg_Output(2), responseReg_Input(2));	

	response	<= responseReg_Output;
	
end dfl;

