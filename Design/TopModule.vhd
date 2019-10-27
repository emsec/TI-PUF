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
use IEEE.numeric_std.all;
use work.lib.all;

entity TopModule is
    Port (
	        clk          			: in  STD_LOGIC;
			  PRNG_rst     			: in  STD_LOGIC;
           rst 						: in  STD_LOGIC;

           Challenge					: in  STD_LOGIC_VECTOR (63 downto 0);
			  Run_Count    			: in  STD_LOGIC_VECTOR ( 3 downto 0);
	        MaskedPositions_Count : in  STD_LOGIC_VECTOR ( 2 downto 0);

			  Response_t   			: out STD_LOGIC_VECTOR ( 2 downto 0);  -- just for debugging 
			  Response_b   			: out STD_LOGIC_VECTOR ( 2 downto 0);

           done 						: out STD_LOGIC);
end TopModule;

architecture Behavioral of TopModule is

	signal Gen_Mask_rst	: STD_LOGIC;
	signal Gen_Mask_done	: STD_LOGIC;
	signal fresh_mask    : STD_LOGIC_VECTOR( 0 to     1);
	signal Mask_Pos    	: STD_LOGIC_VECTOR( 0 to    63);
	signal Mask          : Mask_array(1 downto 0);
	signal Mask_128Bits	: STD_LOGIC_VECTOR( 0 to   127);

begin

	Gen_Mask_inst: ENTITY work.Gen_Mask
	Generic Map (8, 64, 2, 2)
	port Map (	
		clk,
		PRNG_rst,
		Gen_Mask_rst,
		MaskedPositions_Count,
		Mask,
		Mask_Pos,
		fresh_mask,
		Gen_Mask_done);

	Mask_128Bits <= Mask(0) & Mask(1);

	---------------------------------------------------

	TIPUF_Inst: entity work.TIPUF
	Generic Map (16)
	Port Map ( 
		clk,
		rst,
		Gen_Mask_rst,
		Gen_Mask_done,
		Run_Count,
		Challenge,
		Mask_Pos,
		Mask_128Bits,
		fresh_mask,
		Response_t,
		Response_b,
		done);		
	
	----------------------------------------
	
end Behavioral;

