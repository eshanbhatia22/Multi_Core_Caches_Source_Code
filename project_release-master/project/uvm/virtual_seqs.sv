//=====================================================================
// Project: 4 core MESI cache design
// File Name: virtual_seqs.sv
// Description: virtual sequences library
// Designers: Venky & Suru
//=====================================================================

class base_vseq extends uvm_sequence;

    `uvm_object_utils(base_vseq)
    `uvm_declare_p_sequencer(virtual_sequencer_c)

    //main processor number, secondary processor 1 and 2
    rand int mp, sp1, sp2;

    constraint c_processor_numbers{
        mp inside {['d0:'d3]};
        sp1 inside {['d0:'d3]};
        sp2 inside {['d0:'d3]};
        unique {mp, sp1, sp2};
    }

    function new (string name = "base_vseq");
        super.new(name);
    endfunction

    task pre_body();
        if(starting_phase != null) begin
            starting_phase.raise_objection(this, get_type_name());
            `uvm_info(get_type_name(), "raise_objection", UVM_LOW)
            `uvm_info(get_type_name(), $sformatf("Main Processor=%0d\tSP1=%0d\tSP2=%0d", mp, sp1, sp2), UVM_LOW)
        end
    endtask : pre_body

    task post_body();
        if(starting_phase != null) begin
            starting_phase.drop_objection(this, get_type_name());
            `uvm_info(get_type_name(), "drop_objection", UVM_LOW)
        end
    endtask : post_body

endclass : base_vseq

