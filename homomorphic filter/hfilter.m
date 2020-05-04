function [ img_filtrata ] = hfilter(immagine, N, D0, min_, max_)
    % Michele Marazzi, 873616
    n = size(immagine, 1)*2 + 1;
    m = size(immagine, 2)*2 + 1;
    
    logimg = log(im2double(immagine)+1);
    img_spettro = fft2(logimg, n, m);
    img_spettro = fftshift(img_spettro);
   
    [f1,f2] = freqspace([n m],'meshgrid');
    Hd = ones(n, m);
    r = sqrt(f1.^2 + f2.^2);
    
    D0 = D0*ones(n, m);
    Hd = min_ + (max_ - min_)*ones(n,m) ./ (1+ (D0./r).^(2*N));
    %figure, mesh(Hd);

    img_spettro = img_spettro .* Hd;
    img_spettro = ifftshift(img_spettro);
    img_filtrata = real(ifft2(img_spettro));
    img_filtrata = img_filtrata(1:size(immagine,1),1:size(immagine,2));
    img_filtrata = im2uint8((exp(img_filtrata))-1);
    
end
    