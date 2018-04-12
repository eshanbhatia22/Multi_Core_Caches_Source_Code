//=====================================================================
// Project : 4 core MESI cache design
// File Name : addr_segregator_proc.sv
// Description : divide address into different parts
// Designer : Yuhao Yang
//=====================================================================
// Notable Change History:
// Date By   Version Change Description
// 2016/4/2  1.0     Initial Release
//=====================================================================
module addr_segregator_proc #(
                              parameter ADDR_WID   = `ADDR_WID_LV2   ,
                              parameter INDEX_MSB  = `INDEX_MSB_LV2  ,
                              parameter INDEX_LSB  = `INDEX_LSB_LV2  ,
                              parameter OFFSET_MSB = `OFFSET_MSB_LV2 ,
                              parameter OFFSET_LSB = `OFFSET_LSB_LV2 ,
                              parameter TAG_MSB    = `TAG_MSB_LV2    ,
                              parameter TAG_LSB    = `TAG_LSB_LV2
                            
                              )(
                              input                                  cmd_rd          ,
                              input                                  cmd_wr          ,
                              input      [ADDR_WID - 1 : 0]          address         ,
                              output reg [INDEX_MSB    : INDEX_LSB]  index_proc      ,
                              output reg [TAG_MSB      : TAG_LSB]    tag_proc        ,
                              output reg [OFFSET_MSB   : OFFSET_LSB] blk_offset_proc 
                              );
    reg [ADDR_WID - 1 : 0] zeros = 0;
    
    always @ * begin 
        if(cmd_rd || cmd_wr) begin 
            index_proc      = address[INDEX_MSB : INDEX_LSB];
            tag_proc        = address[TAG_MSB : TAG_LSB];
            blk_offset_proc = address[OFFSET_MSB : OFFSET_LSB];
        end
        else begin 
            index_proc      = zeros[INDEX_MSB : INDEX_LSB];
            tag_proc        = zeros[TAG_MSB : TAG_LSB];
          blk_offset_proc = zeros[OFFSET_MSB : OFFSET_LSB];
      end
  end
             
endmodule
