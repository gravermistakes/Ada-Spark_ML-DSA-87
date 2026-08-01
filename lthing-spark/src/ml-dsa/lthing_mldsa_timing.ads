------------------------------------------------------------------------------
--  LTHING.MLDSA.Timing — Branchless arithmetic for side-channel resistance
--
--  Every function here avoids secret-dependent conditional branches: the
--  control flow is identical regardless of input values.  All mask functions
--  return either 16#FFFF_FFFF# (all-ones) or 0 (all-zeros).
--
--  Whether GNAT emits a branch or a cmov for Boolean'Pos depends on
--  optimisation level; the 0 - V idiom (wrapping unsigned subtraction)
--  produces branchless codegen at every -O level. Verify the assembly
--  after any toolchain upgrade.
--
--  SPARK_Mode (On); proof target is AoRTE + flow + stated contracts.
--
--  GPL-3.0-or-later.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

with Interfaces; use Interfaces;
with LTHING_Types; use LTHING_Types;

package LTHING_MLDSA_Timing is

   ---------------------------------------------------------------------------
   --  Bool_Mask — all-ones if Cond, all-zeros otherwise.
   ---------------------------------------------------------------------------
   function Bool_Mask (Cond : Boolean) return Unsigned_32
     with Global => null,
          Post   => (if Cond then Bool_Mask'Result = 16#FFFF_FFFF#
                     else Bool_Mask'Result = 0);

   ---------------------------------------------------------------------------
   --  Select_U32 — returns A if Choose_B is False, B if True. Branchless.
   ---------------------------------------------------------------------------
   function Select_U32
     (A, B : Unsigned_32; Choose_B : Boolean) return Unsigned_32
     with Global => null,
          Inline,
          Post   => (if Choose_B then Select_U32'Result = B
                     else Select_U32'Result = A);

   ---------------------------------------------------------------------------
   --  Ge_Mask — all-ones mask if A >= B, all-zeros otherwise.
   ---------------------------------------------------------------------------
   function Ge_Mask (A, B : Unsigned_32) return Unsigned_32
     with Global => null,
          Post   => (if A >= B then Ge_Mask'Result = 16#FFFF_FFFF#
                     else Ge_Mask'Result = 0);

   ---------------------------------------------------------------------------
   --  Eq_Mask — all-ones mask if A = B, all-zeros otherwise.
   ---------------------------------------------------------------------------
   function Eq_Mask (A, B : Unsigned_32) return Unsigned_32
     with Global => null,
          Post   => (if A = B then Eq_Mask'Result = 16#FFFF_FFFF#
                     else Eq_Mask'Result = 0);

   ---------------------------------------------------------------------------
   --  Lt_Mask — all-ones mask if A < B, all-zeros otherwise.
   ---------------------------------------------------------------------------
   function Lt_Mask (A, B : Unsigned_32) return Unsigned_32
     with Global => null,
          Post   => (if A < B then Lt_Mask'Result = 16#FFFF_FFFF#
                     else Lt_Mask'Result = 0);

   ---------------------------------------------------------------------------
   --  Secure_Wipe — zero a Byte_Array, defeating dead-store elimination
   --  via pragma Inspection_Point.
   ---------------------------------------------------------------------------
   procedure Secure_Wipe (X : in out Byte_Array)
     with Global => null,
          Post   => (for all I in X'Range => X (I) = 0);

end LTHING_MLDSA_Timing;
