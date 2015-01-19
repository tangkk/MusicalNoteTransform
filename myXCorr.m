% this implement a cross-correlation function that cross correlates inLong
% and in Short with a correlation step of "corrstep"
function out = myXCorr(inLong, inShort, corrstep, corrlen)

lenLong = length(inLong);
lenShort = length(inShort);
out = zeros(1,corrlen);

outidx = 1;
for i = 1:corrstep:lenLong
    display([i lenShort lenLong]);
    sum = 0;
    % do multiplication in the kernel
    for j = 1:1:lenShort
        longidx = i+j-1;
        shortidx = j;
        if longidx <= lenLong
            sum = sum + inLong(longidx)*inShort(shortidx);
        end
    end
    out(outidx) = sum;
    outidx = outidx + 1;
end

if length(out) > corrlen
    out = out(1:corrlen);
end