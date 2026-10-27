$Host.UI.RawUI.WindowTitle = 'GEMwhu Stage 1 Real Deployment'
Start-Transcript -LiteralPath 'D:\Desktop\全国RISC-V高水平创新及应用大赛-CIE-香山社区-RISC-V应用创新赛道\香山向量点积加速引擎-官网提交\相关证明材料\recorded_operations\20261023_redeployment\windows_terminal.txt'
Get-Date -Format o
Write-Host 'GEMwhu real local redevelopment; full processor builds are on the supercomputer.'
Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version,OSArchitecture
wsl --list --verbose
$env:TEAM_ID='GEMwhu'
python -B 'D:\Desktop\全国RISC-V高水平创新及应用大赛-CIE-香山社区-RISC-V应用创新赛道\香山向量点积加速引擎-官网提交\相关证明材料\stage1\hello_xiangshan_anyos.py'
& 'D:\Desktop\全国RISC-V高水平创新及应用大赛-CIE-香山社区-RISC-V应用创新赛道\香山向量点积加速引擎-官网提交\相关证明材料\stage1\hello_xiangshan.exe'
wsl -d Ubuntu-24.04 -u root --exec bash '/mnt/d/Desktop/全国RISC-V高水平创新及应用大赛-CIE-香山社区-RISC-V应用创新赛道/_文档整理工作_20261023/真实重新部署/start_session.sh'
Get-Date -Format o
Stop-Transcript
