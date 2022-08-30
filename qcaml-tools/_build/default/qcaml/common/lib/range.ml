(* [[file:~/QCaml/common/range.org::*Type][Type:2]] *)
type t = int list
(* Type:2 ends here *)

(* [[file:~/QCaml/common/range.org::*Conversion][Conversion:2]] *)
let to_int_list r = r

let expand_range r =
  match String.split_on_char '-' r with
  | s :: f :: [] ->
      begin
        let start = int_of_string s
        and finish =  int_of_string f
        in
        assert (start <= finish) ;
        let rec do_work = function
          | i when i=finish -> [ i ]
          | i     -> i::(do_work (i+1))
        in do_work start
      end
  | r :: [] -> [int_of_string r]
  | [] -> []
  | _ -> invalid_arg "Only one range expected"


let of_string s =
  match s.[0] with
  | '0' .. '9' -> [ int_of_string s ]
  | _ ->
      assert (s.[0] = '[') ;
      assert (s.[(String.length s)-1] = ']') ;
      let s = String.sub s 1 ((String.length s) - 2) in
      let l = String.split_on_char ',' s in
      let l = List.map expand_range l in
      List.concat l
      |> List.sort_uniq compare


let to_string l =
  "[" ^
  (List.map string_of_int l
   |> String.concat ",") ^
  "]"
(* Conversion:2 ends here *)

(* [[file:~/QCaml/common/range.org::*Printers][Printers:2]] *)
let pp ppf t =
  Format.fprintf ppf "@[%s@]" (to_string t)
(* Printers:2 ends here *)
