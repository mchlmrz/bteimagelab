% Michele Marazzi, 873616

close all
clear

[nfile, pathf] = uigetfile('*.*', 'Seleziona il video'); 
obj_video = VideoReader([pathf nfile]); 
%obj_video = VideoReader('IMG_2033.MOV.mov');


% Lavoriamo su un frame per volta
% Leggo il primo frame e lo mostro per scegliere la ROI
s_frame = readFrame(obj_video);

% rect predefinita per poter fare test confrontabili
rect = [1.240510000000000e+03 18.510000000000000 6.519800000000000e+02 2.369800000000000e+02];
%[J rect] = imcrop(s_frame);
J = imcrop(s_frame, rect);

pixle_bw = size(J,1)*size(J,2);

% impostazioni filtro 
ord = 2;
f0 = 0.5;
max_  = 1;
min_ = 0.2;

rgbFrame(:, :, 1) = hfilter(J(:, :, 1),ord, f0, min_, max_);
rgbFrame(:, :, 2) = hfilter(J(:, :, 2),ord, f0, min_, max_);
rgbFrame(:, :, 3) = hfilter(J(:, :, 3),ord, f0, min_, max_);

s_frame_hsv = rgb2hsv(rgbFrame);

close

figure, imshow(rgbFrame);

h = waitbar(0, 'Attendere..');

avg_r(1) = sum(sum(rgbFrame(:,:,1)))/pixle_bw;
avg_g(1) = sum(sum(rgbFrame(:,:,2)))/pixle_bw;
avg_b(1) = sum(sum(rgbFrame(:,:,3)))/pixle_bw;

avg_h(1) = sum(sum(s_frame_hsv(:,:,1)))/pixle_bw;
avg_s(1) = sum(sum(s_frame_hsv(:,:,2)))/pixle_bw;
avg_v(1) = sum(sum(s_frame_hsv(:,:,3)))/pixle_bw;

i = 2;
while (hasFrame(obj_video))
    waitbar(obj_video.CurrentTime/obj_video.Duration);
        
    s_frame = imcrop(readFrame(obj_video), rect);
    
    rgbFrame(:, :, 1) = hfilter(s_frame(:, :, 1),ord, f0, min_, max_);
    rgbFrame(:, :, 2) = hfilter(s_frame(:, :, 2),ord, f0, min_, max_);
    rgbFrame(:, :, 3) = hfilter(s_frame(:, :, 3),ord, f0, min_, max_);
    
    s_frame_hsv = rgb2hsv(rgbFrame);

    avg_r(i) = sum(sum(rgbFrame(:,:,1)))/pixle_bw;
    avg_g(i) = sum(sum(rgbFrame(:,:,2)))/pixle_bw;
    avg_b(i) = sum(sum(rgbFrame(:,:,3)))/pixle_bw;

    avg_h(i) = sum(sum(s_frame_hsv(:,:,1)))/pixle_bw;
    avg_s(i) = sum(sum(s_frame_hsv(:,:,2)))/pixle_bw;
    avg_v(i) = sum(sum(s_frame_hsv(:,:,3)))/pixle_bw;

    
    i = i+1;
end
close all;
close(h);


bmp =figure
subplot(2,3,1), plot(avg_r);
title('R');
ylabel('valore');
xlabel('frame');
subplot(2,3,2), plot(avg_g);
title('G');
ylabel('valore');
xlabel('frame');
subplot(2,3,3), plot(avg_b);
title('B');
ylabel('valore');
xlabel('frame');

subplot(2,3,4), plot(avg_h);
title('H');
ylabel('valore');
xlabel('frame');
subplot(2,3,5), plot(avg_s);
title('S');
ylabel('valore');
xlabel('frame');
subplot(2,3,6), plot(avg_v);
title('V');
ylabel('valore');
xlabel('frame');

% % salvataggio immagine automatica
%  filen = sprintf( './esoptz/rect/N%d f%g max%g min%g.bmp ', ....
%      ord, f0, max_, min_);
% 
% 
% saveas(bmp, filen, 'bmp');


