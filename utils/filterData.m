function [data] = filterData(data,fnames,removeFlip)
%FILTERDATA  Takes as input data and fnames (filenames of data points to
% retain). Removes everything else. Optionally, removes flipped bboxes as
% well.

data = data(ismember({data(:).voc_image_id},fnames));
if(nargin > 2 && removeFlip)
    data = data(~[data(:).flip]);
end

end