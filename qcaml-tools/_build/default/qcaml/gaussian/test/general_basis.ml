open Common
open Particles
open Gaussian
open Alcotest

let wd = Common.Qcaml.root ^ Filename.dir_sep ^ "test"

let test_read () =
  let oxygen = Element.of_string "O" in
  let basis = General_basis.read (wd ^ Filename.dir_sep ^ "cc-pvdz") in
  let contractions = List.assoc oxygen basis in
  let n_prim = [| ('S',8) ; ('S',8) ; ('S',1) ; ('P',3) ; ('P',1) ; ('D',1) |] in
  check int "number of contractions" (Array.length n_prim) (Array.length contractions);
  Array.iteri (fun i (l,n) -> 
    let l', primitives = contractions.(i) in
    check char "Angular momentum" l (Angular_momentum.to_char l');
    check int "Number of primitives" n (Array.length primitives)) n_prim;
  ()

let test_read_many () =
  let helium = Element.of_string "He" in
  let basis = General_basis.read (wd ^ Filename.dir_sep ^ "cc-pvdz") in
  let basis_f12 = General_basis.read_many (List.map (fun x -> wd ^ Filename.dir_sep ^x)
                                          ["cc-pvdz"; "cc-pvdz-f12-ri"]) in
  let contractions = List.assoc helium basis in
  let contractions_f12 = List.assoc helium basis_f12 in
  let n_prim = [| ('S',3) ; ('S',1) ; ('P',1) |] in
  let n_prim_f12 =
    [| ('S',3) ; ('S',1) ; ('P',1) ; ('S',1) ; ('S',1) ; ('S',1) ; ('P',1) ; ('P',1) |]
  in
  check int "number of contractions" (Array.length n_prim) (Array.length contractions);
  check int "number of f12 contractions" (Array.length n_prim_f12) (Array.length contractions_f12);
  Printf.printf "%s\n\n" (General_basis.to_string ("He", contractions));
  Printf.printf "%s\n" (General_basis.to_string ("He", contractions_f12));
  Array.iteri (fun i (l,n) -> 
    let l', primitives = contractions.(i) in
    let _ , primitives_f12 = contractions_f12.(i) in
    check char "Angular momentum" l (Angular_momentum.to_char l');
    check int "Number of primitives" n (Array.length primitives);
    check bool "Same primitives as f12" true (primitives = primitives_f12)
  ) n_prim;
  Array.iteri (fun i (l,n) -> 
    let l', primitives = contractions_f12.(i) in
    check char "Angular momentum f12" l (Angular_momentum.to_char l');
    check int "Number of primitives f12" n (Array.length primitives)
  ) n_prim_f12;
  ()

let tests = [
  "read", `Quick, test_read;
  "read_many", `Quick, test_read_many;
]
