//=====================================================================
// Project: 4 core MESI cache design
// File Name: L2_write_miss_blk_replaced.sv
// Description: Test for read-miss to I-cache
// Designers: Venky & Suru
//=====================================================================

class L2_write_miss_blk_replaced extends base_test;

    //component macro
    `uvm_component_utils(L2_write_miss_blk_replaced)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", L2_write_miss_blk_replaced_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing L2_write_miss_blk_replaced test" , UVM_LOW)
    endtask: run_phase

endclass : L2_write_miss_blk_replaced


// Sequence for a read-miss on I-cache
class L2_write_miss_blk_replaced_seq extends base_vseq;
    //object macro
    `uvm_object_utils(L2_write_miss_blk_replaced_seq)

    cpu_transaction_c trans;

    //constructor
    function new (string name="L2_write_miss_blk_replaced_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; address == 32'h5000_ABCD;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; address == 32'h5010_ABCD;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; address == 32'h5020_ABCD;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; address == 32'h5030_ABCD;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; address == 32'h5040_ABCD;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; address == 32'h5050_ABCD;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; address == 32'h5060_ABCD;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; address == 32'h5070_ABCD;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; address == 32'h5080_ABCD;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; address == 32'h5090_ABCD;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; address == 32'h50A0_ABCD;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; address == 32'h50B0_ABCD;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; address == 32'h50C0_ABCD;})	
		
    endtask

endclass : L2_write_miss_blk_replaced_seq
