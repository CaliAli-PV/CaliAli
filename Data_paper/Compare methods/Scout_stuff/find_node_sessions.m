function node_sessions=find_node_sessions(nodes,size_vec)
node_sessions=-1*ones(1,length(nodes));
size_vec=[1,size_vec];
for k=1:length(nodes)
    for j=1:length(size_vec)
        if nodes(k)>=sum(size_vec(1:j)) & nodes(k)<sum(size_vec(1:j+1))
            node_sessions(k)=j;
            break
        end
    end
end