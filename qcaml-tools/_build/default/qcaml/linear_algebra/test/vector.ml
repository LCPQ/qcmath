open Linear_algebra
open Alcotest
open Lacaml.D

let test_all () =
  let n = 100 in
  let a1 = Array.init n (fun _ -> Random.float 10. -. 5.) in
  let a2 = Array.init n (fun _ -> Random.float 10. -. 5.) in
  let u1 = Vec.of_array a1 in
  let u2 = Vec.of_array a2 in
  let v1 = Vector.of_array a1 in
  let v2 = Vector.of_array a2 in

  let check_dot1 label f1 f2 =
    check (float 1.e-14) label (dot u1 (f1 u2)) (Vector.dot v1 (f2 v2))
  in
    
  let check_dot2 label f1 f2 =
    check (float 1.e-14) label (dot u1 (f1 u1 u2)) (Vector.dot v1 (f2 v1 v2))
  in
    
  check int "dim" (Array.length a1) (Vector.dim v1);
  check (float 1.e-14) "dot" (dot u1 u2) (Vector.dot v1 v2);
  check_dot2 "add" (fun x y -> Vec.add x y) Vector.add ;
  check_dot2 "sub" (fun x y -> Vec.sub x y) Vector.sub ;
  check_dot2 "mul" (fun x y -> Vec.mul x y) Vector.mul ;
  check_dot2 "div" (fun x y -> Vec.div x y) Vector.div ;
  check_dot1 "sqr" (fun x -> Vec.sqr x) Vector.sqr ;
  check_dot1 "sin" (fun x -> Vec.sin x) Vector.sin ;
  check_dot1 "cos" (fun x -> Vec.cos x) Vector.cos ;
  check_dot1 "tan" (fun x -> Vec.tan x) Vector.tan ;
  check_dot1 "abs" (fun x -> Vec.abs x) Vector.abs ;
  check_dot1 "neg" (fun x -> Vec.neg x) Vector.neg ;
  check_dot1 "asin" (fun x -> Vec.asin x) Vector.asin ;
  check_dot1 "acos" (fun x -> Vec.acos x) Vector.acos ;
  check_dot1 "atan" (fun x -> Vec.atan x) Vector.atan ;
  check_dot1 "sqrt" (fun x -> Vec.sqrt x) Vector.sqrt ;
  check_dot1 "reci" (fun x -> Vec.reci x) Vector.reci ;
  check_dot1 "map" (fun x -> Vec.map (fun y -> y+. 3.) x) (Vector.map (fun y -> y+. 3.)) ;
  check (float 1.e-14) "norm" (sqrt (dot u1 u1)) (Vector.norm v1);
  check (float 1.e-14) "norm" (sqrt (dot u2 u2)) (Vector.norm v2);
  check (float 1.e-14) "sum" (Vec.sum u1) (Vector.sum v1);
  check (float 1.e-14) "sum" (Vec.sum u2) (Vector.sum v2);
  check (float 1.e-14) "at" (u1.{n/2}) (v1%.(n/2));
  check (float 1.e-14) "at" (u2.{n/2}) (v2%.(n/2));
  check (bool) "of_list" true (v1 = Vector.of_list @@ Array.to_list a1);
  check (bool) "of_list" true (v2 = Vector.of_list @@ Array.to_list a2);
  check (bool) "to_list" true (Vector.to_list v1 = Array.to_list a1);
  check (bool) "to_list" true (Vector.to_list v2 = Array.to_list a2);
  check (bool) "to_array" true (Vector.to_array v1 = a1);
  check (bool) "to_array" true (Vector.to_array v2 = a2);
  check (bool) "make0" true (Vector.make0 n = Vector.make n 0.);
  check (float 1.e-14) "fold" (Vector.sum v1) (Vector.fold (fun a x -> a +. x) 0. v1);
  check (float 1.e-14) "fold" (Vector.sum v2) (Vector.fold (fun a x -> a +. x) 0. v2);
  ()

let tests = [
  "string", `Quick, test_all;
]
