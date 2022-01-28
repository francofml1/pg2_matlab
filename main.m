recObj = audiorecorder(44100,16,1)

%%
disp('Start speaking.')
recordblocking(recObj, 5);
disp('End of Recording.');

%%
play(recObj);

%%
close all
y = getaudiodata(recObj);
t = linspace(0, 5, length(y));
plot(t,y);
grid on;