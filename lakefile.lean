import Lake
open Lake DSL

package Wasm {
  precompileModules := true
}

@[default_target]
lean_lib Wasm

require LSpec from git
  "https://github.com/lurk-lab/LSpec" @ "7f2c46b"

require YatimaStdLib from git
  "https://github.com/imbrem/YatimaStdLib.lean" @ "main"

require Megaparsec from git
  "https://github.com/imbrem/Megaparsec.lean" @ "main"

@[default_target]
lean_exe wasm where
  root := `Main

lean_exe Tests.Dependent
lean_exe Tests.Leb128
lean_exe Tests.SimpleEncodings
lean_exe Tests.BinaryCompatibility
lean_exe Tests.RuntimeCompatibility
