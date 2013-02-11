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
			dbus_out 	: out  STD_LOGIC_VECTOR (7 downto 0);
			iore 			: in  STD_LOGIC;
			iowe 			: in  STD_LOGIC;
			out_en		: out STD_LOGIC
			-- end Signals required by AVR8 for this core, do not modify.
			);
end ExtIRQ_Controller;

-----------------------------------------------------------------------

architecture Behavioral of ExtIRQ_Controller is

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

signal INT0RE : std_logic; -- Rising edge of external input INT0
signal INT0FE : std_logic; -- Falling edge of external input INT0
signal INT1RE : std_logic; -- Rising edge of external input INT1
signal INT1FE : std_logic; -- Falling edge of external input INT1
signal INT2RE : std_logic; -- Rising edge of external input INT2
signal INT2FE : std_logic; -- Falling edge of external input INT2
signal INT3RE : std_logic; -- Rising edge of external input INT3
signal INT3FE : std_logic; -- Falling edge of external input INT3
signal INT4RE : std_logic; -- Rising edge of external input INT4
signal INT4FE : std_logic; -- Falling edge of external input INT4
signal INT5RE : std_logic; -- Rising edge of external input INT5
signal INT5FE : std_logic; -- Falling edge of external input INT5
signal INT6RE : std_logic; -- Rising edge of external input INT6
signal INT6FE : std_logic; -- Falling edge of external input INT6
signal INT7RE : std_logic; -- Rising edge of external input INT7
signal INT7FE : std_logic; -- Falling edge of external input INT7

-- Risign/falling edge detectors	
signal INT0Latched : std_logic;	
signal INT1Latched : std_logic;
signal INT2Latched : std_logic;
signal INT3Latched : std_logic;
signal INT4Latched : std_logic;
signal INT5Latched : std_logic;
signal INT6Latched : std_logic;
signal INT7Latched : std_logic;	

-- Synchronizer signals
signal INT0SA  : std_logic;
signal INT0SB  : std_logic; -- Output of the synchronizer for INT0
signal INT1SA  : std_logic;
signal INT1SB  : std_logic; -- Output of the synchronizer for INT1
signal INT2SA  : std_logic;
signal INT2SB  : std_logic; -- Output of the synchronizer for INT2
signal INT3SA  : std_logic;
signal INT3SB  : std_logic; -- Output of the synchronizer for INT3
signal INT4SA  : std_logic;
signal INT4SB  : std_logic; -- Output of the synchronizer for INT4
signal INT5SA  : std_logic;
signal INT5SB  : std_logic; -- Output of the synchronizer for INT5
signal INT6SA  : std_logic;
signal INT6SB  : std_logic; -- Output of the synchronizer for INT6
signal INT7SA  : std_logic;
signal INT7SB  : std_logic; -- Output of the synchronizer for INT7

--constant EIMSK_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#39#);
--constant EIFR_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#38#);
--constant EICR_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#3A#);

begin

