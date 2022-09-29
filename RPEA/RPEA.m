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
%                 options(1)=-1;   %%��1����ʾ��ʾ����ֵ����¼���ز���ERRLOG�еĴ���ֵ����0����ʾֻ��ʾ����ֵ����-1����ʾ����ʾ�κ���Ϣ%%
%                 options(2)=1e-5;  %%������������֮�����ֵ���ȣ�����ֵ�С�ڹ涨����������%%
%                 options(3)=1e-5;  %%�����������ľ��ȵĶ���%%
%                 options(14)=100;   %%����������������ô���ʱҲ���%%
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
                    clustLabel=clustIdx(i);%���
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
