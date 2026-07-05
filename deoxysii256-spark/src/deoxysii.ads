------------------------------------------------------------------------------
--  Deoxysii — Deoxys-II-256-128 (CAESAR final portfolio, mode SCT-2)
--
--  Root package: the frozen type contract (DEOXYSIIS.md sec 2) and the
--  public M-6 API. Types and the child-package seam (Deoxysii.TBC, P-9) are
--  frozen at G0 and MUST NOT change thereafter — every other unit in this
--  crate depends on both staying exactly as declared here.
--
--  Reference: Deoxys v1.41 (CAESAR round 3, sites.google.com/view/deoxyscipher)
--  and Jean, Nikolic, Peyrin, Seurin, "The Deoxys AEAD Family",
--  J. Cryptology 2021.
--
--  GPL-3.0-or-later (research/hardening lineage; relicense before any
--  commercial distribution -- GPL is incompatible with closed sale).
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

package Deoxysii is

   --  ---- Frozen type contract (DEOXYSIIS.md sec 2) ----

   type Byte is mod 2 ** 8 with Size => 8;

   type Block_128 is array (0 .. 15) of Byte;   --  column-major state (P-1)
   type Key_256   is array (0 .. 31) of Byte;
   type Nonce_120 is array (0 .. 14) of Byte;
   type Tag_128   is array (0 .. 15) of Byte;
   type Byte_Seq  is array (Natural range <>) of Byte;

   subtype State is Block_128;

   type Subtweakeys is array (0 .. 16) of Block_128;   --  STK[0..16] (P-2)

   --  ---- Sizes ----
   KeySize   : constant := 32;
   NonceSize : constant := 15;
   TagSize   : constant := 16;

   --  maxl = 2**60 message blocks per DEOXY_1_41 sec 0. Byte_Seq is bounded
   --  by Natural'Last in this crate (host-memory bound), far below maxl*16;
   --  the maxl ceiling is documented, not separately enforced by a
   --  precondition, since no achievable Ada array approaches it.

   --  ---- M-6: public AEAD API ----
   --
   --  Encrypt: Deoxys-II-256-128 SCT-2 seal. CT and Tag are the ciphertext
   --  and authentication tag; CT'Length = Msg'Length (Deoxys-II adds no
   --  length expansion to the ciphertext -- the tag is returned separately).
   procedure Encrypt
     (Key   : Key_256;
      Nonce : Nonce_120;
      AD    : Byte_Seq;
      Msg   : Byte_Seq;
      CT    : out Byte_Seq;
      Tag   : out Tag_128)
   with
     Pre => CT'Length = Msg'Length;

   --  Decrypt: verify Tag over AD/CT, then recover Msg. Fail-closed: if
   --  authentication fails, Ok is False and Msg is fully zeroized -- no
   --  recovered-plaintext byte is ever exposed on the fail path.
   procedure Decrypt
     (Key   : Key_256;
      Nonce : Nonce_120;
      AD    : Byte_Seq;
      CT    : Byte_Seq;
      Tag   : Tag_128;
      Msg   : out Byte_Seq;
      Ok    : out Boolean)
   with
     Pre  => Msg'Length = CT'Length,
     Post => (if not Ok then (for all B of Msg => B = 0));

end Deoxysii;
