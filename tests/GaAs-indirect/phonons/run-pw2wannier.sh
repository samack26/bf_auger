#!/bin/bash -l

#SBATCH -J GaAs
#SBATCH -p debug
#SBATCH -C knl,quad,cache
#SBATCH -N 1
#SBATCH -t 00:30:00

export OMP_PROC_BIND=true
export OMP_PLACES=threads

export OMP_NUM_THREADS=4
export OMP_STACKSIZE=256m
export MKL_FAST_MEMORY_LIMIT=0

module load craype-hugepages2M

for((i=1;i<=6;i++))
do
cd phonon_$i
../makennkp.sh
mv GaAs.nnkp _ph0
cp ../pw2wannier.in _ph0
rm slurm-*
rm GaAs.wfc*
cd _ph0
srun -n 68 -c4 --cpu_bind=cores ~/espresso/QE-6.2/qe-6.2/bin/pw2wannier90.x < pw2wannier.in > pw2wannier.out
mv GaAs.eig ../
mv UNK* ../
cd ..
cd ..
done