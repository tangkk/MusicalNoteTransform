audioroot = '..\AudioSamples';
noteroot = '..\NoteSamples';
DSR = 4;

audio = 'putongpengyou.mp3';
audiopath = [audioroot '\' audio];
[input, fssong] = audioread(audiopath);
input = toMono(input);
[input, fssong] = myDownsample(input, DSR, fssong);

% notenames = {'E1','F1','F#1','G1','G#1','A1','A#1','B1',...
%     'C2','C#2','D2','D#2','E2','F2','F#2','G2','G#2','A2','A#2','B2',...
%     'C3'};

notenames = {'C2','C#2','D2','D#2','E2','F2','F#2','G2','G#2','A2','A#2','B2',...
    'C3'};

% notenames = {'A1','A#1','B1',...
%     'C2','C#2','D2','D#2','E2','F2','F#2','G2','G#2','A2','A#2','B2',...
%     'C3'};

basscomp = -1;

N = 100;
len = length(notenames);
corrstep = 100;
corrlen = floor(length(input)/corrstep);
corrout = zeros(len, corrlen);
for i = 1:1:len
    fullnotename = strcat('bass','-',notenames(i),'.wav');
    fullnotename = char(fullnotename);
    notepath = strcat(noteroot, '\', fullnotename);
    [note,fsnote] = audioread(notepath);
    note = toMono(note);
    [note, fsnote] = myDownsample(note, DSR, fsnote);
%     corrouttemp = myXCorr(input,note,corrstep,corrlen);
    corrouttemp = myXCorr2(input,note);
    corrouttemp = corrouttemp';
    corrouttemp = downsample(corrouttemp,corrstep);
    if length(corrouttemp) > corrlen
        corrouttemp = corrouttemp(1:corrlen);
    end
    corrout(i,:) = ordfilt2(corrouttemp, N, ones(1,N));
end

close all;
x = ((1:corrlen)/fssong)*corrstep;
figure;
hold on;
for i = 1:1:len
    plot(x, corrout(i,:));
end

% bass transcription output
transout = zeros(1, corrlen);
for i = 1:1:corrlen
    [val, idx] = max(corrout(:,i));
    transout(i) = idx;
end

% post-processing the transout
% with less than a certain length of period, change it to the previous note
B = N;
filteredtransout = zeros(1,corrlen);
for i = 1:1:corrlen
    buf = transout(max(i-B,1):min(i+B,corrlen));
    filteredtransout(i) = mode(buf);
end

figure;
xx = ((1:corrlen)/fssong)*corrstep;
plot(xx, filteredtransout);
set(gca, 'YTick',1:21, 'YTickLabel', notenames);

durationlog = [];
previousbass = filteredtransout(1);
previoustime = 0;
f = fopen([audio '.log'], 'w');
basslog = [num2notename(mod(previousbass+basscomp,12)) ' ' '0' ' '];
fprintf(f, '%s',basslog);
for i = 2:1:corrlen
    currentbass = filteredtransout(i);
    if i == corrlen
        currenttime = xx(i);
        durationlog = [durationlog currenttime-previoustime];
        previoustime = currenttime;
        basslog = [num2str(floor(currenttime/60)) '.' num2str(mod(currenttime,60))];
        fprintf(f, '%s',basslog);
    end
    
    if num2notename(mod(currentbass+basscomp,12)) ~= num2notename(mod(previousbass+basscomp,12))
        currenttime = xx(i);
        durationlog = [durationlog currenttime-previoustime];
        previoustime = currenttime;
        basslog = [num2str(floor(currenttime/60)) '.' num2str(mod(currenttime,60))];
        fprintf(f, '%s\r\n',basslog);
        basslog = [num2notename(mod(currentbass+basscomp, 12)) ' ' [num2str(floor(currenttime/60)) '.' num2str(mod(currenttime,60))] ' '];
        fprintf(f, '%s',basslog);
    end
    previousbass = currentbass;
end

fclose(f);
