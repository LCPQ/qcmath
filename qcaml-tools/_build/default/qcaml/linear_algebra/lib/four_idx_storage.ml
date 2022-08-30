open Common

let max_index = 1 lsl 14

type index_pair = { first : int ; second : int }

type 'a storage_t = 
  | Dense  of ('a,'a) Matrix.t
  | Sparse of (int, float) Hashtbl.t

type 'a t =
  {
    size             : int ;
    two_index        : ('a,'a) Matrix.t;
    two_index_anti   : ('a,'a) Matrix.t;
    three_index      : ('a,'a) Matrix.t;
    three_index_anti : ('a,'a) Matrix.t;
    four_index       : 'a storage_t ;
  }

let relabel t =
  { size = t.size ;
    two_index = Matrix.relabel t.two_index ; 
    two_index_anti = Matrix.relabel t.two_index_anti ; 
    three_index = Matrix.relabel t.three_index ; 
    three_index_anti = Matrix.relabel t.three_index_anti ; 
    four_index = match t.four_index with
      | Dense x -> Dense (Matrix.relabel x)
      | Sparse x -> Sparse x
  }

let key_of_indices ~r1 ~r2 =
  let { first=i ; second=k } = r1 and { first=j ; second=l } = r2 in
  let f i k = 
    let p, r = 
      if i <= k then i, k else k, i
    in p + (r*(r-1))/2
  in
  let p = f i k and q = f j l in
  f p q


let check_bounds r1 r2 t =
  let { first=i ; second=k } = r1 and { first=j ; second=l } = r2 in 
  let size = t.size in
  assert ( (i lor j lor k lor l) > 0 );
  assert ( i <= size && j <= size && k <= size && l <= size )


let dense_index i j size =
  (j-1)*size + i


let sym_index i j =
  if i < j then
    (j*(j-1))/2 + i
  else
    (i*(i-1))/2 + j


let unsafe_get_four_index ~r1 ~r2 t = 

  let get a =
    Matrix.to_bigarray_inplace a
    |> Bigarray.Array2.unsafe_get
  in
  let { first=i ; second=k } = r1 and { first=j ; second=l } = r2 in 

  if i=k then
    if j=l then
      get t.two_index i j
    else
      get t.three_index (dense_index j l t.size) i
  else if j=l then
      get t.three_index (dense_index i k t.size) j

  else if i=l then
    if k=j then 
      get t.two_index_anti i j
    else
      get t.three_index_anti (dense_index j k t.size) i 

  else if j=k then
      get t.three_index_anti (dense_index i l t.size) j

  else if i=j then
    if k=l then 
      get t.two_index_anti i k
    else
      get t.three_index_anti (dense_index k l t.size) i

  else if k=l then
      (* <ij|kk> *)
      get t.three_index_anti (dense_index i j t.size) k

  else
    match t.four_index with
    | Dense  a -> get a (dense_index i k t.size) (sym_index j l)
    | Sparse a -> let key = key_of_indices ~r1 ~r2 in
                  try Hashtbl.find a key
                  with Not_found -> 0.


let get_four_index ~r1 ~r2 t = 
  check_bounds r1 r2 t;
  unsafe_get_four_index ~r1 ~r2 t  


