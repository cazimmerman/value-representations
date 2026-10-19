%% setup
clearvars; close all; clc
addpath(genpath('/jukebox/witten/Chris/matlab/raisedCosineBasis/'));
addpath(genpath('/jukebox/witten/Chris/matlab/glmnet-stanford-old/'))
addpath(genpath('/jukebox/witten/Chris/matlab/cz/ibl_da_neuropixels_2022/encoding-model/'))
addpath(genpath('/jukebox/witten/Chris/matlab/cz/ibl_da_neuropixels_2022/utils/'))
mainpath = '/jukebox/witten/Chris/data/ibl_da_neuropixels/Data/Subjects/';
%% data paths
input_paths = cell(0,0);
%%%%% animal: dop_47 %%%%%
input_paths{end+1}  = 'dop_47/2022-06-05/001/';
input_paths{end+1}  = 'dop_47/2022-06-06/001/';
input_paths{end+1}  = 'dop_47/2022-06-09/003/';
input_paths{end+1}  = 'dop_47/2022-06-10/002/';
%%%%% animal: dop_48 %%%%%
input_paths{end+1}  = 'dop_48/2022-06-19/002/';
input_paths{end+1}  = 'dop_48/2022-06-20/001/';
input_paths{end+1}  = 'dop_48/2022-06-27/002/';
input_paths{end+1}  = 'dop_48/2022-06-28/001/';
%%%%% animal: dop_49 %%%%%
input_paths{end+1} = 'dop_49/2022-06-14/001/';
input_paths{end+1} = 'dop_49/2022-06-15/001/';
input_paths{end+1} = 'dop_49/2022-06-16/001/';
input_paths{end+1} = 'dop_49/2022-06-17/001/';
input_paths{end+1} = 'dop_49/2022-06-18/002/';
input_paths{end+1} = 'dop_49/2022-06-19/001/';
input_paths{end+1} = 'dop_49/2022-06-20/001/';
input_paths{end+1} = 'dop_49/2022-06-27/003/';
%%%%% animal: dop_50 %%%%%
input_paths{end+1} = 'dop_50/2022-09-12/001/';
input_paths{end+1} = 'dop_50/2022-09-13/001/';
input_paths{end+1} = 'dop_50/2022-09-14/003/';
input_paths{end+1} = 'dop_50/2022-09-16/003/';
input_paths{end+1} = 'dop_50/2022-09-17/001/';
input_paths{end+1} = 'dop_50/2022-09-18/001/';
%%%%% animal: dop_53 %%%%%
input_paths{end+1} = 'dop_53/2022-10-02/001/';
input_paths{end+1} = 'dop_53/2022-10-03/001/';
input_paths{end+1} = 'dop_53/2022-10-04/001/';
input_paths{end+1} = 'dop_53/2022-10-05/001/';
input_paths{end+1} = 'dop_53/2022-10-07/001/';
%%%%% animal: dop_56 %%%%%
input_paths{end+1} = 'dop_56/2023-09-30/001/';
input_paths{end+1} = 'dop_56/2023-10-01/001/';
input_paths{end+1} = 'dop_56/2023-10-02/001/';
input_paths{end+1} = 'dop_56/2023-10-03/001/';
input_paths{end+1} = 'dop_56/2023-10-05/001/';
%%%%% animal: dop_57 %%%%%
input_paths{end+1} = 'dop_57/2023-10-17/002/';
input_paths{end+1} = 'dop_57/2023-10-19/002/';
input_paths{end+1} = 'dop_57/2023-10-20/001/';
%%%%% animal: dop_59 %%%%%
input_paths{end+1} = 'dop_59/2023-10-23/003/';
input_paths{end+1} = 'dop_59/2023-10-24/001/';
input_paths{end+1} = 'dop_59/2023-10-25/001/';
input_paths{end+1} = 'dop_59/2023-10-26/001/';
input_paths{end+1} = 'dop_59/2023-10-28/001/';
input_paths{end+1} = 'dop_59/2023-10-29/001/';
%% load and prep

