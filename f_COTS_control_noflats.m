function [ RESULT ] = f_COTS_control( META, RESULT, t, REEF_POP)
%F_COTS_CONTROL Summary of this function goes here
%   Detailed explanation goes here


%include this in some sort of settings file?

%zero out all inputs? remove uncertainty

reefs=META.nb_reefs;

%approximate effort quota for each voyage
voyage_quota=META.COTS_boat_cull_effort/META.COTS_cull_voyages;

%from how many reefs to choose where to focus current voyage;  
%shows how good boats are at picking the best reefs; leave at 1 for always going for the best pick; 
%relaxing this means imperfect knowledge about ranking, but not about presence/absence, connectivity etc
top_reef_picks=1;


%CPUE beyond which the effort is stopped, or the reef is not culled if below this value
%average density of all adult COTS on reef; 0.6 for manta tow<=0.22, 1.35 for manta tow <1
stopping_CPUE=0.6;

%effort wasted if deciding to cull a reef that is below stopping CPUE
%set at half a day of effort, or 2 dives; boat can then immediately move to next reef
daily_quota=META.COTS_boat_cull_effort/META.COTS_cull_days;
wasted_effort=0.5*daily_quota;

%how many voyages to add if there is still unused quota effort after
%standard number of voyages expended; account and compensate for bad luck
%when no COTS are foudn on neihgbourign reefs so the boat turns back early 
%but after wasting some effort
additional_voyages = 2;

%effort mutliplier to figure out how many COTS shoudl actually be killed to get realistic numbers
effort_mutliplier=1;

%keep track of success, effort and time spend doing this
days_at_sea=zeros(reefs,1);
COTS_culled_class=zeros(reefs,META.COTS_maximum_age);
COTS_culled_total=zeros(reefs,1);
culled_reefs=0;

%keep track of densities before culls
RESULT.COTS_dens_b4culls(:,t+1,1:META.COTS_maximum_age) = RESULT.COTS_all_densities(:,t+1,1:META.COTS_maximum_age);
RESULT.COTS_density_adults_b4culls(:,t+1) = RESULT.COTS_adult_densities(:,t+1);

%keep track of coral cover saved over time

