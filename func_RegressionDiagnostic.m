function [X_exploratory_bankfull_Nonoutlier,Y_response_bankfull_Nonoutlier,Index_Nonoutlier,...
    X_exploratory_bankfull_Outlier,Y_response_bankfull_Outlier,Index_Outlier]=...
    func_rmOutlier_Discharg_GageHeight_Rating_Curve_RegDiagn(...
    X_exploratory_bankfull_input,Y_response_bankfull_input,best_fit_model)

f = best_fit_model;
x = X_exploratory_bankfull_input;
y = Y_response_bankfull_input;
%%%%%%%%%%%%%%%%%%%%%%%%%%% Removing Outliers %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Leverage
if length(coeffnames(f)) == 3
p = 3;
f1 = x.^(f.b);
f2 = ((f.a)*log(x)).*(x.^(f.b));
f3 = ones(length(x),1);
J = [f1,f2,f3];
H = J*inv(J'*J)*J';
H_ii = diag(H);
end
if length(coeffnames(f)) == 2
p = 2;
f1 = x.^(f.b);
f2 = ((f.a)*log(x)).*(x.^(f.b));
J = [f1,f2];
H = J*inv(J'*J)*J';
H_ii = diag(H);
end


%%% Testing SIGMA(H_ii) = #Parameters
sum(H_ii);

Leverage_proper_indx = double(H_ii<(3*p/length(x)));

%% Influence
e = y - f(x);
MSE = (1/length(y))*sum(e.^2);
D = ((e.^2).*H_ii )./(p*MSE*((1-H_ii ).^2));
Influence_proper_indx = double(D<1/length(y));
%% Standardized Residual
e = y - f(x);
esi = e./(std(e)*sqrt(1-H_ii));
Std_Res_proper_indx = double(abs(esi)<1.96);

%% Best Observerd Data
x_proper_indx = [];
for i = 1:length(Leverage_proper_indx)
    
    if Leverage_proper_indx(i) == 1 && ...
            Influence_proper_indx(i) == 1 && ...
            Std_Res_proper_indx(i) == 1
        
        x_proper_indx = [x_proper_indx;i];
        
    end
    
end

x_new_min = nanmin(x(x_proper_indx));
y_new_min = y(x_proper_indx);

x_new_less_than_min_indx = x<x_new_min;

x_proper_indx_2 = [];

for i = 1:length(Std_Res_proper_indx)
    
    if x_new_less_than_min_indx(i) == 1 && ...
            Std_Res_proper_indx(i) == 1
        
        x_proper_indx_2 = [x_proper_indx_2;i];
        
    end
    
end

x_proper_indx_final = ...
    [x_proper_indx_2(~ismember(x_proper_indx_2,x_proper_indx));x_proper_indx];
Index_all_data = (1:length(x))';

%%% Non-outlier data
Index_Nonoutlier = sort(x_proper_indx_final);
X_exploratory_bankfull_Nonoutlier  = x(Index_Nonoutlier);
Y_response_bankfull_Nonoutlier = y(Index_Nonoutlier);

%%% Outlier data
Index_Outlier = sort(Index_all_data(~ismember((1:length(x))',Index_Nonoutlier)));
X_exploratory_bankfull_Outlier = x(Index_Outlier);
Y_response_bankfull_Outlier = y(Index_Outlier);

end








