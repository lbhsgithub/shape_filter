### shape_filter
```
% p-code
def marked connected component as markedCC
def connected_component as CC
function markedCCs = markCCs(image,thresholds)
    for every CC in image
        markedCCs = markedCCs + shape_filter(every CC,thresholds)
    end
    function return = shape_filter(every CC,thresholds)
        if shape/area... of CC satisfy thresholds(combination)
            return =  every CC or []
        end
    end
end
```
**shape/area... of CC satisfy thresholds(combination)** is the only part need to define  
#### base on this frame:
##### 1 crack_tool (use figure handle as input of image and thresholds)
![1 GUI](https://github.com/lbhsgithub/shape_filter/blob/master/archived/images/1_GUI.png)  
![1 GUI processed](https://github.com/lbhsgithub/shape_filter/blob/master/archived/images/2_GUI_processed.png)
##### 2 profile
![3 repair](https://github.com/lbhsgithub/shape_filter/blob/master/archived/images/3_repair.png)  