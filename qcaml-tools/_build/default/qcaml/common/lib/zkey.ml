(* [[file:~/QCaml/common/zkey.org::*Types][Types:2]] *)
type t = 
  {
    mutable left   : int;
    mutable right  : int;
    kind   : int ;
  }

open Powers

type kind = 
  | Three  of  Powers.t
  | Four   of (int * int * int * int)
  | Six    of (Powers.t * Powers.t)
  | Nine   of (Powers.t * Powers.t * Powers.t)
  | Twelve of (Powers.t * Powers.t * Powers.t * Powers.t)
(* Types:2 ends here *)



(* | ~of_powers_three~ | Create from a ~Powers.t~       |
 * | ~of_powers_six~   | Create from two ~Powers.t~     |
 * | ~of_powers_nine~  | Create from three ~Powers.t~   |
 * | ~of_powers_twelve~ | Create from four ~Powers.t~    |
 * | ~of_powers~       | Create using the ~kind~ type   |
 * | ~of_int_array~    | Convert from an ~int~ array    |
 * | ~of_int_four~     | Create from four ~ints~        |
 * | ~to_int_array~    | Convert to an ~int~ array      |
 * | ~to_powers~       | Convert to an ~Powers.t~ array |
 * | ~to_string~       | Pretty printing                | *)


(* [[file:~/QCaml/common/zkey.org::*Conversions][Conversions:2]] *)
(** Creates a Zkey. *)
let make ~kind right =
  { left = 0 ; right ; kind }

(** Move [right] to [left] and set [right = x] *)
let (<|) z x = 
  z.left  <- z.right;
  z.right <- x;
  z

(** Shift left [right] by 10 bits, and add [x]. *)
let (<<) z x =  
  z.right <- (z.right lsl 10) lor x ;
  z

(** Shift left [right] by 10 bits, and add [x]. *)
let (<+) z x =  
  z.right <- (z.right lsl 15) lor x ;
  z


let of_powers_three { x=a ; y=b ; z=c ; _ } =
  assert (
    let alpha = a lor b lor c in
    alpha >= 0 && alpha < (1 lsl 15)
  );
  make ~kind:3 a <+ b <+ c


let of_int_four i j k l =
  assert (
    let alpha = i lor j lor k lor l in
    alpha >= 0 && alpha < (1 lsl 15)
  );
  make ~kind:4 i <+ j <+ k <+ l


let of_powers_six   { x=a ; y=b ; z=c ; _ } { x=d ; y=e ; z=f ; _ } =
  assert (
    let alpha = a lor b lor c lor d lor e lor f in
    alpha >= 0 && alpha < (1 lsl 10) 
  );
  make ~kind:6 a << b << c << d << e << f 


let of_powers_nine { x=a ; y=b ; z=c ; _ } { x=d ; y=e ; z=f ; _ }
    { x=g ; y=h ; z=i ; _ } = 
  assert (
    let alpha = a lor b lor c lor d lor e lor f lor g lor h lor i in
    alpha >= 0 && alpha < (1 lsl 10) 
  );
  make ~kind:9 a << b << c << d << e << f
  <| g << h << i 


let of_powers_twelve { x=a ; y=b ; z=c ; _ } { x=d ; y=e ; z=f ; _ }
    { x=g ; y=h ; z=i ; _ } { x=j ; y=k ; z=l ; _ }  = 
  assert (
    let alpha = a lor b lor c lor d lor e lor f
                lor g lor h lor i lor j lor k lor l
    in
    alpha >= 0 && alpha < (1 lsl 10) 
  );
  make ~kind:12  a << b << c << d << e << f
  <| g << h << i << j << k << l


let of_powers a = 
  match a with
  | Three   a        -> of_powers_three  a
  | Six    (a,b)     -> of_powers_six    a b
  | Twelve (a,b,c,d) -> of_powers_twelve a b c d
  | Nine   (a,b,c)   -> of_powers_nine   a b c
  | _                -> invalid_arg "of_powers"


let mask10 = 0x3ff
and mask15 = 0x7fff


let of_int_array = function
  | [| a ; b ; c ; d |] -> of_int_four a b c d
  | _ -> invalid_arg "of_int_array"


