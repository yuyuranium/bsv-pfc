package PostfixCalculator;

import Stack::*;
import StmtFSM::*;

typedef enum {
  PFCAdd = 0,
  PFCSub,
  PFCSrl,
  PFCSll,
  PFCAnd,
  PFCOr,
  PFCXor,
  PFCDup,
  PFCSwap,
  PFCEqz,
  PFCPop
} PFCInst deriving(Bits, Eq, FShow);

interface PostfixCalculator#(type data_t);
  method Action push(data_t opd);
  method Action exec(PFCInst inst);
  method data_t getResult();
  (* always_ready *)
  method Bool isFull();
  (* always_ready *)
  method Bool isEmpty();
endinterface

module mkPostfixCalculator#(Integer mem_depth) (PostfixCalculator#(data_t))
    provisos(Bits#(data_t, data_width_nt), Literal#(data_t), Eq#(data_t));

  function data_t arithm_compute(data_t data_a, data_t data_b, PFCInst inst);
    Int#(data_width_nt) a = unpack(pack(data_a));
    Int#(data_width_nt) b = unpack(pack(data_b));
    Int#(data_width_nt) c =
      case (inst)
        PFCAdd:  return a + b;
        PFCSub:  return a - b;
        PFCSrl:  return a >> b;
        PFCSll:  return a << b;
        PFCAnd:  return a & b;
        PFCOr:   return a | b;
        PFCXor:  return a ^ b;
        default: return 0;
      endcase;

    return unpack(pack(c));
  endfunction

  // main stack
  Stack#(data_t) stack <- mkStack(mem_depth);

  // register for the two operands
  Reg#(data_t) opd1 <- mkReg(0);
  Reg#(data_t) opd2 <- mkReg(0);

  // register to store the operation
  Reg#(PFCInst) op <- mkReg(PFCAdd);

  // finite state machine to trigger execution
  FSM exec_fsm <- mkFSM(seq
    action
      opd2 <= stack.top;
      stack.pop();
    endaction

    if (pack(op) <= pack(PFCXor)) seq
      // Do arithmetic computation
      action  // get second operand
        opd1 <= stack.top;
        stack.pop;
      endaction
      stack.push(arithm_compute(opd1, opd2, op));  // push the result
    endseq else if (op == PFCDup) seq
      // push the operand twice
      stack.push(opd2);
      stack.push(opd2);
    endseq else if (op == PFCSwap) seq
      action  // get second operand
        opd1 <= stack.top;
        stack.pop;
      endaction
      // push the operands in reversed order
      stack.push(opd2);
      stack.push(opd1);
    endseq else if (op == PFCEqz) seq
      // push 1 if the operand equals to zero
      stack.push(opd2 == 0 ? 1 : 0);
    endseq else if (op == PFCPop) seq
      noAction;
      // do nothing
    endseq else seq
      stack.push(opd2);  // do nothing
    endseq
  endseq);

  method Action push(data_t opd) if (exec_fsm.done());
    stack.push(opd);
  endmethod

  method Action exec(PFCInst inst);
    op <= inst;
    exec_fsm.start();
  endmethod

  method data_t getResult if (exec_fsm.done) = stack.top;
  method Bool isFull = stack.isFull;
  method Bool isEmpty = stack.isEmpty;
endmodule

endpackage
