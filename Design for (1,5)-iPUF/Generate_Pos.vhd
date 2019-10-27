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

entity Generate_Pos is
	Generic (
		Max 		: integer :=  8;
		size		: integer := 64;
		Mask_size: integer := 2);
	port(
		clk		: in  std_logic;
		rst		: in  std_logic;
		Count		: in  std_logic_vector(integer(ceil(log2(real(Max))))-1            downto 0);
		Random   : in  std_logic_vector(integer(ceil(log2(real(size))))-1+Mask_size downto 0);
		Mask		: out Mask_array(Mask_size-1 	downto 0);
		Pos		: out std_logic_vector(size-1 downto 0);
		done     : out std_logic);
end entity Generate_Pos;

architecture dfl of Generate_Pos is

	constant CounterSize : integer := integer(ceil(log2(real(Max))));
	constant Log_size    : integer := integer(ceil(log2(real(size))));
	
	signal Random1			: std_logic_vector(Log_size-1  downto 0);
	signal Random2			: std_logic_vector(Mask_size-1 downto 0);
	
	signal Counter_en		: std_logic;
	signal Counter_rst	: std_logic;
	signal Counter_value	: std_logic_vector(CounterSize-1 downto 0);
	
	type Mask_array2 is array (integer range <>) of std_logic_vector(size-1 downto 0);
	signal MaskReg 		: Mask_array2(Mask_size-1 downto 0);

	signal PosReg_en		: std_logic_vector(size-1 downto 0);

begin
	
	Random1	<= Random(Log_size-1            downto 0);
	Random2	<= Random(Log_size+Mask_size-1  downto Log_size);
	
	Counter_Inst: entity work.Counter
	Generic map (CounterSize)
	Port Map (clk, Counter_en, rst, Counter_Value);

	Gen_FFs: FOR i in 0 to size-1 GENERATE
		PosFF_Inst: entity work.FlipFlop_en_rst
		Port Map (clk, PosReg_en(i), rst, '1', Pos(i));
		
		Gen_MaskFFs: FOR j in 0 to Mask_size-1 GENERATE
			MaskFF_Inst: entity work.FlipFlop_en_rst
			Port Map (clk, PosReg_en(i), rst, Random2(j), MaskReg(j)(i));
		END GENERATE;
	END GENERATE;

	DecoderProcess: Process(Random1, Counter_en)
	begin
		PosReg_en										  <= (others => '0');
		PosReg_en(to_integer(unsigned(Random1))) <= Counter_en;
	end process;
	
	Counter_en	<= '0' WHEN Count = Counter_Value ELSE '1';
	done			<= not Counter_en;

	Gen_Masks: FOR j in 0 to Mask_size-1 GENERATE
		Mask(j)	<= MaskReg(j);
	END GENERATE;

end architecture;
