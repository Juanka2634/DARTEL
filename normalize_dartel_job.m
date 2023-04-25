%-----------------------------------------------------------------------
% Job saved on 08-Feb-2022 21:22:19 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
function normalize_dartel_job(template6_path, u_rc1, c1)

template6_path = cellstr(template6_path);
u_rc1 = cellstr(u_rc1);
c1 = cellstr(c1);

clear matlabbatch
matlabbatch{1}.spm.tools.dartel.mni_norm.template = template6_path;
matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.flowfields = u_rc1;
matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.images = {
                                                              c1
                                                              }';
matlabbatch{1}.spm.tools.dartel.mni_norm.vox = [1 1 1];
matlabbatch{1}.spm.tools.dartel.mni_norm.bb = [NaN NaN NaN
                                               NaN NaN NaN];
matlabbatch{1}.spm.tools.dartel.mni_norm.preserve = 1;
matlabbatch{1}.spm.tools.dartel.mni_norm.fwhm = [8 8 8];

spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);

end
