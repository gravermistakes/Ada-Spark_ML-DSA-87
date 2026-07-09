------------------------------------------------------------------------------
--  Deoxysii.CT — shared constant-time helpers (DEOXYSIIS.md sec 7).
--
--  CT_Equal: no early return, no branch on a byte value.
--  Zeroize:  unconditional overwrite with zero (fail-closed support).
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

package Deoxysii.CT is

   function CT_Equal (A, B : Tag_128) return Boolean
     with Global => null,
          Post   => (CT_Equal'Result = (for all I in Tag_128'Range => A (I) = B (I)));

   procedure Zeroize (Buf : out Byte_Seq)
     with Post => (for all B of Buf => B = 0);

end Deoxysii.CT;
