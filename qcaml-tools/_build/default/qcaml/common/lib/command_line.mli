(* Types
 * 
 *    #+NAME:type *)

(* [[file:~/QCaml/common/command_line.org::type][type]] *)
type short_opt     = char
type long_opt      = string
type optional      = Mandatory | Optional
type documentation = string
type argument      = | With_arg of string
                     | Without_arg
                     | With_opt_arg of string

type description = {
  short: short_opt ;
  long : long_opt  ;
  opt  : optional  ;
  doc  : documentation ;
  arg  : argument ;
}
(* type ends here *)

(* [[file:~/QCaml/common/command_line.org::*Mutable attributes][Mutable attributes:2]] *)
val set_header_doc : string -> unit
val set_description_doc : string -> unit
val set_footer_doc : string -> unit
(* Mutable attributes:2 ends here *)

(* [[file:~/QCaml/common/command_line.org::*Mutable attributes][Mutable attributes:4]] *)
val anonymous : long_opt -> optional -> documentation -> description
(* Mutable attributes:4 ends here *)

(* Query functions *)


(* [[file:~/QCaml/common/command_line.org::*Query functions][Query functions:1]] *)
val get       : long_opt -> string option
val get_bool  : long_opt -> bool
val anon_args : unit -> string list
(* Query functions:1 ends here *)

(* Specification *)


(* [[file:~/QCaml/common/command_line.org::*Specification][Specification:1]] *)
val set_specs : description list -> unit
(* Specification:1 ends here *)
