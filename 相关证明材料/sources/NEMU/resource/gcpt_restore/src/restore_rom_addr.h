/***************************************************************************************
* Copyright (c) 2020-2022 Institute of Computing Technology, Chinese Academy of Sciences
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#ifndef __RESTORE_ROM_ADDR__
#define __RESTORE_ROM_ADDR__

#define CPT_MAGIC_BUMBER        0xbeef
#define BOOT_CODE               0x0

#define BOOT_FLAG_ADDR          0xECDB0
#define PC_CPT_ADDR             0xECDB8
#define MODE_CPT_ADDR           0xECDC0
#define MTIME_CPT_ADDR          0xECDC8
#define MTIME_CMP_CPT_ADDR      0xECDD0
#define MISC_DONE_CPT_ADDR      0xECDD8
#define MISC_RESERVE            0xECDE0

#define INT_REG_CPT_ADDR        0xEDDE0
#define INT_REG_DONE            0xEDEE0

#define FLOAT_REG_CPT_ADDR      0xEDEE8
#define FLOAT_REG_DONE          0xEDFE8

#define CSR_REG_CPT_ADDR        0xEDFF0
#define CSR_REG_DONE            0xF5FF0
#define CSR_RESERVE             0xF5FF8

#define VECTOR_REG_CPT_ADDR     0xFDFF8
#define VECTOR_REG_DONE         0xFFFF8

#define GCPT_CHECKPOINT_VERSION 0xFFFFC

#ifdef CONFIG_CLINT_MMIO
#define CLINT_MMIO              CONFIG_CLINT_MMIO
#else
#define CLINT_MMIO              0x38000000
#endif
#define CLINT_MTIMECMP          0x4000
#define CLINT_MTIME             0xBFF8

#define RESTORE_GOOD            0x0
#define RESTORE_MODE_BAD        0x1
#define GCPT_INCOMPLETE         0x2
#define VERSION_NOT_MATCH       0x3

#define COMPLETE_FLAG           0xcaff
#define GCPT_VERSION            0x20231222

#define MISA_V 0x200000
#define MISA_H 0x80

#endif //__RESTORE_ROM_ADDR__
