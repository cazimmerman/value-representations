%% input paths
addpath(genpath('/jukebox/witten/Chris/matlab/cz/ibl_da_neuropixels_2022/utils/'));
cz_path = '/jukebox/witten/Chris/data/ibl_da_neuropixels/Data/Subjects/';
input_paths = cell(0,0);

%%%%% animal: dop_47 %%%%%
input_paths{end+1}  = 'dop_47/2022-06-05/001/alf/';
input_paths{end+1}  = 'dop_47/2022-06-06/001/alf/';
input_paths{end+1}  = 'dop_47/2022-06-09/003/alf/';
input_paths{end+1}  = 'dop_47/2022-06-10/002/alf/';
%%%%% animal: dop_48 %%%%%
input_paths{end+1}  = 'dop_48/2022-06-19/002/alf/';
input_paths{end+1}  = 'dop_48/2022-06-20/001/alf/';
input_paths{end+1}  = 'dop_48/2022-06-27/002/alf/';
input_paths{end+1}  = 'dop_48/2022-06-28/001/alf/';
%%%%% animal: dop_49 %%%%%
input_paths{end+1} = 'dop_49/2022-06-14/001/alf/';
input_paths{end+1} = 'dop_49/2022-06-15/001/alf/';
input_paths{end+1} = 'dop_49/2022-06-16/001/alf/';
input_paths{end+1} = 'dop_49/2022-06-17/001/alf/';
input_paths{end+1} = 'dop_49/2022-06-18/002/alf/';
input_paths{end+1} = 'dop_49/2022-06-19/001/alf/';
input_paths{end+1} = 'dop_49/2022-06-20/001/alf/';
input_paths{end+1} = 'dop_49/2022-06-27/003/alf/';
%%%%% animal: dop_50 %%%%%
input_paths{end+1} = 'dop_50/2022-09-12/001/alf/';
input_paths{end+1} = 'dop_50/2022-09-13/001/alf/';
input_paths{end+1} = 'dop_50/2022-09-14/003/alf/';
input_paths{end+1} = 'dop_50/2022-09-16/003/alf/';
input_paths{end+1} = 'dop_50/2022-09-17/001/alf/';
input_paths{end+1} = 'dop_50/2022-09-18/001/alf/';
%%%%% animal: dop_53 %%%%%
input_paths{end+1} = 'dop_53/2022-10-02/001/alf/';
input_paths{end+1} = 'dop_53/2022-10-03/001/alf/';
input_paths{end+1} = 'dop_53/2022-10-04/001/alf/';
input_paths{end+1} = 'dop_53/2022-10-05/001/alf/';
input_paths{end+1} = 'dop_53/2022-10-07/001/alf/';
%%%%% animal: dop_56 %%%%%
input_paths{end+1} = 'dop_56/2023-09-30/001/alf/';
input_paths{end+1} = 'dop_56/2023-10-01/001/alf/';
input_paths{end+1} = 'dop_56/2023-10-02/001/alf/';
input_paths{end+1} = 'dop_56/2023-10-03/001/alf/';
input_paths{end+1} = 'dop_56/2023-10-05/001/alf/';
%%%%% animal: dop_57 %%%%%
input_paths{end+1} = 'dop_57/2023-10-17/002/alf/';
input_paths{end+1} = 'dop_57/2023-10-19/002/alf/';
input_paths{end+1} = 'dop_57/2023-10-20/001/alf/';
%%%%% animal: dop_59 %%%%%
input_paths{end+1} = 'dop_59/2023-10-23/003/alf/';
input_paths{end+1} = 'dop_59/2023-10-24/001/alf/';
input_paths{end+1} = 'dop_59/2023-10-25/001/alf/';
input_paths{end+1} = 'dop_59/2023-10-26/001/alf/';
input_paths{end+1} = 'dop_59/2023-10-28/001/alf/';
input_paths{end+1} = 'dop_59/2023-10-29/001/alf/';
%% settings
% var1 = 'QLEARNING';
var1 = 'CRAC'; % QLEARNING
outputdir_suffix = 'SeqAC_noawin_m_avchoice_median_FINAL';
null_sessions = 200;
runall = 0;
%% submit jobs
session_list = 1:length(input_paths);

for i = session_list
    load([cz_path,input_paths{i},'ephys_data.mat']);
    if isfield(ephys_data,'units')
        N_total = length(ephys_data.units);
        idx = []; systemCommand = [];
        input_dir = [cz_path,input_paths{i},'encodingmodels/inputs/neurons/'];
        if runall
            region = AllenRegions_limited({ephys_data.units.location});
            idx = find([ephys_data.units.label]==1 & ismember(region.IDs,1:10) & [ephys_data.units.presence]>=0.9);
        else
            for j = 1:N_total
                if ephys_data.units(j).label==1 && ephys_data.units(j).presence >= 0.9
                    region = AllenRegions_limited({ephys_data.units(j).location});
                    if ismember(region.IDs,5:8)
                        if exist([input_dir,'neuron_',num2str(j,'%03.0f'),'_pretest.mat'],'file') == 2
                            load([input_dir,'neuron_',num2str(j,'%03.0f'),'_pretest.mat'],'output');
                            if isstruct(output.real) && output.pvalue.full<=0.01+1E-10
                                output_dir = [cz_path,input_paths{i},'encodingmodels/outputs/',var1,'_',outputdir_suffix,'/neuron_',num2str(j,'%03.0f'),'/'];
                                if length(dir([output_dir,'neuron_',num2str(j,'%03.0f'),'_session_*.mat'])) < 201
                                    idx = [idx j];
                                end
                            end
                        else
                            idx = [idx j];
                        end
                    end
                end
            end
            idx = unique(idx);
        end
        disp(['Recording: ',input_paths{i}(1:end-5)])
        if ~isempty(idx)
            if runall
                missing = sprintf('%.0f,',idx); missing = missing(1:end-1);
            else
                missing = sprintf('%.0f,',idx); missing = missing(1:end-1);
            end
            
            systemCommand = ['sbatch --array=',missing,' /jukebox/witten/Chris/matlab/cz/ibl_da_neuropixels_2022/encoding-model/encodingmodel_batch.sh ',input_paths{i}(1:end-5)];
            disp(['Command:   ',systemCommand])
            [status, result] = system(systemCommand);
            disp(['Result:    ',result])
        else
            disp('Result:    All jobs complete')
            disp(' ')
        end
    else
        disp(['Recording: ',input_paths{i}(1:end-5)])
        disp('Result:    Empty')
        disp(' ')
    end
end