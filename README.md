# First-principles calculations of Auger recombination rates (Beta)

We have tried to make the code as user friendly as possible. If you have any trouble getting things to work, or if you have any questions, do not hesitate to message me on github.

## Direct Auger recombination

- Obtain the eigenenergies and wavefunctions on a irreducible wedge on a dense *k*-point grid
- The user sets carrier concentration and the program will apply a windowing routine to obtain the Fermi-level
- Once the Fermi-level is calculated, we compute the all momentum conserving 4-body interactions (considering Umklapp) to get all of the *k*-points outside of the IBZ that need to be calculated. 
- Compute the eigenenergies and wavefunctions at the new *k*-points
- Finally compute the Auger recombination rate as a function of the band gap.

## Phonon-assisted Auger recombination

- Since the phonon-assisted process does not require momentum conservation (the phonon can provide arbitrary amount of momentum), the combinatorice will be prohibatively large if we are considering *k*-dependent filling of the of the band edges.
- We have to overcome this by assuming that all of the states are at a single point at the band-edge (or a few if they are degenerate).
- Then we compute the electron-phonon matrix elements and Coulomb matrix element
- Note that use use a patched QE to print the electron-phonon matrix elements within QE because it's important for the phase of all wavefunctions to be consistent.

### Prerequisites

Make sure that cray-FFTW is installed on the cluster you are running on and make sure the module is loaded.

### Installing

On cori computing cluster, first run:
```
module load cray-fftw
```
then:
```
make all
```

Do this for both the direct and indirect versions of the code.

## Examples

The inputs and outputs of two runs for GaAs (on an extremely corse grid) are included.

For the direct calculation:

- Obtain the charge density in the `scf` directory
- Obtain the kpoints file in the following the format of the `kpoints.elec` and `kpoints.hole` examples in the nscf directory
- Run the klist.x program in the directory with the kpoints files to generate the `klist.elec.irr` file. Which lists of kpoints in the irreducible zone
- In folders named `k_#` where `#` is the index from the `kpoints.elec` file, perform nscf calculations for each k-point.  (examples in `./GaAs-direct/nscf-3x3x3`)
- After completing the run on the irreducible zone we can run the `klists.x` program again to get the Fermi filling, and generate the additional `klist` files to for other points that are need from the BZ.
- After completing QE runs for all of those directories, we can finally run the auger program to obtain the rates

For the indirect calculations:

- First use the patch file to update your quantum espresso install (testes for QE 6.2.1) by running:
```
patch -s -p0 < [bf_auger]/qe_auger_patch.diff
```

In the `PHonon/PH` subdirectory

- Obtain the irreducible q-point files: `kirr_cartesian.dat` and `klist_weights.dat`. The `kirr_cartesian.dat` contains the q-point list written in cartesian coordinates, which will be used for the phonon and electron-phonon coupling calculations. The `klist_weights.dat` is written in relative coordinates and contains the normalized weight for each q-point.
- Run the `makedirs.tsch` script to create the directories (`phonon_#`, where # is the index of q-point) and input files for each q-point contained in `kirr_cartesian.dat`.
- Run `ph.x < ph1.in > ph1.out` to compute the phonon frequencies for each q-point. Run the `extract-freq.sh` to extract the phonon frequencies written into a file named `omega`.
- Run `pw.x < nscf.in > nscf.out` to perform a non-selfconsistent calculation for the kpoint where the band gap is located.
- Run `ph.x < ph2.in > ph2.out` to compute the electron-phonon coupling matrix elements between k and k+q.
- Run the `makennkp.sh` script inside each `phonon_#` directory. This will take `ph2.out` as input to generate the `GaAs.nnkp` file, which will be used by pw2wannier.x. Move the generated `GaAs.nnkp` file to the `_ph0` directory.
- Run `pw2wannier90.x < pw2wannier.in > pw2wannier.out` to extract the eigenvalues (`GaAs.eig`) and wavefunctions (`UNK00001.1` and `UNK00002.1`) for `k` and `k+q`. After completion, move `GaAs.eig`, `UNK00001.1` and `UNK00002.1` files to the directory one level above.
- Run the indirect Auger executables with the `auger.in` file as input to compute the indirect Auger recombination rates.

## Acknowledgments

* Original code by Emmanouil Kioupakis, Daniel Steiauf, Patrick Rinke and Kris T Delaney
* Developed in the group of Chris G. Van de Walle at UC Santa Barbara

# Structure of code

```
├── README.md
└── src
    ├── direct
    │   ├── base.F90
    │   ├── bf_auger.F90
    │   ├── bf_auger_sub_hhe.F90
    │   ├── check_kind.f90
    │   ├── energies.F90
    │   ├── inpfile.f90
    │   ├── kgrids.f90
    │   ├── klists.F90
    │   ├── make.depend
    │   ├── Makefile
    │   ├── me_direct.F90
    │   ├── me_fft_direct.F90
    │   └── me_test.f90
    └── indirect
        ├── base.F90
        ├── calculate_auger_phonon.F90
        ├── fftw3.f
        ├── inpfile.f90
        ├── Makefile
        ├── me_fft.F90
        └── tableio.f90
```
