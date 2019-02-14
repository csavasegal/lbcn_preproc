function [subjVar_final] = localizeElect(subjVar,dirs)
% localizeElect, labels every electrode from patients' Freesurfer folder to
% Desikan-Killiany, Destrieux, Yeo7 atlases. 
% 
% Inputs: 
%       - subjVar
%           should include areas of:
%               LEPTO_coord: leptomeningeal surface coordinates generated
%               by iELVis
%               labels: electrode names as in iELVis
%       - dirs        
%           should include areas of:
%               freesurfer: folder in which Freesurfer folder is found
%               (note that patient folder 
%               fsDir_local: which is the folder of fsaverage
%
% Output:
%       - subjVar_final: updated version of subjVar, which includes table
%       names elinfo. This table has columns of:
%            FS_label: labels as found in Freesurfer elec_recon folder.
%            anatLoc_raw: raw outputs of Desikan-Killiany atlas labeling
%            for surface electrodes and aparc+aseg labeling for depth
%            electrodes.
%            WMvsGM: classification of electrodes either in gray matter or
%            white matter. GM if surface electrode or in cortex as
%            annotated in aparc+aseg. WM, if noncortical depth electrodes
%            (includes subcortical and medical temporal structures).
%            LvsR: lateralizing electrodes according to iELVis labeling.
%            Desikan_Killiany: outputs of Desikan-Killiany atlas labeling
%            for surface electrodes and depth electrodes in gray matter
%            (annotated as 'ctx-' in aparc+aseg).
%            DK_index: index of DK label.
%            DK_lobe: assignment of electrode to 5 lobes (temporal,
%            frontal, occipital, parietal, insula) grouped according to DK
%            atlas.
%            Destrieux: outputs of Destrieux atlas labeling
%            for surface electrodes and depth electrodes in gray matter
%            (annotated as 'ctx-' in aparc+aseg).
%            Destr_index: index of Destrieux label.
%            Destr_long: explanation of Destrieux label.
%            Yeo7: outputs of Yeo7 atlas labeling
%            for surface electrodes and depth electrodes in gray matter
%            (annotated as 'ctx-' in aparc+aseg).
%            Yeo_ind: index of Yeo7.
%
%
% Written and edited by Serdar Akkol and Pedro Pinheiro-Chagas.
% LBCN, Stanford University 2019.
% Areas of improvement: adding Yeo17.
% 


subjVar_final=subjVar;
elinfo = table;

X=dir(dirs.freesurfer);
X = X(~ismember({X.name},{'.','..', '.DS_Store'}) & horzcat(X.isdir) == 1);
if length(X)>1
    warning('There are more than 1 folder under server/patient_code/Freesurfer. Please select the Freesurfer for this patient.')
    FS_folder = uigetdir;
    [~,FS_name,~] = fileparts(FS_folder);
else
    FS_folder=fullfile(X.folder,X.name);  % FS location in fullfile eg.'/Volumes/neurology_jparvizi$/CHINA_C17_02/Freesurfer/C17_02'
    FS_name = X.name;   % FS name as in under Freesurfer folder of each patients' server
end


% getting DK atlas labels
fprintf('Using DK-atlas to get the general anatomical labels.\n')
anatLoc_raw = elec2Parc_subf(FS_folder,FS_name,'DK'); % change that to custom and add freesurfer folder solution
elinfo.FS_label = anatLoc_raw(:,1);
elinfo.anatLoc_raw = anatLoc_raw(:,2);

% arranging anatLoc_raw into WMvsGM, LvsR, and filtered anatLoc
[elinfo.WMvsGM, elinfo.LvsR, elinfo.anatLoc] = filterRegion(anatLoc_raw,FS_folder,FS_name);

% find all subdural electrodes and depth electrodes which are in GM:
GM_depths = elinfo.FS_label(strcmp(elinfo.WMvsGM,'GM'),1);

% Desikan-Killiany:
fprintf('Using Desikan-Killiany atlas to get the major anatomical landmarks of electrodes in gray matter.\n')
[DK_raw, ~] = elec2Parc_subf(FS_folder,FS_name,'DK',GM_depths);
elinfo.Desikan_Killiany = DK_raw(:,2);
% FIND THE CORRESPONDING INDEX and LONG NAME OF THAT LABEL IN DK-ATLAS
[DOCID,GID] = getGoogleSheetInfo('chan_names_ppt', 'chan_names_ppt_log');
googleSheet = GetGoogleSpreadsheet(DOCID, GID);
DK_info = table;
DK_info.DK_index = googleSheet.DK_index;
DK_info.DK_lobe = googleSheet.DK_lobe;
DK_info.DK_short = googleSheet.DK_short;
DK_info = DK_info(all(~cellfun(@isempty, DK_info{:,:}),2),:);

cell_DKinfo = table2cell(DK_info);
for i = 1:length(elinfo.Desikan_Killiany)
    rows = any(strcmp(cell_DKinfo, elinfo.Desikan_Killiany{i}), 2);
    if ~any(rows)  % if empty channel
        elinfo.DK_ind(i) = elinfo.Desikan_Killiany(i);
        elinfo.DK_lobe(i) = elinfo.Desikan_Killiany(i);
    else
        elinfo.DK_ind(i) = cell_DKinfo(rows==1,1);
        elinfo.DK_lobe(i) = cell_DKinfo(rows==1,2);
    end
end

% Destrieux:
fprintf('Using Destrieux-atlas to get the detailed anatomical labels.\n')
[Destrieux_raw, ~] = elec2Parc_subf(FS_folder,FS_name,'D',GM_depths);
elinfo.Destrieux = Destrieux_raw(:,2);
% FIND THE CORRESPONDING INDEX and LONG NAME OF THAT LABEL IN DESTRIEUX
D_info = table;
D_info.D_index = googleSheet.D_index;
D_info.D_long = googleSheet.D_long;
D_info.D_short = googleSheet.D_short;
D_info = D_info(all(~cellfun(@isempty, D_info{:,:}),2),:);

cell_Dinfo = table2cell(D_info);
for i = 1:length(elinfo.Destrieux)
    rows = any(strcmp(cell_Dinfo, elinfo.Destrieux{i}), 2);
    if ~any(rows)  % if empty channel
        elinfo.Destr_ind(i) = elinfo.Destrieux(i);
        elinfo.Destr_long(i) = elinfo.Destrieux(i);
    else
        elinfo.Destr_ind(i) = cell_Dinfo(rows==1,1);
        elinfo.Destr_long(i) = cell_Dinfo(rows==1,2);
    end
end


% Yeo7 network
if ~exist([FS_folder, filesep, 'label', filesep, 'rh_Yeo2011_7Networks_N1000.mat'], 'file')
    fprintf('There is no Yeo7-annotation file. So createIndivYeoMapping is running. This might take some time.\n')
    createIndivYeoMapping_subf(FS_folder, dirs.fsDir_local)
end
fprintf('Using Yeo7-atlas to get the network labels.\n')
[Yeo7_raw, ~]=elec2Parc_subf(FS_folder,FS_name,'Y7',GM_depths);
elinfo.Yeo7 = Yeo7_raw(:,2);
% FIND THE CORRESPONDING INDEX OF THAT LABEL FOR YEO7 ATLAS
Yeo_info = table;
Yeo_info.Yeo_index = googleSheet.Yeo_index;
Yeo_info.Yeo_labels = googleSheet.Yeo_labels;
Yeo_info = Yeo_info(all(~cellfun(@isempty, Yeo_info{:,:}),2),:);

cell_Yeoinfo = table2cell(Yeo_info);
for i = 1:length(elinfo.Destrieux)
    rows = any(strcmp(cell_Yeoinfo, elinfo.Yeo7{i}), 2);
    if ~any(rows)   % if empty channel
        elinfo.Yeo_ind(i) = elinfo.Yeo7(i);
        elinfo.Yeo7(i) = elinfo.Yeo7(i);
    else
        elinfo.Yeo_ind(i) = cell_Yeoinfo(rows==1,1);
        elinfo.Yeo7(i) = cell_Yeoinfo(rows==1,2);
    end
end


% Arranging elinfo according to subjVar.label:
cell_elinfo = table2cell(elinfo);
subjVar_final.elinfo = elinfo;
subjVar_final.elinfo(:,:) = [];
for i = 1:length(subjVar.labels)
    if contains(subjVar.labels{i},'empty','IgnoreCase',true)  % if empty channel
        subjVar_final.elinfo(i,:) = subjVar.labels(i);
    else
        rows = any(strcmp(cell_elinfo, subjVar.labels{i}), 2);
        subjVar_final.elinfo(i,:) = elinfo(rows==1,:);
    end
end

end





%% Subfunction1: 
function [elecParc, label_list] =elec2Parc_subf(FS_folder,subj,atlas,GM_depths)
% Original function is elec2parc, which is part of iELVis toolbox. Modified to skip
% gray matter depth electrodes to be labeled in in surface atlases
% (Destrieux, Desikan-Killiany and Yeo).

% Folder with surface files
surfaceFolder=fullfile(FS_folder,'surf');

% Folder with cortical parcellation files
labelFolder=fullfile(FS_folder,'label');

% If not looking for Yeo7
if nargin<4
    GM_depths = {};
end


%% Import electrode locations
% Pial coordinates
pialFname=fullfile(FS_folder,'elec_recon',sprintf('%s.PIAL',subj));
pialCoordStr=csv2Cell(pialFname,' ',2);
nElec=size(pialCoordStr,1);
pialCoord=zeros(nElec,3);
for a=1:nElec,
    for b=1:3,
        pialCoord(a,b)=str2double(pialCoordStr{a,b});
    end
end

% Need to get brainmask dimensions for flipping 3rd pvox coordinate
mriFname=fullfile(FS_folder,'mri','brainmask.mgz');
if ~exist(mriFname,'file')
   error('File %s not found.',mriFname); 
end
mri=MRIread(mriFname);
%mri.vol is ILA (i.e., S->I, R->L, P->A)
sVol=size(mri.vol);
clear mri mriFname

% Voxel coordinates
pvoxFname=fullfile(FS_folder,'elec_recon',sprintf('%s.PIALVOX',subj));
pvoxCoordStr=csv2Cell(pvoxFname,' ',2);
nElec=size(pvoxCoordStr,1);
pvoxCoord=zeros(nElec,3);
for a=1:nElec,
    for b=1:3,
        pvoxCoord(a,b)=str2num(pvoxCoordStr{a,b});
    end
end
% Need to swap first two dimensions and flip 3rd to make coordinates
% compatible with vox2Seg.m
pvoxCoord=round(pvoxCoord+1);
pvoxCoord(:,[1 2])=pvoxCoord(:,[2 1]);
pvoxCoord(:,3)=sVol(3)-pvoxCoord(:,3);

% Import electrode labels
labelFname=fullfile(FS_folder,'elec_recon',sprintf('%s.electrodeNames',subj));
elecLabels=csv2Cell(labelFname,' ',2);

elecParc=cell(nElec,2);
hem=[];
for hemLoop=1:2,
    if hemLoop==1
        hem='L';
    else
        hem='R';
    end
    
    %% Are there any electrodes in this hemisphere?
    elecIdsThisHem=findStrInCell(hem,elecLabels(:,3));
    nElecThisHem=length(elecIdsThisHem);
    if nElecThisHem
        %% READ SURFACE
        surfFname=fullfile(surfaceFolder,[lower(hem) 'h.pial']);
        [cort.vert, cort.tri]=read_surf(surfFname);
        nVertex=length(cort.vert);
        
        %% Get cortical parcellation
        if exist(atlas,'file')
            [~, label, colortable]=read_annotation(atlas);
        else
            switch upper(atlas)
                case 'DK'
                    parcFname=fullfile(labelFolder,[lower(hem) 'h.aparc.annot']);
                    [~, label, colortable]=read_annotation(parcFname);
                    %[averts,label,colortable]=read_annotation(parcFname);
                case 'D'
                    parcFname=fullfile(labelFolder,[lower(hem) 'h.aparc.a2009s.annot']);
                    [~, label, colortable]=read_annotation(parcFname);
                case 'Y7'
                    parcFname=fullfile(labelFolder,[lower(hem) 'h_Yeo2011_7Networks_N1000.mat']);
                    load(parcFname);
                case 'Y17'
                    parcFname=fullfile(labelFolder,[lower(hem) 'h_Yeo2011_17Networks_N1000.mat']);
                    load(parcFname);
                otherwise
                    error('Unrecognized value of atlas argument.')
            end
        end
        
        for elecLoop=1:nElecThisHem
            elecParc{elecIdsThisHem(elecLoop),1}=elecLabels{elecIdsThisHem(elecLoop),1};
            
            % Go through and set depth electrode assignments to depth:
            if elecLabels{elecIdsThisHem(elecLoop),2}=='D' && ~any(strcmp(GM_depths,elecLabels{elecIdsThisHem(elecLoop)}))
                if strcmp(atlas,'DK')
                    elecParc{elecIdsThisHem(elecLoop),2}=vox2Seg_subf(pvoxCoord(elecIdsThisHem(elecLoop),:),FS_folder);
                else
                    elecParc{elecIdsThisHem(elecLoop),2}='Depth';
                end
            else
                % Find closest vertex
                [~, minId]=min(sum( (repmat(pialCoord(elecIdsThisHem(elecLoop),:),nVertex,1)-cort.vert).^2,2 ));
                
                % Grab parcellation label for that vertex
                if sum(colortable.table(:,5)==label(minId))
                    elecParc{elecIdsThisHem(elecLoop),2}=colortable.struct_names{find(colortable.table(:,5)==label(minId))};
                else
                    elecParc{elecIdsThisHem(elecLoop),2}='undefined';
                end
            end
        end
        
    end
end

label_list = colortable.struct_names;
for x = 1:length(label_list)
    label_list{x,2} = num2str(x);
end
end

%% Subfunction2:
function anatLabel=vox2Seg_subf(coordILA,fsSubDir)
% Original function is vox2Seg, from iELVis toolbox. Modified to run as subfunction.
asegFname=[fsSubDir '/mri/aparc+aseg.mgz'];

if ~exist(asegFname,'file')
   error('File %s not found.',asegFname); 
end

aseg=MRIread(asegFname);

%% Load table
pathstr = fileparts(which('mgrid2matlab'));
inFile=fullfile(pathstr,'FreeSurferColorLUTnoFormat.txt');
if ~exist(inFile,'file')
    error('Could not find file %s',inFile);
end
fid=fopen(inFile,'r');
%fid=fopen('/Applications/freesurfer/FreeSurferColorLUTnoFormat.txt','r');
tbl=textscan(fid,'%d%s%d%d%d%d');
fclose(fid);

%% Find anatomical region corresponding to voxel
id=find(aseg.vol(coordILA(1),coordILA(2),coordILA(3))==tbl{1});
id=min(id);
anatLabel=tbl{2}{id};
end

%% Subfunction3: WMvsGM
function [WMvsGM, LvsR, anatLoc] = filterRegion(anatLabel, FS_folder,FS_name)
% This subfunction gets information if electrode is in gray matter vs white
% matter, Left vs Right and anatomical location in Desikan-Killiany atlas
% if surface electrode or in aseg+aparc.mgz if depth electrode. 
% - WMvsGM is defined as being in cortex (GM), if surface electrode (GM) or 
% in other regions (WM).
% - LvsR is defined according to iELVis .ELECTRODENAMES file.
% - anatLoc is region name from DK atlas if surface electrode or from 
% aseg+aparc if depth electrode.

labelFname=fullfile(FS_folder,'elec_recon',sprintf('%s.electrodeNames',FS_name));
elecLabels=csv2Cell(labelFname,' ',2);

% LvsR:
LvsR = elecLabels(:,3);
% LvsR = cell2table(LvsR);

% WMvsGM & anatLoc:
nElec=length(anatLabel);
WMvsGM{nElec,1}='';
anatLoc{nElec,1}='';

for i=1:length(anatLabel)
    if strcmp(elecLabels{i,2},'S') || strcmp(elecLabels{i,2},'G')
        anatLoc{i,1}= anatLabel{i,2};
        WMvsGM{i,1} = 'GM';
    elseif strcmp(elecLabels{i,2},'D')
        if contains(anatLabel{i,2}, 'ctx-')
            WMvsGM{i,1} = 'GM';
            expr = regexp(anatLabel{i,2},'ctx-[rl]h-','split');
            anatLoc{i,1}= expr{2};
        else
            WMvsGM{i,1} = 'WM';
            anatLoc{i,1}= anatLabel{i,2};
        end
    end
end
end

%% Subfunction4:
function createIndivYeoMapping_subf(sub_dir, avg_dir)
% Original function is createIndivYeoMapping, from iELVis toolbox. Modified
% to run independent from SUBJECT_DIR of Freesurfer. 
%
% This function assigns each point on an individual subject's pial surface
% to the Yeo-7 area and Yeo-17 area atlases, which are based on resting
% state fMRI data. It simply takes the mapping of the individual brain to
% that of the FreeSurfer average brain and assigns each point in the
% individual the label of the closest point in the average brain.

labelFolder=fullfile(sub_dir,'label');

%% 7 area labels taken from the original paper:
% Yeo BT, Krienen FM, Sepulcre J, Sabuncu MR, Lashkari D, Hollinshead M, 
% Roffman JL, Smoller JW, Zollei L., Polimeni JR, Fischl B, Liu H, Buckner 
% RL. The organization of the human cerebral cortex estimated by intrinsic 
% functional connectivity. J Neurophysiol 106(3):1125-65, 2011.

y7labels=cell(1,7);
y7labels{1}='MedialWall';
y7labels{2}='Visual';
y7labels{3}='Somatomotor';
y7labels{4}='Dorsal Attention';
y7labels{5}='Ventral Attention';
y7labels{6}='Limbic';
y7labels{7}='Frontoparietal';
y7labels{8}='Default';

for hemLoop=1:2
    if hemLoop==1
        hem='lh';
    else
        hem='rh';
    end
    fprintf('Creating Yeo mapping for hemisphere: %s\n',hem);
    
    
    %% Read Sub Pial Surf
    fname=[sub_dir '/surf/' hem '.pial'];
    pial=read_surf_helper(fname);
    
    
    %% Read Sub Spherical Surf
    fname=[sub_dir '/surf/' hem '.sphere.reg'];
    sph=read_surf_helper(fname);
    n_sub_vert=size(sph.vert,1);
    
    
    %% Load Avg Spherical Surf
    fname=[avg_dir '/surf/' hem '.sphere.reg'];
    avg_sph=read_surf_helper(fname);
    n_avg_vert=length(avg_sph.vert);
    
    
    %% Load Yeo atlases
    fname7=[hem '.Yeo2011_7Networks_N1000.annot'];
    fname17=[hem '.Yeo2011_17Networks_N1000.annot'];
    [avgBrainYeo7, label7, colortable7]=read_annotation(fullfile(avg_dir,'label',fname7));
    [avgBrainYeo17, label17, colortable17]=read_annotation(fullfile(avg_dir,'label',fname17));
    
    for b=2:8
        colortable7.struct_names{b}=y7labels{b};
    end
    
    indivBrainYeo7=zeros(n_sub_vert,1);
    indivBrainYeo17=zeros(n_sub_vert,1);
    vertices=zeros(n_sub_vert,1);
    
    
    %% Map pial surface vertices in subject's sphere to avg sph
    fprintf('Processing vertex:\n');
    for b=1:n_sub_vert
        if ~rem(b,1000)
            fprintf('%d of %d\n',b,n_sub_vert);
        end
        dst=sum( (avg_sph.vert-repmat(sph.vert(b,:),n_avg_vert,1)).^2 ,2);
        [dummy id]=min(dst);
        
        vertices(b)=id;
        indivBrainYeo7(b)=label7(id);
        indivBrainYeo17(b)=label17(id);
    end
    
    %% Export individual annotation as a mat file
    annotFname7=fullfile(labelFolder,[hem '_Yeo2011_7Networks_N1000.mat']);
    fprintf('Saving Yeo7 %s\n',annotFname7);
    label=indivBrainYeo7;
    colortable=colortable7;
    save(annotFname7,'label','colortable');
    
    annotFname17=fullfile(labelFolder,[hem '_Yeo2011_17Networks_N1000.mat']);
    fprintf('Saving Yeo17 %s\n',annotFname17);
    label=indivBrainYeo17;
    colortable=colortable17;
    save(annotFname17,'label','colortable');
    
end
end