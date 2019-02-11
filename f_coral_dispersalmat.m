function [ tempcoralmat ] = f_coral_dispersalmat( META, RESULT, t, coral_connectivity )
%F_CORAL_DISPERSALMAT Summary of this function goes here
%   Detailed explanation goes here

for s=1:META.nb_coral_types %
    % First weigh output larvae by proportional suitable habitat for Montastraea
    output_larvae = RESULT.total_fecundity(:,t,s).*META.area_habitat;
    % Now larvae are distributed over the connected reefs
    
    % Karlo says: I THINK THIS SHOULD WORK - first calcualte outputs,
    % then add them up for each sink - but check
    tempcoralmat=zeros(META.nb_reefs);
    for rf1 =1:META.nb_reefs
        if META.force_coral_selfseed==1%with forced self-seeding
            tempcoralmat(rf1,:)=(1-META.coral_selfseed)*output_larvae(rf1)*coral_connectivity(s).matrix(rf1,:);
            if META.coral_selfseed>0
                if coral_connectivity(s).matrix(rf1,rf1)>0
                    tempcoralmat(rf1,rf1)=(META.coral_selfseed)*output_larvae(rf1)*coral_connectivity(s).matrix(rf1,rf1);
                else
                    tempcoralmat(rf1,rf1)=(META.coral_selfseed)*output_larvae(rf1)*max(max(coral_connectivity(s).matrix));
                end
            end
        else%without forced self-seeding
            tempcoralmat(rf1,:)=output_larvae(rf1)*coral_connectivity(s).matrix(rf1,:);
        end
    end
    

    %RESULT.input_larvae(:,t,s) = transp(output_larvae)*coral_connectivity(s).matrix ;
    % Matrix multiplication1 (Connectivity matrices: rows = sink reefs, columns = source)
end

end

