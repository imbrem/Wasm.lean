import LSpec

import Megaparsec.Parsec
import Wasm.Wast.Parser

open LSpec

open Megaparsec.Parsec
open Wasm.Wast.Parser

open Megaparsec.Errors.Bundle in
inductive ParseFailure (src : String) (e : ParseErrorBundle Char String Unit) : Prop
instance : Testable (ParseFailure src e) := .isFailure s!"Parsing:\n{src}\n{e}"

def testParse (parser: Parsec Char String Unit α)
              (src : String) (y : α) [BEq α] [ToString α] : TestSeq :=
  match parse parser src with
  | .error pe => test "parsing failed" (ParseFailure src pe)
  | .ok x =>
    if x == y
    then test src true
    else test "doesn't match" (ExpectationFailure s!"{y}" s!"{x}")

open Wasm.Wast.AST.Type'.Type'

def testFisF : TestSeq :=
  testParse typeP "f32" (f 32)

open Wasm.Wast.Num.Num.Int

def testMinusOneisI32MinusOne : TestSeq :=
  testParse iP "i32.const -1" ⟨ 32, -1 ⟩

open Wasm.Wast.AST.Operation
open Wasm.Wast.AST.Type'
open Wasm.Wast.Num.Uni

/-

Recap:

  inductive Operation where
  | nop
  | const : Type' → NumUniT → Operation
  | add : Type' → Get' → Get' → Operation
  | block : List Type' → List Operation → Operation
  | loop : List Type' → List Operation → Operation
  | if : List Type' → List Operation → List Operation → Operation
  | br : LabelIndex → Operation
  | br_if : LabelIndex → Operation

-/

instance : BEq Operation where
  beq := (toString · == toString ·)

def testAdd42IsOpAddConstStack : TestSeq :=
  testParse (binopP "add" .add) "i32.add (i32.const 42)" $
    Operation.add (.i 32)
                  (.from_operation (.const (.i 32) (.i ⟨ 32, 42 ⟩ )))
                  (.from_stack)

open Wasm.Wast.AST.Func
open Wasm.Wast.AST.Local

instance : BEq Func where
  beq := (toString · == toString ·)

def testParamIsActuallyLocal : TestSeq :=
  testParse paramP "param $t i32" (Local.mk (.some "t") (Type'.i 32))

def testSomeParamsParse : TestSeq :=
  testParse nilParamsP "(param $t i32) (param $coocoo f32) (param i64)" $
    [Local.mk (.some "t") (Type'.i 32),
      Local.mk (.some "coocoo") (Type'.f 32),
      Local.mk .none (Type'.i 64)]

def testSpacesAreIgnoredWhileParsingParams : TestSeq :=
  testParse nilParamsP "(param i32) (param $coocoo f32)  ( param i64 ) ( something_else )" $
    [Local.mk .none (Type'.i 32),
    Local.mk (.some "coocoo") (Type'.f 32),
    Local.mk .none (Type'.i 64)]

def testResultParses : TestSeq :=
  testParse brResultsP "( result i32)" [Type'.i 32]

def testBlockResultConstEndParses : TestSeq :=
  testParse opP "(block (result i32) (i32.const 1) end)" $
    (.block [(Type'.i 32)] [(.const (Type'.i 32) (.i (ConstInt.mk 32 1)))])

def testIfParses : TestSeq :=
  testParse ifP "if (result i32) (then (i32.const 42)) (else (i32.const 9))" $
    (.if [(Type'.i 32)] (.from_stack) [(.const (Type'.i 32) (.i (ConstInt.mk 32 42)))]
          [(.const (Type'.i 32) (.i (ConstInt.mk 32 9)))])

def testFuncs : TestSeq :=
  let test' := testParse (bracketed funcP)
  group "check that functions parse" $
    test' "(func)" (Func.mk .none .none [] [] [] []) ++
    test' "(func (param $x i32) (param i32) (result i32))"
      (Func.mk .none .none
        [(Local.mk (.some "x") (.i 32)), (Local.mk .none (.i 32))]
        [(.i 32)] [] []
      ) ++
    test' "(func (param $x i32) (param i32) (result i32) (result i64))"
      (Func.mk .none .none
        [(Local.mk (.some "x") (.i 32)), (Local.mk .none (.i 32))]
        [(.i 32), (.i 64)] [] []
      ) ++
    test' "(func (param $x i32) (param $y i32) (result i32))"
      (Func.mk .none .none
        [ (Local.mk (.some "x") (.i 32)), (Local.mk (.some "y") (.i 32))]
        [(.i 32)] [] []
      ) ++
    test' "(func (param $x i32) (param i32) (result i32) (i32.add (i32.const 40) (i32.const 2)))"
    (Func.mk .none .none
      [(Local.mk (.some "x") (.i 32)), (Local.mk .none (.i 32))]
      [(.i 32)] []
      [(.add (.i 32) (.from_operation (.const (.i 32) (.i (ConstInt.mk 32 40))))
        (.from_operation (.const (.i 32) (.i (ConstInt.mk 32 2))))
        )]
    )

def testFlawedFuncDoesntParse : TestSeq :=
  test "NO PARSE: (func func (param $x i32) (param i32) (result i32) (result i64) (result i64))" $
    not (parses? (bracketed funcP) "(func func (param $x i32) (param i32) (result i32) (result i64) (result i64))")

def main : IO UInt32 :=
  lspecIO $
    testFisF ++
    testMinusOneisI32MinusOne ++
    testAdd42IsOpAddConstStack ++
    testParamIsActuallyLocal ++
    testSomeParamsParse ++
    testSpacesAreIgnoredWhileParsingParams ++
    testResultParses ++
    testBlockResultConstEndParses ++
    testIfParses ++
    testFuncs ++
    testFlawedFuncDoesntParse
