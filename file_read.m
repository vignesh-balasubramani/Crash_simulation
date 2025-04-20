% script to segregate parts from '.key' file of LS-DYNA
% reads the list of Parts, elements(beams,discrete,shell,solids), nodes and
% materials 
% INPUTS needed     : .key file
% functions needed  : shell_list.m
clearvars;
%
%
%list of material cards
%add all the material cards that are present in the file
m1='*MAT_PIECEWISE_LINEAR_PLASTICITY';
m2='*MAT_ELASTIC';
m3='*MAT_MODIFIED_PIECEWISE_LINEAR_PLASTICITY';
m4='*MAT_BLATZ-KO_RUBBER';
m5='*MAT_ELASTIC';
m6='*MAT_RIGID';
m7='*MAT_LOW_DENSITY_FOAM';
m8='*MAT_SPOTWELD';
m9='*MAT_SPRING_ELASTIC';
m10='*MAT_DAMPER_VISCOUS';
m11='*MAT_SPRING_NONLINEAR_ELASTIC';
%
%% data collection-------------------------------------------------------
fid=fopen("yaris-coarse-v1l.key",'r'); % input the file name here
a=1;b=1;c=1;x=1;
%
%% while loop reads through everyline of the .key file ------------------
while ~feof(fid)
    each_row=fgetl(fid);
    if strcmp(each_row,'*PART') %% generates the list of parts
        d=fgetl(fid);
        A=fgetl(fid);
        e=fgetl(fid);
        B=textscan(fid,'%d %*[\n]');
        Part={A,B{1}};
        P{b,1}=Part{1,1};
        P{b,2}=Part{1,2};
        Parts=cell2table(P);
        b=b+1;
    elseif strcmp(each_row,'*SECTION_SHELL') %% to read the thickness of the part
        Shell_section(x,:)=shell_list(fid); %% calls the funtion shell_list.m
        x=x+1;
    elseif strcmp(each_row,'*ELEMENT_SOLID') %% reads solid elements
        e_solids=cell2mat(textscan(fid,'%f %f %f %f %f %f %f %f %f %f %*[\n]','Headerlines',1));
    elseif strcmp(each_row,'*ELEMENT_SHELL') %% reads shell elements
        e_shell=cell2mat(textscan(fid,'%f %f %f %f %f %f %*[\n]','Headerlines',1));
    elseif strcmp(each_row,'*ELEMENT_BEAM') %% reads beam elements
        e_beam=cell2mat(textscan(fid,'%f %f %f %f %f %*f %*[\n]','Headerlines',1));
    elseif strcmp(each_row,'*ELEMENT_DISCRETE') %% reads discrete elements
        e_discrete=cell2mat(textscan(fid,'%f %f %f %f %*[\n]','Headerlines',1));
    elseif strcmp(each_row,'*NODE') %% reads the node definition
        nodes=cell2mat(textscan(fid,'%f %f %f %f %*[\n]','Headerlines',1));
    elseif strcmp(each_row,m1) || strcmp(each_row,m2) || strcmp(each_row,m3)...
            || strcmp(each_row,m4) || strcmp(each_row,m5) || strcmp(each_row,m6)...
            || strcmp(each_row,m7) || strcmp(each_row,m8) || strcmp(each_row,m9)...
            || strcmp(each_row,m10) || strcmp(each_row,m11) %% reads the materials
        % add more material cards if necessary
        M=textscan(fid,'%f %f %f %f %f %*[/n]','Headerlines',1);
        mat{c,:}=M;
        c=c+1;
    end
    a=a+1;
end
mat=cell2table(mat);
fclose(fid);
%% sorting----------------------------------------------------------------
e_solids=sortrows(e_solids,2);
e_shell=sortrows(e_shell,2);
e_beam=sortrows(e_beam,2);
e_discrete=sortrows(e_discrete,2);
nodes=sortrows(nodes,1);
%% shell_section co-ordinating with Parts--------------------------------
for y=1:size(Parts)
    try
        f=find(Shell_section(:,1)==Parts{y,2});
        Parts{y,3}=Shell_section(f,2);
    catch
        Parts{y,3}=NaN;
    end
end
Parts.Properties.VariableNames=["Part name","Part id","Shell_thickness"];
%% saving the data-------------------------------------------------------
save('Elements.mat','e_solids','e_shell','e_beam','e_discrete');
save('Nodes.mat','nodes');
save('Parts.mat','Parts');
save('Materials.mat','mat');
