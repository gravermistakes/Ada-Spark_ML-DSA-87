------------------------------------------------------------------------------
--  Deoxysii.CT — body. The accumulate-then-compare shape is load-bearing:
--  every byte is always visited, the comparison happens once at the end.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

package body Deoxysii.CT is

   function CT_Equal (A, B : Tag_128) return Boolean is
      Diff : Byte := 0;
   begin
      for I in Tag_128'Range loop
         Diff := Diff or (A (I) xor B (I));
         pragma Loop_Invariant
           ((Diff = 0) = (for all J in 0 .. I => A (J) = B (J)));
      end loop;
      return Diff = 0;
   end CT_Equal;

   procedure Zeroize (Buf : out Byte_Seq) is
   begin
      Buf := (others => 0);
      --  Inspection point so the overwrite is observable and resists dead-
      --  code elimination (DEOXYSIIS.md sec 7).
      pragma Inspection_Point (Buf);
   end Zeroize;

end Deoxysii.CT;
