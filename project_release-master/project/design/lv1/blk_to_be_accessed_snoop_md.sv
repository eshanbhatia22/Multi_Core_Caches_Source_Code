//=====================================================================
// Project : 4 core MESI cache design
// File Name : blk_to_be_accessed_snoop_md.sv
// Description : decide which block to access, snoop side
// Designer : Yuhao Yang
//=====================================================================
// Notable Change History:
// Date By   Version Change Description
// 2016/4/13  1.0     Initial Release
//=====================================================================

module blk_to_be_accessed_snoop_md #(
                                    parameter ASSOC     = `ASSOC_LV1 ,
                                    parameter ASSOC_WID = `ASSOC_WID_LV1
                                    )(
                                    input                          blk_hit_snoop         ,
                                    input      [ASSOC - 1     : 0] access_blk_snoop      ,
                                    output reg [ASSOC_WID - 1 : 0] blk_access_snoop
                                   );

    always @* begin
        blk_access_snoop = 0;    
        if(blk_hit_snoop) begin 
            for(int i = 0; i < ASSOC; i++) begin 
                if(access_blk_snoop[i] == 1'b1)
                    blk_access_snoop = i;
            end
        end
    end
                               
endmodule