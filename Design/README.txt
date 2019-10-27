----------------------------------------------------------------------------------
COMPANY:	Ruhr University Bochum, Embedded Security
AUTHOR:		Anita Aghaie, Amir Moradi
TOIPC:		TI-PUF: Toward Side-Channel Resistant Physical Unclonable Functions
----------------------------------------------------------------------------------
Copyright (c) 2019, Anita Aghaie, Amir Moradi
 All rights reserved.

BSD-3-Clause License
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the copyright holder, their organization nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTERS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
----------------------------------------------------------------------------------

This design package shows how to apply the TI-PUF concept on Interpose PUF[1].
To this end, the design makes use of the (1,5)-Interpose PUF, i.e., the top layer
consists of a single 64-bit APUF, and the bottom layer a 5-XOR APUF, each a 65-bit
APUF. The interpose bit (for the bottom layer) is 31, i.e., exactly at the middle
of the APUFs of the bottom layer.

The main module is in the file "TopModule.vhd".
In order to generate the masks (in the file "Gen_Mask.vhd"), the design exemplary
makes use of 31-bit LFSRs with maximum cycle based on [2].

The verilog files in this package are of the interpose PUF design taken from [3].

[1] https://doi.org/10.13154/tches.v2019.i4.243-290
[2] http://courses.cse.tamu.edu/walker/csce680/lfsr_table.pdf
[3] https://github.com/scluconn/DA_PUF_Library

----------------------------------------------------------------------------------
