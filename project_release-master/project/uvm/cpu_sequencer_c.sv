//=====================================================================
// Project: 4 core MESI cache design
// File Name: cpu_sequencer_c.sv
// Description: cpu sequencer component
// Designers: Venky & Suru
//=====================================================================

class cpu_sequencer_c extends uvm_sequencer #(cpu_transaction_c);
    //component macro
    `uvm_component_utils(cpu_sequencer_c)

    //constructor
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

endclass : cpu_sequencer_c
