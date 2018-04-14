//=====================================================================
// Project : 4 core MESI cache design
// File Name : cache_block_lv1_il.sv
// Description : cache block for level 1 instruction level
// Designer : Yuhao Yang
//=====================================================================
// Notable Change History:
// Date By   Version Change Description
// 2016/4/12  1.0     Initial Release
//=====================================================================

//`include "def_lv1.sv"
module cache_block_lv1_il #(
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
                             input   [ASSOC_WID - 1      : 0] lru_replacement_proc    ,
                             output                           data_in_bus_cpu_lv1_il  ,
                             input                            data_in_bus_lv1_lv2     ,
                             output  [ASSOC_WID - 1      : 0] blk_accessed_main       
                             ); 
    parameter INVALID 	= 2'b00;
    parameter VALID	    = 2'b01;
    
    wire [TAG_MSB    : TAG_LSB   ] tag_proc;
    wire [INDEX_MSB  : INDEX_LSB ] index_proc;
    wire [OFFSET_MSB : OFFSET_LSB] blk_offset_proc;
    
    wire [ASSOC*MESI_WID - 1 : 0] cache_proc_mesi;
    wire [ASSOC*TAG_WID - 1  : 0] cache_proc_tag;
    wire [ASSOC - 1          : 0] access_blk_proc;    
    wire                          blk_hit_proc;
    wire                          blk_free;
    wire [ASSOC_WID - 1      : 0] free_blk_num;
    wire [ASSOC_WID - 1      : 0] blk_access_proc;  

    blk_hit_proc_md #(
                       .ASSOC(ASSOC) 
                      )
                      inst_hit_proc_md(
                                       .cmd_rd          (cpu_rd)          ,
                                       .cmd_wr          (1'b0)           ,
                                       .access_blk_proc (access_blk_proc) ,
                                       .blk_hit_proc    (blk_hit_proc)
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
                                                .cmd_wr          (1'b0),
                                                .address         (addr_bus_cpu_lv1),
                                                .index_proc      (index_proc),
                                                .tag_proc        (tag_proc),
                                                .blk_offset_proc (blk_offset_proc)
                                            );
                                            
    free_blk_md #(
                .ASSOC(ASSOC),
                .ASSOC_WID(ASSOC_WID),
                .MESI_WID(MESI_WID),
                .INVALID(INVALID)
                )
                inst_free_blk_md (
                                    .blk_hit_proc    (blk_hit_proc),
                                    .cache_proc_mesi (cache_proc_mesi),
                                    .blk_free        (blk_free),
                                    .free_blk_num    (free_blk_num)
                                 );
    
    access_blk_proc_md #(
                       .ASSOC(ASSOC),
                       .ASSOC_WID(ASSOC_WID),
                       .MESI_WID(MESI_WID),
                       .TAG_WID(TAG_WID),
                       .TAG_MSB(TAG_MSB),
                       .TAG_LSB(TAG_LSB),
                       .INVALID(INVALID)
                      ) 
                      inst_access_blk_proc_md( 
                                        .cmd_rd          (cpu_rd),
                                        .cmd_wr          (1'b0),
                                        .tag_proc        (tag_proc),
                                        .cache_proc_mesi (cache_proc_mesi),
                                        .cache_proc_tag  (cache_proc_tag),
                                        .access_blk_proc (access_blk_proc)
                                      );
                                      
    blk_to_be_accessed_md #(
                             .ASSOC(ASSOC),
                             .ASSOC_WID(ASSOC_WID)
                            )
                            inst_blk_to_be_accessed_md (
                                                         .blk_hit_proc         (blk_hit_proc),
                                                         .access_blk_proc      (access_blk_proc),
                                                         .lru_replacement_proc (lru_replacement_proc),
                                                         .free_blk_num         (free_blk_num),
                                                         .blk_free             (blk_free),
                                                         .blk_access_proc      (blk_access_proc)
                                                        ); 
    main_func_lv1_il #( 
                        .ASSOC(ASSOC),
                        .ASSOC_WID(ASSOC_WID),
                        .DATA_WID(DATA_WID),
                        .ADDR_WID(ADDR_WID),
                        .INDEX_MSB(INDEX_MSB),
                        .INDEX_LSB(INDEX_LSB),
                        .TAG_MSB(TAG_MSB),
                        .TAG_LSB(TAG_LSB),
                        .CACHE_DATA_WID(CACHE_DATA_WID),
                        .CACHE_TAG_MSB(CACHE_TAG_MSB),
                        .CACHE_TAG_LSB(CACHE_TAG_LSB),
                        .CACHE_DEPTH(CACHE_DEPTH),
                        .CACHE_MESI_MSB(CACHE_MESI_MSB),
                        .CACHE_MESI_LSB(CACHE_MESI_LSB),
                        .CACHE_TAG_MESI_WID(CACHE_TAG_MESI_WID),
                        .MESI_WID(MESI_WID),
                        .OFFSET_WID(OFFSET_WID)
                        )
                        inst_main_func_lv1_il( 
                                                .clk                     (clk),
                                                .data_bus_lv1_lv2        (data_bus_lv1_lv2),
                                                .addr_bus_lv1_lv2        (addr_bus_lv1_lv2),
                                                .data_bus_cpu_lv1        (data_bus_cpu_lv1),
                                                .addr_bus_cpu_lv1        (addr_bus_cpu_lv1),
                                                .lv2_rd                  (lv2_rd),
                                                .cpu_rd                  (cpu_rd),
                                                .bus_lv1_lv2_gnt_proc    (bus_lv1_lv2_gnt_proc),
                                                .bus_lv1_lv2_req_proc_il (bus_lv1_lv2_req_proc_il),
                                                .index_proc              (index_proc),
                                                .tag_proc                (tag_proc),
                                                .blk_hit_proc            (blk_hit_proc),
                                                .blk_free                (blk_free),
                                                .blk_access_proc         (blk_access_proc),
                                                .lru_replacement_proc    (lru_replacement_proc),
                                                .data_in_bus_cpu_lv1_il  (data_in_bus_cpu_lv1_il),
						// BUG 3 : tied to 1'b1
                                                //.data_in_bus_lv1_lv2     (1'b1),
                                                .data_in_bus_lv1_lv2     (data_in_bus_lv1_lv2),
                                                .blk_accessed_main       (blk_accessed_main),
                                                .cache_proc_mesi         (cache_proc_mesi),
                                                .cache_proc_tag          (cache_proc_tag)
                                             );                                                        
                         
endmodule

