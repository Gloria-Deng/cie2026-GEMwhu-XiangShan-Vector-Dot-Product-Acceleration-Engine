
















#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>




static const char *VIRTUAL_DESC_TOKENS[] = {
    "VMnet", "VMware", "VirtualBox", "VBox", "vEthernet", "Hyper-V",
    "Loopback", "Tap", "TAP", "WAN Miniport", "PPTP", "Npcap", "aTrust",
    "Tunnelling", "Virtual Adapter"
};
#define VIRTUAL_DESC_TOKENS_N \
    ((int)(sizeof VIRTUAL_DESC_TOKENS / sizeof VIRTUAL_DESC_TOKENS[0]))

static int desc_is_virtual(const char *d) {
    int k;
    if (!d) return 0;
    for (k = 0; k < VIRTUAL_DESC_TOKENS_N; k++)
        if (*VIRTUAL_DESC_TOKENS[k] && strstr(d, VIRTUAL_DESC_TOKENS[k])) return 1;
    return 0;
}





static const char *drop_reason(unsigned iftype, int oper_up, const char *desc,
                               uint32_t a) {
    if ((a & 0xFF000000u) == 0x7F000000u) return "loopback";
    if (a == 0) return "zero";
    if ((a & 0xFFFF0000u) == 0xA9FE0000u) return "link_local_169_254";
    if (iftype == 24u || iftype == 23u || iftype == 131u || iftype == 22u)
        return "virtual_iftype";
    if (!oper_up) return "not_operational_up";
    if (desc_is_virtual(desc)) return "virtual_adapter_desc";
    return NULL;
}

#if defined(__unix__) || defined(__APPLE__)
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <ifaddrs.h>
#include <net/if.h>
#endif

#ifdef _WIN32








#include <windows.h>
#include <iphlpapi.h>
#endif

typedef struct {
    char ip[64];
    char cand[512];
    char ifaces[1024];
    char excl[1024];
    char egress[64];
    unsigned long sel_idx;
    int trunc;
} pool_t;

static void pool_init(pool_t *r) {
    snprintf(r->ip, sizeof r->ip, "unavailable");
    snprintf(r->cand, sizeof r->cand, "none");
    snprintf(r->ifaces, sizeof r->ifaces, "none");
    snprintf(r->excl, sizeof r->excl, "none");
    snprintf(r->egress, sizeof r->egress, "none");
    r->sel_idx = 0;
    r->trunc = 0;
}





static size_t row(char *buf, size_t used, size_t cap, const char *sep,
                  uint32_t a, unsigned long idx, const char *tail, const char *why,
                  int *trunc) {
    int need;
    if (used + 200 >= cap) { *trunc = 1; return used; }
    if (used) used += (size_t)snprintf(buf + used, cap - used, "%s", sep);
    need = snprintf(buf + used, cap - used, "%u.%u.%u.%u#idx%lu%s%s",
                    (a >> 24) & 0xFF, (a >> 16) & 0xFF, (a >> 8) & 0xFF, a & 0xFF, idx,
                    (why || tail) ? "#" : "", (why ? why : (tail ? tail : "")));
    if (need < 0 || (size_t)need >= cap - used) { *trunc = 1; return used; }
    return used + (size_t)need;
}

#ifdef _WIN32

typedef struct { unsigned type; unsigned oper; int up; char descr[132]; } ifinfo_t;





#define IFIDX_MAX 4096

