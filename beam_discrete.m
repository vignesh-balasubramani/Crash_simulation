%%calculates the length of beam elements
clear all;clear vars;
load('Elements.mat');
load('Nodes.mat')
node_id=nodes(:,1);
for a=1:length(e_beam)
    for b=0:1
        c=find(node_id==e_beam(a,(3+b)));
        co_ord=nodes(c,2:4);
        e_beam(a,6+(b*3):8+(b*3))=co_ord;
    end
    e_beam(a,12)=sqrt((e_beam(a,9)-e_beam(a,6))^2 ...
        +(e_beam(a,10)-e_beam(a,7))^2+(e_beam(a,11)-e_beam(a,8))^2);
end
for d=1:length(e_discrete)
    for e=0:1
        f=find(node_id==e_beam(d,(3+e)));
        co_ord=nodes(f,2:4);
        e_discrete(d,5+(e*3):7+(e*3))=co_ord;
    end
    e_discrete(d,11)=sqrt((e_discrete(d,8)-e_discrete(d,5))^2 ...
        +(e_discrete(d,9)-e_discrete(d,6))^2+(e_discrete(d,10)-e_discrete(d,7))^2);
end
save('elements_beam_discrete.mat','e_discrete','e_beam');