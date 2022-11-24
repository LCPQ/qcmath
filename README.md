# qcmath

Mathematica modules for electronic structure calculations developed at the 
Laboratoire de Chimie et Physique Quantiques ([LCPQ](https://www.lcpq.ups-tlse.fr)) UMR5626 (Toulouse, France).
qcmath is primarily developed to help newcomers in quantum chemistry to easily develop their own ideas and codes.
Note that qcmath is **not** designed for computational efficiency.

**Contributors:**
- [Pierre-Francois Loos](https://pfloos.github.io/WEB_LOOS)
- [Anthony Scemama](https://scemama.github.io)
- Enzo Monino
- Antoine Marie
- Raul Quintero

# qcmath abilities

## Ground-state calculations
- restricted and unrestricted Hartree-Fock (HF)
- Moller-Plesset (MP) perturbation theory
- various flavours of coupled-cluster (CC) calculations

## Charged excitations
- *GW* approximation
- T-matrix approximation
- second- and third-order Green's function (GF)

## Neutral excitations
- maximum overlap method (MOM)
- configuration interaction (CI)
- random-phase approximation (RPA)
- Bethe-Salpeter equation (BSE)
- algebraic-diagrammatic construction (ADC)

# Miscellaneous
The computation of integrals within qcmath is currently performed with [QCaml](https://gitlab.com/scemama/QCaml).
All the IO are performed with [TREXIO](https://github.com/TREX-CoE/trexio).

# Installation blueprint

To be written...

# Coding and contributing to qcmath

Due to its modular structure it should be easy to implement your own new method in qcmath.
There is a module_example.nb notebook in the utils folder that explains how to add a module to the code as well as describing the coding convention. 


