//=====================================================================
// Project: 4 core MESI cache design
// File Name: cpu_monitor_c.sv
// Description: cpu monitor component
// Designers: Venky & Suru
//=====================================================================

class cpu_monitor_c extends uvm_monitor;
    //component macro
    `uvm_component_utils(cpu_monitor_c)
    cpu_mon_packet_c packet;
    uvm_analysis_port #(cpu_mon_packet_c) mon_out;

    // Virtual interface of used to drive and observe CPU-LV1 interface signals
    virtual interface cpu_lv1_interface vi_cpu_lv1_if;

    covergroup cover_cpu_packet;
        option.per_instance = 1;
        option.name = "cover_cpu_packets";
        REQUEST: coverpoint packet.request_type;
        //TODO: add coverpoints for Data, Address, etc.
		ADDRESS: coverpoint packet.address {
			option.auto_bin_max = 20;
		}
		
		DATA: coverpoint packet.dat {
			option.auto_bin_max = 20;
		}
		ACCESS_TYPE: coverpoint packet.addr_type;
		ILLEGAL: coverpoint packet.illegal;
		X__ACCESS_TYPE__REQUEST: cross REQUEST, ACCESS_TYPE {
			ignore_bins ib = binsof(ACCESS_TYPE) intersect{ICACHE} && binsof(REQUEST) intersect{WRITE_REQ};
		}
    endgroup

    //constructor
    function new (string name, uvm_component parent);
        super.new(name, parent);
        mon_out = new ("mon_out", this);
        this.cover_cpu_packet = new();
    endfunction : new

    //UVM build phase ()
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // throw error if virtual interface is not set
        if (!uvm_config_db#(virtual cpu_lv1_interface)::get(this, "","vif", vi_cpu_lv1_if))
            `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
    endfunction: build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "RUN Phase", UVM_LOW)
        forever begin
            //TODO: Code for the CPU monitor is incomplete
            //Add code to populate other fields of the cpu monitor packet
            //Ensure that your code can handle all possible cases (read, write
            //etc)
            @(posedge vi_cpu_lv1_if.cpu_rd or posedge vi_cpu_lv1_if.cpu_wr)
            packet = cpu_mon_packet_c::type_id::create("packet", this);
            if(vi_cpu_lv1_if.cpu_rd === 1'b1) begin
                packet.request_type = READ_REQ;
            end
            if(vi_cpu_lv1_if.cpu_wr === 1'b1) begin
                packet.request_type = WRITE_REQ;
            end
            packet.address = vi_cpu_lv1_if.addr_bus_cpu_lv1;
            if(packet.address >= 32'h4000_0000) begin
                packet.addr_type = DCACHE;
            end
            @(posedge vi_cpu_lv1_if.data_in_bus_cpu_lv1 or posedge vi_cpu_lv1_if.cpu_wr_done)
            packet.dat = vi_cpu_lv1_if.data_bus_cpu_lv1;
            @(negedge vi_cpu_lv1_if.cpu_rd or negedge vi_cpu_lv1_if.cpu_wr)
            mon_out.write(packet);
            cover_cpu_packet.sample();
        end
    endtask : run_phase

endclass : cpu_monitor_c
