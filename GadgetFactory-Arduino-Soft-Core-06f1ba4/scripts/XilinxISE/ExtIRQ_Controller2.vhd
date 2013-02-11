--**********************************************************************************************
-- External Interrupt Controller Block Peripheral for the AVR Core
-- Version 1.00
-- Created 01.26.2013
-- Designed by Rob Brown
--**********************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

use WORK.AVRuCPackage.all;

entity ExtIRQ_Controller is Port(
			-- begin Signals required by AVR8 for this core, do not modify.
			nReset 		: in  STD_LOGIC;
			clk 			: in  STD_LOGIC;
			adr 			: in  STD_LOGIC_VECTOR (15 downto 0);
			dbus_in 		: in  STD_LOGIC_VECTOR (7 downto 0);
			dbus_out 	: out STD_LOGIC_VECTOR (7 downto 0);
			iore 			: in  STD_LOGIC;
			iowe 			: in  STD_LOGIC;
			out_en		: out STD_LOGIC;
			-- end Signals required by AVR8 for this core, do not modify.
			--globint  	: in  STD_LOGIC;
			clken			: in  STD_LOGIC;
			irq_clken	: in	STD_LOGIC;
			extpins		: in  STD_LOGIC_VECTOR(7 downto 0);
			INTx			: out STD_LOGIC_VECTOR(7 downto 0);
			INTxAck		: in  STD_LOGIC_VECTOR(7 downto 0)
			);
end ExtIRQ_Controller;

-----------------------------------------------------------------------

architecture RTL of ExtIRQ_Controller is

-- Registers
signal EIMSK  : std_logic_vector(7 downto 0);
signal EIFR	  : std_logic_vector(7 downto 0);
signal EICR	  : std_logic_vector(7 downto 0);

  -- EIMSK Bits
alias INT0  : std_logic is EIMSK(0);
alias INT1  : std_logic is EIMSK(1);
alias INT2  : std_logic is EIMSK(2);
alias INT3  : std_logic is EIMSK(3);
alias INT4  : std_logic is EIMSK(4);
alias INT5  : std_logic is EIMSK(5);
alias INT6  : std_logic is EIMSK(6);
alias INT7  : std_logic is EIMSK(7);

  -- EIFR Bits
alias INTF0  : std_logic is EIFR(0);
alias INTF1  : std_logic is EIFR(1);
alias INTF2  : std_logic is EIFR(2);
alias INTF3  : std_logic is EIFR(3);
alias INTF4  : std_logic is EIFR(4);
alias INTF5  : std_logic is EIFR(5);
alias INTF6  : std_logic is EIFR(6);
alias INTF7  : std_logic is EIFR(7); 

-- EICR Bits
alias ISC40  : std_logic is EICR(0);
alias ISC41  : std_logic is EICR(1);
alias ISC50  : std_logic is EICR(2);
alias ISC51  : std_logic is EICR(3);
alias ISC60  : std_logic is EICR(4);
alias ISC61  : std_logic is EICR(5);
alias ISC70  : std_logic is EICR(6);
alias ISC71  : std_logic is EICR(7); 

signal INTxRE : std_logic_vector (7 downto 0); -- Rising edge of external input INTx
signal INTxFE : std_logic_vector (7 downto 0); -- Falling edge of external input INT0

-- Risign/falling edge detectors	
signal INTxLatched : std_logic_vector (7 downto 0);	


-- Synchronizer signals
signal INTxSA  : std_logic_vector (7 downto 0);
signal INTxSB  : std_logic_vector (7 downto 0); -- Output of the synchronizer for INTx

--constant EIMSK_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#39#);
--constant EIFR_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#38#);
--constant EICR_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#3A#);

begin

