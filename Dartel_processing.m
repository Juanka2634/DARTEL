clear
clc
addpath('/opt/dora/Dora/IBEAS/Functions/');
%% Processing images T1 with dartel method

% Principal information

    %Enter the path of the images
path_in = fullfile('/opt','dora','Dora','Estudio_ELA','Resultados','Volumetria','DARTEL');
    %Enter the output path
path_out = fullfile('/opt','dora','Dora','Estudio_ELA','Resultados','Volumetria','DARTEL');

id_1 = "sub-C";
id_2 = "sub-P";

[controls,patients,nfiles,paths_ctr_outs,paths_pat_outs] = principal_info(path_in,path_out,id_1,id_2,"no_pair");

    %% STEP1: Segmentation of white and grey matter

seg_all = cellstr(paths_ctr_outs(:,1),paths_pat_outs(:,1));

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
    
% ti_vol = [paths_pat_outs([1:end],6)];
%ti_vol = [paths_pat_outs([1:28],6);paths_pat_outs(30:length(paths_pat_outs),6)];
ti_vol = [paths_ctr_outs(:,6) ; paths_pat_outs(:,6)];
%ti_vol = [paths_pat_outs([1:7],6);paths_pat_outs([9:14],6);paths_pat_outs([16:18],6);paths_pat_outs([20:23],6)];
%ti_vol = [paths_pat_outs(1:28,6);paths_pat_outs(30:32,6)];

tissue_volumen_job(ti_vol)

opts = delimitedTextImportOptions('Delimiter',',');
data = readmatrix('Tissue_volumen_measure.csv',opts);

[vol_wm,vol_gm,vol_le] = csvimport ('Tissue_volumen_measure.csv','columns',{'Volume1','Volume2','Volume3'});
vol_total = vol_wm + vol_gm +vol_le;
    
    %% STEP4: Statistics with the results of the normalize template


%S = load('controles-pacientes.txt');

