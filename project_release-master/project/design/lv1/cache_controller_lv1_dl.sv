//=====================================================================
// Project : 4 core MESI cache design
// File Name : cache_controller_lv1_dl.sv
// Description : cache controller for level 1 data level
// Designer : Yuhao Yang
//=====================================================================
// Notable Change History:
// Date By   Version Change Description
// 2016/4/16  1.0     Initial Release
//=====================================================================

module cache_controller_lv1_dl #(
                                parameter ASSOC_WID   = `ASSOC_WID_LV1   ,
                                parameter INDEX_MSB   = `INDEX_MSB_LV1   ,
                                parameter INDEX_LSB   = `INDEX_LSB_LV1   ,
                                parameter LRU_VAR_WID = `LRU_VAR_WID_LV1 ,
                                parameter NUM_OF_SETS = `NUM_OF_SETS_LV1 ,
                                parameter ADDR_WID    = `ADDR_WID_LV1    ,
                                parameter MESI_WID    = `MESI_WID_LV1    ,
                                parameter OFFSET_MSB  = `OFFSET_MSB_LV1  ,
                                parameter OFFSET_LSB  = `OFFSET_LSB_LV1  ,
                                parameter TAG_MSB     = `TAG_MSB_LV1     ,
                                parameter TAG_LSB     = `TAG_LSB_LV1
                              )(
                                input  [ASSOC_WID - 1 : 0] blk_accessed_main    ,
                                output [ASSOC_WID - 1 : 0] lru_replacement_proc ,
                                input                      cpu_rd               ,
                                input                      cpu_wr               ,
                                input                      bus_rd               ,
                                input                      bus_rdx              ,
                                input                      invalidate           ,
                                input                      shared               ,
                                input  [MESI_WID - 1  : 0] current_mesi_proc    ,
                                input  [MESI_WID - 1  : 0] current_mesi_snoop   ,
                                output [MESI_WID - 1  : 0] updated_mesi_proc    ,
                                output [MESI_WID - 1  : 0] updated_mesi_snoop   ,
                                input  [ADDR_WID - 1  : 0] addr_bus_cpu_lv1
                              );
                              
    wire [INDEX_MSB :   INDEX_LSB] index_proc; 
    wire [TAG_MSB    :    TAG_LSB] tag_proc;
    wire [OFFSET_MSB : OFFSET_LSB] blk_offset_proc;
    
    
    lru_block_lv1 # (
                     .ASSOC_WID   (ASSOC_WID),
                     .INDEX_MSB   (INDEX_MSB),
                     .INDEX_LSB   (INDEX_LSB),
                     .LRU_VAR_WID (LRU_VAR_WID),
                     .NUM_OF_SETS (NUM_OF_SETS)
                     )
                     inst_lru_block_lv1 (
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
                                                .cmd_rd          (cpu_rd),
                                                .cmd_wr          (cpu_wr),
                                                .address         (addr_bus_cpu_lv1),
                                                .index_proc      (index_proc),
                                                .tag_proc        (tag_proc),
                                                .blk_offset_proc (blk_offset_proc)
                                            );
                                            
    mesi_fsm_lv1 #(
                   .MESI_WID(MESI_WID)
                   )
                   inst_mesi_fsm_lv1 ( 
                                        .cpu_rd(cpu_rd),
                                        .cpu_wr(cpu_wr),
                                        .bus_rd(bus_rd),
                                        .bus_rdx(bus_rdx),
                                        .invalidate(invalidate),
                                        .shared(shared),
                                        .current_mesi_proc(current_mesi_proc),
                                        .current_mesi_snoop(current_mesi_snoop),
                                        .updated_mesi_proc(updated_mesi_proc),
                                        .updated_mesi_snoop(updated_mesi_snoop)
                                    );

                    
                              
endmodule
