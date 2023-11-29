package PostfixCalculator32x32;

import PostfixCalculator::*;

typedef PostfixCalculator#(Int#(32)) PostfixCalculator32x32;

module mkPostfixCalculator32x32 (PostfixCalculator32x32);
  PostfixCalculator32x32 pfc <- mkPostfixCalculator(32);
  return pfc;
endmodule

endpackage
