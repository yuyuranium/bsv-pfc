import BlueCheck::*;
import Stack::*;
import PostfixCalculator::*;
import StmtFSM::*;
import Clocks::*;

module [BlueCheck] mkPostfixCalculatorSpec#(Reset r) ();
  Ensure ensure <- getEnsure;

  PostfixCalculator#(Int#(8)) dut <- mkPostfixCalculator(reset_by r, 8);

  Reg#(Int#(8)) tmp <- mkReg(0);
  Reg#(Int#(32)) cnt <- mkReg(0);

  function Stmt push(Int#(8) x) =
    seq
      if (dut.isFull()) seq
        dut.exec(PFCAdd);  // reduce
      endseq else seq
        dut.push(x);
        ensure(dut.getResult() == x);
      endseq
    endseq;

  function Stmt testOp(Int#(8) x, PFCInst op) = 
    seq
      if (dut.isFull()) seq
        dut.exec(PFCAdd);
      endseq

      action
        tmp <= dut.getResult();
        dut.push(x);
      endaction

      action
        tmp <= case (op)
          PFCAdd:   return tmp + x;
          PFCSub:   return tmp - x;
          PFCSrl:   return tmp >> x;
          PFCSll:   return tmp << x;
          PFCAnd:   return tmp & x;
          PFCOr:    return tmp | x;
          PFCXor:   return tmp ^ x;
          default: return tmp;
        endcase;
        if (!(dut.isFull && op == PFCDup)) action
          dut.exec(op);
        endaction
      endaction


      if (pack(op) <= pack(PFCXor)) seq
        $display("res = %d expect = %d", dut.getResult(), tmp);
        ensure(dut.getResult() == tmp);
      endseq else if (op == PFCDup) seq
        ensure(dut.getResult() == x);
      endseq else if (op == PFCSwap) seq
        ensure(dut.getResult() == tmp);
      endseq else if (op == PFCEqz) seq
        ensure(dut.getResult() == (x == 0 ? 1 : 0));
      endseq
    endseq;

  function Stmt dup(Int#(8) x) =
    seq
      if (dut.isFull()) seq
        dut.exec(PFCAdd);
      endseq else if (dut.isEmpty()) seq
        push(x);
      endseq
      action
        tmp <= dut.getResult();
        dut.exec(PFCDup);
      endaction
      ensure(dut.getResult() == tmp);
    endseq;

  prop("push", push);
  prop("testOp", testOp);
  prop("dup", dup);

endmodule

module [Module] mkPostfixCalculatorTester ();
  blueCheck(mkPostfixCalculatorSpec(noReset));
endmodule
