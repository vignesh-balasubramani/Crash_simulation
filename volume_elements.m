clear vars;clear all;
load('Elements.mat');
load('Nodes.mat');
node_id=nodes(:,1);
for k=1:length(e_solids)
    for l=0:7
        m=find(node_id==e_solids(k,(3+l)));
        co_ord=nodes(m,2:4);
        e_solids(k,11+(l*3):13+(l*3))=co_ord;
    end
end
for n=1:length(e_solids)
    x=e_solids(n,11:3:34);
    y=e_solids(n,12:3:34);
    z=e_solids(n,13:3:34);
    [p,vol]=convhulln([x',y',z']);
    e_solids(n,35)=vol;
end
save('Solid_elements_volume.mat','e_solids');