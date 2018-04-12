//=====================================================================
// Project : 4 core MESI cache design
// File Name : addr_segregator_snoop.sv
// Description : divide address into different parts, snoop side
// Designer : Yuhao Yang
//=====================================================================
// Notable Change History:
// Date By   Version Change Description
// 2016/4/13  1.0     Initial Release
//=====================================================================
module addr_segregator_snoop #(
                              parameter ADDR_WID   = `ADDR_WID_LV1   ,
                              parameter INDEX_MSB  = `INDEX_MSB_LV1  ,
                              parameter INDEX_LSB  = `INDEX_LSB_LV1  ,
                              parameter OFFSET_MSB = `OFFSET_MSB_LV1 ,
                              parameter OFFSET_LSB = `OFFSET_LSB_LV1 ,
                              parameter TAG_MSB    = `TAG_MSB_LV1    ,
                              parameter TAG_LSB    = `TAG_LSB_LV1
                            
                              )(
                              input                                  bus_rd           ,
                              input                                  bus_rdx          ,
                              input                                  invalidate       ,
                              input      [ADDR_WID - 1 : 0]          address          ,
                              output reg [INDEX_MSB    : INDEX_LSB]  index_snoop      ,
                              output reg [TAG_MSB      : TAG_LSB]    tag_snoop        ,
                              output reg [OFFSET_MSB   : OFFSET_LSB] blk_offset_snoop 
                              );
    reg [ADDR_WID - 1 : 0] zeros = 0;
    
    always @ * begin 
        if(bus_rd || bus_rdx || invalidate) begin 
            index_snoop      = address[INDEX_MSB : INDEX_LSB];
            tag_snoop        = address[TAG_MSB : TAG_LSB];
            blk_offset_snoop = address[OFFSET_MSB : OFFSET_LSB];
        end
        else begin 
            index_snoop      = zeros[INDEX_MSB : INDEX_LSB];
            tag_snoop        = zeros[TAG_MSB : TAG_LSB];
            blk_offset_snoop = zeros[OFFSET_MSB : OFFSET_LSB];
      end
  end
             
endmodule