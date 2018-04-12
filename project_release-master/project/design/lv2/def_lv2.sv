//=====================================================================
// Project : 4 core MESI cache design
// File Name : def_lv2.sv
// Description : define constant macros for level 2
// Designer : Yuhao Yang
//=====================================================================
// Notable Change History:
// Date By   Version Change Description
// 2016//  1.0     Initial Release
//=====================================================================

// 8 MBytes, 8-way associative

`define INDEX_WID_LV2 		       18
`define ASSOC_WID_LV2 		        3  
`define OFFSET_WID_LV2  		    2
`define BYTE_WID_LV2 		        3
`define ADDR_WID_LV2 		       32
`define DATA_WID_LV2               32
`define MESI_WID_LV2 		        2


`define ASSOC_LV2               (1<< (`ASSOC_WID_LV2))  // number of ways
`define TAG_WID_LV2 		    ((`ADDR_WID_LV2) - (`OFFSET_WID_LV2) - (`INDEX_WID_LV2))
`define CACHE_DATA_WID_LV2 		(1<<((`OFFSET_WID_LV2) + (`BYTE_WID_LV2)))

// calculation for LRU structure
`define NUM_OF_SETS_LV2 		(1<<(`INDEX_WID_LV2))
`define LRU_VAR_WID_LV2 		((1<<`ASSOC_WID_LV2)-1)  // 

// cache structure parameter calculation
`define CACHE_TAG_MESI_WID_LV2 	((`TAG_WID_LV2) + (`MESI_WID_LV2))
`define NUM_OF_BLK_LV2 		    (1<<((`INDEX_WID_LV2)+(`ASSOC_WID_LV2)))
`define CACHE_DEPTH_LV2         `NUM_OF_BLK_LV2

// each Address input segregation - bit_wise
`define OFFSET_LSB_LV2 		0
`define OFFSET_MSB_LV2 		(`OFFSET_WID_LV2 - 1)
`define INDEX_LSB_LV2 		(`OFFSET_WID_LV2)
`define INDEX_MSB_LV2 		((`OFFSET_WID_LV2) + (`INDEX_WID_LV2) - 1)
`define TAG_LSB_LV2 		((`OFFSET_WID_LV2) + (`INDEX_WID_LV2)) 
`define TAG_MSB_LV2 		31

// each cache line segregation - bit_wise
`define CACHE_TAG_MSB_LV2 		((`MESI_WID_LV2) + (`TAG_WID_LV2) - 1)
`define CACHE_TAG_LSB_LV2 		(`MESI_WID_LV2)
`define CACHE_MESI_MSB_LV2 		((`MESI_WID_LV2) - 1)
`define CACHE_MESI_LSB_LV2 		0
`define CACHE_DATA_MSB_LV2 		((`CACHE_DATA_WID_LV2) - 1)
`define CACHE_DATA_LSB_LV2 		0

`define CACHE_CURRENT_MESI cache_proc_contr[{index_proc,blk_access_proc}][CACHE_MESI_MSB : CACHE_MESI_LSB]
`define CACHE_CURRENT_TAG  cache_proc_contr[{index_proc,blk_access_proc}][CACHE_TAG_MSB : CACHE_TAG_LSB]

