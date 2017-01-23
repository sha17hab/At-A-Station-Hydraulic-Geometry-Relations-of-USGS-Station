function [f_best_model,gness_best_model] = ...
    func_ModifiedCrossValidationEnsemble_DailyData(x,y,...
    crossvalidation_type,foldnum)

x_revised_positive_indx = double(x>0);
y_revised_positive_indx = double(y>0);
positive_indx = (x_revised_positive_indx + y_revised_positive_indx - 1);
positive_indx(positive_indx(:)==-1)=0;
positive_indx = logical(positive_indx);

x_revised = x(positive_indx);
y_revised = y(positive_indx);

warning('off','all')

if exist('crossvalidation_type','var') && ~isempty(crossvalidation_type)
    
    switch crossvalidation_type
        
        case 'LeaveOut'
            loocv_y = cvpartition(length(y_revised),'LeaveOut');
            
        case 'KFold'
            loocv_y = cvpartition(length(y_revised),'KFold',foldnum);
    end
    
end

%% Setting Fitting Initials
s = fitoptions('Method','NonlinearLeastSquares',... 
               'Lower',[-10 0.001 -0.01],... % lower limits of fitting parameters
               'Upper',[10 1000 1], ... % upper limits of fitting parameters
               'Startpoint',[0.0001 0.001 -0.01]); % starting point of numerical experiments
f = fittype('a*(x^b)+c','coefficients',{'c','a','b'},'independent','x','options', s); % fitting function type    

%% Cross-Validation Analysis
N = loocv_y.NumTestSets;
for i_cv = 1:N
    [f_cv,g_cv] = fit(x_revised(training(loocv_y,i_cv)),y_revised(training(loocv_y,i_cv)),f);
    
    leftout_data_indx{i_cv,1} = find(test(loocv_y,i_cv));
    a_par(i_cv,1) = f_cv.a;
    b_par(i_cv,1) = f_cv.b;
    c_par(i_cv,1) = f_cv.c;
    rsquared_par(i_cv,1) = g_cv.rsquare;
    
    %%% Invertibility
    y_x_predicted{:,i_cv} = ((y_revised-...
        c_par(i_cv,1))./a_par(i_cv,1)).^(1/b_par(i_cv,1));
    y_x_predicted{:,i_cv} = real(y_x_predicted{:,i_cv});
    invertibility_11line = fitlm(x_revised,y_x_predicted{:,i_cv},'linear');
    alpha_x_xhat_y{i_cv,1} = leftout_data_indx{i_cv,1};
    alpha_x_xhat_y{i_cv,2} = invertibility_11line.Coefficients{1,1};
    alpha_x_xhat_y{i_cv,3} = invertibility_11line.Coefficients{1,4};
    beta_x_xhat_y{i_cv,1} = leftout_data_indx{i_cv,1};
    beta_x_xhat_y{i_cv,2} = invertibility_11line.Coefficients{2,1};
    beta_x_xhat_y{i_cv,3} = invertibility_11line.Coefficients{2,4};
    
    %%% Bias
    x_y_predicted{:,i_cv} = a_par(i_cv,1)*(x_revised.^b_par(i_cv,1))+c_par(i_cv,1);
    
    %%% Accuracy - x est
    ave_y_x_predicted_minus_x{i_cv,1} = leftout_data_indx{i_cv,1};
    ave_y_x_predicted_minus_x{i_cv,2} = mean(y_x_predicted{:,i_cv}-x_revised);
    median_y_x_predicted_minus_x{i_cv,1} = leftout_data_indx{i_cv,1};
    median_y_x_predicted_minus_x{i_cv,2} = median(y_x_predicted{:,i_cv}-x_revised);
    %%% Accuracy - y est
    ave_x_y_predicted_minus_y{i_cv,1} = leftout_data_indx{i_cv,1};
    ave_x_y_predicted_minus_y{i_cv,2} = mean(x_y_predicted{:,i_cv}-y_revised);
    median_x_y_predicted_minus_y{i_cv,1} = leftout_data_indx{i_cv,1};
    median_x_y_predicted_minus_y{i_cv,2} = median(x_y_predicted{:,i_cv}-y_revised);
    %%% Precision - x est
    std_y_x_predicted_minus_x{i_cv,1} = leftout_data_indx{i_cv,1};
    std_y_x_predicted_minus_x{i_cv,2} = std(y_x_predicted{:,i_cv}-x_revised);
    %%% Precision - y est
    std_x_y_predicted_minus_y{i_cv,1} = leftout_data_indx{i_cv,1};
    std_x_y_predicted_minus_y{i_cv,2} = std(x_y_predicted{:,i_cv}-y_revised);
    
