clear
clc

addpath('/media/juan/ROCKET-NANO/MRI_Analysis/matlab_scripts/DARTEL');
%% Processing images T1 with dartel method

% Principal information

    %Enter the path of the images
path_in = fullfile('/media','juan2634','ROCKET-NANO','MRI_Analysis','ELP','BIDS_ELP');
    %Enter the output path
path_out = fullfile('/media','juan2634','ROCKET-NANO','MRI_Analysis','ELP','BIDS_ELP','derivatives','Morfometria','DARTEL','CTR-ELP');
cd (path_out)

id_1 = "sub-C";
id_2 = "sub-ELP";
num_characters = 9;

[controls,patients,nfiles,paths_ctr_outs,paths_pat_outs] = principal_info(path_in,path_out,id_1,id_2,num_characters,"no_pair");
%%

%exclude_files = ["ELP02" "ELP04","ELP12","P031","P029","P014","P002"];
exclude_files = ["ELP02" "ELP04","ELP12","C003","C011","C029","C032"];

for exc = 1 : length(exclude_files)
    cmd = ['rm -fr ' char(strcat("sub-",exclude_files(exc)))]
    system(cmd)
end

exclude_matrix_ctr = [];
exclude_matrix_pat = [];

for subj = 1 : length(controls)
    ctr_all = split(controls(subj),'-');
    ctr_name = ctr_all(2);
    ctr(subj) = string(ctr_name);
end

aux1 = 1;

for excl_subj = 1 : length(exclude_files)
    for subj = 1 : length(controls)
        if exclude_files(excl_subj) == string(ctr(subj))
            exclude_matrix_ctr(aux1) = subj;
            aux1 = aux1 + 1;
        end
    end
end

for subj_pat = 1 : length(patients)
    pat_all = split(patients(subj_pat),'-');
    pat_name = char(pat_all(2));
    pat(subj_pat) = string(pat_name);
end

aux2 = 1;

for excl_subj = 1 : length(exclude_files)
    for subj = 1 : length(patients)
        if exclude_files(excl_subj) == string(pat(subj))
            exclude_matrix_pat(aux2) = subj;
            aux2 = aux2 + 1;
        end
    end
end

pat(exclude_matrix_pat) = []; 
paths_pat_outs(exclude_matrix_pat,:) = []
patients(exclude_matrix_pat) = [] 
ctr(exclude_matrix_ctr) = []; 
paths_ctr_outs(exclude_matrix_ctr,:) = []
controls(exclude_matrix_ctr) = [] 

    %% STEP1: Segmentation of white and grey matter

exclude_files = ["ELP02" "ELP04","ELP12","P029","P014","P002"];

seg_all = cellstr([paths_ctr_outs(:,1);paths_pat_outs(:,1)]);

segment_matter_job(seg_all);
    
    %% STEP2: Create a template with all images T1

tmp_rc1 = char([paths_ctr_outs(:,2);paths_pat_outs(:,2)]);

tmp_rc2 = char([paths_ctr_outs(:,3);paths_pat_outs(:,3)]);

template_dartel_job(cellstr(tmp_rc1),cellstr(tmp_rc2));
    
    %% STEP3: Normalize the template to MNI space
    
tmp_select = fullfile(path_out,string(controls(1,1)),'Template_6.nii');
u_rc1 = char([paths_ctr_outs(:,4);paths_pat_outs(:,4)]);
c1 = char([paths_ctr_outs(:,5);paths_pat_outs(:,5)]);

normalize_dartel_job(char(tmp_select),char(u_rc1),char(c1))
    
    %% STEP 4 Tissues volumen
    
ti_vol = [paths_ctr_outs([1:end],6);paths_pat_outs([1:end],6)];

tissue_volumen_job(ti_vol,strcat(path_out,'/Tissue_volumen_measure_C_ELP.csv'))

opts = delimitedTextImportOptions('Delimiter',',');
data = readmatrix(strcat(path_out,'/Tissue_volumen_measure_C_ELP.csv'),opts);

[vol_wm,vol_gm,vol_le] = csvimport ('Tissue_volumen_measure_C_ELP.csv','columns',{'Volume1','Volume2','Volume3'});
vol_total = vol_wm + vol_gm +vol_le;

    %% STEP4: Statistics with the results of the normalize template

ELP_study = [ctr' ;pat'];
   
[name1 name2] = search_database(ELP_study, path_out);

fileID = readtable(name1);

mkdir (fullfile(path_out,'Results_Ctr_ELP'));
dir_out = fullfile(path_out,'Results_Ctr_ELP');
path_pat = fullfile(path_out);

two_sample_ttest(dir_out,paths_ctr_outs(:,7),paths_pat_outs(:,7),fileID(:,"Var2"),fileID(:,"Var3"),vol_total);