static int read_if_table(ifinfo_t **out, unsigned long *n_out) {
    ULONG len = 0;
    DWORD rc = GetIfTable(NULL, &len, 0);
    PMIB_IFTABLE tab;
    ifinfo_t *v;
    DWORD i;
    if (rc != ERROR_INSUFFICIENT_BUFFER || len == 0) return 0;
    tab = (PMIB_IFTABLE) malloc(len);
    if (!tab) return 0;
    if (GetIfTable(tab, &len, 0) != NO_ERROR) { free(tab); return 0; }
    v = (ifinfo_t *) calloc(IFIDX_MAX, sizeof *v);
    if (!v) { free(tab); return 0; }
    for (i = 0; i < tab->dwNumEntries; i++) {
        MIB_IFROW *r = &tab->table[i];
        unsigned long k = r->dwIndex;
        DWORD dl = r->dwDescrLen;
        if (k >= IFIDX_MAX) continue;
        if (dl > sizeof v[i].descr - 1) dl = sizeof v[i].descr - 1;
        v[k].type = r->dwType;


        v[k].up = (r->dwOperStatus >= 3);
        v[k].oper = (unsigned) r->dwOperStatus;
        memcpy(v[k].descr, r->bDescr, dl);
        v[k].descr[dl] = '\0';
    }
    free(tab);
    *out = v;
    *n_out = IFIDX_MAX;
    return 1;
}

static unsigned long read_egress_index(void) {
    ULONG len = 0;
    DWORD rc = GetIpForwardTable(NULL, &len, 0), i;
    PMIB_IPFORWARDTABLE tab;
    unsigned long best = 0;
    DWORD best_metric = 0xFFFFFFFFu;
    if (rc != ERROR_INSUFFICIENT_BUFFER || len == 0) return 0;
    tab = (PMIB_IPFORWARDTABLE) malloc(len);
    if (!tab) return 0;
    if (GetIpForwardTable(tab, &len, 0) != NO_ERROR) { free(tab); return 0; }
    for (i = 0; i < tab->dwNumEntries; i++) {
        MIB_IPFORWARDROW *f = &tab->table[i];
        if (f->dwForwardDest == 0 && f->dwForwardMask == 0 &&
            f->dwForwardMetric1 < best_metric) {
            best_metric = f->dwForwardMetric1;
            best = f->dwForwardIfIndex;
        }
    }
    free(tab);
    return best;
}

static void win_pick(pool_t *r) {
    ULONG len = 0;
    DWORD rc = GetIpAddrTable(NULL, &len, 0), i;
    PMIB_IPADDRTABLE tab;
    ifinfo_t *info = NULL;
    unsigned long ninfo = 0, egress;
    unsigned long pick = 0xFFFFFFFFul;
    uint32_t pick_ip = 0;
    size_t uc = 0, ui = 0, ux = 0;
    int tc = 0, ti = 0, tx = 0;
    if (rc != ERROR_INSUFFICIENT_BUFFER || len == 0) return;
    tab = (PMIB_IPADDRTABLE) malloc(len);
    if (!tab) return;
    if (!read_if_table(&info, &ninfo)) { free(tab); return; }
    egress = read_egress_index();
    if (GetIpAddrTable(tab, &len, 0) != NO_ERROR) { free(tab); free(info); return; }
    for (i = 0; i < tab->dwNumEntries; i++) {
        uint32_t a = (uint32_t) ntohl(tab->table[i].dwAddr);
        unsigned long idx = (unsigned long) tab->table[i].dwIndex;
        const char *why;
        char tail[208];





        if (idx < ninfo)
            snprintf(tail, sizeof tail, "if%lu#st%lu#%s",
                     (unsigned long) info[idx].type,
                     (unsigned long) info[idx].oper, info[idx].descr);
        else
            snprintf(tail, sizeof tail, "if0#st0#no_interface_row");
        why = (idx < ninfo) ? drop_reason(info[idx].type, info[idx].up,
                                          info[idx].descr, a) : "no_interface_row";
        if (why) {
            char ex[256];
            snprintf(ex, sizeof ex, "%s#%s", tail, why);
            ux = row(r->excl, ux, sizeof r->excl, ";", a, idx, ex, NULL, &tx);
            continue;
        }
        uc = row(r->cand, uc, sizeof r->cand, ",", a, idx, NULL, NULL, &tc);
        ui = row(r->ifaces, ui, sizeof r->ifaces, ";", a, idx, tail, NULL, &ti);
        if (idx < pick) { pick = idx; pick_ip = a; }
    }
    if (pick_ip) {
        snprintf(r->ip, sizeof r->ip, "%u.%u.%u.%u", (pick_ip >> 24) & 0xFF,
                 (pick_ip >> 16) & 0xFF, (pick_ip >> 8) & 0xFF, pick_ip & 0xFF);
        r->sel_idx = pick;
    }
    if (egress) snprintf(r->egress, sizeof r->egress, "%lu", egress);
    r->trunc = (tc || ti || tx);
    free(tab);
    free(info);
}
static void win_host_name(char *out, size_t n) {
    DWORD cnt = (DWORD)n;
    if (GetComputerNameExA(ComputerNameDnsFullyQualified, out, &cnt) && cnt > 0) return;
    cnt = (DWORD)n;
    if (GetComputerNameExA(ComputerNameNetBIOS, out, &cnt) && cnt > 0) return;
    snprintf(out, n, "unknown");
}
#endif

