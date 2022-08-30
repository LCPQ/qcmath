(* [[file:~/QCaml/simulation/simulation.org::*Simulation][Simulation:2]] *)
open Common
open Particles
open Operators
(* Simulation:2 ends here *)

(* [[file:~/QCaml/simulation/simulation.org::*Type][Type:2]] *)
type t = {
  charge            : Charge.t;
  electrons         : Electrons.t;
  nuclei            : Nuclei.t;
  ao_basis          : Ao.Basis.t;
  operators         : Operator.t list;
}
(* Type:2 ends here *)



(* | ~nuclei~            | Nuclear coordinates used in the smiulation           |
 * | ~charge~            | Total charge (electrons + nuclei)                    |
 * | ~electrons~         | Electrons used in the simulation                     |
 * | ~ao_basis~          | Atomic basis set                                     |
 * | ~nuclear_repulsion~ | Nuclear repulsion energy                             |
 * | ~operators~         | List of extra operators (range-separation, f12, etc) | *)


(* [[file:~/QCaml/simulation/simulation.org::*Access][Access:2]] *)
let nuclei            t = t.nuclei
let charge            t = t.charge
let electrons         t = t.electrons
let ao_basis          t = t.ao_basis
let nuclear_repulsion t = Nuclei.repulsion @@ nuclei t
let operators         t = t.operators
(* Access:2 ends here *)



(* Defaults:
 * - multiplicity : ~1~
 * - charge : ~0~
 * - operators : ~[]~ *)


(* [[file:~/QCaml/simulation/simulation.org::*Creation][Creation:2]] *)
let make
    ?(multiplicity=1)
    ?(charge=0)
    ?(operators=[])
    ~nuclei
    ao_basis
  =

  (* Tune Garbage Collector *)
  let gc = Gc.get () in
  Gc.set { gc with space_overhead = 1000  };

  let electrons =
    Electrons.of_atoms ~multiplicity ~charge nuclei
  in

  let charge = 
    Charge.(Nuclei.charge nuclei + Electrons.charge electrons)
  in

  { charge ; nuclei ; electrons ; ao_basis ; operators}
(* Creation:2 ends here *)

(* [[file:~/QCaml/simulation/simulation.org::*Printers][Printers:2]] *)
let pp ppf t =
  let formula = Nuclei.formula t.nuclei in
  let n_aos = Ao.Basis.size t.ao_basis in
  let n_ops = List.length t.operators in
  Format.fprintf ppf "@[@[%s@], @[%a@], @[%d AOs@], @[%d operators@]@]"
    formula  Electrons.pp t.electrons n_aos n_ops
(* Printers:2 ends here *)
