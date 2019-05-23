%% shape_filter is in the tail
%% file open
[address{2},address{1}] = uigetfile({'*.jpg';'*.png'}); 
p = imread([address{1},address{2}]);
p = imcrop(p);
%p = imrotate(p,90);
%% 
if numel(size(p))==3
    p = rgb2gray(p);
end
%%
GUI(p,address)
function GUI(p,address)
    %%
    % 目标：希望得到callback函数的返回值，否侧输出会有问题
        % 官方帮助文档：guidata(object_handle,data),如果object_handle不是图窗，则使用该对象的父图窗。
        % 建立handles与父图窗的关联? handles = guihandles(MainFigure); ——好像不是这个意思
        % 不会用guidata，先用global代替了
    %% ParentFigure
    MainFigure = figure('Name','crack tool','NumberTitle','off'); % why error happens when put imshow(p) before slider?
    %% initialize
    global handles % 以后还可以设置一个fix以实现连续操作
    handles.raw_image = p;
    handles.binarized_image = p;
    handles.current_image = p;
    handles.address = address;
    %% binarize combination
    %'position',[left bottom width heigh]
    % 一定要有外层GUI函数这里的edit_binary才会成为全局变量？
    edit_binary = uicontrol('parent',MainFigure,'unit','normalized',...
                            'style','edit',...
                            'position',[0.15 0.1 0.1 0.03],...
                            'callback',{@binary_callback});
    slider_binary = uicontrol('parent',MainFigure,'unit','normalized',...
                            'style','slider',...
                            'position',[0.3 0.1 0.4 0.03],...
                            'callback',{@binary_callback});
    %% use shape_filter to eliminate
    edit_S = uicontrol('parent',MainFigure,'unit','normalized',...
                            'style','edit',...
                            'position',[0.15 0.05 0.08 0.03],'string','10');
    edit_k1 = uicontrol('parent',MainFigure,'unit','normalized',...
                            'style','edit',...
                            'position',[0.25 0.05 0.08 0.03],'string','5');
    uicontrol('parent',MainFigure,'unit','normalized',...
                            'style','text',...
                            'position',[0.25 0.02 0.08 0.03],'string','△Y-△X<');
    uicontrol('parent',MainFigure,'unit','normalized',...
                            'style','pushbutton',...
                            'position',[0.5 0.04 0.08 0.05],'string','eliminate',...
                            'callback',{@eliminate_by_shape_filter});
    uicontrol('parent',MainFigure,'unit','normalized',...
                            'style','pushbutton',...
                            'position',[0.6 0.04 0.08 0.05],'string','isolate',...
                            'callback',{@eliminate_by_shape_filter});
    %% output
    uicontrol('parent',MainFigure,'unit','normalized',...
                            'style','pushbutton',...
                            'position',[0.72 0.04 0.2 0.05],'string','export current image',...
                            'callback',{@output});
    %% end
    imshow(p);
    %% callback
    %% binarize 在raw_image的基础上操作
    function binary_callback(hObject,~)
        p_local = handles.raw_image; 
        k = get(hObject,'value');
        if k
            set(edit_binary,'string',num2str(k));
        else
            k = get(hObject,'string');
            k = str2double(k);
            set(slider_binary,'value',k);
        end
        p_local = imbinarize(p_local,k);
        imshow(p_local);
        % save
        handles.binarized_image = p_local;
        handles.current_image = p_local;
    end
    %%
    function output(~,~)
%     test(handles.binarized_image,handles.current_image);
%     function test(p1,p2)
%     subplot(1,2,1);
%     imshow(p1);
%     subplot(1,2,2);
%     imshow(p2); 
%     end
        k = get(edit_binary,'string');
        output_name = [handles.address{1},'2ize-',k,'-',handles.address{2}];
        imwrite(handles.current_image,output_name);
    end
    %% 
    function eliminate_by_shape_filter(hObject,~) %"handles" 的 GLOBAL 或 PERSISTENT 声明显示在嵌套函数中，但应出现在使用它的最外面的函数中。
        %p_local = handles.raw_image;
        %p_local = imbinarize(p_local,get(slider_binary,'value'));
        p_local = handles.binarized_image;
        % 获得figure中的值
        S = str2double(get(edit_S,'string'));
        k1 = str2double(get(edit_k1,'string'));
        parameters = [S,k1];
        %
        markedCCs = markCCs(~p_local,parameters);
        if get(hObject,'string') == "eliminate"
            %eliminate
            for markedCC = markedCCs   % 分段做，避免数据太多溢出
                p_local(markedCC{1}) = 1;
            end
        else
             %isolate
            p_local = true(size(p_local));
            for markedCC = markedCCs   % 分段做，避免数据太多溢出
                p_local(markedCC{1}) = 0;
            end
        end
        imshow(p_local);
        % save
        handles.current_image = p_local;
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

%% core
function T_F = shape_filter(subs,parameters_threshold) 
    % basic
    S = size(subs,1);
    x_ = subs(:,2);
    y_ = subs(:,1);
    deltaX = max(x_)-min(x_);
    deltaY = max(y_)-min(y_);
    % parameters
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
