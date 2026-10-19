# Code related to the paper "VTA dopamine neuron activity produces spatially organized stimulus and action value representations through conditioned reinforcement"


This repository contains:
- Code to fit encoding models to the Neuropixels data in the paper (designed for Princeton computing clusters)
- Code to generate the encoding model figures in the paper


The figure code requires the following MATLAB toolboxes:
- Statistics and Machine Learning Toolbox
- Image Processing Toolbox

The figure code also requires access to the following data and atlas files:
- `BasicModel.mat` (compiled output from the basic encoding models with task event kernels)
- `ActionValueModel.mat` (compiled output from the bilinear encoding models with action value gains from the extended Q-learning model)
- `RelativeValueStateValueModel.mat` (compiled output from the bilinear encoding models with relative and state value gains from the extended Q-learning model)
- `ConditionedReinforcerModel.mat` (compiled output from the bilinear encoding models with value and propensity gains from the conditioned reinforcer model)
- `allen_subdivisions.tif` (atlas from [Chon et al. 2019](https://doi.org/10.1038/s41467-019-13057-w))
- `41467_2019_13057_MOESM4_ESM.csv` (ontology from [Chon et al. 2019](https://doi.org/10.1038/s41467-019-13057-w))

The encoding model code requires the following packages:
- glmnet-matlab (https://github.com/junyangq/glmnet-matlab)
- raisedCosineBasis (https://github.com/pillowlab/raisedCosineBasis)


Data and atlas files: Coming soon


bioRxiv: https://doi.org/10.1101/2025.11.04.685995
