function encodingmodel_batch(sessionpath,neuronid,var1,nullsessions)

% encodingmodel_batch('dop_47/2022-06-05/001',67,'QLEARNING',200)

addpath(genpath('/jukebox/witten/Chris/matlab/raisedCosineBasis/'));
addpath(genpath('/jukebox/witten/Chris/matlab/glmnet-stanford-old/'))
addpath(genpath('/jukebox/witten/Chris/matlab/cz/ibl_da_neuropixels_2022/encoding-model/'))
addpath(genpath('/jukebox/witten/Chris/matlab/cz/ibl_da_neuropixels_2022/utils/'))

outputdir_suffix = 'SeqAC_noawin_m_avchoice_median_FINAL';

var1set = {'QLEARNING','CRAC'};
if ~ismember(var1,var1set)
    disp('Problem disaster!')
    return
end

if ~isempty(gcp('nocreate'))
    delete(gcp('nocreate'));
end
pc = parcluster('local');
pc.JobStorageLocation = strcat('/tmp/',getenv('USER'),'-',getenv('SLURM_JOB_ID'),'-',getenv('SLURM_ARRAY_TASK_ID'));
pc.NumWorkers = 4;
parpool(pc,pc.NumWorkers);

load(['/jukebox/witten/Chris/data/ibl_da_neuropixels/Data/Subjects/',sessionpath,'/alf/encodingmodels/inputs/neurons/','neuron_',num2str(neuronid,'%03.0f'),'.mat'],'Y')
if Y.metadata.label == 1
    label = 'good';
else
    label = 'mua';
end
disp(' ')
disp('------------------------------------------------------------------')
disp(['Recording ID: ',Y.metadata.session(1:end-5)])
disp(['Probe ID:     ',Y.metadata.probe(1:7)])
disp(['Cluster ID:   ',num2str(Y.metadata.clusterid)])
disp(['Location:     ',Y.metadata.location])
disp(['Label:        ',label])
disp('------------------------------------------------------------------')

if exist(['/jukebox/witten/Chris/data/ibl_da_neuropixels/Data/Subjects/',sessionpath,'/alf/encodingmodels/inputs/neurons/','neuron_',num2str(neuronid,'%03.0f'),'_residuals.mat'],'file') == 2
    disp('Residuals already generated.')
else
    tic
    makeresiduals(sessionpath,neuronid)
    disp(['Residuals generated in ',num2str(toc,'%04.0f'),' seconds.'])
end
disp('------------------------------------------------------------------')

