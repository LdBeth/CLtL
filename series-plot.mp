input metaflow
prologues := 2;
%filenametemplate "%j-%c.ps";
verbatimtex \input cltlmac etex
beginfig(1);
  u=0.8pt;
  z2c = (20u,0);
  z2s = (40u,40u);
  draw rect2(btex scan etex);
  drawarrow (z2ml+(-20u,0))--z2ml;
  z3c = z2c + (80u,-17u);
  z3s = (40u,40u);
  draw rect3(btex sum etex);
  drawarrow z2mr--(z2mr+(10u,0))--(z3ml+(-20u,0))--z3ml;
  putitem4 u*30right of 3;
  z4s = (40u,40u);
  draw rect4(btex series etex);
  drawarrow z3mr--z4ml;
  for i:=0 upto 4:
    draw ((z3mr+u*((5+i*4),4)))--((z3mr+u*((5+i*4),-4)));
  endfor;
  z5ml = z4mr+(30u,17u);
  z5s = (40u,40u);
  draw rect5(btex \Xsharp{}M/ etex);
  drawarrow z4mr--(z4mr+(30u,0));
  drawarrow (z2mr+(10u,0))--(z3ml+(-20u,34u))--z5ml+(0,17u);
  putitem6 u*30right of 5;
  z6s = u*(40,40);
  draw rect6(btex max etex);
  drawarrow z5mr--z6ml;
  drawarrow z6mr--(z6mr+(20u,0));
endfig;
end;
