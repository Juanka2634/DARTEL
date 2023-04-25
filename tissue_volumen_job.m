%-----------------------------------------------------------------------
% Job saved on 13-Feb-2022 14:12:17 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
function tissue_volumen_job(tissue)

clear matlabbatch

matlabbatch{1}.spm.util.tvol.matfiles = cellstr(tissue);
matlabbatch{1}.spm.util.tvol.tmax = 3;
matlabbatch{1}.spm.util.tvol.mask = {'/home/quizhpilema.134643/matlab/spm12/tpm/mask_ICV.nii,1'};
matlabbatch{1}.spm.util.tvol.outf = 'Tissue_volumen_measure';

spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);

end
