open Lacaml.D
   
type 'a t = Vec.t

let relabel t = t
let copy ?n ?ofsy ?incy ?y ?ofsx ?incx t = copy ?n ?ofsy ?incy ?y ?ofsx ?incx t 
let norm t = nrm2 t

let dim  t = Vec.dim  t
let neg  t = Vec.neg  t
let sum  t = Vec.sum  t
let abs  t = Vec.abs  t
let sin  t = Vec.sin  t
let cos  t = Vec.cos  t
let tan  t = Vec.tan  t
let asin t = Vec.asin t
let acos t = Vec.acos t
let atan t = Vec.atan t
let reci t = Vec.reci t
let sqr  t = Vec.sqr  t
let sqrt  t = Vec.sqrt t

let init  f t = Vec.init  f t
let iter  f t = Vec.iter  f t
let map   f t = Vec.map   f t
let iteri f t = Vec.iteri f t

let fold f a t = Vec.fold f a t

let add t1 t2 = Vec.add t1 t2
let sub t1 t2 = Vec.sub t1 t2
let mul t1 t2 = Vec.mul t1 t2
let div t1 t2 = Vec.div t1 t2
let dot t1 t2 = dot t1 t2
let amax    t = amax t

let create   n = Vec.create   n
let make0    n = Vec.make0    n
let of_array a = Vec.of_array a
let of_list  l = Vec.of_list  l
let to_array t = Vec.to_array t
let to_list  t = Vec.to_list  t

let make n x = Vec.make n x

(*
let of_bigarray t = copy t
let to_bigarray t = copy t
*)

let of_bigarray_inplace t = t
let to_bigarray_inplace t = t
              
let random ?rnd_state ?(from= -. 1.0) ?(range=2.0) n = 
  let state =
    match rnd_state with
    | None -> Random.get_state ()
    | Some state -> state
  in
  Vec.random ~rnd_state:state ~from ~range n


let normalize v =
  let result = copy v in
  scal (1. /. (nrm2 v)) result;
  result


let (%.) t i = t.{i}
               
let set t i v = t.{i} <- v
