typedef enum {SNOOP_IN_M = 0, SNOOP_IN_E = 1, SNOOP_IN_S = 3} case_t;

class read_miss_dcache_snoop_service extends base_test;

    //component macro
    `uvm_component_utils(read_miss_dcache_snoop_service)

    rand case_t case_type;

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", read_miss_dcache_snoop_service_seq::type_id::get());
        // randomize the case type
        if (!std::randomize(case_type)) `uvm_error(get_type_name(), "Randomize error on case_type");
	        uvm_config_db#(case_t)::set(this,"tb.vsequencer.read_miss_dcache_snoop_service_seq","case_type",case_type);
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing read_miss_dcache_snoop_service test" , UVM_LOW)
    endtask: run_phase

endclass : read_miss_dcache_snoop_service
			   
// Sequence for a read-miss to D-cache -> serviced by snoop cache
class read_miss_dcache_snoop_service_seq extends base_vseq;
   //object macro
   `uvm_object_utils(read_miss_dcache_snoop_service_seq)

    cpu_transaction_c trans;
    rand case_t case_type;
    bit [`ADDR_WID_LV1-1 : 0]   access_address;

    //constructor
    function new (string name="read_miss_dcache_snoop_service_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        uvm_config_db#(case_t)::get(null,get_full_name(),"case_type", case_type);
        `uvm_info(get_type_name(), $sformatf("Case to run is %s",case_type.name()), UVM_LOW)

        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
        access_address = trans.address;

        // for putting snoop cache in M, issue a write request to the same address
        if (case_type == SNOOP_IN_M)
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp1], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == access_address;})

		// for putting snoop cache in S, issue a read request to the same address on SP2
	    if (case_type == SNOOP_IN_S)
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[sp2], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == access_address;})

		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == access_address;})

 	endtask

endclass : read_miss_dcache_snoop_service_seq
