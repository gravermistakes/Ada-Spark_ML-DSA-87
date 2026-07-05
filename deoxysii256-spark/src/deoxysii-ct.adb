------------------------------------------------------------------------------
--  Deoxysii.CT (body)
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

package body Deoxysii.CT is

   function CT_Equal (A, B : Tag_128) return Boolean is
      Diff : Byte := 0;
   begin
      for I in A'Range loop
         Diff := Diff or (A (I) xor B (I));
         pragma Loop_Invariant (True);
      end loop;
      return Diff = 0;
   end CT_Equal;

   procedure Zeroize (Data : in out Byte_Seq) is
   begin
      Data := (others => 0);
      --  Data is an out/in-out parameter write, not a dead local store, so
      --  GNAT will not eliminate it under standard optimization levels; the
      --  Inspection_Point is kept anyway per DEOXYSIIS.md sec 7's explicit
      --  hardening suggestion, documented rather than silently dropped.
      pragma Inspection_Point (Data);
   end Zeroize;

end Deoxysii.CT;
