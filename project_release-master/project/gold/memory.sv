//=====================================================================
// Project : 4 core MESI cache design
// File Name : memory.sv
// Description : main memory
// Designer : Yuhao Yang
//=====================================================================
// Notable Change History:
// Date By   Version Change Description
// 2016/4/25  1.0     Initial Release
//=====================================================================
module memory #( 
                  parameter DATA_WID        = `DATA_WID_LV2 ,
                  parameter ADDR_WID        = `ADDR_WID_LV2 
              )(
                input                           clk                   ,
                inout      [DATA_WID - 1   : 0] data_bus_lv2_mem      ,
                input      [ADDR_WID - 1   : 0] addr_bus_lv2_mem      ,
                input                           mem_rd                ,
                input                           mem_wr                ,
                output reg                      mem_wr_done           ,
                output reg                      data_in_bus_lv2_mem
               );

    reg [DATA_WID - 1 : 0] mem[int];
    reg [DATA_WID - 1 : 0] data_bus_lv2_mem_reg;
    
    assign data_bus_lv2_mem = data_bus_lv2_mem_reg;
    
    always @(posedge clk) begin
        data_in_bus_lv2_mem  <= 1'b0;
        data_bus_lv2_mem_reg <= 32'hz;
        mem_wr_done          <= 1'b0;
        
        if(mem_rd) begin   // read
            if(mem.exists(addr_bus_lv2_mem)) begin
                data_bus_lv2_mem_reg <= mem[addr_bus_lv2_mem];
                data_in_bus_lv2_mem  <= 1'b1;
            end                
            else begin 
                data_bus_lv2_mem_reg <= addr_bus_lv2_mem[3] ? 32'h5555_aaaa : 32'haaaa_5555;
                data_in_bus_lv2_mem  <= 1'b1; 
            end                                     
        end
        else if(mem_wr) begin 
            mem[addr_bus_lv2_mem] = data_bus_lv2_mem;
            mem_wr_done           <= 1'b1;
        end
    end

endmodule    

