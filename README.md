# Raag detection using Hidden Markov Model

The goal of the project is to detect the [raag](https://en.wikipedia.org/wiki/Raga) from a new musical sequence using a [Hidden Markov Model(HMM)](https://en.wikipedia.org/wiki/Hidden_Markov_model). A raag is a musical concept in Indian classical music that is defined by a set of notes and characterized by certain melodic transitions. These unique transitions are used to differentiate one raag from another. Typically, trained musicians with years of experience can accurately discern raags. In this work, a HMM is used to learn the transitional probabilites between musical notes that characterize each raag. The pitch contour is used as the observations/features for the model. When testing a new sequence, the maximum log likelihood given each model is chosen to be the identified raag. An accuracy of 81.25% was achieved on the test set of 16 samples across different modalities.

More information can be found in the [report](./report/root.pdf).

The slides can be found here: https://drive.google.com/open?id=11s1sBFKECmgvhUHfe8tk_3WZ1P_ojTN3ISCg9Lz3lKM

## Description of files

The main code is in `main.m` and its dependencies are located in `src/`

`main.m` has the following 3 sections:
To test, please run the last section!
	- data preprocessing: processes the data in the 'train' directory and creates 'models/model.mat'
	- training (baum welch) is done on 'models/data.mat' and 'models/model.mat' is generated.
	- testing on the files located in the 'test' directory with 'models/model.mat'

Directories:
- models - to store intermediate data/models
- plots - figures, plots generated
- src - all the src files which main.m is dependent on.
- test - contains 16 test sequences
- train - contains 3 sequences for each of the 5 raag class. 
`./praat` was used to create the pitch contour