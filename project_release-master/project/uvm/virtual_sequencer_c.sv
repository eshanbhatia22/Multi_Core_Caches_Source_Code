//=====================================================================
// Project: 4 core MESI cache design
// File Name: virtual_sequencer_c.sv
// Description: virtual sequencer component
// Designers: Venky & Suru
//=====================================================================

class virtual_sequencer_c extends uvm_sequencer;
    //component macro
    `uvm_component_utils(virtual_sequencer_c)

    cpu_sequencer_c cpu_seqr[0:3];

    //constructor
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

endclass : virtual_sequencer_c
