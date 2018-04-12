//=====================================================================
// Project : 4 core MESI cache design
// File Name : cache_wrapper_lv2.sv
// Description : wrap cache block and controller of lv2
// Designer : Yuhao Yang
//=====================================================================
// Notable Change History:
// Date By   Version Change Description
// 2016/4/7  1.0     Initial Release
//=====================================================================
module cache_wrapper_lv2 #(
                            parameter ASSOC              = `ASSOC_LV2              ,
                            parameter ASSOC_WID          = `ASSOC_WID_LV2          ,
                            parameter DATA_WID           = `DATA_WID_LV2           ,
                            parameter ADDR_WID           = `ADDR_WID_LV2           ,
                            parameter INDEX_MSB          = `INDEX_MSB_LV2          ,
                            parameter INDEX_LSB          = `INDEX_LSB_LV2          ,
                            parameter TAG_MSB            = `TAG_MSB_LV2            ,
                            parameter TAG_LSB            = `TAG_LSB_LV2            ,
                            parameter OFFSET_MSB         = `OFFSET_MSB_LV2         ,
                            parameter OFFSET_LSB         = `OFFSET_LSB_LV2         ,
                            parameter CACHE_DATA_WID     = `CACHE_DATA_WID_LV2     ,
                            parameter CACHE_TAG_MSB      = `CACHE_TAG_MSB_LV2      ,
                            parameter CACHE_TAG_LSB      = `CACHE_TAG_LSB_LV2      ,
                            parameter CACHE_DEPTH        = `CACHE_DEPTH_LV2        , 
                            parameter CACHE_MESI_MSB     = `CACHE_MESI_MSB_LV2     ,
                            parameter CACHE_MESI_LSB     = `CACHE_MESI_LSB_LV2     ,
                            parameter CACHE_TAG_MESI_WID = `CACHE_TAG_MESI_WID_LV2 ,
                            parameter MESI_WID           = `MESI_WID_LV2           ,
                            parameter OFFSET_WID         = `OFFSET_WID_LV2         ,
                            parameter TAG_WID            = `TAG_WID_LV2
                          )
                         (
                          input                               clk                  ,
                          inout      [DATA_WID - 1       : 0] data_bus_lv1_lv2     ,
                          input      [ADDR_WID - 1       : 0] addr_bus_lv1_lv2     ,
                          inout      [DATA_WID - 1       : 0] data_bus_lv2_mem     ,
                          output     [ADDR_WID - 1       : 0] addr_bus_lv2_mem     ,
                          output                              mem_rd               ,
                          output                              mem_wr               ,
                          input                               mem_wr_done          ,
                          input                               lv2_rd               ,
                          input                               lv2_wr               ,
                          output                              lv2_wr_done          ,
                          input                               cp_in_cache          ,
                          input                               bus_lv1_lv2_gnt_lv2  ,
                          output                              bus_lv1_lv2_req_lv2  ,
                          output                              data_in_bus_lv1_lv2  ,
                          input                               data_in_bus_lv2_mem  
                         ); 
           
    wire     [ASSOC_WID - 1      : 0] lru_replacement_proc ;
    wire     [ASSOC_WID - 1      : 0] blk_accessed_main    ;
    
    cache_block_lv2 inst_cache_block_lv2 ( 
                                            .clk                  (clk),
                                            .lru_replacement_proc (lru_replacement_proc),
                                            .blk_accessed_main    (blk_accessed_main),
                                            .data_bus_lv1_lv2     (data_bus_lv1_lv2),
                                            .addr_bus_lv1_lv2     (addr_bus_lv1_lv2),
                                            .data_bus_lv2_mem     (data_bus_lv2_mem),
                                            .addr_bus_lv2_mem     (addr_bus_lv2_mem),
                                            .mem_rd               (mem_rd),
                                            .mem_wr               (mem_wr),
                                            .mem_wr_done          (mem_wr_done),
                                            .lv2_rd               (lv2_rd),
                                            .lv2_wr               (lv2_wr),
                                            .lv2_wr_done          (lv2_wr_done),
                                            .cp_in_cache          (cp_in_cache),
                                            .bus_lv1_lv2_gnt_lv2  (bus_lv1_lv2_gnt_lv2),
                                            .bus_lv1_lv2_req_lv2  (bus_lv1_lv2_req_lv2),
                                            .data_in_bus_lv1_lv2  (data_in_bus_lv1_lv2),
                                            .data_in_bus_lv2_mem  (data_in_bus_lv2_mem)
                                        );
                                        
    cache_controller_lv2 inst_cache_controller_lv2 (
                                                    .blk_accessed_main    (blk_accessed_main),
                                                    .lru_replacement_proc (lru_replacement_proc),
                                                    .lv2_rd               (lv2_rd),
                                                    .lv2_wr               (lv2_wr),
                                                    .addr_bus_lv1_lv2     (addr_bus_lv1_lv2)
                                                    );

endmodule
