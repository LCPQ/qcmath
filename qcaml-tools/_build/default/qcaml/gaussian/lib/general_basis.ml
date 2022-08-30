(** General basis set read from a file  *)

open Common
open Particles
    
type primitive =
  {
    exponent   : float ;
    coefficient: float ;
  }

type general_contracted_shell = Angular_momentum.t * (primitive array)

type element_basis = Element.t * (general_contracted_shell array)

type t = element_basis list


exception No_shell
exception Malformed_shell of string


let read_shell line_stream =
  try

    let shell, n =
      try
        let line = Stream.next line_stream in
        if String.trim line = "$END" then raise End_of_file;
        Scanf.sscanf line " %c %d " (fun shell n -> shell, n)
      with
      | End_of_file -> raise No_shell
      | Stream.Failure -> raise No_shell
      | Scanf.Scan_failure m -> raise (Malformed_shell m)
    in

    let rec loop = function
      | 0 -> []
      | i -> let contraction = 
               let line = Stream.next line_stream in
               try Scanf.sscanf line " %_d %f %f "
                     (fun exponent coefficient -> { exponent ; coefficient })
               with _ -> raise (Malformed_shell (Printf.sprintf
                     "Expected %d %c contractions, error at contraction %d:\n%s"
                      n shell (n-i+1) line))
        in
        contraction :: loop (pred i)
    in
    Some (Angular_momentum.of_char shell, Array.of_list (loop n))

  with
  | No_shell -> None




let read_element line_stream =
  try

    let line = Stream.next line_stream in
    let element =
      Scanf.sscanf line " %s " Element.of_string
    in

    let rec loop () =
      match read_shell line_stream with
      | Some shell -> shell :: loop ()
      | None -> []
    in
    Some (element, Array.of_list (loop ()) )

  with
  | Stream.Failure -> None
  

let read_stream line_stream = 
  let rec loop accu =
    try
      match read_element line_stream with
      | Some e -> loop (e :: accu)
      | None -> accu
    with
    Element.ElementError _ -> loop accu
  in
  loop [] 

let read filename =
  let ic = open_in filename in
  let line_stream =
    Stream.from (fun _ -> 
      try Some (input_line ic)
      with End_of_file -> None )
  in
  let result = read_stream line_stream in
  close_in ic;
  result


let combine basis_list =
  let h = Hashtbl.create 63 in
  List.concat basis_list
  |> List.iter (fun (k,v) ->
      let l = Hashtbl.find_all h k in
      Hashtbl.replace h k (Array.concat (l@[v]) )
      ) ;
  Hashtbl.fold (fun k v accu -> (k, v)::accu) h []


let read_many filenames =
  List.map read filenames
  |> combine

  
let string_of_primitive ?id prim =
  match id with
  | None -> (string_of_float prim.exponent)^" "^(string_of_float prim.coefficient)
  | Some i -> (string_of_int i)^" "^(string_of_float prim.exponent)^" "^(string_of_float prim.coefficient)


let string_of_contracted_shell (angular_momentum, prim_array) =
  let n = 
    Array.length prim_array
  in
  Printf.sprintf "%s %d\n%s"
    (Angular_momentum.to_string angular_momentum) n
    (Array.init n (fun i -> string_of_primitive ~id:(i+1) prim_array.(i))
     |> Array.to_list
     |> String.concat "\n")


let string_of_contracted_shell_array a =
  Array.map string_of_contracted_shell a
  |> Array.to_list
  |> String.concat "\n"


let to_string (name, contracted_shell_array) =
  Printf.sprintf "%s\n%s" name (string_of_contracted_shell_array contracted_shell_array)


let of_string input_string = 
  String.split_on_char '\n' input_string
  |> Stream.of_list
  |> read_stream


let pp_primitive ppf prim =
  Format.fprintf ppf "@[%17.10e  %17.10e@]" prim.exponent prim.coefficient
    

let pp_gcs ppf gcs =
  let (angular_momentum, prim_array) = gcs in
  Format.fprintf ppf "@[%a  %d@]@."
    Angular_momentum.pp_string angular_momentum
    (Array.length prim_array);

  Array.iteri (fun i prim -> Format.fprintf ppf "@[%3d  %a@]@."
                  (i+1) pp_primitive prim) prim_array

    
let pp_element_basis ppf eb =
  let (element, basis) = eb in
  Format.fprintf ppf "@[%s@]@." (String.uppercase_ascii @@ Element.to_long_string element);
  Array.iter (fun b -> Format.fprintf ppf "@[%a@]" pp_gcs b) basis

let pp ppf t =
  List.iter (fun x -> Format.fprintf ppf "@[%a@]@." pp_element_basis x) t
