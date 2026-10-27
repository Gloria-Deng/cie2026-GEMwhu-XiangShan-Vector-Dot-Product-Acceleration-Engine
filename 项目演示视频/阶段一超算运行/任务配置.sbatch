#!/bin/bash
#SBATCH --job-name=video-vadd
#SBATCH --partition=hpxg
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=90000M
#SBATCH --time=02:30:00
#SBATCH --output=/project/chensiyuan/vdot/video_vadd_20261027_oLekMF/video-vadd-%j.txt
set -euo pipefail
export PATH=/usr/bin:/bin
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1
ulimit -s unlimited
cd /project/chensiyuan/vdot/video_vadd_20261027_oLekMF
printf 'single vadd execution on host: '
/usr/bin/hostname
/usr/bin/python3 -u /project/chensiyuan/vdot/slim_check_20261023/materials/scripts/run_one.py --run-root /project/chensiyuan/vdot/video_vadd_20261027_oLekMF --program vadd_full_register --cycles 30000
