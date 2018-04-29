//=====================================================================
// Project : 4 core MESI cache design
// File Name : lru_block_lv1.sv
// Description : implement lru policy in level 1 cache
// Designer : Yuhao Yang
//=====================================================================
// Notable Change History:
// Date By   Version Change Description
// 2016/4/11  1.0     Initial Release
//=====================================================================

module lru_block_lv1 #(
                       parameter ASSOC_WID   = `ASSOC_WID_LV1   ,
                       parameter INDEX_MSB   = `INDEX_MSB_LV1   ,
                       parameter INDEX_LSB   = `INDEX_LSB_LV1   ,
                       parameter LRU_VAR_WID = `LRU_VAR_WID_LV1 ,
                       parameter NUM_OF_SETS = `NUM_OF_SETS_LV1
                      )
                     (
                       input      [INDEX_MSB     : INDEX_LSB ] index_proc        ,
                       input      [ASSOC_WID - 1 : 0         ] blk_accessed_main ,
                       output reg [ASSOC_WID - 1 : 0         ] lru_replacement_proc
                     );
    
    // Pseudo-LRU Block State parameters
    parameter BLK0_REPLACEMENT = 3'b00x;
    parameter BLK1_REPLACEMENT = 3'b01x;
    parameter BLK2_REPLACEMENT = 3'b1x0;
	// BUG 9 : LRU replacement hung because of incorrect state
    // parameter BLK3_REPLACEMENT = 3'bx01;
	parameter BLK3_REPLACEMENT = 3'b1x1;

	parameter BLK0_ACCESS = 3'b000;
	parameter BLK1_ACCESS = 3'b001;
	parameter BLK2_ACCESS = 3'b010;
	parameter BLK3_ACCESS = 3'b011;

	covergroup cover_lru;
		option.per_instance = 1;
		cov_repl_blk: coverpoint lru_replacement_proc {
			bins BIN_REP_BLK_0 = BLK0_REPLACEMENT;
			bins BIN_REP_BLK_1 = BLK1_REPLACEMENT;
			bins BIN_REP_BLK_2 = BLK2_REPLACEMENT;
			bins BIN_REP_BLK_3 = BLK3_REPLACEMENT;
		}
		cov_access_blk: coverpoint blk_accessed_main {
			bins BIN_ACC_BLK_0 = BLK0_ACCESS;
			bins BIN_ACC_BLK_1 = BLK1_ACCESS;
			bins BIN_ACC_BLK_2 = BLK2_ACCESS;
			bins BIN_ACC_BLK_3 = BLK3_ACCESS;
		}
    endgroup

	cover_lru inst_cover_lru = new();

    reg [LRU_VAR_WID - 1 : 0] lru_var [NUM_OF_SETS - 1 : 0];    
    
    // determine which to replace
    always @ * begin 
        casex (lru_var[index_proc])
            BLK0_REPLACEMENT: lru_replacement_proc = 2'b00;
            BLK1_REPLACEMENT: lru_replacement_proc = 2'b01;
            BLK2_REPLACEMENT: lru_replacement_proc = 2'b10;
            BLK3_REPLACEMENT: lru_replacement_proc = 2'b11; 
            default:          lru_replacement_proc = 2'b00;
        endcase
    end
    
    
    // next state logic
    always @ * begin 
        case (blk_accessed_main)
            3'b000: begin 
                lru_var[index_proc][2:1] = 2'b11;
            end 
            3'b001: begin 
                lru_var[index_proc][2:1] = 2'b10;
            end
            3'b010: begin 
                lru_var[index_proc][2] = 1'b0;
                lru_var[index_proc][0] = 1'b1;
            end
            3'b011: begin 
                lru_var[index_proc][2] = 1'b0;
                lru_var[index_proc][0] = 1'b0;
            end
            default: lru_var[index_proc] = 3'b0;
        endcase
    end

    
    
endmodule
