
let canonical_ortho ?thresh:(thresh=1.e-6) ~overlap c = 
  let u, d, _ = Matrix.svd overlap in
  let d_sqrt = Vector.sqrt d in
  let n = (* Number of non-negligible singular vectors *)
    Vector.fold (fun accu x -> if x > thresh then accu + 1 else accu) 0 d
  in
  let d_inv_sq = (* D^{-1/2} *)
    Vector.map (fun x ->
      if x >= thresh then 1. /. x
      else 0. ) d_sqrt
  in
  let dx = Vector.to_bigarray_inplace d in
  if n < Vector.dim d_sqrt then
    Printf.printf "Removed linear dependencies below %f\n" (1. /. dx.{n})
  ;
  Matrix.scale_cols_inplace u d_inv_sq ;
  Matrix.gemm_nn u c


let qr_ortho m =
  (* Performed twice for precision *)
  let q, _ = Matrix.qr m in 
  let q, _ = Matrix.qr q in
  q




