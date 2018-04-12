//=====================================================================
// Project : 4 core MESI cache design
// File Name : blk_hit_snoop_md.sv
// Description : indicate if there is a hit
// Designer : Yuhao Yang
//=====================================================================
// Notable Change History:
// Date By   Version Change Description
// 2016/4/13  1.0     Initial Release
//=====================================================================
module blk_hit_snoop_md #(
                          parameter ASSOC    = `ASSOC_LV1 
                         )(
                           input                      bus_rd          ,
                           input                      bus_rdx          ,
                           input                      invalidate      ,
                           input      [ASSOC - 1 : 0] access_blk_snoop ,
                           output reg                 blk_hit_snoop
                         );

    always @* begin 
        if(bus_rd || bus_rdx || invalidate) begin
        
            if(|access_blk_snoop == 1'b1)
                blk_hit_snoop = 1'b1;
            else 
                blk_hit_snoop = 1'b0;
        end
        else 
            blk_hit_snoop = 1'b0;
    end
                        
                         
endmodule