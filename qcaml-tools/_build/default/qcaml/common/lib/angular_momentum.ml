

(* An exception is raised when the ~Angular_momentum.t~ element can't
 * be created.
 * 
 * The ~kind~ is used to build shells, shell doublets, triplets or
 * quartets, use in the two-electron operators. *)


(* [[file:~/QCaml/common/angular_momentum.org::*Type][Type:2]] *)
type t =
  | S | P | D | F | G | H | I | J | K | L | M | N | O
  | Int of int

exception Angular_momentum_error of string

type kind =
    Singlet of t
  | Doublet of (t * t)
  | Triplet of (t * t * t)
  | Quartet of (t * t * t * t)

open Powers
(* Type:2 ends here *)



(*    | ~of_char~   | Returns an ~Angular_momentum.t~ when a shell is given as  a character (case insensitive) |
 *    | ~to_char~   | Converts the angular momentum into a char                                                |
 *    | ~of_int~    | Returns a shell given an $l$ value.                                                      |
 *    | ~to_int~    | Returns the $l_{max}$ value of the shell                                                 |
 *    | ~to_string~ | Converts the angular momentum into a string                                              |
 * 
 *    Example:
 *    #+begin_example
 * Angular_momentum.of_char 'p';;
 * - : Angular_momentum.t = P
 * 
 * Angular_momentum.(to_char P);;
 * - : char = 'P'
 * 
 * Angular_momentum.of_int 2;;
 * - : Angular_momentum.t = D
 * 
 * Angular_momentum.(to_int D);;
 * - : int = 2
 * 
 * Angular_momentum.(to_string D);;
 * - : string = "D"
 *    #+end_example *)


(* [[file:~/QCaml/common/angular_momentum.org::*Conversions][Conversions:2]] *)
let of_char = function
  | 's' | 'S' -> S      | 'p' | 'P' -> P
  | 'd' | 'D' -> D      | 'f' | 'F' -> F
  | 'g' | 'G' -> G      | 'h' | 'H' -> H
  | 'i' | 'I' -> I      | 'j' | 'J' -> J
  | 'k' | 'K' -> K      | 'l' | 'L' -> L
  | 'm' | 'M' -> M      | 'n' | 'N' -> N
  | 'o' | 'O' -> O
  | c -> raise (Angular_momentum_error (String.make 1 c))

let to_string = function
  | S -> "S"       | P -> "P"
  | D -> "D"       | F -> "F"
  | G -> "G"       | H -> "H"
  | I -> "I"       | J -> "J"
  | K -> "K"       | L -> "L"
  | M -> "M"       | N -> "N"
  | O -> "O"       | Int i -> string_of_int i


let to_char = function
  | S -> 'S'       | P -> 'P'
  | D -> 'D'       | F -> 'F'
  | G -> 'G'       | H -> 'H'
  | I -> 'I'       | J -> 'J'
  | K -> 'K'       | L -> 'L'
  | M -> 'M'       | N -> 'N'
  | O -> 'O'       | Int _ -> '_'


let to_int = function
  | S -> 0         | P -> 1
  | D -> 2         | F -> 3
  | G -> 4         | H -> 5
  | I -> 6         | J -> 7
  | K -> 8         | L -> 9
  | M -> 10        | N -> 11
  | O -> 12        | Int i -> i


let of_int = function
  | 0 -> S         | 1 -> P
  | 2 -> D         | 3 -> F
  | 4 -> G         | 5 -> H
  | 6 -> I         | 7 -> J
  | 8 -> K         | 9 -> L
  | 10 -> M        | 11 -> N
  | 12 -> O        | i -> Int i
(* Conversions:2 ends here *)



(*    | ~n_functions~ | Returns the number of cartesian functions in a shell.                                       |
 *    | ~zkey_array~  | Array of ~Zkey.t~, where each element is a a key associated with the the powers of $x,y,z$. |
 * 
 *    Example:
 *    #+begin_example
 * Angular_momentum.(n_functions D) ;;
 * - : int = 6
 * 
 * Angular_momentum.( zkey_array (Doublet (P,S)) );;
 * - : Zkey.t array =
 * [|< 01125899906842624 | 1, 0, 0, 0, 0, 0 >;
 *   < 01099511627776 | 0, 1, 0, 0, 0, 0 >;
 *   < 01073741824 | 0, 0, 1, 0, 0, 0 >|]
 *    #+end_example *)


(* [[file:~/QCaml/common/angular_momentum.org::*Shell functions][Shell functions:2]] *)
let n_functions a =
  let a =
    to_int a
  in
  (a*a + 3*a + 2)/2


let zkey_array_memo : (kind, Zkey.t array) Hashtbl.t =
  Hashtbl.create 13

let zkey_array a =

  let keys_1d l =
    let create_z { x ; y ; _ } =
      Powers.of_int_tuple (x,y,l-(x+y))
    in
    let rec create_y accu xyz =
      let { x ; y ; z ;_ } = xyz in
      match y with
      | 0 -> (create_z xyz)::accu
      | _ -> let ynew = y-1 in
          (create_y [@tailcall]) ( (create_z xyz)::accu) (Powers.of_int_tuple (x,ynew,z))
    in
    let rec create_x accu xyz =
      let { x ; z ;_ } = xyz in
      match x with
      | 0 -> (create_y [] xyz)@accu
      | _ -> let xnew = x-1 in
          let ynew = l-xnew in
          (create_x [@tailcall]) ((create_y [] xyz)@accu) (Powers.of_int_tuple (xnew, ynew, z))
    in
    create_x [] (Powers.of_int_tuple (l,0,0))
    |> List.rev
  in

  try
    Hashtbl.find zkey_array_memo a

  with Not_found ->

    let result =
      begin
        match a with
        | Singlet l1 ->
            List.rev_map (fun x -> Zkey.of_powers_three x) (keys_1d @@ to_int l1)

        | Doublet (l1, l2) ->
            List.rev_map (fun a ->
              List.rev_map (fun b -> Zkey.of_powers_six a b) (keys_1d @@ to_int l2)
            ) (keys_1d @@ to_int l1)
            |> List.concat

        | Triplet (l1, l2, l3) ->

            List.rev_map (fun a ->
              List.rev_map (fun b ->
                List.rev_map (fun c ->
                  Zkey.of_powers_nine a b c) (keys_1d @@ to_int l3)
              ) (keys_1d @@ to_int l2)
              |> List.concat
            ) (keys_1d @@ to_int l1)
            |> List.concat

        | Quartet (l1, l2, l3, l4) ->

            List.rev_map (fun a ->
              List.rev_map (fun b ->
                List.rev_map (fun c ->
                  List.rev_map (fun d ->
                    Zkey.of_powers_twelve a b c d) (keys_1d @@ to_int l4)
                ) (keys_1d @@ to_int l3)
                |> List.concat
              ) (keys_1d @@ to_int l2)
              |> List.concat
            ) (keys_1d @@ to_int l1)
            |> List.concat
      end
      |> List.rev
      |> Array.of_list
    in
    Hashtbl.add zkey_array_memo a result;
    result
(* Shell functions:2 ends here *)



(*    Example:
 *    #+begin_example
 * Angular_momentum.(D + P);;
 * - : Angular_momentum.t = F
 * 
 * Angular_momentum.(F - P);;
 * - : Angular_momentum.t = D
 *    #+end_example *)


(* [[file:~/QCaml/common/angular_momentum.org::*Arithmetic][Arithmetic:2]] *)
let ( + ) a b =
  of_int ( (to_int a) + (to_int b) )

let ( - ) a b =
  of_int ( (to_int a) - (to_int b) )
(* Arithmetic:2 ends here *)

(* [[file:~/QCaml/common/angular_momentum.org::*Printers][Printers:2]] *)
let pp_string ppf x =
  Format.fprintf ppf "@[%s@]" (to_string x)

let pp_int ppf x =
  Format.fprintf ppf "@[%d@]" (to_int x)

let pp = pp_string
(* Printers:2 ends here *)
