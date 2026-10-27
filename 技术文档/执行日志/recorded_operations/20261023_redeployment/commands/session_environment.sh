export TZ=Asia/Shanghai LC_ALL=C.UTF-8 TEAM_ID=GEMwhu PYTHONDONTWRITEBYTECODE=1
export DEPLOY_BASE=/root/gemwhu-stage1-20261023
export ORIGINAL='/mnt/d/Desktop/全国RISC-V高水平创新及应用大赛-CIE-香山社区-RISC-V应用创新赛道/香山向量点积加速引擎-官网提交/相关证明材料'
export RECORD_OUT='/mnt/d/Desktop/全国RISC-V高水平创新及应用大赛-CIE-香山社区-RISC-V应用创新赛道/香山向量点积加速引擎-官网提交/相关证明材料/recorded_operations/20261023_redeployment'
export VDOT_TOOLS="$DEPLOY_BASE/tools"
export DOWNLOADS="$DEPLOY_BASE/downloads"
export SUBMISSION="$DEPLOY_BASE/materials"
export PS4='+[$(date --iso-8601=seconds)] ${BASH_SOURCE}:${LINENO}: '
PS1='GEMwhu stage1 \w # '
printf '\n=== Real local redevelopment %s ===\n' "$(date --iso-8601=seconds)"
printf 'Full XiangShan processor builds belong to the existing supercomputer work.\n'
printf 'This session reinstalls the local WSL tools and executes local checks.\n'
