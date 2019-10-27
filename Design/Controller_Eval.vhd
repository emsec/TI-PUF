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

entity Controller_Eval is
	Port(
		clk						: in  std_logic;
		rst						: in  std_logic;
		PUF_done					: in  std_logic;
		LFSR2bit_finish		: in  std_logic;
		LFSR2bit_start			: out std_logic;
		PUF_trigger				: out std_logic;
		done						: out std_logic);
end entity Controller_Eval;


architecture dfl of Controller_Eval is

	type FSM_STATES is  (S_Start, S_WaitForDone, S_End);

  	signal fsm_state    : FSM_STATES := S_Start;
  	signal next_state   : FSM_STATES;

	signal PUF_trigger_int		: STD_LOGIC;

begin

	FSM: process(clk, rst, next_state)
	begin
		if (rising_edge(clk)) then
			if (rst = '1') then
				fsm_state 	   <= S_Start;	
			else
				fsm_state		<= next_state;
			end if;
		end if;
	end process;	
			
	----------------------------------------------------			
				
	state_change:	process(fsm_state, LFSR2bit_finish, PUF_done)
	begin
		LFSR2bit_start			<= '0';
		PUF_trigger				<= '0';
		done						<= '0';
		
		next_state				<= fsm_state;
		
		case fsm_state is
		when S_Start =>
			if (PUF_done = '0') then
				next_state		<= S_WaitForDone;
			end if;
			
		when S_WaitForDone =>
			PUF_trigger			<= '1';
			
			if (PUF_done = '1') then
				LFSR2bit_start	<= '1';

				if (LFSR2bit_finish = '0') then
					next_state		<= S_Start;
				else
					next_state		<= S_End;
				end if;
			end if;
			
		when S_End =>
			done					<= '1';
			
		end case;
	end process;	

end architecture;
