function [param] = calc_flowcurve(strain,stress,T)

%calculation of bottom limit for model fitting( =>strain 2%)
idx_bottom = find(strain > 0.02,1,'First');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%model fitting

opts.Interpreter = 'tex';
% Include the desired Default answer
opts.Default = 'Ludwik';
% Use the TeX interpreter to format the question
quest = 'Wählen Sie einen Extrapolationsansatz zur Ermittlung der Fließfunktion aus:';
answer = questdlg(quest,'Boundary Condition','Ludwik','Johnson Cook',opts);

if answer == "Ludwik"
    disp('Für die Extrapolation der Fließfunktion wird das Ludwik Modell verwendet.')
    %Ludwik model
    g   = fittype('C*x^n');
    f   = fit(strain(idx_bottom:end), stress(idx_bottom:end), g, 'StartPoint', [400; 0.02]);

    %extract parameters:
    C =  f(1);
    n = f(2);
    
    disp(['C = ',num2str(C),'  n = ',num2str(n)])
elseif answer == "Johnson Cook"
    disp('Für die Extrapolation der Fließfunktion wird das Johnson-Cook Modell verwendet.')
    
    T0 = 20;    %ambient temperature
    Ts = 1200;   %melting temperature

    %Johnson-Cook
    g = fittype('(A+C*x^n)*(1-((T-T0)/(Ts-T0))^m)','problem',{'T','T0','Ts'});
    f = fit(strain(idx_bottom:end),stress(idx_bottom:end),g,'problem',{T,T0,Ts},'Startpoint',[400;300; 200; -0.5]);
    
    %extract parameters:
    A = f(1);
    C = f(2);
    m = f(3);
    n = f(4);
    disp(['A = ',num2str(A),'  C = ',num2str(C),'  n = ',num2str(n),'  m = ',num2str(m)])
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Plot initialization
color = [[127,127,127];[222,0,0];[55,96,146];[0,176,80];[210,210,210];[238,127,0];[240,182,0]]/256;
figure(2)
hold on, box on, grid on

plot(strain,stress,'Linewidth',2)
plot([strain(idx_bottom) strain(idx_bottom)],[0 stress(idx_bottom)],'--','color',color(2,:),'Linewidth',1)
p = scatter(strain(idx_bottom),stress(idx_bottom),30,color(2,:),'filled');
set(get(get(p,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');


%initialization of strain to plot extrapolation model
xx  = linspace(strain(idx_bottom),strain(end),20);

plot(xx,f(xx),':.','Linewidth',2)

xlabel('Dehnung')
ylabel('Spannung')
legend('Experiment','2% Dehnung','Ludwik Extrapolation','Location','SouthEast')

param = [];

end


    
    