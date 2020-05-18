function h = PlotTrialAvg_chao(data,column,conds,plot_params)

% plots average timecourse for each condition, separately for each electrode
% INPUTS:
%       data: can be either freq x trial x time  or trial x time
%       column: column of data.trialinfo by which to sort trials for plotting
%       conds:  cell containing specific conditions to plot within column (default: all of the conditions within column)
%               can group multiple conds together by having a cell of cells
%               (e.g. conds = {{'math'},{'autobio','self-internal'}})
%       col:    colors to use for plotting each condition (otherwise will
%               generate randomly)
%       plot_params:    controls plot features (see genPlotParams.m script)

%load('cdcol.mat')

if ndims(data.wave)==3 % if spectral data
    datatype = 'Spec';
else
    datatype = 'NonSpec';
end

if isempty(plot_params)
    plot_params = genPlotParams(project_name,'timecourse');
end

if ~plot_params.multielec
    ncategs = length(conds);
else
    ncategs = 1;
end

%%

winSize = floor(data.fsample*plot_params.sm);
gusWin= gausswin(winSize)/sum(gausswin(winSize));


plot_data = cell(1,ncategs);

if strcmp(datatype,'Spec')
    freq_inds = data.freqs >= plot_params.freq_range(1) & data.freqs <= plot_params.freq_range(2);
    data.wave = squeeze(nanmean(data.wave(freq_inds,:,:)));  % avg across freq. domain
end

