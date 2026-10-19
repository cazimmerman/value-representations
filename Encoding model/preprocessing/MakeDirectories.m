function MakeDirectories(path,probe)

input_dir = path;
output_dir = ['Z:\Chris\data\ibl_da_neuropixels\',input_dir(9:end)];
if ~exist(output_dir,'dir')
    mkdir(output_dir)
end
output_dir = ['Z:\Chris\data\ibl_da_neuropixels\Data\null_sessions\'];
if ~exist(output_dir,'dir')
    mkdir(output_dir)
end

for i = 1:length(probe)
    input_dir = [path,probe{i}];
    output_dir = ['Z:\Chris\data\ibl_da_neuropixels\',input_dir(9:end)];
    if ~exist(output_dir,'dir')
        mkdir(output_dir)
    end
end