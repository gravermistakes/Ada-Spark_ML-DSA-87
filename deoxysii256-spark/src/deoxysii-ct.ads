------------------------------------------------------------------------------
--  Deoxysii.CT — constant-time comparison and zeroization (DEOXYSIIS.md
--  sec 7, [shared]). Fully specified, unambiguous; written once at G0 rather
--  than duplicated by whichever lane needs it.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

package Deoxysii.CT is

   --  Constant-time tag comparison: accumulates diff over every byte with
   --  no early return and no branch on a byte value (DEOXYSIIS.md sec 7).
   function CT_Equal (A, B : Tag_128) return Boolean
   with
     Global => null;

   --  Unconditional overwrite with 0 (DEOXYSIIS.md sec 7). Used on the
   --  Decrypt fail path so no recovered-plaintext byte is ever exposed.
   procedure Zeroize (Data : in out Byte_Seq)
   with
     Global => null,
     Post   => (for all B of Data => B = 0);

end Deoxysii.CT;
