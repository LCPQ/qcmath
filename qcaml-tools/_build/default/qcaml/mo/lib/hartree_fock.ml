open Linear_algebra
open Particles
open Common

type ao = Ao.Ao_dim.t
type mo = Mo_dim.t

type hartree_fock_data =
  {
    iteration       :  int ;
    coefficients    :  (ao, mo) Matrix.t   option  ;
    eigenvalues     :  mo Vector.t option   ;
    error           :  float       option   ;
    diis            :  (mo*mo) Diis.t   option     ;
    energy          :  float       option   ;
    density         :  (ao,ao) Matrix.t   option   ;
    density_a       :  (ao,ao) Matrix.t   option   ;
    density_b       :  (ao,ao) Matrix.t   option   ;
    fock            :  Fock.t  option   ;
    fock_a          :  Fock.t  option   ;
    fock_b          :  Fock.t  option   ;
  }

and hartree_fock_kind  =
| RHF  (** Restricted Hartree-Fock *)
| ROHF (** Restricted Open-shell Hartree-Fock *)
| UHF  (** Unrestricted Hartree-Fock *)

and t =
  {
    kind              : hartree_fock_kind;
    simulation        : Simulation.t;
    guess             : Guess.t;
    data              : hartree_fock_data option lazy_t array;
    nocc              : int   ;
  }


let empty = 
  { 
    iteration       =  0                ; 
    coefficients    =  None             ; 
    eigenvalues     =  None             ; 
    error           =  None             ; 
    diis            =  None             ; 
    energy          =  None             ; 
    density         =  None             ; 
    density_a       =  None             ; 
    density_b       =  None             ; 
    fock            =  None             ; 
    fock_a          =  None             ; 
    fock_b          =  None             ; 
  } 






module Si = Simulation
module El = Electrons


let  kind               t  =  t.kind
let  simulation         t  =  t.simulation
let  guess              t  =  t.guess
let  nocc               t  =  t.nocc



let n_iterations t =
  Array.fold_left (fun accu x ->
    match Lazy.force x with
    | Some _ -> accu + 1
    | None -> accu
    ) 0 t.data


let last_iteration t =
  Util.of_some @@ Lazy.force t.data.(n_iterations t - 1)

let eigenvectors t =
  let data = last_iteration t in
  Util.of_some data.coefficients

let eigenvalues t =
  let data = last_iteration t in
  Util.of_some data.eigenvalues

let density t =
  let data = last_iteration t in
  match kind t with
  | RHF  -> Util.of_some data.density
  | ROHF -> Matrix.add (Util.of_some data.density_a) (Util.of_some data.density_b)
  | _    -> failwith "Not implemented"

let occupation t =
  let n_alfa, n_beta =
    El.n_alfa @@ Simulation.electrons @@ simulation t,
    El.n_beta @@ Simulation.electrons @@ simulation t
  in
  match kind t with
  | RHF  -> Vector.init (Matrix.dim2 @@ eigenvectors t) (fun i ->
                if i <= nocc t then 2.0 else 0.0)
  | ROHF ->  Vector.init (Matrix.dim2 @@ eigenvectors t) (fun i ->
                 if i <= n_beta then 2.0 else
                 if i <= n_alfa then 1.0 else
                 0.0)
  | _    -> failwith "Not implemented"


let energy t = 
  let data = last_iteration t in
  Util.of_some data.energy


let nuclear_repulsion t =
  Si.nuclear_repulsion (simulation t)


let ao_basis t =
  Si.ao_basis (simulation t)


let kin_energy t =
  let m_T    =
    ao_basis t
    |> Ao.Basis.kin_ints 
  in
  let m_P = density t in
  Matrix.gemm_trace m_P m_T


let eN_energy t =
  let m_V =
    ao_basis t
    |> Ao.Basis.eN_ints 
  in
  let m_P = density t in
  Matrix.gemm_trace m_P m_V


