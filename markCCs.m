function markedCCs = markCCs(p,thresholds)
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
        if shape_filter(subs,thresholds)
            markedCCs{end+1} = indexs;
        end
    end 
end