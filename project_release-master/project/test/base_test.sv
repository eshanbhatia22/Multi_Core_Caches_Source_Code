//=====================================================================
// Project: 4 core MESI cache design
// File Name: base_test.sv
// Description: Base test class
// Designers: Venky & Suru
//=====================================================================

class base_test extends uvm_test;

    uvm_cmdline_processor clp;
    string temp_string = "0";
    //component macro
    `uvm_component_utils(base_test)

    //components of the environment
    env           tb;
    //enables for the different CPUs
    bit [3:0]           cpu_en;

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
        clp = uvm_cmdline_processor::get_inst();
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        set_config_int("*", "recording_detail", 1);//to enable transaction recording
        set_config_int("tb.cpu[0]", "is_active", UVM_ACTIVE);
        set_config_int("tb.cpu[1]", "is_active", UVM_ACTIVE);
        set_config_int("tb.cpu[2]", "is_active", UVM_ACTIVE);
        set_config_int("tb.cpu[3]", "is_active", UVM_ACTIVE);
        super.build_phase(phase);
        tb = env::type_id::create("tb", this);
    endfunction : build_phase

    function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction : end_of_elaboration_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction : connect_phase

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.phase_done.set_drain_time(this, 10ns);
    endtask : run_phase

    function void report_phase(uvm_phase phase);
        uvm_report_server reportServer = uvm_report_server::get_server();
        super.report_phase(phase);
        $display("---Test Summary---");
        $display("");
        $display("---Final Test Status---");
        if(reportServer.get_severity_count(UVM_FATAL) == 0 && reportServer.get_severity_count(UVM_ERROR) == 0) begin
            $display("");
            $display("Test PASS");
            $display(" ____   _    ____ ____\n|  _ \\ / \\  / ___/ ___|\n| |_) / _ \\ \\___ \\___ \\\n|  __/ ___ \\ ___) |__) |\n|_| /_/   \\_\\____/____/");
            $display("");
        end
        else begin
            $display("");
            $display("Test FAIL");
            $error(" _____ _    ___ _\n|  ___/ \\  |_ _| |\n| |_ / _ \\  | || |\n|  _/ ___ \\ | || |___\n|_|/_/   \\_\\___|_____|");
            $display("");
        end
        endfunction
endclass : base_test
