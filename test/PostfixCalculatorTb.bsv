import PostfixCalculator::*;
import StmtFSM::*;

module mkPostfixCalculatorTb ();
  PostfixCalculator#(Int#(8)) dut <- mkPostfixCalculator(16);
  Reg#(int) cnt <- mkReg(0);

  rule rl_inc;
    cnt <= cnt + 1;
  endrule

  // main
  mkAutoFSM(
  seq
    dut.push(1);
    // 1 2 + 3 – 4 5 & | 6 7 ^ <<
    dut.push(2);
    dut.exec(PFCAdd);
    dut.push(3);
    dut.exec(PFCSub);
    dut.push(4);
    dut.push(5);
    dut.exec(PFCAnd);
    dut.exec(PFCOr);
    dut.push(6);
    dut.push(7);
    dut.exec(PFCXor);
    dut.exec(PFCSll);
    $display("[%d] Result: %d", cnt, dut.getResult());  // Result = 8

    // a b ^ dup 1 - & eqz
    dut.push(9);  // a = 8, b = 9
    dut.exec(PFCXor);
    dut.exec(PFCDup);
    dut.push(1);
    dut.exec(PFCSub);
    dut.exec(PFCAnd);
    dut.exec(PFCEqz);
    $display("[%d] Result: %d", cnt, dut.getResult());  // Result = 1

    // a (dup 1 & swap 1 >>)8x (+)8x
    dut.push('b01110010);
    dut.exec(PFCAdd);  // a = 01110011
    repeat (8) seq
      dut.exec(PFCDup);
      dut.push(1);
      dut.exec(PFCAnd);
      dut.exec(PFCSwap);
      dut.push(1);
      dut.exec(PFCSrl);
    endseq
    noAction;
    repeat (8) seq
      dut.exec(PFCAdd);
    endseq
    $display("[%d] Result: %d", cnt, dut.getResult());  // Result = 5
  endseq);

endmodule
