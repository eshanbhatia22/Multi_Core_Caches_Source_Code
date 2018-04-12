//=====================================================================
// Project : 4 core MESI cache design
// File Name : cache_top.sv
// Description : cache top level, including lv1 and lv2
// Designer : Yuhao Yang
//=====================================================================
// Notable Change History:
// Date By   Version Change Description
// 2016/4/25  1.0     Initial Release
//=====================================================================

module cache_top # (
                    parameter ASSOC_LV1              = `ASSOC_LV1              ,
                    parameter ASSOC_WID_LV1          = `ASSOC_WID_LV1          ,
                    parameter DATA_WID_LV1           = `DATA_WID_LV1           ,
                    parameter ADDR_WID_LV1           = `ADDR_WID_LV1           ,
                    parameter INDEX_MSB_LV1          = `INDEX_MSB_LV1          ,
                    parameter INDEX_LSB_LV1          = `INDEX_LSB_LV1          ,
                    parameter TAG_MSB_LV1            = `TAG_MSB_LV1            ,
                    parameter TAG_LSB_LV1            = `TAG_LSB_LV1            ,
                    parameter OFFSET_MSB_LV1         = `OFFSET_MSB_LV1         ,
                    parameter OFFSET_LSB_LV1         = `OFFSET_LSB_LV1         ,
                    parameter CACHE_DATA_WID_LV1     = `CACHE_DATA_WID_LV1     ,
                    parameter CACHE_TAG_MSB_LV1      = `CACHE_TAG_MSB_LV1      ,
                    parameter CACHE_TAG_LSB_LV1      = `CACHE_TAG_LSB_LV1      ,
                    parameter CACHE_DEPTH_LV1        = `CACHE_DEPTH_LV1        , 
                    parameter CACHE_MESI_MSB_LV1     = `CACHE_MESI_MSB_LV1     ,
                    parameter CACHE_MESI_LSB_LV1     = `CACHE_MESI_LSB_LV1     ,
                    parameter CACHE_TAG_MESI_WID_LV1 = `CACHE_TAG_MESI_WID_LV1 ,
                    parameter MESI_WID_LV1           = `MESI_WID_LV1           ,
                    parameter OFFSET_WID_LV1         = `OFFSET_WID_LV1         ,
                    parameter LRU_VAR_WID_LV1        = `LRU_VAR_WID_LV1        ,
                    parameter NUM_OF_SETS_LV1        = `NUM_OF_SETS_LV1        ,
                    parameter TAG_WID_LV1            = `TAG_WID_LV1            ,
                    parameter IL_DL_ADDR_BOUND_LV1   = `IL_DL_ADDR_BOUND       ,

                    parameter ASSOC_LV2              = `ASSOC_LV2              ,
                    parameter ASSOC_WID_LV2          = `ASSOC_WID_LV2          ,
                    parameter DATA_WID_LV2           = `DATA_WID_LV2           ,
                    parameter ADDR_WID_LV2           = `ADDR_WID_LV2           ,
                    parameter INDEX_MSB_LV2          = `INDEX_MSB_LV2          ,
                    parameter INDEX_LSB_LV2          = `INDEX_LSB_LV2          ,
                    parameter TAG_MSB_LV2            = `TAG_MSB_LV2            ,
                    parameter TAG_LSB_LV2            = `TAG_LSB_LV2            ,
                    parameter OFFSET_MSB_LV2         = `OFFSET_MSB_LV2         ,
                    parameter OFFSET_LSB_LV2         = `OFFSET_LSB_LV2         ,
                    parameter CACHE_DATA_WID_LV2     = `CACHE_DATA_WID_LV2     ,
                    parameter CACHE_TAG_MSB_LV2      = `CACHE_TAG_MSB_LV2      ,
                    parameter CACHE_TAG_LSB_LV2      = `CACHE_TAG_LSB_LV2      ,
                    parameter CACHE_DEPTH_LV2        = `CACHE_DEPTH_LV2        , 
                    parameter CACHE_MESI_MSB_LV2     = `CACHE_MESI_MSB_LV2     ,
                    parameter CACHE_MESI_LSB_LV2     = `CACHE_MESI_LSB_LV2     ,
                    parameter CACHE_TAG_MESI_WID_LV2 = `CACHE_TAG_MESI_WID_LV2 ,
                    parameter MESI_WID_LV2           = `MESI_WID_LV2           ,
                    parameter OFFSET_WID_LV2         = `OFFSET_WID_LV2         ,
                    parameter TAG_WID_LV2            = `TAG_WID_LV2
                   )(
                    input                           clk                     ,
                    inout  [DATA_WID_LV1 - 1   : 0] data_bus_cpu_lv1_0      ,
                    input  [ADDR_WID_LV1 - 1   : 0] addr_bus_cpu_lv1_0      ,
                    inout  [DATA_WID_LV1 - 1   : 0] data_bus_cpu_lv1_1      ,
                    input  [ADDR_WID_LV1 - 1   : 0] addr_bus_cpu_lv1_1      ,
                    inout  [DATA_WID_LV1 - 1   : 0] data_bus_cpu_lv1_2      ,
                    input  [ADDR_WID_LV1 - 1   : 0] addr_bus_cpu_lv1_2      ,
                    inout  [DATA_WID_LV1 - 1   : 0] data_bus_cpu_lv1_3      ,
                    input  [ADDR_WID_LV1 - 1   : 0] addr_bus_cpu_lv1_3      ,
                    input  [           3       : 0] cpu_rd                  ,
                    input  [           3       : 0] cpu_wr                  ,
                    output [           3       : 0] cpu_wr_done             ,
                    input  [           3       : 0] bus_lv1_lv2_gnt_proc    ,
                    output [           3       : 0] bus_lv1_lv2_req_proc    ,
                    input  [           3       : 0] bus_lv1_lv2_gnt_snoop   ,
                    output [           3       : 0] bus_lv1_lv2_req_snoop   ,
                    output [           3       : 0] data_in_bus_cpu_lv1     ,
                     
                    inout  [DATA_WID_LV2 - 1   : 0] data_bus_lv2_mem        ,
                    output [ADDR_WID_LV2 - 1   : 0] addr_bus_lv2_mem        ,
                    output                          mem_rd                  ,
                    output                          mem_wr                  ,
                    input                           mem_wr_done             ,
                    input                           bus_lv1_lv2_gnt_lv2     ,
                    output                          bus_lv1_lv2_req_lv2     ,
                    input                           data_in_bus_lv2_mem
                     
                   );
                   
    wire [DATA_WID_LV1 - 1   : 0] data_bus_lv1_lv2    ;
    wire [ADDR_WID_LV1 - 1   : 0] addr_bus_lv1_lv2    ;
    wire                          lv2_rd              ;
    wire                          lv2_wr              ;
    wire                          lv2_wr_done         ;
    wire                          cp_in_cache         ;   
    wire                          data_in_bus_lv1_lv2 ; 
    
    cache_wrapper_lv2 #( 
                        .ASSOC(ASSOC_LV2),
                        .ASSOC_WID(ASSOC_WID_LV2),
                        .DATA_WID(DATA_WID_LV2),
                        .ADDR_WID(ADDR_WID_LV2),
                        .INDEX_MSB(INDEX_MSB_LV2),
                        .INDEX_LSB(INDEX_LSB_LV2),
                        .TAG_MSB(TAG_MSB_LV2),
                        .TAG_LSB(TAG_LSB_LV2),
                        .OFFSET_MSB(OFFSET_MSB_LV2),
                        .OFFSET_LSB(OFFSET_LSB_LV2),
                        .CACHE_DATA_WID(CACHE_DATA_WID_LV2),
                        .CACHE_TAG_MSB(CACHE_TAG_MSB_LV2),
                        .CACHE_TAG_LSB(CACHE_TAG_LSB_LV2),
                        .CACHE_DEPTH(CACHE_DEPTH_LV2),
                        .CACHE_MESI_MSB(CACHE_MESI_MSB_LV2),
                        .CACHE_MESI_LSB(CACHE_MESI_LSB_LV2),
                        .CACHE_TAG_MESI_WID(CACHE_TAG_MESI_WID_LV2),
                        .MESI_WID(MESI_WID_LV2),
                        .OFFSET_WID(OFFSET_WID_LV2),
                        .TAG_WID(TAG_WID_LV2)
                    )
                     inst_cache_wrapper_lv2 ( 
                                            .clk(clk),
                                            .data_bus_lv1_lv2(data_bus_lv1_lv2),
                                            .addr_bus_lv1_lv2(addr_bus_lv1_lv2),
                                            .data_bus_lv2_mem(data_bus_lv2_mem),
                                            .addr_bus_lv2_mem(addr_bus_lv2_mem),
                                            .mem_rd(mem_rd),
                                            .mem_wr(mem_wr),
                                            .mem_wr_done(mem_wr_done),
                                            .lv2_rd(lv2_rd),
                                            .lv2_wr(lv2_wr),
                                            .lv2_wr_done(lv2_wr_done),
                                            .cp_in_cache(cp_in_cache),
                                            .bus_lv1_lv2_gnt_lv2(bus_lv1_lv2_gnt_lv2),
                                            .bus_lv1_lv2_req_lv2(bus_lv1_lv2_req_lv2),
                                            .data_in_bus_lv1_lv2(data_in_bus_lv1_lv2),
                                            .data_in_bus_lv2_mem(data_in_bus_lv2_mem)
                                        );
`ifdef DUAL_CORE

    cache_lv1_dualcore #( 
                            .ASSOC(ASSOC_LV1),
                            .ASSOC_WID(ASSOC_WID_LV1),
                            .DATA_WID(DATA_WID_LV1),
                            .ADDR_WID(ADDR_WID_LV1),
                            .INDEX_MSB(INDEX_MSB_LV1),
                            .INDEX_LSB(INDEX_LSB_LV1),
                            .TAG_MSB(TAG_MSB_LV1),
                            .TAG_LSB(TAG_LSB_LV1),
                            .OFFSET_MSB(OFFSET_MSB_LV1),
                            .OFFSET_LSB(OFFSET_LSB_LV1),
                            .CACHE_DATA_WID(CACHE_DATA_WID_LV1),
                            .CACHE_TAG_MSB(CACHE_TAG_MSB_LV1),
                            .CACHE_TAG_LSB(CACHE_TAG_LSB_LV1),
                            .CACHE_DEPTH(CACHE_DEPTH_LV1),
                            .CACHE_MESI_MSB(CACHE_MESI_MSB_LV1),
                            .CACHE_MESI_LSB(CACHE_MESI_LSB_LV1),
                            .CACHE_TAG_MESI_WID(CACHE_TAG_MESI_WID_LV1),
                            .MESI_WID(MESI_WID_LV1),
                            .OFFSET_WID(OFFSET_WID_LV1),
                            .LRU_VAR_WID(LRU_VAR_WID_LV1),
                            .NUM_OF_SETS(NUM_OF_SETS_LV1),
                            .TAG_WID(TAG_WID_LV1),
                            .IL_DL_ADDR_BOUND(IL_DL_ADDR_BOUND_LV1)
                        )
                         inst_cache_lv1_dualcore ( 
                                                    .clk(clk),
                                                    .data_bus_lv1_lv2(data_bus_lv1_lv2),
                                                    .addr_bus_lv1_lv2(addr_bus_lv1_lv2),
                                                    .data_bus_cpu_lv1_0(data_bus_cpu_lv1_0),
                                                    .addr_bus_cpu_lv1_0(addr_bus_cpu_lv1_0),
                                                    .data_bus_cpu_lv1_1(data_bus_cpu_lv1_1),
                                                    .addr_bus_cpu_lv1_1(addr_bus_cpu_lv1_1),
                                                    .lv2_rd(lv2_rd),
                                                    .lv2_wr(lv2_wr),
                                                    .lv2_wr_done(lv2_wr_done),
                                                    .cp_in_cache(cp_in_cache),
                                                    .cpu_rd(cpu_rd),
                                                    .cpu_wr(cpu_wr),
                                                    .cpu_wr_done(cpu_wr_done),
                                                    .bus_lv1_lv2_gnt_proc(bus_lv1_lv2_gnt_proc),
                                                    .bus_lv1_lv2_req_proc(bus_lv1_lv2_req_proc),
                                                    .bus_lv1_lv2_gnt_snoop(bus_lv1_lv2_gnt_snoop),
                                                    .bus_lv1_lv2_req_snoop(bus_lv1_lv2_req_snoop),
                                                    .data_in_bus_cpu_lv1(data_in_bus_cpu_lv1),
                                                    .data_in_bus_lv1_lv2(data_in_bus_lv1_lv2)
                                                );


