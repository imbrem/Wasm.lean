import Wasm.Wast.AST
import Wasm.Wast.Code
import YatimaStdLib
import Wasm.Leb128

open Wasm.Leb128
open Wasm.Wast.Code
open Wasm.Wast.AST.Global
open Wasm.Wast.AST.Module
open Wasm.Wast.AST.Type'
open Wasm.Wast.AST.Local
open Wasm.Wast.AST.Operation
open Wasm.Wast.AST.Func

open ByteArray
open Nat

namespace Wasm.Bytes

def magic : ByteArray := ByteArray.mk #[0, 0x61, 0x73, 0x6d]

def version : ByteArray := ByteArray.mk #[1, 0, 0, 0]

def b (x : UInt8) : ByteArray :=
  ByteArray.mk #[x]

def b0 := ByteArray.mk #[]

def flatten (xs : List ByteArray) : ByteArray :=
  xs.foldl Append.append b0

def ttoi (x : Type') : UInt8 :=
  match x with
  | .i 32 => 0x7f
  | .i 64 => 0x7e
  | .f 32 => 0x7d
  | .f 64 => 0x7c

def lindex (bss : ByteArray) : ByteArray :=
  uLeb128 bss.data.size ++ bss

def mkVec (xs : List α) (xtobs : α → ByteArray) : ByteArray :=
  let bs := flatten $ xs.map xtobs
  uLeb128 xs.length ++ bs

def mkStr (x : String) : ByteArray :=
  uLeb128 x.length ++ x.toUTF8

def indexLocals (f : Func) : List (Nat × Local) :=
  let idxParams := f.params.enum
  let idxLocals := f.locals.enumFrom f.params.length
  idxParams ++ idxLocals

def indexNamedLocals (f : Func) : List (Nat × Local) :=
  let onlyNamed := List.filter (·.2.name.isSome)
  onlyNamed $ indexLocals f

def indexFuncs (fs : List Func) : List (Nat × Func) := fs.enum

def indexFuncsWithNamedLocals (fs : List Func)
  : List (Nat × List (Nat × Local)) :=
  (fs.map indexNamedLocals).enum.filter (!·.2.isEmpty)

def indexNamedGlobals (gs : List Global) : List (Nat × Global) :=
  let onlyNamed := List.filter (·.2.name.isSome)
  onlyNamed gs.enum

-- TODO: maybe calculate the opcodes instead of having lots of lookup subtables?
-- def extractIBinOp (α : Type') (offset : UInt8)
def extractEqz (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x45
  | .i 64 => 0x50
  | _ => unreachable!

def extractEq (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x46
  | .i 64 => 0x51
  | .f 32 => 0x5b
  | .f 64 => 0x61

def extractNe (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x47
  | .i 64 => 0x52
  | .f 32 => 0x5c
  | .f 64 => 0x62

def extractLt (α : Type') : ByteArray :=
  b $ match α with
  | .f 32 => 0x5d
  | .f 64 => 0x63
  | _ => unreachable!

def extractGt (α : Type') : ByteArray :=
  b $ match α with
  | .f 32 => 0x5e
  | .f 64 => 0x64
  | _ => unreachable!

def extractLe (α : Type') : ByteArray :=
  b $ match α with
  | .f 32 => 0x5f
  | .f 64 => 0x65
  | _ => unreachable!

def extractGe (α : Type') : ByteArray :=
  b $ match α with
  | .f 32 => 0x60
  | .f 64 => 0x66
  | _ => unreachable!

def extractLts (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x48
  | .i 64 => 0x53
  | _ => unreachable!

def extractLtu (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x49
  | .i 64 => 0x54
  | _ => unreachable!

def extractGts (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x4a
  | .i 64 => 0x55
  | _ => unreachable!

def extractGtu (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x4b
  | .i 64 => 0x56
  | _ => unreachable!

def extractLes (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x4c
  | .i 64 => 0x57
  | _ => unreachable!

def extractLeu (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x4d
  | .i 64 => 0x58
  | _ => unreachable!

def extractGes (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x4e
  | .i 64 => 0x59
  | _ => unreachable!

def extractGeu (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x4f
  | .i 64 => 0x5a
  | _ => unreachable!

def extractClz (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x67
  | .i 64 => 0x79
  | _ => unreachable!

def extractCtz (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x68
  | .i 64 => 0x7a
  | _ => unreachable!

def extractPopcnt (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x69
  | .i 64 => 0x7b
  | _ => unreachable!

def extractAdd (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x6a
  | .i 64 => 0x7c
  | .f 32 => 0x92
  | .f 64 => 0xa0

def extractSub (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x6b
  | .i 64 => 0x7d
  | .f 32 => 0x93
  | .f 64 => 0xa1

def extractMul (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x6c
  | .i 64 => 0x7e
  | .f 32 => 0x94
  | .f 64 => 0xa2

def extractDiv (α : Type') : ByteArray :=
  b $ match α with
  | .f 32 => 0x95
  | .f 64 => 0xa3
  | _ => unreachable!

def extractMin (α : Type') : ByteArray :=
  b $ match α with
  | .f 32 => 0x96
  | .f 64 => 0xa4
  | _ => unreachable!

def extractMax (α : Type') : ByteArray :=
  b $ match α with
  | .f 32 => 0x97
  | .f 64 => 0xa5
  | _ => unreachable!

def extractCopysign (α : Type') : ByteArray :=
  b $ match α with
  | .f 32 => 0x98
  | .f 64 => 0xa6
  | _ => unreachable!

def extractDivS (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x6d
  | .i 64 => 0x7f
  | _ => unreachable!

def extractDivU (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x6e
  | .i 64 => 0x80
  | _ => unreachable!

def extractRemS (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x6f
  | .i 64 => 0x81
  | _ => unreachable!

def extractRemU (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x70
  | .i 64 => 0x82
  | _ => unreachable!

def extractAnd (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x71
  | .i 64 => 0x83
  | _ => unreachable!

def extractOr (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x72
  | .i 64 => 0x84
  | _ => unreachable!

def extractXor (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x73
  | .i 64 => 0x85
  | _ => unreachable!

def extractShl (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x74
  | .i 64 => 0x86
  | _ => unreachable!

def extractShrS (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x75
  | .i 64 => 0x87
  | _ => unreachable!

def extractShrU (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x76
  | .i 64 => 0x88
  | _ => unreachable!

def extractRotl (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x77
  | .i 64 => 0x89
  | _ => unreachable!

def extractRotr (α : Type') : ByteArray :=
  b $ match α with
  | .i 32 => 0x78
  | .i 64 => 0x8a
  | _ => unreachable!

def extractLocalLabel (ls : List (Nat × Local)) : LocalLabel → ByteArray
  | .by_index idx => sLeb128 idx
  | .by_name name => match ls.find? (·.2.name = .some name) with
    | .some (idx,_) => sLeb128 idx
    | .none => sorry

def extractGlobalLabel (gs : List (Nat × Global)) : GlobalLabel → ByteArray
  | .by_index idx => sLeb128 idx
  | .by_name name => match gs.find? (·.2.name = .some name) with
    | .some (idx,_) => sLeb128 idx
    | .none => sorry

mutual
  -- https://coolbutuseless.github.io/2022/07/29/toy-wasm-interpreter-in-base-r/
  partial def extractGet' (gs : List (Nat × Global))
                          (ls : List (Nat × Local))
                          (x : Get') : ByteArray :=
    match x with
    | .from_stack => b0
    | .from_operation o => extractOp gs ls o

  partial def extractOp (gs : List (Nat × Global))
                        (ls : List (Nat × Local))
                        : Operation → ByteArray
    | .nop => b 0x01
    | .drop => b 0x1a
    -- TODO: signed consts exist??? We should check the spec carefully.
    | .const (.i 32) (.i ci) => b 0x41 ++ sLeb128 ci.val
    | .const (.i 64) (.i ci) => b 0x42 ++ sLeb128 ci.val
    | .const _ _ => sorry -- TODO: float binary encoding
    | .eqz    t g => extractGet' gs ls g ++ extractEqz t
    | .eq t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractEq t
    | .ne t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractNe t
    | .lt_u t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractLtu t
    | .lt_s t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractLts t
    | .gt_u t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractGtu t
    | .gt_s t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractGts t
    | .le_u t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractLeu t
    | .le_s t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractLes t
    | .ge_u t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractGeu t
    | .ge_s t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractGes t
    | .lt t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractLt t
    | .gt t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractGt t
    | .le t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractLe t
    | .ge t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractGe t
    | .clz    t g => extractGet' gs ls g ++ extractClz t
    | .ctz    t g => extractGet' gs ls g ++ extractCtz t
    | .popcnt t g => extractGet' gs ls g ++ extractPopcnt t
    | .add t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractAdd t
    | .sub t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractSub t
    | .mul t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractMul t
    | .div t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractDiv t
    | .min t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractMin t
    | .max t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractMax t
    | .div_s t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractDivS t
    | .div_u t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractDivU t
    | .rem_s t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractRemS t
    | .rem_u t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractRemU t
    | .and t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractAnd t
    | .or  t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractOr  t
    | .xor t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractXor t
    | .shl t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractShl t
    | .shr_u t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractShrU t
    | .shr_s t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractShrS t
    | .rotl t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractRotl t
    | .rotr t g1 g2 => extractGet' gs ls g1 ++ extractGet' gs ls g2 ++ extractRotr t
    | .local_get ll => b 0x20 ++ extractLocalLabel ls ll
    | .local_set ll => b 0x21 ++ extractLocalLabel ls ll
    | .local_tee ll => b 0x22 ++ extractLocalLabel ls ll
    | .global_get gl => b 0x23 ++ extractGlobalLabel gs gl
    | .global_set gl => b 0x24 ++ extractGlobalLabel gs gl
    | .block ts ops =>
      let bts := flatten $ ts.map (b ∘ ttoi)
      let obs := bts ++ mkVec ops (extractOp gs ls)
      b 0x02 ++ bts ++ lindex obs ++ b 0x0b
    | .loop ts ops =>
      let bts := flatten $ ts.map (b ∘ ttoi)
      let obs := bts ++ mkVec ops (extractOp gs ls)
      b 0x03 ++ bts ++ lindex obs ++ b 0x0b
    | .if ts thens elses =>
      let bts := flatten $ ts.map (b ∘ ttoi)
      let bth := mkVec thens (extractOp gs ls)
      let belse := if elses.isEmpty then b0 else
        let bel := mkVec elses (extractOp gs ls)
        b 0x05 ++ lindex bel
      b 0x04 ++ bts ++ lindex (bth ++ belse) ++ b 0x0b
    | .br li => b 0x0c ++ sLeb128 li
    | .br_if li => b 0x0d ++ sLeb128 li


end

def extractOps (globals : List (Nat × Global)) (locals : List (Nat × Local)) (ops : List Operation)
  : ByteArray :=
  flatten $ ops.map (extractOp globals locals)

def extractFuncTypes (f : Func) : ByteArray :=
  let header := b 0x60
  let params := mkVec f.params (b ∘ ttoi ∘ fun l => l.type)
  let result := mkVec f.results (b ∘ ttoi)
  header ++ params ++ result

def extractTypes (m : Module) : ByteArray :=
  let header := b 0x01
  let funcs := mkVec m.func extractFuncTypes
  header ++ lindex funcs

/- Function section -/
def extractFuncIds (m : Module) : ByteArray :=
  let funs :=
    uLeb128 m.func.length ++
    m.func.foldl (fun acc _x => acc ++ b acc.data.size.toUInt8) b0
  b 0x03 ++ lindex funs

def extractFuncBody (globals : List (Nat × Global)) (f : Func) : ByteArray :=
  -- Locals are encoded with counts of subgroups of the same type.
  let localGroups := f.locals.groupBy (fun l1 l2 => l1.type = l2.type)
  let extractCount
    | ls@(l::_) => uLeb128 ls.length ++ b (ttoi l.type)
    | [] => b0
  let locals := mkVec localGroups extractCount

  let obs := extractOps globals (indexNamedLocals f) f.ops

  -- for each function's code section, we'll add its size after we do
  -- all the other computations.
  lindex $ locals ++ obs ++ b 0x0b

def extractFuncBodies (m : Module) : ByteArray :=
  let header := b 0x0a
  let extractFBwGlobals := extractFuncBody $ indexNamedGlobals m.globals
  header ++ lindex (mkVec m.func extractFBwGlobals)

-- TODO
def extractModName (_ : Module) : ByteArray := b0
-- TODO
def extractFuncNames (_ : List Func) : ByteArray := b0

/-
                       ___________________________________________________
                      /                                                   \
                     |                                                    |
                     |            (_) __ _  ___| | ____ _| |              |
                     |            | |/ _` |/ __| |/ / _` | |              |
                     |            | | (_| | (__|   < (_| | |              |
                     |           _/ |\__,_|\___|_|\_\__,_|_|              |
                     |          |__/                                      |
                     |                                                    |
                     |                         _   _  __ _          _     |
                     |            ___ ___ _ __| |_(_)/ _(_) ___  __| |    |
                     |           / __/ _ \ '__| __| | |_| |/ _ \/ _` |    |
                     |          | (_|  __/ |  | |_| |  _| |  __/ (_| |    |
                     |           \___\___|_|   \__|_|_| |_|\___|\__,_|    |
                     |                                                    |
        _            ,_     ______________________________________________.
       / \      _-'    |   /
     _/|  \-''- _ /    |  /
__-' { |          \    | /
    /             \    |/
    /       "o.  |o }
    |            \ ;                 TODO: generalise
                  ',                    wasm maps
       \_         __\               and indirect maps
         ''-_    \.//
           / '-____'
          /
        _'
      _-

-/

def extractGlobalType : GlobalType → ByteArray
  | ⟨mut?, t⟩ => b (ttoi t) ++ b (if mut? then 0x01 else 0x00)

def extractGlobal (g : Global) : ByteArray :=
  let egt := extractGlobalType g.type
  let einit := match g.init with -- some copy paste to avoid passing locals
  | .const (.i 32) (.i ci) => b 0x41 ++ sLeb128 ci.val
  | .const (.i 64) (.i ci) => b 0x42 ++ sLeb128 ci.val
  | _ => unreachable! -- TODO: upon supporting imports, add that global.get case
  egt ++ einit ++ b 0x0b

def extractGlobals (gs : List Global) : ByteArray :=
  b 0x06 ++ mkVec gs extractGlobal

def encodeLocal (l : Nat × Local) : ByteArray :=
  match l.2.name with
  | .some n => uLeb128 l.1 ++ mkStr n
  | .none   => uLeb128 l.1 -- TODO: check logic

def encodeFunc (f : (Nat × List (Nat × Local))) : ByteArray :=
  uLeb128 f.1 ++ mkVec f.2 encodeLocal

def extractLocalNames (fs : List Func) : ByteArray :=
  let subsection_header := b 0x02
  let ifs := indexFuncsWithNamedLocals fs
  if !ifs.isEmpty then
    subsection_header ++ lindex (mkVec ifs encodeFunc)
  else
    b0

def extractNames (m : Module) : ByteArray :=
  let header := b 0x00
  let name := "name".toUTF8
  let modName := extractModName m
  let funcNames := extractFuncNames m.func
  let locNames := extractLocalNames m.func
  if (modName.size > 0 || funcNames.size > 0 || locNames.size > 0) then
    header ++ (lindex $ (lindex name) ++ modName ++ funcNames ++ locNames)
  else
    b0

def extractExports (m : Module) : ByteArray :=
  let exports := indexFuncs $ m.func.filter (·.export_.isSome)
  if !exports.isEmpty then
    let header := b 0x07
    let extractExport | (idx, f) => match f.export_ with
      | .some x => mkStr x ++ b 0x00 ++ uLeb128 idx
      | .none => b0
    header ++ lindex (mkVec exports extractExport)
  else
    b0

def mtob (m : Module) : ByteArray :=
  magic ++
  version ++
  (extractTypes m) ++
  (extractFuncIds m) ++
  (extractGlobals m.globals) ++
  (extractExports m) ++
  (extractFuncBodies m) ++
  (extractNames m)
