(* [[file:~/QCaml/common/util.org::*Erf][Erf:3]] *)
external erf_float : float -> float
  = "erf_float_bytecode" "erf_float" [@@unboxed] [@@noalloc]
(* Erf:3 ends here *)

(* [[file:~/QCaml/common/util.org::*Erfc][Erfc:3]] *)
external erfc_float : float -> float = "erfc_float_bytecode" "erfc_float" [@@unboxed] [@@noalloc]
(* Erfc:3 ends here *)

(* [[file:~/QCaml/common/util.org::*Gamma][Gamma:3]] *)
external gamma_float : float -> float
  = "gamma_float_bytecode" "gamma_float" [@@unboxed] [@@noalloc]
(* Gamma:3 ends here *)

(* [[file:~/QCaml/common/util.org::*Popcnt][Popcnt:3]] *)
external popcnt : int64 -> int32 = "popcnt_bytecode" "popcnt"
[@@unboxed] [@@noalloc]

let popcnt i = (popcnt [@inlined] ) i |> Int32.to_int
(* Popcnt:3 ends here *)

(* [[file:~/QCaml/common/util.org::*Trailz][Trailz:3]] *)
external trailz : int64 -> int32 = "trailz_bytecode" "trailz" "int"
[@@unboxed] [@@noalloc]

let trailz i = trailz i |> Int32.to_int
(* Trailz:3 ends here *)

(* [[file:~/QCaml/common/util.org::*Leadz][Leadz:3]] *)
external leadz : int64 -> int32 = "leadz_bytecode" "leadz" "int"
[@@unboxed] [@@noalloc]

let leadz i = leadz i |> Int32.to_int
(* Leadz:3 ends here *)



(* | ~fact~              | Factorial function.                                                                                                       |
 * | ~binom~             | Binomial coefficient. ~binom n k~ = $C_n^k$                                                                               |
 * | ~binom_float~       | float variant of ~binom~                                                                                                  |
 * | ~pow~               | Fast implementation of the power function for small integer powers                                                        |
 * | ~chop~              | In ~chop a f~, evaluate ~f~ only if the absolute value of ~a~ is larger than ~Constants.epsilon~, and return ~a *. f ()~. |
 * | ~float_of_int_fast~ | Faster implementation of float_of_int for small positive ints                                                             |
 * | ~not_implemented~   | Fails if some functionality is not implemented                                                      |
 * | ~of_some~           | Extracts the value of an option                                                                                           | *)


(* [[file:~/QCaml/common/util.org::*General%20functions][General functions:2]] *)
let memo_float_of_int =
  Array.init 64 float_of_int

let float_of_int_fast i =
  if Int.logand i 63 = i then
    memo_float_of_int.(i)
  else
    float_of_int i


let factmax = 150

let fact_memo =
  let rec aux accu_l accu = function
    | 0 ->  (aux [@tailcall]) [1.] 1. 1
    | i when (i = factmax) ->
        let x = (float_of_int factmax) *. accu in
        List.rev (x::accu_l)
    | i ->  let x = (float_of_int i) *. accu in
        (aux [@tailcall]) (x::accu_l) x (i+1)
  in
  aux [] 0. 0
  |> Array.of_list

let fact = function
  | i when (i < 0) ->
      raise (Invalid_argument "Argument of factorial should be non-negative")
  | i when (i > 150) ->
      raise (Invalid_argument "Result of factorial is infinite")
  | i -> fact_memo.(i)


let binom =
  let memo = 
    let m = Array.make_matrix 64 64 0 in
    for n=0 to Array.length m - 1 do
      m.(n).(0) <- 1;
      m.(n).(n) <- 1;
      for k=1 to (n - 1) do
        m.(n).(k) <- m.(n-1).(k-1) + m.(n-1).(k)
      done
    done;
    m
  in
  let rec f n k =
    assert (k >= 0);
    assert (n >= k);
    if k = 0 || k = n then
      1
    else if n < 64 then 
      memo.(n).(k)
    else
      f (n-1) (k-1) + f (n-1) k
  in f


let binom_float n k =
  binom n k
  |> float_of_int_fast


let rec pow a = function
  | 0 -> 1.
  | 1 -> a
  | 2 -> a *. a
  | 3 -> a *. a *. a
  | -1 -> 1. /. a
  | n when  n > 0  ->
      let b = pow a (n / 2) in
      b *. b *. (if n mod 2 = 0 then 1. else a)
  | n when  n < 0  -> (pow [@tailcall]) (1./.a) (-n)
  | _ -> assert false


let chop f g =
  if (abs_float f) < Constants.epsilon then 0.
  else f *. (g ())


exception Not_implemented of string
let not_implemented string = 
  raise (Not_implemented string)


let of_some = function
  | Some a -> a
  | None   -> assert false
(* General functions:2 ends here *)



