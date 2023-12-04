#include <systemc.h>
#include <iostream>
#include <string>
#include <utility>

#include "InstGen.h"

void InstGen::handle_clk()
{
    exec_en.write(false);
    exec_inst.write(0);
    push_en.write(false);
    push_opd.write(0);
    while (true) {
        wait();
        for (std::string &e : expr) {
            auto p = parse_expr(e);

            if (p.first) {
                int inst = p.second;
                while (!exec_ready.read()) {
                    wait();
                }
                exec_en.write(true);
                exec_inst.write(inst);
                std::cout << "[" << sc_time_stamp() << "]\t"
                          << "Executing: " << e << "\n";
                wait();
            } else {
                int opd = p.second;
                if (full.read()) {
                    std::cout << "[" << sc_time_stamp() << "]\t"
                              << "Error: Stack overflowed when pushing "
                              << opd << "\n";
                    sc_stop();
                }
                while (!push_ready.read()) {
                    wait();
                }
                push_en.write(true);
                push_opd.write(opd);
                std::cout << "[" << sc_time_stamp() << "]\t"
                          << "Pushing: " << opd << "\n";
                wait();
            }
            exec_en.write(false);
            exec_inst.write(0);
            push_en.write(false);
            push_opd.write(0);
        }
        // wait for result ready
        while (!result_ready.read()) {
            wait();
        }
        std::cout << "[" << sc_time_stamp() << "]\t"
                  << "Got result: " << result.read().to_int() << "\n";
        sc_stop();
    }
}

std::pair<bool, int> InstGen::parse_expr(std::string e)
{
    bool is_inst = true;
    int opd_or_inst = 0;

    // decode the primary expression
    if (e == "+" || e == "add") {
        opd_or_inst = 0;
    } else if (e == "-" || e == "sub") {
        opd_or_inst = 1;
    } else if (e == ">>" || e == "srl") {
        opd_or_inst = 2;
    } else if (e == "<<" || e == "sll") {
        opd_or_inst = 3;
    } else if (e == "&" || e == "and") {
        opd_or_inst = 4;
    } else if (e == "|" || e == "or") {
        opd_or_inst = 5;
    } else if (e == "^" || e == "xor") {
        opd_or_inst = 6;
    } else if (e == "dup") {
        opd_or_inst = 7;
    } else if (e == "swap") {
        opd_or_inst = 8;
    } else if (e == "eqz") {
        opd_or_inst = 9;
    } else if (e == "pop") {
        opd_or_inst = 10;
    } else {
        is_inst = false;
        opd_or_inst = std::stoi(e);
    }

    return std::make_pair(is_inst, opd_or_inst);
}
