(** Contains the conventions relative to the program.

  The phase convention is given by:
  {% $\sum_i c_i > 0$ %} or {% $\min_i c_i \ge  0$ %}

*)

open Vector
    
let in_phase vec =
  let s = Vector.sum vec in
  if s = 0. then 
    let rec first_non_zero k =
      if k > Vector.dim vec then
        k-1
      else if vec%.(k) = 0. then
        first_non_zero (k+1)
      else k
    in
    let k = first_non_zero 1 in
    vec%.(k) >= 0.
  else
    s > 0.


let rephase mat  =
  Matrix.to_col_vecs mat
  |> Array.map (fun v -> if in_phase v then v else Vector.neg v)
  |> Matrix.of_col_vecs

