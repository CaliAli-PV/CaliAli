function register=extract_cell_register(idx,nodes,node_sessions,size_vec)

register=zeros(max(idx),length(size_vec));
for k=1:length(nodes)
    sess=node_sessions(k);
    index=nodes(k)-sum(size_vec(1:sess-1));
    register(idx(k),sess)=index;
end
  