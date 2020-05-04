close all
clear
load loopMRI.mat

volrv = zeros(25,1);

% posizione marker iniziale 
marker = zeros(256, 216);
marker(130, 75) = 1;
marker = im2uint16(marker);

figure
for i=1:25
    sli = slice6(:,:,1,i);
            
    im = imreconstruct(marker, sli, 8);
            
    mask_min = imextendedmax(im, 70);
    im = imimposemin(im, not(mask_min));
    
    % rimapping per esaltare ancora di piu' ventricolo
    im = imadjust(im, [0.00070 1], []);
    
    [bin_canny v] = edge(im, 'Canny', [0.02 0.28]);
 
    bin_bridge = bwmorph(bin_canny, 'bridge');
     
    % praticamente per selezionare solo il ventricolo anche se e'
    % collegato ad altro:
    bin_bridge = bwselect(not(bin_bridge), 75, 130, 4);
    
    % faccio closing del ventricolo, per chiudere i buchi e smussare
    se = strel('disk', 6);
    bin_bridge = imclose(bin_bridge, se);
    
    % vado ad estrapolare i boundaries 
    if (i == 1)
        boundaries(1) = bwboundaries(bin_bridge, 'noholes');
    else
        boundaries(i) = bwboundaries(bin_bridge, 'noholes');    
    end
    
    % conto i pixel bianchi per calcolare il volume
    pbianchi = sum(sum(bin_bridge));
    % mm*mm*mm = 0.001ml
    % calcolo volume in mL
    volrv(i) = pbianchi * xres * yres * zres /1000;

  
    subplot(1,2,1);
    imshow(sli,[]);
    hold on
    visboundaries(boundaries(i), 'LineWidth', 0.1, 'color', 'Green')
    title(i);
    ax2 = subplot(1,2,2);
    plot(volrv, '-+g', 'LineWidth',1);
    xlabel('Frame')
    ylabel('Vol [mL]');
    title('Andamento volume RV');
    grid on;
    ylim(ax2, [2 3.5]*10);
    xlim(ax2, [1 25]);
    %xticks(1:1:25);
    %yticks(20:1.5:35);
    
    pause(0.04);
end


%% LEFT VENTRICLE 
% x109 y114s

marker = zeros(256, 216);
marker(114, 109) = 1;
marker = im2uint16(marker);
    
vol_lv = zeros(25,1);
figure
for i=1:25
    sli = slice6(:,:,1,i);
       
    im = imreconstruct(marker, sli, 8);
    
    mask_min = imextendedmax(im, 70);
    im = imimposemin(im, not(mask_min)); 
    
    % anche qua imadjust ma molto piu' "forte"
    im = imadjust(im, [0.001 1], []);
    
    % differenza rispetto right ventricle
    se = strel('disk', 2);
    im = imclose(im, se);

    
    [bin_canny v] = edge(im, 'Canny', [0.02 0.28]);
  
    bin_bridge = bwmorph(bin_canny, 'bridge');
    bin_bridge = bwselect(not(bin_bridge), 109, 114, 4);
 
    se = strel('disk', 6);
    bin_bridge = imclose(bin_bridge, se);
    if (i == 1)
        boundaries_lv(1) = bwboundaries(bin_bridge, 'noholes');
    else
        boundaries_lv(i) = bwboundaries(bin_bridge, 'noholes');    
    end
    
    % conto i pixel bianchi per calcolare il volume
    pbianchi_lv = sum(sum(bin_bridge));
    vol_lv(i) = pbianchi_lv * xres * yres * zres /1000;

    subplot(1,2,1);
    imshow(sli,[]);
    hold on
    visboundaries(boundaries_lv(i), 'LineWidth', 0.1, 'color', 'Cyan')
    title(i);
    ax2 = subplot(1,2,2);
    plot(vol_lv, '-xc', 'LineWidth',1);
    xlabel('Frame')
    ylabel('Vol [mL]');
    grid on;
    title('Andamento volume LV');
    ylim(ax2, [1 3]*10);
    xlim(ax2, [1 25]);
    %xticks(1:1:25)
    %yticks(10:2:30);
    
    pause(0.04);
end

%% sovrapposizione di entrambi, faccio andare 2 volte per poter vedere bene
figure

v = VideoWriter('animate_ventricles.avi', 'MPEG-4');
v.FrameRate = 10;
open(v);

for i=1:25
    tic;
    
    sli = slice6(:,:,1,i);
    subplot(1,2,1);
    imshow(sli,[]);
    hold on
    visboundaries(boundaries_lv(i), 'LineWidth', 0.1, 'color', 'Cyan')
    visboundaries(boundaries(i), 'LineWidth', 0.1, 'color', 'Green')
    hold off;
    title(i);
    
    % codice che serve per non dover ricalcolare i voli, utilizzare i
    % vecchi ma simulare comunque un andamento nel tempo
    ax2 = subplot(1,2,2);
    ylv = [vol_lv(1:i)' zeros(25-i,1)'];
    y = [volrv(1:i)' zeros(25-i,1)'];
    plot([1:1:25], ylv, '-xc', [1:1:25], y, '-+g', 'LineWidth',1);
    
    title('Andamento volumi')

    xlabel('Frame')
    ylabel('Vol [mL]');
    ylim(ax2, [1 3.5]*10);
    %yticks(10:2.5:35);
    xlim(ax2, [1 25]);
    %xticks(1:1:25);
    legend('Ventricolo Sinistro','Ventricolo Destro');
    grid on;

    
     frame = getframe(gcf);
    writeVideo(v,frame);
    pause(1/30 - (tic-toc));
    
end
close(v)

%% fitting delle curve
figure

frv= fit([1:1:25]', volrv, 'smoothingspline', 'SmoothingParam', 0.7);
flv= fit([1:1:25]', vol_lv, 'smoothingspline', 'SmoothingParam', 0.7);
plot([1:1:25], ylv, '-xc', [1:1:25], y, '-+g', 'LineWidth',0.5);
hold on;
plot(frv, 'r');
hold on;
plot(flv, 'k');


ylim([10 35]);
%yticks(10:2.5:35);
xlim([1 25]);
%xticks(1:1:25);
legend('LV', 'RV', 'Interpolazione RV', 'Interpolazione LV');
grid on;

xlabel('Frame')
ylabel('Vol [mL]');
title('Curve adattate');

