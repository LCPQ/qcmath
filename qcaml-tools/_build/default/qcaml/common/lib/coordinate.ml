(* [[file:~/QCaml/common/coordinate.org::*Type][Type:2]] *)
type bohr 
type angstrom 

type xyz = {
  x : float ;
  y : float ;
  z : float ;
}

type 'a point = xyz

type t = bohr point

type axis = X | Y | Z
(* Type:2 ends here *)



(* | ~make~          | Creates a point in atomic units |
 * | ~make_angstrom~ | Creates a point in angstrom     |
 * | ~zero~          | $(0., 0., 0.)$                  | *)


(* [[file:~/QCaml/common/coordinate.org::*Creation][Creation:2]] *)
external make          : 'a point -> t              = "%identity"
external make_angstrom : 'a point -> angstrom point = "%identity"

let zero =
  make { x = 0. ; y = 0. ; z = 0. }
(* Creation:2 ends here *)



(* | ~bohr_to_angstrom~ | Converts a point in bohr to angstrom |
 * | ~angstrom_to_bohr~ | Converts a point in angstrom to bohr | *)


(* [[file:~/QCaml/common/coordinate.org::*Conversion][Conversion:2]] *)
let b_to_a b = Constants.a0 *. b 
let bohr_to_angstrom { x ; y ; z } =
  make { x = b_to_a x ;
         y = b_to_a y ;
         z = b_to_a z ; }


let a_to_b a = Constants.a0_inv *. a 
let angstrom_to_bohr { x ; y ; z } =  
  make { x = a_to_b x ;
         y = a_to_b y ;
         z = a_to_b z ; }
(* Conversion:2 ends here *)



(*    | ~neg~     | Negative of a point                                  |
 *    | ~get~     | Extracts the projection of the coordinate on an axis |
 *    | ~dot~     | Dot product                                          |
 *    | ~norm~    | $\ell{^2}$ norm of the vector                        |
 *    | $\vert .$ | Scales the vector by a constant                      |
 *    | $\vert +$ | Adds two vectors                                     |
 *    | $\vert -$ | Subtracts two vectors                                |
 * 
 *    Example:
 *    #+begin_example
 * Coordinate.neg { x=1. ; y=2. ; z=3. } ;;
 * - : Coordinate.t =  -1.0000  -2.0000  -3.0000
 * 
 * Coordinate.(get Y { x=1. ; y=2. ; z=3. }) ;;
 * - : float = 2.
 * 
 * Coordinate.(
 *   2. |. { x=1. ; y=2. ; z=3. }
 * ) ;;
 * - : Coordinate.t =   2.0000   4.0000   6.0000
 * 
 * Coordinate.(
 *   { x=1. ; y=2. ; z=3. } |+ { x=2. ; y=3. ; z=1. } 
 * );;
 * - : Coordinate.t =   3.0000   5.0000   4.0000
 * 
 * Coordinate.(
 *   { x=1. ; y=2. ; z=3. } |- { x=2. ; y=3. ; z=1. } 
 * );;
 * - : Coordinate.t =  -1.0000  -1.0000   2.0000
 *    #+end_example *)



(* [[file:~/QCaml/common/coordinate.org::*Vector%20operations][Vector operations:2]] *)
let get axis { x ; y ; z } = 
  match axis with
  | X -> x 
  | Y -> y 
  | Z -> z  


let ( |. )  s { x ; y ; z } =
  make { x = s *. x ;
         y = s *. y ;
         z = s *. z ; }


let ( |+ )
    { x = x1 ; y = y1 ; z = z1 }
    { x = x2 ; y = y2 ; z = z2 } =
  make { x = x1 +. x2 ;
         y = y1 +. y2 ;
         z = z1 +. z2 ; }


let ( |- )
    { x = x1 ; y = y1 ; z = z1 }
    { x = x2 ; y = y2 ; z = z2 } =
  make { x = x1 -. x2 ;
         y = y1 -. y2 ;
         z = z1 -. z2 ; }


let neg a = -1. |. a


let dot
    { x = x1 ; y = y1 ; z = z1 }
    { x = x2 ; y = y2 ; z = z2 } =
  x1 *. x2 +.
  y1 *. y2 +.
  z1 *. z2


let norm u =
  sqrt ( dot u u )
(* Vector operations:2 ends here *)



(* Coordinates can be printed in bohr or angstrom. *)


(* [[file:~/QCaml/common/coordinate.org::*Printers][Printers:2]] *)
open Format
let pp ppf c = 
  fprintf ppf "@[@[%8.4f@] @[%8.4f@] @[%8.4f@]@]" c.x c.y c.z

let pp_bohr ppf c = 
  fprintf ppf "@[(@[%10f@], @[%10f@], @[%10f@] Bohr)@]" c.x c.y c.z

let pp_angstrom ppf c = 
  let c = bohr_to_angstrom c in
  fprintf ppf "@[(@[%10f@], @[%10f@], @[%10f@] Angs)@]" c.x c.y c.z
(* Printers:2 ends here *)
