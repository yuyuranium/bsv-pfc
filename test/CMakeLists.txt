add_bsim_executable(stack-btest mkStackTester StackTests.bsv
  SRC_DIRS ${PROJECT_SOURCE_DIR}/vendor/bluecheck
           ${PROJECT_SOURCE_DIR}/lib)

add_bsim_executable(pfc-btest mkPostfixCalculatorTester PostfixCalculatorTests.bsv
  SRC_DIRS ${PROJECT_SOURCE_DIR}/vendor/bluecheck
           ${PROJECT_SOURCE_DIR}/lib)

add_bsim_executable(pfc-tb mkPostfixCalculatorTb PostfixCalculatorTb.bsv
  SRC_DIRS ${PROJECT_SOURCE_DIR}/lib)
