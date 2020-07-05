// This file is compiled as C++ and linked with stdlib
// into the simulation executable.

#include <iostream>
#include <svdpi.h>

using namespace std;

extern "C" void helloFromSV(svBit);

extern "C" int helloFromCpp(svLogic a) {
  // 0 is 0
  // 1 is 1
  // 2 is Z
  // 3 is X
  int a_int = a;
  cout << "(C++) a is " << a_int << endl;
  cout << "Scope is " << svGetNameFromScope(svGetScope()) << endl;
  helloFromSV(a);
  return 0;
}
