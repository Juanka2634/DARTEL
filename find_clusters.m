%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find_clusters;
% Función para filtrar una imagen de SPM (ej, spmT_0001.img) por tamaño de
% cluster.
% 
% Cómo se usa:
% 1. Teclear en la prompt de Matlab:
% >> find_clusters;
% 
% 2. Matlab os pedirá que localicéis la imagen que queréis filtrar. El
% resultado se guardará en la misma carpeta donde está esa imagen.
% 
% 3. Seguir las instrucciones en la pantalla para :
%    - Elegir el nombre para guardar la imagen filtrada
%    - Elegir el umbral t o p por el que filtrar a nivel de voxel
%       * Si se elige una p, la función pedirá los grados de libertad del
%       análisis para calcular automáticamente la t correspondiente
%    - Elegir el tamaño de cluster k para filtrar a nivel de cluster
% 
% 4. Se almacena en el mismo directorio que la imagen original:
%   (Ejemplo para imagen original de nombre 'ejemplo.img', filtrada con p =
%   0.001 y k = 100)
%
%   a) ejemplo_p0.001_k100.img
        %--> Todos los voxels con p > 0.001 son puestos a cero
        %    y también todos los voxeles pertenecientes a clusters de
        %    tamaño menor a 100
%   b) ejemplo_p0.001_k100_allvox.img
        %--> Todos los voxels pertenecientes a clusters de tamaño menor a
        %    100 son eliminados, pero se dejan los voxeles de p > 0.001.
        %    Útil para que en MRICron los bordes de la overlay permanezcan
        %    smooth. En la escala de MRICron hay que especificar la t
        %    umbral, por contra.
%   c) ejemplo_p0.001_k100_inv.img
        %--> Imagen inversa. Contiene los clusters MENORES que el umbral k
        %    especificado.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function im_map_k = find_clusters(varargin)

% m = %matriz [x,y,z]
% 
% u = %threshold_t;
% size_k = %threshold_k;

if (nargin == 0)
    disp('---------------------------------------------------------------')
    [FileName,PathName] = uigetfile('*.img;*.nii','Select the image to filter');
    if isempty(FileName)
        disp('No file selected. Ending routine...');
        return;        
    end
    v = spm_vol(fullfile(PathName,FileName));
    m = spm_read_vols(v);
    EXT = fliplr(strtok(fliplr(FileName),'.'));
    l_EXT = length(EXT);
% % %     NewName = input(sprintf('\n & Enter name [Default, ''%s_filtered''] : ',FileName(1:end-l_EXT-1)), 's');
% % %     if isempty(NewName)
% % %         NewName = sprintf('%s_filtered.%s',FileName(1:end-l_EXT-1),EXT);
% % %     elseif ~strcmp(NewName(end-l_EXT+1:end),EXT)
% % %         NewName = strcat(NewName,'.',EXT);
% % %     end
% % %     disp(sprintf('\n --> Saving results to ''%s''',NewName));
% % %     disp(sprintf(' --> in ''%s''',PathName));
% % %     NewName = fullfile(PathName,NewName);
% % %     v.fname = NewName;
elseif nargin == 1
    m = varargin{1};
end


p_or_t = input('\n & Choose ''t'' or ''p'' value for thresholding [Default, ''t''] : ','s');
if ~strcmp(p_or_t,'t') && ~strcmp(p_or_t,'p')
    p_or_t = 't';
end
switch p_or_t
    case 't'
    u = input('\n & Enter t threshold [Default, t = 3] : ');
    if isempty(u)
        u = 3;
        disp(' --> Selected default t = 3')
    end
    tvalue = u;
    
    case 'p'
    u = input('\n & Enter p-value [Default, p = 0.05] : ');
    if isempty(u)
        u = 0.05;
        disp(' --> Selected default p = 0.05')
    end
    pvalue = u;
    df = input('\n     & Enter the degrees of freedom of your analysis : ');
    if isempty(df)
        df = 10;
        disp('      --> Selected default df = 10')
    end
    u = abs(tinv(u,df));
end
    

size_k = input('\n & Enter extent threshold [Default, k = 0] : ');
if isempty(size_k)
    size_k = 0;
    disp(' --> Selected default k = 0')
