//=====================================================================
// Project : 4 core MESI cache design
// File Name : cache_controller_lv2.sv
// Description : cache controller for level 2
// Designer : Yuhao Yang
//=====================================================================
// Notable Change History:
// Date By   Version Change Description
// 2016/4/7  1.0     Initial Release
//=====================================================================

module cache_controller_lv2 #(
                                parameter ASSOC_WID   = `ASSOC_WID_LV2   ,
                                parameter INDEX_MSB   = `INDEX_MSB_LV2   ,
                                parameter INDEX_LSB   = `INDEX_LSB_LV2   ,
                                parameter LRU_VAR_WID = `LRU_VAR_WID_LV2 ,
                                parameter NUM_OF_SETS = `NUM_OF_SETS_LV2 ,
                                parameter ADDR_WID    = `ADDR_WID_LV2    ,
                                parameter OFFSET_MSB  = `OFFSET_MSB_LV2  ,
                                parameter OFFSET_LSB  = `OFFSET_LSB_LV2  ,
                                parameter TAG_MSB     = `TAG_MSB_LV2     ,
                                parameter TAG_LSB     = `TAG_LSB_LV2
                              )(
                                input  [ASSOC_WID - 1 : 0] blk_accessed_main    ,
                                output [ASSOC_WID - 1 : 0] lru_replacement_proc ,
                                input                      lv2_rd               ,
                                input                      lv2_wr               ,
                                input  [ADDR_WID - 1  : 0] addr_bus_lv1_lv2
                              );
                              
    wire [INDEX_MSB :   INDEX_LSB] index_proc;    
    wire [TAG_MSB    :    TAG_LSB] tag_proc;
    wire [OFFSET_MSB : OFFSET_LSB] blk_offset_proc;

    
    lru_block_lv2 # (
                     .ASSOC_WID   (ASSOC_WID),
                     .INDEX_MSB   (INDEX_MSB),
                     .INDEX_LSB   (INDEX_LSB),
                     .LRU_VAR_WID (LRU_VAR_WID),
                     .NUM_OF_SETS (NUM_OF_SETS)
                     )
                     inst_lru_block_lv2 (
                                          .index_proc(index_proc),
                                          .blk_accessed_main(blk_accessed_main),
                                          .lru_replacement_proc(lru_replacement_proc)
                                         );
                                    
    addr_segregator_proc #( 
                            .ADDR_WID(ADDR_WID),
                            .INDEX_MSB(INDEX_MSB),
                            .INDEX_LSB(INDEX_LSB),
                            .OFFSET_MSB(OFFSET_MSB),
                            .OFFSET_LSB(OFFSET_LSB),
                            .TAG_MSB(TAG_MSB),
                            .TAG_LSB(TAG_LSB)
                           )
                           inst_addr_segregator ( 
                                                .cmd_rd          (lv2_rd),
                                                .cmd_wr          (lv2_wr),
                                                .address         (addr_bus_lv1_lv2),
                                                .index_proc      (index_proc),
                                                .tag_proc        (tag_proc),
                                                .blk_offset_proc (blk_offset_proc)
                                            );
                              
endmodule