[name1 name2]= search_database(patients',path_out);

fileID = readtable(name1);

mkdir (fullfile(path_out,'Result_DARTEL_actual',name2(end)));
dir_out = fullfile(path_out,'Result_DARTEL_actual',name2(end));
path_pat = fullfile(path_out);

var1_batch = {};
var2_batch = [];
var3_batch = [];
var4_batch = [];
var5_batch = [];

[rows1 columns1] = size(fileID);
for i = 1 : rows1
    names_var = string(fileID.Var1(i));
    var1_batch{i,1} = char(fullfile(path_pat,names_var,strcat('smwc1',names_var(),',1')));
    var2_batch(i,1) = fileID.Var2(i);
    var3_batch(i,1) = fileID.Var3(i);
    var4_batch(i,1) = fileID.Var4(i);
%     if string(fileID.Var3(i)) == "Mujer"
%         var3_batch(i,1) = 0; %If the varaible is Mujer change the value for 0
%     else
%         var3_batch(i,1) = 1;
%     end
%         var4_batch(i,1) = fileID.Var4(i);
%     if string(fileID.Var4(i)) == "E3/E3" || string(fileID.Var4(i)) == "E3/E2"
%         var4_batch(i,1) = 0; %If the varaible is Mujer change the value for 0
%     else
%         var4_batch(i,1) = 1;
%     end
end

two_sample_ttest(dir_out,paths_ctr_outs(:,7),paths_pat_outs(:,7),vol_total,S);

% mkdir (fullfile(path_out,'Patients','bulbar-espinal'));
% dir_paired_out = fullfile(path_out,'Patients','bulbar-espinal');
% 
% paired_test_job(dir_paired_out,vol_total)

    %% Statistics bulbar - spinal
    
mkdir (fullfile(path_out,'Patients','bulbar-espinal'));
dir_paired_out = fullfile(path_out,'Patients','bulbar-espinal');

S = load('bulbar-spinal.txt');

var1 = paths_pat_outs(:,7);
clear group_bulbar
clear group_spinal
vol1 = [];
vol2 = [];
age1 = [];
age2 = [];
ALSFR1 = [];
ALSFR2 = [];

gb = 1;
gs = 1;

for y = 1 : length(var1)
    if S(y,2) == 2
        group_bulbar(gb) = var1(y);
        vol1(gb) = vol_total(y);
        age1(gb) = S(y,3);
        ALSFR1(gb) = S(y,4);
        gb = gb + 1;
    end
    if S(y,2) == 1
        group_spinal(gs) = var1(y);
        vol2(gs) = vol_total(y);
        age2(gs) = S(y,3);
        ALSFR2(gs)=S(y,4);
        gs = gs + 1;
    end
end
    
Age = [age1 age2]';
vol_group = [vol1 vol2]';
ALSFR = [ALSFR1 ALSFR2]';

two_sample_ttest(dir_paired_out, cellstr(group_bulbar'), cellstr(group_spinal'), vol_group, Age, ALSFR,'Bulbar','Espinal');

%% afectaciones cognitivos

mkdir (fullfile(path_out,'Patients','sinafecognitiva-afecognitiva'));
dir_paired_out = fullfile(path_out,'Patients','sinafecognitiva-afecognitiva');

%S = load('sinafeccognitivo-afeccognitivo.txt');

filesID = fopen('sinafeccognitivo-afeccognitivo.txt','r');
formatSpec = '%*s %d %d %d';
sizeA = [3 Inf];
A = fscanf(filesID,formatSpec,sizeA);
fclose(filesID)
B = A';


var1 = paths_pat_outs([1:length(B)],7);
vol_conv = paths_pat_outs([1:length(B)],6);
vol1 = [];
vol2 = [];
age1 = [];
age2 = [];
gb = 1;
gs = 1;

ti_vol = [vol_conv];
tissue_volumen_job(ti_vol)
opts = delimitedTextImportOptions('Delimiter',',');
data = readmatrix('Tissue_volumen_measure.csv',opts);
[vol_wm,vol_gm,vol_le] = csvimport ('Tissue_volumen_measure.csv','columns',{'Volume1','Volume2','Volume3'});
vol_total = vol_wm + vol_gm +vol_le;

for y = 1 : length(var1)
    if B(y,2) == 0
        group_no_deterioro(gb) = var1(y);
        vol1(gb) = vol_total(y);
        age1(gb) = B(y,1);
        ALSFR1(gb) = B(y,3);
        gb = gb + 1;
    end
    if B(y,2) == 1
        group_deterioro(gs) = var1(y);
        vol2(gs) = vol_total(y);
        age2(gs) = B(y,1);
        ALSFR2(gs) = B(y,3);
        gs = gs + 1;
    end
end
    
Age = [age1 age2]';
vol_group = [vol1 vol2]';
ALSFR = [ALSFR1 ALSFR2]';

%two_sample_ttest(dir_paired_out, cellstr(group_no_deterioro'), cellstr(group_deterioro'), vol_group, Age);
two_sample_ttest(dir_paired_out, cellstr(group_no_deterioro'), cellstr(group_deterioro'), vol_group, Age, ALSFR,'group_no_deterioro','group_deterioro');

%% Progresores rápido vs lentos GRUPOS

mkdir (fullfile(path_out,'Patients','pro_rapido-pro-lento'));
dir_paired_out = fullfile(path_out,'Patients','pro_rapido-pro-lento');

%S = load('proRapidos_proLentos.txt');

filesID = fopen('proRapidos_proLentos.txt','r');
formatSpec = '%*s %d %f %d';
sizeA = [3 Inf];
A = fscanf(filesID,formatSpec,sizeA);
fclose(filesID)
B = A';

var1 = [paths_pat_outs(1:28,7);paths_pat_outs(30:length(paths_pat_outs)-1,7)];
vol_conv = [paths_pat_outs(1:28,6);paths_pat_outs(30:length(paths_pat_outs)-1,6)];

gb = 1;
gs = 1;

ti_vol = [vol_conv];
tissue_volumen_job(ti_vol)
opts = delimitedTextImportOptions('Delimiter',',');
data = readmatrix('Tissue_volumen_measure.csv',opts);
[vol_wm,vol_gm,vol_le] = csvimport ('Tissue_volumen_measure.csv','columns',{'Volume1','Volume2','Volume3'});
vol_total = vol_wm + vol_gm +vol_le;

median_1 = median(B(:,2));
mean_1 = mean(B(:,2));

for y = 1 : length(var1)
    if B(y,2) >= mean_1
        group_proRapido(gb) = var1(y);
        vol1(gb) = vol_total(y);
        age1(gb) = B(y,1);
        ALSFR1(gb) = B(y,3);
        gb = gb + 1;
    end
    if B(y,2) < mean_1
        group_proLento(gs) = var1(y);
        vol2(gs) = vol_total(y);
        age2(gs) = B(y,1);
        ALSFR2(gs) = B(y,3);
        gs = gs + 1;
    end
end
    
Age = [age1 age2]';
vol_group = [vol1 vol2]';
ALSFR = [ALSFR1 ALSFR2]';
name1 = 'GProRapido';
name2 = 'GProLento';
two_sample_ttest(dir_paired_out, cellstr(group_proRapido'), cellstr(group_proLento'), vol_group, Age,ALSFR,name1,name2);

%% one sample t-test covariable rate_progress1

mkdir (fullfile(path_out,'Patients','pro_rapidoVar-pro_lentoVar'));
dir_paired_out = fullfile(path_out,'Patients','pro_rapidoVar-pro_lentoVar');

S = load('proRapidosVar_proLentosVar.txt');

pat_list = [paths_pat_outs(1:28,7);paths_pat_outs(30:32,7)];

median_1 = median(S(:,3));
mean_1 = mean(S(:,3));

rate_progress1 = S(:,3);
Age = S(:,2);

one_sample_ttest(dir_paired_out, cellstr(pat_list), rate_progress1, vol_total, Age);

%% statistics rate_progres2 GROUP

mkdir (fullfile(path_out,'Patients','pro_rapido2-pro_lento2'));
dir_paired_out = fullfile(path_out,'Patients','pro_rapido2-pro_lento2');

S = load('proRapidos2_proLentos2.txt');

var1 = [paths_pat_outs(1:7,7);paths_pat_outs(9:14,7);paths_pat_outs(16:18,7);paths_pat_outs(20:23,7)];

gb = 1;
gs = 1;

median_1 = median(S(:,3));
mean_1 = mean(S(:,3));

for y = 1 : length(var1)
    if S(y,3) >= median_1
        group_proRapido2(gb) = var1(y);
        %vol1(gb) = vol_total(y);
        age1(gb) = S(y,2);
        gb = gb + 1;
    end
    if S(y,3) < median_1
        group_proLento2(gs) = var1(y);
        %vol2(gs) = vol_total(y);
        age2(gs) = S(y,2);
        gs = gs + 1;
    end
end
    
Age = [age1 age2]';
vol_group = [vol1 vol2]';
name1 = 'GProRapido2';
name2 = 'GProLento2';

two_sample_ttest(dir_paired_out, cellstr(group_proRapido2'), cellstr(group_proLento2'), vol_group, Age,name1,name2);
    
%% Daño cognitivo o conductual vs controles pareados

clear
clc

path_out = fullfile('/opt','dora','Dora','Estudio_ELA','Resultados','Volumetria','DARTEL');

mkdir (fullfile(path_out,'Patients','ControlesPar_vs_DañoCogn_Cond'));
dir_paired_out = fullfile(path_out,'Patients','ControlesPar_vs_DañoCogn_Cond');

[ID_DB Age_ID DCog DCond] = csvimport('Cong_Cond_vs_ControlesPar.csv', 'columns', [1,2,3,4],'noHeader', true);

gs = 1;

for x = 1 : length(Age_ID)
    id_split = char(ID_DB(x));
    if id_split(1) == 'P'
        id_split2 = string(strrep(ID_DB(x),'P','C'));
        if DCog(x) == 1 || DCond(x) == 1
            varDCogDCon(gs) =  fullfile(path_out,"sub-"+string(ID_DB(x)),"smwc1sub-"+string(ID_DB(x)+".nii"));
            varControlesPar(gs) = fullfile(path_out,"sub-"+id_split2,"smwc1sub-"+id_split2+".nii");
            vartissueDCogDCon(gs) =  fullfile(path_out,"sub-"+string(ID_DB(x)),"sub-"+string(ID_DB(x)+"_seg8.mat"));
            vartissueControlesPar(gs) = fullfile(path_out,"sub-"+id_split2,"sub-"+id_split2+"_seg8.mat");
            age1(gs) = Age_ID(x);
            %ti_vol(gs) = fullfile(path_out,"sub-"+id_split2,"smwc1sub-"+id_split2+".nii");
            for y = 1 : length(Age_ID)
                if id_split2 == ID_DB(y)
                    age2(1,gs) = Age_ID(y);
                end
            end
            gs = gs + 1;
        end
    end
end

varDCogDCon';
varControlesPar';

ti_vol = [vartissueControlesPar';vartissueDCogDCon'];

tissue_volumen_job(ti_vol)

opts = delimitedTextImportOptions('Delimiter',',');
data = readmatrix('Tissue_volumen_measure.csv',opts);

[vol_wm,vol_gm,vol_le] = csvimport ('Tissue_volumen_measure.csv','columns',{'Volume1','Volume2','Volume3'});
vol_total = vol_wm + vol_gm +vol_le;

Age = [age2';age1'];

name1 = 'ControlesPareados';
name2 = 'DañoCog_o_Cond';

two_sample_ttest(dir_paired_out, cellstr(varControlesPar'), cellstr(varDCogDCon'), vol_total, Age,name1,name2);


%% Postbasal grupos

clear
clc

path_out = fullfile('/opt','dora','Dora','Estudio_ELA','Resultados','Volumetria','DARTEL');

mkdir (fullfile(path_out,'Patients','post_basal'));
dir_paired_out = fullfile(path_out,'Patients','post_basal');

[ID_DB Age_ID PostBasal ALSFR] = csvimport('post_basal_1.csv', 'columns', [1,2,3,4],'noHeader', true);

gs = 1;
gg = 1;

for x = 1 : length(Age_ID)
    if PostBasal(x) == 1
        GrupoRapidoProg(gs) = fullfile(path_out,"sub-"+string(ID_DB(x)),"smwc1sub-"+string(ID_DB(x)+".nii"));
        tissueGrupoRapidoProg(gs) =  fullfile(path_out,"sub-"+string(ID_DB(x)),"sub-"+string(ID_DB(x)+"_seg8.mat"));
        age1(gs) = Age_ID(x);
        ALSFR1(gs) = ALSFR(x);
        gs = gs +1;
    else
        GrupoLentaProg(gg) = fullfile(path_out,"sub-"+string(ID_DB(x)),"smwc1sub-"+string(ID_DB(x)+".nii"));
        tissueGrupoLentaProg(gg) =  fullfile(path_out,"sub-"+string(ID_DB(x)),"sub-"+string(ID_DB(x)+"_seg8.mat"));
        age2(gg) = Age_ID(x);
        ALSFR2(gg) = ALSFR(x);
        gg = gg + 1;
    end
end

ti_vol = [tissueGrupoLentaProg';tissueGrupoRapidoProg'];

tissue_volumen_job(ti_vol)

opts = delimitedTextImportOptions('Delimiter',',');
data = readmatrix('Tissue_volumen_measure.csv',opts);

[vol_wm,vol_gm,vol_le] = csvimport ('Tissue_volumen_measure.csv','columns',{'Volume1','Volume2','Volume3'});
vol_total = vol_wm + vol_gm +vol_le;

Age = [age2';age1'];
ALSFR = [ALSFR1 ALSFR2]';

name1 = 'GrupoLentaProg';
name2 = 'GrupoRapidoProg';

two_sample_ttest(dir_paired_out, cellstr(GrupoLentaProg'), cellstr(GrupoRapidoProg'), vol_total, Age,ALSFR,name1,name2);

%% ASLFR basal

clear
clc

path_out = fullfile('/opt','dora','Dora','Estudio_ELA','Resultados','Volumetria','DARTEL');

mkdir (fullfile(path_out,'Patients','ASLFR_basal'));
dir_paired_out = fullfile(path_out,'Patients','ASLFR_basal');

[ID_DB Age_ID ASLFR_basal] = csvimport('ASLFR_basal.csv', 'columns', [1,2,3],'noHeader', true);

median_1 = median(ASLFR_basal);

gs = 1;
gg = 1;



for x = 1 : length(Age_ID)
    if ASLFR_basal(x) >= median_1
        GrupoASLFR_basal1(gs) = fullfile(path_out,"sub-"+string(ID_DB(x)),"smwc1sub-"+string(ID_DB(x)+".nii"));
        tissueGrupoASLFR_basal1(gs) =  fullfile(path_out,"sub-"+string(ID_DB(x)),"sub-"+string(ID_DB(x)+"_seg8.mat"));
        age1(gs) = Age_ID(x);
        gs = gs +1;
    else
        GrupoASLFR_basal0(gg) = fullfile(path_out,"sub-"+string(ID_DB(x)),"smwc1sub-"+string(ID_DB(x)+".nii"));
        tissueGrupoASLFR_basal0(gg) =  fullfile(path_out,"sub-"+string(ID_DB(x)),"sub-"+string(ID_DB(x)+"_seg8.mat"));
        age2(gg) = Age_ID(x);
        gg = gg +1;
    end
end

ti_vol = [tissueGrupoASLFR_basal1';tissueGrupoASLFR_basal0'];

tissue_volumen_job(ti_vol)

opts = delimitedTextImportOptions('Delimiter',',');
data = readmatrix('Tissue_volumen_measure.csv',opts);

[vol_wm,vol_gm,vol_le] = csvimport ('Tissue_volumen_measure.csv','columns',{'Volume1','Volume2','Volume3'});
vol_total = vol_wm + vol_gm +vol_le;

Age = [age1';age2'];

name1 = 'ASLFR_alto';
name2 = 'ASLFR_bajo';

two_sample_ttest(dir_paired_out, GrupoASLFR_basal1', GrupoASLFR_basal0', vol_total, Age, name1,name2);






    
