% script that generates bounding box over all parts
% Inputs needed     : Parts.mat (all the element definitions)
%                     Shell_elements_area.mat
%                     Solid_elements_volume.mat
%                     elements_beam_discrete.mat
% functions needed  : area3D.mat
% Outputs           : Parts_bounded.mat
clearvars;
% file_read;
% area_elements;
% volume_elements;
% beam_discrete;
load('Parts.mat') %reads the Part, elements, nodes and material data
load('Shell_elements_area.mat')
load('Solid_elements_volume.mat')
load('elements_beam_discrete.mat')
%% finds the elements present in the current part
for d=1:size(Parts) 
    p=Parts{d,2};
    %finds which elements beling to a certain part---------------
    beam_l=ismember(e_beam(:,2),p);
    discrete_l=ismember(e_discrete(:,2),p);
    shell_tria_l=ismember(e_shell_tria(:,2),p);
    shell_quad_l=ismember(e_shell_quad(:,2),p);
    solids_l=ismember(e_solids(:,2),p);
    beam=e_beam.*(double([zeros(length(e_beam),2),repelem(beam_l,1,10)]));
    discrete=e_discrete.*(double([zeros(length(e_discrete),2),repelem(discrete_l,1,9)]));
    shell_tria=e_shell_tria.*(double([zeros(length(e_shell_tria),2),repelem(shell_tria_l,1,13)]));
    shell_quad=e_shell_quad.*(double([zeros(length(e_shell_quad),2),repelem(shell_quad_l,1,17)]));
    solids=e_solids.*(double([zeros(length(e_solids),2),repelem(solids_l,1,33)]));
    %%area and volume calculation
    a_t=sum(shell_tria);
    a_q=sum(shell_quad);
    v_s=sum(solids);
    area=a_t(1,15)+a_q(1,19);
    if area~=0
        actual_volume=Parts{d,3}*area;
    else 
        actual_volume=v_s(1,35);
    end    
    Parts{d,4}=actual_volume;
    X=[beam(:,6);beam(:,9);discrete(:,5);discrete(:,8); ...
        shell_tria(:,6);shell_tria(:,9);shell_tria(:,12); ...
        shell_quad(:,7);shell_quad(:,10);shell_quad(:,13); ...
        shell_quad(:,16);solids(:,11);solids(:,14);solids(:,17); ...
        solids(:,20);solids(:,23);solids(:,26);solids(:,29);solids(:,32)];
    Y=[beam(:,7);beam(:,10);discrete(:,6);discrete(:,9); ...
        shell_tria(:,7);shell_tria(:,10);shell_tria(:,13); ...
        shell_quad(:,8);shell_quad(:,11);shell_quad(:,14); ...
        shell_quad(:,17);solids(:,12);solids(:,15);solids(:,18); ...
        solids(:,21);solids(:,24);solids(:,27);solids(:,30);solids(:,33)];
    Z=[beam(:,8);beam(:,11);discrete(:,7);discrete(:,10); ...
        shell_tria(:,8);shell_tria(:,11);shell_tria(:,14); ...
        shell_quad(:,9);shell_quad(:,12);shell_quad(:,15); ...
        shell_quad(:,18);solids(:,13);solids(:,16);solids(:,19); ...
        solids(:,22);solids(:,25);solids(:,28);solids(:,31);solids(:,34)];    
    X=X(X~=0);Y=Y(Y~=0);Z=Z(Z~=0);
    cornerpoints=zeros(8,3);
    volume=0;
    try %calculates the bounding box-----------------
        [rotmat,cornerpoints,volume,surface]=minboundbox(X,Y,Z,'v',1); %calls the function minboundingbox
    catch
        warning('There has been a warning in calculating the convexhull');
        disp(d);
    end
    % centriod calculation---------------
    dist=zeros(8,1);
    for a=2:8
        dist(a)=sqrt((cornerpoints(a,1)-cornerpoints(1,1))^2+(cornerpoints(a,2)...
            -cornerpoints(1,2))^2+(cornerpoints(a,3)-cornerpoints(1,3))^2);
    end
    [M,i]=max(dist);
    centriod=(cornerpoints(1,:)+cornerpoints(i,:))/2;
    Parts{d,5}={cornerpoints};
    Parts{d,6:8}={centriod(1),centriod(2),centriod(3)};
    Parts{d,9}=volume;
    centriod=(cornerpoints(1,:)+cornerpoints(i,:))/2;
    %% plotting the part
    col='b';
    hx = cornerpoints(:,1);hy = cornerpoints(:,2);hz = cornerpoints(:,3);
    x=[hx(1);hx(2)];y=[hy(1);hy(2)];z=[hz(1);hz(2)];plot3(x,y,z,col);hold on;
    x=[hx(2);hx(3)];y=[hy(2);hy(3)];z=[hz(2);hz(3)];plot3(x,y,z,col);hold on;
    x=[hx(3);hx(4)];y=[hy(3);hy(4)];z=[hz(3);hz(4)];plot3(x,y,z,col);hold on;
    x=[hx(4);hx(1)];y=[hy(4);hy(1)];z=[hz(4);hz(1)];plot3(x,y,z,col);hold on;
    x=[hx(5);hx(6)];y=[hy(5);hy(6)];z=[hz(5);hz(6)];plot3(x,y,z,col);hold on;
    x=[hx(6);hx(7)];y=[hy(6);hy(7)];z=[hz(6);hz(7)];plot3(x,y,z,col);hold on;
    x=[hx(7);hx(8)];y=[hy(7);hy(8)];z=[hz(7);hz(8)];plot3(x,y,z,col);hold on;
    x=[hx(8);hx(5)];y=[hy(8);hy(5)];z=[hz(8);hz(5)];plot3(x,y,z,col);hold on;
    x=[hx(1);hx(5)];y=[hy(1);hy(5)];z=[hz(1);hz(5)];plot3(x,y,z,col);hold on;
    x=[hx(2);hx(6)];y=[hy(2);hy(6)];z=[hz(2);hz(6)];plot3(x,y,z,col);hold on;
    x=[hx(3);hx(7)];y=[hy(3);hy(7)];z=[hz(3);hz(7)];plot3(x,y,z,col);hold on;
    x=[hx(4);hx(8)];y=[hy(4);hy(8)];z=[hz(4);hz(8)];plot3(x,y,z,col);hold on;
    plot3(centriod(1),centriod(2),centriod(3),'x');
    axis equal;
    fm=actual_volume/volume;
    Parts{d,10}=fm;
end
Parts.Properties.VariableNames={'P_name','pid','shell_thickness', ...
    'actual_volume','cornerpoints','centriod_x','centriod_y','centriod_z', ...
    'volume','fm'};
save('Parts_bounded.mat','Parts');
