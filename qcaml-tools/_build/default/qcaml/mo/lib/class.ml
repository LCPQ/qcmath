open Particles
open Common
    
type mo_class =                                                                              
  | Core       of int  (* Always doubly occupied *)
  | Inactive   of int  (* With 0,1 or 2 holes *)
  | Active     of int  (* With 0,1 or 2 holes or particles *)
  | Virtual    of int  (* With 0,1 or 2 particles *)
  | Deleted    of int  (* Always unoccupied *)
  | Auxiliary  of int  (* Auxiliary basis function *)

type t = mo_class list


let pp_mo_class ppf = function
  | Core      i -> Format.fprintf ppf "@[Core %d@]" i
  | Inactive  i -> Format.fprintf ppf "@[Inactive %d@]" i
  | Active    i -> Format.fprintf ppf "@[Active %d@]" i
  | Virtual   i -> Format.fprintf ppf "@[Virtual %d@]" i
  | Deleted   i -> Format.fprintf ppf "@[Deleted %d@]" i
  | Auxiliary i -> Format.fprintf ppf "@[Auxiliary %d@]" i

let pp ppf t =
  Format.fprintf ppf "@[[@,";
  let rec aux = function
  | [] -> Format.fprintf ppf "]@]"
  | x :: [] -> Format.fprintf ppf "%a@,]@]" pp_mo_class x
  | x :: rest -> ( Format.fprintf ppf "%a@,;@," pp_mo_class x; aux rest )
  in
  aux t


let of_list t = t

let to_list t = t


let core_mos t =
  List.filter_map (fun x ->
      match x with 
      | Core i -> Some i
      | _ -> None) t


let inactive_mos t =
  List.filter_map (fun x ->
      match x with 
      | Inactive i -> Some i
      | _ -> None ) t


let active_mos t =
  List.filter_map (fun x ->
      match x with 
      | Active i -> Some i
      | _ -> None ) t


let virtual_mos t =
  List.filter_map (fun x ->
      match x with 
      | Virtual i -> Some i
      | _ -> None ) t


let deleted_mos t =
  List.filter_map (fun x ->
      match x with                                                                           
      | Deleted i -> Some i
      | _ -> None ) t



let auxiliary_mos t =
  List.filter_map (fun x ->
      match x with                                                                           
      | Auxiliary i -> Some i
      | _ -> None ) t


let mo_class_array t =
  let sze = List.length t + 1 in
  let result = Array.make sze (Deleted 0) in
  List.iter (fun c ->
      match c with
      |  Core      i  ->  result.(i)  <-  Core      i
      |  Inactive  i  ->  result.(i)  <-  Inactive  i
      |  Active    i  ->  result.(i)  <-  Active    i
      |  Virtual   i  ->  result.(i)  <-  Virtual   i
      |  Deleted   i  ->  result.(i)  <-  Deleted   i
      |  Auxiliary i  ->  result.(i)  <-  Auxiliary i
    ) t;
  result


let fci ~frozen_core mo_basis =
  let mo_num = Basis.size mo_basis in
  let ncore  = Frozen_core.num_mos frozen_core in
  of_list (
      List.concat [
        Util.list_range 1 ncore
        |> List.map (fun i -> Core i) ;
        Util.list_range (ncore+1) mo_num
        |> List.map (fun i -> Active i) 
      ]
  )

let cas_sd mo_basis ~frozen_core n m =
  let mo_num = Basis.size mo_basis in
  let n_alfa = Basis.simulation mo_basis |> Simulation.electrons |> Electrons.n_alfa in
  let n_beta = Basis.simulation mo_basis |> Simulation.electrons |> Electrons.n_beta in
  let n_unpaired = n_alfa - n_beta in
  let n_alfa_in_cas = (n - n_unpaired)/2 + n_unpaired in
  let last_inactive = n_alfa - n_alfa_in_cas in
  let last_active  = last_inactive + m in
  let ncore  = min (Frozen_core.num_mos frozen_core) last_inactive in
  of_list (
    List.concat [
        Util.list_range 1 ncore
        |> List.map (fun i -> Core i) ;
        Util.list_range (ncore+1) last_inactive
        |> List.map (fun i -> Inactive i) ;
        Util.list_range (last_inactive+1) last_active
        |> List.map (fun i -> Active i) ;
        Util.list_range (last_active+1) mo_num
        |> List.map (fun i -> Virtual i) 
      ]
  )


