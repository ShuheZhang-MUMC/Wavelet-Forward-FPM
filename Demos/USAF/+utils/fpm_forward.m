function [loss,dldw1,dldw2] = fpm_forward(wavefront1, wavefront2, kc,...
                                                              b_ledpos, ...
                                                              dY_obs, ...
                                                              pratio, ...
                                                              type)

global upsamp

loss = 0;

dldw1 = 0*wavefront1;
dldw2 = 0;

ft_wavefront1 = fftshift(fft2(wavefront1));

for data_con = 1:size(dY_obs,3)
    disp("processing batch ... " + data_con + "/" + size(dY_obs,3))

    kt = kc(1) + b_ledpos(data_con,1);
    kb = kc(2) + b_ledpos(data_con,1);
    kl = kc(3) + b_ledpos(data_con,2);
    kr = kc(4) + b_ledpos(data_con,2);
    
    sub_wavefront1 = ft_wavefront1(kt:kb,kl:kr);

    x = ifft2(ifftshift(sub_wavefront1 .* wavefront2)) / pratio^2;

    if upsamp > 1
        dY_est = sqrt(imresize(abs(x).^2,1/upsamp,'box'));
        [loss_temp,dm] = loss_func.wavelet_loss(dY_est, ...
                                           dY_obs(:,:,data_con), 7, 'db3');
        x = imresize(dm./(dY_est + 1e-5),upsamp,'bicubic') ...
                                  .* x * pratio^2; %
    else
        dY_est = abs(x);
        [loss_temp,dm] = loss_func.wavelet_loss(dY_est, ...
                                           dY_obs(:,:,data_con), 7, 'db3');
        x = dm .* sign(x) * pratio^2; %
    end


    x_record    =   fftshift(fft2(x));
    x           =   deconv_pie(x_record,wavefront2,type);


    dldw1(kt:kb,kl:kr) = dldw1(kt:kb,kl:kr) + x;
    dldw2 = dldw2 + deconv_pie(x_record,sub_wavefront1,type);
    loss = loss + loss_temp;
end

dldw1 = ifft2(ifftshift(dldw1)); 
end

function out = deconv_pie(in,ker,type)
    switch type
        case 'ePIE'
            out = conj(ker) .* in ./ max(max(abs(ker).^2));
        case 'tPIE'
            bias = abs(ker) ./ max(max(abs(ker)));
            fenzi = conj(ker) .* in ;
            fenmu = (abs(ker).^2 + 100);
            out = bias .* fenzi ./ fenmu;
        case 'none'
            out = conj(ker) .* in;
        otherwise 
            error()
    end
end

