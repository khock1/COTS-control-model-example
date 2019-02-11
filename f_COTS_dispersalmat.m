function [ tempcotsmat ] = f_COTS_dispersalmat( META, RESULT, t, cots_connectivity )
%F_COTS_DISPERSALMAT Summary of this function goes here
%   Detailed explanation goes here
if isstruct(cots_connectivity)
    ccm=cots_connectivity.matrix;
else
    ccm=cots_connectivity;
end
tempcotsmat=zeros(META.nb_reefs);
for rf3 =1:META.nb_reefs
    egg_production = f_COTS_reproduction( RESULT, META, rf3, t );
    if META.COTS_min_selfseed==1%with forced self-seeding
        tempcotsmat(rf3,:)=(1-META.COTS_selfseed)*egg_production*ccm(rf3,:);
        if META.COTS_selfseed>0
            if ccm(rf3,rf3)>0
                tempcotsmat(rf3,rf3)=(META.COTS_selfseed)*egg_production*ccm(rf3,rf3);
            else
                tempcotsmat(rf3,rf3)=(META.COTS_selfseed)*egg_production*max(max(ccm));
            end
        end
    else%without forced self-seeding
        tempcotsmat(rf3,:)=ccm(rf3,:)*egg_production;
    end
end

end

