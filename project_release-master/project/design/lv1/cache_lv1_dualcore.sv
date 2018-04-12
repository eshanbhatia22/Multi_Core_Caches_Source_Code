//=====================================================================
// Project : 4 core MESI cache design
// File Name : cache_lv1_dualcore.sv
// Description : lv1 cache for 2 cores
// Designer : Yuhao Yang
//=====================================================================
// Notable Change History:
// Date By   Version Change Description
// 2016/10/27  1.0     Initial Release
//=====================================================================

`define DUAL_CORE

module cache_lv1_dualcore #(
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
                            parameter TAG_WID            = `TAG_WID_LV1            ,
                            parameter IL_DL_ADDR_BOUND   = `IL_DL_ADDR_BOUND
                             )
                             (
                             input                           clk                     ,
                             inout  [DATA_WID - 1       : 0] data_bus_lv1_lv2        ,
                             output [ADDR_WID - 1       : 0] addr_bus_lv1_lv2        ,
                             inout  [DATA_WID - 1       : 0] data_bus_cpu_lv1_0      ,
                             input  [ADDR_WID - 1       : 0] addr_bus_cpu_lv1_0      ,
                             inout  [DATA_WID - 1       : 0] data_bus_cpu_lv1_1      ,
                             input  [ADDR_WID - 1       : 0] addr_bus_cpu_lv1_1      ,
                             output                          lv2_rd                  ,
                             output                          lv2_wr                  ,
                             input                           lv2_wr_done             ,
                             output                          cp_in_cache             ,
                             input  [           3       : 0] cpu_rd                  ,
                             input  [           3       : 0] cpu_wr                  ,
                             output [           3       : 0] cpu_wr_done             ,
                             input  [           3       : 0] bus_lv1_lv2_gnt_proc    ,
                             output [           3       : 0] bus_lv1_lv2_req_proc    ,
                             input  [           3       : 0] bus_lv1_lv2_gnt_snoop   ,
                             output [           3       : 0] bus_lv1_lv2_req_snoop   ,
                             output [           3       : 0] data_in_bus_cpu_lv1     ,
                             inout                           data_in_bus_lv1_lv2                  

                         );
                             
    wire [3 : 0] lv2_rd_uni;
    wire [3 : 0] lv2_wr_uni;
    wire [3 : 0] cp_in_cache_uni;
    wire [3 : 0] shared_local;
    wire         shared;
    wire         bus_rd;
    wire         bus_rdx;
    wire [3 : 0] invalidation_done;
    wire         all_invalidation_done;
    wire         invalidate;
    
    assign lv2_rd                = | lv2_rd_uni;
    assign lv2_wr                = | lv2_wr_uni;
    assign shared                = | shared_local;
    assign all_invalidation_done = | invalidation_done;
    assign cp_in_cache           = | cp_in_cache_uni;
    
    assign lv2_rd_uni        [3 : 2] = 2'b00;
    assign lv2_wr_uni        [3 : 2] = 2'b00;
    assign cp_in_cache_uni   [3 : 2] = 2'b00;
    assign shared_local      [3 : 2] = 2'b00;
    assign invalidation_done [3 : 2] = 2'b00;
    
    assign cpu_wr_done           [3 : 2] = 2'b00;
    assign bus_lv1_lv2_req_proc  [3 : 2] = 2'b00;
    assign bus_lv1_lv2_req_snoop [3 : 2] = 2'b00;
    assign data_in_bus_cpu_lv1   [3 : 2] = 2'b00;
    
    cache_lv1_unicore #( 
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
                        .LRU_VAR_WID(LRU_VAR_WID),
                        .NUM_OF_SETS(NUM_OF_SETS),
                        .TAG_WID(TAG_WID),
                        .IL_DL_ADDR_BOUND(IL_DL_ADDR_BOUND)
                    )
                     inst_cache_lv1_unicore_0 ( 
                                                .clk(clk),
                                                .core_id(2'b00),
                                                .data_bus_lv1_lv2(data_bus_lv1_lv2),
                                                .addr_bus_lv1_lv2(addr_bus_lv1_lv2),
                                                .data_bus_cpu_lv1(data_bus_cpu_lv1_0),
                                                .addr_bus_cpu_lv1(addr_bus_cpu_lv1_0),
                                                .lv2_rd(lv2_rd_uni[0]),
                                                .lv2_wr(lv2_wr_uni[0]),
                                                .lv2_wr_done(lv2_wr_done),
                                                .cp_in_cache(cp_in_cache_uni[0]),
                                                .cpu_rd(cpu_rd[0]),
                                                .cpu_wr(cpu_wr[0]),
                                                .cpu_wr_done(cpu_wr_done[0]),
                                                .bus_rd(bus_rd),         
                                                .bus_rdx(bus_rdx),         
                                                .bus_lv1_lv2_gnt_proc(bus_lv1_lv2_gnt_proc[0]),
                                                .bus_lv1_lv2_req_proc(bus_lv1_lv2_req_proc[0]),
                                                .bus_lv1_lv2_gnt_snoop(bus_lv1_lv2_gnt_snoop[0]),
                                                .bus_lv1_lv2_req_snoop(bus_lv1_lv2_req_snoop[0]),
                                                .data_in_bus_cpu_lv1(data_in_bus_cpu_lv1[0]),
                                                .data_in_bus_lv1_lv2(data_in_bus_lv1_lv2),
                                                .invalidate(invalidate),
                                                .all_invalidation_done(all_invalidation_done),
                                                .shared(shared),
                                                .shared_local(shared_local[0]),
                                                .invalidation_done(invalidation_done[0])
                                            );
                                            
    cache_lv1_unicore #( 
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
                        .LRU_VAR_WID(LRU_VAR_WID),
                        .NUM_OF_SETS(NUM_OF_SETS),
                        .TAG_WID(TAG_WID),
                        .IL_DL_ADDR_BOUND(IL_DL_ADDR_BOUND)
                    )
                     inst_cache_lv1_unicore_1 ( 
                                                .clk(clk),
                                                .core_id(2'b01),
                                                .data_bus_lv1_lv2(data_bus_lv1_lv2),
                                                .addr_bus_lv1_lv2(addr_bus_lv1_lv2),
                                                .data_bus_cpu_lv1(data_bus_cpu_lv1_1),
                                                .addr_bus_cpu_lv1(addr_bus_cpu_lv1_1),
                                                .lv2_rd(lv2_rd_uni[1]),
                                                .lv2_wr(lv2_wr_uni[1]),
                                                .lv2_wr_done(lv2_wr_done),
                                                .cp_in_cache(cp_in_cache_uni[1]),
                                                .cpu_rd(cpu_rd[1]),
                                                .cpu_wr(cpu_wr[1]),
                                                .cpu_wr_done(cpu_wr_done[1]),
                                                .bus_rd(bus_rd),             
                                                .bus_rdx(bus_rdx),             
                                                .bus_lv1_lv2_gnt_proc(bus_lv1_lv2_gnt_proc[1]),
                                                .bus_lv1_lv2_req_proc(bus_lv1_lv2_req_proc[1]),
                                                .bus_lv1_lv2_gnt_snoop(bus_lv1_lv2_gnt_snoop[1]),
                                                .bus_lv1_lv2_req_snoop(bus_lv1_lv2_req_snoop[1]),
                                                .data_in_bus_cpu_lv1(data_in_bus_cpu_lv1[1]),
                                                .data_in_bus_lv1_lv2(data_in_bus_lv1_lv2),
                                                .invalidate(invalidate),
                                                .all_invalidation_done(all_invalidation_done),
                                                .shared(shared),
                                                .shared_local(shared_local[1]),
                                                .invalidation_done(invalidation_done[1])
                                            );
                                            

endmodule
