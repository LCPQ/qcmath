(* [[file:~/QCaml/top/install_printers.org::*Intall%20printers][Intall printers:3]] *)
let printers =
  [
    "Ao.Basis.pp" ;
    "Ao.Basis_gaussian.pp" ;
    "Common.Angular_momentum.pp" ;
    "Common.Bitstring.pp" ;
    "Common.Charge.pp" ;
    "Common.Coordinate.pp" ;
    "Common.Powers.pp" ;
    "Common.Range.pp" ;
    "Common.Spin.pp" ;
    "Common.Zkey.pp" ;
    "Gaussian.Atomic_shell.pp" ;
    "Gaussian.Atomic_shell_pair.pp" ;
    "Gaussian.Atomic_shell_pair_couple.pp" ;
    "Mo.Frozen_core.pp" ;
    "Mo.Localization.pp" ;
    "Particles.Electrons.pp" ;
    "Particles.Element.pp" ;
    "Particles.Nuclei.pp" ;
    "Particles.Zmatrix.pp" ;
    "Perturbation.Mp2.pp" ;
    "Simulation.pp" ;
    
  ]

let eval_exn str =
  let lexbuf = Lexing.from_string str in
  let phrase = !Toploop.parse_toplevel_phrase lexbuf in
  Toploop.execute_phrase false Format.err_formatter phrase


let rec install_printers = function
  | [] -> eval_exn "#require \"lacaml.top\";;"
  | printer :: printers ->
      let cmd = Printf.sprintf "#install_printer %s;;" printer in
      eval_exn cmd && install_printers printers

let () =
  if not (install_printers printers) then
    Format.eprintf "Problem installing QCaml-printers@."
(* Intall printers:3 ends here *)
