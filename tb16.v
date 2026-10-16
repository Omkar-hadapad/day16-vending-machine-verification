`timescale 1ns/1ps

//==============================================================
// DAY 16 - VENDING MACHINE TESTBENCH
// Self-checking Verification
//==============================================================

module day16_tb;

    //----------------------------------------------------------
    // CLOCK AND RESET
    //----------------------------------------------------------

    reg clk;
    reg reset;

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    //----------------------------------------------------------
    // INPUTS
    //----------------------------------------------------------

    reg coin_5;
    reg coin_10;


    //----------------------------------------------------------
    // PASS / FAIL COUNTERS
    //----------------------------------------------------------

    integer pass_count;
    integer fail_count;


    //----------------------------------------------------------
    // BASIC GATE SIGNALS
    //----------------------------------------------------------

    reg gA;
    reg gB;

    wire g_not;
    wire g_and;
    wire g_or;
    wire g_xor;
    wire g_nand;
    wire g_nor;


    //----------------------------------------------------------
    // BASIC GATE DUTs
    //----------------------------------------------------------

    not_gate NOT_DUT(
        .A(gA),
        .Y(g_not)
    );

    and_gate AND_DUT(
        .A(gA),
        .B(gB),
        .Y(g_and)
    );

    or_gate OR_DUT(
        .A(gA),
        .B(gB),
        .Y(g_or)
    );

    xor_gate XOR_DUT(
        .A(gA),
        .B(gB),
        .Y(g_xor)
    );

    nand_gate NAND_DUT(
        .A(gA),
        .B(gB),
        .Y(g_nand)
    );

    nor_gate NOR_DUT(
        .A(gA),
        .B(gB),
        .Y(g_nor)
    );


    //----------------------------------------------------------
    // EQUALITY COMPARATOR
    //----------------------------------------------------------

    reg [1:0] eqA;
    reg [1:0] eqB;

    wire equal;

    equality_2bit EQ_DUT(
        .A(eqA),
        .B(eqB),
        .equal(equal)
    );


    //----------------------------------------------------------
    // DFF
    //----------------------------------------------------------

    reg dff_D;
    wire dff_Q;

    dff_sync_reset DFF_DUT(
        .clk(clk),
        .reset(reset),
        .D(dff_D),
        .Q(dff_Q)
    );


    //----------------------------------------------------------
    // STATE REGISTER
    //----------------------------------------------------------

    reg [1:0] sr_next_state;
    wire [1:0] sr_state;

    state_register_2bit STATE_REG_DUT(
        .clk(clk),
        .reset(reset),
        .next_state(sr_next_state),
        .state(sr_state)
    );


    //----------------------------------------------------------
    // NEXT-STATE LOGIC
    //----------------------------------------------------------

    reg [1:0] ns_state;
    reg ns_coin5;
    reg ns_coin10;

    wire [1:0] ns_next_state;

    vending_next_state NEXT_DUT(
        .state(ns_state),
        .coin_5(ns_coin5),
        .coin_10(ns_coin10),
        .next_state(ns_next_state)
    );


    //----------------------------------------------------------
    // OUTPUT DECODER
    //----------------------------------------------------------

    reg [1:0] out_state;
    reg out_coin5;
    reg out_coin10;

    wire out_dispense;
    wire out_change;

    vending_output_decoder OUTPUT_DUT(
        .state(out_state),
        .coin_5(out_coin5),
        .coin_10(out_coin10),
        .dispense(out_dispense),
        .change_5(out_change)
    );


    //----------------------------------------------------------
    // COMPLETE STRUCTURAL MACHINE
    //----------------------------------------------------------

    wire s_dispense;
    wire s_change;

    wire [1:0] s_state;
    wire [1:0] s_next_state;

    vending_machine_structural STRUCT_DUT(
        .clk(clk),
        .reset(reset),

        .coin_5(coin_5),
        .coin_10(coin_10),

        .dispense(s_dispense),
        .change_5(s_change),

        .state(s_state),
        .next_state(s_next_state)
    );


    //----------------------------------------------------------
    // COMPLETE RTL MACHINE
    //----------------------------------------------------------

    wire r_dispense;
    wire r_change;

    vending_machine_rtl RTL_DUT(
        .clk(clk),
        .reset(reset),

        .coin_5(coin_5),
        .coin_10(coin_10),

        .dispense(r_dispense),
        .change_5(r_change)
    );


    //----------------------------------------------------------
    // VCD
    //----------------------------------------------------------

    initial begin
        $dumpfile("day16.vcd");
        $dumpvars(0, day16_tb);
    end


    //==========================================================
    // CHECK 1-BIT
    //==========================================================

    task check_1bit;

        input [127:0] name;
        input expected;
        input actual;

        begin

            if (expected === actual) begin

                pass_count = pass_count + 1;

                $display(
                    "PASS : %s | Expected=%b Actual=%b",
                    name,
                    expected,
                    actual
                );

            end

            else begin

                fail_count = fail_count + 1;

                $display(
                    "FAIL : %s | Expected=%b Actual=%b",
                    name,
                    expected,
                    actual
                );

            end

        end

    endtask


    //==========================================================
    // CHECK 2-BIT
    //==========================================================

    task check_2bit;

        input [127:0] name;
        input [1:0] expected;
        input [1:0] actual;

        begin

            if (expected === actual) begin

                pass_count = pass_count + 1;

                $display(
                    "PASS : %s | Expected=%b Actual=%b",
                    name,
                    expected,
                    actual
                );

            end

            else begin

                fail_count = fail_count + 1;

                $display(
                    "FAIL : %s | Expected=%b Actual=%b",
                    name,
                    expected,
                    actual
                );

            end

        end

    endtask


    //==========================================================
    // TEST SEQUENCE
    //==========================================================

    initial begin

        pass_count = 0;
        fail_count = 0;

        reset = 1'b1;

        coin_5 = 1'b0;
        coin_10 = 1'b0;

        gA = 1'b0;
        gB = 1'b0;

        eqA = 2'b00;
        eqB = 2'b00;

        dff_D = 1'b0;

        sr_next_state = 2'b00;

        ns_state = 2'b00;
        ns_coin5 = 1'b0;
        ns_coin10 = 1'b0;

        out_state = 2'b00;
        out_coin5 = 1'b0;
        out_coin10 = 1'b0;


        //======================================================
        // TEST 1 - BASIC GATES
        //======================================================

        $display("");
        $display("==============================================");
        $display("TEST 1 - BASIC GATES");
        $display("==============================================");

        #1;

        gA = 0;
        gB = 0;
        #1;

        check_1bit("NOT 00", 1, g_not);
        check_1bit("AND 00", 0, g_and);
        check_1bit("OR 00",  0, g_or);
        check_1bit("XOR 00", 0, g_xor);
        check_1bit("NAND 00",1, g_nand);
        check_1bit("NOR 00", 1, g_nor);

        gA = 0;
        gB = 1;
        #1;

        check_1bit("NOT 01", 1, g_not);
        check_1bit("AND 01", 0, g_and);
        check_1bit("OR 01",  1, g_or);
        check_1bit("XOR 01", 1, g_xor);
        check_1bit("NAND 01",1, g_nand);
        check_1bit("NOR 01", 0, g_nor);

        gA = 1;
        gB = 0;
        #1;

        check_1bit("NOT 10", 0, g_not);
        check_1bit("AND 10", 0, g_and);
        check_1bit("OR 10",  1, g_or);
        check_1bit("XOR 10", 1, g_xor);
        check_1bit("NAND 10",1, g_nand);
        check_1bit("NOR 10", 0, g_nor);

        gA = 1;
        gB = 1;
        #1;

        check_1bit("NOT 11", 0, g_not);
        check_1bit("AND 11", 1, g_and);
        check_1bit("OR 11",  1, g_or);
        check_1bit("XOR 11", 0, g_xor);
        check_1bit("NAND 11",0, g_nand);
        check_1bit("NOR 11", 0, g_nor);


        //======================================================
        // TEST 2 - EQUALITY COMPARATOR
        //======================================================

        $display("");
        $display("==============================================");
        $display("TEST 2 - EQUALITY COMPARATOR");
        $display("==============================================");

        eqA = 2'b00;
        eqB = 2'b00;
        #1;
        check_1bit("EQ 00=00", 1, equal);

        eqA = 2'b01;
        eqB = 2'b01;
        #1;
        check_1bit("EQ 01=01", 1, equal);

        eqA = 2'b10;
        eqB = 2'b10;
        #1;
        check_1bit("EQ 10=10", 1, equal);

        eqA = 2'b11;
        eqB = 2'b11;
        #1;
        check_1bit("EQ 11=11", 1, equal);

        eqA = 2'b00;
        eqB = 2'b01;
        #1;
        check_1bit("EQ 00!=01", 0, equal);

        eqA = 2'b10;
        eqB = 2'b11;
        #1;
        check_1bit("EQ 10!=11", 0, equal);


        //======================================================
        // TEST 3 - D FLIP-FLOP
        //======================================================

        $display("");
        $display("==============================================");
        $display("TEST 3 - D FLIP-FLOP");
        $display("==============================================");

        reset = 1;
        dff_D = 0;

        @(posedge clk);
        #1;

        check_1bit("DFF RESET", 0, dff_Q);

        reset = 0;
        dff_D = 1;

        @(posedge clk);
        #1;

        check_1bit("DFF LOAD 1", 1, dff_Q);

        dff_D = 0;

        @(posedge clk);
        #1;

        check_1bit("DFF LOAD 0", 0, dff_Q);


        //======================================================
        // TEST 4 - STATE REGISTER
        //======================================================

        $display("");
        $display("==============================================");
        $display("TEST 4 - STATE REGISTER");
        $display("==============================================");

        reset = 1;

        @(posedge clk);
        #1;

        check_2bit("STATE RESET", 2'b00, sr_state);

        reset = 0;

        sr_next_state = 2'b01;

        @(posedge clk);
        #1;

        check_2bit("STATE LOAD S5", 2'b01, sr_state);

        sr_next_state = 2'b10;

        @(posedge clk);
        #1;

        check_2bit("STATE LOAD S10", 2'b10, sr_state);


        //======================================================
        // TEST 5 - NEXT-STATE LOGIC
        //======================================================

        $display("");
        $display("==============================================");
        $display("TEST 5 - NEXT-STATE LOGIC");
        $display("==============================================");

        ns_state = 2'b00;
        ns_coin5 = 0;
        ns_coin10 = 0;
        #1;
        check_2bit("S0 + NO COIN", 2'b00, ns_next_state);

        ns_state = 2'b00;
        ns_coin5 = 1;
        ns_coin10 = 0;
        #1;
        check_2bit("S0 + ₹5", 2'b01, ns_next_state);

        ns_state = 2'b00;
        ns_coin5 = 0;
        ns_coin10 = 1;
        #1;
        check_2bit("S0 + ₹10", 2'b10, ns_next_state);

        ns_state = 2'b01;
        ns_coin5 = 0;
        ns_coin10 = 0;
        #1;
        check_2bit("S5 + NO COIN", 2'b01, ns_next_state);

        ns_state = 2'b01;
        ns_coin5 = 1;
        ns_coin10 = 0;
        #1;
        check_2bit("S5 + ₹5", 2'b10, ns_next_state);

        ns_state = 2'b01;
        ns_coin5 = 0;
        ns_coin10 = 1;
        #1;
        check_2bit("S5 + ₹10", 2'b00, ns_next_state);

        ns_state = 2'b10;
        ns_coin5 = 0;
        ns_coin10 = 0;
        #1;
        check_2bit("S10 + NO COIN", 2'b10, ns_next_state);

        ns_state = 2'b10;
        ns_coin5 = 1;
        ns_coin10 = 0;
        #1;
        check_2bit("S10 + ₹5", 2'b00, ns_next_state);

        ns_state = 2'b10;
        ns_coin5 = 0;
        ns_coin10 = 1;
        #1;
        check_2bit("S10 + ₹10", 2'b00, ns_next_state);

        ns_state = 2'b00;
        ns_coin5 = 1;
        ns_coin10 = 1;
        #1;
        check_2bit("INVALID TWO COINS", 2'b00, ns_next_state);

        ns_state = 2'b11;
        ns_coin5 = 0;
        ns_coin10 = 0;
        #1;
        check_2bit("INVALID STATE", 2'b00, ns_next_state);


        //======================================================
        // TEST 6 - OUTPUT DECODER
        //======================================================

        $display("");
        $display("==============================================");
        $display("TEST 6 - OUTPUT DECODER");
        $display("==============================================");

        out_state = 2'b00;
        out_coin5 = 0;
        out_coin10 = 0;
        #1;

        check_1bit("S0 DISPENSE", 0, out_dispense);
        check_1bit("S0 CHANGE",   0, out_change);

        out_state = 2'b01;
        out_coin5 = 1;
        out_coin10 = 0;
        #1;

        check_1bit("S5+₹5 DISPENSE", 0, out_dispense);
        check_1bit("S5+₹5 CHANGE",   0, out_change);

        out_state = 2'b01;
        out_coin5 = 0;
        out_coin10 = 1;
        #1;

        check_1bit("S5+₹10 DISPENSE", 1, out_dispense);
        check_1bit("S5+₹10 CHANGE",   0, out_change);

        out_state = 2'b10;
        out_coin5 = 1;
        out_coin10 = 0;
        #1;

        check_1bit("S10+₹5 DISPENSE", 1, out_dispense);
        check_1bit("S10+₹5 CHANGE",   0, out_change);

        out_state = 2'b10;
        out_coin5 = 0;
        out_coin10 = 1;
        #1;

        check_1bit("S10+₹10 DISPENSE", 1, out_dispense);
        check_1bit("S10+₹10 CHANGE",   1, out_change);

        // Invalid two coins
        out_state = 2'b10;
        out_coin5 = 1;
        out_coin10 = 1;
        #1;

        check_1bit("INVALID DISPENSE", 0, out_dispense);
        check_1bit("INVALID CHANGE",   0, out_change);


        //======================================================
        // TEST 7 - COMPLETE MACHINE RESET
        //======================================================

        $display("");
        $display("==============================================");
        $display("TEST 7 - MACHINE RESET");
        $display("==============================================");

        reset = 1;
        coin_5 = 0;
        coin_10 = 0;

        @(posedge clk);
        #1;

        check_2bit("MACHINE RESET STATE", 2'b00, s_state);
        check_1bit("RESET DISPENSE", 0, s_dispense);
        check_1bit("RESET CHANGE",   0, s_change);


        //======================================================
        // TEST 8 - ₹5 + ₹5 + ₹5
        //======================================================

        $display("");
        $display("==============================================");
        $display("TEST 8 - ₹5 + ₹5 + ₹5");
        $display("==============================================");

        reset = 1;
        coin_5 = 0;
        coin_10 = 0;

        @(posedge clk);
        #1;

        reset = 0;


        //------------------------------------------------------
        // FIRST ₹5
        //------------------------------------------------------

        coin_5 = 1;
        coin_10 = 0;

        #1;

        check_1bit("FIRST ₹5 DISPENSE", 0, s_dispense);
        check_1bit("FIRST ₹5 CHANGE",   0, s_change);

        @(posedge clk);
        #1;

        check_2bit("₹5 STATE", 2'b01, s_state);


        //------------------------------------------------------
        // SECOND ₹5
        //------------------------------------------------------

        coin_5 = 1;
        coin_10 = 0;

        #1;

        check_1bit("SECOND ₹5 DISPENSE", 0, s_dispense);
        check_1bit("SECOND ₹5 CHANGE",   0, s_change);

        @(posedge clk);
        #1;

        check_2bit("₹10 STATE", 2'b10, s_state);


        //------------------------------------------------------
        // THIRD ₹5
        //------------------------------------------------------

        coin_5 = 1;
        coin_10 = 0;

        #1;

        // Mealy output is checked BEFORE state transition.
        check_1bit("₹15 DISPENSE", 1, s_dispense);
        check_1bit("₹15 CHANGE",   0, s_change);

        @(posedge clk);
        #1;

        check_2bit("AFTER ₹15 STATE", 2'b00, s_state);

        coin_5 = 0;
        coin_10 = 0;

        #1;

        check_1bit("AFTER ₹15 DISPENSE", 0, s_dispense);
        check_1bit("AFTER ₹15 CHANGE",   0, s_change);


        //======================================================
        // TEST 9 - ₹10 + ₹5
        //======================================================

        $display("");
        $display("==============================================");
        $display("TEST 9 - ₹10 + ₹5");
        $display("==============================================");

        reset = 1;
        coin_5 = 0;
        coin_10 = 0;

        @(posedge clk);
        #1;

        reset = 0;


        // ₹10
        coin_5 = 0;
        coin_10 = 1;

        @(posedge clk);
        #1;

        check_2bit("₹10 STATE", 2'b10, s_state);


        // ₹5
        coin_5 = 1;
        coin_10 = 0;

        #1;

        check_1bit("₹10+₹5 DISPENSE", 1, s_dispense);
        check_1bit("₹10+₹5 CHANGE",   0, s_change);

        @(posedge clk);
        #1;

        check_2bit("AFTER DISPENSE STATE", 2'b00, s_state);


        //======================================================
        // TEST 10 - ₹10 + ₹10
        //======================================================

        $display("");
        $display("==============================================");
        $display("TEST 10 - ₹10 + ₹10");
        $display("==============================================");

        reset = 1;
        coin_5 = 0;
        coin_10 = 0;

        @(posedge clk);
        #1;

        reset = 0;


        // First ₹10
        coin_5 = 0;
        coin_10 = 1;

        @(posedge clk);
        #1;

        check_2bit("FIRST ₹10 STATE", 2'b10, s_state);


        // Second ₹10
        coin_5 = 0;
        coin_10 = 1;

        #1;

        check_1bit("₹20 DISPENSE", 1, s_dispense);
        check_1bit("₹20 CHANGE",   1, s_change);

        @(posedge clk);
        #1;

        check_2bit("₹20 AFTER STATE", 2'b00, s_state);


        //======================================================
        // TEST 11 - INVALID TWO COINS
        //======================================================

        $display("");
        $display("==============================================");
        $display("TEST 11 - INVALID TWO COINS");
        $display("==============================================");

        reset = 1;
        coin_5 = 0;
        coin_10 = 0;

        @(posedge clk);
        #1;

        reset = 0;

        coin_5 = 1;
        coin_10 = 1;

        #1;

        check_1bit("INVALID INPUT DISPENSE", 0, s_dispense);
        check_1bit("INVALID INPUT CHANGE",   0, s_change);


        //======================================================
        // TEST 12 - STRUCTURAL VS RTL
        //======================================================

        $display("");
        $display("==============================================");
        $display("TEST 12 - STRUCTURAL VS RTL");
        $display("==============================================");

        reset = 1;
        coin_5 = 0;
        coin_10 = 0;

        @(posedge clk);
        #1;

        check_1bit(
            "STRUCT/RTL DISPENSE RESET",
            s_dispense,
            r_dispense
        );

        check_1bit(
            "STRUCT/RTL CHANGE RESET",
            s_change,
            r_change
        );

        reset = 0;


        // ₹5
        coin_5 = 1;
        coin_10 = 0;

        @(posedge clk);
        #1;

        check_1bit(
            "STRUCT/RTL DISPENSE ₹5",
            s_dispense,
            r_dispense
        );

        check_1bit(
            "STRUCT/RTL CHANGE ₹5",
            s_change,
            r_change
        );


        // ₹5
        coin_5 = 1;
        coin_10 = 0;

        @(posedge clk);
        #1;

        check_1bit(
            "STRUCT/RTL DISPENSE ₹10",
            s_dispense,
            r_dispense
        );

        check_1bit(
            "STRUCT/RTL CHANGE ₹10",
            s_change,
            r_change
        );


        // ₹10 -> total ₹20
        coin_5 = 0;
        coin_10 = 1;

        #1;

        check_1bit(
            "STRUCT/RTL DISPENSE ₹20",
            s_dispense,
            r_dispense
        );

        check_1bit(
            "STRUCT/RTL CHANGE ₹20",
            s_change,
            r_change
        );


        //======================================================
        // TEST 13 - SAFETY CHECK
        //======================================================

        $display("");
        $display("==============================================");
        $display("TEST 13 - SAFETY CHECK");
        $display("==============================================");

        reset = 1;
        coin_5 = 0;
        coin_10 = 0;

        @(posedge clk);
        #1;

        reset = 0;

        repeat(20) begin

            #1;

            if ((s_dispense === 1'bx) ||
                (s_change === 1'bx)) begin

                fail_count = fail_count + 1;

                $display(
                    "FAIL : UNKNOWN OUTPUT | DISPENSE=%b CHANGE=%b",
                    s_dispense,
                    s_change
                );

            end

            else begin

                pass_count = pass_count + 1;

                $display(
                    "PASS : OUTPUT VALID | DISPENSE=%b CHANGE=%b",
                    s_dispense,
                    s_change
                );

            end

            @(posedge clk);

        end


        //======================================================
        // FINAL SUMMARY
        //======================================================

        coin_5 = 0;
        coin_10 = 0;

        #10;

        $display("");
        $display("================================================");
        $display("DAY 16 - VENDING MACHINE VERIFICATION SUMMARY");
        $display("================================================");

        $display("PASS COUNT = %0d", pass_count);
        $display("FAIL COUNT = %0d", fail_count);

        if (fail_count == 0) begin

            $display("");
            $display("PROJECT STATUS = PASS");
            $display("ALL VERIFIED TESTS PASSED");

        end

        else begin

            $display("");
            $display("PROJECT STATUS = FAIL");
            $display("DEBUG REQUIRED");

        end

        $display("================================================");

        $finish;

    end


    //==========================================================
    // MONITOR
    //==========================================================

    initial begin

        $monitor(
            "TIME=%0t | RESET=%b | C5=%b | C10=%b | STATE=%b | NEXT=%b | DISPENSE=%b | CHANGE=%b",
            $time,
            reset,
            coin_5,
            coin_10,
            s_state,
            s_next_state,
            s_dispense,
            s_change
        );

    end

endmodule