function concatenate_data_matrices(fileName2, listToConcatenate)
%Concatenate data matrices
load (listToConcatenate{1});
px = x;
py = y;
pl = listOfFileNames;
pdv = divplane;
pc = coords;
pa = angles;
pf = f_width;

for i = 2:length(listToConcatenate)
    load(listToConcatenate{i});
    px = [px x];
    py = [py y];
    pl = [pl listOfFileNames];
    pdv = [pdv divplane];
    pc = [pc coords];
    pa = [pa angles];
    pf = [pf f_width];
end

x = px;
y = py;
listOfFileNames = pl;
divplane = pdv;
coords = pc;
angles = pa;
f_width = pf;
save(fileName2, "x", "y", "divplane", "listOfFileNames", "coords", "angles", "f_width");
end