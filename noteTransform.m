audioroot = '..\AudioSamples';
noteroot = '..\NoteSamples';
instrumentroot = '\bass';
DSR = 4;

audio = 'putongpengyou-2.mp3';
audiopath = [audioroot '\' audio];
[input, fssong] = audioread(audiopath);
input = (input(:,1) + input(:,2))/2;
[input, fssong] = myDownsample(input, DSR, fssong);
inputMax = max(abs(input));
input = input ./ inputMax;

notenames = {'E1','F1','F#1','G1','G#1','A1','A#1','B1',...
    'C2','C#2','D2','D#2','E2','F2','F#2','G2','G#2','A2','A#2','B2',...
    'C3'};

% notenames = {'C2','C#2','D2','D#2','E2','F2','F#2','G2','G#2','A2','A#2','B2',...
%     'C3'};

% notenames = {'A1','A#1','B1',...
%     'C2','C#2','D2','D#2','E2','F2','F#2','G2','G#2','A2','A#2','B2',...
%     'C3'};

% notenames = {'C1','C#1','D1','D#1','E1','F1','F#1','G1','G#1','A1','A#1','B1',...
%     'C2','C#2','D2','D#2','E2','F2','F#2','G2','G#2','A2','A#2','B2',...
%     'C3'};

% compute the bass compensation value
firstnote = notenames(1);
firstnote = char(firstnote);
firstnote(end) = [];
switch firstnote
    case 'C'
        basscomp = 0;
    case 'C#'
        basscomp = 1;
    case 'D'
        basscomp = 2;
    case 'D#'
        basscomp = 3;
    case 'E'
        basscomp = 4;
    case 'F'
        basscomp = 5;
    case 'F#'
        basscomp = 6;
    case 'G'
        basscomp = 7;
    case 'G#'
        basscomp = 8;
    case 'A'
        basscomp = 9;
    case 'A#'
        basscomp = 10;
    case 'B'
        basscomp = 11;
end

N = 100;
len = length(notenames);
corrstep = 100;
corrlen = floor(length(input)/corrstep);
corrout = zeros(len, corrlen);
for i = 1:1:len
    fullnotename = strcat(notenames(i),'.wav');
    fullnotename = char(fullnotename);
    notepath = strcat(noteroot, instrumentroot, '\', fullnotename);
    [note,fsnote] = audioread(notepath);
    note = (note(:,1) + note(:,2))/2;
    [note, fsnote] = myDownsample(note, DSR, fsnote);
    noteMax = max(abs(note));
    note = note ./ noteMax;
    corrouttemp = myXCorr2(input,note);
    corrouttemp = corrouttemp';
    corrouttemp = downsample(corrouttemp,corrstep);
    if length(corrouttemp) > corrlen
        corrouttemp = corrouttemp(1:corrlen);
    end
    corrout(i,:) = ordfilt2(corrouttemp, N, ones(1,N));
end

% release memory
clearvars input corrouttemp note;

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
set(gca, 'YTick',1:length(notenames), 'YTickLabel', notenames);

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
    
    if mod(currentbass+basscomp,12) ~= mod(previousbass+basscomp,12)
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
harmonicChangeTempo = 60 / median(durationlog);
fclose(f);
