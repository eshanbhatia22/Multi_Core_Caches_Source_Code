//=====================================================================
// Project: 4 core MESI cache design
// File Name: cpu_agent_c.sv
// Description: cpu agent component
// Designers: Venky & Suru
//=====================================================================

class cpu_agent_c extends uvm_agent;

    //this field determines whether an agent is active or passive
    protected uvm_active_passive_enum is_active = UVM_ACTIVE;

    cpu_monitor_c monitor;
    cpu_driver_c driver;
    cpu_sequencer_c sequencer;

    //component macro
    `uvm_component_utils_begin(cpu_agent_c)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
    `uvm_component_utils_end

    //Constructor
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase method
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        monitor = cpu_monitor_c::type_id::create("monitor", this);
        if(is_active == UVM_ACTIVE) begin
            sequencer = cpu_sequencer_c::type_id::create("sequencer", this);
            driver = cpu_driver_c::type_id::create("driver", this);
        end
    endfunction : build_phase

    //UVM connect phase method
    function void connect_phase(uvm_phase phase);
        if(is_active == UVM_ACTIVE)
            driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction : connect_phase

endclass: cpu_agent_c