static void print_all(const pool_t *r, const char *host) {
    printf("hello xiangshan, I am %s, IP address %s\n",
           getenv("TEAM_ID") ? getenv("TEAM_ID") : "TEAM_ID_UNSET", r->ip);
    printf("ip_candidates=%s selected_index=%lu rule=lowest_ifindex_not_virtual\n",
           r->cand, r->sel_idx);
    printf("ip_interfaces=%s\n", r->ifaces);
    printf("ip_excluded=%s\n", r->excl);
    printf("egress_index=%s rows_truncated=%d\n", r->egress, r->trunc);
    printf("host=%s compiler=%s\n", host,
           __VERSION__);
}

#if defined(__unix__) || defined(__APPLE__)
static void posix_pick(pool_t *r, char *host, size_t hostn) {
    struct ifaddrs *ifa = NULL, *p2 = NULL;
    unsigned long pick = 0xFFFFFFFFul;
    uint32_t pick_ip = 0;
    size_t uc = 0, ui = 0, ux = 0;
    int tc = 0, ti = 0, tx = 0;
    if (gethostname(host, (int)hostn) != 0) snprintf(host, hostn, "unknown");
    if (getifaddrs(&ifa) != 0) return;
    for (p2 = ifa; p2; p2 = p2->ifa_next) {
        struct sockaddr_in *sa = NULL;
        char nm[32], tail[64];
        uint32_t a;
        const char *why;
        unsigned long idx;
        if (!p2->ifa_addr || p2->ifa_addr->sa_family != AF_INET) continue;
        sa = (struct sockaddr_in *)p2->ifa_addr;
        a = (uint32_t)ntohl(sa->sin_addr.s_addr);
        snprintf(nm, sizeof nm, "%s", p2->ifa_name ? p2->ifa_name : "?");
        idx = (unsigned long)if_nametoindex(nm);




        why = drop_reason(0u, (p2->ifa_flags & IFF_UP) ? 1 : 0, nm, a);
        if (why) {
            ux = row(r->excl, ux, sizeof r->excl, ";", a, idx, NULL, why, &tx);
            continue;
        }
        uc = row(r->cand, uc, sizeof r->cand, ",", a, idx, NULL, NULL, &tc);
        snprintf(tail, sizeof tail, "if0#st0#%s", nm);
        ui = row(r->ifaces, ui, sizeof r->ifaces, ";", a, idx, tail, NULL, &ti);
        if (idx < pick) { pick = idx; pick_ip = a; }
    }
    freeifaddrs(ifa);
    if (pick_ip) {
        snprintf(r->ip, sizeof r->ip, "%u.%u.%u.%u", (pick_ip >> 24) & 0xFF,
                 (pick_ip >> 16) & 0xFF, (pick_ip >> 8) & 0xFF, pick_ip & 0xFF);
        r->sel_idx = pick;
    }
    r->trunc = (tc || ti || tx);
}
#endif

int main(void) {
    char host[256] = "unknown";
    pool_t r;
    pool_init(&r);
#ifdef _WIN32




    win_pick(&r);
    win_host_name(host, sizeof host);
#else
    posix_pick(&r, host, sizeof host);
#endif
    print_all(&r, host);
    return 0;
}