`else

    cache_lv1_multicore #( 
                            .ASSOC(ASSOC_LV1),
                            .ASSOC_WID(ASSOC_WID_LV1),
                            .DATA_WID(DATA_WID_LV1),
                            .ADDR_WID(ADDR_WID_LV1),
                            .INDEX_MSB(INDEX_MSB_LV1),
                            .INDEX_LSB(INDEX_LSB_LV1),
                            .TAG_MSB(TAG_MSB_LV1),
                            .TAG_LSB(TAG_LSB_LV1),
                            .OFFSET_MSB(OFFSET_MSB_LV1),
                            .OFFSET_LSB(OFFSET_LSB_LV1),
                            .CACHE_DATA_WID(CACHE_DATA_WID_LV1),
                            .CACHE_TAG_MSB(CACHE_TAG_MSB_LV1),
                            .CACHE_TAG_LSB(CACHE_TAG_LSB_LV1),
                            .CACHE_DEPTH(CACHE_DEPTH_LV1),
                            .CACHE_MESI_MSB(CACHE_MESI_MSB_LV1),
                            .CACHE_MESI_LSB(CACHE_MESI_LSB_LV1),
                            .CACHE_TAG_MESI_WID(CACHE_TAG_MESI_WID_LV1),
                            .MESI_WID(MESI_WID_LV1),
                            .OFFSET_WID(OFFSET_WID_LV1),
                            .LRU_VAR_WID(LRU_VAR_WID_LV1),
                            .NUM_OF_SETS(NUM_OF_SETS_LV1),
                            .TAG_WID(TAG_WID_LV1),
                            .IL_DL_ADDR_BOUND(IL_DL_ADDR_BOUND_LV1)
                        )
                         inst_cache_lv1_multicore ( 
                                                    .clk(clk),
                                                    .data_bus_lv1_lv2(data_bus_lv1_lv2),
                                                    .addr_bus_lv1_lv2(addr_bus_lv1_lv2),
                                                    .data_bus_cpu_lv1_0(data_bus_cpu_lv1_0),
                                                    .addr_bus_cpu_lv1_0(addr_bus_cpu_lv1_0),
                                                    .data_bus_cpu_lv1_1(data_bus_cpu_lv1_1),
                                                    .addr_bus_cpu_lv1_1(addr_bus_cpu_lv1_1),
                                                    .data_bus_cpu_lv1_2(data_bus_cpu_lv1_2),
                                                    .addr_bus_cpu_lv1_2(addr_bus_cpu_lv1_2),
                                                    .data_bus_cpu_lv1_3(data_bus_cpu_lv1_3),
                                                    .addr_bus_cpu_lv1_3(addr_bus_cpu_lv1_3),
                                                    .lv2_rd(lv2_rd),
                                                    .lv2_wr(lv2_wr),
                                                    .lv2_wr_done(lv2_wr_done),
                                                    .cp_in_cache(cp_in_cache),
                                                    .cpu_rd(cpu_rd),
                                                    .cpu_wr(cpu_wr),
                                                    .cpu_wr_done(cpu_wr_done),
                                                    .bus_lv1_lv2_gnt_proc(bus_lv1_lv2_gnt_proc),
                                                    .bus_lv1_lv2_req_proc(bus_lv1_lv2_req_proc),
                                                    .bus_lv1_lv2_gnt_snoop(bus_lv1_lv2_gnt_snoop),
                                                    .bus_lv1_lv2_req_snoop(bus_lv1_lv2_req_snoop),
                                                    .data_in_bus_cpu_lv1(data_in_bus_cpu_lv1),
                                                    .data_in_bus_lv1_lv2(data_in_bus_lv1_lv2)
                                                );


`endif
                                        


endmodule                    
