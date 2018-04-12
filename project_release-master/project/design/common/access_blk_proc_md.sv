//=====================================================================
// Project : 4 core MESI cache design
// File Name : access_blk_proc_md.sv
// Description : check cache contr if there is a match
// Designer : Yuhao Yang
//=====================================================================
// Notable Change History:
// Date By   Version Change Description
// 2016/4/2  1.0     Initial Release
//=====================================================================
module access_blk_proc_md #(
                            parameter ASSOC     = `ASSOC_LV2     ,
                            parameter ASSOC_WID = `ASSOC_WID_LV2 ,
                            parameter MESI_WID  = `MESI_WID_LV2  ,
                            parameter TAG_WID   = `TAG_WID_LV2   ,
                            parameter TAG_MSB   = `TAG_MSB_LV2   ,
                            parameter TAG_LSB   = `TAG_LSB_LV2   ,
                           // parameter CACHE_MESI_MSB ,
                           // parameter CACHE_MESI_LSB ,
                           // parameter CACHE_TAG_MSB  ,
                           // parameter CACHE_TAG_LSB  ,
                            parameter INVALID   = 0
                            )(
                            input                                      cmd_rd           ,
                            input                                      cmd_wr           ,
                            input      [TAG_MSB             : TAG_LSB] tag_proc         ,
                            input      [ASSOC*MESI_WID - 1  : 0      ] cache_proc_mesi  ,
                            input      [ASSOC*TAG_WID - 1   : 0      ] cache_proc_tag   ,
                            output reg [ASSOC - 1           : 0      ] access_blk_proc
                            );
    integer i;
    wire [MESI_WID - 1 : 0] cache_mesi [ASSOC - 1 : 0];
    wire [TAG_WID - 1  : 0] cache_tag  [ASSOC - 1 : 0];
    
    generate 
        for(genvar gi = 1; gi<=ASSOC; gi++) begin : divide
            assign cache_mesi[gi - 1] = cache_proc_mesi[gi*MESI_WID - 1 : (gi-1)*MESI_WID];
            assign cache_tag [gi - 1] = cache_proc_tag [gi*TAG_WID - 1  : (gi-1)*TAG_WID];
        end
    endgenerate
    
    always @* begin 
        if(cmd_rd || cmd_wr) begin 
            for(i = 0; i < ASSOC; i++) begin
                if(cache_mesi[i] != INVALID && cache_tag[i] == tag_proc)
                    access_blk_proc[i] = 1'b1;
                else
                    access_blk_proc[i] = 1'b0;                
            end
        end
        else begin 
            for(i = 0; i < ASSOC; i++) begin
                access_blk_proc[i] = 1'b0;                
            end
        end
    end

                            
endmodule
