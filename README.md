# SeisElastic2D

An open source software package for isotropic- , anisotropic- and visco-elastic full-waveform inversion

The package includes the following modulues:

1 Basic optimization methods:

    1.1 (diagonal Hessian preconditioned) steepest-denscent (SD)
    1.2 (preconditioned) non-linear conjugate gradient (NCG)
    1.3 (preconditioned) L-BFGS

2 Isotropic-elastic FWI with different model parameterizations: 

    2.1 Velocity-density (DV)
    2.2 Lame-density (DL)
    2.3 Modulus-density (DM)
    2.4 Impedance-density (IPD)
    2.5 Impedance-velocity (VIP)
    2.6 Velocity-Vp/Vs ratio

3 Anisotropic-elastic FWI in VTI, HTI and TTI media: 

    3.1 Diagonal block Hessian preconditioning
    3.2 Elastic constants parameterization
    3.3 Thomsen parameters parameterization
    3.4 ongoing.......

4 Visco-elastic FWI with different misfit functions

5 Misfit functions: 

    5.1 Cross-correlation traveltime (CC)
    5.2 Waveform-difference (WD)
    5.3 Envelope-difference (ED)
    5.4 Envelope-traveltime (ET) 
    5.5 Envelope-log-ratio (ER)
    5.6 Instantaneous-phase-difference (IP)
    5.7 (RMS) Amplitude-difference (AD)
    5.8 (RMS) Amplitude-log-ratio (AR)
    5.9 Differential-traveltime (DT)
    5.10 Differential-amplitude (DA)
    5.11 ongoing........


---------------------------------------------------------------------------------------------------------------------------------
Related publications:

Pan, W., K. A. Innanen and Y, Geng. Elastic full-waveform inversion and parameterization analysis applied to walk away vertical
seismic profile data for unconventional (heavy oil) reservoir characterization. Geophysical Journal International, 2018, 213: 1-35.

Pan, W., Y. Geng and K. A. Innanen. Interparameter tradeoff quantification and reduction in isotropic-elastic full-waveform
inversion: synthetic experiments and Hussar land data set application. Geophysical Journal International, 2018, 213: 1305-1333.


