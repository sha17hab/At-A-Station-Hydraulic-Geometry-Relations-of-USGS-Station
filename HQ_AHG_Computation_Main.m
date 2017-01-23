%
% Author: Shahab Afshari
% Email: safshar00@citymail.cuny.edu
% Civil Engineering Department/Water Resources Program
% City College of New York/City University of New York
% Name: At-A-Station Hydraulic Geometry Relations of USGS Stations 
%
% Description: 
%     Natural streams are characterized by variation in cross-section geometry,
%   bed-slope, bed roughness, hydraulic slope, etc., along their channels
%   resulting from several interacting features of the riverine system including 
%   the effects of discharge changes, geologic context, sediment load, etc. 
%   Quantitative and qualitative assessment of river flow dynamics requires
%   sufficient knowledge of hydraulics and these geophysical variables. 
%
%     Average flow condition theory expressed as ?At-A-Station? hydraulic geometry (AHG)
%   relations are site-specific power-functions, relating the mean stream
%   channel forms (i.e. water depth, top-width, flow velocity, and flow area) to discharge
%
% The Script Introduction:
%     The current script is created for establishing the robust power-law
%     AHG relations at a USGS river monitoring stations. Given a USGS
%     station ID (e.g. '01064118'), sub-sampling size to be applied in
%     Modified Cross-Validation Regression Diagnostic (Afshari et. al.,
%     2017), and computation unit (e.g. 'SI'), a new directory will be automatically
%     created to stored the following products:
%
%     1. MAT files:
%        1.1. {USGS station ID}_DailyPeaks_Data: 
%          1.1.1. BankFull_Discharge: 
%                 Bankfull Flow corresponding to 1.5-year flood event 
%                 based on the specified computation unit.
%          1.1.2. Discharge_GageHeight_Cell_Proper: 
%                 Cell table containing peak stream flow and gage height
%                 records (all in English unit that is the USGS source
%                 unit) and corresponding measurement attributes. It is the
%                 annual maximum instantaneous peak streamflow and gage
%                 height of a USGS station. 
%          1.1.3. index_Unsorted_Discharge_peak and
%                 index_Unsorted_Gage_Height_peak:
%                 Column id of stream flow and gage height records at the  
%                 Discharge_GageHeight_Cell_Proper cell table.
%          1.1.4. X_exploratory and Y_response:
%                 respectively containing stream flow and corresponding gage height
%                 values extracted from Discharge_GageHeight_Cell_Proper
%                 cell table and converted to specified computation unit.
%          1.1.5. Max_Water_Year_Discharge_Sorted_cell:
%                 Cell table containing computed flood years at the USGS
%                 station based on the specified computation unit.
%          1.1.6. Indx_bankfull:
%                 Indicies of within bankfull stage streamflow and gage height
%                 values in X_exploratory and Y_response matricies.
%        1.2. {USGS station ID}_Surveyed_Data:
%          1.2.1. Surveyed_Data_Cell_Raw:
%                 Field Measurment data of a USGS stations 
%        1.3. {USGS station ID}_usgs_site_AHG:
%          1.3.1. USGS_Data_AHG_Table:
%                 Cell table containing USGS site geospatial information,
%                 the estimates of AHG exponent and coefficients, 
%                 estimated shape of bed geometry (power-law exponent), 
%                 full number of field measured records, number
%                 of reliable field measured records.
%     2. PDF files:
%        2.1. {USGS station ID}_usgs_site_floodfreq_disch:
%             Flood frequency curve established for the specified USGS
%             station.
%        2.2. {USGS station ID}_usgs_site_AHG:
%             Graphical representation of AHG relations established for the 
%             specified USGS station.
%
% Reference:  Afshari S., Fekete B. M., Dingman S. L., Devineni N.,
%             Bjerklie D. M., Khanbilvardi R. M. (2017), 
%             Statistical filtering of river survey and streamflow data for
%             improving At-A-Station Hydraulic Geometry Relations, 
%             Journal of Hydrology, DOI: 10.1016/j.jhydrol.2017.01.038
%
%% Inputs (Editable)
site_no = '01064118'; % USGS station ID
subsample_size = 20; % size of the sub-samples or number of folding in Modified Cross-validation Regression Diagnostic 
computation_unit = 'SI'; % 'SI' for metric and 'English' for imperical as computational units

%% Setting ;ath of the working directory containing the required functions (Do NOT Edit)
starting_path = pwd;   
%% Generating Directory to Store Daily and Surveyed Data (Do NOT Edit)
if ~isdir('Imported_USGS_Data')
mkdir Imported_USGS_Data % Name of the directory can be changed 
end
%% Daily Data (Do NOT Edit)
func_conversion_Daily_Data_to_mat_file_StandAlone(site_no,starting_path,computation_unit);
%% Surveyed Data (Do NOT Edit)
func_conversion_Surveyed_Data_to_mat_file_StandAlone(site_no,starting_path);
%% AHG relation computation: Plots and Table (Do NOT Edit)
func_AHG_parameters(site_no,... % USGS site number
    subsample_size,... % Number of folding in Modified Cross-validation Regression Diagnostic
    computation_unit,... % Computation unit in plotting and outcome AHG table. 
    starting_path) % Path of main directory
