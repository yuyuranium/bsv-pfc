#include <systemc.h>
#include <vector>
#include <chrono>
#include <getopt.h>

#include "mkPostfixCalculator32x32_systemc.h"
#include "InstGen.h"

void usage(char *prog_name)
{
    std::cout << "\nPlease provide a postifx expression to the simulator\n"
              << "\nUsage:\n    " << prog_name << " <postfix-expr> [--golden=<golden>]\n\n"
              << "Operands are 32-bit signed integer\n"
              << "Supported operator (instructions):\n"
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
              << "\noptions\n"
              << "    --golden | -g <golden> Specify the golden value of the expression\n"
              << "\nExample:\n    " << prog_name << " 1 2 + 4 swap sub\n\n";
}

int sc_main(int argc, char *argv[])
{
    const static char *opt_str = "hg:";
    const static struct option long_options[] = {
        {"help",   no_argument,       0, 'h'},
        {"golden", required_argument, 0, 'g'},
        {0, 0, 0, 0}
    };

    int opt_idx;
    int golden;
    bool has_golden;
    while (1) {
        int c;
        if ((c = getopt_long(argc, argv, opt_str, long_options, &opt_idx)) ==
            -1) break;

        switch (c) {
        case 'h':
            usage(argv[0]);
            return 0;
        case 'g':
            golden = std::stoi(optarg);
            has_golden = true;
            break;
        default:
            usage(argv[0]);
            return 1;
        }
    }

    // checking if elf file is provided
    if (optind == argc) {
        std::cerr << "\nError: No postfix expression specified\n";
        usage(argv[0]);
        return 1;
    }

    // Generate expression from argv
    std::vector<std::string> expr(argv + optind, argv + argc);

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

    InstGen *igen = new InstGen("igen", expr, has_golden, golden);
    igen->clk_i(clk);
    igen->rst_ni(rst_n);
    igen->full(full);
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

    auto start = std::chrono::high_resolution_clock::now();
    rst_n.write(false);
    sc_start(5, SC_NS);
    rst_n.write(true);
    sc_start();
    auto end = std::chrono::high_resolution_clock::now();
    auto duration =
        std::chrono::duration_cast<std::chrono::duration<double> >(end - start);
    double c = sc_time_stamp() / clk.period();  // elapsed cycles
    std::cout << "Simulation time: " << duration.count() << " seconds\n";
    std::cout << "Simulation freq: " << c / duration.count() / 1000 << " kHz\n";
    sc_close_vcd_trace_file(Tf);  
    return 0;
}
