#!/usr/bin/env python3





















from __future__ import annotations

from cffi import FFI

ffi = FFI()

ffi.cdef(
    r"""
    typedef uint32_t fstHandle;
    struct fstHierScope {
        unsigned char typ; const char *name; const char *component;
        uint32_t name_length; uint32_t component_length; };
    struct fstHierVar {
        unsigned char typ; unsigned char direction;
        unsigned char svt_workspace; unsigned char sdt_workspace;
        unsigned int  sxt_workspace; const char *name;
        uint32_t length; fstHandle handle; uint32_t name_length;
        unsigned is_alias; };
    struct fstHierAttr {
        unsigned char typ; unsigned char subtype;
        unsigned char enc_type; unsigned char name_length;
        const char *name; uint64_t arg; uint64_t argfrom; uint64_t argto;
        uint64_t argdot; uint32_t len; };
    typedef struct fstHier {
        unsigned char htyp;
        union {
            struct fstHierScope scope;
            struct fstHierVar var;
            struct fstHierAttr attr;
        } u;
    } fstHier;
    void *fstReaderOpen(const char *nam);
    void fstReaderClose(void *ctx);
    uint64_t fstReaderGetStartTime(void *ctx);
    uint64_t fstReaderGetEndTime(void *ctx);
    signed char fstReaderGetTimescale(void *ctx);
    int64_t fstReaderGetTimezero(void *ctx);
    uint64_t fstReaderGetVarCount(void *ctx);
    uint64_t fstReaderGetAliasCount(void *ctx);
    uint64_t fstReaderGetMaxHandle(void *ctx);
    int fstReaderIterateHierRewind(void *ctx);
    struct fstHier *fstReaderIterateHier(void *ctx);
    void fstReaderSetFacProcessMask(void *ctx, fstHandle facidx);
    void fstReaderClrFacProcessMaskAll(void *ctx);
    int fstReaderIterBlocks(void *ctx,
        void (*value_change_callback)(void *user_callback_data_pointer,
                                      uint64_t time, fstHandle facidx,
                                      const unsigned char *value),
        void *user_callback_data_pointer, void *vcdhandle);
    """
)

FST_HT_SCOPE, FST_HT_UPSCOPE, FST_HT_VAR = 0, 1, 2



PARENT_DIR = "." + "."

_CB_STATE = {"rows": []}


def safe_io_path(raw, what):

    text = str(raw)
    for part in text.replace("\\", "/").split("/"):
        if part == PARENT_DIR:
            raise SystemExit(f"unsafe {what} path (contains a parent-dir jump): {text}")
    return text


@ffi.callback("void(void *, uint64_t, uint32_t, const unsigned char *)")
def _collect_cb(user, t, facidx, value):
    _CB_STATE["rows"].append((t, facidx, ffi.string(value).decode("ascii", "replace")))


def open_dll(dll_path):

    from pathlib import Path
    checked = safe_io_path(dll_path, "dll")
    return ffi.dlopen(str(Path(checked).resolve()))


def iter_vars(lib, ctx):

    stack = []
    lib.fstReaderIterateHierRewind(ctx)
    while True:
        hier = lib.fstReaderIterateHier(ctx)
        if hier == ffi.NULL:
            break
        htyp = hier.htyp
        if htyp == FST_HT_SCOPE:
            stack.append(ffi.string(hier.u.scope.name).decode("utf-8", "replace"))
        elif htyp == FST_HT_UPSCOPE:
            if stack:
                stack.pop()
        elif htyp == FST_HT_VAR:
            name = ffi.string(hier.u.var.name).decode("utf-8", "replace")
            path = ".".join(stack + [name]) if stack else name
            yield hier.u.var.handle, hier.u.var.length, hier.u.var.is_alias, path


def open_fst(lib, fst_path):

    checked = safe_io_path(fst_path, "fst")
    try:
        checked.encode("ascii")
    except UnicodeEncodeError:
        raise SystemExit(
            "FST path contains non-ASCII characters; fstReaderOpen uses ANSI "
            "fopen on Windows. Copy the FST to an ASCII path first, e.g.:\n"
            "  mkdir -p /tmp/fstwork && cp '<your.fst>' /tmp/fstwork/vadd.fst"
        )
    ctx = lib.fstReaderOpen(checked.encode())
    if ctx == ffi.NULL:
        raise SystemExit(f"cannot open FST: {checked}")
    return ctx


def var_index(lib, fst_path):

    ctx = open_fst(lib, fst_path)
    index = {}
    for handle, width, is_alias, path in iter_vars(lib, ctx):
        if path not in index or is_alias == 0:
            index[path] = handle
    lib.fstReaderClose(ctx)
    return index


def extract_signals(lib, fst_path, handles):

    ctx = open_fst(lib, fst_path)
    lib.fstReaderClrFacProcessMaskAll(ctx)
    for h in handles:
        lib.fstReaderSetFacProcessMask(ctx, h)
    _CB_STATE["rows"] = []
    lib.fstReaderIterBlocks(ctx, _collect_cb, ffi.NULL, ffi.NULL)
    rows = sorted(_CB_STATE["rows"], key=lambda r: (r[0], r[1]))
    lib.fstReaderClose(ctx)
    return rows


def fst_info(lib, fst_path):

    ctx = open_fst(lib, fst_path)
    info = {
        "start_time": lib.fstReaderGetStartTime(ctx),
        "end_time": lib.fstReaderGetEndTime(ctx),
        "timescale_exp": lib.fstReaderGetTimescale(ctx),
        "var_count": lib.fstReaderGetVarCount(ctx),
        "alias_count": lib.fstReaderGetAliasCount(ctx),
        "max_handle": lib.fstReaderGetMaxHandle(ctx),
    }
    lib.fstReaderClose(ctx)
    return info
