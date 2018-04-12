//=====================================================================
// Project : 4 core MESI cache design
// File Name : cache_block_lv1_dl.sv
// Description : cache block for level 1 data level
// Designer : Yuhao Yang
//=====================================================================
// Notable Change History:
// Date By   Version Change Description
// 2016/4/18  1.0     Initial Release
//=====================================================================

module cache_block_lv1_dl #(
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
                             output                          bus_lv1_lv2_req_proc_dl ,
                             input                           bus_lv1_lv2_gnt_snoop   ,
                             output                          bus_lv1_lv2_req_snoop   ,
                             input  [ASSOC_WID - 1      : 0] lru_replacement_proc    ,
                             output                          data_in_bus_cpu_lv1_dl  ,
                             inout                           data_in_bus_lv1_lv2     ,
                             inout                           invalidate              ,
                             input                           all_invalidation_done   ,
                             input  [MESI_WID - 1       : 0] updated_mesi_proc       ,
                             input  [MESI_WID - 1       : 0] updated_mesi_snoop      ,
                             output [MESI_WID - 1       : 0] current_mesi_proc       ,
                             output [MESI_WID - 1       : 0] current_mesi_snoop      ,
                             output                          shared_local            ,
                             output                          cp_in_cache             ,
                             output                          invalidation_done       ,
                             output [ASSOC_WID - 1      : 0] blk_accessed_main              
                         ); 

    parameter INVALID   = 2'b00;
    parameter SHARED    = 2'b01;
    parameter EXCLUSIVE = 2'b10;
    parameter MODIFIED  = 2'b11;
    
    wire [TAG_MSB    : TAG_LSB   ] tag_proc;
    wire [INDEX_MSB  : INDEX_LSB ] index_proc;
    wire [OFFSET_MSB : OFFSET_LSB] blk_offset_proc;
    
    wire [TAG_MSB    : TAG_LSB   ] tag_snoop;
    wire [INDEX_MSB  : INDEX_LSB ] index_snoop;
    wire [OFFSET_MSB : OFFSET_LSB] blk_offset_snoop;
    
    wire [ASSOC*TAG_WID - 1  : 0] cache_proc_tag;
    wire [ASSOC - 1          : 0] access_blk_proc;    
    wire                          blk_hit_proc;
    wire [ASSOC_WID - 1      : 0] blk_access_proc;    
    wire [ASSOC*MESI_WID - 1 : 0] cache_proc_mesi;
    
    wire [ASSOC*MESI_WID - 1 : 0] cache_snoop_mesi;
    wire [ASSOC*TAG_WID - 1  : 0] cache_snoop_tag;
    wire [ASSOC - 1          : 0] access_blk_snoop;    
    wire                          blk_hit_snoop;
    wire [ASSOC_WID - 1      : 0] blk_access_snoop;
    
    wire                          blk_free;
    wire [ASSOC_WID - 1      : 0] free_blk_num;
    
    
    blk_hit_proc_md #(
                       .ASSOC(ASSOC) 
                      )
                      inst_hit_proc_md(
                                       .cmd_rd          (cpu_rd)          ,
                                       .cmd_wr          (cpu_wr)           ,
                                       .access_blk_proc (access_blk_proc) ,
                                       .blk_hit_proc    (blk_hit_proc)
                                       );
                                       
    blk_hit_snoop_md #(
                       .ASSOC(ASSOC) 
                      )
                      inst_hit_snoop_md ( 
                                            .bus_rd           (bus_rd),
                                            .bus_rdx          (bus_rdx),
                                            .invalidate       (invalidate),
                                            .access_blk_snoop (access_blk_snoop),
                                            .blk_hit_snoop    (blk_hit_snoop)
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
                           inst_addr_segregator_proc ( 
                                                    .cmd_rd          (cpu_rd),
                                                    .cmd_wr          (cpu_wr),
                                                    .address         (addr_bus_cpu_lv1),
                                                    .index_proc      (index_proc),
                                                    .tag_proc        (tag_proc),
                                                    .blk_offset_proc (blk_offset_proc)
                                                    );
                                            
    addr_segregator_snoop #( 
                            .ADDR_WID(ADDR_WID),
                            .INDEX_MSB(INDEX_MSB),
                            .INDEX_LSB(INDEX_LSB),
                            .OFFSET_MSB(OFFSET_MSB),
                            .OFFSET_LSB(OFFSET_LSB),
                            .TAG_MSB(TAG_MSB),
                            .TAG_LSB(TAG_LSB)
                           )
                            inst_addr_segregator_snoop ( 
                                                        .bus_rd           (bus_rd),
                                                        .bus_rdx          (bus_rdx),
                                                        .invalidate       (invalidate),
                                                        .address          (addr_bus_lv1_lv2),
                                                        .index_snoop      (index_snoop),
                                                        .tag_snoop        (tag_snoop),
                                                        .blk_offset_snoop (blk_offset_snoop)
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
                                            .cmd_wr          (cpu_wr),
                                            .tag_proc        (tag_proc),
                                            .cache_proc_mesi (cache_proc_mesi),
                                            .cache_proc_tag  (cache_proc_tag),
                                            .access_blk_proc (access_blk_proc)
                                          );
                                      
    access_blk_snoop_md #(
                       .ASSOC(ASSOC),
                       .ASSOC_WID(ASSOC_WID),
                       .MESI_WID(MESI_WID),
                       .TAG_WID(TAG_WID),
                       .TAG_MSB(TAG_MSB),
                       .TAG_LSB(TAG_LSB),
                       .INVALID(INVALID)
                      )
                      inst_access_blk_snoop_md ( 
                                                .bus_rd           (bus_rd),
                                                .bus_rdx          (bus_rdx),
                                                .invalidate       (invalidate),
                                                .tag_snoop        (tag_snoop),
                                                .cache_snoop_mesi (cache_snoop_mesi),
                                                .cache_snoop_tag  (cache_snoop_tag),
                                                .access_blk_snoop (access_blk_snoop)
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
                                                        
    blk_to_be_accessed_snoop_md #(
                                 .ASSOC(ASSOC),
                                 .ASSOC_WID(ASSOC_WID)
                                )
                                 inst_blk_to_be_accessed_snoop_md( 
                                                                .blk_hit_snoop    (blk_hit_snoop),
                                                                .access_blk_snoop (access_blk_snoop),
                                                                .blk_access_snoop (blk_access_snoop)
                                                                );    

                                                                
    main_func_lv1_dl #( 
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
                        .OFFSET_WID(OFFSET_WID),
                        .TAG_WID(TAG_WID)
                        )
                        inst_main_func_lv1_dl ( 
                                                .clk                     (clk),
                                                .core_id                 (core_id),
                                                .data_bus_lv1_lv2        (data_bus_lv1_lv2),
                                                .addr_bus_lv1_lv2        (addr_bus_lv1_lv2),
                                                .data_bus_cpu_lv1        (data_bus_cpu_lv1),
                                                .addr_bus_cpu_lv1        (addr_bus_cpu_lv1),
                                                .lv2_rd                  (lv2_rd),
                                                .lv2_wr                  (lv2_wr),
                                                .lv2_wr_done             (lv2_wr_done), 
                                                .cpu_rd                  (cpu_rd),
                                                .cpu_wr                  (cpu_wr),
                                                .cpu_wr_done             (cpu_wr_done),
                                                .bus_rd                  (bus_rd),
                                                .bus_rdx                 (bus_rdx),
                                                .bus_lv1_lv2_gnt_proc    (bus_lv1_lv2_gnt_proc),
                                                .bus_lv1_lv2_req_proc_dl (bus_lv1_lv2_req_proc_dl),
                                                .bus_lv1_lv2_gnt_snoop   (bus_lv1_lv2_gnt_snoop),
                                                .bus_lv1_lv2_req_snoop   (bus_lv1_lv2_req_snoop),
                                                .index_proc              (index_proc),
                                                .index_snoop             (index_snoop),
                                                .tag_proc                (tag_proc),
                                                .tag_snoop               (tag_snoop),
                                                .blk_hit_proc            (blk_hit_proc),
                                                .blk_hit_snoop           (blk_hit_snoop),
                                                .blk_free                (blk_free),
                                                .blk_access_proc         (blk_access_proc),
                                                .blk_access_snoop        (blk_access_snoop),
                                                .lru_replacement_proc    (lru_replacement_proc),
                                                .data_in_bus_cpu_lv1_dl  (data_in_bus_cpu_lv1_dl),
                                                .data_in_bus_lv1_lv2     (data_in_bus_lv1_lv2),
                                                .invalidate              (invalidate),
                                                .all_invalidation_done   (all_invalidation_done),
                                                .updated_mesi_proc       (updated_mesi_proc),
                                                .updated_mesi_snoop      (updated_mesi_snoop),
                                                .current_mesi_proc       (current_mesi_proc),
                                                .current_mesi_snoop      (current_mesi_snoop),
                                                .shared_local            (shared_local),
                                                .cp_in_cache             (cp_in_cache),
                                                .invalidation_done       (invalidation_done),
                                                .blk_accessed_main       (blk_accessed_main),
                                                .cache_proc_mesi         (cache_proc_mesi),
                                                .cache_snoop_mesi        (cache_snoop_mesi),
                                                .cache_proc_tag          (cache_proc_tag),
                                                .cache_snoop_tag         (cache_snoop_tag)
                                            );

                                                               
                                                        
                                                        

    
                         
endmodule
