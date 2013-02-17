//////////////////////////////////////////////////////////////////////////////
/// Copyright (c) 2013, Jahanzeb Ahmad
/// All rights reserved.
///
/// Redistribution and use in source and binary forms, with or without modification, 
/// are permitted provided that the following conditions are met:
///
///  * Redistributions of source code must retain the above copyright notice, 
///    this list of conditions and the following disclaimer.
///  * Redistributions in binary form must reproduce the above copyright notice, 
///    this list of conditions and the following disclaimer in the documentation and/or 
///    other materials provided with the distribution.
///
///    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
///    EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
///    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
///    SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
///    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
///    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
///    PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
///    WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
///    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
///   POSSIBILITY OF SUCH DAMAGE.
///
///
///  * http://opensource.org/licenses/MIT
///  * http://copyfree.org/licenses/mit/license.txt
///
//////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <stdlib.h>
 
int main(void)
{
    int buffer,bufferFF;  
    int i=0, rc1, rc2, rc,j=0;
    FILE *fp1 = fopen("new.txt", "r"); // orignal
    FILE *fp2 = fopen("hw.txt", "r");
    FILE *fp3 = fopen("diff.txt", "w");

 
    if ((fp1 == NULL)||(fp2 == NULL)||(fp3 == NULL)) {
        perror("Failed to open file \"myfile\"");
        return 1;
    }
	 while(bufferFF!=255 || buffer!=217)
	{	
		if (i%17 == 0)		
		{
			// fscanf(fp1,"%04x",&rc);
			fscanf(fp2,"%04x",&rc);			
		}
		else
		{	
					
			fscanf(fp1,"%02x",&rc1);
			fscanf(fp2,"%02x",&rc2);
			if (rc1 == rc2) 
			{	
				fprintf(fp3,"%04d %02x %02x\n",j,rc1,rc2);
			}
			else
			{
				fprintf(fp3,"%04d %02x %02x --error\n",j,rc1,rc2);
			}
			j = j+1;

			bufferFF = buffer;
			buffer = rc1;						
		}
		
		i=i+1;
	}
	
    
	fclose(fp1);
    fclose(fp2);
    fclose(fp3);
}