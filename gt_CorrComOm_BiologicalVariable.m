function [pt_CorrComOm] = gt_CorrComOm_BiologicalVariable (start_stop_timestamps, corr_timestamps, om_timestamps, com_timestamps)
%
%MAKE SURE: input matrixes have 2 columns


%% Matches
 matches_num = 0;
for row_index = 1: length(start_stop_timestamps) 
    for match = 1: length(corr_timestamps)
        current_match = corr_timestamps(match);
        if current_match > start_stop_timestamps(row_index,1) && current_match < start_stop_timestamps(row_index,2)  %start resp. stop
            matches_num = matches_num + 1;
        end
    end
end

        totalmatches = length(corr_timestamps);

        pt_CorrComOm.matches = matches_num/totalmatches;
        
 %% Commission Error

 commission_num = 0;
 
for row_index = 1: length(start_stop_timestamps) 
    for com = 1: length(com_timestamps)
        current_com = com_timestamps(com);
        if current_com > start_stop_timestamps(row_index,1) && current_com < start_stop_timestamps(row_index,2)  %start resp. stop
            commission_num = commission_num + 1;
        end
    end
end

        total_commission = length(com_timestamps);

        pt_CorrComOm.commission = commission_num/total_commission;
 
 %% Omission Error
 
 omission_num = 0;
 
for row_index = 1: length(start_stop_timestamps) 
    for om = 1: length(om_timestamps)
        current_om = om_timestamps(com);
        if current_om > start_stop_timestamps(row_index,1) && current_om < start_stop_timestamps(row_index,2)  %start resp. stop
            omission_num = omission_num + 1;
        end
    end
end

        total_omission = length(om_timestamps);

        pt_CorrComOm.omission = omission_num/total_omission;
 
       
end













      

        % for i = 1: length(corr_timestamps) 
        %     if matchests > start_stop_timestamps(i,1) || matchests < start_stop_timestamps(i,2)  %start resp. stop
        %         movematches(countMoveMatch) = movematches + 1;
        %     else
        %         restmatches(countRestMatch) = restmatches + 1;
        %     end
        %     
        %     totalmatches = length(matches)
        %     
        %     percMove = movmatches/totalmatches;
        %     percRest = restmatches/totalmatches;
        % end
