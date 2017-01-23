function [Max_Water_Year_Discharge_Sorted_cell_2,...
    BankFull_Discharge,Inxd_bankfull] = ...
    func_FloodFreq_Bankfull_Analysis_Daily_Data_StandAlone(...
    Discharge_GageHeight_Cell_Proper,X_exploratory,...
    Freq_Factors_K_Gamma_logPearsonTypeIII_Table,...
    computation_unit,...
    output_directory_floodfreq_plots)


%% Flood Analysis with Daily Data (Log-Perason Type III Distribution)
% Plotting Recurrence Curves
% Capturing Bankfull Discharge

%% 1) Classification of Fulltimes series of USGS-Daily Data
%
% Section (1) is adopted from "HQ_Proper_Daily_Data_Management_Main.m" script
% which return "Final_Table_of_Indices" array containing the index of
% discharge-stageheight daily data records for each yearly periods, e.g.
% 1990-1991, 1991-1992, etc. This section can be omitted if the associated
% table has already created for a specific site and one may proceed to the
% next sections. (This Comment Should be Modified because of the
% modification of "HQ_Proper_Daily_Data_Management_Main.m")

USGS_site_no_string = Discharge_GageHeight_Cell_Proper{2,2};

%% 2) Calculate the mean, minimum, and maximum discharge for each water year in the period of record.

for i = 2:size(Discharge_GageHeight_Cell_Proper,1)
    % Water Year
    Water_Year_Discharge_cell{i,1} = Discharge_GageHeight_Cell_Proper{i,3}; 
end
clear i String_Value_1

%% 3-1) Rank the data from largest discharge and Stage-Height to smallest discharge.

% Discharge record
Max_Water_Year_Discharge_Sorted_cell_title = {'Rank','Water_Year','Max_Discharge'};
Max_Water_Year_Discharge = X_exploratory;
Indx_Max_Water_Year_Discharge = ...
    find(~isnan(Max_Water_Year_Discharge)>0);
[Max_Water_Year_Discharge_Sorted , Indx_Max_Water_Year_Discharge_2] = ...
    sort(Max_Water_Year_Discharge(Indx_Max_Water_Year_Discharge),1,'descend');
Indx_Max_Water_Year_Discharge_Sorted = ...
    Indx_Max_Water_Year_Discharge(Indx_Max_Water_Year_Discharge_2);
clear Indx_Max_Water_Year_Discharge Indx_Max_Water_Year_Discharge_2
Max_Water_Year_Discharge_Sorted_cell(:,1) = num2cell(1:length(Max_Water_Year_Discharge_Sorted));
Max_Water_Year_Discharge_Sorted_cell(:,2) = Water_Year_Discharge_cell(...
    Indx_Max_Water_Year_Discharge_Sorted+1,1);
Max_Water_Year_Discharge_Sorted_cell(:,3) = num2cell(Max_Water_Year_Discharge_Sorted);
Max_Water_Year_Discharge_Sorted_cell = [Max_Water_Year_Discharge_Sorted_cell_title;...
Max_Water_Year_Discharge_Sorted_cell];
clear Max_Water_Year_Discharge_Sorted_cell_title Indx_Max_Water_Year_Discharge_Sorted ...
    Max_Water_Year_Discharge_Sorted

%% 3-2) Create a column with the log of each max or peak streamflow

% Discharge
Max_Water_Year_Discharge_Sorted_cell{1,4} = 'Log_Max_Discharge';
Max_Water_Year_Discharge_Sorted_cell(2:end,4) = ...
    num2cell(log10(cell2mat(Max_Water_Year_Discharge_Sorted_cell(2:end,3))));

%% 3-3) Create a column with the return period (Tr) for each discharge and Stage-Heigth

% Discharge
Max_Water_Year_Discharge_Sorted_cell{1,5} = 'Return_Period';
Max_Water_Year_Discharge_Sorted_cell(2:end,5) = ...
    num2cell((length(X_exploratory)+1)./cell2mat(...
    Max_Water_Year_Discharge_Sorted_cell(2:end,1)));

%% 3-4) Create a column with the exceedence probability for each discharge and Stage-Heigth

% Discharge
Max_Water_Year_Discharge_Sorted_cell{1,6} = 'Exceedence_Probability';
Max_Water_Year_Discharge_Sorted_cell(2:end,6) = ...
    num2cell(1./cell2mat(...
    Max_Water_Year_Discharge_Sorted_cell(2:end,5)));

%% 4-1) Calculating Mean, Standard Deviation, and Skewness of Log()

% Discharge
Mean_Max_Water_Year_Discharge_Sorted = mean(cell2mat(...
    Max_Water_Year_Discharge_Sorted_cell(2:end,4)));
StD_Max_Water_Year_Discharge_Sorted = std(cell2mat(...
    Max_Water_Year_Discharge_Sorted_cell(2:end,4)));
SkewnessCoeff_Max_Water_Year_Discharge_Sorted = ...
    skewness(cell2mat(Max_Water_Year_Discharge_Sorted_cell(2:end,4)),0);

%% 4-2) Use the frequency factor table and the skew coefficient to find the k values
%       for the 2,5,10,25,50,100, and 200 recurrence intervals

