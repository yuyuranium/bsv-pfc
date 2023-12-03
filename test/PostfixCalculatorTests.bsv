import BlueCheck::*;
import Stack::*;
import PostfixCalculator::*;
import StmtFSM::*;

typedef Int#(32) DType;

Integer kStackDepth = 100;

module [BlueCheck] mkPostfixCalculatorSpec ();
  Ensure ensure <- getEnsure;

  PostfixCalculator#(DType) dut <- mkPostfixCalculator(kStackDepth);
  Reg#(DType) tmp <- mkReg(0);

  function Stmt push(DType x) =
    seq
      if (!dut.isFull()) seq
        dut.push(x);
        ensure(dut.getResult() == x);
      endseq
    endseq;

  function Stmt testOp(DType x, PFCInst op) =
    seq
      if (dut.isFull()) seq
        dut.exec(PFCPop);
      endseq

      action
        tmp <= dut.getResult();
        dut.push(x);
      endaction

      action
        tmp <= case (op)
          PFCAdd:  return tmp + x;
          PFCSub:  return tmp - x;
          PFCSrl:  return tmp >> x;
          PFCSll:  return tmp << x;
          PFCAnd:  return tmp & x;
          PFCOr:   return tmp | x;
          PFCXor:  return tmp ^ x;
          default: return tmp;
        endcase;
      endaction

      if (!(dut.isFull && op == PFCDup || dut.isEmpty && op == PFCPop)) action
        dut.exec(op);
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

  function Stmt dup() =
    seq
      if (dut.isFull()) seq
        dut.exec(PFCAdd);
      endseq else if (dut.isEmpty()) seq
        push(tmp);
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
  // Customise default BlueCheck parameters
  BlueCheck_Params params = bcParams;
  params.showTime = True;
  params.allowViewing = True;
  params.numIterations = 100000;

  // Generate checker
  Stmt s <- mkModelChecker(mkPostfixCalculatorSpec, params);
  mkAutoFSM(s);
endmodule
