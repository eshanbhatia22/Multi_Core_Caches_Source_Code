    +access+rwc                   //allow probes to record signals
    -timescale 1ns/1ns            //set simulation time precision
    -gui                          //launch user interface
    -input ../uvm/waves.tcl

//setup UVM home
    -uvmhome $UVMHOME

//UVM options
    +UVM_VERBOSITY=UVM_LOW

//Add the list of test classes here (uncomment only one)
    //+UVM_TESTNAME=base_test         //-> done
    +UVM_TESTNAME=five_trans_test   //-> done

//file list containing design and TB files to compiled
    -f file_list.f
