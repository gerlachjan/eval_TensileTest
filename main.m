%function main
clc
clear all
close all

l0      = 20;       %intial length
wd      = 9.9;    %width
t       = 2;        %thickness
cs_A    = wd*t;     %cross section area

%generate names and figure out if they are existing

materials    = ["DD11","HLB42","HMnS-HY","HMnS-LY","HSM700"];
names       = [];
for i = 1:5
    for j = 1:19
        for k = 1:4
            name        = materials(i)+"_"+j+"_"+k+".asc";
            names       = [names,name];
        end
    end
end

[~,n1]      = size(names);
filenames   =  [];
for i=1:n1
    filename = names(i);
    file_direction = "experiment_data\"+filename;
    if isfile(file_direction)
    filenames = [filenames,filename];    
    else
        continue
    end
end
main_filenames =string([]);
for i = filenames
    char = convertStringsToChars(i);
    main_filename = char(1:end-5);
    main_filename = convertCharsToStrings(main_filename);
    if sum(contains(main_filenames,main_filename))
    else
        main_filenames = [main_filenames,main_filename];
    end   
end

indizes = zeros(length(main_filenames),4);
iter    = 1;
for i = main_filenames
    idx = find(contains(filenames,i));
    indizes(iter,1:length(idx)) =idx;
    iter = iter+1;
end

