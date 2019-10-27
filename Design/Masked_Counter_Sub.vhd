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

entity Masked_Counter_Sub is
Generic (size : integer := 10);
Port (  
	clk          : in  STD_LOGIC;
	rst      	 : in  STD_LOGIC;
	update1		 : in  STD_LOGIC;
	update2		 : in  STD_LOGIC;
	update3		 : in  STD_LOGIC;
	add			 : in  STD_LOGIC;
	input1       : in  UNSIGNED (size-1 downto 0);
	output1      : out UNSIGNED (size-1 downto 0);
	input2       : in  UNSIGNED (size-1 downto 0);
	output2      : out UNSIGNED (size-1 downto 0));
end Masked_Counter_Sub;

architecture dfl of Masked_Counter_Sub is

	signal Mid_Reg1			: UNSIGNED (size-1 downto 0);
	signal Mid_Reg1_Update	: UNSIGNED (size-1 downto 0);
	signal Mid_Reg2			: UNSIGNED (size-1 downto 0);
	signal Mid_Reg2_Update	: UNSIGNED (size-1 downto 0);
	signal Final_Reg			: UNSIGNED (size-1 downto 0);
	signal Final_Reg_Update	: UNSIGNED (size-1 downto 0);
	signal Add_Unsigned		: UNSIGNED (0 downto 0);

begin
		
	Counter: process(clk, rst, update1, update2, update3, Mid_Reg1_Update, Mid_Reg2_Update, Final_Reg_Update)
	begin
		if (rising_edge(clk)) then
			if (rst = '1') then
				Mid_Reg1		<= (others => '0');
			elsif (update1  = '1') then
				Mid_Reg1		<= Mid_Reg1_Update;
			end if;

			if (rst = '1') then
				Mid_Reg2		<= (others => '0');
			elsif (update2  = '1') then
				Mid_Reg2		<= Mid_Reg2_Update;
			end if;
			
			if (rst = '1') then
				Final_Reg	<= (others => '0');
			elsif (update3  = '1') then
				Final_Reg	<= Final_Reg_Update;
			end if;
		end if;
	end process;	

	Mid_Reg1_Update	<= input1;
	Mid_Reg2_Update	<= input2;
	Add_Unsigned(0)	<= add;
	Final_Reg_Update	<= Mid_Reg2 + Add_Unsigned;
		
	output1				<= Mid_Reg1;
	output2				<= Final_Reg;
	
end dfl;

