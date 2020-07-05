#include <stdio.h>
#include <svdpi.h>

void write_byte( unsigned int addr, unsigned char data );

void read_byte( unsigned int addr, unsigned char *data );

int c_main( void )
{
    unsigned int addr;
    unsigned char b_data, b_exp;

    addr = 0x2000;
    b_data = 0xde;

    write_byte( addr, b_data );
    read_byte( addr, &b_exp );
    if( b_data != b_exp )
        printf("compare error, BYTE : addr = 0x%08x, data = 0x%02x/0x%02x\n",
                                               addr, b_data, b_exp );
    return 0;
}
