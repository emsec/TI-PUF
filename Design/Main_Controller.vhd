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

entity Main_Controller is
	generic (Max: integer := 1024);
	port(
		clk								: in  std_logic;
		rst								: in  std_logic;
		Run_Count 						: in  std_logic_vector(integer(ceil(log2(real(Max))))-1 downto 0);
		Gen_Mask_rst					: out std_logic;
		Gen_Mask_done					: in  std_logic;
		Masked_Evaluate_rst			: out std_logic;
		Masked_Evaluate_done			: in  std_logic;
		Masked_Response_rst			: out std_logic;
		Masked_Response_en			: out std_logic;
		Masked_Voting_rst				: out std_logic;
		Masked_Voting_en				: out std_logic;
		Masked_Voting_done			: in  std_logic;
		PUF_done							: in  std_logic;
		Evaluate_Bottom				: out std_logic;
		Reg_Response_Top_en			: out std_logic;
		done								: out std_logic);
end entity Main_Controller;

architecture dfl of Main_Controller is

	type FSM_STATES is  (S_Start, S_Wait_for_Mask, S_Voting_Loop, S_Voting_Update, S_Wait_for_Evaluate, S_Done);

  	signal fsm_state    				: FSM_STATES := S_Start;
  	signal next_state   				: FSM_STATES;

	constant CounterSize				: INTEGER := integer(ceil(log2(real(Max))));
	signal Max_vector					: UNSIGNED (CounterSize-1 downto 0);
	
	signal Counter_Value				: UNSIGNED (CounterSize-1 downto 0);
	signal Counter_rst				: STD_LOGIC;
	signal Counter_en					: STD_LOGIC;

	signal Evaluate_Bottom_Reg			: STD_LOGIC;
	signal Evaluate_Bottom_Reg_Update: STD_LOGIC;

begin

	Max_vector 			<= unsigned(Run_Count);
	Evaluate_Bottom	<= Evaluate_Bottom_Reg;
	
	----------------------------------------------------			
	
	FSM: process(clk, rst, next_state, Evaluate_Bottom_Reg_Update, Counter_rst, Counter_en, Counter_Value)
	begin
		if (rising_edge(clk)) then
			if (rst = '1') then
				fsm_state 	   		<= S_Start;	
				Evaluate_Bottom_Reg	<= '0';
			else
				fsm_state				<= next_state;
				Evaluate_Bottom_Reg	<= Evaluate_Bottom_Reg_Update;
			end if;
			
			if (Counter_rst = '1') then
				Counter_Value	<= (others => '0');
			elsif (Counter_en = '1') then
				Counter_Value	<= Counter_Value + 1;
			end if;	
		end if;
	end process;	
			
	----------------------------------------------------			
			
	state_change:	process(fsm_state, rst, Counter_Value, Max_Vector, Gen_Mask_done, PUF_done, Masked_Evaluate_done, Masked_Voting_done, Evaluate_Bottom_Reg)
	begin
		Counter_rst						<= '0';
		Counter_en						<= '0';
		Gen_Mask_rst					<= '0';
		Masked_Evaluate_rst			<= '0';
		Masked_Response_rst			<= '0';
		Masked_Response_en			<= '0';
		Masked_Voting_rst				<= '0';
		Masked_Voting_en				<= '0';
		Reg_Response_Top_en			<= '0';
		Evaluate_Bottom_Reg_Update	<= Evaluate_Bottom_Reg;
		done								<= '0';
		
		next_state						<= fsm_state;
		
		case fsm_state is
		when S_Start =>
			Gen_Mask_rst				<= '1';
			next_state					<= S_Wait_for_Mask;

		when S_Wait_for_Mask =>
			if (Gen_Mask_done = '1') then
				Masked_Evaluate_rst	<= '1';
				Masked_Response_rst	<= '1';
				Masked_Voting_rst		<= '1';
				Counter_rst				<= '1';
				next_state				<= S_Voting_Loop;
			end if;	

		when S_Voting_Loop =>
			if (PUF_done = '1') then
				Masked_Response_en	<= '1';
				next_state				<= S_Wait_for_Evaluate;
			end if;
			
		when S_Wait_for_Evaluate =>
			if (PUF_done = '0') then
				if (Masked_Evaluate_done = '1') then
					Masked_Voting_en	<= '1';
					next_state			<= S_Voting_Update;
				else	
					next_state			<= S_Voting_Loop;
				end if;	
			end if;
			
		when S_Voting_Update =>
			if (Masked_Voting_done = '1') then
				Counter_en					<= '1';
				
				if (Counter_Value /= Max_Vector) then
					Masked_Evaluate_rst	<= '1';
					Masked_Response_rst	<= '1';
					next_state				<= S_Voting_Loop;
				else
					Evaluate_Bottom_Reg_Update	<= '1';

					if (Evaluate_Bottom_Reg = '0') then
						Reg_Response_Top_en	<= '1';
						next_state				<= S_Start;
					else
						next_state				<= S_Done;
					end if;	
				end if;
			end if;	

		when S_Done =>
			done							<= '1';
			
		end case;
	end process;	

end architecture;
