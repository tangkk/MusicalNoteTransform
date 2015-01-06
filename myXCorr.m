function out = myXCorr(inLong, inShort, corrstep)

lenLong = length(inLong);
lenShort = length(inShort);
out = zeros(1,lenLong);
for i = 1:corrstep:lenLong
    display([i lenShort lenLong]);
    sum = 0;
    % do multiplication in the kernel
    for j = 1:1:lenShort
        longidx = i+j-1;
        shortidx = j;
        if longidx <= lenLong
            sum = sum + inLong(i+j-1)*inShort(shortidx);
        end
    end
    out(i) = sum;
end