class ICACHE_ONE_HOT extends base_test;

	//component macro
	`uvm_component_utils(ICACHE_ONE_HOT)

	//constructor
	function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

	//UVM build phase
    function void build_phase(uvm_phase phase);
		uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", ICACHE_ONE_HOT_seq::type_id::get());
		super.build_phase(phase);
	endfunction : build_phase

	//UVM run phase
	task run_phase(uvm_phase phase);
		`uvm_info(get_type_name(), "Executing ICACHE_ONE_HOT test" , UVM_LOW)
	endtask : run_phase

endclass : ICACHE_ONE_HOT

// Sequence for 1-hot addressing
class ICACHE_ONE_HOT_seq extends base_vseq;

	//object macro
	`uvm_object_utils(ICACHE_ONE_HOT_seq)

	cpu_transaction_c trans;

	//constructor
    function new (string name="ICACHE_ONE_HOT_seq");
        super.new(name);
    endfunction : new

	virtual task body();

		for (int i = 1; i < 32'h4000_0000; i = i*2 ) begin
			`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ;  address == 32'h0000_0000 + i;})
		end
	endtask


endclass : ICACHE_ONE_HOT_seq
