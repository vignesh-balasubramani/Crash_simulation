function [new_part_1,actual_volume_1,cornerpoints_1, ...
    new_part_2,actual_volume_2,cornerpoints_2]=split_part(id)
% function that splits a part into two equal material volume
% inputs needed are part_id
% outputs are cornerpoints of bounding box of each part and volume of the
% bounding box and actual volume of each parts
    load('Parts_bounded.mat');
    load('Shell_elements_area.mat');
    load('Solid_elements_volume.mat');
    load('elements_beam_discrete.mat');
    load('Nodes.mat')
    col='b';
    check=cell2mat(Parts.centriod_x);
    aa=check<-1000; % x-distance
    Parts(aa,:)=[];
    Parts=sortrows(Parts,10);
    check_vol=Parts.actual_volume;
    ab=(check_vol==0);
    Parts(ab,:)=[];
    ac=id;%part_id
    ae=1;%cornerpointid
    cornerpoints=cell2mat(Parts{ac,5});
    thickness=Parts{ac,3};
    part_id=Parts{ac,2};
    actual_volume=Parts{ac,4};
    %finds which elements beling to a certain part---------------
    beam_l=ismember(e_beam(:,2),part_id);
    discrete_l=ismember(e_discrete(:,2),part_id);
    shell_tria_l=ismember(e_shell_tria(:,2),part_id);
    shell_quad_l=ismember(e_shell_quad(:,2),part_id);
    solids_l=ismember(e_solids(:,2),part_id);
    beam=reshape(e_beam(repelem(beam_l,1,12)),[],12);
    discrete=reshape(e_discrete(repelem(discrete_l,1,11)),[],11);
    shell_tria=reshape(e_shell_tria(repelem(shell_tria_l,1,15)),[],15);
    shell_quad=reshape(e_shell_quad(repelem(shell_quad_l,1,19)),[],19);
    solids=reshape(e_solids(repelem(solids_l,1,35)),[],35);
    % for shell elements
    if ~isempty(shell_quad) || ~isempty(shell_tria)
    node_id=[shell_tria(:,3);shell_tria(:,4);shell_tria(:,5);...
        shell_quad(:,3);shell_quad(:,4);shell_quad(:,5); ...
        shell_quad(:,6)];
    X=[shell_tria(:,6);shell_tria(:,9);shell_tria(:,12); ...
        shell_quad(:,7);shell_quad(:,10);shell_quad(:,13); ...
        shell_quad(:,16)];
    Y=[shell_tria(:,7);shell_tria(:,10);shell_tria(:,13); ...
        shell_quad(:,8);shell_quad(:,11);shell_quad(:,14); ...
        shell_quad(:,17)];
    Z=[shell_tria(:,8);shell_tria(:,11);shell_tria(:,14); ...
        shell_quad(:,9);shell_quad(:,12);shell_quad(:,15); ...
        shell_quad(:,18)];
    check=1;
    end
    % for solid elements
    if ~isempty(solids)
    node_id=[solids(:,3);solids(:,4);solids(:,5); ...
        solids(:,6);solids(:,7);solids(:,8);solids(:,9);solids(:,10)];
    X=[solids(:,11);solids(:,14);solids(:,17); ...
        solids(:,20);solids(:,23);solids(:,26);solids(:,29);solids(:,32)];
    Y=[solids(:,12);solids(:,15);solids(:,18); ...
        solids(:,21);solids(:,24);solids(:,27);solids(:,30);solids(:,33)];
    Z=[solids(:,13);solids(:,16);solids(:,19); ...
        solids(:,22);solids(:,25);solids(:,28);solids(:,31);solids(:,34)];
    check=2;
    end
    node_co_ord=[X,Y,Z];
    Euc_dist=zeros(length(node_co_ord),1);
    % finds the corner node closer to the bounding box corner point
    for ad=1:size(node_co_ord)
    Euc_dist(ad)=sqrt((node_co_ord(ad,1)-cornerpoints(ae,1))^2+ ...
        (node_co_ord(ad,2)-cornerpoints(ae,2))^2+ ...
        (node_co_ord(ad,3)-cornerpoints(ae,3))^2);
    end
    [~,I]=min(Euc_dist);
    plot3(node_co_ord(:,1),node_co_ord(:,2),node_co_ord(:,3),'o');
    axis equal;
    hold on;
    plot3(node_co_ord(I,1),node_co_ord(I,2),node_co_ord(I,3),'x');
    n=node_id(I);
    volume=0;
    figure;
    % splits the part into equal materials
    new_solids=[];
    new_shell_quad=[];
    new_shell_tria=[];
    while volume<(actual_volume/3)
    nodes_to_find=[];
    if check==1
        % adds the adjacent elements from current element
        for i=1:length(n)
            f_q=find(shell_quad(:,3:6)==n(i));
            f_q=mod(f_q,length(shell_quad));
            f_q(f_q==0)=length(shell_quad);
            f_t=find(shell_tria(:,3:5)==n(i));
            f_t=mod(f_t,length(shell_tria));
            f_t(f_t==0)=length(shell_tria);
            x=[shell_quad(f_q,7);shell_quad(f_q,10);shell_quad(f_q,13);shell_quad(f_q,16);shell_tria(f_t,6);shell_tria(f_t,9);shell_tria(f_t,12)];
            y=[shell_quad(f_q,8);shell_quad(f_q,11);shell_quad(f_q,14);shell_quad(f_q,17);shell_tria(f_t,7);shell_tria(f_t,10);shell_tria(f_t,13)];
            z=[shell_quad(f_q,9);shell_quad(f_q,12);shell_quad(f_q,15);shell_quad(f_q,18);shell_tria(f_t,8);shell_tria(f_t,11);shell_tria(f_t,14)];
            plot3(x,y,z,'o');hold on;axis equal;
            new_shell_quad=[new_shell_quad;shell_quad(f_q,:)];
            new_shell_tria=[new_shell_tria;shell_tria(f_t,:)];
            nodes_to_find=unique([nodes_to_find;reshape(shell_quad(f_q,3:6),[],1);reshape(shell_tria(f_t,3:5),[],1)]);
            nodes_to_find(nodes_to_find==n(i))=[];
            shell_quad(f_q,:)=[];
            shell_tria(f_t,:)=[];
        end
        n=nodes_to_find;
        area_quad=sum(new_shell_quad,1);
        area_tria=sum(new_shell_tria,1);
        volume=(area_quad(1,19)+area_tria(1,15))*thickness;
    elseif check==2
        % adds the adjacent elements from current element
        for i=1:length(n)
            f_s=find(solids(:,3:10)==n(i));
            f_s=mod(f_s,length(solids));
            f_s(f_s==0)=length(solids);
            x=[solids(f_s,11);solids(f_s,14);solids(f_s,17);solids(f_s,20);solids(f_s,23);solids(f_s,26);solids(f_s,29);solids(f_s,32)];
            y=[solids(f_s,12);solids(f_s,15);solids(f_s,18);solids(f_s,21);solids(f_s,24);solids(f_s,27);solids(f_s,30);solids(f_s,33)];
            z=[solids(f_s,13);solids(f_s,16);solids(f_s,19);solids(f_s,22);solids(f_s,25);solids(f_s,28);solids(f_s,31);solids(f_s,34)];
            plot3(x,y,z,'o');hold on;axis equal;
            new_solids=[new_solids;solids(f_s,:)];
            nodes_to_find=unique([nodes_to_find;reshape(solids(f_s,3:10),[],1)]);
            nodes_to_find(nodes_to_find==n(i))=[];
            solids(f_s,:)=[];
        end
        n=nodes_to_find;
        v=sum(new_solids);
        volume=v(1,35);
    end
    end
    if check==1
    X1=[shell_tria(:,6);shell_tria(:,9);shell_tria(:,12); ...
        shell_quad(:,7);shell_quad(:,10);shell_quad(:,13); ...
        shell_quad(:,16)];
    Y1=[shell_tria(:,7);shell_tria(:,10);shell_tria(:,13); ...
        shell_quad(:,8);shell_quad(:,11);shell_quad(:,14); ...
        shell_quad(:,17)];
    Z1=[shell_tria(:,8);shell_tria(:,11);shell_tria(:,14); ...
        shell_quad(:,9);shell_quad(:,12);shell_quad(:,15); ...
        shell_quad(:,18)];
    X2=[new_shell_tria(:,6);new_shell_tria(:,9);new_shell_tria(:,12); ...
        new_shell_quad(:,7);new_shell_quad(:,10);new_shell_quad(:,13); ...
        new_shell_quad(:,16)];
    Y2=[new_shell_tria(:,7);new_shell_tria(:,10);new_shell_tria(:,13); ...
        new_shell_quad(:,8);new_shell_quad(:,11);new_shell_quad(:,14); ...
        new_shell_quad(:,17)];
    Z2=[new_shell_tria(:,8);new_shell_tria(:,11);new_shell_tria(:,14); ...
        new_shell_quad(:,9);new_shell_quad(:,12);new_shell_quad(:,15); ...
        new_shell_quad(:,18)]; 
    end
    if check==2
    X1=[solids(:,11);solids(:,14);solids(:,17); ...
        solids(:,20);solids(:,23);solids(:,26);solids(:,29);solids(:,32)];
    Y1=[solids(:,12);solids(:,15);solids(:,18); ...
        solids(:,21);solids(:,24);solids(:,27);solids(:,30);solids(:,33)];
    Z1=[solids(:,13);solids(:,16);solids(:,19); ...
        solids(:,22);solids(:,25);solids(:,28);solids(:,31);solids(:,34)];
    X2=[new_solids(:,11);new_solids(:,14);new_solids(:,17); ...
        new_solids(:,20);new_solids(:,23);new_solids(:,26); ...
        new_solids(:,29);new_solids(:,32)];
    Y2=[new_solids(:,12);new_solids(:,15);new_solids(:,18); ...
        new_solids(:,21);new_solids(:,24);new_solids(:,27); ...
        new_solids(:,30);new_solids(:,33)];
    Z2=[new_solids(:,13);new_solids(:,16);new_solids(:,19); ...
        new_solids(:,22);new_solids(:,25);new_solids(:,28); ...
        new_solids(:,31);new_solids(:,34)];
    end
    %% bounding box for the new part 1
    try %calculates the bounding box-----------------
    [rotmat,cornerpoints_1,volume_1,surface_1]=minboundbox(X1,Y1,Z1,'v',1);
    catch
    warning('There has been a warning in calculating the convexhull');
    end
    % centriod calculation---------------
    dist_1=zeros(8,1);
    for af=2:8
    dist_1(af)=sqrt((cornerpoints_1(af,1)-cornerpoints_1(1,1))^2+(cornerpoints_1(af,2)...
        -cornerpoints_1(1,2))^2+(cornerpoints_1(af,3)-cornerpoints_1(1,3))^2);
    end
    [M,J]=max(dist_1);
    centriod_1=(cornerpoints_1(1,:)+cornerpoints_1(J,:))/2;
    a_t_1=sum(shell_tria);
    a_q_1=sum(shell_quad);
    v_s_1=sum(solids);
    area_1=a_t_1(1,15)+a_q_1(1,19);
    if area_1~=0
    actual_volume_1=thickness*area_1;
    else 
    actual_volume_1=v_s_1(1,35);
    end
    fm_1=actual_volume_1/volume_1;
    figure;
    plot3(X1,Y1,Z1,'o');hold on;
    hx = cornerpoints_1(:,1);hy = cornerpoints_1(:,2);hz = cornerpoints_1(:,3);
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
    plot3(centriod_1(1),centriod_1(2),centriod_1(3),'x');axis equal;
    %% bounding box for new part 2
    try %calculates the bounding box-----------------
    [rotmat,cornerpoints_2,volume_2,surface_2]=minboundbox(X2,Y2,Z2,'v',1);
    catch
    warning('There has been a warning in calculating the convexhull');
    end
    % centriod calculation---------------
    dist_2=zeros(8,1);
    for af=2:8
    dist_2(af)=sqrt((cornerpoints_2(af,1)-cornerpoints_2(1,1))^2+(cornerpoints_2(af,2)...
        -cornerpoints_2(1,2))^2+(cornerpoints_2(af,3)-cornerpoints_2(1,3))^2);
    end
    [M,J]=max(dist_2);
    centriod_2=(cornerpoints_2(1,:)+cornerpoints_2(J,:))/2;
    a_t_2=sum(new_shell_tria);
    a_q_2=sum(new_shell_quad);
    v_s_2=sum(new_solids);
    area_2=a_t_1(1,15)+a_q_1(1,19);
    if area_2~=0
    actual_volume_2=thickness*area_2;
    else 
    actual_volume_2=v_s_2(1,35);
    end
    fm_2=actual_volume_2/volume_2;
    figure;
    plot3(X2,Y2,Z2,'o');hold on;
    hx = cornerpoints_2(:,1);hy = cornerpoints_2(:,2);hz = cornerpoints_2(:,3);
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
    plot3(centriod_2(1),centriod_2(2),centriod_2(3),'x');axis equal;
    %%
    new_part_1=[centriod_1(1),centriod_1(2),centriod_1(3),volume_1,fm_1];
    new_part_2=[centriod_2(1),centriod_2(2),centriod_2(3),volume_2,fm_2];