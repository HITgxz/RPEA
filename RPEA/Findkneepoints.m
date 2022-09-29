function [KneePoints,Deccenter,Distance,r,t] = Findkneepoints(PopObj,PopDec,FrontNo,MaxFNo,r,t,rate)



[N,M] = size(PopObj);
alpha = 0.9;

%% Find the knee points in each front
KneePoints = false(1,N);
Distance   = zeros(1,N);

Current = find(FrontNo==1);
if length(Current) <= M
    KneePoints(Current) = 1;
else
    % Find the extreme points
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
    % Calculate the hyperplane
    Hyperplane = PopObj(Current(Extreme),:)\ones(length(Extreme),1);
    % Calculate the distance of each solution to the hyperplane
    Distance(Current) = -(PopObj(Current,:)*Hyperplane-1)./sqrt(sum(Hyperplane.^2));
    % Update the range of neighbourhood
    Fmax = max(PopObj(Current,:),[],1);
    Fmin = min(PopObj(Current,:),[],1);
    if t == -1
        r = 1;
    else
        r = r/exp((1-t/rate)/M);
    end
%  Current_2 = find(max(PopObj(Current,:)));   
    % Adjust the size of the neighborhood
    % R = norm(Fmax-Fmin).*r(i)*((1+alpha)^(1/M)-1);
    % R = (Fmax-Fmin).*r(i);
    R = Hyperplane*r*((1+alpha)^(1/M)-1);
%     save('test.mat','r')
%     save('test1.mat','R')
    % Select the knee points
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
    save('test2.mat','t')
    KneePoints([Current(Choose==1) Extreme]) = 1;
%     KneePoints(Current(Extreme))=1;
%     KneePoints(Fmin==1)=1;
    Deccenter = PopDec(KneePoints==1,:);
    
end
end