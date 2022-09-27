function S=create_similarity_matrix_2(m1,m2);

% SA_t1=create_similarity_matrix_2(t1_A,All_A);
% SC_t1=create_similarity_matrix_2(t1_C,All_C(:,1:1000));


m1=full(m1)';
m2=full(m2)';

S=zeros(size(m1,2),size(m2,2));

parfor i=1:size(m1,2)
    S(i,:)=1-get_cosine(m1(:,i)',m2');
end
    


