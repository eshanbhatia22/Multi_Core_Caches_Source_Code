//=====================================================================
// Project: 4 core MESI cache design
// File Name: DCACHE_RW_read_hit.sv
// Description: Test for read-miss to I-cache
// Designers: Venky & Suru
//=====================================================================

class DCACHE_RW_read_hit extends base_test;

    //component macro
    `uvm_component_utils(DCACHE_RW_read_hit)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", DCACHE_RW_read_hit_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing DCACHE_RW_read_hit test" , UVM_LOW)
    endtask: run_phase

endclass : DCACHE_RW_read_hit


// Sequence for a read-miss on I-cache
class DCACHE_RW_read_hit_seq extends base_vseq;
    //object macro
    `uvm_object_utils(DCACHE_RW_read_hit_seq)

    cpu_transaction_c trans;

    //constructor
    function new (string name="DCACHE_RW_read_hit_seq");
        super.new(name);
    endfunction : new

    virtual task body();
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; address == 32'h5230_2001;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; address == 32'h5230_2001;})
    endtask

endclass : DCACHE_RW_read_hit_seq
