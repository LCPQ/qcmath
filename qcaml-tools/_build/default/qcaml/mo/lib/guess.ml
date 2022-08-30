open Linear_algebra

type ao = Ao.Ao_dim.t
type mo = Mo_dim.t

type guess =
| Hcore  of (ao,ao) Matrix.t
| Huckel of (ao,ao) Matrix.t
| Matrix of (ao,mo) Matrix.t

type t = guess

module El = Particles.Electrons

let hcore_guess ao_basis = 
  let eN_ints  = Ao.Basis.eN_ints  ao_basis
  and kin_ints = Ao.Basis.kin_ints ao_basis
  in
  Matrix.add eN_ints kin_ints


let huckel_guess ao_basis =
  let c = 0.5 *. 1.75 in
  let eN_ints  = Ao.Basis.eN_ints  ao_basis
  and kin_ints = Ao.Basis.kin_ints ao_basis
  in
  let m_F = Matrix.add eN_ints kin_ints in
  let ao_num   = Ao.Basis.size     ao_basis
  and overlap  = Ao.Basis.overlap  ao_basis
  in
  let diag = Vector.init ao_num (fun i -> m_F%:(i,i) ) in

  function 
  | 0 -> invalid_arg "Huckel guess needs a non-zero number of occupied MOs."
  | _nocc -> 
      Matrix.init_cols ao_num ao_num (fun i j ->
        if (i<>j) then
          c *. (overlap%:(i,j)) /. ((overlap%:(i,i)) *. (overlap%:(j,j)) )  *. (diag%.(i) +. diag%.(j)) 
        else
          diag%.(i) 
    )


let make ?(nocc=0) ~guess ao_basis = 
  match guess with
  | `Hcore  -> Hcore  (hcore_guess  ao_basis)
  | `Huckel -> Huckel (huckel_guess ao_basis nocc)
  | `Matrix m -> Matrix m