let coulomb_energy t =
  let data =
    last_iteration t
  in
  match kind t with
  | RHF ->  let  m_P   =  Util.of_some    data.density  in
            let  fock  =  Util.of_some    data.fock     in
            let  m_J   =  Fock.coulomb    fock          in
            0.5 *. Matrix.gemm_trace m_P m_J

  | ROHF -> let  m_P_a  =  Util.of_some    data.density_a in
            let  m_P_b  =  Util.of_some    data.density_b in
            let  fock_a =  Util.of_some    data.fock_a    in
            let  fock_b =  Util.of_some    data.fock_b    in
            let  m_J_a  =  Fock.coulomb    fock_a         in
            let  m_J_b  =  Fock.coulomb    fock_b         in
            0.5 *. ( (Matrix.gemm_trace m_P_a m_J_a) +. (Matrix.gemm_trace m_P_b m_J_b) )

  | _    -> failwith "Not implemented"


let exchange_energy t = 
  let data =
    last_iteration t
  in
  match kind t with
  | RHF ->  let  m_P   =  Util.of_some  data.density  in
            let  fock  =  Util.of_some  data.fock     in
            let  m_K   =  Fock.exchange fock          in
            -. 0.5 *. Matrix.gemm_trace m_P m_K

  | ROHF -> let  m_P_a  =  Util.of_some   data.density_a in
            let  m_P_b  =  Util.of_some   data.density_b in
            let  fock_a =  Util.of_some   data.fock_a    in
            let  fock_b =  Util.of_some   data.fock_b    in
            let  m_K_a  =  Fock.exchange  fock_a         in
            let  m_K_b  =  Fock.exchange  fock_b         in
            -. 0.5 *. ( (Matrix.gemm_trace m_P_a m_K_a) +. (Matrix.gemm_trace m_P_b m_K_b) )

  | _    -> failwith "Not implemented"






