% Buscar filas y columnas dentro de una base de datos subministrada

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [name_file, name_var] = search_database(subjects_input,path_out)

disp('---------------------------------------------------------------')
[file_database,path_database] = uigetfile({'*.xlsx';'*.csv'});
if isequal(file_database,0)
    disp('\n User selected Cancel')
else
    disp(['\n User selected: ', fullfile(path_database, file_database)])
end

if strfind(file_database,'.xlsx') > 1
    disp('\n Database xlsx detect!');
else
    if strfind(file_database,'.csv') > 1
        disp('\n Database csv detect!');
    else
        disp('\n Database not supported');
    end
end

T = readtable(file_database);
sel_col = input('\n Add name of the column: ','s');
[rows, columns] = size(T);

col_val = 1;
variable_exit = 0;
aux1 = 1;
aux2 = 1;
aux3 = 0;
aux4 = 0;

while col_val == 1
    for x = 1 : columns
        names_header = T.Properties.VariableNames{x};
        if string(sel_col) == string(names_header)
            index_var(aux2) = x ;
            variable_exit = 1;
            disp(sel_col);
        end
    end
    variable_database(aux1) = string(sel_col);
    if variable_exit == 0
        sel_col = input('\n The variable no exist!, Write the name of the variable or exit: ','s');
    end
    sel_col = input('\n Add name of the column or exit for finish: ','s');
    aux1 = aux1 + 1;
    aux2 = aux2 + 1;
    if sel_col == "exit"
        col_val = 0;
    end
end

%Create database new with patientes and variables

if (nargin == 0)
    subj = input("\n Add IDs or variable of patients: ");
elseif nargin ~= 0
    subj = subjects_input;
    ids_variable = input('\n Add the column where IDs are located: ');
end

[rowsubj,columnsubj] = size(subj);
index_var = [ids_variable index_var];

for y = 1 : rowsubj
    for z = 1 : rows
        if subj(y,1) == string(T{z,ids_variable})
            for indx = 1 : length(index_var)
                miss = ismissing(string(T{z,T.Properties.VariableNames{index_var(indx)}}));
                if miss ~= 1
                    if string(T{z,T.Properties.VariableNames{index_var(indx)}}) ~= ""
                        var1(y,indx) = string(T{z,T.Properties.VariableNames{index_var(indx)}});
                    else
                        aux4 = aux4 + 1;
                        aux3(aux4) = y;
                    end
                else
                    aux4 = aux4 + 1;
                    aux3(aux4) = y;
                end
            end
        end
    end
end

str_names = '';
str_names2 = ''; 
for ii = 0 : length(variable_database) - 1
    str_names = strcat(str_names,' %s ');
    str_names2 = strcat(str_names2,'%s_');
end

name_file = strcat(sprintf(str_names2,variable_database),'.txt');
name_var = variable_database;

miss_data = input('Data is missing, do you want to delete it (d) or keep it (k)?: ','s');
if miss_data == 'd'
    if aux3 == 0
        disp('Not delete')
    else
        var1(aux3',:) = [];
    end
else
    var1 = var1;
end

summary_database = var1;

writematrix(summary_database,strcat(path_out,'/',name_file));

end

