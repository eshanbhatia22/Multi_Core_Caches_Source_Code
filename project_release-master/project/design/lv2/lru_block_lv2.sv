//=====================================================================
// Project : 4 core MESI cache design
// File Name : lru_block_lv2.sv
// Description : implement lru policy in level 2 cache
// Designer : Yuhao Yang
//=====================================================================
// Notable Change History:
// Date By   Version Change Description
// 2016/3/31  1.0     Initial Release
//=====================================================================

module lru_block_lv2 #(
                       parameter ASSOC_WID   = `ASSOC_WID_LV2   ,
                       parameter INDEX_MSB   = `INDEX_MSB_LV2   ,
                       parameter INDEX_LSB   = `INDEX_LSB_LV2   ,
                       parameter LRU_VAR_WID = `LRU_VAR_WID_LV2 ,
                       parameter NUM_OF_SETS = `NUM_OF_SETS_LV2
                      )
                     (
                       input      [INDEX_MSB     : INDEX_LSB ] index_proc        ,
                       input      [ASSOC_WID - 1 : 0         ] blk_accessed_main ,
                       output reg [ASSOC_WID - 1 : 0         ] lru_replacement_proc
                     );
    
    // Pseudo-LRU Block State parameters
    parameter BLK0_REPLACEMENT = 7'b00x0xxx;
    parameter BLK1_REPLACEMENT = 7'b00x1xxx;
    parameter BLK2_REPLACEMENT = 7'b01xx0xx;
    parameter BLK3_REPLACEMENT = 7'b01xx1xx;
    parameter BLK4_REPLACEMENT = 7'b1x0xx0x;
    parameter BLK5_REPLACEMENT = 7'b1x0xx1x;
    parameter BLK6_REPLACEMENT = 7'b1x1xxx0;
    parameter BLK7_REPLACEMENT = 7'b1x1xxx1;
    
    reg [LRU_VAR_WID - 1 : 0] lru_var [NUM_OF_SETS - 1 : 0];    
    
    // determine which to replace
    always @ * begin 
        casex (lru_var[index_proc])
            BLK0_REPLACEMENT: lru_replacement_proc = 3'b000;
            BLK1_REPLACEMENT: lru_replacement_proc = 3'b001;
            BLK2_REPLACEMENT: lru_replacement_proc = 3'b010;
            BLK3_REPLACEMENT: lru_replacement_proc = 3'b011;
            BLK4_REPLACEMENT: lru_replacement_proc = 3'b100;
            BLK5_REPLACEMENT: lru_replacement_proc = 3'b101;
            BLK6_REPLACEMENT: lru_replacement_proc = 3'b110;
            BLK7_REPLACEMENT: lru_replacement_proc = 3'b111;
            default:          lru_replacement_proc = 3'b000;
        endcase
    end
    
    
    // next state logic
    always @ * begin 
        case (blk_accessed_main)
            3'b000: begin 
                lru_var[index_proc][6:5] = 2'b11;
                lru_var[index_proc][3]   = 1'b1;
            end 
            3'b001: begin 
                lru_var[index_proc][6:5] = 2'b11;
                lru_var[index_proc][3]   = 1'b0;
            end
            3'b010: begin 
                lru_var[index_proc][6:5] = 2'b10;
                lru_var[index_proc][2]   = 1'b1;
            end
            3'b011: begin 
                lru_var[index_proc][6:5] = 2'b10;
                lru_var[index_proc][2]   = 1'b0;
            end
            3'b100: begin 
                lru_var[index_proc][6]   = 1'b0;
                lru_var[index_proc][4]   = 1'b1;
                lru_var[index_proc][1]   = 1'b1;
            end
            3'b101: begin 
                lru_var[index_proc][6]   = 1'b0;
                lru_var[index_proc][4]   = 1'b1;
                lru_var[index_proc][1]   = 1'b0;
            end
            3'b110: begin 
                lru_var[index_proc][6]   = 1'b0;
                lru_var[index_proc][4]   = 1'b0;
                lru_var[index_proc][0]   = 1'b1;
            end
            3'b111: begin 
                lru_var[index_proc][6]   = 1'b0;
                lru_var[index_proc][4]   = 1'b0;
                lru_var[index_proc][0]   = 1'b0;
            end
            default: lru_var[index_proc] = 7'b0;
        endcase
    end

    
    
endmodule
