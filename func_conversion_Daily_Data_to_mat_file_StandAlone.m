function handle = func_conversion_Daily_Data_to_mat_file_StandAlone(site_no,starting_path,computation_unit)
%% Examples to be applied for the inputs
%%% Site No.
% site_no = '02465000';
%% Required functions and tables:
%%% loading 'Freq_Factors_K_Gamma_logPearsonTypeIII_Table'
load('Freq_Factors_K_Gamma_logPearsonTypeIII_Table')
%%% copying a temporary version of 'tdfread_Modi function' file to 
%%% 'Imported_USGS_Data' directory. 
copyfile('tdfread_Modi.m',fullfile(starting_path,'Imported_USGS_Data'))
%% Importing the USGS Daily Data as *.TXT file into working directory
%%% select directory for saving flood frequency curves and daily peakflow data, OUTPUTS'
cd('Imported_USGS_Data') % Directory for storing USGS data
output_directory_name = pwd;
%%% Building up the URL
url = strcat('https://nwis.waterdata.usgs.gov/nwis/peak?',...
    'site_no=',site_no,'&agency_cd=USGS&format=rdb');
options = weboptions('ContentType','text');
filename = 'example.txt';
%%% Saving the USGS/NWIS tab-separated daily data table as *.TXT file
% outfilename = websave(strcat(output_directory_name,'/',filename),url,options);
outfilename = websave(filename,url,options);
%%%%%%%%%%%%%%%%%%%%%%%%
%% Importing the USGS Daily Data (saved as *.TXT) for further analysis
%%% Format for each line of text:
%   column1: text (%s)
formatSpec = '%s%[^\n\r]';
%%% Finding the headear line (first line after #) and ending line
% Open the text file.
fileID = fopen(outfilename,'r');
tline = fgets(fileID);
startRow = 0;
endRow = 0;
while ischar(tline)
    %disp(tline)
    if ~isempty(strfind(tline,'#'))
        startRow = startRow+1;
        endRow = endRow+1;
        tline = fgets(fileID);
    else
        tline = fgetl(fileID);
        endRow = endRow+1;
    end
end
fclose(fileID);
%%% Read columns of data according to the format.
delimiter = '';
fileID = fopen(outfilename,'r');
dataArray = textscan(fileID, formatSpec,...
    'Delimiter', delimiter,...
    'MultipleDelimsAsOne', true,...
    'HeaderLines' ,startRow,...
    'ReturnOnError', false,...
    'EndOfLine', '\r\n');
dataArray(:,end) = [];

%%%% Check if the data exists
if size(dataArray{1,1},1)<2
    handle = 0;
    delete('example.txt');delete('tdfread_Modi.m');
    cd(starting_path)
    fclose(fileID);
    error(sprintf('No sites/data found using the selection criteria specified. \n Check for the validity of the inputs, e.g. the applied USGS station site number.'))
else
    handle = 1;
    dataArray_dum = dataArray{1,1};
    dataArray_dum(2,:) = [];
fclose(fileID);
end
%%%%

fid = fopen('example.txt','w');
[rows,cols] = size(dataArray_dum);
x = repmat('%s',1,(cols-1+1));
for row = 1:rows
    fprintf(fid,[x,'\n'],dataArray_dum{row,:}');
end
clear rows cols outfilename
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Directory containing the 'tdfread_Modi.m' function
% cd(starting_path)
USGS_Daily_Data = tdfread_Modi(filename,'tab');
field_names = fieldnames(USGS_Daily_Data);
num_fields = size(fieldnames(USGS_Daily_Data),1);
Discharge_GageHeight_Cell_Raw = ...
    cell(size(USGS_Daily_Data.Var1,1),num_fields);

if num_fields == 1
    handle = 0;
    delete('example.txt');delete('tdfread_Modi.m');
    error('There are not enough field avaiable for the imported data associated with the current USGS station')
else
    handle = 1;
end

%%%%%
Discharge_peak_cd_index = [];
Discharge_peak_index = [];

GageHeight_peak_cd_index = [];
GageHeight_peak_index = [];

for num_col = 1:num_fields
    
    struct_field_name = field_names(num_col,1);
    
    Discharge_GageHeight_Cell_Raw{1,num_col} = ...
        regexprep(USGS_Daily_Data.(...
        struct_field_name{1,1})(1,:),'\W','');
    
    switch Discharge_GageHeight_Cell_Raw{1,num_col}
        
        case  'agency_cd'
            
            agency_cd_header_index = num_col;
            
        case  'site_no'
            
            site_no_header_index = num_col;
            
        case  'peak_dt'
            
            peak_dt_header_index = num_col;
            
        otherwise
                       
            % Peak Discharge
            Discharge_peak_cd_index_1(1,num_col) = strfind(...
                Discharge_GageHeight_Cell_Raw(1,num_col),'peak_cd');
            
            if Discharge_peak_cd_index_1{1,num_col} > 0
                
                Discharge_peak_cd_index = [Discharge_peak_cd_index, num_col];
                Discharge_peak_index = [Discharge_peak_index, num_col-1];
                
            end

            % Peak Gage Height
            GageHeight_peak_cd_index_1(1,num_col) = strfind(...
                Discharge_GageHeight_Cell_Raw(1,num_col),'gage_ht_cd');
            
            if GageHeight_peak_cd_index_1{1,num_col} > 0
                
                GageHeight_peak_cd_index = [GageHeight_peak_cd_index, num_col];
                GageHeight_peak_index = [GageHeight_peak_index, num_col-1];
                
            end
            
    end
    
end

if isempty(Discharge_peak_index)  
    error('The imported data of the current USGS station does not contain a field associated with discharge.')  
end

clear Discharge_max_cd_index_1 Discharge_min_cd_index_1
clear Discharge_mean_cd_index_1 GageHeight_max_cd_index_1
clear GageHeight_min_cd_index_1 GageHeight_mean_cd_index_1

type_double_column_indecies = [Discharge_peak_index,...
      GageHeight_peak_index(1)];

%%%%%
struct_field_name_datetime = field_names(peak_dt_header_index,1);
for num_col = 1:num_fields
    
    struct_field_name = field_names(num_col,1);
    
    for num_row = 2:size(USGS_Daily_Data.Var1,1)
        
        if ismember(num_col,type_double_column_indecies)
            
            Discharge_GageHeight_Cell_Raw{num_row,num_col} = ...
                str2double(USGS_Daily_Data.(...
                struct_field_name{1,1})(num_row,:));
            
            if isnan(Discharge_GageHeight_Cell_Raw{num_row,num_col}) == 1
                
                Discharge_GageHeight_Cell_Raw{num_row,num_col} = '';
                
            end
            
        end
        
        if ~ismember(num_col,type_double_column_indecies) && ...
                ~strcmp(struct_field_name_datetime,struct_field_name)
            
            Discharge_GageHeight_Cell_Raw{num_row,num_col} = ...
                regexprep(USGS_Daily_Data.(...
                struct_field_name{1,1})(num_row,:),'\W','');
            
        end
        
        if strcmp(struct_field_name_datetime,struct_field_name)
            
            Date_Vector = datevec(USGS_Daily_Data.(...
                struct_field_name_datetime{1,1})(num_row,:),'yyyy-mm-dd');
            
            Discharge_GageHeight_Cell_Raw{num_row,peak_dt_header_index} = ...
                datestr(USGS_Daily_Data.(...
                struct_field_name_datetime{1,1})(num_row,:),'mm/dd/yyyy');
            
        end
        
    end
    
end

%%% removing rows having empty or '' Discharge values
Discharge_GageHeight_Cell_Raw(strcmp(Discharge_GageHeight_Cell_Raw(:,Discharge_peak_index),''),:) = [];
%%% removing rows having negative Discharge values
Discharge_GageHeight_Cell_Raw(find(cell2mat(Discharge_GageHeight_Cell_Raw(2:end,Discharge_peak_index))<0)+1,:)=[];
if ~isempty(GageHeight_peak_index)
    %%% removing rows having empty or '' Gage-Height values
    Discharge_GageHeight_Cell_Raw(strcmp(Discharge_GageHeight_Cell_Raw(:,GageHeight_peak_index(1)),''),GageHeight_peak_index(1)) = num2cell(NaN);
    %%% removing rows having negative Gage-Height values
    Discharge_GageHeight_Cell_Raw(find(cell2mat(Discharge_GageHeight_Cell_Raw(2:end,GageHeight_peak_index(1)))<0)+1,GageHeight_peak_index(1)) = num2cell(NaN);
end

%%%% Checking if Dicharge values exist 
if size(Discharge_GageHeight_Cell_Raw,1)<3
    handle = 0;
    delete('example.txt');delete('tdfread_Modi.m');
    cd(starting_path)
    error(sprintf('The current USGS station either contains not enough or no discharge records.'))
end
%%%%

%%% Extracting Mean Discharge and Mean Gage-Height Values
X_exploratory = cell2mat(Discharge_GageHeight_Cell_Raw(2:end,...
    Discharge_peak_index));
Y_response = cell2mat(Discharge_GageHeight_Cell_Raw(2:end,...
    GageHeight_peak_index(1)));
Discharge_GageHeight_Cell_Proper = Discharge_GageHeight_Cell_Raw;
index_Unsorted_Discharge_peak = Discharge_peak_index;
index_Unsorted_Gage_Height_peak = GageHeight_peak_index;

output_fileName = strcat(site_no,'_DailyPeaks_Data','.mat');
cd(starting_path)
[Max_Water_Year_Discharge_Sorted_cell,...
    BankFull_Discharge,Inxd_bankfull] = ...
    func_FloodFreq_Bankfull_Analysis_Daily_Data_StandAlone(...
    Discharge_GageHeight_Cell_Proper,X_exploratory,...
    Freq_Factors_K_Gamma_logPearsonTypeIII_Table,...
    computation_unit,...
    output_directory_name);
cd(output_directory_name)
%use that when you save
matfile = fullfile(output_directory_name, output_fileName);
% Assigning Computational Unit
switch computation_unit    
    case 'English'
        X_exploratory = X_exploratory*1;
        Y_response = Y_response*1;
    case 'SI'
        X_exploratory = X_exploratory*0.028316847;
        Y_response = Y_response*0.3048;
end

save(matfile,'Discharge_GageHeight_Cell_Proper',...
    'index_Unsorted_Discharge_peak',...
    'index_Unsorted_Gage_Height_peak',...
    'X_exploratory',...
    'Y_response',...
    'Max_Water_Year_Discharge_Sorted_cell',...
    'BankFull_Discharge',...
    'Inxd_bankfull');

fprintf('%s, been succesfully saved. \n',output_fileName);
%%%%%%%%%%%%%%%%%
delete('example.txt');delete('tdfread_Modi.m');
cd(starting_path)
end

