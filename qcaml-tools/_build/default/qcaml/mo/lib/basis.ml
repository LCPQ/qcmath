open Linear_algebra

(** One-electron orthogonal basis set, corresponding to Molecular Orbitals. *)

module HF = Hartree_fock
module Si = Simulation

type ao = Ao.Ao_dim.t
type mo = Mo_dim.t

type mo_type =
  | RHF | ROHF | UHF | CASSCF | Projected
  | Natural of string
  | Localized of string

type t =
  {
    simulation      : Simulation.t;      (* Simulation which produced the MOs *)
    mo_type         : mo_type;           (* Kind of MOs (RHF, CASSCF, Localized...) *)
    mo_occupation   : mo Vector.t;       (* Occupation numbers *)
    mo_coef         : (ao,mo) Matrix.t;  (* Matrix of the MO coefficients in the AO basis *)
    eN_ints         : (mo,mo) Matrix.t lazy_t;      (* Electron-nucleus potential integrals *)
    ee_ints         : mo Four_idx_storage.t lazy_t; (* Electron-electron potential integrals *)
    kin_ints        : (mo,mo) Matrix.t lazy_t;      (* Kinetic energy integrals *)
    one_e_ints      : (mo,mo) Matrix.t lazy_t;      (* One-electron integrals *)
    (* TODO 
    f12_ints        : F12.t lazy_t;      (* F12 integrals *)
    *)
  }


let size t =
  Matrix.dim2 t.mo_coef

let simulation    t = t.simulation
let mo_type       t = t.mo_type
let ao_basis      t = Si.ao_basis t.simulation
let mo_occupation t = t.mo_occupation
let mo_coef       t = t.mo_coef
let eN_ints       t = Lazy.force t.eN_ints
let ee_ints       t = Lazy.force t.ee_ints
let kin_ints      t = Lazy.force t.kin_ints
let two_e_ints    t = Lazy.force t.ee_ints
(* TODO
let f12_ints      t = Lazy.force t.f12_ints
*)
let one_e_ints    t = Lazy.force t.one_e_ints


let mo_energies t =
  let m_C = mo_coef t in
  let f =
    let m_N = Matrix.of_diag @@ mo_occupation t in
    let m_P = Matrix.x_o_xt ~o:m_N ~x:m_C in
    match t.mo_type with
    | RHF  -> Fock.make_rhf  ~density:m_P (ao_basis t)
    | Projected
    | ROHF -> (Matrix.scale_inplace 0.5 m_P;
               Fock.make_uhf  ~density_same:m_P ~density_other:m_P (ao_basis t))
    | _ -> failwith "Not implemented"
  in
  let m_F0 = Fock.fock f in
  Matrix.xt_o_x ~o:m_F0 ~x:m_C
  |> Matrix.diag


let mo_matrix_of_ao_matrix ~mo_coef ao_matrix =
  Matrix.xt_o_x ~x:mo_coef ~o:ao_matrix


let ao_matrix_of_mo_matrix ~mo_coef ~ao_overlap mo_matrix =
  let sc = Matrix.gemm ao_overlap mo_coef  in
  Matrix.x_o_xt ~x:sc ~o:mo_matrix


let make ~simulation ~mo_type ~mo_occupation ~mo_coef ()  =
  let ao_basis =
    Si.ao_basis simulation
  in
  let eN_ints = lazy (
    Ao.Basis.eN_ints ao_basis
    |> mo_matrix_of_ao_matrix ~mo_coef
  )
  and kin_ints = lazy (
    Ao.Basis.kin_ints ao_basis
    |> mo_matrix_of_ao_matrix ~mo_coef
  )
  and ee_ints = lazy (
    Ao.Basis.ee_ints ao_basis
    |> Four_idx_storage.four_index_transform mo_coef
  )
(*
  and f12_ints = lazy (
    Ao.Basis.f12_ints ao_basis
    |> F12.four_index_transform mo_coef
  )
*)
  in
  let one_e_ints = lazy (
    Matrix.add (Lazy.force eN_ints) (Lazy.force kin_ints) )
  in
  { simulation ; mo_type ; mo_occupation ; mo_coef ;
    eN_ints ; ee_ints ; kin_ints ; one_e_ints ;
  }


let values t point =
  let c = mo_coef t in
  let a = Ao.Basis.values (Simulation.ao_basis t.simulation) point in
  Matrix.gemv_t c a


let of_hartree_fock hf =
  let mo_coef       = HF.eigenvectors hf in
  let simulation    = HF.simulation   hf in
  let mo_occupation = HF.occupation   hf in
  let mo_type =
    match HF.kind hf with
    | HF.RHF  -> RHF
    | HF.ROHF -> ROHF
    | HF.UHF  -> UHF
  in
  make ~simulation ~mo_type ~mo_occupation ~mo_coef ()

(*
let of_mo_basis simulation other =

  let mo_coef =
    let basis = Simulation.ao_basis simulation in
    let basis_other = ao_basis other in
    let m_S =
      Ao.Overlap.(of_basis_pair
        (Ao.Basis.ao_basis basis)
        (Ao.Basis.ao_basis basis_other) )
    in
    let m_X = Ao.Basis.ortho basis in
    (* Project other vectors in the current basis *)
    let m_C =
      gemm m_S @@ mo_coef other
    in
    (* Append dummy vectors to the input vectors *)
    let result =
      let vecs = Mat.to_col_vecs m_X in
      Array.iteri (fun i v -> if (i < Array.length vecs) then vecs.(i) <- v)
	(Mat.to_col_vecs m_C) ;
      Mat.of_col_vecs vecs
    in
    (* Gram-Schmidt Orthonormalization *)
    gemm m_X @@ (Util.qr_ortho @@ gemm ~transa:`T m_X result)
    |> Util.remove_epsilons
    |> Conventions.rephase
  in

  let mo_occupation =
    let occ = mo_occupation other in
    Vec.init (Mat.dim2 mo_coef) (fun i ->
      if (i <= Vec.dim occ) then occ.{i}
      else 0.)
  in
  make ~simulation ~mo_type:Projected ~mo_occupation ~mo_coef ()
*)





let pp ?(start=1) ?(finish=0) ppf t =
    let rows = Matrix.dim1 t.mo_coef
    and cols = Matrix.dim2 t.mo_coef
    in
    let finish =
      match finish with
      | 0 -> cols
      | x -> x
    in

    let rec aux first =

      if (first > finish) then ()
      else
        begin
          Format.fprintf ppf "@[<v>@[<v4>@[<h>%s@;" "Eigenvalues:";

          Array.iteri (fun i x ->
              if (i+1 >= first) && (i+1 <= first+4 ) then
                Format.fprintf ppf "%12f@ " x)
            (Vector.to_array @@ mo_energies t);

          Format.fprintf ppf "@]@;";
          Format.fprintf ppf "@[%a@]"
            (Lacaml.Io.pp_lfmat
              ~row_labels:
                (Array.init rows (fun i -> Printf.sprintf "%d  " (i + 1)))
              ~col_labels:
                (Array.init (min 5 (cols-first+1)) (fun i -> Printf.sprintf "-- %d --" (i + first) ))
              ~print_right:false
              ~print_foot:false
              () ) (Matrix.to_bigarray_inplace t.mo_coef
                    |> Lacaml.D.lacpy ~ac:first ~n:(min 5 (cols-first+1)) ) ;
          Format.fprintf ppf "@]@;@;@]";
          (aux [@tailcall]) (first+5)
        end
    in
    aux start
