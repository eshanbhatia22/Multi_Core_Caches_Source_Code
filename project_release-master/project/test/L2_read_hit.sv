//=====================================================================
// Project: 4 core MESI cache design
// File Name: L2_read_hit.sv
// Description: Test for read-miss to I-cache
// Designers: Venky & Suru
//=====================================================================

class L2_read_hit extends base_test;

    //component macro
    `uvm_component_utils(L2_read_hit)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", L2_read_hit_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing L2_read_hit test" , UVM_LOW)
    endtask: run_phase

endclass : L2_read_hit


// Sequence for a read-miss on I-cache
class L2_read_hit_seq extends base_vseq;
    //object macro
    `uvm_object_utils(L2_read_hit_seq)

    cpu_transaction_c trans;

    //constructor
    function new (string name="L2_read_hit_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; address == 32'h5000_ABCD;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; address == 32'h5000_ABCD;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; address == 32'h3000_ABCD;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; address == 32'h3000_ABCD;})
		
    endtask

endclass : L2_read_hit_seq
