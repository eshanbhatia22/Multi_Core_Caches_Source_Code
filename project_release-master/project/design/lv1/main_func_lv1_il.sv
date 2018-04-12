//=====================================================================
// Project : 4 core MESI cache design
// File Name : main_func_lv1_il.sv
// Description : main function block for level 1 instruction level
// Designer : Yuhao Yang
//=====================================================================
// Notable Change History:
// Date By   Version Change Description
// 2016/4/12  1.0     Initial Release
//=====================================================================

//`include "def_lv1.sv"
module main_func_lv1_il #(
                        parameter ASSOC              = `ASSOC_LV1              ,
                        parameter ASSOC_WID          = `ASSOC_WID_LV1          ,
                        parameter DATA_WID           = `DATA_WID_LV1           ,
                        parameter ADDR_WID           = `ADDR_WID_LV1           ,
                        parameter INDEX_MSB          = `INDEX_MSB_LV1          ,
                        parameter INDEX_LSB          = `INDEX_LSB_LV1          ,
                        parameter TAG_MSB            = `TAG_MSB_LV1            ,
                        parameter TAG_LSB            = `TAG_LSB_LV1            ,
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
                         input                               clk                     ,
                         input      [DATA_WID - 1       : 0] data_bus_lv1_lv2        ,
                         output reg [ADDR_WID - 1       : 0] addr_bus_lv1_lv2        ,
                         inout      [DATA_WID - 1       : 0] data_bus_cpu_lv1        ,
                         input      [ADDR_WID - 1       : 0] addr_bus_cpu_lv1        ,
                         output reg                          lv2_rd                  ,
                         input                               cpu_rd                  ,
                         input                               bus_lv1_lv2_gnt_proc    ,
                         output reg                          bus_lv1_lv2_req_proc_il ,
                         input      [INDEX_MSB  : INDEX_LSB] index_proc              ,
                         input      [TAG_MSB    :   TAG_LSB] tag_proc                ,
                         input                               blk_hit_proc            ,
                         input                               blk_free                ,
                         input      [ASSOC_WID - 1      : 0] blk_access_proc         ,
                         input      [ASSOC_WID - 1      : 0] lru_replacement_proc    ,
                         output reg                          data_in_bus_cpu_lv1_il  ,
                         input                               data_in_bus_lv1_lv2     ,
                         output reg [ASSOC_WID - 1      : 0] blk_accessed_main       ,
                         output reg [ASSOC*MESI_WID - 1 : 0] cache_proc_mesi         ,
                         output reg [ASSOC*TAG_WID - 1  : 0] cache_proc_tag
                         ); 
    integer i;    
    
    parameter INVALID 	= 2'b00;
    parameter VALID	    = 2'b01;
    
    reg [CACHE_DATA_WID - 1     : 0] cache_var        [0 : CACHE_DEPTH/4 - 1];
    reg [CACHE_TAG_MESI_WID - 1 : 0] cache_proc_contr [0 : CACHE_DEPTH - 1];
    
    reg [DATA_WID - 1 : 0] data_bus_cpu_lv1_reg;
    
    reg [31:0] zeros = 32'h0;
    
    initial begin 
        for (i = 0; i<CACHE_DEPTH; i++) begin 
            cache_var[i]        = {CACHE_DATA_WID{1'b0}};
            cache_proc_contr[i] = {CACHE_TAG_MESI_WID{1'b0}};
        end
    end
    
    assign data_bus_cpu_lv1 = data_bus_cpu_lv1_reg;

    
    // select all mesi and tag in a set 
    generate 
        for(genvar gi = 1; gi<=ASSOC; gi++) begin
            assign cache_proc_mesi[gi*MESI_WID - 1 : (gi-1)*MESI_WID] = cache_proc_contr[{index_proc,{ASSOC_WID{1'b0}}}+gi-1][CACHE_MESI_MSB : CACHE_MESI_LSB];
            assign cache_proc_tag [gi*TAG_WID - 1  : (gi-1)*TAG_WID ] = cache_proc_contr[{index_proc,{ASSOC_WID{1'b0}}}+gi-1][CACHE_TAG_MSB  : CACHE_TAG_LSB ];
        end
    endgenerate
    
    
    
    always @(posedge clk) begin
        data_bus_cpu_lv1_reg    <= 32'hz;
        bus_lv1_lv2_req_proc_il <= 1'b0;
        data_in_bus_cpu_lv1_il  <= 1'b0;
        lv2_rd                  <= 1'b0;
        addr_bus_lv1_lv2        <= 32'hz;

                
        if(cpu_rd) begin 
            //  hit
            if(blk_hit_proc) begin                 
                data_bus_cpu_lv1_reg   <= cache_var[{index_proc,blk_access_proc}];
                data_in_bus_cpu_lv1_il <= 1'b1;
                blk_accessed_main      <= blk_access_proc;
            end
            //read miss free blk
            else if(blk_free) begin
                bus_lv1_lv2_req_proc_il <= 1'b1;
                if(bus_lv1_lv2_gnt_proc) begin                 
                    lv2_rd           <= 1'b1;
                    addr_bus_lv1_lv2 <= {tag_proc, index_proc, {OFFSET_WID{1'b0}}};
                    if(data_in_bus_lv1_lv2) begin 
                        cache_var[{index_proc,blk_access_proc}] <= data_bus_lv1_lv2;
                        `CACHE_CURRENT_MESI                     <= VALID;
                        `CACHE_CURRENT_TAG                      <= tag_proc;
                        
                        bus_lv1_lv2_req_proc_il <= 1'b0;
                        lv2_rd                  <= 1'b0;
                        addr_bus_lv1_lv2        <= 32'hz;
                    end
                end
            end
            //no free blk
            else begin 
                `CACHE_CURRENT_MESI <= INVALID;
            end
        end
        
    end
                         
endmodule
