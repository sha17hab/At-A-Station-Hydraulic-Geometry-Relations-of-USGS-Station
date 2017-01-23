function param_set_statistics_table = ...
    func_MCVRD_Rsquared_Bias_Invert_scores(...
    x,... % independent variable
    y,... % dependent variable
    f_final_best_model,... % symbolic function as fitted power-law curve to (x,y) data
    powertype) % text argument describing type of as fitted power-law curve: 'power1' as f(x) = a*x^b, and 'power2' as f(x) = a*x^b+c

%%% Modified Cross-Validation Analysis
switch powertype
    
    case 'power1' %%% Regression Type: f(x) = a*x^b
        for i_cv = 1:1
            a_par(i_cv,1) = f_final_best_model.a;
            b_par(i_cv,1) = f_final_best_model.b;
            
            %%% RSquared, Coefficient of Determination
            yo = y;
            ye = (f_final_best_model.a).*(x.^f_final_best_model.b);
            yo_mean = mean(yo);
            SST = sum((yo-yo_mean).^2);
            SSR = sum((yo-ye).^2);
            rsquared_par(i_cv,1) = 1-(SSR/SST);
            clear SSR SST yo ye yo_mean
            
            %%% Invertibility
            y_x_predicted{:,i_cv} = (y./a_par(i_cv,1)).^(1/b_par(i_cv,1));
            y_x_predicted{:,i_cv} = real(y_x_predicted{:,i_cv});
            
            %%% Bias
            x_y_predicted{:,i_cv} = a_par(i_cv,1)*(x.^b_par(i_cv,1));
            
            %%% Accuracy - x est
            ave_y_x_predicted_minus_x{i_cv,1} = mean(y_x_predicted{:,i_cv}-x);
            median_y_x_predicted_minus_x{i_cv,1} = median(y_x_predicted{:,i_cv}-x);
            %%% Accuracy - y est
            ave_x_y_predicted_minus_y{i_cv,1} = mean(x_y_predicted{:,i_cv}-y);
            median_x_y_predicted_minus_y{i_cv,1} = median(x_y_predicted{:,i_cv}-y);
            %%% Precision - x est
            std_y_x_predicted_minus_x{i_cv,1} = std(y_x_predicted{:,i_cv}-x);
            %%% Precision - y est
            std_x_y_predicted_minus_y{i_cv,1} = std(x_y_predicted{:,i_cv}-y);
            
        end
        param_mat = [num2cell(a_par),num2cell(b_par),num2cell(rsquared_par)];
        clear invertibility_11line f_cv i_cv  loocv_y g_cv
        
        param_set_statistics_table_headings = {...
            '(a,b)','R2','Bias Prec.','Bias Accur.',...
            'Invertibility Prec.','Invertibility Accur'};
        param_set_statistics_table_1 = [...
            num2cell(cell2mat(param_mat(:,1:2)),2),... % (a,b) set
            param_mat(:,end),... % R2
            std_x_y_predicted_minus_y(:,1),... % Bias Precision
            ave_x_y_predicted_minus_y(:,1),... % Bias Accuracy
            std_y_x_predicted_minus_x(:,1),... % Invertibility Precision
            ave_y_x_predicted_minus_x(:,1)]; % Invertibility Accuracy
        param_set_statistics_table = [...
            param_set_statistics_table_headings;...
            param_set_statistics_table_1];
        
        clear param_set_statistics_scaled_table_1 param_set_statistics_table_1 ...
            param_set_statistics_scaled_table_headings ...
            param_set_statistics_table_headings
        
    case 'power2' %%% Regression Type: f(x) = a*x^b+c       
        for i_cv = 1:1
            a_par(i_cv,1) = f_final_best_model.a;
            b_par(i_cv,1) = f_final_best_model.b;
            c_par(i_cv,1) = f_final_best_model.c;
            
            %%% RSquared, Coefficient of Determination
            yo = y;
            ye = (f_final_best_model.a).*(x.^f_final_best_model.b)+f_final_best_model.c;
            yo_mean = mean(yo);
            SST = sum((yo-yo_mean).^2);
            SSR = sum((yo-ye).^2);
            rsquared_par(i_cv,1) = 1-(SSR/SST);
            clear SSR SST yo ye yo_mean
            
            %%% Invertibility
            y_x_predicted{:,i_cv} = ((y-...
                c_par(i_cv,1))./a_par(i_cv,1)).^(1/b_par(i_cv,1));
            y_x_predicted{:,i_cv} = real(y_x_predicted{:,i_cv});
            
            %%% Bias
            x_y_predicted{:,i_cv} = a_par(i_cv,1)*(x.^b_par(i_cv,1))+c_par(i_cv,1);
            
            %%% Accuracy - x est
            ave_y_x_predicted_minus_x{i_cv,1} = mean(y_x_predicted{:,i_cv}-x);
            median_y_x_predicted_minus_x{i_cv,1} = median(y_x_predicted{:,i_cv}-x);
            %%% Accuracy - y est
            ave_x_y_predicted_minus_y{i_cv,1} = mean(x_y_predicted{:,i_cv}-y);
            median_x_y_predicted_minus_y{i_cv,1} = median(x_y_predicted{:,i_cv}-y);
            %%% Precision - x est
            std_y_x_predicted_minus_x{i_cv,1} = std(y_x_predicted{:,i_cv}-x);
            %%% Precision - y est
            std_x_y_predicted_minus_y{i_cv,1} = std(x_y_predicted{:,i_cv}-y);
            
        end
        param_mat = [num2cell(a_par),num2cell(b_par),num2cell(c_par),num2cell(rsquared_par)];
        clear invertibility_11line f_cv i_cv  loocv_y g_cv
        
        param_set_statistics_table_headings = {...
            '(a,b,c)','R2','Bias Prec.','Bias Accur.',...
            'Invertibility Prec.','Invertibility Accur'};
        param_set_statistics_table_1 = [...
            num2cell(cell2mat(param_mat(:,1:3)),2),... % (a,b,c) set
            param_mat(:,end),... % R2
            std_x_y_predicted_minus_y(:,1),... % Bias Precision
            ave_x_y_predicted_minus_y(:,1),... % Bias Accuracy
            std_y_x_predicted_minus_x(:,1),... % Invertibility Precision
            ave_y_x_predicted_minus_x(:,1)]; % Invertibility Accuracy
        param_set_statistics_table = [...
            param_set_statistics_table_headings;...
            param_set_statistics_table_1];
        
        clear param_set_statistics_scaled_table_1 param_set_statistics_table_1 ...
            param_set_statistics_scaled_table_headings ...
            param_set_statistics_table_headings        
end