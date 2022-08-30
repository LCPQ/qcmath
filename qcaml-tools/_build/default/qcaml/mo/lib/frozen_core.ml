(* [[file:~/QCaml/mo/frozen_core.org::*Type][Type:3]] *)
type kind =
  | All_electron
  | Small
  | Large
type t = int array
(* Type:3 ends here *)



(*    | ~make~         | Creates a ~Frozen_core.t~ with the same kind for all atoms               |
 *    | ~of_int_array~ | Creates a ~Frozen_core.t~ giving the number of frozen electrons per atom |
 *    | ~of_int_list~  | Creates a ~Frozen_core.t~ giving the number of frozen electrons per atom |
 * 
 *    #+begin_example
 * let f = Frozen_core.(make Small nuclei) ;;
 * val f : Frozen_core.t = [|0; 2; 2; 0|]
 * 
 * let f = Frozen_core.(of_int_list [0; 2; 2; 0])
 * val f : Frozen_core.t = [|0; 2; 2; 0|]
 *    #+end_example *)


(* [[file:~/QCaml/mo/frozen_core.org::*Creation][Creation:2]] *)
let make_ae nuclei =
  Array.map (fun _ -> 0) nuclei

let make_small nuclei =
  Array.map (fun (e,_) -> Particles.Element.small_core e) nuclei

let make_large nuclei =
  Array.map (fun (e,_) -> Particles.Element.large_core e) nuclei

let make = function
  | All_electron -> make_ae 
  | Small        -> make_small 
  | Large        -> make_large


external of_int_array : int array -> t = "%identity"

let of_int_list = Array.of_list
(* Creation:2 ends here *)



(*    | ~num_elec~ | Number of frozen electrons          |
 *    | ~num_mos~  | Number of frozen molecular orbitals |
 * 
 *    #+begin_example
 * Frozen_core.num_elec f ;;
 * - : int = 4
 * 
 * Frozen_core.num_mos f ;;
 * - : int = 2
 *    #+end_example *)


(* [[file:~/QCaml/mo/frozen_core.org::*Access][Access:2]] *)
let num_elec t =
  Array.fold_left ( + ) 0 t

let num_mos t =
  (num_elec t) / 2
(* Access:2 ends here *)

(* [[file:~/QCaml/mo/frozen_core.org::*Printers][Printers:2]] *)
let pp ppf t =
  Format.fprintf ppf "@[[|";
  Array.iter (fun x -> Format.fprintf ppf "@,@[%d@]" x) t;
  Format.fprintf ppf "|]@]";
(* Printers:2 ends here *)
