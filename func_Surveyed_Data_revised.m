% Survey Data Table

function [Surveyed_Data_Cell_Measurement_Rated,Desired_Columns_Titles_Indecies] = func_Surveyed_Data_revised(Surveyed_Data_Cell_Raw)
%% Finding Blank Values and Generate a Modified Version of the Cell

% the Cell ---> Surveyed_Data_Cell
Surveyed_Data_Cell = Surveyed_Data_Cell_Raw (1,:); %Exctracting the header titles from the raw table.


% The second row in the original the raw table consists of terms meaning
% maximum number of charaters(string), e.g. 15s, 4s, etc. which are 
% redundant. The following line is for extracting all content of the
% original raw table except its second row. 
%Surveyed_Data_Cell_Raw = [ Surveyed_Data_Cell_Raw(1,:) ; Surveyed_Data_Cell_Raw(3:end,:) ];

%%
% Finding the index of the columns of "gage_height_va","chan_discharge",
% "chan_width","chan_velocity", and "chan_area" from the cell of header titles. 

[num_row_titles,num_col_titles] = size(Surveyed_Data_Cell);

i=1;

for i_col_titles = 1:num_col_titles
 
    switch Surveyed_Data_Cell{1,i_col_titles}
        
        case 'gage_height_va'
        Desired_Columns_Titles_Indecies{1,i} = 'gage_height_va';
        Desired_Columns_Titles_Indecies{2,i} = i_col_titles;
        i = i + 1;
        
        case 'chan_discharge'
        Desired_Columns_Titles_Indecies{1,i} = 'chan_discharge';
        Desired_Columns_Titles_Indecies{2,i} = i_col_titles;
        i = i + 1;
        
        case 'chan_width'
        Desired_Columns_Titles_Indecies{1,i} = 'chan_width';
        Desired_Columns_Titles_Indecies{2,i} = i_col_titles;
        i = i + 1;
        
        case 'chan_velocity'
        Desired_Columns_Titles_Indecies{1,i} = 'chan_velocity';
        Desired_Columns_Titles_Indecies{2,i} = i_col_titles;
        i = i + 1;
        
        case 'chan_area'
        Desired_Columns_Titles_Indecies{1,i} = 'chan_area';
        Desired_Columns_Titles_Indecies{2,i} = i_col_titles;  
        i = i + 1;
        
    end

end    % Desired_Columns_Titles_Indecies %%%% is output

%%
% Eliminating rows containing BLANK or NaN values in 
% columns of "gage_height_va","chan_discharge","chan_width","chan_velocity"
% , and "chan_area" from the original cell, i.e. "Surveyed_Data_Cell_Raw". 
[num_row,num_col] = size(Surveyed_Data_Cell_Raw);
for i_row = 2:num_row
    
    for i_col_titles = 1:size(Desired_Columns_Titles_Indecies,2)
        
        if strcmp('', Surveyed_Data_Cell_Raw(i_row,Desired_Columns_Titles_Indecies{2,i_col_titles})) == 1 
            
           break;
            
        elseif i_col_titles == size(Desired_Columns_Titles_Indecies,2)
            
           Surveyed_Data_Cell = [ Surveyed_Data_Cell ; Surveyed_Data_Cell_Raw(i_row,:)];
             
        end
        
    end
    
end

%%
% Extracting rows containing data associated with "GOOD" and "FAIR" types
% of measurement, considering column of "measured_rating_diff". 
[num_row,num_col] = size(Surveyed_Data_Cell);

%Finding the index of column titled as 'measured_rating_diff'
i=1;
for i_col_titles = 1:num_col
   
    if strcmp('measured_rating_diff',Surveyed_Data_Cell{1,i_col_titles}) == 1
        
        Measurement_Rating_Titles_Indecies{1,i} = 'measured_rating_diff';
        Measurement_Rating_Titles_Indecies{2,i} = i_col_titles; 
        
    end
    
end

Surveyed_Data_Cell_Measurement_Rated_1 = Surveyed_Data_Cell(1,:);
for i_row = 2:num_row
    
        if strcmp('GOOD', Surveyed_Data_Cell(i_row,Measurement_Rating_Titles_Indecies{2,1})) == 1 || strcmp('FAIR', Surveyed_Data_Cell(i_row,Measurement_Rating_Titles_Indecies{2,1})) == 1
            
           Surveyed_Data_Cell_Measurement_Rated_1 = [ Surveyed_Data_Cell_Measurement_Rated_1 ; Surveyed_Data_Cell(i_row,:)];
                    
        end
        
end

Surveyed_Data_Cell_Measurement_Rated = Surveyed_Data_Cell_Measurement_Rated_1;

%{
%% Considering column of "meas_type", extracting rows containing data not 
% including "UNSP", "BRUS", "BRDS", "ICE", "OTHR", and "CRAN".

[num_row,num_col] = size(Surveyed_Data_Cell_Measurement_Rated_1);

%Finding the index of column titled as 'meas_type'
i=1;
for i_col_titles = 1:num_col
   
    if strcmp('meas_type',Surveyed_Data_Cell_Measurement_Rated_1{1,i_col_titles}) == 1
        
        Measurement_Type_Titles_Indecies{1,i} = 'meas_type';
        Measurement_Type_Titles_Indecies{2,i} = i_col_titles; 
        
    end
    
end

Surveyed_Data_Cell_Measurement_Rated = Surveyed_Data_Cell_Measurement_Rated_1(1,:);
for i_row = 2:num_row
    
        if strcmp('WADE', Surveyed_Data_Cell_Measurement_Rated_1(i_row,Measurement_Type_Titles_Indecies{2,1})) == 1 ...
                || strcmp('CWAY', Surveyed_Data_Cell_Measurement_Rated_1(i_row,Measurement_Type_Titles_Indecies{2,1})) == 1  ...
                || strcmp('MBOT', Surveyed_Data_Cell_Measurement_Rated_1(i_row,Measurement_Type_Titles_Indecies{2,1})) == 1  ...
                || strcmp('SBOT', Surveyed_Data_Cell_Measurement_Rated_1(i_row,Measurement_Type_Titles_Indecies{2,1})) == 1  ...
                || strcmp('RC', Surveyed_Data_Cell_Measurement_Rated_1(i_row,Measurement_Type_Titles_Indecies{2,1})) == 1  ...
                || strcmp('BOAT', Surveyed_Data_Cell_Measurement_Rated_1(i_row,Measurement_Type_Titles_Indecies{2,1})) == 1 
            
           Surveyed_Data_Cell_Measurement_Rated = [ Surveyed_Data_Cell_Measurement_Rated ; Surveyed_Data_Cell_Measurement_Rated_1(i_row,:)];
                    
        end
        
end

%}
end