function [mov,links]=align_scout_PV(fix,mov,links)

d=size(fix{1, 1}.Cn);
T1.a=fix{1,1}.A;
T1.d=d;

for i=1:size(mov,2)
    T2.a=mov{1,i}.A;
    T2.d=d;
    T3=align_shapes_scout_pv(T1,T2);
    mov{1,i}.A=T3.a;
end

if ~isempty(links)
    for i=1:size(mov,2)
        T2.a=links{1,i}.A;
        T2.d=d;
        T2=align_shapes_scout_pv(T1,T2);
        links{1,i}.A=T2.a;
    end
else
    links=[];
end

end