if Y.metadata.label == 1
    
    if exist(['/jukebox/witten/Chris/data/ibl_da_neuropixels/Data/Subjects/',sessionpath,'/alf/encodingmodels/inputs/neurons/','neuron_',num2str(neuronid,'%03.0f'),'_pretest.mat'],'file') == 2
        disp('Simple encoding models already generated.')
        load(['/jukebox/witten/Chris/data/ibl_da_neuropixels/Data/Subjects/',sessionpath,'/alf/encodingmodels/inputs/neurons/','neuron_',num2str(neuronid,'%03.0f'),'_pretest.mat'],'output')
    else
        disp('Fitting simple encoding models...')
        tic
        output = pretest(sessionpath,neuronid,nullsessions);
        disp(['Simple encoding models generated in ',num2str(toc,'%04.0f'),' seconds.'])
    end
    disp('------------------------------------------------------------------')
    output_dir = ['/jukebox/witten/Chris/data/ibl_da_neuropixels/Data/Subjects/',sessionpath,'/alf/encodingmodels/outputs/',var1,'_',outputdir_suffix,'/neuron_',num2str(neuronid,'%03.0f'),'/'];
    if isstruct(output.real) && output.pvalue.full<=0.01+1E-10
        if ~exist(output_dir,'dir')
            mkdir(output_dir)
        end
        
        disp('Fitting bilinear encoding models...')
        parfor i = 0:nullsessions
            if exist(['/jukebox/witten/Chris/data/ibl_da_neuropixels/Data/Subjects/',sessionpath,'/alf/encodingmodels/outputs/',var1,'_',outputdir_suffix,'/neuron_',num2str(neuronid,'%03.0f'),'/neuron_',num2str(neuronid,'%03.0f'),'_session_',num2str(i,'%03.0f'),'.mat'],'file') == 2
                disp(['Session #',num2str(i,'%03.0f'),' fits already exist.'])
            else
                pause(0.1*rand)
                tic
                encodingmodel_cluster(sessionpath,neuronid,i,var1)
                disp(['Session #',num2str(i,'%03.0f'),' fits completed in ',num2str(toc,'%04.0f'),' seconds.'])
            end
        end
        
        disp('------------------------------------------------------------------')
        
        if exist(['/jukebox/witten/Chris/data/ibl_da_neuropixels/Data/Subjects/',sessionpath,'/alf/encodingmodels/outputs/',var1,'_',outputdir_suffix,'/neuron_',num2str(neuronid,'%03.0f'),'/neuron_',num2str(neuronid,'%03.0f'),'_session_',num2str(0,'%03.0f'),'_alpha_gamma_Qlaser.mat'],'file') == 2
            disp(['Session #',num2str(0,'%03.0f'),' learning rate models already exist.'])
        else
            disp(['Session #',num2str(0,'%03.0f'),' learning rate models already exist.'])
            encodingmodel_cluster_varyalpha(sessionpath,neuronid,0,var1)
        end
        parfor i = 1:nullsessions
            if exist(['/jukebox/witten/Chris/data/ibl_da_neuropixels/Data/Subjects/',sessionpath,'/alf/encodingmodels/outputs/',var1,'_',outputdir_suffix,'/neuron_',num2str(neuronid,'%03.0f'),'/neuron_',num2str(neuronid,'%03.0f'),'_session_',num2str(i,'%03.0f'),'_alpha_gamma_Qlaser.mat'],'file') == 2
                disp(['Session #',num2str(i,'%03.0f'),' learning rate models already exist.'])
            else
                pause(0.1*rand)
                tic
                encodingmodel_cluster_varyalpha_pseudosessions(sessionpath,neuronid,i,var1)
                disp(['Session #',num2str(i,'%03.0f'),' learning rate models completed in ',num2str(toc,'%04.0f'),' seconds.'])
            end
        end
        
        disp('------------------------------------------------------------------')
        
        parfor i = 0:nullsessions
            if exist(['/jukebox/witten/Chris/data/ibl_da_neuropixels/Data/Subjects/',sessionpath,'/alf/encodingmodels/outputs/',var1,'_',outputdir_suffix,'/neuron_',num2str(neuronid,'%03.0f'),'/neuron_',num2str(neuronid,'%03.0f'),'_session_',num2str(i,'%03.0f'),'__REVISIONS_state_value.mat'],'file') == 2
                disp(['Session #',num2str(i,'%03.0f'),' state value fits (REVISIONS) already exist.'])
            else
                pause(0.1*rand)
                tic
                encodingmodel_cluster_state_value(sessionpath,neuronid,i,var1)
                disp(['Session #',num2str(i,'%03.0f'),' state value fits (REVISIONS) completed in ',num2str(toc,'%04.0f'),' seconds.'])
            end
        end

        disp('------------------------------------------------------------------')

        parfor i = 0:nullsessions
            if exist(['/jukebox/witten/Chris/data/ibl_da_neuropixels/Data/Subjects/',sessionpath,'/alf/encodingmodels/outputs/',var1,'_',outputdir_suffix,'/neuron_',num2str(neuronid,'%03.0f'),'/neuron_',num2str(neuronid,'%03.0f'),'_session_',num2str(i,'%03.0f'),'.mat'],'file') == 2
                disp(['Session #',num2str(i,'%03.0f'),' CRAC fits already exist.'])
            else
                pause(0.1*rand)
                tic
                encodingmodel_cluster_CRAC(sessionpath,neuronid,i,var1)
                disp(['Session #',num2str(i,'%03.0f'),' CRAC fits completed in ',num2str(toc,'%04.0f'),' seconds.'])
            end
        end

    else
        disp('No nonzero betas - skipping bilinear encoding model.')
    end
    
else
    disp('Skipping encoding models.')
end
disp('------------------------------------------------------------------')

delete(gcp('nocreate'));