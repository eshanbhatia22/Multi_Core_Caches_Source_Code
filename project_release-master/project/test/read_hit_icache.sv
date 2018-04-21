//=====================================================================
// Project: 4 core MESI cache design
// File Name: read_hit_icache.sv
// Description: Test for read-miss to I-cache
// Designers: Venky & Suru
//=====================================================================

class read_hit_icache extends base_test;

    //component macro
    `uvm_component_utils(read_hit_icache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", read_hit_icache_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing read_hit_icache test" , UVM_LOW)
    endtask: run_phase

endclass : read_hit_icache


// Sequence for a read-miss on I-cache
class read_hit_icache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(read_hit_icache_seq)

    cpu_transaction_c trans;

    //constructor
    function new (string name="read_hit_icache_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == ICACHE_ACC;address == 32'h3230_A02B;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == ICACHE_ACC;address == 32'h3230_A02B;})
      
    endtask

endclass : read_hit_icache_seq
