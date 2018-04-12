
//include directories
    //-incdir ../design/lv1
    //-incdir ../design/lv2
    //-incdir ../design/common
    -incdir ../uvm
    //-incdir ../gold
    -incdir ../test

//compile design files
    ../design/lv2/def_lv2.sv
    ../design/common/addr_segregator_proc.sv
    ../design/lv2/lru_block_lv2.sv
    ../design/common/blk_hit_proc_md.sv
    ../design/common/access_blk_proc_md.sv
    ../design/common/free_blk_md.sv
    ../design/common/blk_to_be_accessed_md.sv
    ../design/lv2/main_func_lv2.sv
    ../design/lv2/cache_block_lv2.sv
    ../design/lv2/cache_controller_lv2.sv
    ../design/lv2/cache_wrapper_lv2.sv

    ../design/lv1/def_lv1.sv
    ../design/lv1/access_blk_snoop_md.sv
    ../design/lv1/addr_segregator_snoop.sv
    ../design/lv1/blk_hit_snoop_md.sv
    ../design/lv1/blk_to_be_accessed_snoop_md.sv
    ../design/lv1/lru_block_lv1.sv
    ../design/lv1/mesi_fsm_lv1.sv
    ../design/lv1/main_func_lv1_il.sv
    ../design/lv1/main_func_lv1_dl.sv
    ../design/lv1/cache_controller_lv1_il.sv
    ../design/lv1/cache_controller_lv1_dl.sv
    ../design/lv1/cache_block_lv1_il.sv
    ../design/lv1/cache_block_lv1_dl.sv
    ../design/lv1/cache_wrapper_lv1_il.sv
    ../design/lv1/cache_wrapper_lv1_dl.sv
    ../design/lv1/cache_lv1_unicore.sv
    ../design/lv1/cache_lv1_multicore.sv
    ../design/cache_top.sv

//compile testbench files
    ../gold/memory.sv
    ../gold/lrs_arbiter.sv
    ../uvm/cpu_lv1_interface.sv
    ../uvm/system_bus_interface.sv
    ../uvm/cpu_pkg.sv
    ../uvm/top.sv
