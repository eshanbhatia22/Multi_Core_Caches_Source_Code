//=====================================================================
// Project: 4 core MESI cache design
// File Name: DCACHE_RW_S_LRU_WRITE
// Description:Test for LRU_write to block in Shared state
// Designers: Keerthana
//=====================================================================

class DCACHE_RW_S_LRU_WRITE extends base_test;

    //component macro
    `uvm_component_utils(DCACHE_RW_S_LRU_WRITE)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", DCACHE_RW_S_LRU_WRITE_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing DCACHE_RW_S_LRU_WRITE test" , UVM_LOW)
    endtask: run_phase

endclass : DCACHE_RW_S_LRU_WRITE


// Sequence for LRU_write to block in Shared state
class DCACHE_RW_S_LRU_WRITE_seq extends base_vseq;
    //object macro
    `uvm_object_utils(DCACHE_RW_S_LRU_WRITE_seq)

    cpu_transaction_c trans;

    //constructor
    function new (string name="DCACHE_RW_S_LRU_WRITE_seq");
        super.new(name);
    endfunction : new

    virtual task body();
    
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; address == 32'h4230_A02B;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; address == 32'h4231_A02B;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; address == 32'h4232_A02B;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; address == 32'h4233_A02B;})
		
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == READ_REQ; address == 32'h4230_A02B;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == READ_REQ; address == 32'h4231_A02B;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == READ_REQ; address == 32'h4232_A02B;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == READ_REQ; address == 32'h4233_A02B;})
		
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; address == 32'h4234_A02B;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == WRITE_REQ; address == 32'h4234_A02B;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; address == 32'h4235_A02B;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; address == 32'h4236_A02B;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; address == 32'h4237_A02B;})
		
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; address == 32'h4238_A02B;})	
		
		
    endtask

endclass : DCACHE_RW_S_LRU_WRITE_seq


