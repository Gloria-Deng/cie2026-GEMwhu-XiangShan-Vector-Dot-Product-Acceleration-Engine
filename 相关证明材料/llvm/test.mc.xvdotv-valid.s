





# CHECK: vdot.vv $0, $0, $0  # encoding: [0x57,0x20,0x00,0xb2]
vdot.vv v0, v0, v0


# CHECK: vdot.vv $8, $9, $10  # encoding: [0x57,0x24,0x95,0xb2]
vdot.vv v8, v9, v10


# CHECK: vdot.vv $1, $2, $3  # encoding: [0xd7,0xa0,0x21,0xb2]
vdot.vv v1, v2, v3


# CHECK: vdot.vv $31, $16, $17  # encoding: [0xd7,0xaf,0x08,0xb3]
vdot.vv v31, v16, v17


# CHECK: vdot.vv $24, $25, $26  # encoding: [0x57,0x2c,0x9d,0xb3]
vdot.vv v24, v25, v26