-- Synchronizers
SyncDFFs:process(clk,nReset)	
begin	
 if (nReset='0') then      -- Reset
	INTxSA <= (others => '0');  
	INTxSB <= (others => '0');   
 elsif (clk='1' and clk'event) then -- Clock
  if (irq_clken='1') then       -- Clock Enable(Note 2)	 
		INTxSA <= extpins;  
		INTxSB <= INTxSA;
  end if;	 	
 end if;	 
end process;	


EdgeDetect:process(clk,nReset)
begin
 if  (nReset='0')  then                 -- Reset
  INTxRE <= (others => '0');
  INTxFE <= (others => '0');
  
  INTxLatched <= (others =>'0');
  
 elsif  (clk='1' and clk'event)  then -- Clock
  if (irq_clken='1') then             -- Clock Enable   
   INTxRE <= not INTxRE and (INTxSB and not INTxLatched);
   INTxFE <= not INTxFE and (not INTxSB and INTxLatched);   
   INTxLatched <= INTxSB;
  end if; 
 end if;
end process;		

-- set the flags

--EIFR <= (INTx 

--INTxF <= ((INTxFE(0) and EIMSK(0) and ISC and not CS10) or     -- Falling edge	 "110"
--            (INT0RE and CS12 and CS11 and CS10);           -- Rising edge	 "111"
			
--INT1_En <= ((INT1FE and CS22 and CS21 and not CS20) or     -- Falling edge	 "110"
--            (INT1RE and CS22 and CS21 and CS20);           -- Rising edge	 "111"

INT0to3_Proc:process(clk,nReset)
begin
 if (nReset='0') then 
  INTx(3 downto 0) <= (others => '0');
 elsif  (clk='1' and clk'event)  then
  if (clken='1') then       -- Clock Enable	
   --if (globint = '1') then -- SREG I bit set, interrupts enabled
		-- interrupts 0 through 3 do not set their corresponding EIFR flag! See Atmega103 Data Sheet top of page 31.
		-- these four interrupts also do not use EICR bits. They are always level triggered, active low.
    	--INTx(0) <= (INT0 and not extpins(0));
		--INTx(1) <= (INT1 and not extpins(1));
		--INTx(2) <= (INT2 and not extpins(2));
		--INTx(3) <= (INT3 and not extpins(3));		
   --end if;
  end if;	 
 end if;	
end process;


EIMSK_Bits:process(clk,nReset)
begin
 if (nReset='0') then 
  EIMSK <= (others => '0');
 elsif  (clk='1' and clk'event)  then
  if (clken='1') then       -- Clock Enable	
   if (adr=EIMSK_Address and iowe='1') then
    EIMSK <= dbus_in;	
   end if;
  end if;	 
 end if;	
end process;

EIFR_Bits:process(clk,nReset)
begin
 if (nReset='0') then 
  EIFR <= (others => '0');
 elsif  (clk='1' and clk'event)  then
  if (clken='1') then       -- Clock Enable	
   if (adr=EIFR_Address and iowe='1') then
    EIFR(7 downto 4) <= dbus_in(7 downto 4);	
	 EIFR(3 downto 0) <= "0000"; -- in Atmega103, these bits a reserved and always read '0', See Atmega103 Data Sheet top of page 31. 	
   end if;
  end if;	 
 end if;	
end process;

EICR_Bits:process(clk,nReset)
begin
 if (nReset='0') then 
  EICR <= (others => '0');
 elsif  (clk='1' and clk'event)  then
  if (clken='1') then       -- Clock Enable	
   if (adr=EICR_Address and iowe='1') then
    EICR <= dbus_in;	
   end if;
  end if;	 
 end if;	
end process;

out_en <= '1' when ((adr=EIMSK_Address or adr=EIFR_Address or adr=EICR_Address) and iore='1') else '0';  

-- Synopsys version
dbus_out <= EIMSK when (adr=EIMSK_Address) else 
				EIFR when (adr=EIFR_Address) else 
            EICR when (adr=EICR_Address) else
				"ZZZZZZZZ";	
end RTL;

