

(* | ~epsilon~          | Value below which a float is considered null. Default is \epsilon = 2.10^{-15} |
 * | ~integrals_cutoff~ | Cutoff value for integrals. Default is \epsilon                                | *)


(* [[file:~/QCaml/common/constants.org::*Thresholds][Thresholds:2]] *)
let epsilon = 2.e-15
let integrals_cutoff = epsilon
(* Thresholds:2 ends here *)



(* | ~pi~             | $\pi = 3.141~592~653~589~793~12$ |
 * | ~two_pi~         | $2 \pi$                          |
 * | ~sq_pi~          | $\sqrt{\pi}$                     |
 * | ~sq_pi_over_two~ | $\sqrt{\pi} / 2$                 |
 * | ~pi_inv~         | $1 / \pi$                        |
 * | ~two_over_sq_pi~ | $2 / \sqrt{\pi}$                 | *)


(* [[file:~/QCaml/common/constants.org::*Mathematical%20constants][Mathematical constants:2]] *)
let pi             = acos (-1.)
let two_pi         = 2. *. pi
let sq_pi          = sqrt pi
let sq_pi_over_two = sq_pi *. 0.5
let pi_inv         = 1. /. pi
let two_over_sq_pi = 2. /. sq_pi
(* Mathematical constants:2 ends here *)



(* | ~a0~       | Bohr's radius : $a_0 = 0.529~177~210~67(23)$ angstrom |
 * | ~a0_inv~   | $1 / a_0$                                             |
 * | ~ha_to_ev~ | Hartree to eV conversion factor : $27.211~386~02(17)$ |
 * | ~ev_to_ha~ | eV to Hartree conversion factor : 1 / ~ha_to_ev~      | *)


(* [[file:~/QCaml/common/constants.org::*Physical%20constants][Physical constants:2]] *)
let a0 = 0.529_177_210_67
let a0_inv = 1. /. a0
let ha_to_ev = 27.211_386_02
let ev_to_ha = 1. /. ha_to_ev
(* Physical constants:2 ends here *)