-- Synchronizers
SyncDFFs:process(cp2,ireset)	
begin	
 if (ireset='0') then      -- Reset
	INT0SA <= '0';  
	INT0SB <= '0';   
	INT1SA <= '0';  
	INT1SB <= '0';   
	INT2SA <= '0';  
	INT2SB <= '0';   
	INT3SA <= '0';  
	INT3SB <= '0';   
	INT4SA <= '0';  
	INT4SB <= '0';   
	INT5SA <= '0';  
	INT5SB <= '0';   
	INT6SA <= '0';  
	INT6SB <= '0';   
	INT7SA <= '0';  
	INT7SB <= '0';   
 elsif (cp2='1' and cp2'event) then -- Clock
  if (tmr_cp2en='1') then       -- Clock Enable(Note 2)	 
		INT0SA <= INT0;  
		INT0SB <= INT0SA;   
		INT1SA <= INT1;  
		INT1SB <= INT1SA;
		INT2SA <= INT2;  
		INT2SB <= INT2SA;
		INT3SA <= INT3;  
		INT3SB <= INT3SA;
		INT4SA <= INT4;  
		INT4SB <= INT4SA;
		INT5SA <= INT5;  
		INT5SB <= INT5SA;
		INT6SA <= INT6;  
		INT6SB <= INT6SA;
		INT7SA <= INT7;  
		INT7SB <= INT7SA;
  end if;	 	
 end if;	 
end process;	

-- Prescaler 1 for TCNT1 and TCNT2
Prescaler_1:process(cp2,ireset)
begin
 if  (ireset='0')  then                 -- Reset
  INT0RE <= '0';
  INT0FE <= '0';
  INT1RE <= '0';
  INT1FE <= '0';
  INT2RE <= '0';
  INT2FE <= '0';
  INT3RE <= '0';
  INT3FE <= '0';
  INT4RE <= '0';
  INT4FE <= '0';
  INT5RE <= '0';
  INT5FE <= '0';
  INT6RE <= '0';
  INT6FE <= '0';
  INT7RE <= '0';
  INT7FE <= '0';
  INT0Latched <= '0';
  INT1Latched <= '0';
  INT2Latched <= '0';
  INT3Latched <= '0';
  INT4Latched <= '0';
  INT5Latched <= '0';
  INT6Latched <= '0';
  INT7Latched <= '0';
 elsif  (cp2='1' and cp2'event)  then -- Clock
  if (tmr_cp2en='1') then             -- Clock Enable   
   INT0RE <= not INT0RE and (INT0SB and not INT0Latched);
   INT0FE <= not INT0FE and (not INT0SB and INT0Latched);
   INT1RE <= not INT1RE and (INT1SB and not INT1Latched);
   INT1FE <= not INT1FE and (not INT1SB and INT1Latched);
	INT2RE <= not INT2RE and (INT2SB and not INT2Latched);
   INT2FE <= not INT2FE and (not INT2SB and INT2Latched);
	INT3RE <= not INT3RE and (INT3SB and not INT3Latched);
   INT3FE <= not INT3FE and (not INT3SB and INT3Latched);
	INT4RE <= not INT4RE and (INT4SB and not INT4Latched);
   INT4FE <= not INT4FE and (not INT4SB and INT4Latched);
	INT5RE <= not INT5RE and (INT5SB and not INT5Latched);
   INT5FE <= not INT5FE and (not INT5SB and INT5Latched);
	INT6RE <= not INT6RE and (INT6SB and not INT6Latched);
   INT6FE <= not INT6FE and (not INT6SB and INT6Latched);
	INT7RE <= not INT7RE and (INT7SB and not INT7Latched);
   INT7FE <= not INT7FE and (not INT7SB and INT7Latched);
   INT0Latched <= INT0SB;
   INT1Latched <= INT1SB;
	INT2Latched <= INT2SB;
	INT3Latched <= INT3SB;
	INT4Latched <= INT4SB;
	INT5Latched <= INT5SB;
	INT6Latched <= INT6SB;
	INT7Latched <= INT7SB;
  end if; 
 end if;
end process;		

--INT0_En <= ((INT0FE and CS12 and CS11 and not CS10) or     -- Falling edge	 "110"
--            (INT0RE and CS12 and CS11 and CS10);           -- Rising edge	 "111"
			
--INT1_En <= ((INT1FE and CS22 and CS21 and not CS20) or     -- Falling edge	 "110"
--            (INT1RE and CS22 and CS21 and CS20);           -- Rising edge	 "111"


EIMSK_Bits:process(cp2,ireset)
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

EIFR_Bits:process(cp2,ireset)
begin
 if (nReset='0') then 
  EIFR <= (others => '0');
 elsif  (clk='1' and clk'event)  then
  if (clken='1') then       -- Clock Enable	
   if (adr=EIFR_Address and iowe='1') then
    EIFR <= dbus_in;	
   end if;
  end if;	 
 end if;	
end process;

EICR_Bits:process(cp2,ireset)
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
				(others => '0');	
end Behavioral;

