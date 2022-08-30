(* ./run_Localisation.native -b basis -x xyz -c charge -o name.mos -i EZFIOdirectory > name.out *)
(* 
#.mos contains the localised orbitales 
#.out contains the localization convergence and the analysis of the spatial extent of the orbitales
*)

open Qcaml

module Command_line = Common.Command_line
module Util = Common.Util
module Range = Common.Range
module Electrons = Particles.Electrons

open Linear_algebra

let read_qp_mo dirname =
  let ic = Unix.open_process_in ("zcat "^dirname^"/mo_basis/mo_coef.gz") in
  let check = String.trim (input_line ic) in
  assert (check = "2");
  let int_list = 
    input_line ic
    |> String.split_on_char ' ' 
    |> List.filter (fun x -> x <> "")
    |> List.map int_of_string
  in
  let n_ao, n_mo = 
    match int_list with
    | [ x ; y ] -> x, y
    | _ -> assert false
  in
  let result = 
          Matrix.init_cols n_ao n_mo (fun _ _ ->
            let s = input_line ic in
            Scanf.sscanf s " %f " (fun x -> x)
          )
  in
  let exit_code = Unix.close_process_in ic in
  assert (exit_code = Unix.WEXITED 0);
  result



let () =
  let open Command_line in
  begin
    set_header_doc (Sys.argv.(0) ^ " - QCaml command");
    set_description_doc "Localizes MOs";
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
          doc="Total charge of the molecule. Default is 0"; } ;
        
        { short='o' ; long="output" ; opt=Mandatory;
          arg=With_arg "<string>";
          doc="Name of the file containing the localized MOs"; } ;

        { short='i' ; long="import" ; opt=Optional;
          arg=With_arg "<string>";
          doc="Name of the EZFIO directory containing MOs"; } ;

        { short='r' ; long="range" ; opt=Mandatory;
          arg=With_arg "<range>";
          doc="Range of orbitals to include in localization"; } ;

      ]
  end;



  (* II : Hartree-Fock *)

  (* 1. Def pour HF *)

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

  let range =
    Command_line.get "range" 
    |> Util.of_some
    |> Range.of_string
    |> Range.to_int_list
  in

  let ezfio_file = Command_line.get "import" in

  let output_filename = Util.of_some @@ Command_line.get "output" in
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


  let simulation = 
    Simulation.make ~charge ~multiplicity ~nuclei ao_basis
  in 

  (* 2. Calcul de Hartree-Fock*)
  let mo_basis = 
     match ezfio_file with
     | Some ezfio_file ->
           let mo_coef =  read_qp_mo  ezfio_file in
           let mo_type = Mo.Basis.Localized "Boys" in
           let elec = Simulation.electrons simulation in
           let n_mo = Matrix.dim2 mo_coef in
           let mo_occupation = Vector.init n_mo (fun i ->
                   if i <= Electrons.n_beta elec then 2.
                   else if i <= Electrons.n_alfa elec then 1.
                   else 0.) in
           Mo.Basis.make ~simulation ~mo_type ~mo_occupation ~mo_coef ()
     | None -> Mo.Hartree_fock.make simulation 
               |> Mo.Basis.of_hartree_fock
  in


  let localization = 
    Mo.Localization.make ~kind:Mo.Localization.Boys mo_basis range
  in

  Format.printf "@[%a@]" (Mo.Localization.pp) localization;

  let local_mo_basis =
    Mo.Localization.to_basis localization
  in

  let local_mos =
    Mo.Basis.mo_coef local_mo_basis
  in
  
  let oc = open_out output_filename in
  Printf.fprintf oc "[\n";
  Matrix.as_vec local_mos
  |> Vector.iter (fun x -> Printf.fprintf oc "%20.15e,\n" x);
  Printf.fprintf oc "]\n";
  close_out oc
