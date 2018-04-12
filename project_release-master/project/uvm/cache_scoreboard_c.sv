//=====================================================================
// Project: 4 core MESI cache design
// File Name: cache_scoreboard_c.sv
// Description: cache scoreboard component
// Designers: Venky & Suru
//=====================================================================

//enum for holding MESI state
typedef enum { STATE_M=3, STATE_E=2, STATE_S=1, STATE_I=0 } state_t;//I = 0, by default the line is set to invalid

//structure to hold a cache set
typedef struct {
    int capacity;
    bit[2:0] lru;
    bit [15:0]  tag[4];    // this is based on spec 256KB cache, 16 bit tag, 14 bit index and 2 bit offset
    bit [`DATA_WID_LV1-1 :0] data[4]; //size is 4 to accomodate 4 ways
    state_t     state[4];
}set_t;

`define CORRECT_DATA_1 32'h5555_AAAA    // data when addr[3] == 1
`define CORRECT_DATA_0 32'hAAAA_5555    // data when addr[3] == 0

class cache_scoreboard_c extends uvm_scoreboard;

    parameter DATA_WID_LV1           = `DATA_WID_LV1       ;
    parameter ADDR_WID_LV1           = `ADDR_WID_LV1       ;

    //cache reference model
    set_t dcache[4][bit [13:0]];//first index is cpu number, second index is the cache set index
    set_t icache[4][bit [13:0]];
    //memory model
    bit[DATA_WID_LV1-1:0] memory[bit[29:0]];//memory indexed by tag+index

    //Queues for expected system bus activity
    sbus_packet_c expected_sbus[4][$];       //first index indicates cpu number i.e the proc request cpu
    //Queues for actual system bus activity
    sbus_packet_c received_sbus[4][$];

    //TLM port declarations
    `uvm_analysis_imp_decl(_cpu0m)//for monitors from CPU-LV1 interface UVC
    `uvm_analysis_imp_decl(_cpu1m)
    `uvm_analysis_imp_decl(_cpu2m)
    `uvm_analysis_imp_decl(_cpu3m)
    `uvm_analysis_imp_decl(_sbus)

    uvm_analysis_imp_cpu0m #(cpu_mon_packet_c, cache_scoreboard_c) sb_cpu0m;
    uvm_analysis_imp_cpu1m #(cpu_mon_packet_c, cache_scoreboard_c) sb_cpu1m;
    uvm_analysis_imp_cpu2m #(cpu_mon_packet_c, cache_scoreboard_c) sb_cpu2m;
    uvm_analysis_imp_cpu3m #(cpu_mon_packet_c, cache_scoreboard_c) sb_cpu3m;
    uvm_analysis_imp_sbus #(sbus_packet_c, cache_scoreboard_c) sb_sbus;

    //component macro
    `uvm_component_utils(cache_scoreboard_c)

    //constructor
    function new (string name, uvm_component parent);
        super.new(name, parent);
        sb_cpu0m = new("sb_cpu0m", this);
        sb_cpu1m = new("sb_cpu1m", this);
        sb_cpu2m = new("sb_cpu2m", this);
        sb_cpu3m = new("sb_cpu3m", this);
        sb_sbus = new("sb_sbus", this);
    endfunction : new

    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "RUN Phase", UVM_LOW)
    endtask : run_phase

    //function to obtain the way in which data is present
    //returns -1 if not a hit
    function int get_way_hit(int cpu_num, bit[13:0] index, bit [15:0] tag, addr_t addr_type);
        int i;
        case(addr_type)
            ICACHE: begin
                if(!icache[cpu_num].exists(index))begin
                    i =-1;
                end
                else if(icache[cpu_num][index].tag[3] == tag && icache[cpu_num][index].state[3] != STATE_I) i = 3;
                else if(icache[cpu_num][index].tag[2] == tag && icache[cpu_num][index].state[2] != STATE_I) i = 2;
                else if(icache[cpu_num][index].tag[1] == tag && icache[cpu_num][index].state[1] != STATE_I) i = 1;
                else if(icache[cpu_num][index].tag[0] == tag && icache[cpu_num][index].state[0] != STATE_I) i = 0;
                else i = -1;
            end
            DCACHE: begin
                if(!dcache[cpu_num].exists(index)) begin
                    i =-1;
                end
                else if(dcache[cpu_num][index].tag[3] == tag && dcache[cpu_num][index].state[3] != STATE_I) i = 3;
                else if(dcache[cpu_num][index].tag[2] == tag && dcache[cpu_num][index].state[2] != STATE_I) i = 2;
                else if(dcache[cpu_num][index].tag[1] == tag && dcache[cpu_num][index].state[1] != STATE_I) i = 1;
                else if(dcache[cpu_num][index].tag[0] == tag && dcache[cpu_num][index].state[0] != STATE_I) i = 0;
                else i = -1;
            end
        endcase
        return i;
    endfunction: get_way_hit

    //call this function when it is a miss
    //presents the line/way within a set into which we must insert the block
    //this block modifies memory! In other words, it updates the reference model
    function int get_way_miss(int cpu_num, bit[13:0] index, addr_t addr_type, bit update);
        int i;
        bit[15:0] temp_tag; //for write back to memory on 'M' block eviction
        case(addr_type)
            ICACHE: begin
                if(!icache[cpu_num].exists(index)) begin
                    if(update) begin `uvm_info(get_type_name(), $sformatf("Starting cache set fill"),UVM_MEDIUM) end
                    i = 3;
                    if(update)begin icache[cpu_num][index].capacity++; end
                end else if (icache[cpu_num][index].capacity < 4) begin
                    if(update) begin `uvm_info(get_type_name(), $sformatf("Way empty"),UVM_MEDIUM) end
                    case(STATE_I)//fill in order 3,2,1,0
                        icache[cpu_num][index].state[3]: i = 3;
                        icache[cpu_num][index].state[2]: i = 2;
                        icache[cpu_num][index].state[1]: i = 1;
                        icache[cpu_num][index].state[0]: i = 0;
                    endcase
                    if(update)begin icache[cpu_num][index].capacity++; end
                end else begin
                    if(update) begin `uvm_info(get_type_name(), $sformatf("eviction! lru state = %b", icache[cpu_num][index].lru),UVM_MEDIUM) end
                    case(icache[cpu_num][index].lru)
                        3'b000: i = 0;
                        3'b001: i = 0;
                        3'b010: i = 1;
                        3'b011: i = 1;
                        3'b100: i = 2;
                        3'b110: i = 2;
                        3'b101: i = 3;
                        3'b111: i = 3;
                    endcase
                    //if evicted block is in Modified, write to memory
                    //ICACHE is never in modified
                end
            end
            DCACHE: begin
                if(!dcache[cpu_num].exists(index)) begin
                    if(update) begin `uvm_info(get_type_name(), $sformatf("Starting cache set fill"),UVM_MEDIUM) end
                    i = 3;
                    if(update) begin dcache[cpu_num][index].capacity++; end
                end
                else if (dcache[cpu_num][index].capacity < 4) begin
                    if(update) begin `uvm_info(get_type_name(), $sformatf("Way empty"),UVM_MEDIUM) end
                    case(STATE_I)
                        dcache[cpu_num][index].state[3]: i = 3;
                        dcache[cpu_num][index].state[2]: i = 2;
                        dcache[cpu_num][index].state[1]: i = 1;
                        dcache[cpu_num][index].state[0]: i = 0;
                    endcase
                    if(update) begin dcache[cpu_num][index].capacity++; end
                end else begin
                    if(update) begin `uvm_info(get_type_name(), $sformatf("eviction lru state = %0b", icache[cpu_num][index].lru),UVM_MEDIUM) end
                    case(dcache[cpu_num][index].lru)
                        3'b000: i = 0;
                        3'b001: i = 0;
                        3'b010: i = 1;
                        3'b011: i = 1;
                        3'b100: i = 2;
                        3'b110: i = 2;
                        3'b101: i = 3;
                        3'b111: i = 3;
                    endcase
                    //if evicted block is in Modified, write to memory
                    if(dcache[cpu_num][index].state[i] == STATE_M && update) begin
                        temp_tag = dcache[cpu_num][index].tag[i];
                        memory[{temp_tag,index}] = dcache[cpu_num][index].data[i];
                    end
                end
            end
        endcase
        return i;
    endfunction: get_way_miss

    extern function void write_cpu0m(cpu_mon_packet_c packet);
    extern function void write_cpu1m(cpu_mon_packet_c packet);
    extern function void write_cpu2m(cpu_mon_packet_c packet);
    extern function void write_cpu3m(cpu_mon_packet_c packet);
    extern function void write_sbus(sbus_packet_c packet);
    extern function void update_cache(cpu_mon_packet_c packet, int cpu_num);

    //function to update the lru state of given set
    function void update_lru(int cpu_num, int j, bit[13:0] index, addr_t addr_type);
        case(addr_type)
            ICACHE: begin
                case(j)
                    0:icache[cpu_num][index].lru[2:1] = 2'b11;
                    1:begin
                        icache[cpu_num][index].lru[2:1] = 2'b10;
                    end
                    2:begin
                        icache[cpu_num][index].lru[2] = 1'b0;
                        icache[cpu_num][index].lru[0] = 1'b1;
                    end
                    3: begin
                        icache[cpu_num][index].lru[2] = 1'b0;
                        icache[cpu_num][index].lru[0] = 1'b0;
                    end
                endcase
            `uvm_info(get_type_name(), $sformatf("LRU STATE INFO! set index=%0h lrustate=%b line accessed/replaced = %d", index, icache[cpu_num][index].lru, j),UVM_MEDIUM)
            end
            DCACHE: begin
                case(j)
                    0:dcache[cpu_num][index].lru = dcache[cpu_num][index].lru | 3'b110;
                    1:begin
                        dcache[cpu_num][index].lru = dcache[cpu_num][index].lru | 3'b100;
                        dcache[cpu_num][index].lru = dcache[cpu_num][index].lru & 3'b101;
                    end
                    2:begin
                        dcache[cpu_num][index].lru = dcache[cpu_num][index].lru | 3'b001;
                        dcache[cpu_num][index].lru = dcache[cpu_num][index].lru & 3'b011;
                    end
                    3:dcache[cpu_num][index].lru = dcache[cpu_num][index].lru & 3'b010;
                endcase
            `uvm_info(get_type_name(), $sformatf("LRU STATE INFO! set index=%0h lrustate=%b line accessed/replaced = %0d", index, dcache[cpu_num][index].lru, j),UVM_MEDIUM)
            end
        endcase
    endfunction : update_lru

    //function to invalidate block (given index and tag) in cpu (cpu_num)
    function void invalidate(int cpu_num, bit[13:0] index, bit[15:0]  tag);
        if(dcache[cpu_num].exists(index)) begin
            if (dcache[cpu_num][index].tag[0] == tag && dcache[cpu_num][index].state[0] != STATE_I) begin
                dcache[cpu_num][index].state[0] = STATE_I;//change state to I on snoop rdx
                dcache[cpu_num][index].capacity--;
                memory[{tag,index}] = dcache[cpu_num][index].data[0];//write back to memory
            end
            else if (dcache[cpu_num][index].tag[1] == tag && dcache[cpu_num][index].state[1] != STATE_I) begin
                dcache[cpu_num][index].state[1] = STATE_I;
                dcache[cpu_num][index].capacity--;
                memory[{tag,index}] = dcache[cpu_num][index].data[1];
            end
            else if (dcache[cpu_num][index].tag[2] == tag && dcache[cpu_num][index].state[2] != STATE_I) begin
                dcache[cpu_num][index].state[2] = STATE_I;
                dcache[cpu_num][index].capacity--;
                memory[{tag,index}] = dcache[cpu_num][index].data[2];
            end
            else if (dcache[cpu_num][index].tag[3] == tag && dcache[cpu_num][index].state[3] != STATE_I) begin
                dcache[cpu_num][index].state[3] = STATE_I;
                dcache[cpu_num][index].capacity--;
                memory[{tag,index}] = dcache[cpu_num][index].data[3];
            end
        end
    endfunction : invalidate

    function void invalidate_others(int cpu_num, bit[13:0] index, bit[15:0] tag);
        for(int i = 0; i <=3; i++)
            if(i != cpu_num)
                invalidate(i, index, tag);
    endfunction : invalidate_others

    function int exist_others(int cpu_num, bit[13:0] index, bit[15:0] tag);
        int shared = 0, j = 0;
        for(int i = 0; i <=3; i++)
            if(i != cpu_num) begin
                j = get_way_hit(i, index, tag, DCACHE);
                if(j>=0) begin
                    shared = 1;
                    if(dcache[i][index].state[j] == STATE_M) begin
                        dcache[i][index].state[j] = STATE_S;//change to shared on snoop read
                        memory[{tag,index}] = dcache[i][index].data[j];//write back to memory if in modify state
                    end
                    else if(dcache[i][index].state[j] == STATE_E) begin
                        dcache[i][index].state[j] = STATE_S;//change to shared on snoop read
                    end
                end
            end
        return shared;
    endfunction : exist_others

    function void check_data(cpu_mon_packet_c packet, int cpu_num);
        int i, j, x;
        bit  miss; bit [15:0] tag; bit [13:0] index; bit[DATA_WID_LV1-1:0] correct_data;
        i = cpu_num; index = packet.address[15:2]; tag = packet.address[31:16];
        if(packet.illegal == 1 || packet.request_type == WRITE_REQ) begin
            `uvm_info(get_type_name(), $sformatf("CHECK_DATA CPU%0d\nWRITE Request", i),UVM_LOW)
            return;
        end
        for(x = 0; x<=3; x++) begin
            j = get_way_hit(x, index, tag, packet.addr_type);
            miss = (j < 0)? 1'b1: 1'b0;
            if(!miss)
                break;
        end
        if(!miss) begin
            if(packet.addr_type == ICACHE) correct_data = icache[x][index].data[j];
            else correct_data = dcache[x][index].data[j];
        end else if (memory.exists({tag, index})) begin
            correct_data = memory[{tag, index}];
        end else if(packet.address[3]) begin
            correct_data = `CORRECT_DATA_1;
        end else begin
            correct_data = `CORRECT_DATA_0;
        end
        `uvm_info(get_type_name(), $sformatf("CHECK_DATA CPU%0d", i),UVM_LOW)
        if(packet.dat === correct_data) begin
            `uvm_info(get_type_name(), $sformatf("Data match!!! expected = %h received = %h", correct_data, packet.dat),UVM_LOW)
        end else begin
            `uvm_error(get_type_name(), $sformatf("Data MISMATCH!!! expected = %h received = %h", correct_data, packet.dat))
        end
    endfunction : check_data

    //function to generate expected system bus activity packet
    function void generate_expected(cpu_mon_packet_c packet, int cpu_num);
        int i, j, l, lru_rep; bit  miss, other_hit; bit [15:0] tag; bit [13:0] index;
        sbus_packet_c expected;
        i = cpu_num; index = packet.address[15:2]; tag = packet.address[31:16];
        expected = sbus_packet_c::type_id::create("expected", this);
        expected.bus_req_proc_num = i;
        expected.req_address = {packet.address[31:2],2'b00};
        if(packet.illegal == 1) begin  // write to Icache: do nothing
            return;
        end
        j = get_way_hit(cpu_num, index, tag, packet.addr_type);
        miss = (j < 0)? 1'b1: 1'b0;
        other_hit = 1'b0;
        if(!miss) begin
            if(packet.request_type == READ_REQ)     //read hit: do nothing
                return;
            else begin       //write hit (only possible to Dcache) Icache write is illegal
                if(dcache[i][index].state[j] != STATE_S)  //write hit to modified/exclusive
                    return;
                else begin
                    expected.bus_req_type = INVALIDATE;
                end
            end
        end else begin// in case of miss
            //code to handle eviction
            if(packet.addr_type == DCACHE) begin
                lru_rep = get_way_miss(cpu_num, index, packet.addr_type, 0);//0 indicates do not update the cache state and memory
                if(dcache[i].exists(index) && dcache[i][index].state[lru_rep] == STATE_M) begin//block to be replaced is in M
                   expected.proc_evict_dirty_blk_flag = 1'b1; 
                   expected.proc_evict_dirty_blk_addr = {dcache[i][index].tag[lru_rep], index, 2'b00}; 
                   expected.proc_evict_dirty_blk_data = dcache[i][index].data[lru_rep]; 
                end
            end

            //code to handle system bus requests
            if(packet.request_type == READ_REQ) begin
                if (packet.addr_type == DCACHE) begin //Dcache read miss
                    expected.bus_req_type = BUS_RD;
                end else if (packet.addr_type == ICACHE) begin //Icache read miss 
                    expected.bus_req_type = ICACHE_RD;
                end
                for(int k = 0; k <= 3; k++) begin       //read miss
                    if(k != i) begin
                        l = get_way_hit(k, index, tag, packet.addr_type);
                        if(l>=0) begin
                            if(packet.addr_type == DCACHE) begin       //set only for DCache
                                //expected.bus_req_snoop_num = k;
                                expected.bus_req_snoop[k] = 1'b1;
                                expected.req_serviced_by = SERV_NONE;
                                expected.rd_data = dcache[k][index].data[l];
                                expected.cp_in_cache= 1'b1;
                                expected.shared= 1'b1;
                                if(dcache[k][index].state[l] == STATE_M) begin
                                    expected.wr_data_snoop = dcache[k][index].data[l];
                                    expected.snoop_wr_req_flag = 1'b1;
                                end
                            end else if (packet.addr_type == ICACHE) begin //set for ICache read miss
                                expected.req_serviced_by = SERV_L2;
                                expected.rd_data = icache[k][index].data[l];
                            end
                            other_hit = 1'b1;
                            //break;
                        end
                    end
                end
                if(!other_hit) begin
                    expected.req_serviced_by = SERV_L2;
                    if(memory.exists({tag, index})) begin
                        expected.rd_data = memory[{tag,index}];
                    end else if(packet.address[3]) begin
                        expected.rd_data = `CORRECT_DATA_1;
                    end else begin
                        expected.rd_data = `CORRECT_DATA_0;
                    end
                end
            end else if(packet.request_type == WRITE_REQ) begin
                expected.bus_req_type = BUS_RDX;
                expected.req_serviced_by = SERV_L2;
                for(int k = 0; k <= 3; k++) begin
                    if(k != i) begin
                        l = get_way_hit(k, index, tag, packet.addr_type);
                        if(l>=0) begin
                            expected.cp_in_cache= 1'b1;
                            if(dcache[k][index].state[l] == STATE_M) begin
                                //expected.bus_req_snoop_num = k;
                                expected.bus_req_snoop[k] = 1'b1;
                                expected.wr_data_snoop = dcache[k][index].data[l];
                                expected.rd_data = dcache[k][index].data[l];
                                expected.snoop_wr_req_flag = 1'b1;
                                other_hit = 1'b1;
                            end
                            break;
                        end
                    end
                end
                if(!other_hit) begin
                    if(memory.exists({tag, index})) begin
                        expected.rd_data = memory[{tag,index}];
                    end else if(packet.address[3]) begin
                        expected.rd_data = `CORRECT_DATA_1;
                    end else begin
                        expected.rd_data = `CORRECT_DATA_0;
                    end
                end
            end
        end
        expected_sbus[i].push_back(expected);
    endfunction : generate_expected

    function void check_system_packet(int i);
        sbus_packet_c expected, received;
        if(expected_sbus[i].size > 0 && received_sbus[i].size == 0) begin
            `uvm_error(get_type_name(), $sformatf("Expected activity is not observed on the system bus"))
            expected = expected_sbus[i].pop_front();
            `uvm_info(get_type_name(), $sformatf("Expected SBUS Packet \n%s", expected.sprint()),UVM_LOW)
            return;
        end else if(expected_sbus[i].size == 0 && received_sbus[i].size > 0) begin
            `uvm_error(get_type_name(), $sformatf("Additional activity is observed on the system bus"))
            received = received_sbus[i].pop_front();
            `uvm_info(get_type_name(), $sformatf("Received SBUS Packet \n%s", received.sprint()),UVM_LOW)
            return;
        end else if(expected_sbus[i].size == 0 && received_sbus[i].size == 0) begin
            `uvm_info(get_type_name(), $sformatf("No System bus activity expected!! match for this request"),UVM_LOW)
            return;
        end
        expected = expected_sbus[i].pop_front();
        received = received_sbus[i].pop_front();
        if(expected.compare(received)) begin
            `uvm_info(get_type_name(), $sformatf("System bus activity matched for this request"),UVM_LOW)
            `uvm_info(get_type_name(), $sformatf("Expected & Received SBUS Packet \n%s", received.sprint()),UVM_LOW)
        end else begin
            `uvm_error(get_type_name(), $sformatf("System bus activity MISMATCH!!!"))
            `uvm_info(get_type_name(), $sformatf("Expected SBUS Packet \n%s", expected.sprint()),UVM_LOW)
            `uvm_info(get_type_name(), $sformatf("Received SBUS Packet \n%s", received.sprint()),UVM_LOW)
        end
    endfunction : check_system_packet

    function void check_phase(uvm_phase phase);
        int x, y;
        sbus_packet_c trans;
        super.check_phase(phase);
        for(int i = 0; i<=3; i++) begin
            x = 0; y = 0;
            if(expected_sbus[i].size()>0 && received_sbus[i].size()>0) begin
                `uvm_error(get_type_name(), $sformatf("CPU packet not received!!! Expected and Received System Bus packet Queues non empty for CPU%0d", i))
            end else if(expected_sbus[i].size>0) begin
                `uvm_error(get_type_name(), $sformatf("Expected System Bus activity is not observed for CPU%0d", i))
            end else if(received_sbus[i].size>0) begin
                `uvm_error(get_type_name(), $sformatf("Additional System Bus activity is observed for CPU%0d", i))
            end
            while(expected_sbus[i].size()>0) begin
                trans = expected_sbus[i].pop_front();
                `uvm_info(get_type_name(), $sformatf("Expected SBUS Packet %0d:\n%s", x, trans.sprint()),UVM_LOW)
                x++;
            end
            while(received_sbus[i].size()>0) begin
                trans = received_sbus[i].pop_front();
                `uvm_info(get_type_name(), $sformatf("Received SBUS Packet %0d:\n%s", y, trans.sprint()),UVM_LOW)
                y++;
            end
        end
    endfunction : check_phase

endclass : cache_scoreboard_c

function void cache_scoreboard_c::update_cache(cpu_mon_packet_c packet, int cpu_num);
    int i, j;
    bit  miss;
    bit [15:0] tag;
    bit [13:0] index;
    i = cpu_num; index = packet.address[15:2]; tag = packet.address[31:16];
    if(packet.illegal == 1) begin
        `uvm_info(get_type_name(), $sformatf("Illegal packet! Write to Icache of CPU%0d attempted", i),UVM_LOW)
        return;
    end
    j = get_way_hit(cpu_num, index, tag, packet.addr_type);
    miss = (j < 0)? 1'b1: 1'b0;
    if(miss) begin
        j = get_way_miss(cpu_num, index, packet.addr_type, 1);//1 indicates update the cache state and memory
    end
    `uvm_info(get_type_name(), $sformatf("Miss=%0d", miss),UVM_MEDIUM)

    case(packet.request_type)
        WRITE_REQ:begin
            if(packet.addr_type == DCACHE) begin
                dcache[i][index].tag[j] = tag;
                dcache[i][index].data[j] = packet.dat;
                dcache[i][index].state[j] = STATE_M;
                invalidate_others(cpu_num, index, tag);
                update_lru(cpu_num, j, index, packet.addr_type);
            end
        end
        READ_REQ:begin
            if(packet.addr_type == ICACHE) begin
                icache[i][index].tag[j] = tag;
                icache[i][index].data[j] = packet.dat;
                icache[i][index].state[j] = STATE_S;
                update_lru(cpu_num, j, index, packet.addr_type);
            end
            else if(packet.addr_type == DCACHE) begin
                dcache[i][index].tag[j] = tag;
                dcache[i][index].data[j] = packet.dat;
                if(miss && exist_others(cpu_num, index, tag))
                    dcache[i][index].state[j] = STATE_S;
                else if(miss)
                    dcache[i][index].state[j] = STATE_E;
                update_lru(cpu_num, j, index,  packet.addr_type);
            end
        end
    endcase
endfunction : update_cache

function void cache_scoreboard_c::write_cpu0m(cpu_mon_packet_c packet);
    `uvm_info(get_type_name(), $sformatf("cpu_mon_packet from CPU0:\n%s", packet.sprint()),UVM_LOW);
    generate_expected(packet, 0);
    check_data(packet, 0);
    check_system_packet(0);
    update_cache(packet, 0);
endfunction : write_cpu0m

function void cache_scoreboard_c::write_cpu1m(cpu_mon_packet_c packet);
    `uvm_info(get_type_name(), $sformatf("cpu_mon_packet from CPU1:\n%s", packet.sprint()),UVM_LOW);
    generate_expected(packet, 1);
    check_data(packet, 1);
    check_system_packet(1);
    update_cache(packet, 1);
endfunction : write_cpu1m

function void cache_scoreboard_c::write_cpu2m(cpu_mon_packet_c packet);
    `uvm_info(get_type_name(), $sformatf("cpu_mon_packet from CPU2:\n%s", packet.sprint()),UVM_LOW);
    generate_expected(packet, 2);
    check_data(packet, 2);
    check_system_packet(2);
    update_cache(packet, 2);
endfunction : write_cpu2m

function void cache_scoreboard_c::write_cpu3m(cpu_mon_packet_c packet);
    `uvm_info(get_type_name(), $sformatf("cpu_mon_packet from CPU3:\n%s", packet.sprint()),UVM_LOW);
    generate_expected(packet, 3);
    check_data(packet, 3);
    check_system_packet(3);
    update_cache(packet, 3);
endfunction : write_cpu3m

function void cache_scoreboard_c::write_sbus(sbus_packet_c packet);
    int i;
    `uvm_info(get_type_name(), $sformatf("Monitor packet from system bus:\n%s", packet.sprint()),UVM_HIGH)
    i = packet.bus_req_proc_num;
    received_sbus[i].push_back(packet);
endfunction : write_sbus

