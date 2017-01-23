function handle = func_conversion_Surveyed_Data_to_mat_file_StandAlone(site_no,starting_path)

%% Examples to be applied for the inputs
%%% Site No.
% site_no = '02465000';
%%% Building up the URL
%% Required functions and tables:
%%% copying a temporary version of 'tdfread_Modi function' file to 
%%% 'Imported_USGS_Data' directory. 
copyfile('tdfread_Modi.m',fullfile(starting_path,'Imported_USGS_Data'))
%% Importing the USGS Surveyed Data as *.TXT file into working directory
%%% select directory for saving surveyed data, OUTPUTS'
cd('Imported_USGS_Data') % Directory for storing USGS data
output_directory_name = pwd;
url = strcat('https://nwis.waterdata.usgs.gov/nwis/measurements?',...
    'site_no=',site_no,'&agency_cd=USGS&format=rdb_expanded');
options = weboptions('ContentType','text');
% filename = '/Users/shahab/Documents/MATLAB/MatlabCodes/Paper-MultiInundationModelComparison/dd.txt';
filename = 'example.txt';
%%% Saving the USGS/NWIS tab-separated daily data table as *.TXT file
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
%%%% Checking if the imported data are out of problems or errors
if strcmp(dataArray_dum{1,1}(1,1:10),'<link rel=')
    handle = 0;
    delete('example.txt');delete('tdfread_Modi.m');
    error('The current USGS station does not have field surveyed data.')
else
    handle = 1;
end

USGS_Surveyed_Data = tdfread_Modi(filename,'tab');
field_names = fieldnames(USGS_Surveyed_Data);
num_fields = size(fieldnames(USGS_Surveyed_Data),1);
Surveyed_Data_Cell_Raw = ...
    cell(size(USGS_Surveyed_Data.Var1,1),num_fields);

if num_fields == 1
    handle = 0;
    delete('example.txt');delete('tdfread_Modi.m');
    error('There are not enough field avaiable for the imported data associated with the current USGS station')
else
    handle = 1;
end


for num_col = 1:num_fields
    
    struct_field_name = field_names(num_col,1);
    
    Surveyed_Data_Cell_Raw{1,num_col} = ...
        regexprep(USGS_Surveyed_Data.(...
        struct_field_name{1,1})(1,:),'\W','');
    
    switch Surveyed_Data_Cell_Raw{1,num_col}
        
        case  'measurement_nu'
            
            measurement_nu_header_index = num_col;
            
        case  'gage_height_va'
            
            gage_height_va_header_index = num_col;
            
        case  'current_rating_nu'
            
            current_rating_nu_header_index = num_col;
            
        case 'chan_discharge'
            
            chan_discharge_header_index = num_col;
            
        case 'chan_width'
            
            chan_width_header_index = num_col;
            
        case 'chan_area'
            
            chan_area_header_index = num_col;
            
        case 'chan_velocity'
            
            chan_velocity_header_index = num_col;
            
        case 'measurement_dt'
            
            measurement_dt_header_index = num_col;
            
    end
    
end

double_column_indecies = [measurement_nu_header_index,...
    gage_height_va_header_index,current_rating_nu_header_index,...
    chan_discharge_header_index,...
    chan_width_header_index,...
    chan_area_header_index,chan_velocity_header_index];

for num_col = 1:num_fields
    
    struct_field_name = field_names(num_col,1);
    
    for num_row = 2:size(USGS_Surveyed_Data.Var1,1)
        
        if num_col == gage_height_va_header_index || ...
                num_col == chan_discharge_header_index || ...
                num_col == chan_width_header_index || ...
                num_col == chan_area_header_index || ...
                num_col == chan_velocity_header_index
            
            Surveyed_Data_Cell_Raw{num_row,num_col} = ...
                str2double(USGS_Surveyed_Data.(...
                struct_field_name{1,1})(num_row,:));
            
            if isnan(Surveyed_Data_Cell_Raw{num_row,num_col}) == 1
                
                Surveyed_Data_Cell_Raw{num_row,num_col} = '';
                
            end
            
            
        else
            
            if  num_col == measurement_dt_header_index
                
                struct_field_name_datetime = field_names(measurement_dt_header_index,1);
                
                Date_Vector = datevec(USGS_Surveyed_Data.(...
                    struct_field_name_datetime{1,1})(num_row,:),'yyyy-mm-dd');
                
                Surveyed_Data_Cell_Raw{num_row,4} = ...
                    datestr(USGS_Surveyed_Data.(...
                    struct_field_name_datetime{1,1})(num_row,:),'mm/dd/yyyy');
                
            else
                
                Surveyed_Data_Cell_Raw{num_row,num_col} = ...
                    regexprep(USGS_Surveyed_Data.(...
                    struct_field_name{1,1})(num_row,:),'\W','');
                
                %                             Surveyed_Data_Cell_Raw{num_row,num_col} = ...
                %                                 struct_field_name{1,1};
                
            end
            
        end
        
    end
    
end

output_fileName = strcat(site_no,'_Surveyed_Data','.mat');

%use that when you save
matfile = fullfile(output_directory_name, output_fileName);
save(matfile,'Surveyed_Data_Cell_Raw');

fprintf('%s, been succesfully saved. \n',output_fileName);
%%%%%%%%%%%%%%%%%
delete('example.txt');delete('tdfread_Modi.m');
cd(starting_path)
end