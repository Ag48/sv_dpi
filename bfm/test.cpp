#include <iostream>
#include <svdpi.h>

extern "C" void write_issue(unsigned int this_addr, unsigned this_data);
extern "C" void read_issue(unsigned int this_addr);
extern "C" void wait_cycle(int val);

extern "C" int test() {
  std::cout << "Start test" << std::endl;
  write_issue(0x00000000, 0x00112233);
  read_issue (0x00000000);
  std::cout << "End test" << std::endl;
  return 0;
}