let unsafe_set_four_index ~r1 ~r2 ~value t = 


  let unsafe_set a =
    Matrix.to_bigarray_inplace a
    |> Bigarray.Array2.unsafe_set
  in

  let { first=i ; second=k } = r1 and { first=j ; second=l } = r2 in 

  let () = 

    if i=k then
      begin
        if j=l then
          begin
            unsafe_set t.two_index i j value;
            unsafe_set t.two_index j i value;
            unsafe_set t.three_index (dense_index i i t.size) j value;
          end;
        unsafe_set t.three_index (dense_index j l t.size) i value;
        unsafe_set t.three_index (dense_index l j t.size) i value;
      end
    else if j=l then
        begin
          unsafe_set t.three_index (dense_index i k t.size) j value;
          unsafe_set t.three_index (dense_index k i t.size) j value;
        end

    else if i=l then
      begin
        if j=k then
          begin
            unsafe_set t.two_index_anti i j value;
            unsafe_set t.two_index_anti j i value;
            unsafe_set t.three_index_anti (dense_index i i t.size) j value;
          end;
        unsafe_set t.three_index_anti (dense_index j k t.size) i value;
        unsafe_set t.three_index_anti (dense_index k j t.size) i value;
      end
    else if j=k then
        begin
          unsafe_set t.three_index_anti (dense_index i l t.size) j value;
          unsafe_set t.three_index_anti (dense_index l i t.size) j value;
        end

    else if i=j then 
      begin
        if k=l then
          begin
            unsafe_set t.two_index_anti i k value;
            unsafe_set t.two_index_anti k i value;
            unsafe_set t.three_index_anti (dense_index i i t.size) k value;
          end;
        unsafe_set t.three_index_anti (dense_index k l t.size) i value;
        unsafe_set t.three_index_anti (dense_index l k t.size) i value;
      end

    else if k=l then
        (* <ij|kk> *)
        begin
          unsafe_set t.three_index_anti (dense_index i j t.size) k value;
          unsafe_set t.three_index_anti (dense_index j i t.size) k value;
        end
  in

  match t.four_index with
  | Dense  a -> let ik = (dense_index i k t.size)
                and jl = (dense_index j l t.size)
                and ki = (dense_index k i t.size)
                and lj = (dense_index l j t.size)
                and ik_s = (sym_index i k)
                and jl_s = (sym_index j l)
                in
                begin
                  unsafe_set a ik jl_s value;
                  unsafe_set a ki jl_s value;
                  unsafe_set a jl ik_s value;
                  unsafe_set a lj ik_s value;
                end
  | Sparse a -> let key = key_of_indices ~r1 ~r2 in
                Hashtbl.replace a key value
    

let set_four_index ~r1 ~r2 ~value t = 
  check_bounds r1 r2 t;
  unsafe_set_four_index ~r1 ~r2 ~value t


let unsafe_increment_four_index ~r1 ~r2 ~value t = 
  let updated_value =
    value +. unsafe_get_four_index ~r1 ~r2 t
  in
  unsafe_set_four_index ~r1 ~r2 ~value:updated_value t


let increment_four_index ~r1 ~r2 ~value t = 
  check_bounds r1 r2 t;
  unsafe_increment_four_index ~r1 ~r2 ~value t


let get ~r1 ~r2 a = 
  get_four_index ~r1 ~r2 a

let set ~r1 ~r2 ~value = 
  match classify_float value with
  | FP_normal -> set_four_index ~r1 ~r2 ~value
  | FP_zero    
  | FP_subnormal -> fun _ -> ()
  | FP_infinite
  | FP_nan ->
    let msg =
      Printf.sprintf "FourIdxStorage.ml : set : r1 = (%d,%d) ; r2 = (%d,%d)"
        r1.first r1.second r2.first r2.second
    in
    raise (Invalid_argument msg)


let increment ~r1 ~r2 = 
  increment_four_index ~r1 ~r2 

let create ~size sparsity =
  assert (size < max_index);
  let two_index        = Matrix.make0 size        size in
  let two_index_anti   = Matrix.make0 size        size in 
  let three_index      = Matrix.make0 (size*size) size in
  let three_index_anti = Matrix.make0 (size*size) size in 
  let four_index = 
    match sparsity with
    | `Dense  -> Dense  ( Matrix.make0   (size*size) ((size*(size+1))/2) )
    | `Sparse -> Sparse ( Hashtbl.create (size*size+13) )
  in
  { size ; two_index ; two_index_anti ; three_index ; three_index_anti ; four_index }


let size t = t.size

let get_chem t i j k l = get ~r1:{ first=i ; second=j } ~r2:{ first=k ; second=l } t
let get_phys t i j k l = get ~r1:{ first=i ; second=k } ~r2:{ first=j ; second=l } t

