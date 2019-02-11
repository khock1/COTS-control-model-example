function [ cns_connmetrics ] = f_precalc_conn( RESULT, META, top_percentile, alpha )

%uses current state fo COTS populations to calcualte average centrality
%metrics from connectvity maamtrices for all years

yrs=size(META.COTSCNS,2);
rfs=META.nb_reefs;
C_numlnk=zeros(rfs,yrs);
C_export=zeros(rfs,yrs);
C_woutdg=zeros(rfs,yrs);
C_avgls=zeros(rfs,yrs);

%calculate average centrality metrics using COTS popualtions; does not consider self-recruitment
for y=1:yrs
    mat=META.COTSCNS(y).cmlpld;
    cotsmat = f_COTS_dispersalmat( META, RESULT, y, mat );
    zdmat=zerodiag(cotsmat);
    for reef=1:rfs
        C_numlnk(reef,y)=nnz(zdmat(reef,:));
        C_export(reef,y)=sum(zdmat(reef,:));
        C_woutdg(reef,y)=weighted_degree(zdmat(reef,find(zdmat(reef,:))),alpha);
        C_avgls(reef,y)=mean(zdmat(reef,find(zdmat(reef,:))));
    end
end

%rank centrality metrics
T_numlnk=zeros(rfs,yrs+2);
T_export=zeros(rfs,yrs+2);
T_woutdg=zeros(rfs,yrs+2);
T_avgls=zeros(rfs,yrs+2);

for y1=1:yrs
    T_woutdg(:,y1)=tiedrank(C_woutdg(:,y1));
    T_avgls(:,y1)=tiedrank(C_avgls(:,y1));
    T_export(:,y1)=tiedrank(C_export(:,y1));
    T_numlnk(:,y1)=tiedrank(C_numlnk(:,y1));
end

T_woutdg(isnan(T_woutdg))=0;
T_avgls(isnan(T_avgls))=0;
T_export(isnan(T_export))=0;
T_numlnk(isnan(T_numlnk))=0;

for r1=1:rfs
    T_woutdg(r1,yrs+1)=mean(T_woutdg(r1,1:yrs));
    T_avgls(r1,yrs+1)=mean(T_avgls(r1,1:yrs));
    T_export(r1,yrs+1)=mean(T_export(r1,1:yrs));
    T_numlnk(r1,yrs+1)=mean(T_numlnk(r1,1:yrs));
end

%calculate the number of times rank >= top_percentile
T_woutdg(:,yrs+2)=0;
for y2=1:yrs
    for r2=1:rfs
        if T_woutdg(r2,y2)>=prctile(T_woutdg(:,y2),top_percentile)
            T_woutdg(r2,yrs+2)=T_woutdg(r2,yrs+2)+1;
        end
        if T_export(r2,y2)>=prctile(T_export(:,y2),top_percentile)
            T_export(r2,yrs+2)=T_export(r2,yrs+2)+1;
        end
        if T_numlnk(r2,y2)>=prctile(T_numlnk(:,y2),top_percentile)
            T_numlnk(r2,yrs+2)=T_numlnk(r2,yrs+2)+1;
        end
        if T_avgls(r2,y2)>=prctile(T_avgls(:,y2),top_percentile)
            T_avgls(r2,yrs+2)=T_avgls(r2,yrs+2)+1;
        end
    end
end

cns_connmetrics=zeros(rfs,4);
cns_connmetrics(:,1)=T_woutdg(:,yrs+2)/yrs;
cns_connmetrics(:,2)=T_numlnk(:,yrs+2)/yrs;
cns_connmetrics(:,3)=T_export(:,yrs+2)/yrs;
cns_connmetrics(:,4)=T_avgls(:,yrs+2)/yrs;
cns_connmetrics(isnan(cns_connmetrics))=0;

end