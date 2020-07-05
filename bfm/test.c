#include <svdpi.h>

void write_issue(unsigned int this_addr, unsigned this_data);
void read_issue(unsigned int this_addr);
void wait_cycle(int val);

int test(void) {
  write_issue(0x00000000, 0x00112233);
  read_issue (0x00000000);
  return 0;
}
