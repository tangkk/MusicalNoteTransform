function notepaths = readpath(varargin)

len = nargin - 1;
noteroot = varargin(1);
display(noteroot);
notepaths = 0;

for i = 2:1:len
    notepaths = [notepaths [noteroot '\' varargin(i) ':']];
end
display(notepaths);