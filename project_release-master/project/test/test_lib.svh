//=====================================================================
// Project: 4 core MESI cache design
// File Name: test_lib.svh
// Description: Base test class and list of tests
// Designers: Keerthana
//=====================================================================
//TODO: add your testcase files in here
`include "base_test.sv"
`include "read_miss_icache.sv"
`include "read_hit_icache.sv"
`include "write_miss_icache.sv"
`include "Addr_Seg_Cornercase.sv"
`include "DCACHE_RW_E_LRU.sv"
`include "DCACHE_RW_E_LRU_WRITE.sv"
`include "DCACHE_RW_M_LRU.sv"
`include "DCACHE_RW_M_LRU_WRITE.sv"
`include "DCACHE_RW_S_LRU.sv"
`include "DCACHE_RW_S_LRU_WRITE.sv"
`include "DCACHE_RW_read0_1_2.sv"
`include "DCACHE_RW_read0_1.sv"
`include "DCACHE_RW_read0_1_write1.sv"
`include "DCACHE_RW_read0_1_write2.sv"
`include "DCACHE_RW_read0_write1.sv"
`include "DCACHE_RW_read_all4.sv"
`include "DCACHE_RW_read_hit.sv"
`include "DCACHE_RW_read_miss.sv"
`include "DCACHE_RW_write0_0.sv"
`include "DCACHE_RW_write0_1.sv"
`include "DCACHE_RW_write0_read2.sv"
`include "DCACHE_RW_write_hit.sv"
`include "DCACHE_RW_write_miss.sv"
`include "L2_read_miss.sv"
`include "L2_read_hit.sv"
`include "L2_read_miss_blk_replaced.sv"
`include "L2_write_hit.sv"
`include "L2_write_miss.sv"
`include "L2_write_miss_blk_replaced.sv"
`include "read_miss_dcache_snoop_service.sv"
