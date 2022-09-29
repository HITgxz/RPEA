function clustIdx = findclustIdx(post)

[N,M]= size(post);
clustIdx = zeros(N,1);

for i=1:N
    for j=1:M
        if post(i,j)==1
            lie = j;
        end
    end
    clustIdx(i,:)=lie;
end