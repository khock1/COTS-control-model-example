function [ tempcotsmat ] = f_COTS_exportpot( META, RESULT, t, dispersalmat )


if isstruct(dispersalmat)
    ccm=dispersalmat.matrix;
else
    ccm=dispersalmat;
end
tempcotsmat=zeros(META.nb_reefs);
for rf3 =1:META.nb_reefs
    egg_production = RESULT.COTS_fecundity(rf3,t);
    if META.force_COTS_selfseed==1%with forced self-seeding
        tempcotsmat(rf3,:)=(1-META.COTS_min_selfseed)*egg_production*ccm(rf3,:);
        if META.COTS_min_selfseed>0
            if ccm(rf3,rf3)>0
                tempcotsmat(rf3,rf3)=(META.COTS_min_selfseed+((1-META.COTS_min_selfseed)*ccm(rf3,rf3)))*egg_production;
            else
                tempcotsmat(rf3,rf3)=(META.COTS_min_selfseed)*egg_production;%*max(max(ccm))
            end
        end
    else%without forced self-seeding
        tempcotsmat(rf3,:)=ccm(rf3,:)*egg_production;
    end
end

end