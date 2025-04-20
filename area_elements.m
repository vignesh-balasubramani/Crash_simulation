%calculates the area of the elements
%function needed area3D.m
clear vars; clear all;
load('Elements.mat');
load('Nodes.mat')
g=1;h=1;
for f=1:length(e_shell)
    if length(unique(e_shell(f,3:6)))==3
        e_shell_tria(g,1:2)=e_shell(f,1:2);
        e_shell_tria(g,3:5)=unique(e_shell(f,3:6),'stable');
        g=g+1;
    else
        e_shell_quad(h,:)=e_shell(f,:);
        h=h+1;
    end
end
node_id=nodes(:,1);
for c=1:length(e_shell_tria)
    for d=0:2
        e=find(node_id==e_shell_tria(c,(3+d)));
        co_ord=nodes(e,2:4);
        e_shell_tria(c,6+(d*3):8+(d*3))=co_ord;
    end
    X=e_shell_tria(c,6:3:14);
    Y=e_shell_tria(c,7:3:14);
    Z=e_shell_tria(c,8:3:14);
    area=area3D(X',Y',Z');
    e_shell_tria(c,15)=area;
end
for a=1:length(e_shell_quad)
    for b=0:3
        i=find(node_id==e_shell_quad(a,(3+b)));
        co_ord=nodes(i,2:4);
        e_shell_quad(a,7+(b*3):9+(b*3))=co_ord;
    end
    X=e_shell_quad(a,7:3:18);
    Y=e_shell_quad(a,8:3:18);
    Z=e_shell_quad(a,9:3:18);
    area=area3D(X',Y',Z');
    e_shell_quad(a,19)=area;
end
save('Shell_elements_area.mat','e_shell_quad','e_shell_tria');