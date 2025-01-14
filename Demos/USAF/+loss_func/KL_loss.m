function [loss,dldx] = KL_loss(x,y)

    small_v = 1e-3;

    loss = x - y.*log(x + small_v);
    dldx = 1 - y./(x + small_v);
    
    loss = sum(loss,'all');
    
end