class DCACHE_MULTI_RAW extends base_test;

	//component macro
	`uvm_component_utils(DCACHE_MULTI_RAW)

	//constructor
	function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

	//UVM build phase
    function void build_phase(uvm_phase phase);
		uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", DCACHE_MULTI_RAW_seq::type_id::get());
		super.build_phase(phase);
	endfunction : build_phase

	//UVM run phase
	task run_phase(uvm_phase phase);
		`uvm_info(get_type_name(), "Executing DCACHE_MULTI_RAW test" , UVM_LOW)
	endtask : run_phase

endclass : DCACHE_MULTI_RAW

// Sequence for 1-hot addressing
class DCACHE_MULTI_RAW_seq extends base_vseq;

	//object macro
	`uvm_object_utils(DCACHE_MULTI_RAW_seq)

	cpu_transaction_c trans;

	//constructor
    function new (string name="DCACHE_MULTI_RAW_seq");
        super.new(name);
    endfunction : new

	virtual task body();

		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; address == 32'h8300_0000;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ;  address == 32'h8300_0000;})

		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == WRITE_REQ; address == 32'h8300_0000;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == READ_REQ;  address == 32'h8300_0000;})

		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], {request_type == WRITE_REQ; address == 32'h8370_0000;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ;  address == 32'h8370_0000;})

		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; address == 32'h8305_0000;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], {request_type == READ_REQ;  address == 32'h8305_0000;})

		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == WRITE_REQ; address == 32'h8310_0000;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], {request_type == WRITE_REQ; address == 32'h8310_0000;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], {request_type == READ_REQ;  address == 32'h8310_0000;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ;  address == 32'h8310_0000;})

	endtask


endclass : DCACHE_MULTI_RAW_seq
