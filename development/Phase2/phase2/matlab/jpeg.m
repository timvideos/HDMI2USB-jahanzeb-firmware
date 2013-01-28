clc;
clear;
close all;

fileID = fopen('hw.txt');

A = fscanf(fileID, '%s');
B = uint8(A);

C = B(1:end);% D8 = 216
% 55 663


fclose(fileID);

%%
fileID = fopen('file.jpg','w');
fprintf(fileID,'%s',C);
fclose(fileID);