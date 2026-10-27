#include <dlfcn.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "cosim_layout.h"

int main(int argc, char **argv) {
    setvbuf(stdout, NULL, _IONBF, 0);
    setvbuf(stderr, NULL, _IONBF, 0);
    if (argc != 6) return 2;
    void *handle = dlopen(argv[1], RTLD_NOW | RTLD_GLOBAL);
    if (!handle) { puts(dlerror()); return 3; }
    void (*init2)(unsigned) = dlsym(handle, "difftest_init_v2");
    void (*init0)(void) = dlsym(handle, "difftest_init");
    void (*setramsize)(size_t) = dlsym(handle, "difftest_set_ramsize");
    void (*memory)(uint64_t, void *, size_t, int) = dlsym(handle, "difftest_memcpy");
    void (*registers)(void *, int) = dlsym(handle, "difftest_regcpy");
    void (*step)(uint64_t) = dlsym(handle, "difftest_exec");
    unsigned *exported_size = dlsym(handle, "DIFFTEST_REG_SIZE");
    if ((!init2 && !init0) || !memory || !registers || !step || !exported_size || *exported_size != OFF_END) {
        puts("REFERENCE_INTERFACE_FAIL");
        return 4;
    }
    if (setramsize) setramsize(0x08000000ULL);
    if (init2) init2(OFF_END); else init0();
    FILE *input = fopen(argv[2], "rb");
    if (!input) { puts("IMAGE_OPEN_FAIL"); return 5; }
    fseek(input, 0, SEEK_END);
    long length = ftell(input);
    rewind(input);
    if (length <= 0 || length > 32 * 1024 * 1024) return 6;
    void *image = malloc((size_t)length);
    if (!image || fread(image, 1, (size_t)length, input) != (size_t)length) return 6;
    fclose(input);
    memory(0x80000000, image, (size_t)length, 1);
    free(image);
    uint8_t state[OFF_END];
    registers(state, 0);
    memset(state + OFF_GPR, 0, 32 * 8);
    uint64_t mode = 3, pc = 0x80000000, status = 3ULL << 9;
    memcpy(state + OFF_MODE, &mode, 8);
    memcpy(state + OFF_PC, &pc, 8);
    memcpy(state + OFF_MSTATUS, &status, 8);
    registers(state, 1);
    uint64_t lower = strtoull(argv[3], 0, 0);
    uint64_t bad = strtoull(argv[4], 0, 0);
    uint64_t upper = strtoull(argv[5], 0, 0);
    for (unsigned count = 0; count < 250000; count++) {
        step(1);
        registers(state, 0);
        memcpy(&pc, state + OFF_PC, 8);
        if (pc == bad) {
            printf("IMAGE FAIL pc=0x%llx\n", (unsigned long long)pc);
            return 1;
        }
        if (lower <= pc && pc < upper && (pc - lower) % 4 == 0) {
            printf("IMAGE PASS pc=0x%llx instructions=%u\n", (unsigned long long)pc, count + 1);
            return 0;
        }
    }
    printf("IMAGE TIMEOUT pc=0x%llx\n", (unsigned long long)pc);
    return 1;
}
