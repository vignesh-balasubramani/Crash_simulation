% takes the bounded parts and filters it based upon 
% 1.x-distance
% 2.splits them based upon fm
% 3.if they are completely enclosed within other parts
% 4.Threshold volume
% Inputs needed     : Parts.mat (all the element definitions)
%                     Shell_elements_area.mat
%                     Solid_elements_volume.mat
%                     elements_beam_discrete.mat
% functions needed  : split_part.mat
% Outputs           : Parts_filtered.mat
clearvars;
load('Parts_bounded.mat');
load('Shell_elements_area.mat');
load('Solid_elements_volume.mat');
load('elements_beam_discrete.mat');
check=cell2mat(Parts.centriod_x);
a=check<-1000; % x-distance
Parts(a,:)=[];
Parts=sortrows(Parts,10);
check_vol=Parts.actual_volume;
ak=(check_vol==0);
Parts(ak,:)=[];
ad=1;
aa=1;
[ai,aj]=size(Parts);
ay=1;
%% splits parts
for ax=1:size(Parts)
    if Parts.fm(ax)<0.003%% condition can be changed
        [new_part_1,actual_volume_1,cornerpoints_1,...
            new_part_2,actual_volume_2,cornerpoints_2]=split_part(ax); % calls function split_part.m        
    new_part_list(ay,1:3)=Parts(ax,1:3);
    new_part_list{ay,4}=actual_volume_1;
    new_part_list{ay,5}={cornerpoints_1};
    new_part_list{ay,6:10}=new_part_1;
    new_part_list(ay+1,1:3)=Parts(ax,1:3);
    new_part_list{ay+1,4}=actual_volume_2;
    new_part_list{ay+1,5}={cornerpoints_2};
    new_part_list{ay+1,6:10}=new_part_2;
    ay=ay+2;
    end
end
%% filter for checking if the parts are enclosed by other parts
while aa<=ai
    ab=aa+1;
    checker=0;
    cornerpoints=cell2mat(Parts.cornerpoints(aa));
    b=1;
    %calculate the direction vector of the three sides of the bounding box
    vectors=zeros(7,3);
    for a=2:8
        vectors(b,:)=cornerpoints(a,:)-cornerpoints(1,:);
        b=b+1;
    end
    d=1;
    dot_product=zeros(6,1);
    for c=2:7
        dot_product(d)=round(dot(vectors(1,:)',vectors(c,:)'));
         d=d+1;
    end
    e=dot_product~=0;
    f=vectors(2:7,:);
    f(e,:)=[];
    h=1;
    dot_product_2=zeros(2,1);
    for g=2:3
        dot_product_2(h)=round(dot(f(1,:)',f(g,:)'));
        h=h+1;
    end
    i=dot_product_2~=0;
    j=f(2:3,:);
    j(i,:)=[];
    % three direction vectors
    u=vectors(1,:)';
    v=f(1,:)';
    w=j';
    ae=2;
    %check if the centriod and all the corner points are falling inside the
    %current bounding box
    [ag,ah]=size(Parts);
    while ab<=ag
        point=cell2mat(Parts{ab,6:8});
        x=(point-cornerpoints(1,:))';
        check1=dot(x,u);
        check2=dot(x,v);
        check3=dot(x,w);
        bound1=dot(u,u);
        bound2=dot(v,v);
        bound3=dot(w,w);
        if 0<check1 && check1<bound1 && 0<check2 && check2<bound2 ...
            && 0<check3 && check3<bound3
            cp=Parts.cornerpoints{ab};
            ac=0;
            for ac=1:8
                point=cp(ac,:);
                x=(point-cornerpoints(1,:))';
                check1=dot(x,u);
                check2=dot(x,v);
                check3=dot(x,w);
                bound1=dot(u,u);
                bound2=dot(v,v);
                bound3=dot(w,w);
                if ~(0<check1 && check1<bound1 && 0<check2 && check2<bound2 ...
                    && 0<check3 && check3<bound3)
                    break
                end
            end
            if ac<=7
                ab=ab+1;
            elseif ac==8
                enclosed_part_id(ad,1)=Parts.pid(aa);
                enclosed_part_id(ad,ae)=Parts.pid(ab);
                ae=ae+1;
                Parts(ab,:)=[];
                [ag,ah]=size(Parts);
                checker=1;
            end
        else
            ab=ab+1;
        end
    end
    if checker==1
        ad=ad+1;
    end
    aa=aa+1;
    [ai,aj]=size(Parts);