end
param_mat = [leftout_data_indx,num2cell(a_par),num2cell(b_par),num2cell(c_par),num2cell(rsquared_par)];
clear invertibility_11line f_cv i_cv  loocv_y g_cv

param_set_statistics_table_headings = {...
    'left-out data indx','(a,b,c)','R2','Bias Prec.','Bias Accur.',...
    'Invertibility Prec.','Invertibility Accur'};
param_set_statistics_table_1 = [...
    param_mat(:,1),... % left-out data indx
    num2cell(cell2mat(param_mat(:,2:4)),2),... % (a,b,c) set
    param_mat(:,end),... % R2
    std_x_y_predicted_minus_y(:,2),... % Bias Precision
    ave_x_y_predicted_minus_y(:,2),... % Bias Accuracy
    std_y_x_predicted_minus_x(:,2),... % Invertibility Precision
    ave_y_x_predicted_minus_x(:,2)]; % Invertibility Accuracy
param_set_statistics_scaled_table_headings = {...
    'left-out data indx','(a,b,c)','R2','Bias Prec.','Bias Accur.',...
    'Invertibility Prec.','Invertibility Accur','Total Score (0-1)'};
param_set_statistics_scaled_table_1 = [...
    param_mat(:,1),... % left-out data indx
    num2cell(cell2mat(param_mat(:,2:4)),2),... % (a,b,c) set
    param_mat(:,end),... % R2
    num2cell(1-(cell2mat(std_x_y_predicted_minus_y(:,2))/max(cell2mat(std_x_y_predicted_minus_y(:,2))))),... % Bias Precision
    num2cell(1-(abs(cell2mat(ave_x_y_predicted_minus_y(:,2)))/max(abs(cell2mat(ave_x_y_predicted_minus_y(:,2)))))),... % Bias Accuracy
    num2cell(1-(cell2mat(std_y_x_predicted_minus_x(:,2))/max(cell2mat(std_y_x_predicted_minus_x(:,2))))),... % Invertibility Precision
    num2cell(1-(abs(cell2mat(ave_y_x_predicted_minus_x(:,2)))/max(abs(cell2mat(ave_y_x_predicted_minus_x(:,2))))))]; % Invertibility Accuracy
param_set_statistics_scaled_table_1 = [...
    param_set_statistics_scaled_table_1,...
    num2cell((sum(cell2mat(param_set_statistics_scaled_table_1(:,3:end)),2)/5))];

param_set_statistics_table = [...
    param_set_statistics_table_headings;...
    param_set_statistics_table_1];
param_set_statistics_scaled_table = [...
    param_set_statistics_scaled_table_headings;...
    param_set_statistics_scaled_table_1];
clear param_set_statistics_scaled_table_1 param_set_statistics_table_1 ...
    param_set_statistics_scaled_table_headings ...
    param_set_statistics_table_headings

%%% index of the dataset ending to the best model
[~,I_BestScore]=max(cell2mat(param_set_statistics_scaled_table(2:end,end)));

x_revised2 = x_revised;
y_revised2 = y_revised;
x_revised2(cell2mat(param_set_statistics_scaled_table(I_BestScore+1,1)))=[];
y_revised2(cell2mat(param_set_statistics_scaled_table(I_BestScore+1,1)))=[];

[f_best_model,gness_best_model] = fit(x_revised2,y_revised2,f);
