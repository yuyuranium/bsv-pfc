import BlueCheck::*;
import Stack::*;
import StmtFSM::*;
import Clocks::*;

module [BlueCheck] mkStackSpec ();
  Ensure ensure <- getEnsure;

  Stack#(Bit#(4)) dut <- mkStack(8);

  Reg#(Bit#(4)) tmp <- mkRegU();

  function Stmt pushPop() =
    seq
      if (!dut.isFull()) seq
        dut.push(tmp);
        dut.pop();
      endseq
    endseq;

  function Stmt popPush() =
    seq
      if (!dut.isEmpty) seq
        action
          tmp <= dut.top;
          dut.pop();
        endaction
        dut.push(tmp);
      endseq
    endseq;

  function Stmt nop() =
    seq endseq;

  function Stmt prop1(Bit#(4) x) =
    seq
      if (!dut.isFull()) seq
        dut.push(x);
        ensure(dut.top == x);
      endseq
    endseq;

  function Stmt prop2() =
    seq
      if (!dut.isEmpty()) seq
        dut.pop();
      endseq
    endseq;

  function Stmt prop3(Bit#(4) x) =
    seq
      if (dut.isEmpty()) seq
        dut.push(x);
        ensure(!dut.isEmpty());
      endseq
    endseq;

  function Stmt prop4() =
    seq
      if (dut.isFull()) seq
        dut.pop();
        ensure(!dut.isFull());
      endseq
    endseq;

  equiv("pushPop", pushPop, nop);
  equiv("popPush", popPush, nop);

  prop("prop1", prop1);
  prop("prop2", prop2);
  prop("prop3", prop3);
  prop("prop4", prop4);

endmodule

module [Module] mkStackTester ();
  blueCheck(mkStackSpec);
endmodule