let make
    ?kind
    ?guess:(guess=`Huckel)
    ?max_scf:(max_scf=64)
    ?level_shift:(level_shift=0.2)
    ?threshold_SCF:(threshold_SCF=1.e-8)
    simulation = 


  (* Number of occupied MOs *)
  let n_alfa, n_beta =
    El.n_alfa @@ Si.electrons simulation,
    El.n_beta @@ Si.electrons simulation
  in

  let nocc = n_alfa in

  let kind = 
    match kind with
    | Some kind -> kind
    | None -> if (n_alfa = n_beta) then RHF else ROHF
  in

  let nuclear_repulsion = 
    Si.nuclear_repulsion simulation
  in

  let ao_basis = 
    Si.ao_basis simulation
  in


  (* Orthogonalization matrix *)
  let m_X = 
    Ao.Basis.ortho ao_basis
  in

  (* Overlap matrix *)
  let m_S =
    Ao.Basis.overlap ao_basis
  in

  (* Level shift in MO basis *)
  let m_LSmo =
    Array.init (Matrix.dim2 m_X) (fun i ->
        if i > nocc then level_shift else 0.)
    |> Vector.of_array
    |> Matrix.of_diag
  in

  (* Guess coefficients *)
  let guess =
    Guess.make ~nocc ~guess ao_basis
  in

  let m_C : (ao,mo) Matrix.t = 
    let c_of_h m_H = 
      let m_Hmo   = Matrix.xt_o_x  ~o:m_H  ~x:m_X in
      let m_C', _ = Matrix.diagonalize_symm  m_Hmo in
      Matrix.gemm_nn  m_X  m_C'
    in
    match guess with
      | Guess.Hcore  m_H -> c_of_h m_H
      | Guess.Huckel m_H -> c_of_h m_H
      | Guess.Matrix m_C -> m_C 
  in

  (* A single SCF iteration *)
  let scf_iteration_rhf data =

    let  nSCF         =  data.iteration + 1
    and  m_C          =  Util.of_some data.coefficients
    and  m_P_prev     =  data.density
    and  fock_prev    =  data.fock
    and  diis         =  
      match data.diis with
      | Some diis -> diis
      | None      -> Diis.make ()
    and  threshold    =  
      match data.error with
      | Some error -> error
      | None       -> threshold_SCF *. 2.
    in

    (* Density matrix over nocc occupied MOs *)
    let m_P =
      Matrix.gemm_nt  ~alpha:2.  ~k:nocc  m_C  m_C
    in

    (* Fock matrix in AO basis *)
    let fock = 
      match fock_prev, m_P_prev, threshold > 100. *. threshold_SCF with
      | Some fock_prev, Some m_P_prev, true -> 
        let threshold = 1.e-8 in
        Fock.make_rhf  ~density:(Matrix.sub m_P m_P_prev) ~threshold ao_basis
        |> Fock.add fock_prev
      | _ -> Fock.make_rhf  ~density:m_P ao_basis
    in

    let m_F0, m_Hc, _, _ =
      let x = fock in
      Fock.(fock x, core x, coulomb x, exchange x)
    in

    (* Add level shift in AO basis *)
    let m_F =
      let m_SC =
        Matrix.gemm_nn m_S m_C
      in
      Matrix.gemm_nn m_SC (Matrix.gemm_nt m_LSmo m_SC)
      |> Matrix.add m_F0
    in


    (* Fock matrix in orthogonal basis *)
    let m_F_ortho =
      Matrix.xt_o_x ~o:m_F ~x:m_X
    in

    let error_fock = 
      let fps =
        Matrix.gemm_nn  m_F  (Matrix.gemm_nn  m_P  m_S)
      and spf =
        Matrix.gemm_nn  m_S  (Matrix.gemm_nn  m_P  m_F)
      in
      Matrix.xt_o_x  ~o:(Matrix.sub  fps  spf)  ~x:m_X
    in

    let diis, m_F_diis = 
      let diis =
        Diis.append
          ~p:(Matrix.as_vec_inplace m_F_ortho)
          ~e:(Matrix.as_vec_inplace error_fock) diis
      in

      try
        let m_F_diis =
          Diis.next diis
          |> Matrix.reshape_vec_inplace (Matrix.dim1 m_F_ortho) (Matrix.dim2 m_F_ortho)
        in
        diis, m_F_diis

      with Failure _ -> (* Failure in DIIS.next *)
        Diis.make (), m_F_ortho
    in
    let diis = 
      Diis.append
        ~p:(Matrix.as_vec_inplace m_F_ortho)
        ~e:(Matrix.as_vec_inplace error_fock) diis
    in


    (* MOs in orthogonal MO basis *)
    let m_C', _ =
      Matrix.diagonalize_symm  m_F_diis
    in

    (* Re-compute eigenvalues to remove level-shift *)
    let eigenvalues = 
      let m_F_ortho =
        Matrix.xt_o_x ~o:m_F0 ~x:m_X
      in
      Matrix.xt_o_x ~o:m_F_ortho ~x:m_C'
      |> Matrix.diag 
    in

    (* MOs in AO basis *)
    let m_C =
      Matrix.gemm_nn  m_X  m_C'
      |> Conventions.rephase
    in

    (* Hartree-Fock energy *)
    let energy =
      nuclear_repulsion +. 0.5 *.
                           Matrix.gemm_trace  m_P  (Matrix.add  m_Hc  m_F)
    in

    (* Convergence criterion *)
    let error =
      error_fock 
      |> Matrix.amax
      |> abs_float
    in

    { empty with
      iteration      = nSCF              ;
      eigenvalues    = Some eigenvalues  ;
      coefficients   = Some m_C          ;
      error          = Some error        ;
      diis           = Some diis         ;
      energy         = Some energy       ;
      density        = Some m_P          ;
      fock           = Some fock         ;
    }

  in

  let scf_iteration_rohf data = 

    let  nSCF         =  data.iteration + 1
    and  m_C          =  Util.of_some data.coefficients
    and  m_P_a_prev   =  data.density_a
    and  m_P_b_prev   =  data.density_b
    and  fock_a_prev  =  data.fock_a
    and  fock_b_prev  =  data.fock_b
    and  diis         =  
      match data.diis with
      | Some diis -> diis
      | None      -> Diis.make ()
    and  threshold    =  
      match data.error with
      | Some error -> error
      | None       -> threshold_SCF *. 2.
    in
    
    (* Density matrix *)
    let m_P_a =
      Matrix.gemm_nt  ~alpha:1.  ~k:n_alfa  m_C  m_C
    in

    let m_P_b =
      Matrix.gemm_nt  ~alpha:1.  ~k:n_beta  m_C  m_C
    in

    let m_P =
      Matrix.add m_P_a m_P_b
    in

    (* Fock matrix in AO basis *)
    let fock_a = 
      match fock_a_prev, threshold > 100. *. threshold_SCF with
      | Some fock_a_prev, true -> 
        let threshold = 1.e-8 in
        Fock.make_uhf  ~density_same:(Matrix.sub m_P_a @@ Util.of_some m_P_a_prev) ~density_other:(Matrix.sub m_P_b @@ Util.of_some m_P_b_prev) ~threshold ao_basis
        |> Fock.add fock_a_prev
      | _ -> Fock.make_uhf  ~density_same:m_P_a  ~density_other:m_P_b ao_basis
    in

    let fock_b = 
      match fock_b_prev, threshold > 100. *. threshold_SCF with
      | Some fock_b_prev, true -> 
        let threshold = 1.e-8 in
        Fock.make_uhf  ~density_same:(Matrix.sub m_P_b @@ Util.of_some m_P_b_prev) ~density_other:(Matrix.sub m_P_a @@ Util.of_some m_P_a_prev) ~threshold ao_basis
        |> Fock.add fock_b_prev
      | _ -> Fock.make_uhf  ~density_same:m_P_b  ~density_other:m_P_a ao_basis
    in

    let m_F_a, m_Hc_a, _, _ =
      let x = fock_a in
      Fock.(fock x, core x, coulomb x, exchange x)
    in

    let m_F_b, m_Hc_b, _, _ =
      let x = fock_b in
      Fock.(fock x, core x, coulomb x, exchange x)
    in


    let m_F_mo_a = 
      Matrix.xt_o_x ~o:m_F_a ~x:m_C
    in

    let m_F_mo_b = 
      Matrix.xt_o_x ~o:m_F_b ~x:m_C
    in

    let m_F_mo  =
      let space k =
        if k <= n_beta then
          `Core
        else if k <= n_alfa then
          `Active
        else
          `Virtual
      in
      Array.init (Matrix.dim2 m_F_mo_a) (fun i ->
          let i = i+1 in
          Array.init (Matrix.dim1 m_F_mo_a) (fun j ->
              let j = j+1 in
              match (space i), (space j) with
              |  `Core     ,  `Core     ->  
                0.5 *. (m_F_mo_a%:(i,j) +. m_F_mo_b%:(i,j)) -.
                (m_F_mo_b%:(i,j) -. m_F_mo_a%:(i,j))

              |  `Active   ,  `Core
              |  `Core     ,  `Active   ->
                m_F_mo_b%:(i,j)

              |  `Core     ,  `Virtual
              |  `Virtual  ,  `Core     
              |  `Active   ,  `Active   ->
                0.5 *. (m_F_mo_a%:(i,j) +. m_F_mo_b%:(i,j))

              |  `Virtual  ,  `Active   
              |  `Active   ,  `Virtual  ->
                m_F_mo_a%:(i,j)

              |  `Virtual  ,  `Virtual  ->
                0.5 *. (m_F_mo_a%:(i,j) +. m_F_mo_b%:(i,j)) +.
                (m_F_mo_b%:(i,j) -. m_F_mo_a%:(i,j))
            ) )
      |> Matrix.of_array
    in

    let m_SC =
      Matrix.gemm_nn  m_S  m_C
    in

    let m_F0 = 
      Matrix.x_o_xt ~x:m_SC ~o:m_F_mo
    in


    (* Add level shift in AO basis *)
    let m_F =
      Matrix.x_o_xt ~x:m_SC ~o:m_LSmo
      |> Matrix.add m_F0
    in

    (* Fock matrix in orthogonal basis *)
    let m_F_ortho =
      Matrix.xt_o_x ~o:m_F ~x:m_X
    in

    let error_fock = 
      let fps =
        Matrix.gemm_nn  m_F  (Matrix.gemm_nn  m_P  m_S)
      and spf =
        Matrix.gemm_nn  m_S  (Matrix.gemm_nn  m_P  m_F)
      in
      Matrix.xt_o_x ~o:(Matrix.sub  fps  spf) ~x:m_X
    in

    let diis, m_F_diis = 
      let diis =
        Diis.append
          ~p:(Matrix.as_vec_inplace m_F_ortho)
          ~e:(Matrix.as_vec_inplace error_fock) diis
      in

      try
        let m_F_diis =
          Diis.next diis
          |> Matrix.reshape_vec_inplace (Matrix.dim1 m_F_ortho) (Matrix.dim2 m_F_ortho)
        in
        diis, m_F_diis

      with Failure _ -> (* Failure in DIIS.next *)
        Diis.make (), m_F_ortho
    in


    (* MOs in orthogonal MO basis *)
    let m_C', _ =
      Matrix.diagonalize_symm  m_F_diis
    in

    (* Re-compute eigenvalues to remove level-shift *)
    let eigenvalues = 
      let m_F_ortho =
        Matrix.xt_o_x ~o:m_F0 ~x:m_X
      in
      Matrix.xt_o_x ~o:m_F_ortho ~x:m_C'
      |> Matrix.diag 
    in

    (* MOs in AO basis *)
    let m_C =
      Matrix.gemm_nn  m_X  m_C'
      |> Conventions.rephase
    in

    (* Hartree-Fock energy *)
    let energy =
      nuclear_repulsion +.  0.5 *. ( Matrix.gemm_trace  m_P_a  (Matrix.add  m_Hc_a  m_F_a) +.
                                     Matrix.gemm_trace  m_P_b  (Matrix.add  m_Hc_b  m_F_b) )
    in

    (* Convergence criterion *)
    let error =
      error_fock 
      |> Matrix.amax
      |> abs_float
    in
    { empty with
      iteration      = nSCF              ;
      eigenvalues    = Some eigenvalues  ;
      coefficients   = Some m_C          ;
      error          = Some error        ;
      diis           = Some diis         ;
      energy         = Some energy       ;
      density_a      = Some m_P_a        ;
      density_b      = Some m_P_b        ;
      fock_a         = Some fock_a       ;
      fock_b         = Some fock_b       ;
    }

  in


  let scf_iteration data =
    match kind with
    | RHF  -> scf_iteration_rhf data
    | ROHF -> scf_iteration_rohf data
    | _    -> failwith "Not implemented"
  in

  let array_data =
      
    let storage =
      Array.make max_scf None
    in

    let rec iteration = function
      | 0 -> Some (scf_iteration { empty with coefficients = Some m_C })
      | n -> begin
          match storage.(n) with
          | Some result -> Some result
          | None ->
            begin
              let data = iteration (n-1) in
              match data with
              | None -> None
              | Some data -> 
                begin
                  (* Check convergence *)
                  let converged, _error =
                    match data.error with
                    | None -> false, 0.
                    | Some error -> (data.iteration = max_scf || error < threshold_SCF), error
                  in
                  if converged then
                    None
                  else
                    begin
                      storage.(n-1) <- Some { empty with
                                              iteration   = data.iteration;
                                              energy      = data.energy ;
                                              eigenvalues = data.eigenvalues ;
                                              error       = data.error ;
                                            };
                      storage.(n) <- Some (scf_iteration data);
                      storage.(n);
                    end
                end
            end
        end
    in
    Array.init max_scf (fun i -> lazy (iteration i))
  in
  { 
      kind;
      simulation;
      guess ;
      data = array_data;
      nocc;
  }










let linewidth = 60

let pp_iterations ppf t =
  let line = (String.make linewidth '-') in
  Format.fprintf ppf "@[%4s%s@]@." "" line;
  Format.fprintf ppf "@[%4s@[%5s@]@,@[%16s@]@,@[%16s@]@,@[%11s@]@]@." 
                      ""    "#" "HF energy  " "Convergence" "HOMO-LUMO";
  Format.fprintf ppf "@[%4s%s@]@." "" line;
  let nocc = nocc t in
  Array.iter (fun data ->
    let data = Lazy.force data in
    match data with
    | None -> ()
    | Some data ->
      let e = Util.of_some data.eigenvalues in
      let gap = e%.(nocc+1) -. e%.(nocc) in
      begin
        Format.fprintf ppf "@[%4s@[%5d@]@,@[%16.8f@]@,@[%16.4e@]@,@[%11.4f@]@]@." ""
          (data.iteration) (Util.of_some data.energy) (Util.of_some data.error) gap;
      end
    ) t.data;
  Format.fprintf ppf "@[%4s%s@]@." "" line


let pp_summary ppf t =
  let print text value = 
    Format.fprintf ppf "@[@[%30s@]@,@[%16.10f@]@]@;" text value;
  and line () = 
    Format.fprintf ppf "@[  %s  @]@;" (String.make (linewidth-4) '-');
  in
  let ha_to_ev = Constants.ha_to_ev in
  let e = eigenvalues t in

  Format.fprintf ppf "@[%s@]@;" (String.make linewidth '=')
  ; Format.fprintf ppf "@[<v>"
  ; print "One-electron energy" (kin_energy t +. eN_energy t) 
  ; print "Kinetic"   (kin_energy t) 
  ; print "Potential" (eN_energy  t) 
  ; line () 
  ; print "Two-electron energy" (coulomb_energy t +. exchange_energy t) 
  ; print "Coulomb"  (coulomb_energy  t) 
  ; print "Exchange" (exchange_energy t) 
  ; line ()
  ; print "HF HOMO" (ha_to_ev *. (e%.(nocc t)))
  ; print "HF LUMO" (ha_to_ev *. (e%.(nocc t + 1)))
  ; print "HF LUMO-LUMO" (ha_to_ev *. (e%.(nocc t + 1) -. e%.(nocc t)))
  ; line ()
  ; print "Electronic   energy" (energy t -. nuclear_repulsion t) 
  ; print "Nuclear   repulsion" (nuclear_repulsion t) 
  ; print "Hartree-Fock energy" (energy t) 
  ; Format.fprintf ppf "@]"
  ; Format.fprintf ppf "@[%s@]@;" (String.make linewidth '=')




let pp ppf t =
  Format.fprintf ppf "@.@[%s@]@." (String.make 70 '=');
  Format.fprintf ppf "@[%34s %-34s@]@." (match t.kind with
  | UHF  -> "Unrestricted"
  | RHF  -> "Restricted"
  | ROHF -> "Restricted Open-shell") "Hartree-Fock";
  Format.fprintf ppf "@[%s@]@.@." (String.make 70 '=');
  Format.fprintf ppf "@[%a@]@." pp_iterations t;
  Format.fprintf ppf "@[<v 4>@;%a@]@." pp_summary    t
