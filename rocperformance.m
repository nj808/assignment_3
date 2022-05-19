%Draws a ROC Performance Probability Curve using the input scorer when
%diagnosis is predicted for a test_set
function [] = rocperformance(scorer,test_set,name)

%Plot a ROC performance curve and compute the area under the curve for the
%'0'  and '1' categories in the diagnosis class 
[X0,Y0,~,AUC0] = perfcurve(test_set.diagnosis,scorer(:,1),'0');
[X1,Y1,~,AUC1] = perfcurve(test_set.diagnosis,scorer(:,2),'1');
plot(X0,Y0);
hold on;
plot(X1,Y1);
legend((sprintf("Area under curve for '0' class is: %.2f",AUC0)), ...
    (sprintf("Area under curve for '1' class is: %.2f",AUC1)), ...
    "Location","southeast");
title(sprintf('ROC for Classification using %s Classifier',name));
xlabel('False Positive rate');
ylabel('True Positive rate');
hold off;
end