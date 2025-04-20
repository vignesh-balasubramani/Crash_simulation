function Shell=shell_list(fid)
% function that recieves the line id and outputs the shell thickness of the
% current part
% fid - current line in the file
a=fgetl(fid);
A=cell2mat(textscan(fid,'%f',1));
b=fgetl(fid);
c=fgetl(fid);
B=cell2mat(textscan(fid,'%f',1));
Shell=[A,B];
end