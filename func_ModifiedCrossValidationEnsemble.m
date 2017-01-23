function [f_final_best_model,... % symbolic function as outcome
    param_set_statistics_table] = ... % cell structure containing: 'R2','Bias Prec.','Bias Accur.','Invertibility Prec.', and 'Invertibility Accur'
    func_ModifiedCrossValidationEnsemble(...
    x,... % independent variable
    y,... % dependent variable
    powertype,... % text argument describing type of as fitted power-law curve: 'power1' as f(x) = a*x^b, and 'power2' as f(x) = a*x^b+c
    ensemble_counts,... % number of ensumbles associated with a particular partitioning (e.g. leave-one-out, 10-folds, etc.)
    crossvalidation_type,... % string name of a particular partitioning (e.g. leave-one-out, 10-folds, etc.), indicated as: 'LeaveOut' or 'KFold'
    foldnum) % 'KFold' value
startpath = pwd;
switch powertype
    
    case 'power2' %%% Regression Type: f(x) = a*x^b+c
        Final_Tables_a_coeff = zeros(ensemble_counts,1);
        Final_Tables_b_exp = zeros(ensemble_counts,1);
        Final_Tables_c_intercpt = zeros(ensemble_counts,1);
        Final_Tables_r2 = zeros(ensemble_counts,1);
        Final_Tables_sse = zeros(ensemble_counts,1);
        parfor times = 1:ensemble_counts
            switch crossvalidation_type
                case 'LeaveOut'
                    [f_best_model,gness_best_model] = ...
                        func_ModifiedCrossValidationEnsemble_DailyData(...
                        x,...
                        y,...
                        'LeaveOut');
                case 'KFold'
                    [f_best_model,gness_best_model] = ...
                        func_ModifiedCrossValidationEnsemble_DailyData(...
                        x,...
                        y,...
                        'KFold',foldnum);
            end
            % Example: a = 1.5 , b = 0.45 , c = 2.5
            Final_Tables_a_coeff(times,1) = f_best_model.a;
            Final_Tables_b_exp(times,1) = f_best_model.b;
            Final_Tables_c_intercpt(times,1) = f_best_model.c;
            Final_Tables_r2(times,1) = gness_best_model.rsquare;
            Final_Tables_sse(times,1) = gness_best_model.sse;
        end
        a_mean=mean(Final_Tables_a_coeff(:,1));
        b_mean=mean(Final_Tables_b_exp(:,1));
        c_mean=mean(Final_Tables_c_intercpt(:,1));
        %%%% Creating symbolic cfit function %%%%
        x_scratch = linspace(0.1,1,10)';
        y_scratch = x_scratch.^1 + randn(length(x_scratch),1);
        [f_final_best_model,~]=fit(x_scratch,y_scratch,'power2');
        warning('off')
        f_final_best_model.a = a_mean;
        f_final_best_model.b = b_mean;
        f_final_best_model.c = c_mean;
        clear x_scratch y_scratch
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        param_set_statistics_table = ...
            func_MCVRD_Rsquared_Bias_Invert_scores(...
            x,... % independent variable
            y,... % dependent variable
            f_final_best_model,... % symbolic function as fitted power-law curve to (x,y) data
            'power2'); % text argument describing type of as fitted power-law curve: 'power1' as f(x) = a*x^b, and 'power2' as f(x) = a*x^b+c
        %%%%%%%%%%%% End of Case 'power2' %%%%%%%%%%%%%%%
        
    case 'power1' %%% Regression Type: f(x) = a*x^b
        Final_Tables_a_coeff = zeros(ensemble_counts,1);
        Final_Tables_b_exp = zeros(ensemble_counts,1);
        Final_Tables_r2 = zeros(ensemble_counts,1);
        Final_Tables_sse = zeros(ensemble_counts,1);
        parfor times = 1:ensemble_counts
            switch crossvalidation_type
                case 'LeaveOut'
                    [f_best_model,gness_best_model] = ...
                        func_ModifiedCrossValidationEnsemble_SurveyedData(...
                        x,...
                        y,...
                        'LeaveOut');
                case 'KFold'
                    [f_best_model,gness_best_model] = ...
                        func_ModifiedCrossValidationEnsemble_SurveyedData(...
                        x,...
                        y,...
                        'KFold',foldnum);
            end
            % Example: a = 1.5 , b = 0.45
            Final_Tables_a_coeff(times,1) = f_best_model.a;
            Final_Tables_b_exp(times,1) = f_best_model.b;
            Final_Tables_r2(times,1) = gness_best_model.rsquare;
            Final_Tables_sse(times,1) = gness_best_model.sse;
        end
        a_mean=mean(Final_Tables_a_coeff(:,1));
        b_mean=mean(Final_Tables_b_exp(:,1));
        %%%% Creating symbolic cfit function %%%%
        x_scratch = linspace(0.1,1,10)';
        y_scratch = x_scratch.^1 + randn(length(x_scratch),1);
        [f_final_best_model,~]=fit(x_scratch,y_scratch,'power1');
        warning('off')
        f_final_best_model.a = a_mean;
        f_final_best_model.b = b_mean;
        clear x_scratch y_scratch
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        param_set_statistics_table = ...
            func_MCVRD_Rsquared_Bias_Invert_scores(...
            x,... % independent variable
            y,... % dependent variable
            f_final_best_model,... % symbolic function as fitted power-law curve to (x,y) data
            'power1'); % text argument describing type of as fitted power-law curve: 'power1' as f(x) = a*x^b, and 'power2' as f(x) = a*x^b+c      
        %%%%%%%%%%%% End of Case 'power1' %%%%%%%%%%%%%%%
end
cd(startpath);
end
%%%%%