(** Transform the Zkey into an int array *)
let to_int_array { left ; right ; kind }  = 
  match kind with
  | 3  -> [|
      mask15 land (right lsr 30) ;
      mask15 land (right lsr 15) ;
      mask15 land  right
    |]

  | 4  -> [|
      mask15 land (right lsr 45) ;
      mask15 land (right lsr 30) ;
      mask15 land (right lsr 15) ;
      mask15 land  right
    |]

  | 6  -> [| 
      mask10 land (right lsr 50) ;
      mask10 land (right lsr 40) ;
      mask10 land (right lsr 30) ;
      mask10 land (right lsr 20) ;
      mask10 land (right lsr 10) ;
      mask10 land right
    |]

  | 12 -> [|
      mask10 land (left  lsr 50) ;
      mask10 land (left  lsr 40) ;
      mask10 land (left  lsr 30) ;
      mask10 land (left  lsr 20) ;
      mask10 land (left  lsr 10) ;
      mask10 land  left ;
      mask10 land (right lsr 50) ;
      mask10 land (right lsr 40) ;
      mask10 land (right lsr 30) ;
      mask10 land (right lsr 20) ;
      mask10 land (right lsr 10) ;
      mask10 land  right
    |]

  | 9  -> [|
      mask10 land (left  lsr 20) ;
      mask10 land (left  lsr 10) ;
      mask10 land  left ;
      mask10 land (right lsr 50) ;
      mask10 land (right lsr 40) ;
      mask10 land (right lsr 30) ;
      mask10 land (right lsr 20) ;
      mask10 land (right lsr 10) ;
      mask10 land  right
    |]
  | _ -> invalid_arg (__FILE__^": to_int_array")



(** Transform the Zkey into an int tuple *)
let to_powers { left ; right ; kind } = 
  match kind with
  | 3  -> Three (Powers.of_int_tuple (
    mask15 land (right lsr 30) ,
    mask15 land (right lsr 15) ,
    mask15 land  right
  ))

  | 6  -> Six (Powers.of_int_tuple 
                 ( mask10 land (right lsr 50) ,
                   mask10 land (right lsr 40) ,
                   mask10 land (right lsr 30)),
               Powers.of_int_tuple
                 ( mask10 land (right lsr 20) ,
                   mask10 land (right lsr 10) ,
                   mask10 land right )
              )

  | 12 -> Twelve (Powers.of_int_tuple 
                    ( mask10 land (left  lsr 50) ,
                      mask10 land (left  lsr 40) ,
                      mask10 land (left  lsr 30)),
                  Powers.of_int_tuple
                    ( mask10 land (left  lsr 20) ,
                      mask10 land (left  lsr 10) ,
                      mask10 land  left ) ,
                  Powers.of_int_tuple
                    ( mask10 land (right lsr 50) ,
                      mask10 land (right lsr 40) ,
                      mask10 land (right lsr 30)),
                  Powers.of_int_tuple
                    ( mask10 land (right lsr 20) ,
                      mask10 land (right lsr 10) ,
                      mask10 land  right )
                 )

  | 9  -> Nine (Powers.of_int_tuple 
                  ( mask10 land (left  lsr 20) ,
                    mask10 land (left  lsr 10) ,
                    mask10 land  left ) ,
                Powers.of_int_tuple
                  ( mask10 land (right lsr 50) ,
                    mask10 land (right lsr 40) ,
                    mask10 land (right lsr 30)),
                Powers.of_int_tuple
                  ( mask10 land (right lsr 20) ,
                    mask10 land (right lsr 10) ,
                    mask10 land  right )
               )

  | _ -> invalid_arg (__FILE__^": to_powers")
(* Conversions:2 ends here *)



(* | ~hash~    | Associates a nonnegative integer to any Zkey    |
 * | ~equal~   | The equal function. True if two Zkeys are equal |
 * | ~compare~ | Comparison function, used for sorting           | *)


(* [[file:~/QCaml/common/zkey.org::*Functions%20for%20hash%20tables][Functions for hash tables:2]] *)
let hash = Hashtbl.hash 

let equal
    { right = r1 ; left = l1 ; kind = k1 }
    { right = r2 ; left = l2 ; kind = k2 } =
  r1 = r2 && l1 = l2 && k1 = k2


let compare
    { right = r1 ; left = l1 ; kind = k1 }
    { right = r2 ; left = l2 ; kind = k2 } =
  if k1 <> k2 then invalid_arg (__FILE__^": cmp");
  if r1 < r2 then -1
  else if r1 > r2 then 1
  else if l1 < l2 then -1
  else if l1 > l2 then 1
  else 0


let to_string { left ; right ; kind } =
  "< " ^  string_of_int left  ^ string_of_int right ^ " | " ^ (
    to_int_array { left ; right ; kind }
    |> Array.map string_of_int
    |> Array.to_list
    |> String.concat ", "
  ) ^ " >"
(* Functions for hash tables:2 ends here *)

(* [[file:~/QCaml/common/zkey.org::*Printers][Printers:2]] *)
let pp ppf t =
  Format.fprintf ppf "@[%s@]" (to_string t)
(* Printers:2 ends here *)
