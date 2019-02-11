function [ reefs2cull ] = f_COTS_select_reefs( META, remaining_COTSa, top_reef_picks, ...
    top_neighbouring_reefs, neighbouring_reefs_visit, t )
%F_COTS_SELECTREEF Summary of this function goes here

year=round(t/2);

%   Detailed explanation goes here
switch META.COTS_reefs2cull_strat
    
    case 0%pick a reef with lots of COTS, %determine current COTS densities on reefs
        adult_cots_dens=remaining_COTSa;
        [ ~, sorted_indices ] = sort( adult_cots_dens(:), 'descend' );
        %pick reefs based only on their predicted COTS numbers score, no neighbours but the same total number picked
        reefs2cull=sorted_indices(datasample(1:top_reef_picks,neighbouring_reefs_visit+1,'Replace',false));
        
    case 1%pick a reef with lots of COTS, manage reefs around it from total quota remaining
        
        adult_cots_dens=remaining_COTSa;
        [ ~, sorted_indices ] = sort( adult_cots_dens(:), 'descend' );
        %always pick one reef; this means that boats pick sequentially and reevaluate
        picked_reef=sorted_indices(datasample(1:top_reef_picks,1,'Replace',false));
        %if there are any neighbouring reef to visit
        if neighbouring_reefs_visit>0
            %determine distances of other reefs to picked reef
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
        
        
        
    case 2%estimated COTS larval export connectvity strategy, no neighbours
        %uses future matrix, knowledge of future connectivity perfect
        %pick reef based on short-range connectivity, select only on connectivity
        %see how much COTS larvae are about the be exported; this should
        %already include the size of the COTS population and the potnetial
        %to export; which means that it does not count coral on home reef
        %more, and could ignore large COTS popualtions on sinks,
        
        %select next year's matrix; so we are precogs
        [ ~, cots_mat ] = f_conn_select( 2, year+1, META.ACROCNS, META.COTSCNS );
        %calculate outputs based on this year's COTS population and next year's matrix
        cotsmat = f_COTS_dispersalmat( META, RESULT, year, cots_mat );
        cots_exportpot=sum(cotsmat,2);
        [ ~, sorted_indices ] = sort( cots_exportpot(:), 'descend' );
        %pick reefs based only on their predicted export score, no neighbours but the same total number picked
        reefs2cull=sorted_indices(datasample(1:top_reef_picks,neighbouring_reefs_visit+1,'Replace',false));
        
    case 3%estimated COTS larval export connectvity strategy, with neighbours
        %uses future matrix, knowledge of future connectivity perfect
        %pick reef based on short-range connectivity, select neihgbours as well
        %see how much COTS larvae are about the be exported; this should
        %already include the size of the COTS population and the potnetial
        %to export; which means that it does not count coral on home reef
        %more, and could ignore large COTS popualtions on sinks,
        %neighbours are opportunistic
        
        %select next year's matrix; so we are precogs
        [ ~, cots_mat ] = f_conn_select( 2, year+1, META.ACROCNS, META.COTSCNS );
        %calculate outputs based on this year's COTS population and next year's matrix
        cotsmat = f_COTS_dispersalmat( META, RESULT, year, cots_mat );
        cots_exportpot=sum(cotsmat,2);
        [ ~, sorted_indices ] = sort( cots_exportpot(:), 'descend' );
        %always pick one reef; this means that boats pick sequentially and reevaluate
        picked_reef=sorted_indices(datasample(1:top_reef_picks,1,'Replace',false));
        %if there are any neighbouring reef to visit
        if neighbouring_reefs_visit>0
            %determine distances of other reefs to picked reef
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
        
    case 4%pick reef based on short-range connectivity, manage reefs around it
        %imperfect knowledge of connectivity, probabilistic, more realistic, but sometimes wrong and sensitive to threshold
        
        %calculate centrality metrics for current COTS popualtion density and
        %all connectivity metrics to get probabilties of reef being in top percentile
        top_percentile=80;
        alpha=0.5;
        connmetrics  = f_precalc_conn( RESULT, META, top_percentile, alpha );
        %sort out reefs using centrality; if 1 then weighted outdegree
        centr=1;
        [ ~, sorted_indices ] = sort( connmetrics(:,centr), 'descend' );
        %always pick one reef; this means that boats pick sequentially and reevaluate
        picked_reef=sorted_indices(datasample(1:top_reef_picks,1,'Replace',false));
        %if there are any neighbouring reef to visit
        if neighbouring_reefs_visit>0
            %determine distances of other reefs to picked reef
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
        
    case 5%pick reef based on short-range connectivity, only manage picked reefs
        %imperfect knowledge of connectivity, probabilistic, more realistic, but sometimes wrong and sensitive to threshold
        
        %calculate centrality metrics for current COTS population density and
        %all connectivity metrics to get probabilties of reef being in top percentile
        top_percentile=80;
        alpha=0.5;
        connmetrics  = f_precalc_conn( RESULT, META, top_percentile, alpha );
        %sort out reefs using centrality; if 1 then weighted outdegree
        centr=1;
        [ ~, sorted_indices ] = sort( connmetrics(:,centr), 'descend' );
        %pick reefs based only on their predicted export score, no neighbours but the same total number picked
        reefs2cull=sorted_indices(datasample(1:top_reef_picks,neighbouring_reefs_visit+1,'Replace',false));
        
    case 6%use short-range connectivity but also consider COTS damage, perfect
        
        
        
    case 7%use short-range connectivity but also consider COTS damage, probabilistic
        
        
        
    case 8%use short-range connectivity but also consider COTS damage and coral recovery, perfect
        
        
        
    case 9%use short-range connectivity but also consider COTS damage and coral recovery, probabilistic
        
        
        
    case 10%consider COTS prevalence on reef and its neighbours
        
        
        
    case 11%consider COTS prevalence on reef and its neighbours, and their short-range connectivity
        
end

%detemrien whether or not to cull on other reefs around the one that was picked
if META.COTS_cull_surrounding==0
    %pick reefs based only on their predicted COTS numbers score, no neighbours but the same total number picked
    reefs2cull=sorted_indices(datasample(1:top_reef_picks,neighbouring_reefs_visit+1,'Replace',false));
else
    %always pick one reef; this means that boats pick sequentially and reevaluate
    picked_reef=sorted_indices(datasample(1:top_reef_picks,1,'Replace',false));
    %if there are any neighbouring reef to visit
    if neighbouring_reefs_visit>0
        %determine distances of other reefs to picked reef
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
%contribute to sink, and how much COTS sttlers can expect to eat coral
%this is dynamic connectivity
end

