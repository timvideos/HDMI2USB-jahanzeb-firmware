filename='smpte';
filenamet=strcat(filename,'.txt');

I = imread(filename,'jpg');


fid = fopen(filenamet,'w+');

for y = 1:768
   for x = 1:1024
       fprintf(fid,'%2x%2x%2x\n',I(y,x,1),I(y,x,2),I(y,x,3));
       
   end;    
   disp(y)
end;
fclose(fid);
