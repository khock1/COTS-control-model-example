function [ reefs2cull ] = f_COTS_select_reefs( META, RESULT, reefs2visit, top_reef_picks, ...
    top_neighbouring_reefs, neighbouring_reefs_visit, t, REEF_POP )
%F_COTS_SELECTREEF Summary of this function goes here

year=round(t/2);

%   Detailed explanation goes here
switch META.COTS_reefs2cull_strat
    
    case 0%pick a reef with lots of COTS, use current COTS densities on reefs
        adult_cots_dens=RESULT.COTS_adult_densities(:,t+1);
        [ ~, sorted_indices ] = sort( adult_cots_dens(:), 'descend' );

    case 1%estimated COTS larval export connectvity strategy
        %uses future matrix, knowledge of future connectivity perfect
        %pick reef based on short-range connectivity, select only on connectivity
        %see how much COTS larvae are about the be exported; this should
        %already include the size of the COTS population and the potnetial
        %to export; which means that it does not count coral on home reef
        %more, and could ignore large COTS popualtions on sinks,
        
        %sol1
%         %select next year's matrix; so we are precogs
%         [ ~, cots_mat ] = f_conn_select( 2, year+1, META.ACROCNS, META.COTSCNS );
%         %calculate outputs based on this year's COTS population and next year's matrix
%         %cotsmat = f_COTS_dispersalmat( META, RESULT, year, cots_mat );
%         cotsmat = f_COTS_exportpot( META, RESULT, year, cots_mat );
%         %cotsmat=zerodiag(cotsmat);%if we want to ignore self-recruitment
%         cots_exportpot=sum(cotsmat,2);
        %sol2
        %cots_exportpot=RESULT.COTS_larval_output(:,t);
        
        %Looking into the future!!
        
        
        season = iseven(t);
        if season==0
            pick_year=RESULT.WQ_chronology(t+2);
        else
            pick_year=RESULT.WQ_chronology(t+1);
        end
        
        new_density_COTS=zeros(META.nb_reefs,16);
        for rf=1:META.nb_reefs
            temp1_density_COTS = zeros(size(META.COTS_feeding_rates,2),1) ;
            density_COTS=RESULT.COTS_all_densities(rf,t+1,:);
            temp1_density_COTS(2:end) = squeeze(density_COTS(1:(end-1))) ;% Increment the age of all COTS before mortality
            % (note this eradicates the oldest COTS)
            new_density_COTS(rf,:) = (1-META.COTS_mortality').*temp1_density_COTS' ;
        end
        
        mature_COTS_density = squeeze(sum(new_density_COTS(:,META.COTS_fecundity~=0),2)) ;
        fertilization_success = 0.14 * ((10^8)*mature_COTS_density/META.total_area_cm2).^0.61 ;
        fertilization_success(fertilization_success>0.9)=0.9;  %fertilization cap (max obtained by Babcock)
        COTS_densities = squeeze(new_density_COTS(:,:));
        new_COTS_fecundity(:,1) = sum(squeeze(COTS_densities(1:META.nb_reefs,:)).*...
            META.COTS_fecundity(ones(1,META.nb_reefs),:),2).*fertilization_success ;
        
        COTS_output_larvae = new_COTS_fecundity.*META.area_habitat;        
        
        %COTS_output_larvae = RESULT.COTS_fecundity(:,t+1).*META.area_habitat;
                
        if META.doing_water_quality == 1
            % mean Chlorophyll concentration (sum of Chl a) increases larval survivorship
            COTS_output_larvae = COTS_output_larvae.*REEF_POP(pick_year).COTS_larvae_survival(:,season+1) ;
        end
        
        cots_conn_matrix = META.COTSCNS(pick_year).cmlpld;
        COTS_out=zeros(META.nb_reefs);
        for rf1=1:META.nb_reefs
            for rf2=1:META.nb_reefs
                COTS_out(rf1,rf2)=COTS_output_larvae(rf1,1)*cots_conn_matrix(rf1,rf2);
            end
        end
        cots_exportpot=sum(COTS_out,2);
        
        [ ~, sorted_indices ] = sort( cots_exportpot(:), 'descend' );
        
        
    case 2%estimated COTS larval export connectvity strategy
        %uses future matrix, knowledge of future connectivity perfect
        %pick reef based on short-range connectivity, select only on connectivity
        %see how much COTS larvae are about the be exported; this should
        %already include the size of the COTS population and the potnetial
        %to export; which means that it does not count coral on home reef
        %more, and could ignore large COTS popualtions on sinks,
        
        %sol1
%         %select next year's matrix; so we are precogs
%         [ ~, cots_mat ] = f_conn_select( 2, year+1, META.ACROCNS, META.COTSCNS );
%         %calculate outputs based on this year's COTS population and next year's matrix
%         %cotsmat = f_COTS_dispersalmat( META, RESULT, year, cots_mat );
%         cotsmat = f_COTS_exportpot( META, RESULT, year, cots_mat );
%         %cotsmat=zerodiag(cotsmat);%if we want to ignore self-recruitment
%         cots_exportpot=sum(cotsmat,2);
        %sol2
        %cots_exportpot=RESULT.COTS_larval_output(:,t);
        
        %Looking not so much into the future
        
        season = iseven(t);
        if season==0
            pick_year=RESULT.WQ_chronology(t+2);
        else
            pick_year=RESULT.WQ_chronology(t+1);
        end
        
        COTS_output_larvae = RESULT.COTS_fecundity(:,t+1).*META.area_habitat;
                
        if META.doing_water_quality == 1
            % mean Chlorophyll concentration (sum of Chl a) increases larval survivorship
            COTS_output_larvae = COTS_output_larvae.*REEF_POP(pick_year).COTS_larvae_survival(:,season+1) ;
        end
        
        cots_conn_matrix = META.COTSCNS(pick_year).cmlpld;
        COTS_out=zeros(META.nb_reefs);
        for rf1=1:META.nb_reefs
            for rf2=1:META.nb_reefs
                COTS_out(rf1,rf2)=COTS_output_larvae(rf1,1)*cots_conn_matrix(rf1,rf2);
            end
        end
        cots_exportpot=sum(COTS_out,2);
        
        [ ~, sorted_indices ] = sort( cots_exportpot(:), 'descend' );
        
    case 3%pick reef based on short-range connectivity
        %imperfect knowledge of connectivity, probabilistic, more realistic, but sometimes wrong and sensitive to threshold
        
        %calculate centrality metrics for current COTS popualtion density and
        %all connectivity metrics to get probabilties of reef being in top percentile
        top_percentile=80;
        alpha=0.5;
        connmetrics  = f_precalc_conn( RESULT, META, top_percentile, alpha );
        %sort out reefs using centrality; if 1 then weighted outdegree
        centr=1;
        [ ~, sorted_indices ] = sort( connmetrics(:,centr), 'descend' );
        
    case 4%pick reef based on short-range connectivity, only manage picked reefs
        %imperfect knowledge of connectivity, probabilistic, more realistic, but sometimes wrong and sensitive to threshold
        
        %calculate centrality metrics for current COTS population density and
        %all connectivity metrics to get probabilties of reef being in top percentile
        top_percentile=80;
        alpha=0.5;
        connmetrics  = f_precalc_conn( RESULT, META, top_percentile, alpha );
        %sort out reefs using centrality; if 1 then weighted outdegree
        centr=1;
        [ ~, sorted_indices ] = sort( connmetrics(:,centr), 'descend' );
        
    case 5%use short-range connectivity but also consider COTS damage, perfect
        
        
        
    case 6%use short-range connectivity but also consider COTS damage, probabilistic
        
        
        
    case 7%use short-range connectivity but also consider COTS damage and coral recovery, perfect
        
        
        
    case 8%use short-range connectivity but also consider COTS damage and coral recovery, probabilistic
        
        
        
    case 9%consider COTS prevalence on reef and its neighbours, go to best gorup of reefs to minimise time
        
        
        
    case 10%consider COTS prevalence on reef and its neighbours, and their short-range connectivity
        
end

%detemrine whether or not to cull on other reefs around the one that was picked
if META.COTS_cull_surrounding==0
    %pick reefs based only on their predicted COTS numbers score, no neighbours but the same total number picked
    if top_reef_picks<reefs2visit
        top_reef_picks=reefs2visit;
    end
    reefs2cull=sorted_indices(datasample(1:top_reef_picks,reefs2visit,'Replace',false));
else
    %always pick one reef; this means that boats pick sequentially and reevaluate
    picked_reef=sorted_indices(datasample(1:top_reef_picks,1,'Replace',false));
    %if there are any neighbouring reef to visit
    if neighbouring_reefs_visit>0
        %determine distances of other reefs to picked reef; compelx trajectories to be added later
        dist_to_picked=META.COTS_interreef_distances(:,picked_reef);
        %sort by distance, NOT BY COTS DENSITIES - so knowledge plays no role here
        [ ~, sorted_neighb ] = sort( dist_to_picked(:), 'descend' );
        %pick among bneighbouring reefs in random order
        picked_neighb=sorted_neighb(datasample(1:top_neighbouring_reefs,neighbouring_reefs_visit,'Replace',false));
        %determine which reefs to visit, order will be picked reef first, then neighbours
        reefs2cull=vertcat(picked_reef, picked_neighb);
    else
        reefs2cull=picked_reef;
    end
end


%pick reef based on complex connectivity, select only on connectvity
%pick reef based on complex connectivity, manage reefs around it
%pick reef based on complex connectivity and coral connectvity, select only on connectvity
%pick reef based on complex connectivity and coral connectvity, manage reefs around it

%cases that take into account states of reefs downstream WRT coral and COTS
%for example, link strength based on how much coral settlers can
%contribute to sink, and how much COTS settlers can expect to eat coral
%this is dynamic connectivity
end

