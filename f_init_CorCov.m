function [ initial_cover ] = f_init_CorCov( META, n )
%F_INIT_CORCOV Summary of this function goes here
%   Detailed explanation goes here

% original META.corcov_initprobs values [ 0.09 ; 0.09 ; 0.09 ; 0.03 ; 0.03 ;0.03 ]

switch META.initial_coral_comm_comp
    case 1%what YM originally used; specify different exact numbers
        initial_cover = META.max_initial_corcov(n)*(META.corcov_initprobs/0.36) ; 
    case 2%random probabilities aroudn the prespecified ones; not known how iniital state affects later fate
        tst=randsample(6,1000,'true',META.corcov_initprobs);
        prbs=[nnz(find(tst==1))/1000 nnz(find(tst==2))/1000 nnz(find(tst==3))/1000 nnz(find(tst==4))/1000 nnz(find(tst==5))/1000 nnz(find(tst==6))/1000];
        initial_cover =META(n).max_initial_corcov*prbs;
        clear tst;
    case 3%use realistic coral community compot
        initial_cover = cns_habitat(n, 5:10);
        
        
end

end

