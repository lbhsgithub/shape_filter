%% 形状函数在最后
%% file open
addpath('./other_file')
[fname,path] = uigetfile({'*.jpg';'*.png'}); 
p0 = imread([path,fname]);
p0 = imcrop(p0);
if numel(size(p0))==3
    p0 = rgb2gray(p0);
end
%% 
p = p0;
GUI(p,fname);
function GUI(p,fname)  % name的问题之后再说
    MainFigure=figure('Name','crack tool','NumberTitle','off'); %why error happens when put imshow(p) before slider??      [left bottom width heigh]
    edit_binary=uicontrol('style','edit','parent',MainFigure,'unit','normalized','position',[0.15 0.1 0.1 0.03],'string','0~1','callback',{@edit_binary_callback,p});
    slider_binary=uicontrol('style','slider','parent',MainFigure,'unit','normalized','position',[0.3 0.1 0.4 0.03],'callback',{@slider_binary_callback,p});
    %% use shape_filter to eliminate
    edit_S = uicontrol('style','edit','parent',MainFigure,'unit','normalized','position',[0.15 0.05 0.08 0.03],'string','10');
    edit_k1 = uicontrol('style','edit','parent',MainFigure,'unit','normalized','position',[0.25 0.05 0.08 0.03],'string','5');
    uicontrol('style','text','parent',MainFigure,'unit','normalized','position',[0.25 0.02 0.08 0.03],'string','△Y-△X<');
    uicontrol('style','pushbutton','parent',MainFigure,'unit','normalized','position',[0.5 0.04 0.08 0.05],'string','eliminate','callback',{@eliminate_by_shape_filter,p,1});
    uicontrol('style','pushbutton','parent',MainFigure,'unit','normalized','position',[0.6 0.04 0.08 0.05],'string','isolate','callback',{@eliminate_by_shape_filter,p,0});
    %% output
    uicontrol('style','pushbutton','parent',MainFigure,'unit','normalized','position',[0.72 0.04 0.2 0.05],'string','export current image','callback',{@output,p,fname});
    imshow(p);
    %% save
    %uicontrol('style','pushbutton','parent',MainFigure,'unit','normalized','position',[0.72 0.1 0.15 0.05],'string','save current image','callback',{@output,p,fname});
    %imshow(p);
    %% 
    function slider_binary_callback(hObject,~,p)
        k_slider=get(hObject,'value');
        set(edit_binary,'string',num2str(k_slider));
        p=imbinarize(p,get(hObject,'value'));
        imshow(p);
    end
    %%
    function edit_binary_callback(hObject,~,p)
        k_edit=get(hObject,'string');
        set(slider_binary,'value',str2double(k_edit));
        p=imbinarize(p,str2double(k_edit));
        imshow(p);
    end
    %%
    function output(~,~,p,fname)
        k=get(slider_binary,'value');
        p = imbinarize(p,k);
        path = uigetdir();
        imwrite(p,[path,'\2ize-',num2str(k),'-',fname]);
    end
    %% 
    function eliminate_by_shape_filter(~,~,p0,symbol)
        % 重做二值化
        p = imbinarize(p0,get(slider_binary,'value'));
        % 获得figure中的值
        S = str2double(get(edit_S,'string'));
        k1 = str2double(get(edit_k1,'string'));
        parameters = [S,k1];
        %
        markedCCs = markCCs(~p,parameters);
        if symbol
            %eliminate
            for markedCC = markedCCs   % 分段做，避免数据太多溢出
                p(markedCC{1}) = 1;
            end
        else
             %isolate
            p = true(size(p));
            for markedCC = markedCCs   % 分段做，避免数据太多溢出
                p(markedCC{1}) = 0;
            end
        end
        imshow(p);
    end
end

function markedCCs = markCCs(p,parameters)
    sizeofimage = size(p);
    CC = bwconncomp(p);
    markedCCs = {};  % previously unknown 
    % one CC
    for CCi = CC.PixelIdxList
        % index to subscript 
        amount = length(CCi{1});
        subs = zeros(amount,2);
        indexs = CCi{1};
        for i = 1:amount
            [subs(i,1),subs(i,2)] = ind2sub(sizeofimage,indexs(i));
        end
        % filter
        if shape_filter(subs,parameters)
            markedCCs{end+1} = indexs;
        end
    end 
end

% 所有的工作都在这个函数的逻辑判断上
function T_F = shape_filter(subs,parameters_threshold) 
    % 由斜条或者斜半圆想到，面积不饱满。pi*△x*△y与面积相比
    % 计算要用的参数
    S = size(subs,1);
    x_ = subs(:,2);
    y_ = subs(:,1);
    deltaX = max(x_)-min(x_);
    deltaY = max(y_)-min(y_);
    Y_X = deltaY - deltaX;
    % parallel conditions
    T_F = false;
    if (S<parameters_threshold(1))
        T_F = true;
    end
    if (Y_X<parameters_threshold(2))
        T_F = true;
    end
end
