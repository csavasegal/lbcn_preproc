function trialinfo = CompTrialinfo(trialinfo, project_name)

switch project_name
    case 'Calculia'
        trialinfo.keys = [];
        for i = 1:size(trialinfo,1)
            if trialinfo.isActive(i) == 1
                trialinfo.condNames(i) = {[trialinfo.condNames{i} '_active']};
            else
                trialinfo.condNames(i) = {[trialinfo.condNames{i} '_passive']};
            end
        end
        
    case 'MMR'
        for i = 1:size(trialinfo,1)
            if trialinfo.isCalc(i) == 1
                if trialinfo.AbsDeviant(i) == 0
                    trialinfo.correctness{i} = 'correct';
                elseif trialinfo.AbsDeviant(i) > 0
                    trialinfo.correctness{i} = 'incorrect';
                else
                end
            else
                trialinfo.correctness{i} = 'no math';
            end
        end
        
    case 'Context'
        trialinfo.condNames2 = trialinfo.condNames;
        trialinfo.condNamesBasic = trialinfo.condNames;
        for i = 1:size(trialinfo,1)
            if trialinfo.isActive(i) == 1
                trialinfo.condNames(i) = {[trialinfo.condition{i} '_active']};
                trialinfo.condNamesBasic(i) = {'active'};
            else
                trialinfo.condNames(i) = {[trialinfo.condition{i} '_passive']};
                trialinfo.condNamesBasic(i) = {'passive'};
            end
        end
        
    case 'EglyDriver'
        %             interval_tmp = discretize(trialinfo.int_cue_targ_time, 5);
        %             trialinfo.condNames_interval = cellstr(num2str(interval_tmp));
        for i = 1:size(trialinfo,1)
            if trialinfo.cue_pos(i) == 1 || trialinfo.cue_pos(i) == 2
                trialinfo.CondNamesCueLoc{i} = [trialinfo.CondNames{i} '_cue_left'];
            else
                trialinfo.CondNamesCueLoc{i} = [trialinfo.CondNames{i} '_cue_right'];
            end
            
            
            
        end
        trialinfo.response_time(trialinfo.response_time == 0) = nan;
        
        
        
    case 'EglyDriver_stim'
        for i = 1:size(trialinfo,1)
            if trialinfo.TTL(i,3) == 128
                trialinfo.CondNames{i} = [trialinfo.CondNames{i} '_stim'];
            else
                trialinfo.CondNames{i} = [trialinfo.CondNames{i} '_nostim'];
            end
        end
end

end