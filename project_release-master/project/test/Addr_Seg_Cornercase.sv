//=====================================================================
// Project: 4 core MESI cache design
// File Name: Addr_Seg_Cornercase.sv
// Description: Test for corner cases to ensure proper Address Segregation
// Designers: Keerthana
//=====================================================================

class Addr_Seg_Cornercase extends base_test;

    //component macro
    `uvm_component_utils(Addr_Seg_Cornercase)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", Addr_Seg_Cornercase_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing Addr_Seg_Cornercase test" , UVM_LOW)
    endtask: run_phase

endclass : Addr_Seg_Cornercase


// Sequence for corner cases to ensure proper Address Segregation
class Addr_Seg_Cornercase_seq extends base_vseq;
    //object macro
    `uvm_object_utils(Addr_Seg_Cornercase_seq)

    cpu_transaction_c trans;

    //constructor
    function new (string name="Addr_Seg_Cornercase_seq");
        super.new(name);
    endfunction : new

    virtual task body();
     	
		//Corner Cases
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ;  address == 32'h4000_0000;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ;  address == 32'h3FFF_FFFF;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ;  address == 32'h0000_0000;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ;  address == 32'hFFFF_FFFF;})
		
    endtask

endclass : Addr_Seg_Cornercase_seq