end
fprintf('\n');
    switch p_or_t
        case 'p'
            NewName = sprintf('%s_p%.4f_k%d.%s',FileName(1:end-l_EXT-1),pvalue,size_k,EXT);
            NewName2 = sprintf('%s_p%.4f_k%d_allvox.%s',FileName(1:end-l_EXT-1),pvalue,size_k,EXT);
            NewName3 = sprintf('%s_p%.4f_k%d_inv.%s',FileName(1:end-l_EXT-1),pvalue,size_k,EXT);
        case 't'
            NewName = sprintf('%s_t%.4f_k%d.%s',FileName(1:end-l_EXT-1),tvalue,size_k,EXT);
            NewName2 = sprintf('%s_t%.4f_k%d_allvox.%s',FileName(1:end-l_EXT-1),tvalue,size_k,EXT);
            NewName3 = sprintf('%s_t%.4f_k%d_inv.%s',FileName(1:end-l_EXT-1),tvalue,size_k,EXT);
    end
    
    if isempty(NewName)
        NewName = sprintf('%s_filtered.%s',FileName(1:end-l_EXT-1),EXT);
        NewName2 = sprintf('%s_filtered_allvox.%s',FileName(1:end-l_EXT-1),EXT);
        NewName3 = sprintf('%s_filtered_inv.%s',FileName(1:end-l_EXT-1),EXT);
    elseif ~strcmp(NewName(end-l_EXT+1:end),EXT)
        NewName = strcat(NewName,'.',EXT);
        NewName2 = strcat(NewName2,'.',EXT);
        NewName3 = strcat(NewName3,'.',EXT);
    end
    disp(sprintf('\n --> Saving results to ''%s''',NewName));
    disp(sprintf(' --> in ''%s''',PathName));
    NewName = fullfile(PathName,NewName);
    NewName2 = fullfile(PathName,NewName2);
    NewName3 = fullfile(PathName,NewName3);

    v.fname = NewName;    
    v2 = v;
    v2.fname = NewName2;
    v3 = v;
    v3.fname = NewName3;


disp('---------------------------------------------------------------');

tic;
im_map_t = m > u; % logical: 1 = activated voxel; 0 = non-activated voxel
im_map_k = zeros(size(im_map_t));

fprintf('\n\nLooking for clusters of k >= %d ...\n\n',size_k);

CC18 = bwconncomp(im_map_t,18);
n_clusters = CC18.NumObjects;
STATS = regionprops(CC18,'Area');


size_clusters = zeros(n_clusters,1);
for i = 1:n_clusters
    size_clusters(i,1) = STATS(i,1).Area;
end
clusters_to_keep = find(size_clusters >= size_k);
clusters_to_delete = find(size_clusters < size_k);

n_clusters = length(clusters_to_keep);
n_clusters_delete = length(clusters_to_delete);

fprintf('Found n = %d clusters.\n\n',n_clusters);

fprintf('   id   |        k        \n');
fprintf('--------|-----------------\n');
for i_cluster = 1:n_clusters
    n_vox_cluster = size_clusters(clusters_to_keep(i_cluster));
    fprintf('   %2d   |      %d \n',i_cluster,n_vox_cluster);
    if i_cluster == n_clusters
        fprintf('\n');
    end
end
    



CC18_k = CC18;
CC18_k.NumObjects = n_clusters;
PixelIdxList = cell(1,n_clusters);
for i = 1:n_clusters
    PixelIdxList{1,i} = CC18_k.PixelIdxList{1,clusters_to_keep(i)};
end
CC18_k.PixelIdxList = PixelIdxList;

im_map_k = labelmatrix(CC18_k) > 0;

toc;


CC18_kinv = CC18;
CC18_kinv.NumObjects = n_clusters_delete ;
PixelIdxList = cell(1,n_clusters_delete );
for i = 1:n_clusters_delete 
    PixelIdxList{1,i} = CC18_kinv.PixelIdxList{1,clusters_to_delete(i)};
end
CC18_kinv.PixelIdxList = PixelIdxList;

im_map_kinv = labelmatrix(CC18_kinv) > 0;

toc;

disp(sprintf('\nFINISHED.'));

if nargin == 0
    m2 = m;
    m3 = m;
    % save file to disk:
    I = find(im_map_k == 0);
    m(I) = 0;
    spm_write_vol(v,m);
    % save file to disk:
    I = find(im_map_k == 0 & im_map_t);
    m2(I) = 0;
    spm_write_vol(v2,m2);
    
    % save file to disk:
    I = find(im_map_kinv == 0);
    m3(I) = 0;
    spm_write_vol(v3,m3);

end

end
