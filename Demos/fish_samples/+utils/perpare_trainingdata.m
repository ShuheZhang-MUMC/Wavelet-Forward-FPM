function [wavefront1,wavefront2,...
                        data_cube,...
                        pratio,Pupil0] = perpare_trainingdata(path,...
                                                             rect,...
                                                             color_index,...
                                                             pix,...
                                                             num_leds,...
                                                             batch_size)

global upsamp
% load loc_pos.mat
imRaw_new = zeros(pix,pix,sum(num_leds,'all'));

% Load data, crop image
for num_of_image = 1:sum(num_leds,'all')
    clc
    disp(num_of_image);
    img = double(imread([path{color_index},'2.000_',num2str(num_of_image),'.tif'],...
        'PixelRegion',{[rect(2),rect(2)+pix-1], ...
                       [rect(1),rect(1)+pix-1]}));

    % clear img_full;
    imRaw_new(:,:,num_of_image) = mean(img,3);
end

close all

imRaw_new = imRaw_new - min(imRaw_new(:));
imRaw_new = imRaw_new / max(imRaw_new(:));
imRaw_new = sqrt(imRaw_new);

rot_ang = 0 / 180 * pi;
[f_pos_set_true,pratio,Pupil0] = init_environment_rgb(color_index,...
                                                      pix, ...
                                                      num_leds,...
                                                      rot_ang);


fpm_cube = combine(arrayDatastore(f_pos_set_true, 'IterationDimension',1),...
                   arrayDatastore(imRaw_new, 'IterationDimension',3));

% (0~225) set mini-batch size a total of 225 images for FPM recon
data_cube = minibatchqueue(fpm_cube,...
            'MiniBatchSize',     batch_size,...
            'MiniBatchFormat',   ["",""],...
            'OutputEnvironment', {'gpu'},...
            'OutputAsDlarray',   false,...
            'OutputCast',        'single');

wavefront1 = gpuArray(single(imresize(imRaw_new(:,:,1),pratio * upsamp))); 
wavefront2 = gpuArray(single(Pupil0));       

end



function [f_pos_set_true,pratio,Pupil0] = init_environment_rgb(color_index, ...
                                                               pix, ...
                                                               led_num, ...
                                                               rot_ang)
global upsamp

lambda  = [0.623,0.532,0.488]; 
% wavelength
D_led   =  9 * 1000;          % LED distance
H_led   = 125 * 1000;          % LED distance to sample

k_lamuda = 2*pi/lambda(color_index); 

pixel_size  = 6.5 / upsamp;               % Camera pixel size
mag         = 4;               % Magnification
NA          = 0.1 ;             % Objective lens numerical aperture
M = pix * upsamp;
N = pix * upsamp;                           % Image size captured by CCD
D_pixel = pixel_size / mag;        % Image plane pixel size
kmax    = NA * k_lamuda;               % Maximum wave number corresponding to the numerical aperture of the objective lens

%Magnification of the reconstructed image compared to the original image
MAGimg = 4;              % ceil(1+2*D_pixel*3*D_led/sqrt((3*D_led)^2+h^2)/lamuda);%Magnification of the reconstructed image compared to the original image
MM  =   M*MAGimg;
NN  =   N*MAGimg;        % Image size after reconstruction
pratio = MAGimg;
led_total = sum(led_num(:));

pix_large = pix * upsamp;
%% spatial frequency
fx_CCD = (-pix_large/2:pix_large/2-1)/(pix_large * D_pixel);
df = fx_CCD(2)-fx_CCD(1);
[fx_CCD,fy_CCD] = meshgrid(fx_CCD);
CTF_CCD = (fx_CCD.^2+fy_CCD.^2)<(NA/lambda(color_index)).^2;
Pupil0 = CTF_CCD;

Rcam = lambda(color_index) / NA*mag / 2 /pixel_size;
RLED = NA*sqrt(D_led^2+H_led^2)/D_led;
Roverlap = 1/pi*(2*acos(1/2/RLED)-1/RLED*sqrt(1-(1/2/RLED)^2));

disp(['the overlapping rate is ',num2str(Rcam)]);
disp(['the overlapping rate is ',num2str(Roverlap)]);
plane_wave_org = zeros(led_total,2); %initial non-shifted plane wave

%% plane wave direction
count = 0;
for ring = 1:length(led_num)
    phi = linspace(0,2*pi,led_num(ring)+1) + rot_ang;
    for con = 1:led_num(ring)
        count = count + 1;
        r = D_led * (ring - 1);
        v = [0,0,H_led]-[r .* cos(phi(con)),r .* sin(phi(con)),0];
        v = v/norm(v);
        plane_wave_org(count,1) = v(2);
        plane_wave_org(count,2) = v(1);  
    end
end

f_pos_set_true = zeros(led_total,4);
for con = 1:led_total
    fxc = round((MM+1)/2 + (plane_wave_org(con,1)/lambda(color_index))/df);
    fyc = round((MM+1)/2 + (plane_wave_org(con,2)/lambda(color_index))/df);
    
    fxl = round(fxc-(pix_large-1)/2);fxh=round(fxc+(pix_large-1)/2);
    fyl = round(fyc-(pix_large-1)/2);fyh=round(fyc+(pix_large-1)/2);
    f_pos_set_true(con,:) = [fxl,fxh,fyl,fyh];
end

end