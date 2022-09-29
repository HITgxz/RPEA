function [KneePoints,Deccenter,Distance,r,t] = Findkneepoints(PopObj,PopDec,FrontNo,MaxFNo,r,t,rate)
[N,M] = size(PopObj);
alpha = 0.9;

KneePoints = false(1,N);
Distance   = zeros(1,N);

Current = find(FrontNo==1);
if length(Current) <= M
    KneePoints(Current) = 1;
else
    [~,Rank]   = sort(PopObj(Current,:),'descend');
    Extreme    = zeros(1,M);
    Extreme(1) = Rank(1,1);
    for j = 2 : length(Extreme)
        k = 1;
        Extreme(j) = Rank(k,j);
        while ismember(Extreme(j),Extreme(1:j-1))
            k = k+1;
            Extreme(j) = Rank(k,j);
        end
    end
    Hyperplane = PopObj(Current(Extreme),:)\ones(length(Extreme),1);
    Distance(Current) = -(PopObj(Current,:)*Hyperplane-1)./sqrt(sum(Hyperplane.^2));
    Fmax = max(PopObj(Current,:),[],1);
    Fmin = min(PopObj(Current,:),[],1);
    if t == -1
        r = 1;
    else
        r = r/exp((1-t/rate)/M);
    end
    R = Hyperplane*r*((1+alpha)^(1/M)-1);
    [~,Rank] = sort(Distance(Current),'descend');
    Choose   = zeros(1,length(Rank));
    Remain   = ones(1,length(Rank));
    for j = Rank
        if Remain(j)
            for k = 1 : length(Current)
                if abs(PopObj(Current(j),:)-PopObj(Current(k),:)) <= R
                    Remain(k) = 0;
                end
            end
            Choose(j) = 1;
        end
    end
    t = sum(Choose)/length(Current);
    KneePoints([Current(Choose==1) Extreme]) = 1;
    Deccenter = PopDec(KneePoints==1,:);
    
end
end