cotscs=META.COTS_control_strat(t);
switch cotscs
    case 0%do nothing
        
    case 1%kill all COTS based on detectability; no quota
        
        for reef = 1:length(META.reef_ID)
            n = META.reef_ID(reef);
            this_cots_dens=reshape(RESULT.COTS_all_densities(n,t+1,:),META.COTS_maximum_age,1);
            RESULT.COTS_all_densities(n,t+1,1:META.COTS_maximum_age)=this_cots_dens.*(1-META.COTS_detectability);
            RESULT.COTS_adult_densities(:,t+1)=sum(RESULT.COTS_all_densities(:,t+1,3:end),3);
            
        end
        remaining_COTS=reshape(RESULT.COTS_all_densities(:,t+1,1:META.COTS_maximum_age),reefs,META.COTS_maximum_age);
        remaining_COTSa=RESULT.COTS_adult_densities(:,t+1);
        
    case 2%pick which reefs to visit, based on META.COTS_reefs2cull_strat, using quota
        
        %calculate the initial quota based on effort and number of boats
        remaining_quota=META.COTS_boat_cull_effort*META.COTS_cull_boats;
        %initial number of voyages per 6 months
        remaining_voyages=META.COTS_cull_voyages*META.COTS_cull_boats;
        %initial number of COTS per size class and total COTS adults
        remaining_COTS=reshape(RESULT.COTS_all_densities(:,t+1,1:META.COTS_maximum_age),reefs,META.COTS_maximum_age);
        remaining_COTSa=RESULT.COTS_adult_densities(:,t);
        %while there are still voyages remaining
        while remaining_voyages>0
            %first determine how many reefs to visit on this voyage
            reefs2visit=poissrnd(4.73404);%from AMPTO
            %reefs2visit=1;
            %max number of reefs around selected reef that the boat would also visit opportunistically;
            %set at 1 if boat only visits selected reef; real ampto data shows poissrnd(4.73404) per voyage, minus one that is selected
            neighbouring_reefs_visit=top_reef_picks-reefs2visit;
            %from how many neighbouring reefs to choose where to go besides focal reef;
            %should be a bit higher than number to visit opportunistically, otherwise it is perfectly
            %aligned to distance from focal reef; FOR NOW, THIS IS NOT RELATED TO COTS DENSITIES FOUND ON THOSE REEFS
            if neighbouring_reefs_visit<=9
                top_neighbouring_reefs=10;
            else
                top_neighbouring_reefs=neighbouring_reefs_visit+1;
            end
            %now calculate how effort quota is spent
            if remaining_quota>(daily_quota*2)%if there is still quota to expend, else break loop
                %if there is still effort to expend that is more than average voyage quota
                if remaining_quota>(voyage_quota*META.COTS_cull_boats)
                    this_quota=voyage_quota;
                else%else spend all of it
                    this_quota=remaining_quota;
                end
            else
                break;
            end
            
            %strategy seelcting reefs to visit based on META.COTS_reefs2cull_strat
            reefs2cull=f_COTS_select_reefs( META,RESULT,reefs2visit, top_reef_picks,top_neighbouring_reefs,neighbouring_reefs_visit, t, REEF_POP );
            
            for this_visit=1:length(reefs2cull)
                this_reef=reefs2cull(this_visit,1);
                this_cots_dens=remaining_COTS(this_reef,:);
                this_area=META.area_habitat(this_reef,1)*10^6;
                if sum(this_cots_dens(1,3:end))>stopping_CPUE%if there are more adult COTS than stopping rule
                    if this_area<(this_quota*1.05)%reef allowed to exceed quota by 5%; more means leess unused quota in the end
                        %fully eradicate
                        tempCC=remaining_COTS(this_reef,:);
                        remaining_COTS(this_reef,:)=this_cots_dens.*transpose((1-META.COTS_detectability));
                        remaining_COTS(remaining_COTS<0)=0;
                        remaining_quota=remaining_quota-this_area;
                        this_quota=this_quota-this_area;
                        days_at_sea(this_reef,1)=days_at_sea(this_reef,1)+(this_quota/daily_quota);
                        COTS_culled_class(this_reef,:)=round(COTS_culled_class(this_reef,:)+((tempCC-remaining_COTS(this_reef,:))*(this_area/400)));
                        COTS_culled_total(this_reef,1)=round(COTS_culled_total(this_reef,1)+sum(COTS_culled_class(this_reef,:)));
                        culled_reefs=culled_reefs+1;
                    else%reef is too big to cull with the remaining voyage quota; if this is 1st reef on voyage, then eradication may only be partial
                        tempCC=remaining_COTS(this_reef,:);
                        %calcualte how much of the reef can be eradicated
                        prc_area_culled=this_quota/this_area;
                        part_effort=(META.COTS_detectability).*prc_area_culled;%*effort_mutliplier
                        %this is uniform, not spatially explicit
                        remaining_COTS(this_reef,:)=this_cots_dens.*transpose((1-part_effort));
                        remaining_COTS(remaining_COTS<0)=0;
                        days_at_sea(this_reef,1)=days_at_sea(this_reef,1)+(this_quota/daily_quota);
                        COTS_culled_class(this_reef,:)=round(COTS_culled_class(this_reef,:)+((tempCC-remaining_COTS(this_reef,:))*(this_quota/400)));
                        COTS_culled_total(this_reef,1)=round(COTS_culled_total(this_reef,1)+sum(COTS_culled_class(this_reef,:)));
                        remaining_quota=remaining_quota-this_quota;
                        this_quota=0;%all quota expended, so it will break after this
                        culled_reefs=culled_reefs+1;
                    end
                else%else waste half a day worth of area to searching, cull for half a day, and move on
                    tempCC=remaining_COTS(this_reef,:);
                    if wasted_effort>this_area
                        wasted_effort=this_area;
                    end
                    prc_area_culled=wasted_effort/this_area;
                    part_effort=(META.COTS_detectability)*prc_area_culled;
                    remaining_COTS(this_reef,:)=this_cots_dens.*transpose(part_effort);
                    remaining_COTS(remaining_COTS<0)=0;
                    this_quota=this_quota-wasted_effort;
                    days_at_sea(this_reef,1)=days_at_sea(this_reef,1)+0.5;
                    COTS_culled_class(this_reef,:)=round(COTS_culled_class(this_reef,:)+((tempCC-remaining_COTS(this_reef,:))*(wasted_effort/400)));
                    COTS_culled_total(this_reef,1)=round(COTS_culled_total(this_reef,1)+sum(COTS_culled_class(this_reef,:)));
                    remaining_quota=remaining_quota-wasted_effort;
                    culled_reefs=culled_reefs+1;
                end
                if this_quota<(daily_quota/0.501)%if there is less than half a day effort left, break
                    break;
                end
            end
            remaining_voyages=remaining_voyages-1;
            %if quota remaining is greater than single voyage quota but voyage is 0 ie last, add another voyage for at elast two more
            if remaining_quota>voyage_quota && remaining_voyages==0
                if additional_voyages>0
                    remaining_voyages=1;
                    additional_voyages=additional_voyages-1;
                end
            end
        end
        
        
        %update COTS populations as a result of culls
        remaining_COTSa(:,1)=sum(remaining_COTS(:,3:end),2);
        RESULT.COTS_all_densities(:,t+1,1:META.COTS_maximum_age)=reshape(remaining_COTS,reefs,1,META.COTS_maximum_age);
        RESULT.COTS_adult_densities(:,t+1)=remaining_COTSa(:,1);
        %keep track of impact of the effort
        RESULT.COTS_culling_days(:,t)=ceil(days_at_sea*2)/2;
        RESULT.COTS_culled_class(:,t,1:META.COTS_maximum_age)=reshape(COTS_culled_class,reefs,1,META.COTS_maximum_age);
        RESULT.COTS_culled_total(:,t)=COTS_culled_total;
        RESULT.COTS_culled_reefs(1,t)=culled_reefs;
        RESULT.COTS_culled_overall(1,t)=sum(COTS_culled_total);
end





end

