//=====================================================================
// Project : 4 core MESI cache design
// File Name : blk_to_be_accessed_md.sv
// Description : decide which block to access
// Designer : Yuhao Yang
//=====================================================================
// Notable Change History:
// Date By   Version Change Description
// 2016/4/4  1.0     Initial Release
//=====================================================================

module blk_to_be_accessed_md #(
                                parameter ASSOC     = `ASSOC_LV2 ,
                                parameter ASSOC_WID = `ASSOC_WID_LV2
                               )(
                                input                          blk_hit_proc         ,
                                input      [ASSOC - 1     : 0] access_blk_proc      ,
                                input      [ASSOC_WID - 1 : 0] lru_replacement_proc ,
                                input      [ASSOC_WID - 1 : 0] free_blk_num         ,
                                input                          blk_free             ,
                                output reg [ASSOC_WID - 1 : 0] blk_access_proc
                               );

    always @* begin 
        if(blk_hit_proc) begin 
            blk_access_proc = 0;
            for(int i = 0; i < ASSOC; i++) begin 
                if(access_blk_proc[i] == 1'b1)
                    blk_access_proc = i;
            end
        end
        else if(blk_free)
            blk_access_proc = free_blk_num;
        else
            blk_access_proc =  lru_replacement_proc;
    end
                               
endmodule
