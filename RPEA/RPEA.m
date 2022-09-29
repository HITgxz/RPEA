        function main(Algorithm,Problem)
            %% Parameter setting
            rate = Algorithm.ParameterSet(0.3);
            %% Generate random population
            Population = Problem.Initialization();
            varDim = Problem.D;
            objDim = Problem.M;
            pm = 1.0/varDim;
            popSize = Problem.N;
            objVals = Population.objs;
            r          = -ones(1,2*Problem.N);	% Ratio of size of neighorhood
            t          = -ones(1,2*Problem.N);	% Ratio of knee points
%             Outset = Population;
            %% Optimization
            while Algorithm.NotTerminated(Population)
                [FrontNo,MaxFNo]                = NDSort(Population.objs,Population.cons,Problem.N);
                [~,Deccenter,~,r,t] = Findkneepoints(Population.objs,Population.decs,FrontNo,MaxFNo,r,t,rate);
%                 options = zeros(1,14);
%                 options(1)=-1;   %%用1来表示显示错误值，记录返回参数ERRLOG中的错误值；用0来表示只显示错误值；用-1来表示不显示任何信息%%
%                 options(2)=1e-5;  %%两个连续步骤之间的中值精度（绝对值差）小于规定即满足条件%%
%                 options(3)=1e-5;  %%求解误差函数所需的精度的度量%%
%                 options(14)=100;   %%最大迭代次数，满足该次数时也输出%%
                nClust=size(Deccenter,1);
                pop = Population.decs;
                Outset = Population;
                [~, options, post, ~] = sp_kmeans(Deccenter,pop,options);
                clustIdx = findclustIdx(post);
                NSet=cell(nClust,1);              
                for i=1:nClust
                    mark=clustIdx==i;
                    num=sum(mark);
                    if num>1
                        neigPop=pop(mark,1:varDim);
                    elseif num==1
                        neigPop=zeros(2,varDim);
                        id=randsample(popSize,1);
                        neigPop(1,1:varDim)=pop(mark,1:varDim);
                        neigPop(2,1:varDim)=pop(id,1:varDim);
                        while neigPop(2,1:varDim)==pop(mark,1:varDim)
                            id=randsample(popSize,1);
                            neigPop(2,1:varDim)=pop(id,1:varDim);
                        end
                    end
                    NSet(i,1)={neigPop};
                end   
                for i=1:Problem.N
                    clustLabel=clustIdx(i);%编号
                    NP=NSet{clustLabel,1};
                    NPSize=size(NP,1);
                    if rand<0.5
                        idx=randsample(NPSize,2); 
                        parents(1:2,1:varDim)=NP(idx,1:varDim);
                        y = OperatorDE(Population(i).decs,parents(1,1:varDim),parents(2,1:varDim));
                                            else
                                                idx=randsample(Problem.N,2); parents(1:2,1:varDim)=pop(idx,1:varDim);
                                                y = OperatorDE(Population(i).decs,parents(1,1:varDim),parents(2,1:varDim));
                    end
                   [Outset,FrontNo] = Select(Outset,FrontNo,y);
                end
                Population = Outset;
            end
        end
