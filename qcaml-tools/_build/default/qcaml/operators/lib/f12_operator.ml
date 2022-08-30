(** Type for f12 correlation factors *)

type t =
  {
    expo_s : float ;
    gaussian : Gaussian_operator.t
  }


let make_gaussian_corr_factor expo_s coef_g expo_sg =
  let expo_sg =
    Array.map (fun x -> x *. expo_s *. expo_s) expo_sg
  in
  let gaussian = Gaussian_operator.make coef_g expo_sg in
  { expo_s ; gaussian }


(* -1/expo_s *. exp (-expo_s r) *)
let gaussian_geminal expo_s =
  let coef_g =
    [| 0.3144 ; 0.3037 ; 0.1681 ; 0.09811 ; 0.06024 ; 0.03726 |]
    |> Array.map (fun x -> -. x /. expo_s)
  and expo_sg =
    [| 0.2209 ; 1.004 ;  3.622 ; 12.16 ;   45.87 ;  254.4 |]
  in
  make_gaussian_corr_factor expo_s coef_g expo_sg



(* exp (-expo_s r) *)
let simple_gaussian_geminal expo_s =
  let coef_g =
    [| 0.3144 ; 0.3037 ; 0.1681 ; 0.09811 ; 0.06024 ; 0.03726 |]
  and expo_sg =
    [| 0.2209 ; 1.004 ;  3.622 ; 12.16 ;   45.87 ;  254.4 |]
  in
  make_gaussian_corr_factor expo_s coef_g expo_sg



(** r12 * exp ( -expo_s * r) *)
let gaussian_geminal_times_r12 expo_s =
  let coef_g =
    [| 0.2454 ; 0.2938 ; 0.1815 ; 0.11281 ; 0.07502 ; 0.05280 |]
  and expo_sg =
    [| 0.1824 ; 0.7118;  2.252 ; 6.474 ;   19.66 ;  77.92 |]
  in make_gaussian_corr_factor expo_s coef_g expo_sg


(* exp (-expo_s r) *)
let simple_gaussian_geminal' expo_s =
  let coef_g =
    [|
    -3.4793465193721626604883567779324948787689208984375 ;
    -0.00571703486454788484955047422886309504974633455276489257812 ;
    4.14878218728681513738365538301877677440643310546875 ;
    0.202874298181392742623785352407139725983142852783203125 ;
    0.0819187742387294803858566183407674543559551239013671875 ;
    0.04225945671351955673644695821167260874062776565551757812 ;
    |]
  and expo_sg =
    [|
    0.63172472556807146570889699432882480323314666748046875;
    26.3759196683467962429858744144439697265625;
    0.63172102793029016876147352377302013337612152099609375;
    7.08429025944207335641067402320913970470428466796875;
    42.4442841447001910637482069432735443115234375;
    391.44036073596890901171718724071979522705078125 ;
    |]
  in make_gaussian_corr_factor expo_s coef_g expo_sg






