library ieee;
use ieee.std_logic_1164.all;
-- need conversion function to convert reals/integers to std logic vectors
use ieee.std_logic_arith.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


package emc_pkg is


subtype SLV64_TYPE is std_logic_vector(0 to 63);
type    SLV64_ARRAY_TYPE is array (natural range <>) of SLV64_TYPE;
type    INTEGER_ARRAY_TYPE is array (natural range <>) of integer;

function calc_num_ce (ce_num_array : INTEGER_ARRAY_TYPE) return integer;

function get_id_index (id_array :INTEGER_ARRAY_TYPE; 
                       id       : integer)
                       return integer;
end emc_pkg;

package body emc_pkg is
-----------------------------------------------------------------------------
-- Function get_id_index
--
-- This function is used to process the array specifying the target function
-- assigned to a Base Address pair address range. The id_array and a 
-- id number is input to the function. A integer is returned reflecting the
-- array index of the id matching the id input number. This function
-- should only be called if the id number is known to exist in the 
-- name_array input. This can be detirmined by using the  find_ard_id
-- function.
-----------------------------------------------------------------------------
 function get_id_index (id_array :INTEGER_ARRAY_TYPE;      
                        id       : integer) return integer is
 
    Variable match       : Boolean := false;
    Variable match_index : Integer := 10000; -- a really big number!
    
    
 begin
 
    for array_index in 0 to id_array'length-1 loop
        
               
        If (match = true) Then  -- match already found so do nothing
            
            null; 
            
        else  -- compare the numbers one by one
          
           match       := (id_array(array_index) = id);
           
           If (match) Then
              match_index := array_index;
           else
               null;
           End if;
          
        End if;
        
    End loop;
   
    return(match_index);
    
 end function get_id_index;

-----------------------------------------------------------------------------
-- Function calc_num_ce
--
-- This function is used to process the array specifying the number of Chip
-- Enables required for a Base Address specification. The array is input to
-- the function and an integer is returned reflecting the total number of 
-- Chip Enables required for the CE, RdCE, and WrCE Buses
-----------------------------------------------------------------------------
  function calc_num_ce (ce_num_array : INTEGER_ARRAY_TYPE) return integer is

     Variable ce_num_sum : integer := 0;

  begin
    
    for i in 0 to (ce_num_array'length)-1 loop
        ce_num_sum := ce_num_sum + ce_num_array(i);
    End loop;
     
    return(ce_num_sum);
       
  end function calc_num_ce;

end package body emc_pkg;
