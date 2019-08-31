function output = stackTraces(donor, acceptor, nstack)
assert(length(donor) == length(acceptor), ...
    "Must have same length for donor and acceptor");
ntime = length(donor);
output = zeros(nstack * 2, ntime);
traces.donor(1,:);
for i = 1 : nstack
    output(i,:) = circshift(donor,[0,-i]);
end
for i = 1 : nstack
    output(nstack + i,:) = circshift(acceptor(:),[0,-i]);
end
output = output(:,1 : ntime-nstack);

