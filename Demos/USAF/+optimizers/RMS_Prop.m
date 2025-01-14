classdef RMS_Prop < handle
    properties
        name = 'RMS_Prop'
        squave = 0;
        buffer = 0;
        r1 = 0.9;
        mum = 1;

        centered = true;
        g0 = 0;
        lr = 1e-2;
    end
    
    methods
        function obj = RMS_Prop(squave,buffer,beta1,mum,centered,lr)
            obj.squave = squave;
            obj.buffer = buffer;
            obj.r1 = beta1;
  
            obj.mum = mum;
            obj.centered = centered;
            obj.lr = lr;
        end
        
        function para_out = step(obj,para_in,grad)
            obj.squave = obj.r1 + (1 - obj.r1) .* abs(grad).^2;
            if obj.centered
                obj.g0 = obj.r1 .* obj.g0 + (1 - obj.r1) .* grad;
                obj.squave = obj.squave - abs(obj.g0).^2;
            end
        
            if obj.mum > 0
                obj.buffer = obj.mum .* obj.buffer + ...
                                      grad ./ (sqrt(obj.squave) + 1e-5);
                para_out = para_in - obj.lr .* obj.buffer;
            else
                para_out = para_in - obj.lr .* grad ./...
                                                 (sqrt(obj.squave) + 1e-5);
            end
        end
    end
end