let set_chem t i j k l value = set ~r1:{ first=i ; second=j } ~r2:{ first=k ; second=l } ~value t
let set_phys t i j k l value = set ~r1:{ first=i ; second=k } ~r2:{ first=j ; second=l } ~value t 

let increment_chem t i j k l value = increment ~r1:{ first=i ; second=j } ~r2:{ first=k ; second=l } ~value t
let increment_phys t i j k l value = increment ~r1:{ first=i ; second=k } ~r2:{ first=j ; second=l } ~value t 



(** Element for the stream *)
type element =
{
  i_r1: int ;
  j_r2: int ;
  k_r1: int ;
  l_r2: int ;
  value: float
}


let get_phys_all_i d ~j ~k ~l  =
  Vector.init d.size (fun i -> get_phys d i j k l)
    

let get_chem_all_i d ~j ~k ~l  =
  Vector.init d.size (fun i -> get_chem d i j k l)


let get_phys_all_ij d ~k ~l  =
  Matrix.init_cols d.size d.size (fun i j -> get_phys d i j k l)
    

let get_chem_all_ij d ~k ~l  =

  if k = l then

      let result = 
        Matrix.col_inplace d.three_index k
        |> Vector.to_bigarray_inplace
        |> Bigarray.genarray_of_array1 
      in
      Bigarray.reshape_2 result d.size d.size
      |> Matrix.of_bigarray_inplace

  else

      match d.four_index with
      | Dense  a -> 
          let kl = sym_index k l in
          let result = 
            Matrix.col_inplace a kl
            |> Vector.to_bigarray_inplace
            |> Bigarray.genarray_of_array1
          in
          Bigarray.reshape_2 result d.size d.size
          |> Matrix.of_bigarray_inplace
      | Sparse _ ->
          Matrix.init_cols d.size d.size (fun i j -> get_chem d i j k l)
    

    
let to_stream d =

  let i = ref 0
  and j = ref 1
  and k = ref 1
  and l = ref 1
  in
  let f_dense _ =
    incr i;
    if !i > !k then begin
      i := 1;
      incr j;
      if !j > !l then begin
        j := 1;
        incr k;
        if !k > !l then begin
          k := 1;
          incr l;
        end;
      end;
     end;
     if !l <= d.size then 
       Some { i_r1 = !i ; j_r2 = !j ;
             k_r1 = !k ; l_r2 = !l ;
             value = get_phys d !i !j !k !l
           }
     else
       None
  in
  Stream.from f_dense
    

(** Write all integrals to a file with the <ij|kl> convention *)
let to_file ?(cutoff=Constants.integrals_cutoff) ~filename data =
  let oc = open_out filename in
  to_stream data 
  |> Stream.iter (fun {i_r1 ; j_r2 ; k_r1 ; l_r2 ; value} ->
           if (abs_float value > cutoff) then
            Printf.fprintf oc " %5d %5d %5d %5d%20.15f\n" i_r1 j_r2 k_r1 l_r2 value);
  close_out oc



let of_file ~size ~sparsity filename =
  let result = create ~size sparsity in
  let ic = Scanf.Scanning.open_in filename in
  let rec read_line () =
    let result =
      try
        Some (Scanf.bscanf ic " %d %d %d %d %f" (fun i j k l v ->
          set_phys result i j k l v))
      with End_of_file -> None
    in
    match result with
    | Some () -> (read_line [@tailcall]) ()
    | None    -> ()
  in
  read_line ();
  Scanf.Scanning.close_in ic;
  result


let to_list data =
  let s =
    to_stream data
  in
  let rec append accu = 
    let d = 
      try Some (Stream.next s) with
      | Stream.Failure -> None
    in
    match d with
    | None -> List.rev accu
    | Some d -> (append [@tailcall]) (d :: accu) 
  in
  append [] 



     

