function [ init_densities ] = f_init_COTS( META, n  )
%F_INIT_COTS Summary of this function goes here
%   Detailed explanation goes here


reefs=META.reef_init_COTS;
nb_reefs=META.nb_reefs;
max_age=META.COTS_maximum_age;
choose_distribution=META.COTS_choose_distribution;
distribution=META.COTS_sizeclass_distribution;
%nb_perreef=META.COTS_nb_perreef;
nb_perreef=zeros(1,nb_reefs);
nb_perreef(1,:)=6;

init_densities=zeros(1,1,max_age);

if ismember(n, reefs);
    switch choose_distribution
        case 0%no COTS, all zero
            for rf=1:length(reefs)
                init_densities(1,1,:) = zeros(1,max_age);
            end
        case 1%random COTS size classes on specified reefs
            for rf=1:length(reefs)
                %init_densities(1,1,:) = nb_perreef(rf)*rand(1,max_age);
                init_densities(1,1,:) = nb_perreef(rf)*rand(1,max_age);
            end
        case 2%use a pre-specified distribution per reef
            for rf=1:length(reefs)
                init_densities(1,reefs(rf),:) = distribution(rf,:);
            end
        case 3%distribute COTS number per reef randomly using mortalities across all classes
            cots_probdistr=f_COTS_byClass(COTS_mortalities, max_age, 0);
            for rf=1:length(reefs)
                init_densities(1,reefs(rf),:) = nb_perreef(rf)*cots_probdistr;
            end
        case 4%distribute COTS number per reef using mortalities randomly across adult classes only;
            %expected densities of juveniles are derived from mortalities
            cots_probdistr=f_COTS_byClass(COTS_mortalities, max_age, 1);
            for rf=1:length(reefs)
                init_densities(1,reefs(rf),5:end) = nb_perreef(rf)*cots_probdistr;
            end
        case 5%use probabilistic distribution, with random numbers, for all classes
        case 6%use probabilistic distribution, with random numbers, for adult classes
        case 7%use distribution derived from AMPTO size classes; TO DO
    end
    %add more distributions later, like realistic size classes
    
end
end

