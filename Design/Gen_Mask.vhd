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
use work.lib.all;

entity Gen_Mask is
	Generic (
		Max 		: integer :=  8;
		size		: integer := 64;
		Mask_size: integer :=  2;
		fm_size	: integer :=  2);
	port(
		clk			: in  std_logic;
		PRNG_rst		: in  std_logic;
		rst			: in  std_logic;
		Count			: in  std_logic_vector(integer(ceil(log2(real(Max))))-1 downto 0);
		Mask			: out Mask_array(Mask_size-1 	   downto 0);
		Pos			: out std_logic_vector(size-1    downto 0);
		fresh_mask	: out std_logic_vector(fm_size-1 downto 0);
		done     	: out std_logic);
end entity Gen_Mask;

architecture dfl of Gen_Mask is

	constant Log_size    : integer := integer(ceil(log2(real(size))));
	signal Random	: std_logic_vector(Log_size+Mask_size-1  downto 0);

	type Random_array_type is array (integer range <>) of std_logic_vector(1 to 31);
	signal Random_array	: Random_array_type(Log_size+Mask_size-1  downto 0);
	
	constant Inits : STD_LOGIC_VECTOR(1 to 31*(Log_size+Mask_size)) := MakeRand(31, Log_size+Mask_size);

begin
	
	Gen_LFSRs: FOR i in 0 to Log_size+Mask_size-1 GENERATE
		LFSR_Inst: entity work.LFSR_General
		Generic Map ( 31, 31, 28, 0, 0, Inits(i*31+1 to (i+1)*31))
		Port Map (PRNG_rst, '1', clk,	Random_array(i));	
		
		Random(i)	<= Random_array(i)(31);
	END GENERATE;
	
	Gen_Pos_Inst: entity work.Generate_Pos
	Generic Map (Max, Size, Mask_size)
	Port Map(clk, rst, Count, Random, Mask, Pos, done);

	fresh_mask	<= Random(fm_size-1 downto 0);

end architecture;
