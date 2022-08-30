type 'a t =
{
  p : 'a Vector.t list;
  e : 'a Vector.t list;
  m : int;
  mmax : int;
}

let make ?mmax:(mmax=15) () = 
  assert (mmax > 1);
  {
    p = [];
    e = [];
    m = 0 ;
    mmax;
   }


let append ~p ~e diis =
  let update v l =  
    if diis.m < diis.mmax then
      v :: l
    else
      match List.rev l with
      | [] -> assert false
      | _ :: rest -> v :: List.rev rest
  in
  { diis with
    p = update p diis.p;
    e = update e diis.e;
    m = min diis.mmax (diis.m+1);
  }


type nvec
type one
  
let next diis =
  let e = Matrix.of_col_vecs_list diis.e 
  and p = Matrix.of_col_vecs_list diis.p
  in
  let a =
    let rec aux m = 
      let a = Matrix.make (m+1) (m+1) 1. in
      let ax = Matrix.to_bigarray_inplace a in
      ax.{m+1,m+1} <- 0.;
      Matrix.gemm_tn_inplace ~c:a ~m ~n:m e e;
      if m > 1 && Matrix.sycon a > 1.e-14 then 
        (aux [@tailcall]) (m-1)
      else a
    in
    aux diis.m
  in
  let m = Matrix.dim1 a - 1 in
  let c : (nvec,one) Matrix.t = Matrix.make0 (m+1) 1 in
  let cx = Matrix.to_bigarray_inplace c in
  cx.{m+1,1} <- 1.;
  Matrix.sysv_inplace a ~b:c ;
  Matrix.gemm_nn ~k:m p c
  |> Matrix.as_vec_inplace
  |> Vector.relabel

(*
  |> Vector.relabel
   *)
    

