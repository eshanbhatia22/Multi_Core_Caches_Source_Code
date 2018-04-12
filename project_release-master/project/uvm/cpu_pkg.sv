//=====================================================================
// Project: 4 core MESI cache design
// File Name: cpu_package_c.sv
// Description: cpu package
// Designers: Venky & Suru
//=====================================================================

package cpu_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "cpu_transaction_c.sv"
    `include "cpu_mon_packet_c.sv"
    `include "cpu_monitor_c.sv"
    `include "cpu_sequencer_c.sv"
    `include "cpu_seqs.sv"
    `include "cpu_driver_c.sv"
    `include "cpu_agent_c.sv"
endpackage
