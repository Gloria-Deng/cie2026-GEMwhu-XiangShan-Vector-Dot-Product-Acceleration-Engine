#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

static int nibble(char c)
{
    if (c >= '0' && c <= '9') return c - '0';
    if (c >= 'a' && c <= 'f') return c - 'a' + 10;
    if (c >= 'A' && c <= 'F') return c - 'A' + 10;
    return -1;
}

static int byte_at(const char *text, int lane)
{
    int offset = 30 - lane * 2;
    int hi = nibble(text[offset]);
    int lo = nibble(text[offset + 1]);
    if (hi < 0 || lo < 0) exit(2);
    return hi * 16 + lo;
}

int main(void)
{
    int index;
    char a[33], b[33], expected[33];
    int count = 0;
    while (scanf("%d %32s %32s %32s", &index, a, b, expected) == 4) {
        if (strlen(a) != 32 || strlen(b) != 32 || strlen(expected) != 32) return 2;
        int64_t sum = 0;
        for (int lane = 0; lane < 8; ++lane) {
            int av = byte_at(a, lane);
            int bv = byte_at(b, lane);
            if (av >= 128) av -= 256;
            if (bv >= 128) bv -= 256;
            sum += (int64_t)av * (int64_t)bv;
        }
        printf("%d %024x%08x\n", index, 0, (unsigned)(uint32_t)sum);
        ++count;
    }
    if (!feof(stdin) || count == 0) return 2;
    return 0;
}
