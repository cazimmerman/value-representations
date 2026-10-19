%% setup
clearvars; close all; clc;
addpath('Z:\Chris\matlab\cz\ibl_da_neuropixels_2022\utils\');
addpath(genpath('Z:\Chris\matlab\numpy-matlab\'));
%% data files
input_paths = cell(0,0);
probe = cell(0,0);

%%%%% animal: dop_47 %%%%%
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_47\2022-06-05\001\alf\';
probe{end+1}       = {'probe00\pykilosort';'probe01\pykilosort';'probe02\pykilosort';'probe03\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_47\2022-06-06\001\alf\';
probe{end+1}       = {'probe00\pykilosort';'probe01\pykilosort';'probe02\pykilosort';'probe03\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_47\2022-06-09\003\alf\';
probe{end+1}       = {'probe00\pykilosort';'probe01\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_47\2022-06-10\002\alf\';
probe{end+1}       = {'probe00\pykilosort';'probe01\pykilosort'};

%%%%% animal: dop_48 %%%%%
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_48\2022-06-19\002\alf\';
probe{end+1}       = {'probe00\pykilosort';'probe01\pykilosort';'probe02\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_48\2022-06-20\001\alf\';
probe{end+1}       = {'probe00\pykilosort';'probe01\pykilosort';'probe02\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_48\2022-06-27\002\alf\';
probe{end+1}       = {'probe00\pykilosort';'probe01\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_48\2022-06-28\001\alf\';
probe{end+1}       = {'probe00\pykilosort'};

%%%%% animal: dop_49 %%%%%
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_49\2022-06-14\001\alf\';
probe{end+1}       = {'probe00\pykilosort';'probe01\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_49\2022-06-15\001\alf\';
probe{end+1}       = {'probe00\pykilosort';'probe01\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_49\2022-06-16\001\alf\';
probe{end+1}       = {'probe00\pykilosort';'probe01\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_49\2022-06-17\001\alf\';
probe{end+1}       = {'probe00\pykilosort';'probe01\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_49\2022-06-18\002\alf\';
probe{end+1}       = {'probe00\pykilosort';'probe01\pykilosort';'probe02\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_49\2022-06-19\001\alf\';
probe{end+1}       = {'probe00\pykilosort';'probe01\pykilosort';'probe02\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_49\2022-06-20\001\alf\';
probe{end+1}       = {'probe00\pykilosort';'probe01\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_49\2022-06-27\003\alf\';
probe{end+1}       = {'probe00\pykilosort';'probe01\pykilosort'};

%%%%% animal: dop_50 %%%%%
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_50\2022-09-12\001\alf\';
probe{end+1}       = {'probe00\pykilosort';'probe01\pykilosort';'probe02\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_50\2022-09-13\001\alf\';
probe{end+1}       = {'probe00\pykilosort';'probe01\pykilosort';'probe02\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_50\2022-09-14\003\alf\';
probe{end+1}       = {'probe00\pykilosort';'probe01\pykilosort';'probe02\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_50\2022-09-16\003\alf\';
probe{end+1}       = {'probe00\pykilosort';'probe01\pykilosort';'probe02\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_50\2022-09-17\001\alf\';
probe{end+1}       = {'probe00\pykilosort';'probe01\pykilosort';'probe02\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_50\2022-09-18\001\alf\';
probe{end+1}       = {'probe00\pykilosort';'probe01\pykilosort';'probe02\pykilosort'};

%%%%% animal: dop_53 %%%%%
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_53\2022-10-02\001\alf\';
probe{end+1}       = {'probe00\pykilosort';'probe01\pykilosort';'probe02\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_53\2022-10-03\001\alf\';
probe{end+1}       = {'probe01\pykilosort';'probe02\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_53\2022-10-04\001\alf\';
probe{end+1}       = {'probe00\pykilosort';'probe01\pykilosort';'probe02\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_53\2022-10-05\001\alf\';
probe{end+1}       = {'probe00\pykilosort';'probe01\pykilosort';'probe02\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_53\2022-10-07\001\alf\';
probe{end+1}       = {'probe00\pykilosort';'probe01\pykilosort';'probe02\pykilosort'};

%%%%% animal: dop_56 %%%%%
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_56\2023-09-30\001\alf\';
probe{end+1}       = {'probe00\pykilosort';'probe01\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_56\2023-10-01\001\alf\';
probe{end+1}       = {'probe00\pykilosort';'probe01\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_56\2023-10-02\001\alf\';
probe{end+1}       = {'probe00\pykilosort';'probe01\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_56\2023-10-03\001\alf\';
probe{end+1}       = {'probe00\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_56\2023-10-05\001\alf\';
probe{end+1}       = {'probe00\pykilosort'};

%%%%% animal: dop_57 %%%%%
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_57\2023-10-17\002\alf\';
probe{end+1}       = {'probe00\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_57\2023-10-19\002\alf\';
probe{end+1}       = {'probe00\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_57\2023-10-20\001\alf\';
probe{end+1}       = {'probe00\pykilosort'};

%%%%% animal: dop_59 %%%%%
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_59\2023-10-23\003\alf\';
probe{end+1}       = {'probe00\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_59\2023-10-24\001\alf\';
probe{end+1}       = {'probe00\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_59\2023-10-25\001\alf\';
probe{end+1}       = {'probe00\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_59\2023-10-26\001\alf\';
probe{end+1}       = {'probe00\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_59\2023-10-28\001\alf\';
probe{end+1}       = {'probe00\pykilosort'};
input_paths{end+1} = 'Z:\Alex\Data\Subjects\dop_59\2023-10-29\001\alf\';
probe{end+1}       = {'probe00\pykilosort'};
%% pre-processing
gcp;
tic
disp(' ')
disp('----------------------------------------------------------')
disp('Generating standardized data structure for each experiment')
disp('----------------------------------------------------------')
parfor i = 1:length(input_paths)
    MakeDirectories(input_paths{i},probe{i})
    disp(['Processing behavior data for session #',num2str(i,'%02.f')])
    LoadBehaviorData(input_paths{i});
    disp(['Processing ephys data for session #',num2str(i,'%02.f')])
    LoadEphysData(input_paths{i},probe{i},0.01);
end
disp('Generating surrogate behavior data for null sessions')
MakeNullSessions(input_paths,200,1000,'_SeqAC_noawin_m_avchoice_median');
disp(['Elapsed time is ',num2str(toc/60,3),' min'])
delete(gcp)