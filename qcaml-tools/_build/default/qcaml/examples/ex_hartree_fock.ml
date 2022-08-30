(* [[file:~/QCaml/examples/ex_hartree_fock.org::*Header][Header:1]] *)
module Command_line = Qcaml.Common.Command_line
module Util = Qcaml.Common.Util

let () =
(* Header:1 ends here *)

(* [[file:~/QCaml/examples/ex_hartree_fock.org::*Definition][Definition:1]] *)
let open Command_line in
begin
  set_header_doc (Sys.argv.(0) ^ " - QuAcK command");
  set_description_doc "Computes the one- and two-electron hartree_fock on the Gaussian atomic basis set.";
  set_specs
    [ { short='b' ; long="basis" ; opt=Mandatory;
	arg=With_arg "<string>";
	doc="Name of the file containing the basis set"; } ;
      
      { short='x' ; long="xyz" ; opt=Mandatory;
	arg=With_arg "<string>";
	doc="Name of the file containing the nuclear coordinates in xyz format"; } ;

      { short='m' ; long="multiplicity" ; opt=Optional;
        arg=With_arg "<int>";
        doc="Spin multiplicity (2S+1). Default is singlet"; } ;
      
      { short='c' ; long="charge" ; opt=Optional;
        arg=With_arg "<int>";
        doc="Total charge of the molecule. Specify negative charges with 'm' instead of the minus sign, for example m1 instead of -1. Default is 0"; } ;
      
    ]
end;
(* Definition:1 ends here *)

(* [[file:~/QCaml/examples/ex_hartree_fock.org::*Interpretation][Interpretation:1]] *)
let basis_file  = Util.of_some @@ Command_line.get "basis" in
let nuclei_file = Util.of_some @@ Command_line.get "xyz" in

let charge =
  match Command_line.get "charge" with
  | Some x -> ( if x.[0] = 'm' then
                  ~- (int_of_string (String.sub x 1 (String.length x - 1)))
                else
                  int_of_string x )
  | None   -> 0
in
    
let multiplicity =
  match Command_line.get "multiplicity" with
  | Some x -> int_of_string x
  | None -> 1
in
(* Interpretation:1 ends here *)

(* [[file:~/QCaml/examples/ex_hartree_fock.org::*Computation][Computation:1]] *)
let nuclei =
  Qcaml.Particles.Nuclei.of_xyz_file nuclei_file
in
(* Computation:1 ends here *)

(* [[file:~/QCaml/examples/ex_hartree_fock.org::*Computation][Computation:2]] *)
let ao_basis =
  Qcaml.Ao.Basis.of_nuclei_and_basis_filename ~nuclei basis_file
in
(* Computation:2 ends here *)

(* [[file:~/QCaml/examples/ex_hartree_fock.org::*Computation][Computation:3]] *)
let simulation = Qcaml.Simulation.make ~charge ~multiplicity ~nuclei ao_basis in
(* Computation:3 ends here *)

(* [[file:~/QCaml/examples/ex_hartree_fock.org::*Computation][Computation:4]] *)
let hf = Qcaml.Mo.Hartree_fock.make ~guess:`Huckel simulation in
(* Computation:4 ends here *)

(* [[file:~/QCaml/examples/ex_hartree_fock.org::*Output][Output:1]] *)
Format.printf "@[%a@]" (Mo.Hartree_fock.pp) hf
(* Output:1 ends here *)