(* The lower [[https://en.wikipedia.org/wiki/Incomplete_gamma_function][Incomplete Gamma function]] is implemented :
 * \[
 * \gamma(\alpha,x)  =  \int_0^x e^{-t}  t^{\alpha-1} dt
 * \]
 * 
 * p: $\frac{1}{\Gamma(\alpha)} \int_0^x e^{-t} t^{\alpha-1} dt$
 * 
 * q: $\frac{1}{\Gamma(\alpha)} \int_x^\infty e^{-t} t^{\alpha-1} dt$
 * 
 * Reference : Haruhiko Okumura: C-gengo niyoru saishin algorithm jiten
 * (New Algorithm handbook in C language) (Gijyutsu hyouron sha,
 * Tokyo, 1991) p.227 [in Japanese]  *)



(* [[file:~/QCaml/common/util.org::*Functions%20related%20to%20the%20Boys%20function][Functions related to the Boys function:2]] *)
let incomplete_gamma ~alpha x = 
  assert (alpha >= 0.);
  assert (x >= 0.);
  let a = alpha in
  let a_inv = 1./. a in
  let gf = gamma_float alpha in
  let loggamma_a = log gf in
  let rec p_gamma x =
    if x >= 1. +. a then 1. -. q_gamma x 
    else if x = 0. then 0.
    else
      let rec pg_loop prev res term k =
        if k > 1000. then failwith "p_gamma did not converge."
        else if prev = res then res
        else
          let term = term *. x /. (a +. k) in
          (pg_loop [@tailcall]) res (res +. term) term (k +. 1.)
      in
      let r0 =  exp (a *. log x -. x -. loggamma_a) *. a_inv in
      pg_loop min_float r0 r0 1.

  and q_gamma x =
    if x < 1. +. a then 1. -. p_gamma x 
    else
      let rec qg_loop prev res la lb w k =
        if k > 1000. then failwith "q_gamma did not converge."
        else if prev = res then res
        else
          let k_inv = 1. /. k in
          let kma = (k -. 1. -. a) *. k_inv in
          let la, lb =
            lb, kma *. (lb -. la) +. (k +. x) *. lb *. k_inv
          in
          let w = w *. kma  in
          let prev, res = res, res +. w /. (la *. lb) in
          (qg_loop [@tailcall]) prev res la lb w (k +. 1.)
      in
      let w = exp (a *. log x -. x -. loggamma_a) in
      let lb = (1. +. x -. a) in
      qg_loop min_float (w /. lb) 1. lb w 2.0
  in
  gf *. p_gamma x
(* Functions related to the Boys function:2 ends here *)



(* The [[https://link.springer.com/article/10.1007/s10910-005-9023-3][Generalized Boys function]] is implemented, 
 * ~maxm~ is the maximum total angular momentum.
 * 
 * \[
 * F_m(x) = \frac{\gamma(m+1/2,x)}{2x^{m+1/2}}
 * \]
 * where $\gamma$ is the incomplete gamma function.
 * 
 * - $F_0(0.) = 1$ 
 * - $F_0(t) = \frac{\sqrt{\pi}}{2\sqrt{t}} \text{erf} ( \sqrt{t} )$ 
 * - $F_m(0.) = \frac{1}{2m+1}$ 
 * - $F_m(t)  = \frac{\gamma{m+1/2,t}}{2t^{m+1/2}}$
 * - $F_m(t)  = \frac{ 2t\, F_{m+1}(t) + e^{-t} }{2m+1}$  *)


(* [[file:~/QCaml/common/util.org::*Functions%20related%20to%20the%20Boys%20function][Functions related to the Boys function:4]] *)
let boys_function ~maxm t =
  assert (t >= 0.);
  match maxm with
  | 0 ->
      begin
        if t = 0. then [| 1. |] else
          let sq_t = sqrt t in
          [| (Constants.sq_pi_over_two /. sq_t) *.  erf_float sq_t |]
      end
  | _ ->
      begin
        assert (maxm > 0);
        let result =
          Array.init (maxm+1) (fun m -> 1. /. float_of_int (2*m+1))
        in
        let power_t_inv = (maxm+maxm+1)  in
        try  
          let fmax = 
            let t_inv = sqrt (1. /. t) in
            let n = float_of_int maxm in
            let dm = 0.5 +. n in
            let f  = (pow t_inv power_t_inv ) in
            match classify_float f with
            | FP_normal -> (incomplete_gamma ~alpha:dm t) *. 0.5 *. f
            | FP_zero
            | FP_subnormal -> 0.
            | _ -> raise Exit
          in
          let emt = exp (-. t) in
          result.(maxm) <- fmax;
          for n=maxm-1 downto 0 do
            result.(n) <- ( (t+.t) *. result.(n+1) +. emt) *. result.(n)
          done;
          result
        with Exit -> result
      end
(* Functions related to the Boys function:4 ends here *)



(* | ~list_some~  | Filters out all ~None~ elements of the list, and returns the elements without the ~Some~ |
 * | ~list_range~ | Creates a list of consecutive integers                                                   |
 * | ~list_pack~  | ~list_pack n l~ Creates a list of ~n~-elements lists                                     | *)


(* [[file:~/QCaml/common/util.org::*List%20functions][List functions:2]] *)
let list_some l =
  List.filter (function None -> false | _ -> true) l
  |> List.rev_map (function Some x -> x | _ -> assert false)
  |> List.rev


let list_range first last = 
  if last < first then [] else
    let rec aux accu = function
      | 0 -> first :: accu
      | i -> (aux [@tailcall]) ( (first+i)::accu ) (i-1)
    in
    aux [] (last-first)


let list_pack n l =
  assert (n>=0);
  let rec aux i accu1 accu2 = function
    | [] -> if accu1 = [] then
          List.rev accu2
        else 
          List.rev ((List.rev accu1) :: accu2)
    | a :: rest ->
        match i with
        | 0 -> (aux [@tailcall]) (n-1)  [] ((List.rev (a::accu1)) :: accu2) rest
        | _ -> (aux [@tailcall]) (i-1)  (a::accu1) accu2 rest
  in
  aux (n-1) [] [] l
(* List functions:2 ends here *)



(* | ~array_range~   | Creates an array of consecutive integers             |
 * | ~array_sum~     | Returns the sum of all the elements of the array     |
 * | ~array_product~ | Returns the product of all the elements of the array | *)


(* [[file:~/QCaml/common/util.org::*Array%20functions][Array functions:2]] *)
let array_range first last = 
  if last < first then [| |] else
    Array.init (last-first+1) (fun i -> i+first)


let array_sum a = 
  Array.fold_left ( +. ) 0. a


let array_product a = 
  Array.fold_left ( *. ) 1. a
(* Array functions:2 ends here *)



(* | ~stream_range~   | Creates a stream returning consecutive integers |
 * | ~stream_to_list~ | Read a stream and put items in a list           |
 * | ~stream_fold~    | Apply a fold to the elements of the stream      | *)


(* [[file:~/QCaml/common/util.org::*Stream%20functions][Stream functions:2]] *)
let stream_range first last = 
  Stream.from (fun i ->
    let result = i+first in
    if result <= last then
      Some result
    else None
  )

let stream_to_list stream = 
  let rec aux accu =
    let new_accu = 
      try
        Some (Stream.next stream :: accu)
      with Stream.Failure -> None
    in
    match new_accu with
    | Some new_accu -> (aux [@tailcall]) new_accu
    | None -> accu
  in List.rev @@ aux []


let stream_fold f init stream =
  let rec aux accu =
    let new_accu = 
      try
        let element = Stream.next stream in
        Some (f accu element)
      with Stream.Failure -> None
    in  
    match new_accu with
    | Some new_accu -> (aux [@tailcall]) new_accu
    | None -> accu
  in
  aux init
(* Stream functions:2 ends here *)



(*    | ~pp_float_array~        | Printer for float arrays                             |
 *    | ~pp_float_array_size~   | Printer for float arrays with size                   |
 *    | ~pp_float_2darray~      | Printer for matrices                                 |
 *    | ~pp_float_2darray_size~ | Printer for matrices with size                       |
 *    | ~pp_bitstring~          | Printer for bit strings (used by ~Bitstring~ module) |
 * 
 *    Example:
 *    #+begin_example
 * pp_float_array_size:
 * [ 6:   1.000000   1.732051   1.732051   1.000000   1.732051   1.000000 ]
 * 
 * pp_float_array: 
 * [    1.000000   1.732051   1.732051   1.000000   1.732051   1.000000 ]
 * 
 * pp_float_2darray_size
 * [
 *   2:[ 6:  1.000000   1.732051   1.732051   1.000000   1.732051   1.000000 ]
 *     [ 4:  1.000000   2.000000   3.000000   4.000000 ] ]
 * 
 * pp_float_2darray:
 * [ [   1.000000   1.732051   1.732051   1.000000   1.732051   1.000000 ]
 *   [   1.000000   2.000000   3.000000   4.000000 ] ]
 * 
 * pp_bitstring 14:
 * +++++------+--
 *    #+end_example *)


(* [[file:~/QCaml/common/util.org::*Printers][Printers:2]] *)
let pp_float_array ppf a = 
  Format.fprintf ppf "@[<2>[@ ";
  Array.iter (fun f -> Format.fprintf ppf "@[%10f@]@ " f) a;
  Format.fprintf ppf "]@]"

let pp_float_array_size ppf a = 
  Format.fprintf ppf "@[<2>@[ %d:@[<2>" (Array.length a);
  Array.iter (fun f -> Format.fprintf ppf "@[%10f@]@ " f) a;
  Format.fprintf ppf "]@]@]"

let pp_float_2darray ppf a = 
  Format.fprintf ppf "@[<2>[@ ";
  Array.iter (fun f -> Format.fprintf ppf "@[%a@]@ " pp_float_array f) a;
  Format.fprintf ppf "]@]"

let pp_float_2darray_size ppf a = 
  Format.fprintf ppf "@[<2>@[ %d:@[" (Array.length a);
  Array.iter (fun f -> Format.fprintf ppf "@[%a@]@ " pp_float_array_size f) a;
  Format.fprintf ppf "]@]@]"

let pp_bitstring n ppf bs =
  String.init n (fun i -> if (Z.testbit bs i) then '+' else '-')
  |> Format.fprintf ppf "@[<h>%s@]"
(* Printers:2 ends here *)
