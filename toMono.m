function songMono = toMono(song)

sizeSong = size(song);
if sizeSong(2) > 1
    songMono = (song(:,1)+song(:,2))/2;
    songMonoMax = max(abs(songMono));
    songMono = songMono ./ songMonoMax;
else
    songMono = song;
    songMonoMax = max(abs(songMono));
    songMono = songMono ./ songMonoMax;
end