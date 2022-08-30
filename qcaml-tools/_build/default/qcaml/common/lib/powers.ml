

(* ~tot~ always contains ~x+y+z~. *)


(* [[file:~/QCaml/common/powers.org::*Type][Type:2]] *)
type t = {
  x   : int ;
  y   : int ;
  z   : int ;
  tot : int ;
}
(* Type:2 ends here *)



(*    Example:
 *     #+begin_example
 * Powers.of_int_tuple (2,3,1);;
 * - : Powers.t = x^2 + y^3 + z^1
 * 
 * Powers.(to_int_tuple (of_int_tuple (2,3,1)));;
 * - : int * int * int = (2, 3, 1)
 *     #+end_example *)


(* [[file:~/QCaml/common/powers.org::*Conversions][Conversions:2]] *)
let of_int_tuple t =
  let result =
    match t with
    | (x,y,z) -> { x ; y ; z ; tot=x+y+z }
  in
  if result.x < 0 ||
     result.y < 0 ||
     result.z < 0 ||
     result.tot < 0 then
      invalid_arg (__FILE__^": of_int_tuple");
  result


let to_int_tuple { x ; y ; z ; _ } = (x,y,z)
(* Conversions:2 ends here *)



(* | ~get~ | Returns the value of the power for $x$, $y$ or $z$
 * | ~incr~ | Returns a new ~Powers.t~ with the power on the given axis incremented |
 * | ~decr~ | Returns a new ~Powers.t~ with the power on the given axis decremented. As opposed to ~of_int_tuple~, the values may become negative|
 * 
 *    Example:
 *     #+begin_example
 * Powers.get Coordinate.Y (Powers.of_int_tuple (2,3,1));;
 * - : int = 3
 * 
 * Powers.incr Coordinate.Y (Powers.of_int_tuple (2,3,1));;
 * - : Powers.t = x^2 + y^4 + z^1
 * 
 * Powers.decr Coordinate.Y (Powers.of_int_tuple (2,3,1));;
 * - : Powers.t = x^2 + y^2 + z^1
 *     #+end_example *)



(* [[file:~/QCaml/common/powers.org::*Operations][Operations:2]] *)
let get coord t =
  match coord with
  | Coordinate.X -> t.x
  | Coordinate.Y -> t.y
  | Coordinate.Z -> t.z

let incr coord t =
  match coord with
  | Coordinate.X -> let r = t.x+1 in { t with x = r ; tot = t.tot+1 }
  | Coordinate.Y -> let r = t.y+1 in { t with y = r ; tot = t.tot+1 }
  | Coordinate.Z -> let r = t.z+1 in { t with z = r ; tot = t.tot+1 }

let decr coord t =
  match coord with
  | Coordinate.X -> let r = t.x-1 in { t with x = r ; tot = t.tot-1 }
  | Coordinate.Y -> let r = t.y-1 in { t with y = r ; tot = t.tot-1 }
  | Coordinate.Z -> let r = t.z-1 in { t with z = r ; tot = t.tot-1 }
(* Operations:2 ends here *)

(* [[file:~/QCaml/common/powers.org::*Printers][Printers:2]] *)
let pp ppf t =
  Format.fprintf ppf "@[x^%d + y^%d + z^%d@]" t.x t.y t.z
(* Printers:2 ends here *)
