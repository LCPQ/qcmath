

(* When an xyz file is read by =xyz_parser.mly=, it is converted into
 * an ~xyz_file~ data structure. *)


(* [[file:~/QCaml/particles/nuclei.org::*Parser][Parser:2]] *)
open Common

type nucleus =
  {
    element: Element.t ;
    coord  : Coordinate.angstrom Coordinate.point;
  }

type xyz_file =
  {
    number_of_atoms : int ;
    file_title      : string ;
    nuclei          : nucleus list ;
  }
(* Parser:2 ends here *)
