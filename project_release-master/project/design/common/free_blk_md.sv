//=====================================================================
// Project : 4 core MESI cache design
// File Name : free_blk_md.sv
// Description : indicate if there is a free block
// Designer : Yuhao Yang
//=====================================================================
// Notable Change History:
// Date By   Version Change Description
// 2016/4/3  1.0     Initial Release
//=====================================================================

module free_blk_md #(
                      parameter ASSOC     = `ASSOC_LV2     ,
                      parameter ASSOC_WID = `ASSOC_WID_LV2 ,
                      parameter MESI_WID  = `MESI_WID_LV2  ,
                      parameter INVALID   = 0
                     )(
                      input                               blk_hit_proc    ,
                      input      [ASSOC*MESI_WID - 1 : 0] cache_proc_mesi ,
                      output reg                          blk_free        ,
                      output reg [ASSOC_WID - 1 : 0]      free_blk_num
                     );
    
    integer i;
    wire [MESI_WID - 1 : 0] cache_mesi [ASSOC - 1 : 0];
    
    generate 
        for(genvar gi = 1; gi<=ASSOC; gi++) begin : divide
            assign cache_mesi[gi - 1] = cache_proc_mesi[gi*MESI_WID - 1 : (gi-1)*MESI_WID];
        end
    endgenerate
                     
    always @* begin
        blk_free = 1'b0;
        free_blk_num = 0;
        
        if(blk_hit_proc == 1'b0) begin 
            for (i = 0; i < ASSOC; i++) begin 
                if(cache_mesi[i] == INVALID) begin 
                    blk_free     = 1'b1;
                    free_blk_num = i;
                end
            end
        end
    end
                     
endmodule
