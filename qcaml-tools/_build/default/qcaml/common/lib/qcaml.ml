

(* | ~root~ | Path to the QCaml source directory |
 * | ~name~ | ~"QCaml"~                          | *)


(* [[file:~/QCaml/common/qcaml.org::*QCaml][QCaml:2]] *)
let name = "QCaml"

let root =
  let rec chop = function
    | [] -> []
    | x :: _ as l when x = name -> l
    | _ :: rest -> chop rest
  in
  String.split_on_char Filename.dir_sep.[0] (Sys.getcwd ())
  |> List.rev
  |> chop
  |> List.rev
  |> String.concat Filename.dir_sep
(* QCaml:2 ends here *)
