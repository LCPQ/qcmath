let qcmath_dir = 
  try Sys.getenv "QCMATH_ROOT" with
  Not_found -> "."

let qcmath_input = qcmath_dir ^ "/input/"
let qcmath_mol   = qcmath_dir ^ "/mol/"
let qcmath_basis = qcmath_dir ^ "/basis/"
let qcmath_int   = qcmath_dir ^ "/int/"

let qcmath_basis_filename = qcmath_dir ^ "basis"
let qcmath_molecule_filename = qcmath_dir ^ "molecule"

module Command_line = Qcaml.Common.Command_line
module Util = Qcaml.Common.Util
open Qcaml.Linear_algebra

let () =
  let open Command_line in
  begin
    set_header_doc (Sys.argv.(0) ^ " - qcmath command");
    set_description_doc "Prepares the input data for QuAcK.
Writes $QCMATH_ROOT/input/basis and $QCMATH_ROOT/input/molecule.
If $QCMATH_ROOT is not set, $QCMATH_ROOT is replaces by the current
directory.";
    set_specs
      [ { short='b' ; long="basis" ; opt=Mandatory;
          arg=With_arg "<string>";
          doc="Name of the file containing the basis set in the $QCMATH_ROOT/basis/ directory"; } ;

        { short='x' ; long="xyz" ; opt=Mandatory;
          arg=With_arg "<string>";
          doc="Name of the file containing the nuclear coordinates in xyz format in the $QCMATH_ROOT/mol/ directory without the .xyz extension"; } ;

        { short='m' ; long="multiplicity" ; opt=Optional;
          arg=With_arg "<int>";
          doc="Spin multiplicity (2S+1). Default is singlet"; } ;

        { short='c' ; long="charge" ; opt=Optional;
          arg=With_arg "<int>";
          doc="Total charge of the molecule. Specify negative charges with 'm' instead of the minus sign, for example m1 instead of -1. Default is 0"; } ;

        { short='f' ; long="frozen-core" ; opt=Optional;
          arg=Without_arg ;
          doc="Freeze core MOs. Default is false"; } ;

        { short='r' ; long="rydberg" ; opt=Optional;
          arg=With_arg "<int>" ;
          doc="Number of Rydberg electrons. Default is 0"; } ;

        { short='u' ; long="range-separation" ; opt=Optional;
          arg=With_arg "<float>";
          doc="Range-separation parameter."; } ;
      ]
  end;

  (* Handle options *)
  let basis_file  = 
    qcmath_basis ^ (Util.of_some @@ Command_line.get "basis")
  in
  let nuclei_file =
    qcmath_mol ^ (Util.of_some @@ Command_line.get "xyz") ^ ".xyz"
  in
  let frozen_core = Command_line.get_bool "frozen-core" in

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

  let rydberg =
    match Command_line.get "rydberg" with
    | Some x -> int_of_string x
    | None -> 0
  in

  let range_separation = 
    match Command_line.get "range-separation" with
    | None -> None
    | Some mu -> Some (float_of_string mu) 
  in


  let nuclei = 
    Qcaml.Particles.Nuclei.of_xyz_file nuclei_file
  in

  let electrons =
    Qcaml.Particles.Electrons.of_atoms ~multiplicity ~charge nuclei
  in

  let basis = 
    Qcaml.Gaussian.Basis.of_nuclei_and_basis_filename ~nuclei basis_file
  in


  let print_basis nuclei basis =
    let oc = open_out qcmath_basis_filename in
    let ocf = Format.formatter_of_out_channel oc in
    let g_basis = Qcaml.Gaussian.Basis.general_basis basis in
    let dict = 
      Array.to_list nuclei
      |> List.mapi (fun i (e, _) ->
            (i+1), List.assoc e g_basis
          ) 
    in
    List.iter (fun (i,b) ->
      Format.fprintf ocf "%d  %d\n" i (Array.length b);
      Array.iter (fun x ->
          Format.fprintf ocf "%a" Qcaml.Gaussian.General_basis.pp_gcs x) b
      ) dict;
    close_out oc
  in
  print_basis nuclei basis;


  let print_molecule nuclei electrons =
    let oc = open_out qcmath_molecule_filename in
    let nat  = Array.length nuclei in
    let nela = Qcaml.Particles.Electrons.n_alfa electrons in
    let nelb = Qcaml.Particles.Electrons.n_beta electrons in
    let ncore = 
      if frozen_core then
        Qcaml.Particles.Nuclei.small_core nuclei 
      else 0
    in
    let nryd = rydberg in
    Printf.fprintf oc "# nAt nEla nElb nCore nRyd\n";
    Printf.fprintf oc " %4d %4d %4d %5d %4d\n" nat nela nelb ncore nryd;
    Printf.fprintf oc "# Znuc   x            y           z\n";
    let open Qcaml.Common.Coordinate in
    Array.iter (fun (element, coord) ->
      Printf.fprintf oc "%3s    %16.10f     %16.10f     %16.10f\n"
          (Qcaml.Particles.Element.to_string element)
          coord.x coord.y coord.z
        ) nuclei;
    close_out oc
  in    
  print_molecule nuclei electrons;

  let operators =
    match range_separation with
    | None -> []
    | Some mu -> [ Qcaml.Operators.Operator.of_range_separation mu ]
  in

  let ao_basis =
    Qcaml.Ao.Basis.of_nuclei_and_basis_filename ~kind:`Gaussian
      ~operators ~cartesian:true ~nuclei basis_file
  in

  let overlap   = Qcaml.Ao.Basis.overlap   ao_basis in
  let eN_ints   = Qcaml.Ao.Basis.eN_ints   ao_basis in
  let kin_ints  = Qcaml.Ao.Basis.kin_ints  ao_basis in
  let multipole = Qcaml.Ao.Basis.multipole ao_basis in
  let x_mat     = multipole "x" in
  let y_mat     = multipole "y" in
  let z_mat     = multipole "z" in

  let ee_ints   = Qcaml.Ao.Basis.ee_ints   ao_basis in
  let lr_ints   =
    match range_separation with                                                               
    | Some _mu -> Some (Qcaml.Ao.Basis.ee_lr_ints ao_basis)
    | None -> None
  in

  Matrix.to_file ~sym:true ~filename:(qcmath_dir ^ "/int/Ov.dat") overlap;
  Matrix.to_file ~sym:true ~filename:(qcmath_dir ^ "/int/Nuc.dat") eN_ints;
  Matrix.to_file ~sym:true ~filename:(qcmath_dir ^ "/int/Kin.dat") kin_ints;
  Matrix.to_file ~sym:true ~filename:(qcmath_dir ^ "/int/x.dat") x_mat;
  Matrix.to_file ~sym:true ~filename:(qcmath_dir ^ "/int/y.dat") y_mat;
  Matrix.to_file ~sym:true ~filename:(qcmath_dir ^ "/int/z.dat") z_mat;

  Four_idx_storage.to_file ~filename:(qcmath_dir ^ "/int/ERI.dat") ee_ints;

  match lr_ints with
  | Some integrals -> Four_idx_storage.to_file ~filename:"/int/ERI_lr.dat" integrals;
  | None -> ()
  ;
  
  Unix.execv (qcmath_dir ^ "/bin/qcmath") [| "qcmath" |]




