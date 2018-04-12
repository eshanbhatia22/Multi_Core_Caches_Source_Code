//=====================================================================
// Project : 4 core MESI cache design
// File Name : cache_lv1_unicore.sv
// Description : lv cache for a single core
// Designer : Yuhao Yang
//=====================================================================
// Notable Change History:
// Date By   Version Change Description
// 2016/4/23  1.0     Initial Release
//=====================================================================

module cache_lv1_unicore #(
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
                             )(
                             input                           clk                     ,
                             input  [1                  : 0] core_id                 ,
                             inout  [DATA_WID - 1       : 0] data_bus_lv1_lv2        ,
                             inout  [ADDR_WID - 1       : 0] addr_bus_lv1_lv2        ,
                             inout  [DATA_WID - 1       : 0] data_bus_cpu_lv1        ,
                             input  [ADDR_WID - 1       : 0] addr_bus_cpu_lv1        ,
                             output                          lv2_rd                  ,
                             output                          lv2_wr                  ,
                             input                           lv2_wr_done             ,
                             input                           cpu_rd                  ,
                             input                           cpu_wr                  ,
                             output                          cpu_wr_done             ,
                             inout                           bus_rd                  ,
                             inout                           bus_rdx                 ,
                             input                           bus_lv1_lv2_gnt_proc    ,
                             output                          bus_lv1_lv2_req_proc    ,
                             input                           bus_lv1_lv2_gnt_snoop   ,
                             output                          bus_lv1_lv2_req_snoop   ,
                             output                          data_in_bus_cpu_lv1     ,
                             inout                           data_in_bus_lv1_lv2     ,
                             inout                           invalidate              ,
                             input                           all_invalidation_done   ,
                             input                           shared                  ,                             
                             output                          shared_local            ,
                             output                          cp_in_cache             ,
                             output                          invalidation_done              

                         );

    
    
    wire cpu_rd_dl;
    wire cpu_rd_il;
    wire cpu_wr_dl;
    wire lv2_rd_dl;
    wire lv2_rd_il;
    wire bus_lv1_lv2_req_proc_dl;
    wire bus_lv1_lv2_req_proc_il;
    wire data_in_bus_cpu_lv1_dl;
    wire data_in_bus_cpu_lv1_il;
    
    assign cpu_wr_dl = (addr_bus_cpu_lv1 > IL_DL_ADDR_BOUND)? cpu_wr : 1'b0;
    assign cpu_rd_dl = (addr_bus_cpu_lv1 > IL_DL_ADDR_BOUND)? cpu_rd : 1'b0;  

    assign cpu_rd_il = (addr_bus_cpu_lv1 <= (IL_DL_ADDR_BOUND & 32'h0fffffff))? cpu_rd : 1'b0;
    
    assign lv2_rd               = lv2_rd_dl | lv2_rd_il;
    assign bus_lv1_lv2_req_proc = bus_lv1_lv2_req_proc_dl | bus_lv1_lv2_req_proc_il;
    assign data_in_bus_cpu_lv1  = data_in_bus_cpu_lv1_dl | data_in_bus_cpu_lv1_il;
    
    cache_wrapper_lv1_dl #( 
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
                            .TAG_WID(TAG_WID)
                        )
                         inst_cache_wrapper_lv1_dl ( 
                                                    .clk(clk),
                                                    .core_id(core_id),
                                                    .data_bus_lv1_lv2(data_bus_lv1_lv2),
                                                    .addr_bus_lv1_lv2(addr_bus_lv1_lv2),
                                                    .data_bus_cpu_lv1(data_bus_cpu_lv1),
                                                    .addr_bus_cpu_lv1(addr_bus_cpu_lv1),
                                                    .lv2_rd(lv2_rd_dl),
                                                    .lv2_wr(lv2_wr),
                                                    .lv2_wr_done(lv2_wr_done),
                                                    .cpu_rd(cpu_rd_dl),
                                                    .cpu_wr(cpu_wr_dl),
                                                    .cpu_wr_done(cpu_wr_done),
                                                    .bus_rd(bus_rd),
                                                    .bus_rdx(bus_rdx),
                                                    .bus_lv1_lv2_gnt_proc(bus_lv1_lv2_gnt_proc),
                                                    .bus_lv1_lv2_req_proc_dl(bus_lv1_lv2_req_proc_dl),
                                                    .bus_lv1_lv2_gnt_snoop(bus_lv1_lv2_gnt_snoop),
                                                    .bus_lv1_lv2_req_snoop(bus_lv1_lv2_req_snoop),
                                                    .data_in_bus_cpu_lv1_dl(data_in_bus_cpu_lv1_dl),
                                                    .data_in_bus_lv1_lv2(data_in_bus_lv1_lv2),
                                                    .invalidate(invalidate),
                                                    .all_invalidation_done(all_invalidation_done),
                                                    .shared(shared),
                                                    .shared_local(shared_local),
                                                    .cp_in_cache(cp_in_cache),
                                                    .invalidation_done(invalidation_done)
                                                );
                                            
    cache_wrapper_lv1_il #( 
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
                            .TAG_WID(TAG_WID)
                        )
                         inst_cache_wrapper_lv1_il ( 
                                                    .clk(clk),
                                                    .data_bus_lv1_lv2(data_bus_lv1_lv2),
                                                    .addr_bus_lv1_lv2(addr_bus_lv1_lv2),
                                                    .data_bus_cpu_lv1(data_bus_cpu_lv1),
                                                    .addr_bus_cpu_lv1(addr_bus_cpu_lv1),
                                                    .lv2_rd(lv2_rd_il),
                                                    .cpu_rd(cpu_rd_il),
                                                    .bus_lv1_lv2_gnt_proc(bus_lv1_lv2_gnt_proc),
                                                    .bus_lv1_lv2_req_proc_il(bus_lv1_lv2_req_proc_il),
                                                    .data_in_bus_cpu_lv1_il(data_in_bus_cpu_lv1_il),
                                                    .data_in_bus_lv1_lv2(data_in_bus_lv1_lv2)
                                                );


                           
endmodule