for p = 1:length(input_paths)
    sessionpath = input_paths{p};
    disp(' ')
    disp('-----------------------------')
    disp(['Session ID: ',sessionpath(1:end-5)])
    load([mainpath,sessionpath,'alf/ephys_data.mat'],'ephys_data');
    neurons_include	= 1:length(ephys_data.units);
    disp(['Number of good units: ',num2str(length(neurons_include))])
    disp('-----------------------------')
    inputs_dir = [mainpath,sessionpath,'alf/encodingmodels/inputs/neurons/'];
    outputs_dir1 = [mainpath,sessionpath,'alf/encodingmodels/outputs/QLEARNING_ActionValueStateValue_Qmedian/'];
    outputs_dir2 = [mainpath,sessionpath,'alf/encodingmodels/outputs/QLEARNING_ContraValueIpsiValue_Qmedian/'];
    for j = 1:length(neurons_include)
        region = AllenRegions_limited({ephys_data.units(j).location});
        if (ephys_data.units(j).presence>=0.9) && (ismember(region.IDs,1:10))
            if exist([inputs_dir,'neuron_',num2str(j,'%03.0f'),'_residuals.mat'],'file') ~= 2
                makeresiduals(sessionpath,j)
            end
            if (ephys_data.units(j).label==1)
                disp(['Neuron #',num2str(j),': good'])
                if exist([inputs_dir,'neuron_',num2str(j,'%03.0f'),'_pretest.mat'],'file') ~= 2
                    tic
                    disp('  Fitting pre-test...')
                    output = pretest(sessionpath,j,200);
                else
                    load([inputs_dir,'neuron_',num2str(j,'%03.0f'),'_pretest.mat'])
                end
                disp(['  region = ',num2str(region.IDs),' p = ',num2str(output.pvalue.full,'%0.3f')])
                if output.pvalue.full>0.01+1E-10
                    if exist([outputs_dir1,'neuron_',num2str(j,'%03.0f')],'dir')
                        disp('  --> Deleting output directory...')
                        rmdir([outputs_dir1,'neuron_',num2str(j,'%03.0f')],'s')
                    end
                    if exist([outputs_dir2,'neuron_',num2str(j,'%03.0f')],'dir')
                        disp('  --> Deleting output directory...')
                        rmdir([outputs_dir2,'neuron_',num2str(j,'%03.0f')],'s')
                    end
                elseif ~(ismember(region.IDs,5:8))
                    if exist([outputs_dir1,'neuron_',num2str(j,'%03.0f'),'/neuron_',num2str(j,'%03.0f'),'_session_000_alpha_gamma_Qlaser.mat'],'file') == 2
                        disp('  --> Deleting learning rate file...')
                        delete([outputs_dir1,'neuron_',num2str(j,'%03.0f'),'/neuron_',num2str(j,'%03.0f'),'_session_000_alpha_gamma_Qlaser.mat'])
                    end
                    if exist([outputs_dir2,'neuron_',num2str(j,'%03.0f'),'/neuron_',num2str(j,'%03.0f'),'_session_000_alpha_gamma_Qlaser.mat'],'file') == 2
                        disp('  --> Deleting learning rate file...')
                        delete([outputs_dir2,'neuron_',num2str(j,'%03.0f'),'/neuron_',num2str(j,'%03.0f'),'_session_000_alpha_gamma_Qlaser.mat'])
                    end
                end
            else
                disp(['Neuron #',num2str(j),': mua'])
                disp(['  region = ',num2str(region.IDs)])
                if exist([inputs_dir,'neuron_',num2str(j,'%03.0f'),'_pretest.mat'],'file') == 2
                    disp('  --> Deleting pre-test file...')
                    delete([inputs_dir,'neuron_',num2str(j,'%03.0f'),'_pretest.mat'])
                end
                if exist([outputs_dir1,'neuron_',num2str(j,'%03.0f')],'dir')
                    disp('  --> Deleting output directory...')
                    rmdir([outputs_dir1,'neuron_',num2str(j,'%03.0f')],'s')
                end
                if exist([outputs_dir2,'neuron_',num2str(j,'%03.0f')],'dir')
                    disp('  --> Deleting output directory...')
                    rmdir([outputs_dir2,'neuron_',num2str(j,'%03.0f')],'s')
                end
            end
        else
            disp(['Neuron #',num2str(j),': skip'])
            disp(['  region = ',num2str(region.IDs),', presence = ',num2str(ephys_data.units(j).presence,'%0.2f')])
            if exist([inputs_dir,'neuron_',num2str(j,'%03.0f'),'.mat'],'file') == 2
                disp('  --> Deleting input file...')
                delete([inputs_dir,'neuron_',num2str(j,'%03.0f'),'.mat'])
            end
            if exist([inputs_dir,'neuron_',num2str(j,'%03.0f'),'_residuals.mat'],'file') == 2
                disp('  --> Deleting residuals file...')
                delete([inputs_dir,'neuron_',num2str(j,'%03.0f'),'_residuals.mat'])
            end
            if exist([inputs_dir,'neuron_',num2str(j,'%03.0f'),'_pretest.mat'],'file') == 2
                disp('  --> Deleting pre-test file...')
                delete([inputs_dir,'neuron_',num2str(j,'%03.0f'),'_pretest.mat'])
            end
            if exist([outputs_dir1,'neuron_',num2str(j,'%03.0f')],'dir')
                disp('  --> Deleting output directory...')
                rmdir([outputs_dir1,'neuron_',num2str(j,'%03.0f')],'s')
            end
            if exist([outputs_dir2,'neuron_',num2str(j,'%03.0f')],'dir')
                disp('  --> Deleting output directory...')
                rmdir([outputs_dir2,'neuron_',num2str(j,'%03.0f')],'s')
            end
        end
    end
end