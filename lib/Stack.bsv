package Stack;

interface Stack#(type data_t);
  method Action push(data_t din);
  method Action pop();
  method data_t top();
  (* always_ready *)
  method Bool isEmpty();
  (* always_ready *)
  method Bool isFull();
endinterface

module mkStack#(Integer depth) (Stack#(data_t))
    provisos(Bits#(data_t, data_width_nt));

  Reg#(data_t) stack_mem[depth];
  for (Integer i = 0; i < depth; i = i + 1)
    stack_mem[i] <- mkRegU;

  StackSize size    <- mkStackSize(depth);
  PulseWire pushing <- mkPulseWire();
  PulseWire popping <- mkPulseWire();
  Wire#(data_t) din_w   <- mkWire();

  Bool full  = size.equal(depth);
  Bool empty = size.equal(0);

  rule push_r (pushing && !popping);
    size.incr();
    stack_mem[0] <= din_w;
    for (Integer i = 1; i < depth; i = i + 1)
      stack_mem[i] <= stack_mem[i - 1];
  endrule

  rule pop_r (popping && !pushing);
    size.decr();
    for (Integer i = 1; i < depth; i = i + 1)
      stack_mem[i - 1] <= stack_mem[i];
  endrule

  method Action push(data_t din) if (!full);
    pushing.send();
    din_w <= din;
  endmethod

  method Action pop() if (!empty);
    popping.send();
  endmethod

  method data_t top if (!empty);
    return stack_mem[0];
  endmethod

  method Bool isEmpty = empty;
  method Bool isFull = full;
endmodule

interface StackSize;
  method Action incr;
  method Action decr;
  method Action clear;
  method Bool equal(Integer n);
endinterface

module _mkStackSize#(Reg#(UInt#(w)) c) (StackSize);
  method Action incr;
    c <= c + 1;
  endmethod

  method Action decr;
    c <= c - 1;
  endmethod

  method Action clear;
    c <= 0;
  endmethod

  method Bool equal(Integer n) = c == fromInteger(n);
endmodule

module mkStackSize#(Integer depth) (StackSize);
  StackSize s;
  if      (depth < (2 ** 1)) begin Reg#(UInt#(1)) r <- mkReg(0); s <- _mkStackSize(r); end
  else if (depth < (2 ** 2)) begin Reg#(UInt#(2)) r <- mkReg(0); s <- _mkStackSize(r); end
  else if (depth < (2 ** 3)) begin Reg#(UInt#(3)) r <- mkReg(0); s <- _mkStackSize(r); end
  else if (depth < (2 ** 4)) begin Reg#(UInt#(4)) r <- mkReg(0); s <- _mkStackSize(r); end
  else if (depth < (2 ** 5)) begin Reg#(UInt#(5)) r <- mkReg(0); s <- _mkStackSize(r); end
  else if (depth < (2 ** 6)) begin Reg#(UInt#(6)) r <- mkReg(0); s <- _mkStackSize(r); end
  else if (depth < (2 ** 7)) begin Reg#(UInt#(7)) r <- mkReg(0); s <- _mkStackSize(r); end
  else if (depth < (2 ** 8)) begin Reg#(UInt#(8)) r <- mkReg(0); s <- _mkStackSize(r); end
  else error("Cannot instantiate stack with depth larger than 256");
  return s;
endmodule

endpackage
