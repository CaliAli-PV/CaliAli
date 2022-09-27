function [in,f1,opti]=get_t_score_SCOUT(GT,in)

for i=1:numel(in)
    in{i}=align_shapes_con(GT,in{i});
    [in{i}.m,in{i}.s]=calculate_best_matching_score2(GT.a,in{i}.a,GT.c,in{i}.c);
    in{i}.t=get_errors_2(in{i}.m,size(GT.c,1));
end

f1=zeros(size(in));
for i=1:numel(f1)
f1(i)=table2array(in{i}.t(80,1));
end

[~,I]=max(f1,[],'all');

opti=in{I};

