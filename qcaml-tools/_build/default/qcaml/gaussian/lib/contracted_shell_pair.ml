open Common
    
type t =
{
  coefs_and_shell_pairs     : (float * Primitive_shell_pair.t) list;
  shell_a         : Contracted_shell.t;
  shell_b         : Contracted_shell.t;
}


module Am  = Angular_momentum
module Co  = Coordinate
module Cs  = Contracted_shell
module Ps  = Primitive_shell
module Psp = Primitive_shell_pair

(** Creates an contracted shell pair : a list of pairs of primitive shells.
    A contracted shell with N functions combined with a contracted
    shell with M functions generates a NxM array of shell pairs.
*)
let make ?(cutoff=Constants.epsilon) s_a s_b =

  let make = Psp.create_make_of (Cs.primitives s_a).(0) (Cs.primitives s_b).(0) in

  let coefs_and_shell_pairs = 
    Array.mapi (fun i p_a ->
        let c_a = (Cs.coefficients s_a).(i) in
        let make = make p_a in
        Array.mapi (fun j p_b ->
            let c_b = (Cs.coefficients s_b).(j) in
            let coef = c_a *. c_b in
            assert (coef <> 0.);
            let cutoff = cutoff /. abs_float coef in
            coef, make p_b cutoff) (Cs.primitives s_b)) (Cs.primitives s_a)
    |> Array.to_list
    |> Array.concat
    |> Array.to_list
    |> List.filter (function (_, Some _) -> true | _ -> false)
    |> List.map (function (c, Some x) -> (c *. Psp.normalization x, x) | _ -> assert false)
  in

  match coefs_and_shell_pairs with
  | [] -> None
  | coefs_and_shell_pairs -> Some { shell_a = s_a ; shell_b = s_b ; coefs_and_shell_pairs }



let shell_a x = x.shell_a
let shell_b x = x.shell_b
let coefs_and_shell_pairs x = x.coefs_and_shell_pairs

let shell_pairs x =
  List.map snd x.coefs_and_shell_pairs
  |> Array.of_list

let coefficients x =
  List.map fst x.coefs_and_shell_pairs
  |> Array.of_list

let exponents_inv x =
  List.map (fun (_,sp) -> Psp.exponent_inv sp) x.coefs_and_shell_pairs
  |> Array.of_list

let a_minus_b x =
  match x.coefs_and_shell_pairs with
  | [] -> assert false
  | (_,sp)::_ -> Psp.a_minus_b sp

let a_minus_b_sq x = 
  match x.coefs_and_shell_pairs with
  | [] -> assert false
  | (_,sp)::_ -> Psp.a_minus_b_sq sp

let ang_mom x = 
  match x.coefs_and_shell_pairs with
  | [] -> assert false
  | (_,sp)::_ -> Psp.ang_mom sp

let norm_scales x = 
  match x.coefs_and_shell_pairs with
  | [] -> assert false
  | (_,sp)::_ -> Psp.norm_scales sp

let monocentric x =
  match x.coefs_and_shell_pairs with
  | [] -> assert false
  | (_,sp)::_ -> Psp.monocentric  sp



(** Returns an integer characteristic of a contracted shell pair *)
let hash a = 
  List.rev_map Hashtbl.hash a
  |> Array.of_list

(** Comparison function, used for sorting *)
let compare t t' =
  let a = hash t.coefs_and_shell_pairs in
  let b = hash t'.coefs_and_shell_pairs in
  if a = b then 0
  else if (Array.length a < Array.length b) then -1
  else if (Array.length a > Array.length b) then  1
  else 
    let out = ref 0 in
    begin
     try
        for k=0 to (Array.length a - 1) do
          if a.(k) < b.(k) then
            (out := (-1); raise Not_found)
          else if a.(k) > b.(k) then
            (out :=  1; raise Not_found);
        done
     with Not_found -> ();
    end;
    !out


(** The array of all shell pairs with their correspondance in the list
    of contracted shells.
*)
let of_contracted_shell_array ?(cutoff=Constants.epsilon) basis =
  let rec loop accu = function
  | [] -> accu
  | (s_a :: rest) as l ->
    let new_accu = 
      (List.map (fun s_b -> make ~cutoff s_a s_b) l) :: accu
    in (loop [@tailcall]) new_accu rest
  in
  loop [] (List.rev (Array.to_list basis))
  |> List.concat
  |> Util.list_some


(*

let equivalent x y =
  (Array.length x = Array.length y) &&
  let rec eqv = function
  | 0 -> true
  | k -> if Psp.equivalent x.(k) y.(k) then
            (eqv [@tailcall]) (k-1)
         else false
  in eqv (Array.length x - 1)


(** A list of unique shell pairs *)
let unique sp =
  let sp = 
    Array.to_list sp
    |> Array.concat
    |> Array.to_list
  in
  let rec aux accu = function
  | [] -> accu
  | x::rest -> 
      let newaccu = 
        try
          ignore @@ List.find (fun y -> equivalent x y) accu;
          accu
        with Not_found -> (x::accu)
      in
      (aux [@tailcall]) newaccu rest
  in
  aux [] sp
*)


let zkey_array x =
  Am.zkey_array (Am.Doublet 
    Cs.(ang_mom x.shell_a, ang_mom x.shell_b)
  )


