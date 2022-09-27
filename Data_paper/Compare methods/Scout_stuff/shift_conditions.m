function bool=shift_conditions(assign,j,l,session_ids,change)
bool=(assign(l)~=j)&(~any(session_ids(l)==session_ids(assign==j)))&...
(isempty(change)||(ismember(assign(l),change)||ismember(j,change)));
                  