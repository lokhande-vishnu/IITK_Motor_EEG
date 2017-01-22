% minFunc
fprintf('Compiling minFunc files...\n');
mex -outdir minFunc minFunc/lbfgsC.c
% mex -outdir lossFuncs minFunc/lbfgsC.c
% UGM
fprintf('Compiling UGM files...\n');
mex -outdir UGM/compiled UGM/mex/UGM_makeEdgeVEC.c
mex -outdir UGM/compiled UGM/mex/UGM_CRF_makePotentialsC.c
mex -outdir UGM/compiled UGM/mex/UGM_CRF_PseudoNLLC.c
mex -outdir UGM/compiled UGM/mex/UGM_Decode_ICMC.c
mex -outdir UGM/compiled UGM/mex/UGM_Infer_LBPC.c
mex -outdir UGM/compiled UGM/mex/UGM_LogConfigurationPotentialC.c
mex -outdir UGM/compiled UGM/mex/UGM_CRF_NLLC.c