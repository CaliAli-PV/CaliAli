function sim=get_cosine(A,w)

for i=1:size(w,1)
    co(i)=dot(A,w(i,:))/(norm(A)*norm(w(i,:)));
end
co(isnan(co))=0;
sim=1-co;
end

    