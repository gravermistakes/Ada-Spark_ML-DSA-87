------------------------------------------------------------------------------
--  LTHING.MLDSA.Timing (body) — branchless constant-time helpers
--  GPL-3.0-or-later.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

package body LTHING_MLDSA_Timing is

   ---------------------------------------------------------------------------
   --  Bool_Mask
   ---------------------------------------------------------------------------
   function Bool_Mask (Cond : Boolean) return Unsigned_32 is
      V : constant Unsigned_32 := Boolean'Pos (Cond);
   begin
      return 0 - V;
   end Bool_Mask;

   ---------------------------------------------------------------------------
   --  Select_U32
   ---------------------------------------------------------------------------
   function Select_U32
     (A, B : Unsigned_32; Choose_B : Boolean) return Unsigned_32
   is
      Mask : constant Unsigned_32 := Bool_Mask (Choose_B);
   begin
      return (A and not Mask) or (B and Mask);
   end Select_U32;

   ---------------------------------------------------------------------------
   --  Ge_Mask
   ---------------------------------------------------------------------------
   function Ge_Mask (A, B : Unsigned_32) return Unsigned_32 is
   begin
      return Bool_Mask (A >= B);
   end Ge_Mask;

   ---------------------------------------------------------------------------
   --  Eq_Mask
   ---------------------------------------------------------------------------
   function Eq_Mask (A, B : Unsigned_32) return Unsigned_32 is
   begin
      return Bool_Mask (A = B);
   end Eq_Mask;

   ---------------------------------------------------------------------------
   --  Lt_Mask
   ---------------------------------------------------------------------------
   function Lt_Mask (A, B : Unsigned_32) return Unsigned_32 is
   begin
      return Bool_Mask (A < B);
   end Lt_Mask;

   ---------------------------------------------------------------------------
   --  Secure_Wipe
   ---------------------------------------------------------------------------
   procedure Secure_Wipe (X : in out Byte_Array) is
   begin
      for I in X'Range loop
         X (I) := 0;
         pragma Loop_Invariant (for all K in X'First .. I => X (K) = 0);
      end loop;
      pragma Inspection_Point (X);
   end Secure_Wipe;

end LTHING_MLDSA_Timing;
