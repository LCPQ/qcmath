(* Tests header                                                    :noexport: *)


(* [[file:~/QCaml/common/bitstring.org::*Tests%20header][Tests header:1]] *)
open Common.Bitstring
let check_bool = Alcotest.(check bool)
let check msg x = check_bool msg true x
let test_all () =
  let x = 8745687 in
  let one_x  = of_int x in
  let z = Z.shift_left (Z.of_int x) 64 in
  let many_x = of_z z in
(* Tests header:1 ends here *)

(* [[file:~/QCaml/common/bitstring.org::*General%20implementation][General implementation:3]] *)
check_bool "of_x" true (one_x = (of_int x));
check_bool "of_z" true (one_x = (of_z (Z.of_int x)));
(* General implementation:3 ends here *)



(*    Example:
 *    #+begin_example
 * Bitstring.(shift_left (of_int 15) 2);;
 * - : Bitstring.t =
 * --++++----------------------------------------------------------
 * 
 * Bitstring.(shift_right (of_int 15) 2);;
 * - : Bitstring.t =
 * ++--------------------------------------------------------------
 * 
 * Bitstring.shift_left_one 32 4;;
 * - : Bitstring.t =
 * ----+-----------------------------------------------------------
 * 
 * Bitstring.(testbit (of_int 15) 3);;
 * - : bool = true
 * 
 * Bitstring.(testbit (of_int 15) 4);;
 * - : bool = false
 *    #+end_example *)


(* [[file:~/QCaml/common/bitstring.org::*General%20implementation][General implementation:5]] *)
check_bool "shift_left1"     true (of_int (x lsl 3) = shift_left one_x 3);
check_bool "shift_left2"     true (of_z (Z.shift_left z 3) = shift_left many_x 3);
check_bool "shift_left3"     true (of_z (Z.shift_left z 100) = shift_left many_x 100);
check_bool "shift_right1"    true (of_int (x lsr 3) = shift_right one_x 3);
check_bool "shift_right2"    true (of_z (Z.shift_right z 3) = shift_right many_x 3);
check_bool "shift_left_one1" true (of_int (1 lsl 3) = shift_left_one 4 3);
check_bool "shift_left_one2" true (of_z (Z.shift_left Z.one 200) = shift_left_one 300 200);
check_bool "testbit1" true  (testbit (of_int 8) 3);
check_bool "testbit2" false (testbit (of_int 8) 2);
check_bool "testbit3" false (testbit (of_int 8) 4);
check_bool "testbit4" true  (testbit (of_z (Z.of_int 8)) 3);
check_bool "testbit5" false (testbit (of_z (Z.of_int 8)) 2);
check_bool "testbit6" false (testbit (of_z (Z.of_int 8)) 4);
(* General implementation:5 ends here *)




(*    Example:
 *    #+begin_example
 * Bitstring.(logor (of_int 15) (of_int 73));;
 * - : Bitstring.t =
 * ++++--+---------------------------------------------------------
 * 
 * Bitstring.(logand (of_int 15) (of_int 10));;
 * - : Bitstring.t =
 * -+-+------------------------------------------------------------
 * 
 * Bitstring.(logxor (of_int 15) (of_int 73));;
 * - : Bitstring.t =
 * -++---+---------------------------------------------------------
 *    #+end_example *)

   

(* [[file:~/QCaml/common/bitstring.org::*General%20implementation][General implementation:7]] *)
check_bool "logor1" true (of_int (1 lor 2) = logor (of_int 1) (of_int 2));
check_bool "logor2" true (of_z (Z.of_int (1 lor 2)) = logor (of_z Z.one) (of_z (Z.of_int 2)));
check_bool "logxor1" true (of_int (1 lxor 2) = logxor (of_int 1) (of_int 2));
check_bool "logxor2" true (of_z (Z.of_int (1 lxor 2)) = logxor (of_z Z.one) (of_z (Z.of_int 2)));
check_bool "logand1" true (of_int (1 land 3) = logand (of_int 1) (of_int 3));
check_bool "logand2" true (of_z (Z.of_int (1 land 3)) = logand (of_z Z.one) (of_z (Z.of_int 3)));
(* General implementation:7 ends here *)

(* [[file:~/QCaml/common/bitstring.org::*General%20implementation][General implementation:11]] *)
check_bool "to_list" true ([ 1 ; 3 ; 4 ; 6 ] = (to_list (of_int 45)));
(* General implementation:11 ends here *)



(*    Example:
 *    #+begin_example
 *    Bitstring.permutations 2 4;;
 * - : Bitstring.t list =
 * [++--------------------------------------------------------------;
 *  +-+-------------------------------------------------------------;
 *  -++-------------------------------------------------------------;
 *  +--+------------------------------------------------------------;
 *  -+-+------------------------------------------------------------;
 *  --++------------------------------------------------------------]
 *    #+end_example *)


(* [[file:~/QCaml/common/bitstring.org::*General%20implementation][General implementation:13]] *)
check "permutations"
  (permutations 2 4 = List.map of_int
     [ 3 ; 5 ; 6 ; 9 ; 10 ; 12 ]);
(* General implementation:13 ends here *)

(* Tests                                                           :noexport: *)


(* [[file:~/QCaml/common/bitstring.org::*Tests][Tests:1]] *)
()

let tests = [
  "all", `Quick, test_all;
]
(* Tests:1 ends here *)
