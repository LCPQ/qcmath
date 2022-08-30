open Linear_algebra
open Common

type ao = Ao.Ao_dim.t

type t =
  {
    fock     : (ao,ao) Matrix.t ;
    core     : (ao,ao) Matrix.t ;
    coulomb  : (ao,ao) Matrix.t ;
    exchange : (ao,ao) Matrix.t ;
  }


let fock t = t.fock
let core t = t.core
let coulomb t = t.coulomb
let exchange t = t.exchange


let make_rhf ~density ?(threshold=Constants.epsilon) ao_basis =
  let m_P  = density
  and m_T  = Ao.Basis.kin_ints ao_basis
  and m_V  = Ao.Basis.eN_ints  ao_basis
  and m_G  = Ao.Basis.ee_ints  ao_basis 
  in
  let nBas = Matrix.dim1 m_T
  in

  let m_Hc = Matrix.add m_T m_V 
  and m_J = Array.make_matrix nBas nBas 0.
  and m_K = Array.make_matrix nBas nBas 0.
  in

  for sigma = 1 to nBas do
    let m_Ksigma = m_K.(sigma-1) in
    for nu = 1 to nBas do
      let m_Jnu = m_J.(nu-1) in
      for lambda = 1 to nBas do
        let pJ = m_P%:(lambda,sigma)
        and pK = 0.5 *. (m_P%:(lambda,nu))
        in
        match (abs_float pJ > threshold , abs_float pK > threshold, nu < sigma) with
        | (false, false, _) -> ()
        | (true , true , true) ->
            begin
              for mu = 1 to nu do
                let integral = 
                  Four_idx_storage.get_phys m_G mu lambda nu sigma
                in
                if (integral <> 0.) then begin
                  m_Jnu.(mu-1) <- m_Jnu.(mu-1) +.  pJ *. integral;
                  m_Ksigma.(mu-1) <- m_Ksigma.(mu-1) +. pK *. integral
                end
              done;
              for mu = nu+1 to sigma do
                m_Ksigma.(mu-1) <- m_Ksigma.(mu-1) +.
                                   pK *. Four_idx_storage.get_phys m_G mu lambda nu sigma
              done
            end
        | (true , true , false) ->
            begin
              for mu = 1 to sigma do
                let integral = 
                  Four_idx_storage.get_phys m_G mu lambda nu sigma
                in
                if (integral <> 0.) then begin
                  m_Jnu.(mu-1) <- m_Jnu.(mu-1) +.  pJ *. integral;
                  m_Ksigma.(mu-1) <- m_Ksigma.(mu-1) +. pK *. integral
                end
              done;
              for mu = sigma+1 to nu do
                m_Jnu.(mu-1) <-
                  m_Jnu.(mu-1) +. pJ *. Four_idx_storage.get_phys m_G mu lambda nu sigma
              done
            end
        | (false, true , _) ->
            for mu = 1 to sigma do
              m_Ksigma.(mu-1) <-
                m_Ksigma.(mu-1) +. pK *. Four_idx_storage.get_phys m_G mu lambda nu sigma
            done
        | (true , false, _) ->
            for mu = 1 to nu do
              m_Jnu.(mu-1) <-
                m_Jnu.(mu-1) +. pJ *. Four_idx_storage.get_phys m_G mu lambda nu sigma
            done
      done
    done;
    for mu = 1 to sigma-1 do
      m_K.(mu-1).(sigma-1) <- m_Ksigma.(mu-1);
    done
  done;
  for nu = 1 to nBas do
    let m_Jnu = m_J.(nu-1) in
    for mu = 1 to nu-1 do
      m_J.(mu-1).(nu-1) <- m_Jnu.(mu-1)
    done
  done;

  let m_J = Matrix.of_array m_J
  and m_K = Matrix.of_array m_K
  in
  { fock = Matrix.add m_Hc (Matrix.sub m_J m_K) ;
    core = m_Hc ; coulomb = m_J ; exchange = m_K }



