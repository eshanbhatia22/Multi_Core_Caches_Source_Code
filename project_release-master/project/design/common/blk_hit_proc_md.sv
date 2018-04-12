//=====================================================================
// Project : 4 core MESI cache design
// File Name : blk_hit_proc_md.sv
// Description : indicate if there is a hit
// Designer : Yuhao Yang
//=====================================================================
// Notable Change History:
// Date By   Version Change Description
// 2016/4/3  1.0     Initial Release
//=====================================================================
module blk_hit_proc_md #(
                          parameter ASSOC    = `ASSOC_LV2 
                         )(
                           input                      cmd_rd          ,
                           input                      cmd_wr          ,
                           input      [ASSOC - 1 : 0] access_blk_proc ,
                           output reg                 blk_hit_proc
                         );

    always @* begin 
        if(cmd_rd || cmd_wr) begin
        
            if(|access_blk_proc == 1'b1)
                blk_hit_proc = 1'b1;
            else 
                blk_hit_proc = 1'b0;
        end
        else 
            blk_hit_proc = 1'b0;
    end
                        
                         
endmodule
