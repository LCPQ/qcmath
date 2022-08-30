open Common
open Constants


type t = {
  norm_scales     : float array lazy_t;
  exponent        : float;              (* {% $\alpha + \beta$ %} *)
  exponent_inv    : float;              (* {% $1/(\alpha + \beta)$ %} *)
  a_minus_b_sq    : float;              (* {% $|A-B|^2$ %} *)
  normalization   : float;              (* [norm_coef_a * norm_coef_b * g], with
                     {% $g = (\pi/(\alpha+\beta))^(3/2) \exp (-|A-B|^2 \alpha\beta/(\alpha+\beta))$ %} *)
  center          : Coordinate.t;       (* {% $P = (\alpha A + \beta B)/(\alpha+\beta)$ %} *)
  center_minus_a  : Coordinate.t;       (* {% $P - A$ %} *)
  a_minus_b       : Coordinate.t;       (* {% $A - B$ %} *)
  ang_mom         : Angular_momentum.t; 
  shell_a         : Primitive_shell.t;
  shell_b         : Primitive_shell.t;
}

module Am = Angular_momentum
module Co = Coordinate
module Ps = Primitive_shell


let hash a = 
  Hashtbl.hash a


let equivalent a b =
  a.exponent = b.exponent &&
  a.ang_mom = b.ang_mom &&
  a.normalization = b.normalization &&
  a.center = b.center &&
  a.center_minus_a = b.center_minus_a &&
  a.a_minus_b = b.a_minus_b


let cmp a b =
  hash a - hash b


let create_make_of p_a p_b =

  let a_minus_b = 
    Co.( Ps.center p_a |- Ps.center p_b )
  in

  let a_minus_b_sq =
    Co.dot a_minus_b a_minus_b
  in

  let norm_scales = lazy (
    Array.map (fun v1 ->
        Array.map (fun v2 -> v1 *. v2) (Ps.norm_scales p_b)
      ) (Ps.norm_scales p_a)
    |> Array.to_list
    |> Array.concat
  ) in

  let ang_mom =
    Am.( Ps.ang_mom p_a + Ps.ang_mom p_b )
  in

  function p_a -> 

    let norm_coef_a =
      Ps.normalization p_a
    in

    let alfa_a = 
      Co.( Ps.exponent p_a |. Ps.center p_a )
    in

    function p_b -> 

      let normalization =
        norm_coef_a *. Ps.normalization p_b
      in

      let exponent =
        Ps.exponent p_a +. Ps.exponent p_b
      in

      let exponent_inv = 1. /. exponent in

      let normalization = 
        let argexpo = 
          Ps.exponent p_a *. Ps.exponent p_b *. a_minus_b_sq *. exponent_inv
        in
        normalization *. (pi *. exponent_inv)**1.5 *. exp (-. argexpo)
      in

      function cutoff ->

        if abs_float normalization > cutoff then (

          let beta_b = 
            Co.( Ps.exponent p_b |. Ps.center p_b )
          in

          let center =
            Co.(exponent_inv |. (alfa_a |+ beta_b))
          in

          let center_minus_a = 
            Co.(center |- Ps.center p_a)
          in

          Some {
            ang_mom ; 
            exponent ; exponent_inv ; center ; center_minus_a ; a_minus_b ; 
            a_minus_b_sq ; normalization ; norm_scales ; shell_a = p_a;
            shell_b = p_b }

        )
        else None

      
let make p_a p_b =
  let f =
    create_make_of p_a p_b
  in
  match f p_a p_b 0. with
  | Some result -> result
  | None -> assert false


let norm_scales x =
  Lazy.force x.norm_scales

let exponent_inv x = x.exponent_inv

let monocentric x =
  Ps.center x.shell_a = Ps.center x.shell_b


let ang_mom x = x.ang_mom

let a_minus_b x = x.a_minus_b

let a_minus_b_sq x = x.a_minus_b_sq

let center_minus_a x = x.center_minus_a

let normalization x = x.normalization

let exponent x = x.exponent

let center x = x.center

let shell_a x = x.shell_a

let shell_b x = x.shell_b


let zkey_array x =
  Am.zkey_array (Am.Doublet 
    Ps.(ang_mom x.shell_a, ang_mom x.shell_b)
  )



