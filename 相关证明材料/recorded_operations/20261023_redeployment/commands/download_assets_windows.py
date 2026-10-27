from pathlib import Path
import urllib.request,urllib.parse,time
from datetime import datetime
W=Path(__file__).resolve().parent
D=W/'downloads';D.mkdir(exist_ok=True)
proxy=(W/'windows_proxy.txt').read_text(encoding='utf-8').strip()
opener=urllib.request.build_opener(urllib.request.ProxyHandler({'http':proxy,'https':proxy}))
items=[
 ('firtool.tar.gz','https://github.com/llvm/circt/releases/download/firtool-1.62.1/firrtl-bin-linux-x64.tar.gz'),
 ('riscv.tar.gz','https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v14.2.0-3/xpack-riscv-none-elf-gcc-14.2.0-3-linux-x64.tar.gz'),
 ('verilator.tar.gz','https://github.com/verilator/verilator/archive/refs/tags/v5.052.tar.gz')]
for name,url in items:
    target=D/name
    if target.exists():raise SystemExit('Choose a new download directory')
    print(datetime.now().astimezone().isoformat(),'DOWNLOAD',url,flush=True)
    with opener.open(url,timeout=90) as response,target.open('wb') as f:
        expected=int(response.headers.get('Content-Length','0'))
        total=0;last=time.monotonic()
        while block:=response.read(1024*1024):
            f.write(block);total+=len(block)
            if time.monotonic()-last>2:
                print(name,'received',total,'of',expected,'bytes',flush=True);last=time.monotonic()
    if expected and total!=expected:raise SystemExit('Incomplete download')
    print('DOWNLOAD_COMPLETE',name,total,flush=True)
