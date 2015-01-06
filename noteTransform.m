% function noteTransform(note, song)
song = 'basssong.wav';
note = 'bass-D2.wav';
root = 'd:\Documents\REAPER Media';

songpath = [root '\' song];
notepath = [root '\' note];

[song,fssong] = audioread(songpath);
song = toMono(song);
% [song, fssong] = myDownsample(song, 10, fs);

[note,fsnote] = audioread(notepath);
note = toMono(note);
% note = note(length(note)/8:length(note)/4);
% noteplayer = audioplayer(note, fsnote);
% play(noteplayer);

corrstep = 200;
xcorrout = myXCorr(song,note, corrstep);
xcorrout = normalize(xcorrout);

close all;
figure;
plot(xcorrout);
hold;
plot(song);
% hold;
% plot(note);
