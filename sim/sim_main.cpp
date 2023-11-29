#include <systemc.h>
#include <vector>

#include "mkPostfixCalculator32x32_systemc.h"
#include "InstGen.h"

int sc_main(int argc, char *argv[])
{
    if (argc < 2) {
        std::cout << "\nPlease provide a postifx expression to the simulator\n"
                  << "\nUsage:\n    " << argv[0] << " <postfix-expr>\n\n"
                  << "Operands are 32-bit signed integer\n"
                  << "Supported operator (instructions) are\n"
                  << "    add (+)\n"
                  << "    sub (-)\n"
                  << "    srl (>>)\n"
                  << "    sll (<<)\n"
                  << "    and (&)\n"
                  << "    or  (|)\n"
                  << "    xor (^)\n"
                  << "    dup\n"
                  << "    swap\n"
                  << "    eqz\n"
                  << "    pop\n"
                  << "\nExample:\n    " << argv[0] << " 1 2 + 4 swap sub\n\n";
        exit(-1);
    }

    sc_clock clk("clk", 1, SC_NS);
    sc_signal<bool> rst_n("rst_n");

    sc_signal<bool> empty;
    sc_signal<bool> full;

    sc_signal<sc_bv<32> > result;
    sc_signal<bool> result_ready;

    sc_signal<bool> exec_en;
    sc_signal<sc_bv<4> > exec_inst;
    sc_signal<bool> exec_ready;

    sc_signal<bool> push_en;
    sc_signal<sc_bv<32> > push_opd;
    sc_signal<bool> push_ready;

    mkPostfixCalculator32x32 *pfc = new mkPostfixCalculator32x32("pfc");
    pfc->CLK(clk);
    pfc->RST_N(rst_n);
    pfc->isEmpty(empty);
    pfc->isFull(full);
    pfc->getResult(result);
    pfc->RDY_getResult(result_ready);
    pfc->EN_exec(exec_en);
    pfc->exec_inst(exec_inst);
    pfc->RDY_exec(exec_ready);
    pfc->EN_push(push_en);
    pfc->push_opd(push_opd);
    pfc->RDY_push(push_ready);

    // Generate expression from argv
    std::vector<std::string> expr(argv + 1, argv + argc);

    InstGen *igen = new InstGen("igen", expr);
    igen->clk_i(clk);
    igen->rst_ni(rst_n);
    igen->result(result);
    igen->result_ready(result_ready);
    igen->exec_en(exec_en);
    igen->exec_inst(exec_inst);
    igen->exec_ready(exec_ready);
    igen->push_en(push_en);
    igen->push_opd(push_opd);
    igen->push_ready(push_ready);

    sc_trace_file* Tf;
    Tf = sc_create_vcd_trace_file("traces");
    sc_trace(Tf, clk, "clk");
    sc_trace(Tf, rst_n, "rst_n");
    sc_trace(Tf, result, "result");
    sc_trace(Tf, result_ready, "result_ready");
    sc_trace(Tf, exec_en, "exec_en");
    sc_trace(Tf, exec_inst, "exec_inst");
    sc_trace(Tf, exec_ready, "exec_ready");
    sc_trace(Tf, push_en, "push_en");
    sc_trace(Tf, push_opd, "push_opd");
    sc_trace(Tf, push_ready, "push_ready");

    rst_n.write(false);
    sc_start(5, SC_NS);
    rst_n.write(true);
    sc_start();
    sc_close_vcd_trace_file(Tf);  
    return 0;
}
