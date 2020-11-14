# CardioGrowth
Rapid computational model to predict cardiac growth and remodeling

            
            .:::.   .:::.
           :::::::.:::::::
           :::::::::::::::
           ':::::::::::::'
             ':::::::::'
               ':::::'              
                 ':'

MATLAB code of the rapid computational model developed by Colleen Witzenburg and Pim Oomen at the University of Virginia to predict cardiac growth and remodeling using changes in strain. The main code is CompartmentalGrowth, there one can choose one of the following input files calibrated to experimental data:

For Oomen et al., 2020, using a thick-walled ventricular geometry based on Lumens et al., 2009 and Walmsley et al., 2015:
    - Vernooy2007:   8 weeks of left bundle branch block followed by 8 weeks of cardiac resynchronization therapy
    - ScarPaceSweep: Similar to Vernooy2007 but set up to be used in a sweep of pacing locations, in combination with scripts that can be found in AnalysisOomen2020

For Witzenburg et al., J. Cardiovasc Transl Res 2018, using a thin-walled
spherical ventricular geometry based on Santamore and Burckhoff (1991)
    - PressureOverloadFitting: calibrated to Sasayama et al., 1976
    - PressureOverloadValidation: calibrated to Nagatomo et al. 1999
    - VolumeOverloadFitting: calibrated to Kleaveland et al., 1988
    - VolumeOverloadValidation: calibrated to Nakano et lal., 1991

You are encouraged to develop your own input file based on the included ones, and share them with others (contact us to have them included here).


Last updated on 2020/11/12
Pim Oomen
pim@virginia.edu
Department of Biomedical Engineering, University of Virginia
