//=====================================================================
// Project : 4 core MESI cache design
// File Name : cache_wrapper_lv1_il.sv
// Description : cache wrapper for level 1 instruction level
// Designer : Yuhao Yang
//=====================================================================
// Notable Change History:
// Date By   Version Change Description
// 2016/4/19  1.0     Initial Release
//=====================================================================

module cache_wrapper_lv1_il #(
                                parameter ASSOC              = `ASSOC_LV1              ,
                                parameter ASSOC_WID          = `ASSOC_WID_LV1          ,
                                parameter DATA_WID           = `DATA_WID_LV1           ,
                                parameter ADDR_WID           = `ADDR_WID_LV1           ,
                                parameter INDEX_MSB          = `INDEX_MSB_LV1          ,
                                parameter INDEX_LSB          = `INDEX_LSB_LV1          ,
                                parameter TAG_MSB            = `TAG_MSB_LV1            ,
                                parameter TAG_LSB            = `TAG_LSB_LV1            ,
                                parameter OFFSET_MSB         = `OFFSET_MSB_LV1         ,
                                parameter OFFSET_LSB         = `OFFSET_LSB_LV1         ,
                                parameter CACHE_DATA_WID     = `CACHE_DATA_WID_LV1     ,
                                parameter CACHE_TAG_MSB      = `CACHE_TAG_MSB_LV1      ,
                                parameter CACHE_TAG_LSB      = `CACHE_TAG_LSB_LV1      ,
                                parameter CACHE_DEPTH        = `CACHE_DEPTH_LV1        , 
                                parameter CACHE_MESI_MSB     = `CACHE_MESI_MSB_LV1     ,
                                parameter CACHE_MESI_LSB     = `CACHE_MESI_LSB_LV1     ,
                                parameter CACHE_TAG_MESI_WID = `CACHE_TAG_MESI_WID_LV1 ,
                                parameter MESI_WID           = `MESI_WID_LV1           ,
                                parameter OFFSET_WID         = `OFFSET_WID_LV1         ,
                                parameter LRU_VAR_WID        = `LRU_VAR_WID_LV1        ,
                                parameter NUM_OF_SETS        = `NUM_OF_SETS_LV1        ,
                                parameter TAG_WID            = `TAG_WID_LV1
                             )(
                                 input                            clk                     ,
                                 input   [DATA_WID - 1       : 0] data_bus_lv1_lv2        ,
                                 output  [ADDR_WID - 1       : 0] addr_bus_lv1_lv2        ,
                                 inout   [DATA_WID - 1       : 0] data_bus_cpu_lv1        ,
                                 input   [ADDR_WID - 1       : 0] addr_bus_cpu_lv1        ,
                                 output                           lv2_rd                  ,
                                 input                            cpu_rd                  ,
                                 input                            bus_lv1_lv2_gnt_proc    ,
                                 output                           bus_lv1_lv2_req_proc_il ,
                                 output                           data_in_bus_cpu_lv1_il  ,
                                 input                            data_in_bus_lv1_lv2      
                             );
                             
    wire [ASSOC_WID - 1 : 0] lru_replacement_proc;
    wire [ASSOC_WID - 1 : 0] blk_accessed_main;
    
    cache_controller_lv1_il #( 
                                .ASSOC_WID(ASSOC_WID),
                                .INDEX_MSB(INDEX_MSB),
                                .INDEX_LSB(INDEX_LSB),
                                .LRU_VAR_WID(LRU_VAR_WID),
                                .NUM_OF_SETS(NUM_OF_SETS),
                                .ADDR_WID(ADDR_WID),
                                .OFFSET_MSB(OFFSET_MSB),
                                .OFFSET_LSB(OFFSET_LSB),
                                .TAG_MSB(TAG_MSB),
                                .TAG_LSB(TAG_LSB)
                            )
                             inst_cache_controller_lv1_il ( 
                                                            .blk_accessed_main(blk_accessed_main),
                                                            .lru_replacement_proc(lru_replacement_proc),
                                                            .cpu_rd(cpu_rd),
                                                            .cpu_wr(1'b0),
                                                            .addr_bus_cpu_lv1(addr_bus_cpu_lv1)
                                                        );
                                                        
    cache_block_lv1_il #( 
                        .ASSOC(ASSOC),
                        .ASSOC_WID(ASSOC_WID),
                        .DATA_WID(DATA_WID),
                        .ADDR_WID(ADDR_WID),
                        .INDEX_MSB(INDEX_MSB),
                        .INDEX_LSB(INDEX_LSB),
                        .TAG_MSB(TAG_MSB),
                        .TAG_LSB(TAG_LSB),
                        .OFFSET_MSB(OFFSET_MSB),
                        .OFFSET_LSB(OFFSET_LSB),
                        .CACHE_DATA_WID(CACHE_DATA_WID),
                        .CACHE_TAG_MSB(CACHE_TAG_MSB),
                        .CACHE_TAG_LSB(CACHE_TAG_LSB),
                        .CACHE_DEPTH(CACHE_DEPTH),
                        .CACHE_MESI_MSB(CACHE_MESI_MSB),
                        .CACHE_MESI_LSB(CACHE_MESI_LSB),
                        .CACHE_TAG_MESI_WID(CACHE_TAG_MESI_WID),
                        .MESI_WID(MESI_WID),
                        .OFFSET_WID(OFFSET_WID),
                        .TAG_WID(TAG_WID)
                    )
                     inst_cache_block_lv1_il ( 
                                                .clk(clk),
                                                .data_bus_lv1_lv2(data_bus_lv1_lv2),
                                                .addr_bus_lv1_lv2(addr_bus_lv1_lv2),
                                                .data_bus_cpu_lv1(data_bus_cpu_lv1),
                                                .addr_bus_cpu_lv1(addr_bus_cpu_lv1),
                                                .lv2_rd(lv2_rd),
                                                .cpu_rd(cpu_rd),
                                                .bus_lv1_lv2_gnt_proc(bus_lv1_lv2_gnt_proc),
                                                .bus_lv1_lv2_req_proc_il(bus_lv1_lv2_req_proc_il),
                                                .lru_replacement_proc(lru_replacement_proc),
                                                .data_in_bus_cpu_lv1_il(data_in_bus_cpu_lv1_il),
                                                .data_in_bus_lv1_lv2(data_in_bus_lv1_lv2),
                                                .blk_accessed_main(blk_accessed_main)
                                            );

                             
                             
endmodule
