#! /usr/bin/env python3
#
# Python script to generate random postfix expression

import sys
import random
import argparse

# Default instructions to generate
instructions = ['+', '-']

def generate_random_postfix_expression(length: int, min: int, max: int) -> str:
    golden = []
    stack = []
    for i in range(length):
        if random.random() < 0.5 and len(stack) >= 2:
            op = random.choice(instructions)
            # Generate composite expression
            right_expr = stack.pop()
            left_expr = stack.pop()
            stack.append(f'{left_expr} {right_expr} {op}')
            # Compute the golden in infix
            right_opd = golden.pop()
            left_opd = golden.pop()
            golden.append(eval(f'{left_opd} {op} {right_opd}'))
        else:
            opd = random.randint(min, max)
            stack.append(opd)
            golden.append(opd)

    while len(stack) > 1:
        op = random.choice(instructions)
        # Generate composite expression
        right_expr = stack.pop()
        left_expr = stack.pop()
        stack.append(f'{left_expr} {right_expr} {op}')
        # Compute the golden in infix
        right_opd = golden.pop()
        left_opd = golden.pop()
        golden.append(eval(f'{left_opd} {op} {right_opd}'))

    return f'{stack[0]} --golden={golden[0]}'

parser = argparse.ArgumentParser()

parser.add_argument('n', type=int,
                    default=100, help='maximum length of the expression')
parser.add_argument('--min', type=int,
                    default=0, help='lower bound of operands')
parser.add_argument('--max', type=int,
                    default=100, help='upper bound of operands')
parser.add_argument('--inst', type=str,
                    nargs='+', help='instructions to generate')

args = parser.parse_args()

if args.inst:
    instructions = args.inst

print(generate_random_postfix_expression(args.n, args.min, args.max))
