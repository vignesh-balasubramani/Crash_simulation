function A = boundingbox(n)
%calculates the minimum bounding box
    B_max=max(n);
    B_min=min(n);
    Bounds=B_max(:,1:3)-B_min(:,1:3);
    Centroid=(B_max(:,1:3)+B_min(:,1:3))/2;
    A=[Bounds,Centroid];
end