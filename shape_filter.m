% need to define
function T_F = shape_filter(subs,thresholds) 
    S = size(subs,1);
    x_ = subs(:,2);
    y_ = subs(:,1);
    deltaX = max(x_)-min(x_);
    deltaY = max(y_)-min(y_);
    Y_X = deltaY - deltaX;
    % parallel conditions
    T_F = false;
    if (S<thresholds(1))
        T_F = true;
    end
    if (Y_X<thresholds(2))
        T_F = true;
    end
end