dataExp = {};
m_all = [];
for i=1:length(main_filenames)
    iter = 1;
    for idx = indizes(i,1:3)
        if idx == 0
            dataExp{1,iter} = zeros(3000,5);
            iter = iter+1;
            continue
        end
        file_direction = "experiment_data\"+filenames(idx);
        comma2point_overwrite(file_direction)
        fid     = fopen(file_direction, 'rt');
        C       = textscan(fid, '%f%f%f%f%f%f%f%f%f','HeaderLines', 1);
        fclose(fid);
        disp(filenames(idx))
        cn = 5;  %columns of interest
        %colum 1-5: time[s], displacement[mm], force[N], traverse[mm], temperatur[°C]
        data=[];
        for j=1:cn
            data(:,j) = C{j};
        end
        %save data to specific filename in cell array
        dataExp{1,iter} = data;
        iter = iter+1;
        
    end
    
    u01_raw = dataExp{1,1}(:,2);
    u02_raw = dataExp{1,2}(:,2);
    u03_raw = dataExp{1,3}(:,2);
    
    f01_raw = dataExp{1,1}(:,3);
    f02_raw = dataExp{1,2}(:,3);
    f03_raw = dataExp{1,3}(:,3);
    
    T01      = dataExp{1,1}(end,5);
    T02      = dataExp{1,1}(end,5);
    T03      = dataExp{1,1}(end,5);
    
    [u01,f01] = rawToCleaned(u01_raw,f01_raw);
    [u02,f02] = rawToCleaned(u02_raw,f02_raw);
    [u03,f03] = rawToCleaned(u03_raw,f03_raw);
    
    
    [xx,fxx] = bestfit(u01,u02,u03,f01,f02,f03);
    
    stress01 =f01/cs_A;
    strain01 = u01/l0;
    m01 = diff(stress01)./diff(strain01);
    idx_interest = 4;
    if isempty(m01)
        disp("Elastizitätsmodul kann nicht berechnet werden und wird auf Null gesetzt.")
        E01 = 0;
    else
        E01 = m01(idx_interest);
        if E01 == inf
            E01 = m01(idx_interest+1);
        end
    end
    
    stress02 =f02/cs_A;
    strain02 = u02/l0;
    m02 = diff(stress02)./diff(strain02);
    if isempty(m02)
        disp("Elastizitätsmodul kann nicht berechnet werden und wird auf Null gesetzt.")
        E02 = 0;
    else
        E02 = m02(idx_interest);
        if E02 == inf
            E02 = m02(idx_interest+1);
        end
    end
    
    stress03 =f03/cs_A;
    strain03 = u03/l0;
    m03 = diff(stress03)./diff(strain03);
    if isempty(m03)
        disp("Elastizitätsmodul kann nicht berechnet werden und wird auf Null gesetzt.")
        E03 = 0;
    else
        E03 = m03(idx_interest);
        if E03 == inf
            E03 = m03(idx_interest+1);
        end
    end
    
    %calculation of averaged stress and strain
    stress = fxx/cs_A;
    strain = xx/l0;
    
    %calculation of averaged Young's Modulus
    m = diff(stress)./diff(strain);
    E = m(4);
    E_all = [E01 E02 E03 E];
    
    %calculation of true values
    [strain_true01,stress_true01] = true_values(stress01,strain01,E01);
    [strain_true02,stress_true02] = true_values(stress02,strain02,E02);
    [strain_true03,stress_true03] = true_values(stress03,strain03,E03);
    [strain_true,stress_true]     = true_values(stress,strain,E);
  
    
    %calculation of flow curve
    %[param] = calc_flowcurve(strain_true01,stress_true01,T01);
    
    

    
    %Plot initialization
    IULblue = [55 96 146]/256;
    color = [[127,127,127];[222,0,0];[55,96,146];[0,176,80];[210,210,210];[238,127,0];[240,182,0]]/256;

    figure(1)
    subplot(4,1,1);
    %plot(u01_raw,f01_raw,u02_raw,f02_raw,u03_raw,f03_raw,'color',color(2,:))
    hold off
    plot(u01_raw,f01_raw,'color',color(1,:))
    hold on
    plot(u02_raw,f02_raw,'color',color(2,:))
    hold on
    plot(u03_raw,f03_raw,'color',color(3,:))
    xlabel('Verschiebung in mm')
    ylabel('Kraft in N')
    title(main_filenames(i)+"raw",'Interpreter','none')
    legend(main_filenames(i)+"1",main_filenames(i)+"2",main_filenames(i)+"3",'Interpreter','none','Location','BestOutside')
    box on, grid on
    
    subplot(4,1,2);
    %plot(u01,f01,u02,f02,u03,f03)
    hold off
    plot(u01,f01,'color',color(1,:))
    hold on
    plot(u02,f02,'color',color(2,:))
    hold on
    plot(u03,f03,'color',color(3,:))
    xlabel('Verschiebung in mm')
    ylabel('Kraft in N')
    title(main_filenames(i)+"cleared",'Interpreter','none')
    legend(main_filenames(i)+"1",main_filenames(i)+"2",main_filenames(i)+"3",'Interpreter','none','Location','BestOutside')
    box on, grid on
    
    subplot(4,1,3);
    %plot(strain01,stress01,strain02,stress02,strain03,stress03)
    hold off
    plot(strain01,stress01,'color',color(1,:))
    hold on
    plot(strain02,stress02,'color',color(2,:))
    hold on
    plot(strain03,stress03,'color',color(3,:))
    xlabel('Dehnung')
    ylabel('Spannung in MPa')
    title(main_filenames(i)+"cleared",'Interpreter','none')
    legend(main_filenames(i)+"1",main_filenames(i)+"2",main_filenames(i)+"3",'Interpreter','none','Location','BestOutside')
    box on, grid on
    
    subplot(4,1,4);
    hold off
    bar(1,E_all(1),'Facecolor',color(1,:))
    hold on
    bar(2,E_all(2),'Facecolor',color(2,:))
    hold on
    bar(3,E_all(3),'Facecolor',color(3,:))
    hold on
    bar(4,E_all(4),'Facecolor',color(5,:))
    xticks(1:4)
    xticklabels(["E01","E02", "E03","E"])
    ylabel('Elastizitätsmodul in MPa')
    title(main_filenames(i)+"cleared",'Interpreter','none')
    box on, grid on
       
%     figure(2)
%     plot(u01,f01,u02,f02,u03,f03)
%     xlabel('Verschiebung in mm')
%     ylabel('Kraft in N')
%     title(main_filenames(i)+"cleared",'Interpreter','none')
%     legend(main_filenames(i)+"1",main_filenames(i)+"2",main_filenames(i)+"3",'Interpreter','none','Location','Best')
%     box on, grid on
    
end

%end
%% additional functions
function    comma2point_overwrite( filespec )
    % replaces all occurences of comma (",") with point (".") in a text-file.
        file    = memmapfile( filespec, 'writable', true );
        comma   = uint8(',');
        point   = uint8('.');
        file.Data( transpose( file.Data==comma) ) = point;
end

