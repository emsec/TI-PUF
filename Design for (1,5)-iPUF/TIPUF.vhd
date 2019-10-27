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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity TIPUF is
	Generic (Max : integer :=  1024);
	Port(
		clk		 			: in  std_logic;
		rst		 			: in  std_logic;
		Gen_Mask_rst		: out std_logic;
		Gen_Mask_done		: in  std_logic;
		Run_Count 			: in  std_logic_vector(integer(ceil(log2(real(Max))))-1 downto 0);
		Challenge 			: in  std_logic_vector(0 to 63);
		Mask_Pos	 			: in  std_logic_vector(0 to 63);
		Mask_128Bits		: in  STD_LOGIC_VECTOR(0 to 127);
		fresh_mask			: in  STD_LOGIC_VECTOR(0 to 1);
		Response_t			: out std_logic_vector(0 to 2);
		Response_b			: out std_logic_vector(0 to 2);
		done		 			: out std_logic);
end entity TIPUF;

architecture dfl of TIPUF is

	constant N1  : integer := 64;     -- Challenge length
	constant N2  : integer := N1+1;
	constant K1  : integer := 1;
	constant K2  : integer := 5;      -- No. of APUF
	constant POS : integer := 31;  	 -- Feedback position, the middle position is 31

	signal PUF_Input							: STD_LOGIC_VECTOR(0 to 64);
	signal PUF_trigger_t						: STD_LOGIC;
	signal PUF_trigger_b						: STD_LOGIC;
	signal PUF_trigger						: STD_LOGIC;
	signal PUF_done_t							: STD_LOGIC;
	signal PUF_done_b							: STD_LOGIC;
	signal PUF_done							: STD_LOGIC;
	signal PUF_output_t						: STD_LOGIC;
	signal PUF_output_b						: STD_LOGIC;
	signal PUF_output							: STD_LOGIC;

	signal Masked_Evaluate_rst				: STD_LOGIC;
	signal Masked_Evaluate_done			: STD_LOGIC;
	signal Evaluate_Bottom					: STD_LOGIC;
	
	signal Reg_Response_Top_en				: STD_LOGIC;
	signal Reg_Response_Top					: STD_LOGIC_VECTOR(0 to 2);

	signal Masked_Response_rst          : STD_LOGIC;
	signal Masked_Response_en				: STD_LOGIC;

	signal Masked_Voting_rst           	: STD_LOGIC;
	signal Masked_Voting_en					: STD_LOGIC;
	signal Masked_Voting_input				: STD_LOGIC_VECTOR(2 downto 0);
	signal Masked_Voting_output			: STD_LOGIC_VECTOR(2 downto 0);
	signal Masked_Voting_done				: STD_LOGIC;

begin

	Masked_Evaluate_Inst: entity work.Masked_Evaluate
	Port Map(  
		clk,
		Masked_Evaluate_rst,
		Evaluate_Bottom,
		Mask_128Bits,
		Challenge,
		Reg_Response_Top,
		Mask_Pos,
		PUF_done,
		PUF_Input,
		PUF_trigger,
		Masked_Evaluate_done);
	
	Masked_Response_Inst: entity work.Masked_Response
	Port Map(
		clk,
		Masked_Response_rst,
		Masked_Response_en,
		PUF_output,
		fresh_mask,
		Masked_Voting_input);
	
	Masked_Voting_Inst: entity work.Masked_Voting
	Generic Map (Max)
	Port Map(
		clk,
		Masked_Voting_rst,
		Masked_Voting_en,
		Masked_Voting_input,
		Masked_Voting_output,
		Masked_Voting_done);		

	Reg_Response_Top_Inst: ENTITY work.Reg_en
	Generic Map (3)
	Port Map ( 
		clk, 
		Reg_Response_Top_en, 
		Masked_Voting_output, 
		Reg_Response_Top);

	iXAPUF: ENTITY work.ixor_apuf 
	Generic Map (N1 => N1, N2 => N2, K1 => K1, K2 => K2, POS => POS)
	Port Map (
		clk 				=> clk,
		tigSig_t			=> PUF_trigger_t,
		tigSig_b 		=> PUF_trigger_b,
		c					=> PUF_Input,
		respReady_t		=> PUF_done_t,
		respReady_b		=> PUF_done_b,
		respBitT			=> PUF_output_t,
		respBitB			=> PUF_output_b);

	Controller_Inst: entity work.Main_Controller
	Generic Map (Max)
	Port Map(
		clk,
		rst,
		Run_Count,
		Gen_Mask_rst,
		Gen_Mask_done,
		Masked_Evaluate_rst,
		Masked_Evaluate_done,
		Masked_Response_rst,
		Masked_Response_en,
		Masked_Voting_rst,
		Masked_Voting_en,
		Masked_Voting_done,
		PUF_done,
		Evaluate_Bottom,
		Reg_Response_Top_en,
		done);
			
	------------------------------------------------	

	PUF_trigger_t	<= '0'   			WHEN Evaluate_Bottom = '1' ELSE PUF_trigger;
	PUF_trigger_b	<= PUF_trigger		WHEN Evaluate_Bottom = '1' ELSE '0';	
	PUF_done 		<= PUF_done_b 		WHEN Evaluate_Bottom = '1' ELSE PUF_done_t;
	PUF_output		<= PUF_output_b	WHEN Evaluate_Bottom = '1' ELSE PUF_output_t;

	Response_t		<= Reg_Response_Top;
	Response_b		<=	Masked_Voting_output;
		
end architecture;
