//=====================================================================
// Project: 4 core MESI cache design
// File Name: env.sv
// Description: test bench component
// Designers: Venky & Suru
//=====================================================================

//include the system bus monitor
`include "system_bus_monitor_c.sv"
//include the virtual sequencer
`include "virtual_sequencer_c.sv"
//include the virtual sequences
`include "virtual_seqs.sv"
//include the scoreboard
`include "cache_scoreboard_c.sv"

class env extends uvm_env;

    //component macro
    `uvm_component_utils(env)

    //components within the tb
    cpu_agent_c                 cpu[0:3];
    virtual_sequencer_c         vsequencer;
    system_bus_monitor_c      sbus_monitor;
    cache_scoreboard_c          sb;

    //Constructor
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase method
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cpu[0] = cpu_agent_c::type_id::create("cpu[0]", this);
        cpu[1] = cpu_agent_c::type_id::create("cpu[1]", this);
        cpu[2] = cpu_agent_c::type_id::create("cpu[2]", this);
        cpu[3] = cpu_agent_c::type_id::create("cpu[3]", this);
        vsequencer = virtual_sequencer_c::type_id::create("vsequencer", this);
        sbus_monitor = system_bus_monitor_c::type_id::create("sbus_monitor", this);
        sb = cache_scoreboard_c::type_id::create("sb", this);
    endfunction : build_phase

    //UVM connect phase method
    function void connect_phase(uvm_phase phase);
        //virtual sequencer connections
        vsequencer.cpu_seqr[0] = cpu[0].sequencer;
        vsequencer.cpu_seqr[1] = cpu[1].sequencer;
        vsequencer.cpu_seqr[2] = cpu[2].sequencer;
        vsequencer.cpu_seqr[3] = cpu[3].sequencer;
        cpu[0].monitor.mon_out.connect(sb.sb_cpu0m);
        cpu[1].monitor.mon_out.connect(sb.sb_cpu1m);
        cpu[2].monitor.mon_out.connect(sb.sb_cpu2m);
        cpu[3].monitor.mon_out.connect(sb.sb_cpu3m);
        sbus_monitor.sbus_out.connect(sb.sb_sbus);
    endfunction : connect_phase

endclass: env
