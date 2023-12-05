add_bsim_executable(stack-btest mkStackTester StackTests.bsv
  LINK_LIBS Stack BlueCheck)

add_bsim_executable(pfc-btest mkPostfixCalculatorTester PostfixCalculatorTests.bsv
  LINK_LIBS Stack PostfixCalculator BlueCheck)

add_bsim_executable(pfc-tb mkPostfixCalculatorTb PostfixCalculatorTb.bsv
  LINK_LIBS Stack PostfixCalculator)
