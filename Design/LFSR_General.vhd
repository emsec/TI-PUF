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

entity LFSR_General is
	 generic(
		size	  : integer := 8;
		tab1    : integer := 8;
		tab2    : integer := 6;
		tab3    : integer := 5;
		tab4    : integer := 4;
		init    : STD_LOGIC_VECTOR := "10000000");
    Port ( 
			  rst   : in  STD_LOGIC;
			  en    : in  STD_LOGIC;
           clk   : in  STD_LOGIC;
           O     : out STD_LOGIC_VECTOR(1 to size));
end LFSR_General;

architecture Behavioral of LFSR_General is

	signal State  		: std_logic_vector(0 to size) := '0' & init;

	signal tab_signal	: std_logic_vector(1 to 4);
	signal feedback 	: std_logic;

begin

	GenReg:	Process(clk, en, rst)
	begin
		if (clk'event AND clk = '1') then
			if (rst = '1') then
				State		<= '0' & init;
			elsif (en = '1') then
				State		<= '0' & feedback & State (1 to size-1);
			end if;	
		end if;
	end process;

	feedback <= State(tab1) XOR State(tab2) XOR State(tab3) XOR State(tab4);

	O			<= State(1 to size);

end Behavioral;