% Discharge
if SkewnessCoeff_Max_Water_Year_Discharge_Sorted > ...
        Freq_Factors_K_Gamma_logPearsonTypeIII_Table{2,1}
    
    Freq_Factors_K_Gamma_logPearsonTypeIII_Table_2 = zeros(1,...
        size(Freq_Factors_K_Gamma_logPearsonTypeIII_Table,2));
    Freq_Factors_K_Gamma_logPearsonTypeIII_Table_2(1,1) = ...
        SkewnessCoeff_Max_Water_Year_Discharge_Sorted;
    for j = 2:size(Freq_Factors_K_Gamma_logPearsonTypeIII_Table,2)
        Freq_Factors_K_Gamma_logPearsonTypeIII_Table_2(1,j) = ...
            pchip(cell2mat(Freq_Factors_K_Gamma_logPearsonTypeIII_Table(2:end,1)),...
            cell2mat(Freq_Factors_K_Gamma_logPearsonTypeIII_Table(2:end,j)),...
            SkewnessCoeff_Max_Water_Year_Discharge_Sorted);
    end
    Freq_Factors_K_Gamma_logPearsonTypeIII_Table = [...
        Freq_Factors_K_Gamma_logPearsonTypeIII_Table(1,:)
        num2cell(Freq_Factors_K_Gamma_logPearsonTypeIII_Table_2);
        Freq_Factors_K_Gamma_logPearsonTypeIII_Table(2:end,:)];
    FirstIndex_Discharge = find(SkewnessCoeff_Max_Water_Year_Discharge_Sorted<=...
        cell2mat(Freq_Factors_K_Gamma_logPearsonTypeIII_Table(...
        2:end,1)), 1, 'last')+1; % 1 is added because the heading is excluded.
    NextIndex_Discharge = FirstIndex_Discharge + 1;
    
elseif SkewnessCoeff_Max_Water_Year_Discharge_Sorted < ...
        Freq_Factors_K_Gamma_logPearsonTypeIII_Table{end,1}
    
    Freq_Factors_K_Gamma_logPearsonTypeIII_Table_2 = zeros(1,...
        size(Freq_Factors_K_Gamma_logPearsonTypeIII_Table,2));
    Freq_Factors_K_Gamma_logPearsonTypeIII_Table_2(1,1) = ...
        SkewnessCoeff_Max_Water_Year_Discharge_Sorted;
    for j = 2:size(Freq_Factors_K_Gamma_logPearsonTypeIII_Table,2)
        Freq_Factors_K_Gamma_logPearsonTypeIII_Table_2(1,j) = ...
            pchip(cell2mat(Freq_Factors_K_Gamma_logPearsonTypeIII_Table(2:end,1)),...
            cell2mat(Freq_Factors_K_Gamma_logPearsonTypeIII_Table(2:end,j)),...
            SkewnessCoeff_Max_Water_Year_Discharge_Sorted);
    end
    Freq_Factors_K_Gamma_logPearsonTypeIII_Table = [...
        Freq_Factors_K_Gamma_logPearsonTypeIII_Table;...
        num2cell(Freq_Factors_K_Gamma_logPearsonTypeIII_Table_2)];
    FirstIndex_Discharge = find(SkewnessCoeff_Max_Water_Year_Discharge_Sorted<=...
        cell2mat(Freq_Factors_K_Gamma_logPearsonTypeIII_Table(...
        2:end,1)), 1, 'last')+1; % 1 is added because the heading is excluded.
    FirstIndex_Discharge = FirstIndex_Discharge - 1;
    NextIndex_Discharge = FirstIndex_Discharge + 1;
    
else
    
    FirstIndex_Discharge = find(SkewnessCoeff_Max_Water_Year_Discharge_Sorted<=...
        cell2mat(Freq_Factors_K_Gamma_logPearsonTypeIII_Table(...
        2:end,1)), 1, 'last')+1; % 1 is added because the heading is excluded.
    NextIndex_Discharge = FirstIndex_Discharge + 1;
    
end

Freq_Factors_K_Gamma_logPearsonTypeIII_Table_Practical_title = {'Return_Period',...
    ['K(' num2str(Freq_Factors_K_Gamma_logPearsonTypeIII_Table{...
    NextIndex_Discharge,1}) ')'],['K(' num2str(Freq_Factors_K_Gamma_logPearsonTypeIII_Table{...
    FirstIndex_Discharge,1}) ')'],['K(' num2str(SkewnessCoeff_Max_Water_Year_Discharge_Sorted) ')']};

Freq_Factors_K_Gamma_logPearsonTypeIII_Table_Practical_Dsch(:,1) = ...
    Freq_Factors_K_Gamma_logPearsonTypeIII_Table(1,2:end)';
Freq_Factors_K_Gamma_logPearsonTypeIII_Table_Practical_Dsch(:,2) = ...
    Freq_Factors_K_Gamma_logPearsonTypeIII_Table(NextIndex_Discharge,2:end)';
