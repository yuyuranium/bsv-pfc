#ifndef _SIM_INST_GEN_H
#define _SIM_INST_GEN_H

#include <systemc.h>

#include <vector>
#include <utility>

SC_MODULE(InstGen) {
  public:
    sc_in<bool> clk_i;
    sc_in<bool> rst_ni;

    sc_in<bool> full;

    sc_in<sc_bv<32> > result;
    sc_in<bool> result_ready;
    
    sc_out<bool> exec_en;
    sc_out<sc_bv<4> > exec_inst;
    sc_in<bool> exec_ready;
    
    sc_out<bool> push_en;
    sc_out<sc_bv<32> > push_opd;
    sc_in<bool> push_ready;

    // Constructor
    InstGen(sc_module_name name, std::vector<std::string> &expr)
        : sc_module(name)
    {
        this->expr = expr;
        SC_HAS_PROCESS(InstGen);
        SC_THREAD(handle_clk);
        sensitive << clk_i.neg();
        reset_signal_is(rst_ni, false);
    }

  private:
    std::vector<std::string> expr;
    void handle_clk();
    std::pair<bool, int> parse_expr(std::string);
};

#endif