let four_index_transform_dense_sparse ds coef source =

  let mo_num = Matrix.dim2 coef in
  let ao_num = Matrix.dim1 coef in
  let mo_num_2  = mo_num * mo_num in
  let ao_num_2  = ao_num * ao_num in
  let ao_mo_num = ao_num * mo_num in
  let range_ao = Util.array_range 1 ao_num in
  let coefx = Matrix.to_bigarray_inplace coef in

  Printf.eprintf "4-idx transformation \n%!";

  let n = ref 0 in
  let task delta =
      let u = Matrix.create mo_num_2 mo_num
      and o = Matrix.create ao_num ao_num_2 
      and p = Matrix.create ao_num_2 mo_num
      and q = Matrix.create ao_mo_num mo_num
      in

      Matrix.fill_inplace u 0.;

      Array.iter (fun l ->
          if abs_float coefx.{l,delta} > Constants.epsilon then
            begin

              (* o_i_jk *)
              let jk = ref 1 in
              Array.iter (fun k ->
                  get_chem_all_ij source ~k ~l 
                  |> Matrix.copy_inplace ~b:o ~bc:!jk 
                  |> ignore;
                  jk := !jk + ao_num;
                ) range_ao;

              (* p_jk_alpha  = \sum_i o_i_jk c_i_alpha *)
              Matrix.gemm_inplace ~transa:`T ~c:p o coef;
              
              (* p_j_kalpha *)
              let p' = Matrix.reshape_inplace ao_num ao_mo_num p in

              (* q_kalpha_beta  = \sum_j p_j_kalpha c_j_beta *)
              Matrix.gemm_inplace ~transa:`T ~c:q p' coef;
              
              (* q_k_alphabeta  = \sum_j p_j_kalpha c_j_beta *)
              let q' = Matrix.reshape_inplace ao_num mo_num_2 q in

              (* u_alphabeta_gamma = \sum_k q_k_alphabeta c_k_gamma *)
              Matrix.gemm_inplace ~transa:`T ~beta:1. ~alpha:coefx.{l,delta} ~c:u q' coef ;

            end
        ) range_ao;
      let u =
        let b = 
          Matrix.to_bigarray_inplace u
          |> Bigarray.genarray_of_array2
        in
        Bigarray.reshape b [| mo_num ; mo_num ; mo_num |]
        |> Bigarray.array3_of_genarray 
      in
      let rec aux accu alpha beta gamma = 
        if alpha > beta then
          aux accu 1 (beta+1) gamma
        else if beta > mo_num then
          aux accu 1 1 (gamma+1)
        else if gamma > delta then
          accu
        else
            let x = u.{alpha,beta,gamma} in
            let new_accu = 
              if abs_float x > Constants.integrals_cutoff then
                (alpha, beta, gamma, delta, x) :: accu
              else
                accu
            in
            aux new_accu (alpha+1) beta gamma
      in
      aux [] 1 1 1
      |> Array.of_list
(*
      let result = ref [] in
      for gamma = 1 to delta do
        for beta = 1 to mo_num do
          for alpha = 1 to beta do
            let x = u.{alpha,beta,gamma} in
            if abs_float x > Constants.integrals_cutoff then
              result := (alpha, beta, gamma, delta, x) :: !result;
          done
        done
      done;
      Array.of_list !result
 *)
  in

  let destination = create ~size:mo_num ds in

  Util.list_range 1 mo_num 
(*
  |> Stream.of_list 
  |> Parallel.stream_map task 
*)
  |> List.map task
  |> Stream.of_list 

  |> Stream.iter (fun l ->
     (incr n ; Printf.eprintf "\r%d / %d%!" !n mo_num);
     Array.iter (fun (alpha, beta, gamma, delta, x) ->
      set_chem destination alpha beta gamma delta x) l);

  Printf.eprintf "\n%!";
  destination


let four_index_transform coef source =
  match source.four_index with
  | Sparse   _ -> four_index_transform_dense_sparse `Sparse coef source
  | Dense    _ -> four_index_transform_dense_sparse `Dense  coef source

