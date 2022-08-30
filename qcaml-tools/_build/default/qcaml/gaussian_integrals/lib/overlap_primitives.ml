open Common
open Util


(* Horizontal and Vertical Recurrence Relations (HVRR) *)
let hvrr (angMom_a, angMom_b) (expo_inv_p) (center_ab, center_pa)
  =

  (* Vertical recurrence relations *)
  let rec vrr angMom_a =

    if angMom_a > 0 then
      chop center_pa (fun () -> vrr (angMom_a-1))
      +. chop (0.5 *. float_of_int_fast (angMom_a-1) *. expo_inv_p) 
        (fun () -> vrr (angMom_a-2))
    else if angMom_a = 0 then 1.
    else 0.


  (* Horizontal recurrence relations *)
  and hrr angMom_a angMom_b =

    if angMom_b > 0 then
      hrr (angMom_a+1) (angMom_b-1) +. chop center_ab
      (fun () -> hrr angMom_a (angMom_b-1) )
    else if angMom_b = 0 then
      vrr angMom_a 
    else 0.

  in
  hrr angMom_a angMom_b 



let overlap = hvrr

