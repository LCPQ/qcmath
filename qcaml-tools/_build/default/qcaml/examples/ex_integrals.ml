(* [[file:~/QCaml/examples/ex_integrals.org::*Header][Header:1]] *)
module Command_line = Qcaml.Common.Command_line
module Util = Qcaml.Common.Util
open Qcaml.Linear_algebra

let () =
(* Header:1 ends here *)

(* [[file:~/QCaml/examples/ex_integrals.org::*Definition][Definition:1]] *)
let open Command_line in
begin
  set_header_doc (Sys.argv.(0) ^ " - QuAcK command");
  set_description_doc "Computes the one- and two-electron integrals on the Gaussian atomic basis set.";
  set_specs
    [ { short='b' ; long="basis" ; opt=Mandatory;
	arg=With_arg "<string>";
	doc="Name of the file containing the basis set"; } ;

      { short='x' ; long="xyz" ; opt=Mandatory;
	arg=With_arg "<string>";
	doc="Name of the file containing the nuclear coordinates in xyz format"; } ;

      { short='u' ; long="range-separation" ; opt=Optional;
	arg=With_arg "<float>";
	doc="Range-separation parameter."; } ;
    ]
end;
(* Definition:1 ends here *)

(* [[file:~/QCaml/examples/ex_integrals.org::*Interpretation][Interpretation:1]] *)
let basis_file  = Util.of_some @@ Command_line.get "basis" in
let nuclei_file = Util.of_some @@ Command_line.get "xyz" in

let range_separation =
  match Command_line.get "range-separation" with
  | None -> None
  | Some mu -> Some (float_of_string mu)
in

let operators =
  match range_separation with
  | None -> []
  | Some mu -> [ Qcaml.Operators.Operator.of_range_separation mu ]
in
(* Interpretation:1 ends here *)

(* [[file:~/QCaml/examples/ex_integrals.org::*Computation][Computation:1]] *)
let nuclei =
  Qcaml.Particles.Nuclei.of_xyz_file nuclei_file
in
(* Computation:1 ends here *)

(* [[file:~/QCaml/examples/ex_integrals.org::*Computation][Computation:2]] *)
let ao_basis =
  Qcaml.Ao.Basis.of_nuclei_and_basis_filename ~kind:`Gaussian
    ~operators ~cartesian:true ~nuclei basis_file
in
(* Computation:2 ends here *)

(* [[file:~/QCaml/examples/ex_integrals.org::*Computation][Computation:3]] *)
let overlap   = Qcaml.Ao.Basis.overlap   ao_basis in
let eN_ints   = Qcaml.Ao.Basis.eN_ints   ao_basis in
let kin_ints  = Qcaml.Ao.Basis.kin_ints  ao_basis in
let multipole = Qcaml.Ao.Basis.multipole ao_basis in
let x_mat     = multipole "x" in
let y_mat     = multipole "y" in
let z_mat     = multipole "z" in
(* Computation:3 ends here *)

(* [[file:~/QCaml/examples/ex_integrals.org::*Computation][Computation:4]] *)
let ee_ints   = Qcaml.Ao.Basis.ee_ints   ao_basis in
let lr_ints   = 
  match range_separation with
  | Some _mu -> Some (Qcaml.Ao.Basis.ee_lr_ints ao_basis)
  | None -> None
in
(* Computation:4 ends here *)

(* [[file:~/QCaml/examples/ex_integrals.org::*Output][Output:1]] *)
Matrix.to_file ~filename:"overlap.dat" ~sym:true overlap;
Matrix.to_file ~filename:"eN.dat" ~sym:true eN_ints;
Matrix.to_file ~filename:"kinetic.dat" ~sym:true kin_ints;
Matrix.to_file ~filename:"x.dat" ~sym:true x_mat;
Matrix.to_file ~filename:"y.dat" ~sym:true y_mat;
Matrix.to_file ~filename:"z.dat" ~sym:true z_mat;
(* Output:1 ends here *)

(* [[file:~/QCaml/examples/ex_integrals.org::*Output][Output:2]] *)
Four_idx_storage.to_file ~filename:"eri.dat" ee_ints;
match lr_ints with
| Some integrals -> Four_idx_storage.to_file ~filename:"eri_lr.dat" integrals;
| None -> ()
(* Output:2 ends here *)
