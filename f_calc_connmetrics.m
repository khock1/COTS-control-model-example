function [ connmetrics ] = f_calc_connmetrics ( META )

totyrs=size(META.ACROCNS,2);
totrfs=META.nb_reefs;
C_numlnk=zeros(totrfs,totyrs);
C_export=zeros(totrfs,totyrs);
C_woutdg=zeros(totrfs,totyrs);
C_avgls=zeros(totrfs,totyrs);
for y=1:totyrs
    mat=COTSCNS(y).cmlpld;
    zdmat=zerodiag(mat);
    for reef=1:totrfs
        C_numlnk(reef,y)=nnz(zdmat(reef,:));
        C_export(reef,y)=sum(zdmat(reef,:));
        C_woutdg(reef,y)=weighted_degree(zdmat(reef,find(zdmat(reef,:))),0.5);
        C_avgls(reef,y)=mean(zdmat(reef,find(zdmat(reef,:))));
    end
end


T_numlnk=zeros(totrfs,totyrs);
T_export=zeros(totrfs,totyrs);
T_woutdg=zeros(totrfs,totyrs);
T_avgls=zeros(totrfs,totyrs);

for y=1:totyrs
    T_woutdg(:,y)=tiedrank(C_woutdg(:,y));
    T_avgls(:,y)=tiedrank(C_avgls(:,y));
    T_export(:,y)=tiedrank(C_export(:,y));
    T_numlnk(:,y)=tiedrank(C_numlnk(:,y));
end

pr=totyrs5;
T_woutdg(:,(totyrs+1))=0;
T_export(:,(totyrs+1))=0;
T_numlnk(:,(totyrs+1))=0;
T_avgls(:,(totyrs+1))=0;
for y=1:totyrs
    for r=1:totrfs
        if T_woutdg(r,y)>=prctile(T_woutdg(:,y),pr)
            T_woutdg(r,(totyrs+1))=T_woutdg(r,(totyrs+1))+1;
        end
        if T_export(r,y)>=prctile(T_export(:,y),pr)
            T_export(r,(totyrs+1))=T_export(r,(totyrs+1))+1;
        end
        if T_numlnk(r,y)>=prctile(T_numlnk(:,y),pr)
            T_numlnk(r,(totyrs+1))=T_numlnk(r,(totyrs+1))+1;
        end
        if T_avgls(r,y)>=prctile(T_avgls(:,y),pr)
            T_avgls(r,(totyrs+1))=T_avgls(r,(totyrs+1))+1;
        end
    end
end

connmetrics(:,1)=T_woutdg(:,10)/totyrs;
connmetrics(:,2)=T_numlnk(:,10)/totyrs;
connmetrics(:,3)=T_export(:,10)/totyrs;
connmetrics(:,4)=T_avgls(:,10)/totyrs;

end