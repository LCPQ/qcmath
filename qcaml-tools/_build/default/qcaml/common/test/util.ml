(* Test header                                                     :noexport: *)


(* [[file:~/QCaml/common/util.org::*Test%20header][Test header:1]] *)
open Common.Util
open Alcotest
(* Test header:1 ends here *)

(* Test *)


(* [[file:~/QCaml/common/util.org::*Test][Test:1]] *)
let test_external () =
  check (float 1.e-15) "erf" 0.842700792949715 (erf_float 1.0);
  check (float 1.e-15) "erf" 0.112462916018285 (erf_float 0.1);
  check (float 1.e-15) "erf" (-0.112462916018285) (erf_float (-0.1));
  check (float 1.e-15) "erfc" 0.157299207050285 (erfc_float 1.0);
  check (float 1.e-15) "erfc" 0.887537083981715 (erfc_float 0.1);
  check (float 1.e-15) "erfc" (1.112462916018285) (erfc_float (-0.1));
  check (float 1.e-14) "gamma" (1.77245385090552) (gamma_float 0.5);
  check (float 1.e-14) "gamma" (9.51350769866873) (gamma_float (0.1));
  check (float 1.e-14) "gamma" (-3.54490770181103) (gamma_float (-0.5));
  check int "popcnt" 6 (popcnt @@ Int64.of_int 63);
  check int "popcnt" 8 (popcnt @@ Int64.of_int 299605);
  check int "popcnt" 1 (popcnt @@ Int64.of_int 65536);
  check int "popcnt" 0 (popcnt @@ Int64.of_int 0);
  check int "trailz" 3 (trailz @@ Int64.of_int 8);
  check int "trailz" 2 (trailz @@ Int64.of_int 12);
  check int "trailz" 0 (trailz @@ Int64.of_int 1);
  check int "trailz" 64 (trailz @@ Int64.of_int 0);
  check int "leadz" 60 (leadz @@ Int64.of_int 8);
  check int "leadz" 60 (leadz @@ Int64.of_int 12);
  check int "leadz" 63 (leadz @@ Int64.of_int 1);
  check int "leadz" 64 (leadz @@ Int64.of_int 0);
  ()
(* Test:1 ends here *)

(* [[file:~/QCaml/common/util.org::*General%20functions][General functions:3]] *)
let test_general () = 
  check int "of_some_of_int_fast" 1 (of_some (Some 1)) ;
  check int "binom" 35 (binom 7 4);
  check (float 1.e-15) "fact" 5040. (fact 7);
  check (float 1.e-15) "binom_float" 35.0 (binom_float 7 4);
  check (float 1.e-15) "pow" 729.0 (pow 3.0 6);
  check (float 1.e-15) "float_of_int_fast" 10.0 (float_of_int_fast 10);
  ()
(* General functions:3 ends here *)

(* [[file:~/QCaml/common/util.org::*Functions%20related%20to%20the%20Boys%20function][Functions related to the Boys function:5]] *)
let test_boys () =
  check (float 1.e-15) "incomplete_gamma" 0.0 (incomplete_gamma ~alpha:0.5 0.);
  check (float 1.e-15) "incomplete_gamma" 1.114707979049507 (incomplete_gamma ~alpha:0.5 0.4);
  check (float 1.e-15) "incomplete_gamma" 1.4936482656248544 (incomplete_gamma ~alpha:0.5 1.);
  check (float 1.e-15) "incomplete_gamma" 1.7724401246392805 (incomplete_gamma ~alpha:0.5 10.);
  check (float 1.e-15) "incomplete_gamma" 1.7724538509055159 (incomplete_gamma ~alpha:0.5 100.);

  check (float 1.e-15) "boys" 1.0 (boys_function ~maxm:0 0.).(0);
  check (float 1.e-15) "boys" 0.2 (boys_function ~maxm:2 0.).(2);
  check (float 1.e-15) "boys" (1./.3.) (boys_function ~maxm:2 0.).(1);
  check (float 1.e-15) "boys" 0.8556243918921488 (boys_function ~maxm:0 0.5).(0);
  check (float 1.e-15) "boys" 0.14075053682591263 (boys_function ~maxm:2 0.5).(2);
  check (float 1.e-15) "boys" 0.00012711171070276764 (boys_function ~maxm:3 15.).(3);
  ()
(* Functions related to the Boys function:5 ends here *)

(* [[file:~/QCaml/common/util.org::*List%20functions][List functions:3]] *)
let test_list () =
  check bool "list_range" true ([ 2; 3; 4 ] = list_range 2 4);
  check bool "list_some" true ([ 2; 3; 4 ] =
                               list_some ([ None ; Some 2 ; None ; Some 3 ; None ; None ; Some 4]) );
  check bool "list_pack" true (list_pack 3 (list_range 1 20) =
                               [[1; 2; 3]; [4; 5; 6]; [7; 8; 9]; [10; 11; 12]; [13; 14; 15];
                                [16; 17; 18]; [19; 20]]);
  ()
(* List functions:3 ends here *)

(* [[file:~/QCaml/common/util.org::*Array%20functions][Array functions:3]] *)
let test_array () =
  check bool "array_range" true ([| 2; 3; 4 |] = array_range 2 4);
  check (float 1.e-15) "array_sum" 9. (array_sum [| 2.; 3.; 4. |]);
  check (float 1.e-15) "array_product" 24. (array_product [| 2.; 3.; 4. |]);
  ()
(* Array functions:3 ends here *)

(* Test footer                                                     :noexport: *)


(* [[file:~/QCaml/common/util.org::*Test%20footer][Test footer:1]] *)
let tests = [
  "External", `Quick, test_external;
  "General" , `Quick, test_general;
  "Boys"    , `Quick, test_boys;
  "List"    , `Quick, test_list;
  "Array"   , `Quick, test_array;
]
(* Test footer:1 ends here *)
