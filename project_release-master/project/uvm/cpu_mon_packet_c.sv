//=====================================================================
// Project: 4 core MESI cache design
// File Name: cpu_mon_packet.sv
// Description: packet class for cpu monitor to pass to the scoreboard
// Designers: Venky & Suru
//=====================================================================
typedef enum {ICACHE, DCACHE} addr_t;

class cpu_mon_packet_c extends uvm_sequence_item;

    parameter DATA_WID_LV1      = `DATA_WID_LV1;
    parameter ADDR_WID_LV1      = `ADDR_WID_LV1;

    request_t request_type;//Read or Write
    addr_t addr_type;//ICACHe or DCACHE
    logic [DATA_WID_LV1-1 : 0] dat;//Data
    logic [ADDR_WID_LV1-1 : 0] address;//Address
    int num_cycles;//Number of cycles to service the request
    bit illegal;//Is the request illegal i.e. write to ICACHE


    // UVM macros for built-in automation
    `uvm_object_utils_begin(cpu_mon_packet_c)
        `uvm_field_int(dat, UVM_ALL_ON)
        `uvm_field_int(address, UVM_ALL_ON)
        `uvm_field_int(num_cycles, UVM_ALL_ON)
        `uvm_field_int(illegal, UVM_ALL_ON)
        `uvm_field_enum(request_t, request_type, UVM_ALL_ON)
        `uvm_field_enum(addr_t, addr_type, UVM_ALL_ON)
    `uvm_object_utils_end

    // Constructor
    function new (string name = "cpu_mon_packet_c");
        super.new(name);

        this.dat            = {DATA_WID_LV1{1'bz}};
        this.address        = {ADDR_WID_LV1{1'bz}};
        this.num_cycles     = 0;
        this.illegal        = 1'b0;

    endfunction : new
endclass : cpu_mon_packet_c