Freq_Factors_K_Gamma_logPearsonTypeIII_Table_Practical_Dsch(:,3) = ...
    Freq_Factors_K_Gamma_logPearsonTypeIII_Table(FirstIndex_Discharge,2:end)';

Cs_A = cell2mat(Freq_Factors_K_Gamma_logPearsonTypeIII_Table(FirstIndex_Discharge,...
    1));
Cs_B = SkewnessCoeff_Max_Water_Year_Discharge_Sorted;
Cs_C = cell2mat(Freq_Factors_K_Gamma_logPearsonTypeIII_Table(NextIndex_Discharge,...
    1));
K_A = cell2mat(Freq_Factors_K_Gamma_logPearsonTypeIII_Table(FirstIndex_Discharge,...
    2:end));
K_C = cell2mat(Freq_Factors_K_Gamma_logPearsonTypeIII_Table(NextIndex_Discharge,...
    2:end));
K_B = K_A-((Cs_A-Cs_B)/(Cs_A-Cs_C))*(K_A-K_C);

Freq_Factors_K_Gamma_logPearsonTypeIII_Table_Practical_Dsch(:,4) = num2cell(K_B');
Freq_Factors_K_Gamma_logPearsonTypeIII_Table_Practical_Dsch = [...
    Freq_Factors_K_Gamma_logPearsonTypeIII_Table_Practical_title;...
    Freq_Factors_K_Gamma_logPearsonTypeIII_Table_Practical_Dsch];

Max_Water_Year_Discharge_Sorted_cell_2(:,1) = ...
    Freq_Factors_K_Gamma_logPearsonTypeIII_Table_Practical_Dsch(:,1);
Max_Water_Year_Discharge_Sorted_cell_2(:,2) = ...
    Freq_Factors_K_Gamma_logPearsonTypeIII_Table_Practical_Dsch(:,4);
Max_Water_Year_Discharge_Sorted_cell_2(:,3) = ...
    ['Discharge'; num2cell(10.^(Mean_Max_Water_Year_Discharge_Sorted+...
    cell2mat(Freq_Factors_K_Gamma_logPearsonTypeIII_Table_Practical_Dsch(2:end,4))*...
    StD_Max_Water_Year_Discharge_Sorted))];

clear Cs_A Cs_B Cs_C K_A K_C K_B FirstIndex_Discharge NextIndex_Discharge...
    Freq_Factors_K_Gamma_logPearsonTypeIII_Table_Practical_title ...
    Freq_Factors_K_Gamma_logPearsonTypeIII_Table_Practical_Dsch ...
    Mean_Max_Water_Year_Discharge_Sorted ...
    StD_Max_Water_Year_Discharge_Sorted ...
    SkewnessCoeff_Max_Water_Year_Discharge_Sorted

%% 5) log-log plotting

% Assigning Computational Unit
switch computation_unit    
    case 'English'
        unit_conv_fact = 1;
        label_y0 = 'Discharg [ft^3/s]';
        label_y = 'Discharg [ {ft^3}/s ]';
    case 'SI'
        unit_conv_fact = 0.028316847;
        label_y0 = 'Discharg [m^3/s]';
        label_y = 'Discharg [ {m^3}/s ]';
end

all_figs = figure;
set(all_figs ,'visible','off');
loglog(cell2mat(Max_Water_Year_Discharge_Sorted_cell_2(2:end,1)),...
    unit_conv_fact*cell2mat(Max_Water_Year_Discharge_Sorted_cell_2(2:end,3)),'b-',...
    'LineWidth',2,'Marker','.','MarkerSize',10)
String_Value_startdate = strread(Water_Year_Discharge_cell{2,1},'%s','delimiter','/');
String_Value_enddate = strread(Water_Year_Discharge_cell{end,1},'%s','delimiter','/');
title({'Flood Frequency Analysing, Using Log-Pearson Type III';...
    ['USGS Site No. ',USGS_site_no_string,', ' strjoin(['Water Years: ',String_Value_startdate(3,1),'-',...
    String_Value_enddate(3,1)])]},'FontSize',16);
xlabel('Return Period [ year ]','FontSize',15);
ylabel(label_y,'FontSize',15);
set(gca,'FontSize',14);

grid on

output_fileName = strcat([output_directory_floodfreq_plots  '\' ...
    USGS_site_no_string '_usgs_site_floodfreq_disch']);

orient landscape
print(all_figs,'-dpdf',output_fileName)
close(all_figs);
clear all_figs

%% 6) Capturing Bank-Full Discharge or Stage-Height

BankFull_Discharge = interp1(cell2mat(Max_Water_Year_Discharge_Sorted_cell_2(2:end,1)),...
  cell2mat(Max_Water_Year_Discharge_Sorted_cell_2(2:end,3)),1.5,'spline' );
Inxd_bankfull = find(X_exploratory<=BankFull_Discharge);

BankFull_Discharge = unit_conv_fact*BankFull_Discharge;
Max_Water_Year_Discharge_Sorted_cell_2{1,end} = label_y0;
Max_Water_Year_Discharge_Sorted_cell_2(2:end,end) = num2cell(unit_conv_fact*...
    cell2mat(Max_Water_Year_Discharge_Sorted_cell_2(2:end,end)));