let make_uhf ~density_same ~density_other ?(threshold=Constants.epsilon) ao_basis =
  let m_P_a  = density_same
  and m_P_b  = density_other
  and m_T  = Ao.Basis.kin_ints ao_basis
  and m_V  = Ao.Basis.eN_ints  ao_basis
  and m_G  = Ao.Basis.ee_ints  ao_basis 
  in
  let nBas = Matrix.dim1 m_T
  in

  let m_Hc = Matrix.add m_T m_V 
  and m_J = Array.make_matrix nBas nBas 0.
  and m_K = Array.make_matrix nBas nBas 0.
  in

  for sigma = 1 to nBas do
    let m_Ksigma = m_K.(sigma-1) in
    for nu = 1 to nBas do
      let m_Jnu = m_J.(nu-1) in
      for lambda = 1 to nBas do
        let pJ = m_P_a%:(lambda,sigma) +. m_P_b%:(lambda,sigma)
        and pK = m_P_a%:(lambda,nu)
        in
        match (abs_float pJ > threshold , abs_float pK > threshold, nu < sigma) with
        | (false, false, _) -> ()
        | (true , true , true) ->
            begin
              for mu = 1 to nu do
                let integral = 
                  Four_idx_storage.get_phys m_G mu lambda nu sigma
                in
                if (integral <> 0.) then begin
                  m_Jnu.(mu-1) <- m_Jnu.(mu-1) +.  pJ *. integral;
                  m_Ksigma.(mu-1) <- m_Ksigma.(mu-1) +. pK *. integral
                end
              done;
              for mu = nu+1 to sigma do
                m_Ksigma.(mu-1) <- m_Ksigma.(mu-1) +.
                                   pK *.Four_idx_storage.get_phys m_G mu lambda nu sigma
              done
            end
        | (true , true , false) ->
            begin
              for mu = 1 to sigma do
                let integral = 
                  Four_idx_storage.get_phys m_G mu lambda nu sigma
                in
                if (integral <> 0.) then begin
                  m_Jnu.(mu-1) <- m_Jnu.(mu-1) +.  pJ *. integral;
                  m_Ksigma.(mu-1) <- m_Ksigma.(mu-1) +. pK *. integral
                end
              done;
              for mu = sigma+1 to nu do
                m_Jnu.(mu-1) <-
                  m_Jnu.(mu-1) +. pJ *. Four_idx_storage.get_phys m_G mu lambda nu sigma
              done
            end
        | (false, true , _) ->
            for mu = 1 to sigma do
              m_Ksigma.(mu-1) <-
                m_Ksigma.(mu-1) +. pK *. Four_idx_storage.get_phys m_G mu lambda nu sigma
            done
        | (true , false, _) ->
            for mu = 1 to nu do
              m_Jnu.(mu-1) <-
                m_Jnu.(mu-1) +. pJ *. Four_idx_storage.get_phys m_G mu lambda nu sigma
            done
      done
    done;
    for mu = 1 to sigma-1 do
      m_K.(mu-1).(sigma-1) <- m_Ksigma.(mu-1);
    done
  done;
  for nu = 1 to nBas do
    let m_Jnu = m_J.(nu-1) in
    for mu = 1 to nu-1 do
      m_J.(mu-1).(nu-1) <- m_Jnu.(mu-1)
    done
  done;
  
  let m_J = Matrix.of_array m_J
  and m_K = Matrix.of_array m_K
  in
  { fock = Matrix.add m_Hc (Matrix.sub m_J m_K) ;
    core = m_Hc ; coulomb = m_J ; exchange = m_K }







let op ~f f1 f2 =
  assert (f1.core = f2.core);
  let m_Hc = f1.core
  and m_J = f f1.coulomb f2.coulomb
  and m_K = f f1.exchange f2.exchange
  in
  {
    fock     = Matrix.add m_Hc (Matrix.sub m_J m_K);
    core     = m_Hc;
    coulomb  = m_J;
    exchange = m_K;
  }


let add = op ~f:(fun a b -> Matrix.add a b)

let sub = op ~f:(fun a b -> Matrix.sub a b)

let scale alpha f1 = 
  let m_Hc = f1.core
  and m_J = Matrix.copy f1.coulomb 
  and m_K = Matrix.copy f1.exchange 
  in
  Matrix.scale_inplace alpha m_J;
  Matrix.scale_inplace alpha m_K;
  {
    fock     = Matrix.add m_Hc (Matrix.sub m_J m_K);
    core     = m_Hc;
    coulomb  = m_J;
    exchange = m_K;
  }



let pp ppf a =
  Format.fprintf ppf "@[<2>";
  Format.fprintf ppf "@[ Fock matrix:@[<2>@[%a@]@.]@]" Matrix.pp a.fock;
  Format.fprintf ppf "@[ Core Hamiltonian:@[<2>@[%a@]@.]@]" Matrix.pp a.core;
  Format.fprintf ppf "@[ Coulomb matrix:@[<2>@[%a@]@.]@]" Matrix.pp a.coulomb;
  Format.fprintf ppf "@[ Exchange matrix:@[<2>@[%a@]@.]@]" Matrix.pp a.exchange;
  Format.fprintf ppf "@]"