end
%% filter for checking if the part fits the threshold volume
Parts=sortrows(Parts,4);
threshold=100000;
bf=1;
bc=1;
while Parts.actual_volume(bc)<threshold
    c_current=cell2mat(Parts{bc,6:8});
    bg=2;
    vol=Parts.actual_volume(bc);
    new_part(bf,1)=Parts.pid(bc);
    % adds the adjacent part till the actual volume crosses the threshold
    % volume
    while 1
        centriod=cell2mat([Parts.centriod_x,Parts.centriod_y, ...
            Parts.centriod_z]);
        euc_dist=zeros(length(centriod),1);
        for bd=1:length(centriod)
            euc_dist(bd)=sqrt((centriod(bd,1)-c_current(1,1))^2+ ...
            (centriod(bd,2)-c_current(1,2))^2+ ...
            (centriod(bd,3)-c_current(1,3))^2);
        end
        Min=min(euc_dist(euc_dist~=0));
        be=find(Min==euc_dist);
        if length(be)>1
            be=be(1);
        end
        new_part(bf,bg)=Parts.pid(be);
        bg=bg+1;
        vol=vol+Parts.actual_volume(be);
        Parts(be,:)=[];
        if vol>threshold
            Parts(bc,:)=[];
            centriod(bc,:)=[];
            bf=bf+1;
            break
        end
    end
end
[da,db]=size(new_part);
%% calulating bounding boxes for the new_part
for dc=1:da
    beam=zeros(size(e_beam));
    discrete=zeros(size(e_discrete));
    shell_quad=zeros(size(e_shell_quad));
    shell_tria=zeros(size(e_shell_tria));
    solids=zeros(size(e_solids));
    for dd=1:db
        dp=new_part(dc,dd);
        if dp~=0
           beam_l=ismember(e_beam(:,2),dp);
           discrete_l=ismember(e_discrete(:,2),dp);
           shell_tria_l=ismember(e_shell_tria(:,2),dp);
           shell_quad_l=ismember(e_shell_quad(:,2),dp);
           solids_l=ismember(e_solids(:,2),dp);
           t_beam=e_beam.*(double([zeros(length(e_beam),2),repelem(beam_l,1,10)]));
           t_discrete=e_discrete.*(double([zeros(length(e_discrete),2),repelem(discrete_l,1,9)]));
           t_shell_tria=e_shell_tria.*(double([zeros(length(e_shell_tria),2),repelem(shell_tria_l,1,13)]));
           t_shell_quad=e_shell_quad.*(double([zeros(length(e_shell_quad),2),repelem(shell_quad_l,1,17)]));
           t_solids=e_solids.*(double([zeros(length(e_solids),2),repelem(solids_l,1,33)]));
           beam=[beam;t_beam];
           discrete=[discrete;t_discrete];
           shell_quad=[shell_quad;t_shell_quad];
           shell_tria=[shell_tria;t_shell_tria];
           solids=[solids;t_solids];
        end
    end
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
        [rotmat,cornerpoints,volume,surface]=minboundbox(X,Y,Z,'v',1);
    catch
        warning('There has been a warning in calculating the convexhull');
        disp(dd);
    end
    % centriod calculation---------------
    dist=zeros(8,1);
    for da=2:8
        dist(da)=sqrt((cornerpoints(da,1)-cornerpoints(1,1))^2+(cornerpoints(da,2)...
            -cornerpoints(1,2))^2+(cornerpoints(da,3)-cornerpoints(1,3))^2);
    end
    [M,i]=max(dist);
    centriod=(cornerpoints(1,:)+cornerpoints(i,:))/2;
% plots the new part
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
    plot3(centriod(1),centriod(2),centriod(3),'x'); hold on;
    axis equal;
end
%% plots parts
for zz=1:size(Parts)
    col='b';
    cornerpoints=cell2mat(Parts.cornerpoints(zz));
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
    hold on;
    centriod=cell2mat(Parts{zz,6:8});
    plot3(centriod(1,1),centriod(1,2),centriod(1,3),'x'); hold on;
    axis equal;
end
save('Parts_filtered.mat','Parts','new_part','enclosed_part_id');