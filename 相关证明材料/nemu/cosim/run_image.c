

#include <dlfcn.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "cosim_layout.h"
int main(int argc, char **argv) {
  if (argc != 6) return 2;
  void *h=dlopen(argv[1],RTLD_NOW|RTLD_GLOBAL);
  if (!h) { puts(dlerror()); return 2; }
  void (*init2)(unsigned)=dlsym(h,"difftest_init_v2");
  void (*init0)(void)=dlsym(h,"difftest_init");
  void (*mem)(uint64_t,void*,size_t,int)=dlsym(h,"difftest_memcpy");
  void (*reg)(void*,int)=dlsym(h,"difftest_regcpy");
  void (*step)(uint64_t)=dlsym(h,"difftest_exec");
  unsigned *size=dlsym(h,"DIFFTEST_REG_SIZE");
  if ((!init2&&!init0)||!mem||!reg||!step||!size||*size!=OFF_END) return 3;
  if (init2) init2(OFF_END); else init0();
  FILE *f=fopen(argv[2],"rb"); if(!f) return 4;
  fseek(f,0,SEEK_END); long length=ftell(f); rewind(f);
  if(length<=0||length>32*1024*1024) return 4;
  void *image=malloc(length); if(!image||fread(image,1,length,f)!=(size_t)length) return 4;
  fclose(f); mem(0x80000000,image,length,1); free(image);



  uint8_t blob[OFF_END]; reg(blob,0); memset(blob+OFF_GPR,0,32*8);
  uint64_t mode=3,pc=0x80000000,status=3ULL<<9;
  memcpy(blob+OFF_MODE,&mode,8); memcpy(blob+OFF_PC,&pc,8); memcpy(blob+OFF_MSTATUS,&status,8);
  reg(blob,1);
  uint64_t ok=strtoull(argv[3],0,0), bad=strtoull(argv[4],0,0), end=strtoull(argv[5],0,0);
  for(unsigned i=0;i<250000;i++) {
    step(1); reg(blob,0); memcpy(&pc,blob+OFF_PC,8);
    if(getenv("VDOT_IMAGE_TRACE")&&i<80) {
      uint64_t t0,t1,s0,vl,vt; memcpy(&t0,blob+OFF_GPR+5*8,8); memcpy(&t1,blob+OFF_GPR+6*8,8);
      memcpy(&s0,blob+OFF_GPR+8*8,8); memcpy(&vl,blob+OFF_VL,8); memcpy(&vt,blob+OFF_VTYPE,8);
      fprintf(stderr,"%u pc=%lx t0=%lx t1=%lx s0=%lx vl=%lu vt=%lx\n",i,(unsigned long)pc,(unsigned long)t0,(unsigned long)t1,(unsigned long)s0,(unsigned long)vl,(unsigned long)vt);
      fprintf(stderr,"v8=%02x%02x v9=%02x%02x v4=%02x%02x\n",blob[OFF_VR+8*16],blob[OFF_VR+8*16+1],blob[OFF_VR+9*16],blob[OFF_VR+9*16+1],blob[OFF_VR+4*16],blob[OFF_VR+4*16+1]);
    }
    if (pc==bad) { printf("IMAGE FAIL pc=0x%lx\n",(unsigned long)pc); return 1; }
    if ((end==0&&pc==ok)||(end!=0&&pc>=ok&&pc<end&&(pc-ok)%4==0)) {
      printf("IMAGE PASS pc=0x%lx instructions=%u\n",(unsigned long)pc,i+1); return 0;
    }
  }
  printf("IMAGE TIMEOUT pc=0x%lx\n",(unsigned long)pc); return 1;
}
