type t = 
  {
    size              : int;
    contracted_shells : Contracted_shell.t array ;
    atomic_shells     : Atomic_shell.t array lazy_t;
    general_basis     : General_basis.t ;
  }

module As = Atomic_shell
module Cs = Contracted_shell
module Gb = General_basis
module Ps = Primitive_shell

let general_basis t = t.general_basis

(** Returns an array of the basis set per atom *)
let of_nuclei_and_general_basis nucl bas =
  let index_ = ref 0 in
  let contracted_shells = 
    Array.map (fun (e, center) ->
        List.assoc e bas
        |> Array.map (fun (ang_mom, shell) ->
            let lc = 
              Array.map (fun Gb.{exponent ; coefficient} ->
                coefficient, Ps.make ang_mom center exponent) shell
            in
            let result = Cs.make ~index:!index_ lc in
            index_ := !index_ + Cs.size_of_shell result;
            result
          )
    ) nucl
    |> Array.to_list
    |> Array.concat
  in
  let atomic_shells = lazy(
    let uniq_center_angmom =
      Array.map (fun x -> Cs.center x, Cs.ang_mom x) contracted_shells
      |> Array.to_list
      |> List.sort_uniq compare
    in
    let csl = 
      Array.to_list contracted_shells
    in
    List.map (fun (center, ang_mom) ->
      let a = 
        List.filter (fun x -> Cs.center x = center && Cs.ang_mom x = ang_mom) csl
        |> Array.of_list
      in
      As.make ~index:(Cs.index a.(0)) a
    ) uniq_center_angmom
    |> List.sort (fun x y -> compare (As.index x) (As.index y))
    |> Array.of_list
  ) in
  { contracted_shells ; atomic_shells ; size = !index_;
    general_basis = bas }


let size t = t.size

let atomic_shells t = Lazy.force t.atomic_shells

let contracted_shells t = t.contracted_shells

let to_string b =
  let b = atomic_shells b in
  let line ="
-----------------------------------------------------------------------
" in 
  "
                          Atomic Basis set
                          ----------------

-----------------------------------------------------------------------
 #   Angular   Coordinates (Bohr)       Exponents       Coefficients
    Momentum  X        Y        Z
-----------------------------------------------------------------------
"
  ^
  ( Array.map (fun p -> Format.(fprintf str_formatter "%a" As.pp p;
    flush_str_formatter ())) b
    |> Array.to_list
    |> String.concat line
  )
  ^ line



let of_nuclei_and_basis_filename ~nuclei filename = 
  let general_basis = 
    General_basis.read filename
  in
  of_nuclei_and_general_basis nuclei general_basis

let of_nuclei_and_basis_string ~nuclei str = 
  let general_basis = 
    General_basis.of_string str
  in
  of_nuclei_and_general_basis nuclei general_basis


let of_nuclei_and_basis_filenames ~nuclei filenames = 
  let general_basis = 
    General_basis.read_many filenames
  in
  of_nuclei_and_general_basis nuclei general_basis


let pp ppf t =
  Format.fprintf ppf "@[%s@]" (to_string t)

