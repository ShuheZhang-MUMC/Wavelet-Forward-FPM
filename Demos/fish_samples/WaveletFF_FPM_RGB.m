%{
    FPM reconstruction using ELFPIE engine
    [Paper]: https://www.sciencedirect.com/science/article/pii/S0165168423001627
    [Codes]: https://github.com/ShuheZhang-MUMC/elfpie_algorithm/
    
    The loss function is replaced to Wavelet forward loss (2024 Sept)
    Wavelet forward family
    [Paper]: https://onlinelibrary.wiley.com/doi/epdf/10.1002/lpor.202401183

    If you use this code for your research and find it help, please cite
    our papers. Thank you very much!
%}


clear
clc

led_num = [1,8,12,16,24,32];


path = {'samples/20240917100mm-29-R\0\0\',...
        'samples/20240917100mm-29-G\0\0\',...
        'samples/20240917100mm-29-B\0\0\'};

for color_index = 2

figure;
[temp,rect] = imcrop((imread([path{color_index},'2.000_1.tif'])));
if rem(size(temp,1),2) == 1
    rect(4) = rect(4) - 1;
end
if rem(size(temp,2),2) == 1
    rect(3) = rect(3) - 1;
end
pix = fix((rect(4) + rect(3))/2);
pix = pix + mod(pix,2);
rect = fix(rect);
save("loc_pos.mat","pix","rect")



%% preparing reconstruction data for ELFPIE engine
global upsamp
upsamp = 1;
batch_size = 16;

[wavefront1,...
 wavefront2,...
 fpm_cube,pratio,Pupil0] = utils.perpare_trainingdata(path,...
                                                    rect,...
                                                    color_index,...
                                                    pix,...
                                                    led_num,...
                                                    batch_size);


lr = 0.007;

optimizer_w1 = optimizers.RMS_Prop(0,0,0.999,0,false,lr);
optimizer_w2 = optimizers.RMS_Prop(0,0,0.999,0,false,lr);

% optimizer_w1 = optimizers.YoGi(0,0,0.9,0.999,lr);
% optimizer_w2 = optimizers.YoGi(0,0,0.9,0.999,lr);

epoch = 0;
iteration = 0;
decon_type = 'none';

numEpochs = 20;

[~,raw_img] = fpm_cube.next();
raw_img = raw_img(:,:,1);



while epoch < numEpochs
    epoch = epoch + 1;
    fpm_cube.reset();

    all_images = sum(led_num,'all');

    while fpm_cube.hasdata()
        all_images = max(all_images - batch_size,0);
        clc
        disp("processing bacth, image remains ... " + all_images + "/" + sum(led_num,'all'));

        iteration = iteration + 1;
        [leds,dY_obs] = fpm_cube.next();
        
        % forward propagation, gain gradient
        [loss,dldw1,dldw2] = utils.fpm_forward(wavefront1, wavefront2 ,...
                                                     leds, ...
                                                     dY_obs, ...
                                                     pratio, ...
                                                     decon_type);

        % learning the parameters
        wavefront1 = optimizer_w1.step(wavefront1,dldw1);
        wavefront2 = optimizer_w2.step(wavefront2,dldw2);

        % refine pupil function
        wavefront2 = wavefront2 .* Pupil0;
        wavefront2 = min(max(abs(wavefront2),0.8),1.2) .* sign(wavefront2);
    end

    if epoch > 10
        optimizer_w1.lr = optimizer_w1.lr * 0.6;
        optimizer_w2.lr = optimizer_w2.lr * 0.6;
    end

    disp(epoch)

    % Result visualization
    if mod(epoch,1) == 0
        o = wavefront1;

        % F = fftshift(fft2(wavefront1));
        % img_spe = log(abs(F)+1);mm = max(max(log(abs(F)+1)))/2;
        % img_spe(img_spe>mm) = mm;
        % img_spe(img_spe<0) = 0;
        % img_spe = mat2gray(img_spe);

        figure(5);
        imshow([abs(o),imresize(raw_img,size(o),'box')],[]);  
        drawnow;
    end
end

end



function [dldw] = tv_reg(w)

dx = @(x) [x(:,2:end) - x(:,1:end-1),x(:,1) - x(:,end)];
dy = @(x) [x(2:end,:) - x(1:end-1,:);x(1,:) - x(end,:)];

dxT = @(x) [x(:,end) - x(:,1),x(:,1:end-1) - x(:,2:end)];
dyT = @(x) [x(end,:) - x(1,:);x(1:end-1,:) - x(2:end,:)];

dldw = dxT(sign(dx(w))) + dyT(sign(dy(w)));
end