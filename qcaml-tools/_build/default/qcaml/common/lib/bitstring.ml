(* Single-integer implementation                                   :noexport: *)


(* [[file:~/QCaml/common/bitstring.org::*Single-integer%20implementation][Single-integer implementation:1]] *)
module One = struct

  let of_int x =
    assert (x > 0); x

  let numbits _ = 63
  let zero = 0
  let is_zero x = x = 0
  let shift_left x i = x lsl i
  let shift_right x i = x lsr i
  let shift_left_one i = 1 lsl i
  let testbit x i = ( (x lsr i) land 1 ) = 1
  let logor a b = a lor b
  let neg a = - a
  let logxor a b = a lxor b
  let logand a b = a land b
  let lognot a = lnot a
  let minus_one a = a - 1
  let plus_one a = a + 1

  let popcount = function
    | 0 -> 0
    | r  -> Util.popcnt (Int64.of_int r)

  let trailing_zeros r =
    Util.trailz (Int64.of_int r)

  let hamdist a b =
    a lxor b
    |> popcount

  let pp ppf s =
    Format.fprintf ppf "@[@[%a@]@]" (Util.pp_bitstring 64)
      (Z.of_int s)

end
(* Single-integer implementation:1 ends here *)

(* Zarith implementation                                           :noexport: *)


(* [[file:~/QCaml/common/bitstring.org::*Zarith%20implementation][Zarith implementation:1]] *)
module Many = struct

  let of_z x = x
  let zero = Z.zero
  let is_zero x = x = Z.zero
  let shift_left = Z.shift_left
  let shift_right = Z.shift_right
  let shift_left_one i = Z.shift_left Z.one i
  let testbit = Z.testbit
  let logor = Z.logor
  let logxor = Z.logxor
  let logand = Z.logand
  let lognot = Z.lognot
  let neg = Z.neg
  let minus_one = Z.pred
  let plus_one = Z.succ
  let trailing_zeros = Z.trailing_zeros
  let hamdist = Z.hamdist
  let numbits i = max (Z.numbits i) 64

  let popcount z =
    if z = Z.zero then 0 else Z.popcount z

  let pp ppf s =
    Format.fprintf ppf "@[@[%a@]@]" (Util.pp_bitstring (Z.numbits s))  s

end
(* Zarith implementation:1 ends here *)

(* [[file:~/QCaml/common/bitstring.org::*Type][Type:2]] *)
type t =
  | One of int
  | Many of Z.t
(* Type:2 ends here *)



