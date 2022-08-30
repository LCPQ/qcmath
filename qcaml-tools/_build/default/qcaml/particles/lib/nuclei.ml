(* [[file:~/QCaml/particles/nuclei.org::*Type][Type:2]] *)
open Common

type t = (Element.t * Coordinate.t) array
open Xyz_ast
(* Type:2 ends here *)



(* | ~of_xyz_string~ | Create from a string, in xyz format                         |
 * | ~of_xyz_file~   | Create from a file, in xyz format                           |
 * | ~of_zmt_string~ | Create from a string, in z-matrix format                    |
 * | ~of_zmt_file~   | Create from a file, in z-matrix format                      |
 * | ~to_string~     | Transform to a string, for printing                         |
 * | ~of_filename~   | Detects the type of file (xyz, z-matrix) and reads the file | *)


(* [[file:~/QCaml/particles/nuclei.org::*Conversion][Conversion:2]] *)
let of_xyz_lexbuf lexbuf =
  let data = 
    Xyz_parser.input Nuclei_lexer.read_all lexbuf
  in

  let len = List.length data.nuclei in
  if len <> data.number_of_atoms then
    Printf.sprintf "Error: expected %d atoms but %d read" 
      data.number_of_atoms len
    |> failwith;

  List.map (fun nucleus ->
    nucleus.element, Coordinate.angstrom_to_bohr nucleus.coord
  ) data.nuclei
  |> Array.of_list


let of_xyz_string input_string = 
  Lexing.from_string input_string
  |> of_xyz_lexbuf


let of_xyz_file filename =
  let ic = open_in filename in
  let lexbuf =
    Lexing.from_channel ic
  in
  let result = 
    of_xyz_lexbuf lexbuf
  in
  close_in ic;
  result


let of_zmt_string buffer =
  Zmatrix.of_string buffer
  |> Zmatrix.to_xyz
  |> Array.map (fun (e,x,y,z) ->
    (e, Coordinate.(angstrom_to_bohr @@ make_angstrom { x ; y ; z} ))
  )


let of_zmt_file filename =
  let ic = open_in filename in
  let rec aux accu =
    try
      let line = input_line ic in
      aux (line::accu)
    with End_of_file ->
      close_in ic;
      List.rev accu
      |> String.concat "\n"
  in aux []
     |> of_zmt_string


let to_string atoms =
  "
                Nuclear Coordinates (Angstrom)
                ------------------------------

-----------------------------------------------------------------------
   Center   Atomic   Element          Coordinates (Angstroms)
            Number                 X             Y             Z
-----------------------------------------------------------------------
" ^
  (Array.mapi (fun i (e, coord) ->
     let open Coordinate in
     let coord =
       bohr_to_angstrom coord
     in
     Printf.sprintf " %5d    %5d    %5s   %12.6f  %12.6f  %12.6f"
       (i+1)  (Element.to_int e)  (Element.to_string e) 
       coord.x coord.y coord.z
   ) atoms
   |> Array.to_list
   |> String.concat "\n" ) ^
  "
-----------------------------------------------------------------------

"


let of_filename filename =
  of_xyz_file filename


let to_xyz_string t =
  [ string_of_int (Array.length t) ; "" ] @
  ( Array.map (fun (e, coord) ->
      let open Coordinate in
      let coord =
        bohr_to_angstrom coord
      in
      Printf.sprintf " %5s   %12.6f  %12.6f  %12.6f"
        (Element.to_string e) coord.x coord.y coord.z
    ) t 
    |> Array.to_list )
  |> String.concat "\n"
(* Conversion:2 ends here *)



(* | ~formula~    | Returns the chemical formula                     |
 * | ~repulsion~  | Nuclear repulsion energy, in atomic units        |
 * | ~charge~     | Sum of the charges of the nuclei                 |
 * | ~small_core~ | Number of core electrons in the small core model |
 * | ~large_core~ | Number of core electrons in the large core model | *)


(* [[file:~/QCaml/particles/nuclei.org::*Query][Query:2]] *)
let formula t =
  let dict = Hashtbl.create 67 in
  Array.iter (fun (e,_) ->
    let e = Element.to_string e in
    let value =
      try (Hashtbl.find dict e) + 1
      with Not_found -> 1
    in
    Hashtbl.replace dict e value
  ) t;
  Hashtbl.to_seq_keys dict
  |> List.of_seq
  |> List.sort String.compare
  |> List.fold_left (fun accu key ->
    let x = Hashtbl.find dict key in
    accu ^ key ^ "_{" ^ (string_of_int x) ^ "}") ""


  
let repulsion nuclei =
  let get_charge e = 
    Element.to_charge e
    |> Charge.to_float
  in
  Array.fold_left ( fun accu (e1, coord1) -> 
    accu +. 
    Array.fold_left (fun accu (e2, coord2) ->
      let r = Coordinate.(norm (coord1 |- coord2)) in
      if r > 0. then
        accu +. 0.5 *. (get_charge e2) *. (get_charge e1) /. r
      else accu
    ) 0. nuclei
  ) 0.  nuclei


let charge nuclei = 
  Array.fold_left (fun accu (e, _) -> accu + Charge.to_int (Element.to_charge e) )
    0 nuclei 
  |> Charge.of_int


let small_core a = 
  Array.fold_left (fun accu (e,_) -> accu + (Element.small_core e)) 0 a


let large_core a = 
  Array.fold_left (fun accu (e,_) -> accu + (Element.large_core e)) 0 a
(* Query:2 ends here *)

(* [[file:~/QCaml/particles/nuclei.org::*Printers][Printers:2]] *)
let pp ppf t =
  Format.fprintf ppf "@[%s@]" (to_string t)
(* Printers:2 ends here *)
