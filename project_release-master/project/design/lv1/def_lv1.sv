//=====================================================================
// Project : 4 core MESI cache design
// File Name : def_lv1.sv
// Description : define constant macros for level 1
// Designer : Yuhao Yang
//=====================================================================
// Notable Change History:
// Date By   Version Change Description
// 2016//  1.0     Initial Release
//=====================================================================

// 256KB 4-way associative

`define INDEX_WID_LV1 		       14
`define ASSOC_WID_LV1 		        2  
`define OFFSET_WID_LV1  		    2
`define BYTE_WID_LV1 		        3
`define ADDR_WID_LV1 		       32
`define DATA_WID_LV1               32
`define MESI_WID_LV1 		        2
`define IL_DL_ADDR_BOUND           32'h3FFF_FFFF


`define ASSOC_LV1               (1<< (`ASSOC_WID_LV1))  // number of ways
`define TAG_WID_LV1 		    ((`ADDR_WID_LV1) - (`OFFSET_WID_LV1) - (`INDEX_WID_LV1))
`define CACHE_DATA_WID_LV1 		(1<<((`OFFSET_WID_LV1) + (`BYTE_WID_LV1)))

// calculation for LRU structure
`define NUM_OF_SETS_LV1 		(1<<(`INDEX_WID_LV1))
`define LRU_VAR_WID_LV1 		((1<<`ASSOC_WID_LV1)-1)  // 

// cache structure parameter calculation
`define CACHE_TAG_MESI_WID_LV1 	((`TAG_WID_LV1) + (`MESI_WID_LV1))
`define NUM_OF_BLK_LV1 		    (1<<((`INDEX_WID_LV1)+(`ASSOC_WID_LV1)))
`define CACHE_DEPTH_LV1         `NUM_OF_BLK_LV1

// each Address input segregation - bit_wise
`define OFFSET_LSB_LV1 		0
`define OFFSET_MSB_LV1 		(`OFFSET_WID_LV1 - 1)
`define INDEX_LSB_LV1 		(`OFFSET_WID_LV1)
`define INDEX_MSB_LV1 		((`OFFSET_WID_LV1) + (`INDEX_WID_LV1) - 1)
`define TAG_LSB_LV1 		((`OFFSET_WID_LV1) + (`INDEX_WID_LV1)) 
`define TAG_MSB_LV1 		31

// each cache line segregation - bit_wise
`define CACHE_TAG_MSB_LV1 		((`MESI_WID_LV1) + (`TAG_WID_LV1) - 1)
`define CACHE_TAG_LSB_LV1 		(`MESI_WID_LV1)
`define CACHE_MESI_MSB_LV1 		((`MESI_WID_LV1) - 1)
`define CACHE_MESI_LSB_LV1 		0
`define CACHE_DATA_MSB_LV1 		((`CACHE_DATA_WID_LV1) - 1)
`define CACHE_DATA_LSB_LV1 		0

`define CACHE_CURRENT_MESI cache_proc_contr[{index_proc,blk_access_proc}][CACHE_MESI_MSB : CACHE_MESI_LSB]
`define CACHE_CURRENT_TAG  cache_proc_contr[{index_proc,blk_access_proc}][CACHE_TAG_MSB : CACHE_TAG_LSB]

`define CACHE_CURRENT_MESI_PROC `CACHE_CURRENT_MESI
`define CACHE_CURRENT_TAG_PROC  `CACHE_CURRENT_TAG
`define CACHE_CURRENT_MESI_SNOOP cache_proc_contr[{index_snoop,blk_access_snoop}][CACHE_MESI_MSB : CACHE_MESI_LSB]