(* | ~of_int~         | Creates a bit string from an ~int~                                                                                                                                                               |
 * | ~of_z~           | Creates a bit string from an ~Z.t~ multi-precision integer                                                                                                                                       |
 * | ~zero~           | ~zero n~ creates a zero bit string with ~n~ bits                                                                                                                                                 |
 * | ~is_zero~        | True if all the bits of the bit string are zero.                                                                                                                                                 |
 * | ~numbits~        | Returns the number of bits used to represent the bit string                                                                                                                                      |
 * | ~testbit~        | ~testbit t n~ is true if the ~n~-th bit of the bit string ~t~ is set to ~1~                                                                                                                      |
 * | ~neg~            | Returns the negative of the integer interpretation of the bit string                                                                                                                             |
 * | ~shift_left~     | ~shift_left t n~ returns a new bit strings with all the bits shifted ~n~ positions to the left                                                                                                   |
 * | ~shift_right~    | ~shift_right t n~ returns a new bit strings with all the bits shifted ~n~ positions to the right                                                                                                 |
 * | ~shift_left_one~ | ~shift_left_one size n~ returns a new bit strings with the ~n~-th bit set to one. It is equivalent as shifting ~1~ by ~n~ bits to the left, ~size~ is the total number of bits of the bit string |
 * | ~logor~          | Bitwise logical or                                                                                                                                                                               |
 * | ~logxor~         | Bitwise logical exclusive or                                                                                                                                                                     |
 * | ~logand~         | Bitwise logical and                                                                                                                                                                              |
 * | ~lognot~         | Bitwise logical negation                                                                                                                                                                         |
 * | ~plus_one~       | Takes the integer representation of the bit string and adds one                                                                                                                                  |
 * | ~minus_one~      | Takes the integer representation of the bit string and removes one                                                                                                                               |
 * | ~hamdist~        | Returns the Hamming distance, i.e. the number of bits differing between two bit strings                                                                                                          |
 * | ~trailing_zeros~ | Returns the number of trailing zeros in the bit string                                                                                                                                           |
 * | ~permutations~   | ~permutations m n~ generates the list of all possible ~n~-bit strings with ~m~ bits set to ~1~. Algorithm adapted from [[https://graphics.stanford.edu/~seander/bithacks.html#NextBitPermutation][Bit twiddling hacks]]                                                       |
 * | ~popcount~       | Returns the number of bits set to one in the bit string                                                                                                                                          |
 * | ~to_list~        | Converts a bit string into a list of integers indicating the positions where the bits are set to ~1~. The first value for the position is not ~0~ but ~1~                                        | *)


(* [[file:~/QCaml/common/bitstring.org::*General%20implementation][General implementation:2]] *)
let of_int x =
  One (One.of_int x)

let of_z x =
  if Z.numbits x < 64 then One (Z.to_int x) else Many (Many.of_z x)
(* General implementation:2 ends here *)


    
(*    Example:
 *    #+begin_example
 * Bitstring.of_int 15;;
 * - : Bitstring.t =
 * ++++------------------------------------------------------------
 *    #+end_example *)
   

(* [[file:~/QCaml/common/bitstring.org::*General%20implementation][General implementation:4]] *)
let zero = function
  | n when n < 64 -> One (One.zero)
  | _ -> Many (Many.zero)


let numbits = function
  | One x -> One.numbits x
  | Many x -> Many.numbits x


let is_zero = function
  | One x -> One.is_zero x
  | Many x -> Many.is_zero x


let neg = function
  | One x -> One (One.neg x)
  | Many x -> Many (Many.neg x)


let shift_left x i = match x with
  | One x -> One (One.shift_left x i)
  | Many x -> Many (Many.shift_left x i)


let shift_right x i = match x with
  | One x -> One (One.shift_right x i)
  | Many x -> Many (Many.shift_right x i)

let shift_left_one = function
  | n when n < 64 -> fun i -> One (One.shift_left_one i)
  | _ -> fun i -> Many (Many.shift_left_one i)

let testbit = function
  | One x -> One.testbit x
  | Many x -> Many.testbit x
(* General implementation:4 ends here *)

(* [[file:~/QCaml/common/bitstring.org::*General%20implementation][General implementation:6]] *)
let logor a b =
  match a,b with
  | One a, One b -> One (One.logor a b)
  | Many a, Many b -> Many (Many.logor a b)
  | _ -> invalid_arg "Bitstring.logor"


let logxor a b =
  match a,b with
  | One a, One b -> One (One.logxor a b)
  | Many a, Many b -> Many (Many.logxor a b)
  | _ -> invalid_arg "Bitstring.logxor"


let logand a b =
  match a,b with
  | One a, One b -> One (One.logand a b)
  | Many a, Many b -> Many (Many.logand a b)
  | _ -> invalid_arg "Bitstring.logand"


let lognot = function
  | One x -> One (One.lognot x)
  | Many x -> Many (Many.lognot x)
(* General implementation:6 ends here *)

(* [[file:~/QCaml/common/bitstring.org::*General%20implementation][General implementation:8]] *)
let minus_one = function
  | One x -> One (One.minus_one x)
  | Many x -> Many (Many.minus_one x)


let plus_one = function
  | One x -> One (One.plus_one x)
  | Many x -> Many (Many.plus_one x)
(* General implementation:8 ends here *)




(*    Example:
 *    #+begin_example
 * Bitstring.(plus_one (of_int 15));;
 * - : Bitstring.t =
 * ----+-----------------------------------------------------------
 *    
 * Bitstring.(minus_one (of_int 15));;
 * - : Bitstring.t =
 * -+++------------------------------------------------------------
 *    #+end_example *)



(* [[file:~/QCaml/common/bitstring.org::*General%20implementation][General implementation:9]] *)
let trailing_zeros = function
  | One x -> One.trailing_zeros x
  | Many x -> Many.trailing_zeros x


let hamdist a b = match a, b with
  | One a, One b -> One.hamdist a b
  | Many a, Many b -> Many.hamdist a b
  | _ -> invalid_arg "Bitstring.hamdist"


let popcount = function
  | One x -> One.popcount x
  | Many x -> Many.popcount x
(* General implementation:9 ends here *)




(*    Example:
 *    #+begin_example
 * Bitstring.(trailing_zeros (of_int 12));;
 * - : int = 2
 * 
 * Bitstring.(hamdist (of_int 15) (of_int 73));;
 * - : int = 3
 * 
 * Bitstring.(popcount (of_int 15));;
 * - : int = 4
 *    #+end_example *)


(* [[file:~/QCaml/common/bitstring.org::*General%20implementation][General implementation:10]] *)
let rec to_list ?(accu=[]) = function
  | t when (is_zero t) -> List.rev accu
  | t -> let newlist =
           (trailing_zeros t + 1)::accu
      in
      logand t @@ minus_one t
      |> (to_list [@tailcall]) ~accu:newlist
(* General implementation:10 ends here *)



(*    Example:
 *    #+begin_example
 * Bitstring.(to_list (of_int 45));;
 * - : int list = [1; 3; 4; 6]
 *    #+end_example *)


(* [[file:~/QCaml/common/bitstring.org::*General%20implementation][General implementation:12]] *)
let permutations m n =

  let rec aux k u rest =
    if k=1 then
      List.rev (u :: rest)
    else
      let t   = logor u @@ minus_one u in
      let t'  = plus_one t in
      let not_t = lognot t in
      let neg_not_t = neg not_t in
      let t'' = shift_right (minus_one @@ logand not_t neg_not_t) (trailing_zeros u + 1) in
      (*
      let t'' = shift_right (minus_one (logand (lognot t) t')) (trailing_zeros u + 1) in
      *)
      (aux [@tailcall]) (k-1) (logor t' t'') (u :: rest)
  in
  aux (Util.binom n m) (minus_one (shift_left_one n m)) []
(* General implementation:12 ends here *)

(* [[file:~/QCaml/common/bitstring.org::*Printers][Printers:2]] *)
let pp ppf = function
  | One x -> One.pp ppf x
  | Many x -> Many.pp ppf x
(* Printers:2 ends here *)
