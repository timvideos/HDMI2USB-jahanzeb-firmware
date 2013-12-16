OEB = 0x02;
OED = 0x01;
PB1 = 0;
PD0 = 0;
while ( PD5 != 0 );
PD0 = 1;
while ( !PD1 );
PB1 = 1;
OEB = 0x00;