data.wave = convn(data.wave,gusWin','same');

% group data by conditions
if plot_params.multielec
    groupall = true;
else
    groupall = false;
end
% if plotting single trials, include noisy trials so can plot in different color
[grouped_trials_all,~] = groupConds(conds,data.trialinfo,column,'none',[],groupall);
[grouped_trials,cond_names] = groupConds(conds,data.trialinfo,column,plot_params.noise_method,plot_params.noise_fields_trials,groupall);
% if eliminating noisy trials, keep track of how many clean trials remain for
% each condition (and include in figure legend)

%chao save the cond_names for single_trial replot
cond_names2 = cond_names;

if (strcmp(plot_params.noise_method,'trials'))
    for gi = 1:length(cond_names)
        cond_names{gi} = [cond_names{gi},' (',num2str(length(grouped_trials{gi})),' of ',num2str(length(grouped_trials_all{gi})), ' trials)'];
    end
end

plot_data = cell(1,ncategs); % with noisy epochs excluded
plot_data_all = cell(1,ncategs); %including noisy epochs

for ci = 1:ncategs
    plot_data{ci} = data.wave(grouped_trials{ci},:);
    plot_data_all{ci} = data.wave(grouped_trials_all{ci},:);
end

% smooth and plot data
if ~plot_params.multielec
    figureDim = [0 0 .3 .4];
    figure('units', 'normalized', 'outerposition', figureDim)
end


for ci = 1:ncategs
%     plot_data{ci} = convn(plot_data{ci},gusWin','same');
    lineprops.col{1} = plot_params.col(ci,:);
    if plot_params.single_trial
        subplot(ncategs,1,ci)
        plot(data.time,plot_data_all{ci}', 'r')
        hold on
        %% chao adjustment
        %check the single trial one by one and plot the trial has Z score bigger than plot_params.single_trial_thr and mark it by blue line
        %the red trials are the ones exclude by Pedro's pipeline
        y_lim = [max(-5,min(plot_data_all{ci}(:))),min(10,max(plot_data_all{ci}(:)))];
        xlim(plot_params.xlim)
        ylim(y_lim)
      
        for di = 1:size(plot_data{ci},1)
            plot(data.time,plot_data{ci}(di,:),'Color',[.5 .5 .5])
        end
        
       for di = 1:size(plot_data{ci},1)
           if ~isempty(find(plot_data{ci}(di,:)>=plot_params.single_trial_thr))
               fprintf('the outlier trial (blue) over threshold %d came from condition %d trila %d\n;',plot_params.single_trial_thr,ci,di);
               plot(data.time,plot_data{ci}(di,:), 'b')   
           else
           end
       end
        %%
        %plot(data.time,plot_data{ci}', 'Color', [.5 .5 .5]) 
        % plot over non-noisy trials in grey
        %  plot(data.time,plot_data{ci}', 'Color', [.5 .5 .5]) % plot over non-noisy trials in grey
        title(cond_names{ci})
        
        xlabel(plot_params.xlabel)
        ylabel(plot_params.ylabel)
        set(gca,'fontsize',plot_params.textsize)
        box off
        
        if size(data.trialinfo.allonsets,2) > 1
            time_events = cumsum(nanmean(diff(data.trialinfo.allonsets,1,2)));
            for i = 1:length(time_events)
                plot([time_events(i) time_events(i)],ylim,'Color', [.5 .5 .5], 'LineWidth',1)
            end
        else
            
        end
        plot([0 0],ylim, 'Color', [0 0 0], 'LineWidth',2)
        plot(xlim,[0 0], 'Color', [.5 .5 .5], 'LineWidth',1)
        
        box on 
    else % chao, this section is about replot the HFB and remove the outlier tiral at the same time 
        if plot_params.single_trial_replot
            for di = 1:size(plot_data{ci},1)
                if ~isempty(find(plot_data{ci}(di,:)>=plot_params.single_trial_thr))
                    fprintf('You have deleted the data over threshold %d from the condition %d  trial %d\n;',plot_params.single_trial_thr,ci,di);
                else
                end
            end
            [thr_raw,thr_column] = find(plot_data{ci} >= plot_params.single_trial_thr);
            thr_raw = unique(thr_raw);
            plot_data{ci}(thr_raw,:)=[];
            
            cond_names{ci} = [cond_names2{ci},' (',num2str(size(plot_data{ci},1)),' of ',num2str(size(plot_data_all{ci},1)), ' trials)'];
        end
            
        if ~strcmp(plot_params.eb,'none')
            lineprops.style= '-';
            lineprops.width = plot_params.lw;
            lineprops.edgestyle = '-';
            if strcmp(plot_params.eb,'ste')
                if size(plot_data{ci},1) == 1
                    plot_data{ci} = [plot_data{ci}; plot_data{ci}]; % plot_data has to have at least 2 trials for sd
                else
                end
                mseb(data.time,nanmean(plot_data{ci}),nanstd(plot_data{ci})/sqrt(size(plot_data{ci},1)),lineprops,1);
                hold on
            else %'std'
                mseb(data.time,nanmean(plot_data{ci}),nanstd(plot_data{ci}),lineprops,1);
                hold on
                
            end
        else
                %%
%         if ~strcmp(plot_params.eb,'none')
%             lineprops.style= '-';
%             lineprops.width = plot_params.lw;
%             lineprops.edgestyle = '-';
%             if strcmp(plot_params.eb,'ste')
%                 if size(plot_data{ci},1) == 1
%                     plot_data{ci} = [plot_data{ci}; plot_data{ci}]; % plot_data has to have at least 2 trials for sd
%                 else
%                 end
%                 mseb(data.time,nanmean(plot_data{ci}),nanstd(plot_data{ci})/sqrt(size(plot_data{ci},1)),lineprops,1);
%                 hold on
%             else %'std'
%                 mseb(data.time,nanmean(plot_data{ci}),nanstd(plot_data{ci}),lineprops,1);
%                 hold on
%             end
%         end
        end
    end
    h(ci)=plot(data.time,nanmean(plot_data{ci}),'LineWidth',plot_params.lw,'Color',plot_params.col(ci,:));
    hold on
end

if ~plot_params.single_trial
    xlim(plot_params.xlim)
    
    %%
    %chao  this section is about adjust appropriate ylim
    if ~isempty(plot_params.ylim)
        ylim(plot_params.ylim)
    else
    end
    %%
    
    xlabel(plot_params.xlabel);
    ylabel(plot_params.ylabel)

    set(gca,'fontsize',plot_params.textsize)
    box off
    
    %% Plot lines to mark events
    y_lim = ylim;
    
    if size(data.trialinfo.allonsets,2) > 1
        time_events = cumsum(nanmean(diff(data.trialinfo.allonsets,1,2)));
        for i = 1:length(time_events)
            plot([time_events(i) time_events(i)],y_lim,'Color', [.5 .5 .5], 'LineWidth',1)
        end
    else
        
    end
    plot([0 0],y_lim, 'Color', [0 0 0], 'LineWidth',2)
    plot(xlim,[0 0], 'Color', [.5 .5 .5], 'LineWidth',1)
    ylim(y_lim)
    
    box on % Pedro concluded
end

set(gcf,'color','w')

if plot_params.legend && ~plot_params.single_trial
    leg = legend(h,cond_names,'Location','Northeast', 'AutoUpdate','off');
    legend boxoff
    set(leg,'fontsize',14, 'Interpreter', 'none')
end

