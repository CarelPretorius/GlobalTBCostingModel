function [Total_RN,ImpactData,RN_Outputs,RN_Out]=CalcResourceNeeds(ISO3, Intvn_Data, TargetPop_Data, CostIntvn, PIN_MAP, bReportRNDetails, Vacc_Costs, noti_trends, ImpactDenoms)
PF_GP=1;

INFL_Val=1.8;
%%%%%%%%%%%%%%%%%%%%%%%%
%PF intervention list
Intvn_PI_0=1;%scale notification down by 0%
Intvn_PI_25=2;%scale notification down by 25%
Intvn_PI_50=3;%scale notification down by 50%
Intvn_PI_75=4;%scale notification down by 75%
Intvn_ACF=5;
Intvn_DSTandDef=6;
Intvn_TPT=7;
Intvn_GP_25=8;%scale GP uniformly by 25%
Intvn_GP_50=9;%scale GP uniformly by 50%
Intvn_GP_75=10;%scale GP uniformly by 75%
Intvn_All=11;
Intvn_Baseline=12;
Intvn_PF=13;
%%%%%%%%%%%%%%%%%%%%%%%%
noti_trend_PF=1;
noti_trend_IC=2;
noti_trend_PI=3;
noti_trend_GP=4;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Vac_UC=12;

noti_years=CostIntvn.noti_years;%2022:2030;
noti_trend_type=CostIntvn.noti_trend_type;
% doBaseline=0;
% if(CostIntvn.Intvn_Type==Intvn_Baseline)
%   doBaseline=1;
% end

IntvnList=CostIntvn.IntvnList;
Scn_Num=CostIntvn.Scn_Num;

BaseYear=CostIntvn.year1;
ScaleYear=CostIntvn.year2;
c0=[];
if(BaseYear>2022+2),c0=ones(1,length(2022:BaseYear-2));end


CostEndYear=CostIntvn.year3;
CostYears2=CostEndYear-ScaleYear;
CostYearsN=length(noti_years);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PI_Factor=1;
PI_Factor1=1;
if( ~isempty(intersect([IntvnList],[Intvn_PI_0])) ),
    PI_Factor=0.01;
    PI_Factor1=0.01;
end

if( ~isempty(intersect([IntvnList],[Intvn_PI_25])) ),
    PI_Factor=0.15;
    PI_Factor1=0.1;
end

if( ~isempty(intersect([IntvnList],[Intvn_PI_50])) ),
    PI_Factor=0.30;
    PI_Factor1=0.2;
end

if( ~isempty(intersect([IntvnList],[Intvn_PI_75])) ),
    %0.5
    %UKR 0.4
    PI_Factor=0.5;
    PI_Factor1=0.3;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if(noti_trend_type==noti_trend_GP)

    Noti_GP_dat=TargetPop_Data{11};

    ind=find(strcmp(Noti_GP_dat(:,3),ISO3));
    if(~isempty(ind))
        noti_target=cell2mat(Noti_GP_dat(ind,8:16));
        noti_trend=noti_target/noti_target(1);
    end

end


if(noti_trend_type==noti_trend_IC)
    
    if( isempty(intersect([IntvnList],[Intvn_PI_0:Intvn_PI_75,Intvn_ACF,Intvn_GP_25:Intvn_GP_75,Intvn_All])) ),
    %if( ~isempty(intersect([IntvnList],[Intvn_Baseline,Intvn_DSTandDef,Intvn_TPT])) ), 
        noti_trend=ones(size(noti_years));
    else
        if( ~isempty(intersect([IntvnList],[Intvn_ACF:Intvn_All])) ),
            noti_trend=noti_trends;
        end

         if( ~isempty(intersect([IntvnList],[Intvn_PI_0:Intvn_PI_75])) ),
            noti_trend=noti_trends;
            noti_trend(6:end)=PI_Factor*noti_trends(6:end);
         end

        % if( ~isempty(intersect([IntvnList],[Intvn_PI_0:Intvn_PI_75])) ),
        %     % c1=CostIntvn.NotiTrend_Base;
        %     % c2=CostIntvn.NotiTrend_Target;
        %     % c3=linspace(c1,c2,ScaleYear-BaseYear+1);
        %     % c4=c2*ones(1,CostYears2);c5=c2*ones(1,5);
        %     % noti_trend=[c0*(c1),c1,c3,c4,c5];
        %     noti_trend=noti_trends;
        %     noti_trend(7:end)=PI_Factor*noti_trends(7:end);
        % end

            % c1=CostIntvn.NotiTrend_Base;
            % c2=CostIntvn.NotiTrend_Target;
            % c3=linspace(c1,c2,ScaleYear-BaseYear+1);
            % c4=c2*ones(1,CostYears2);c5=c2*ones(1,5);
            % noti_trend1=[c0*(c1),c1,c3,c4,c5];

        %     c1=CostIntvn.NotiTrend_Base;
        %     c2=CostIntvn.NotiTrend_Target;
        %     c3=c1*ones(1,ScaleYear-BaseYear);
        %     c4=linspace(c1,c2,CostYears2+1);
        %     c5=c2*ones(1,5);
        %     noti_trend=[c0*c1(1),c1,c3,c4,c5];
        % else    
        %     c1=CostIntvn.NotiTrend_Base;
        %     c2=CostIntvn.NotiTrend_Target;
        %     c3=linspace(c1,c2,ScaleYear-BaseYear+1);
        %     c4=c2*ones(1,CostYears2);c5=c2*ones(1,5);
        %     noti_trend=[c0*(c1),c1,c3,c4,c5];
      
    end

    % c3=c1*ones(1,ScaleYear-BaseYear);
    % c4=linspace(c1,c2,CostYears2+1);
    % c5=c2*ones(1,5);
    % DST_Cov.INH_RR_Sens_DST=[c0*c1(1),c1,c3,c4,c5];

end

if(noti_trend_type==noti_trend_PI)
    
    if(~isempty(noti_trends))
        noti_trend=noti_trends;
        noti_trend(6:end)=PI_Factor*noti_trends(6:end);
    end

end

if(noti_trend_type==noti_trend_PF)
    
    if(~isempty(noti_trends))
        noti_trend=noti_trends;
    end

end


NOTI_trend=CostIntvn.noti_inbaseyear*noti_trend;%test
% if(isempty(NOTI_trend))
%     x=1;
% end

NOTI_Dat{1}=noti_years;
NOTI_Dat{2}=NOTI_trend;
NOTI_Dat{3}=CostIntvn.DP_pop_15Plus;

%UC_File=['C:\work\GlobalModel\','UC_Res_Table.mat']
load UC_Res_Table.mat UC_RES

Dx_Intv=Intvn_Data{1};
ind=find(strcmp(UC_RES(:,1),ISO3));
if(strcmp(ISO3,'ZWE')),
    ind=find(strcmp(UC_RES(:,1),'ZAF'));
end;

if(strcmp(ISO3,'PRK')),
    ind=find(strcmp(UC_RES(:,1),'CHN'));
end;

if(strcmp(ISO3,'VEN')),
    ind=find(strcmp(UC_RES(:,1),'COL'));
end;

UC_L=UC_RES(ind,:);
UC_List=cell2mat(Intvn_Data{1});
%UC_List=[1:24,27,39:41]
[UC_Dx,UC_Dx_T,UC_Dx_NT]=GetUnitCost(UC_L,UC_List,noti_years);
UC_Dx_T_0=UC_Dx_T;
UC_Dx_NT_0=UC_Dx_NT;

%fname_Costing=[path,'TGFCostingModel_ImplementationV2c.xlsx'];
%[~,~,Dx_Intv]=xlsread(fname_Costing,'ScreenAndDx_PIN2023','A7:A30');
%Dx_Intv=Intvn_Data{1};
%UC_List=cell2mat(Dx_Intv);
%UC_Dx=GetUnitCost(UC_L,UC_List,noti_years);


%[~,~,Tx_Intv]=xlsread(fname_Costing,'Treatment_PIN2023','A4:A45');
Tx_Intv=Intvn_Data{2};
UC_List=cell2mat(Tx_Intv);

[UC_Tx,UC_Tx_T,UC_Tx_NT]=GetUnitCost(UC_L,UC_List,noti_years);
%Set BPAL M to BPAL paed
UC_Tx_T(5,:)=UC_Tx_T(12,:);
UC_Tx_NT(5,:)=UC_Tx_NT(12,:);
%Apply Treatment UC reductions, TGF and GDF correction, from 2024 to 2027
%BPAL 7, 14
%BPALM 5, 12
%Four-month RPT-MOX regimen 10
UC_Tx_red=ones(size(UC_Tx_T));

%UC_Tx_red(7,:)=[[1,1],linspace(1,0.65,4),[0.65,0.65,0.65,0.65*ones(1,5)]];
%UC_Tx_red(14,:)=[[1,1],linspace(1,0.65,4),[0.65,0.65,0.65,0.65*ones(1,5)]];
%UC_Tx_red(5,:)=[[1,1],linspace(1,0.65,4),[0.65,0.65,0.65,0.65*ones(1,5)]];
%UC_Tx_red(12,:)=[[1,1],linspace(1,0.65,4),[0.65,0.65,0.65,0.65*ones(1,5)]];
%UC_Tx_red(10,:)=[[1,1],linspace(1,0.52,4),[0.52,0.52,0.52,0.52*ones(1,5)]];

UC_Tx_T=UC_Tx_T.*UC_Tx_red;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%[~,~,TPT_Intv]=xlsread(fname_Costing,'Treatment_PIN2023','A51:A61');
TPT_Intv=Intvn_Data{3};
UC_List=cell2mat(TPT_Intv);
[UC_TPT,UC_TPT_T,UC_TPT_NT]=GetUnitCost(UC_L,UC_List,noti_years);
%Apply TPT UC reductions, TGF and GDF correction, from 2024 to 2027
UC_TPT_red=ones(size(UC_TPT_T));
%3 HP (adult) 2
UC_TPT_red(2,:)=[[1,1],linspace(1,0.5,4),[0.5,0.5,0.5,0.5*ones(1,5)]];

UC_TPT_T=UC_TPT_T.*UC_TPT_red;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%[~,~,Intv_List]=xlsread(fname_Costing,'InterventionList','A1:K85');
Intv_List=Intvn_Data{4};

%Intervention coverage data
Intvn_Cov_base_dat=Intvn_Data{5};
Intvn_Cov_target_dat=Intvn_Data{6};

ind=find(strcmp(Intvn_Cov_base_dat(:,2),ISO3));
Intvn_Cov_base=cell2mat(Intvn_Cov_base_dat(ind,5:end));
Intvn_Cov_target=cell2mat(Intvn_Cov_target_dat(ind,5:end));

IntvnCov_Scr_base=Intvn_Cov_base(1:28)';
IntvnCov_Tx_base=Intvn_Cov_base(29:70)';
IntvnCov_TPT_base=Intvn_Cov_base(71:81)';

IntvnCov_Scr_target=Intvn_Cov_target(1:28)';
IntvnCov_Tx_target=Intvn_Cov_target(29:70)';
IntvnCov_TPT_target=Intvn_Cov_target(71:81)';

for J=1:length(IntvnCov_Scr_base)
    
    if( ~isempty(intersect([IntvnList],[Intvn_PI_0:Intvn_PI_75,Intvn_Baseline])) ), 
        IntvnCov_Scr_target(J)=PI_Factor*IntvnCov_Scr_base(J);
    end
    
    c1=IntvnCov_Scr_base(J);
    c2=IntvnCov_Scr_target(J);
    if(PF_GP==0)
        c3=linspace(c1,c2,ScaleYear-BaseYear+1);
        c4=c2*ones(1,CostYears2);
        c5=c2*ones(1,5);
        IntvnCov_Scr(J,:)=[c0*(c1),c1,c3,c4,c5];
    else
        c3=c1*ones(1,ScaleYear-BaseYear);
        c4=linspace(c1,c2,CostYears2+1);
        c5=c2*ones(1,5);
        IntvnCov_Scr(J,:)=[c0*(c1),c1,c3,c4,c5];
        % if( ~isempty(intersect([IntvnList],[Intvn_PI_0:Intvn_PI_75])) ), 
        %     IntvnCov_Scr(J,:)=c2*ones(size(IntvnCov_Scr(J,:)));
        %     IntvnCov_Scr(J,1)=c1;
        % end

    end
end

for J=1:length(IntvnCov_Tx_base)
if( ~isempty(intersect([IntvnList],[Intvn_PI_0:Intvn_PI_75,Intvn_Baseline ])) ), 
    IntvnCov_Tx_target(J)=PI_Factor*IntvnCov_Tx_base(J);
end    
c1=IntvnCov_Tx_base(J);
c2=IntvnCov_Tx_target(J);
c3=linspace(c1,c2,ScaleYear-BaseYear+1);
c4=c2*ones(1,CostYears2);
c5=c2*ones(1,5);
IntvnCov_Tx(J,:)=[c0*(c1),c1,c3,c4,c5];

% if( ~isempty(intersect([IntvnList],[Intvn_PI_0:Intvn_PI_75])) ), 
%     IntvnCov_Tx(J,:)=c2*ones(size(IntvnCov_Tx(J,:)));
%     IntvnCov_Tx(J,1)=c1;
% end

end

for J=1:length(IntvnCov_TPT_target)
if( ~isempty(intersect([IntvnList],[Intvn_PI_0:Intvn_PI_75,Intvn_Baseline])) ), 
    IntvnCov_TPT_target(J)=PI_Factor*IntvnCov_TPT_base(J);
end     
c1=IntvnCov_TPT_base(J);
c2=IntvnCov_TPT_target(J);
c3=linspace(c1,c2,ScaleYear-BaseYear+1);
c4=c2*ones(1,CostYears2);
c5=c2*ones(1,5);
IntvnCov_TPT(J,:)=[c0*(c1),c1,c3,c4,c5];

% if( ~isempty(intersect([IntvnList],[Intvn_PI_0:Intvn_PI_75])) ), 
%     IntvnCov_TPT(J,:)=c2*ones(size(IntvnCov_TPT(J,:)));
%     IntvnCov_TPT(J,1)=c1;
% end

end

TB_PTB = 1;
TB_ETB = 2;


[CostingData,ImpactData]=CalcTargetPops(ISO3, TargetPop_Data, NOTI_Dat, CostIntvn, ImpactDenoms);


iso3=CostingData{1};
NOTI=CostingData{2};
HH_Contacts=CostingData{3};
ART_Cohorts=CostingData{4};
HR_Groups=CostingData{5};
PatientInitiated=CostingData{6};
CostingTPs=CostingData{7};
DST_Out=CostingData{8};


num_years=length(NOTI.years);

INFL_R=INFL_Val*ones(1,num_years)/100;
INFL(1)=1;
for I=2:length(NOTI.years);
 INFL(I)=INFL(I-1)*(1+INFL_R(1));
end;

%INFL=ones(size(INFL));

%cost of running program, as proportion of direct costs
program_costs_markup=70/100;
program_costs_markup_baseline=program_costs_markup;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pc_factor=0.5;
% if( ~isempty(intersect([IntvnList],[Intvn_PI_0])) ),
%     pc_factor=pc_factor+0*(1-pc_factor);
%     program_costs_markup = pc_factor*program_costs_markup;
% end
% 
% if( ~isempty(intersect([IntvnList],[Intvn_PI_25])) ),     
%     pc_factor=pc_factor+0.25*(1-pc_factor);
%     program_costs_markup = pc_factor*program_costs_markup;
% end
% 
% if( ~isempty(intersect([IntvnList],[Intvn_PI_50])) ),     
%     pc_factor=pc_factor+0.5*(1-pc_factor);
%     program_costs_markup = pc_factor*program_costs_markup;
% end
% 
% if( ~isempty(intersect([IntvnList],[Intvn_PI_75])) ),     
%     pc_factor=pc_factor+0.75*(1-pc_factor);
%     program_costs_markup = pc_factor*program_costs_markup;
% end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

enabler_markup_nonPPM=9.5/100;%enabler for CRG, patient support, 
%Most countries do not have high pvt sector involvement in TB
enabler_markup_PPM=0;
if(CostIntvn.IsHighPvtSector==1)
    enabler_markup_PPM=8/100;
end

enabler_markup=0;
if( ~isempty(intersect([IntvnList],[Intvn_ACF])) ),
    if(length(IntvnList)==1) 
     enabler_markup = 0.5*enabler_markup_nonPPM + 0.5*enabler_markup_PPM;
    end
     %enabler_markup = enabler_markup_nonPPM + enabler_markup_PPM;
end

if( ~isempty(intersect([IntvnList],[Intvn_DSTandDef])) ), 
    if(length(IntvnList)==1)
        enabler_markup = 0.5*enabler_markup_nonPPM + 0.5*enabler_markup_PPM;
    end
     %enabler_markup = enabler_markup_nonPPM + enabler_markup_PPM;
end

if(  ~isempty(intersect([IntvnList],[Intvn_TPT])) ),
    if(length(IntvnList)==1)
        enabler_markup = 0.5*enabler_markup_nonPPM + 0.5*enabler_markup_PPM;
    end
     %enabler_markup = enabler_markup_nonPPM + enabler_markup_PPM;
end


if( length(IntvnList)>=3 ),     
    enabler_markup = enabler_markup_nonPPM + enabler_markup_PPM;
end


if( ~isempty(intersect([IntvnList],[Intvn_GP_25])) ),     
    enabler_markup = 0.15*enabler_markup_nonPPM + 0.25*enabler_markup_PPM;
end

if( ~isempty(intersect([IntvnList],[Intvn_GP_50])) ),     
    enabler_markup = 0.40*enabler_markup_nonPPM + 0.5*enabler_markup_PPM;
end

if( ~isempty(intersect([IntvnList],[Intvn_GP_75])) ),     
    enabler_markup = 0.6*enabler_markup_nonPPM + 0.75*enabler_markup_PPM;
end

if( ~isempty(intersect([IntvnList],[Intvn_All])) ),     
    enabler_markup = enabler_markup_nonPPM + enabler_markup_PPM;
end

%all 0.4
%UKR 0.5 0.6
if( ~isempty(intersect([IntvnList],[Intvn_Baseline])) ),     
    enabler_markup = 0.4*enabler_markup_nonPPM + 0.4*enabler_markup_PPM;
    enabler_markup_baseline = enabler_markup;  
end

if( ~isempty(intersect([IntvnList],[Intvn_PF])) ),     
    enabler_markup = 0.5*enabler_markup_nonPPM + 0.6*enabler_markup_PPM;
end

enabler_markup_baseline = enabler_markup_nonPPM + 0.5*enabler_markup_PPM;

%enabler_markup=0.135;
% pc_factor=0.5;
% if( ~isempty(intersect([IntvnList],[Intvn_PI_0])) ),
% 
%     pc_factor=pc_factor+0*(1-pc_factor);
%     enabler_markup = pc_factor*(enabler_markup_nonPPM + 0.5*enabler_markup_PPM);
% end
% 
% if( ~isempty(intersect([IntvnList],[Intvn_PI_25])) ),     
%     pc_factor=pc_factor+0.15*(1-pc_factor);
%     enabler_markup = pc_factor*(enabler_markup_nonPPM + 0.5*enabler_markup_PPM);
% end
% 
% if( ~isempty(intersect([IntvnList],[Intvn_PI_50])) ),     
%     pc_factor=pc_factor+0.4*(1-pc_factor);
%     enabler_markup = pc_factor*(enabler_markup_nonPPM + 0.5*enabler_markup_PPM);
% end
% 
% if( ~isempty(intersect([IntvnList],[Intvn_PI_75])) ),     
%     pc_factor=pc_factor+0.6*(1-pc_factor);
%     enabler_markup = pc_factor*(enabler_markup_nonPPM + 0.5*enabler_markup_PPM);
% end



% if( ~isempty(intersect([IntvnList],[Intvn_DSTandDef,Intvn_All])) ),     
%  enabler_markup=1.5*6/100;
% end
% 
% %Countries with high pvt sector involvement need more enablers
% if(CostIntvn.IsHighPvtSector==1)
%     if( ~isempty(intersect([IntvnList],[Intvn_ACF,Intvn_TPT])) ),        
%      enabler_markup=10/100;
%     end
%     if( ~isempty(intersect([IntvnList],[Intvn_DSTandDef,Intvn_All])) ),        
%      enabler_markup=1.5*10/100;
%     end    
%        
% end

%Screening and diagnosis
ScrByGrp=CostingTPs{6};%number screened from TP calc
DxRefByGrp=CostingTPs{7};%number referred for diagnosis
TPTDxByGrp=CostingTPs{8};%number tested for LTBI
DST_Out=CostingTPs{9};%number tested RR

TotalScreened=sum(ScrByGrp,1);
TotalDxRef=sum(DxRefByGrp,1);


DxByGrp=CostingTPs{1};%number screened from TP calc
TotalDx=sum(DxByGrp,1);

Dx_PINS_Base=PIN_MAP{1};

DxGroups= PIN_MAP{2};
DxGroups_Groups=DxGroups.Groups;

DxQ=PIN_MAP{3};

num_intv=size(Dx_PINS_Base{I},1);
Dx_RN=zeros(num_intv,num_years);
Dx_POP=zeros(num_intv,num_years);
group_Dx_POP=cell(1);
Tx_POP=zeros(num_intv,num_years);

PLHIVonly=find(strcmp(DxGroups_Groups,'PLHIV'))
EPTBonly=find(strcmp(DxGroups_Groups,'Extrapulmonary'))
CONTACTSonly=find(strcmp(DxGroups_Groups,'HHC)'))
CONTACTSonlyTx=find(strcmp(DxGroups_Groups,'HHC aged > 5 years and other high risk groups (excluding PLHIV)'))
U5sonly=find(strcmp(DxGroups_Groups,'Children <5 years'))

DST_Adjust=ones(num_intv,num_years);
Dst=CostingTPs{2};
Rif_R=Dst.DST_Conf_RifR./TotalDx;
Rif_S=1-Rif_R;

PropOfScreenedDxRef=TotalDxRef./TotalScreened;
PropOfScreenedDx=TotalDx./TotalScreened;
NNTT=TotalScreened./TotalDx;
NNTTByGrp=ScrByGrp./DxByGrp;

RR_DST_Dx=DST_Out{1};
INH_DST_Dx=DST_Out{2};
FQ_DST_Dx=DST_Out{3};
NumberResTested=RR_DST_Dx+INH_DST_Dx+FQ_DST_Dx;

RR_Confirmed=DST_Out{4};
RS_Confirmed=DST_Out{5};
FQR_Confirmed=DST_Out{6};
INH_Confirmed=DST_Out{7};


%Adjust for number referred for diagnosis
DST_Adjust([2,10,12,19:21,26:28],:)=DST_Adjust([2,10,12,19:21,26:28],:).*repmat(PropOfScreenedDxRef,9,1);
%Adjust for confirmed TB
DST_Adjust([11],:)=DST_Adjust([11],:).*repmat(PropOfScreenedDx,1,1);
%Adjust further for Conf Rif R only
%DST_Adjust([13:15,17],:)=DST_Adjust([13:15,17],:).*repmat(Rif_R,4,1);
%Adjust further for Conf Rif S only
%DST_Adjust([16],:)=DST_Adjust([16],:).*Rif_S;


%add transport costs to sputum collection 
UC_Dx_T(3,:)=UC_Dx_T(3,:)+2;

for I=1:size(ScrByGrp,1)
     %Group eligibility restrictions for specific interventions
     
     group_eligible=ones(num_intv,num_years);
     %Contacts
     if(~ismember(I,[11:13])),group_eligible(CONTACTSonly,:)=0;end  
     
     %Contacts Tx
     if(~ismember(I,[12:13])),group_eligible(CONTACTSonly,:)=0;end  
     
     %EPTB
     if(~ismember(I,[6:10])),group_eligible(EPTBonly,:)=0;end    
     
     %PLHIV for CRP
     if(~ismember(I,[3:5,8:10,14:19])),group_eligible(PLHIVonly,:)=0;end    
     
     %U5 for gastric aspiration
     if(~ismember(I,[1,6,11])),group_eligible(U5sonly,:)=0;end  
           
     NumScreened=ScrByGrp(I,:);     
     Num_Screened=repmat(NumScreened,num_intv,1);
     Num_Screened([13],:)=INH_DST_Dx(I,:)+FQ_DST_Dx(I,:);
     %number tested RR and INH res
     Num_Screened([16],:)=INH_DST_Dx(I,:);
     %number tes FQ res
     Num_Screened([17],:)=FQ_DST_Dx(I,:);
    
        
     NumLTBIDx=TPTDxByGrp(I,:);
     Num_LTBIDx=repmat(NumLTBIDx,3,1);
     Num_Screened([23,24,25],:)=Num_LTBIDx;
     
     Dx_PINS_base=Dx_PINS_Base{I};

     %POP= TP x PIN x Q
     group_Dx_POP{I} = (DST_Adjust.*group_eligible).*IntvnCov_Scr.*Num_Screened.*repmat(Dx_PINS_base(:,2),1,num_years).*repmat(DxQ.Q,1,num_years);
     
end

for I=1:size(ScrByGrp,1)
    
  %HR groups   
%   if(I==20) 
%       UC_Dx_T(22,:)=UC_Dx_T_0(15,:);
%       UC_Dx_NT(22,:)=UC_Dx_NT_0(15,:);
%   end
 
  group_Dx_POPi=group_Dx_POP{I};
  %number SC and LC calculated from FL and SL LPA
  group_Dx_POPi([14],:)=group_Dx_POPi(16,:)+group_Dx_POPi(17,:);
  %group_Dx_POPi([15],:)=0*(group_Dx_POPi(16,:)+group_Dx_POPi(17,:));
  
  %RN=UC x INFL x TP x PIN x Q
  group_Dx_RN=group_Dx_POPi.*(UC_Dx_T+UC_Dx_NT.*repmat(INFL,num_intv,1));
   
  Dx_RN=Dx_RN + (group_Dx_RN); 
  Dx_POP=Dx_POP + (group_Dx_POPi);
    
end    



% DxByGrp
% sum(DxByGrp)
% pause

%Resource needs for TB treatment
Tx_PopsU15=CostingTPs{3};
Tx_PopsP15=CostingTPs{4};

Tx_PopsU15_PTB=Tx_PopsU15{1};
Tx_PopsU15_ETB=Tx_PopsU15{2};

Tx_PopsP15_PTB=Tx_PopsP15{1};
Tx_PopsP15_ETB=Tx_PopsP15{2};


Tx_PinsU15_Base   = PIN_MAP{4};
Tx_PinsU15_Target = PIN_MAP{5};
Tx_PinsP15_Base   = PIN_MAP{6};
Tx_PinsP15_Target = PIN_MAP{7};
TxGroups          = PIN_MAP{8};
TxQ_U15           = PIN_MAP{9};
TxQ_P15           = PIN_MAP{10};


bed_day_ind=find(TxQ_P15.FQ_R_LongDel(:,1)==47);
if(CostIntvn.eca_country==1)
TxQ_P15.FQ_R_LongDel(bed_day_ind,2)=60;
TxQ_P15.FQ_R_BPAL(bed_day_ind,2)=60;
TxQ_P15.FQ_S_ShortBDQ(bed_day_ind,2)=60;
TxQ_P15.FQ_S_BPALM(bed_day_ind,2)=60;

TxQ_U15.FQ_R_LongDel(bed_day_ind,2)=60;
TxQ_U15.FQ_R_BPAL(bed_day_ind,2)=60;
TxQ_U15.FQ_S_ShortBDQ(bed_day_ind,2)=60;
TxQ_U15.FQ_S_BPALM(bed_day_ind,2)=60;
end



%PINS
%children
U15_INH_S_2HRZE4HR_pin=Tx_PinsU15_Base.INH_S_2HRZE4HR;
U15_INH_S_6HRZEto_pin=Tx_PinsU15_Base.INH_S_6HRZEto;
U15_INH_S_2HRZHR_pin=Tx_PinsU15_Base.INH_S_2HRZ2HR;
U15_INH_R_6HREZLfx_pin=Tx_PinsU15_Base.INH_R_6REZLfx;

U15_FQ_S_BPALM_pin=Tx_PinsU15_Base.FQ_S_BPALM;
U15_FQ_S_ShortBDQ_pin=Tx_PinsU15_Base.FQ_S_ShortBDQ;
U15_FQ_R_BPAL_pin=Tx_PinsU15_Base.FQ_R_BPAL;
U15_FQ_R_LongDel_pin=Tx_PinsU15_Base.FQ_R_LongDel;

%adults
P15_INH_S_2HRZE_pin=Tx_PinsP15_Base.INH_S_2HRZE4HRE;
P15_INH_S_RPTMOX_pin=Tx_PinsP15_Base.INH_S_4RPTMOX;
P15_INH_R_6HREZLfx_pin=Tx_PinsP15_Base.INH_R_6REZLfx;

P15_FQ_S_BPALM_pin=Tx_PinsP15_Base.FQ_S_BPALM;
P15_FQ_S_ShortBDQ_pin=Tx_PinsP15_Base.FQ_S_ShortBDQ;
P15_FQ_R_BPAL_pin=Tx_PinsP15_Base.FQ_R_BPAL;
P15_FQ_R_LongDel_pin=Tx_PinsP15_Base.FQ_R_LongDel;


TxGroups_Intv=TxGroups.IntvCode;
TxGroups_Groups=TxGroups.Groups;

num_intv=size(Tx_PinsU15_Base.INH_S_2HRZE4HR,1);
Tx_RN=zeros(num_intv,num_years);
Tx_POP=zeros(num_intv,num_years);


PTBonly=find(strcmp(TxGroups_Groups,'PTBGroups'));
EPTBonly=find(strcmp(TxGroups_Groups,'EPTBGroups'));

%Tx_RN=0;
for I = [TB_PTB,TB_ETB]

%use to control for intervention that depends on PTB or EPTB status
PulmTBStatus=ones(num_intv,1);
if(I==TB_PTB),PulmTBStatus(EPTBonly,:)=0;end
if(I==TB_ETB),PulmTBStatus(PTBonly,:)=0;end
  

%Tx num    
%children
U15_INH_S_2HRZE4HR_num=Tx_PopsU15{I}.INH_S_2HRZE4HR;
U15_INH_S_6HRZEto_num=Tx_PopsU15{I}.INH_S_6HRZEto;
U15_INH_S_2HRZHR_num=Tx_PopsU15{I}.INH_S_2HRZHR;
U15_INH_R_6HREZLfx_num=Tx_PopsU15{I}.INH_R_6HREZLfx;

U15_FQ_S_BPALM_num=Tx_PopsU15{I}.FQ_S_BPALM;
U15_FQ_S_ShortBDQ_num=Tx_PopsU15{I}.FQ_S_ShortBDQ;
U15_FQ_R_BPAL_num=Tx_PopsU15{I}.FQ_R_BPAL;
U15_FQ_R_LongDel_num=Tx_PopsU15{I}.FQ_R_LongDel;

%adults
P15_INH_S_2HRZE_num=Tx_PopsP15{I}.INH_S_2HRZE;
P15_INH_S_RPTMOX_num=Tx_PopsP15{I}.INH_S_RPTMOX;
P15_INH_R_6HREZLfx_num=Tx_PopsP15{I}.INH_R_6HREZLfx;

P15_FQ_S_BPALM_num=Tx_PopsP15{I}.FQ_S_BPALM;
P15_FQ_S_ShortBDQ_num=Tx_PopsP15{I}.FQ_S_ShortBDQ;
P15_FQ_R_BPAL_num=Tx_PopsP15{I}.FQ_R_BPAL;
P15_FQ_R_LongDel_num=Tx_PopsP15{I}.FQ_R_LongDel;

TxQ_U15_INH_S_2HRZE4HR=TxQ_U15.INH_S_2HRZE4HR(:,2);
TxQ_U15_INH_S_6HRZEto=TxQ_U15.INH_S_6HRZEto(:,2);
TxQ_U15_INH_S_2HRZ2HR=TxQ_U15.INH_S_2HRZ2HR(:,2);

TxQ_U15_INH_S=TxQ_U15_INH_S_2HRZE4HR+TxQ_U15_INH_S_6HRZEto+TxQ_U15_INH_S_2HRZ2HR;

TxQ_U15_INH_R_6REZLfx=TxQ_U15.INH_R_6REZLfx(:,2);
TxQ_U15_FQ_S_BPALM=TxQ_U15.FQ_S_BPALM(:,2);
TxQ_U15_FQ_S_ShortBDQ=TxQ_U15.FQ_S_ShortBDQ(:,2);
TxQ_U15_FQ_R_BPAL=TxQ_U15.FQ_R_BPAL(:,2);
TxQ_U15_FQ_R_LongDel=TxQ_U15.FQ_R_LongDel(:,2);

TxQ_P15_INH_S_2HRZE4HRE=TxQ_P15.INH_S_2HRZE4HRE(:,2);
TxQ_P15_INH_S_4RPTMOX= TxQ_P15.INH_S_4RPTMOX(:,2);
TxQ_P15_INH_R_6REZLfx=TxQ_P15.INH_R_6REZLfx(:,2);
TxQ_P15_FQ_S_BPALM=TxQ_P15.FQ_S_BPALM(:,2);
TxQ_P15_FQ_S_ShortBDQ=TxQ_P15.FQ_S_ShortBDQ(:,2);
TxQ_P15_FQ_R_BPAL=TxQ_P15.FQ_R_BPAL(:,2);
TxQ_P15_FQ_R_LongDel=TxQ_P15.FQ_R_LongDel(:,2);



%RN=UC x INFL x TP x PIN x Q
%Children
Tx_RN_Child =IntvnCov_Tx.*(UC_Tx_T+UC_Tx_NT.*repmat(INFL,num_intv,1)).*repmat(PulmTBStatus,1,num_years).*repmat(U15_INH_S_2HRZE4HR_num,num_intv,1).*repmat(U15_INH_S_2HRZE4HR_pin(:,2),1,num_years).*repmat(TxQ_U15_INH_S_2HRZE4HR,1,num_years)+...
             IntvnCov_Tx.*(UC_Tx_T+UC_Tx_NT.*repmat(INFL,num_intv,1)).*repmat(PulmTBStatus,1,num_years).*repmat(U15_INH_S_6HRZEto_num,num_intv,1).*repmat(U15_INH_S_6HRZEto_pin(:,2),1,num_years).*repmat(TxQ_U15_INH_S_6HRZEto,1,num_years)+...
             IntvnCov_Tx.*(UC_Tx_T+UC_Tx_NT.*repmat(INFL,num_intv,1)).*repmat(PulmTBStatus,1,num_years).*repmat(U15_INH_S_2HRZHR_num,num_intv,1).*repmat(U15_INH_S_2HRZHR_pin(:,2),1,num_years).*repmat(TxQ_U15_INH_S_2HRZ2HR,1,num_years)+...
             IntvnCov_Tx.*(UC_Tx_T+UC_Tx_NT.*repmat(INFL,num_intv,1)).*repmat(PulmTBStatus,1,num_years).*repmat(U15_INH_R_6HREZLfx_num,num_intv,1).*repmat(U15_INH_R_6HREZLfx_pin(:,2),1,num_years).*repmat(TxQ_U15_INH_R_6REZLfx,1,num_years)+...
             IntvnCov_Tx.*(UC_Tx_T+UC_Tx_NT.*repmat(INFL,num_intv,1)).*repmat(PulmTBStatus,1,num_years).*repmat(U15_FQ_S_BPALM_num,num_intv,1).*repmat(U15_FQ_S_BPALM_pin(:,2),1,num_years).*repmat(TxQ_U15_FQ_S_BPALM,1,num_years)+...
             IntvnCov_Tx.*(UC_Tx_T+UC_Tx_NT.*repmat(INFL,num_intv,1)).*repmat(PulmTBStatus,1,num_years).*repmat(U15_FQ_S_ShortBDQ_num,num_intv,1).*repmat(U15_FQ_S_ShortBDQ_pin(:,2),1,num_years).*repmat(TxQ_U15_FQ_S_ShortBDQ,1,num_years)+...
             IntvnCov_Tx.*(UC_Tx_T+UC_Tx_NT.*repmat(INFL,num_intv,1)).*repmat(PulmTBStatus,1,num_years).*repmat(U15_FQ_R_BPAL_num,num_intv,1).*repmat(U15_FQ_R_BPAL_pin(:,2),1,num_years).*repmat(TxQ_U15_FQ_R_BPAL,1,num_years)+...
             IntvnCov_Tx.*(UC_Tx_T+UC_Tx_NT.*repmat(INFL,num_intv,1)).*repmat(PulmTBStatus,1,num_years).*repmat(U15_FQ_R_LongDel_num,num_intv,1).*repmat(U15_FQ_R_LongDel_pin(:,2),1,num_years).*repmat(TxQ_U15_FQ_R_LongDel,1,num_years);
 
%Adults
Tx_RN_Adult =IntvnCov_Tx.*(UC_Tx_T+UC_Tx_NT.*repmat(INFL,num_intv,1)).*repmat(INFL,num_intv,1).*repmat(PulmTBStatus,1,num_years).*repmat(P15_INH_S_2HRZE_num,num_intv,1).*repmat(P15_INH_S_2HRZE_pin(:,2),1,num_years).*repmat(TxQ_P15_INH_S_2HRZE4HRE,1,num_years)+...
             IntvnCov_Tx.*(UC_Tx_T+UC_Tx_NT.*repmat(INFL,num_intv,1)).*repmat(INFL,num_intv,1).*repmat(PulmTBStatus,1,num_years).*repmat(P15_INH_S_RPTMOX_num,num_intv,1).*repmat(P15_INH_S_RPTMOX_pin(:,2),1,num_years).*repmat(TxQ_P15_INH_S_4RPTMOX,1,num_years)+...
             IntvnCov_Tx.*(UC_Tx_T+UC_Tx_NT.*repmat(INFL,num_intv,1)).*repmat(INFL,num_intv,1).*repmat(PulmTBStatus,1,num_years).*repmat(P15_INH_R_6HREZLfx_num,num_intv,1).*repmat(P15_INH_R_6HREZLfx_pin(:,2),1,num_years).*repmat(TxQ_P15_INH_R_6REZLfx,1,num_years)+...
             IntvnCov_Tx.*(UC_Tx_T+UC_Tx_NT.*repmat(INFL,num_intv,1)).*repmat(INFL,num_intv,1).*repmat(PulmTBStatus,1,num_years).*repmat(P15_FQ_S_BPALM_num,num_intv,1).*repmat(P15_FQ_S_BPALM_pin(:,2),1,num_years).*repmat(TxQ_P15_FQ_S_BPALM,1,num_years)+...
             IntvnCov_Tx.*(UC_Tx_T+UC_Tx_NT.*repmat(INFL,num_intv,1)).*repmat(INFL,num_intv,1).*repmat(PulmTBStatus,1,num_years).*repmat(P15_FQ_S_ShortBDQ_num,num_intv,1).*repmat(P15_FQ_S_ShortBDQ_pin(:,2),1,num_years).*repmat(TxQ_P15_FQ_S_ShortBDQ,1,num_years)+...
             IntvnCov_Tx.*(UC_Tx_T+UC_Tx_NT.*repmat(INFL,num_intv,1)).* repmat(INFL,num_intv,1).*repmat(PulmTBStatus,1,num_years).*repmat(P15_FQ_R_BPAL_num,num_intv,1).*repmat(P15_FQ_R_BPAL_pin(:,2),1,num_years).*repmat(TxQ_P15_FQ_R_BPAL,1,num_years)+...
             IntvnCov_Tx.*(UC_Tx_T+UC_Tx_NT.*repmat(INFL,num_intv,1)).*repmat(INFL,num_intv,1).*repmat(PulmTBStatus,1,num_years).*repmat(P15_FQ_R_LongDel_num,num_intv,1).*repmat(P15_FQ_R_LongDel_pin(:,2),1,num_years).*repmat(TxQ_P15_FQ_R_LongDel,1,num_years);

%RN=UC x INFL x TP x PIN x Q
%Children
Tx_POP_Child =IntvnCov_Tx.*repmat(PulmTBStatus,1,num_years).*repmat(U15_INH_S_2HRZE4HR_num,num_intv,1).*repmat(U15_INH_S_2HRZE4HR_pin(:,2),1,num_years).*repmat(TxQ_U15_INH_S_2HRZE4HR,1,num_years)+...
              IntvnCov_Tx.*repmat(PulmTBStatus,1,num_years).*repmat(U15_INH_S_6HRZEto_num,num_intv,1).*repmat(U15_INH_S_6HRZEto_pin(:,2),1,num_years).*repmat(TxQ_U15_INH_S_6HRZEto,1,num_years)+...
              IntvnCov_Tx.*repmat(PulmTBStatus,1,num_years).*repmat(U15_INH_S_2HRZHR_num,num_intv,1).*repmat(U15_INH_S_2HRZHR_pin(:,2),1,num_years).*repmat(TxQ_U15_INH_S_2HRZ2HR,1,num_years)+...
              IntvnCov_Tx.*repmat(PulmTBStatus,1,num_years).*repmat(U15_INH_R_6HREZLfx_num,num_intv,1).*repmat(U15_INH_R_6HREZLfx_pin(:,2),1,num_years).*repmat(TxQ_U15_INH_R_6REZLfx,1,num_years)+...
              IntvnCov_Tx.*repmat(PulmTBStatus,1,num_years).*repmat(U15_FQ_S_BPALM_num,num_intv,1).*repmat(U15_FQ_S_BPALM_pin(:,2),1,num_years).*repmat(TxQ_U15_FQ_S_BPALM,1,num_years)+...
              IntvnCov_Tx.*repmat(PulmTBStatus,1,num_years).*repmat(U15_FQ_S_ShortBDQ_num,num_intv,1).*repmat(U15_FQ_S_ShortBDQ_pin(:,2),1,num_years).*repmat(TxQ_U15_FQ_S_ShortBDQ,1,num_years)+...
              IntvnCov_Tx.*repmat(PulmTBStatus,1,num_years).*repmat(U15_FQ_R_BPAL_num,num_intv,1).*repmat(U15_FQ_R_BPAL_pin(:,2),1,num_years).*repmat(TxQ_U15_FQ_R_BPAL,1,num_years)+...
              IntvnCov_Tx.*repmat(PulmTBStatus,1,num_years).*repmat(U15_FQ_R_LongDel_num,num_intv,1).*repmat(U15_FQ_R_LongDel_pin(:,2),1,num_years).*repmat(TxQ_U15_FQ_R_LongDel,1,num_years);
 
    
%Adults
Tx_POP_Adult =IntvnCov_Tx.*repmat(PulmTBStatus,1,num_years).*repmat(P15_INH_S_2HRZE_num,num_intv,1).*repmat(P15_INH_S_2HRZE_pin(:,2),1,num_years).*repmat(TxQ_P15_INH_S_2HRZE4HRE,1,num_years)+...
             IntvnCov_Tx.*repmat(PulmTBStatus,1,num_years).*repmat(P15_INH_S_RPTMOX_num,num_intv,1).*repmat(P15_INH_S_RPTMOX_pin(:,2),1,num_years).*repmat(TxQ_P15_INH_S_4RPTMOX,1,num_years)+...
             IntvnCov_Tx.*repmat(PulmTBStatus,1,num_years).*repmat(P15_INH_R_6HREZLfx_num,num_intv,1).*repmat(P15_INH_R_6HREZLfx_pin(:,2),1,num_years).*repmat(TxQ_P15_INH_R_6REZLfx,1,num_years)+...
             IntvnCov_Tx.*repmat(PulmTBStatus,1,num_years).*repmat(P15_FQ_S_BPALM_num,num_intv,1).*repmat(P15_FQ_S_BPALM_pin(:,2),1,num_years).*repmat(TxQ_P15_FQ_S_BPALM,1,num_years)+...
             IntvnCov_Tx.*repmat(PulmTBStatus,1,num_years).*repmat(P15_FQ_S_ShortBDQ_num,num_intv,1).*repmat(P15_FQ_S_ShortBDQ_pin(:,2),1,num_years).*repmat(TxQ_P15_FQ_S_ShortBDQ,1,num_years)+...
             IntvnCov_Tx.*repmat(PulmTBStatus,1,num_years).*repmat(P15_FQ_R_BPAL_num,num_intv,1).*repmat(P15_FQ_R_BPAL_pin(:,2),1,num_years).*repmat(TxQ_P15_FQ_R_BPAL,1,num_years)+...
             IntvnCov_Tx.*repmat(PulmTBStatus,1,num_years).*repmat(P15_FQ_R_LongDel_num,num_intv,1).*repmat(P15_FQ_R_LongDel_pin(:,2),1,num_years).*repmat(TxQ_P15_FQ_R_LongDel,1,num_years);
     
%Children + Adults
Tx_RN = Tx_RN + (Tx_RN_Child+Tx_RN_Adult);
Tx_POP = Tx_POP + (Tx_POP_Child+Tx_POP_Adult);

       
end

% Tx_POP
% sum(Tx_POP)
% pause

%Resournce needs for TB prevention
TPT_Base=PIN_MAP{11};
TPT_Q=PIN_MAP{12};

TPT_DS_Child_pin=TPT_Base.DS_Child(:,2);
TPT_DS_Adult_pin=TPT_Base.DS_Adult(:,2);
TPT_DR_Child_pin=TPT_Base.DR_Child(:,2);
TPT_DR_Adult_pin=TPT_Base.DR_Adult(:,2);

TPT_DS_Child_Q=TPT_Q.DS_Child(:,2);
TPT_DS_Adult_Q=TPT_Q.DS_Adult(:,2);
TPT_DR_Child_Q=TPT_Q.DR_Child(:,2);
TPT_DR_Adult_Q=TPT_Q.DR_Adult(:,2);

TPT_Pop=CostingTPs{5};

TPT_Tx_U15_DS_num=TPT_Pop.TPT_Tx_U15_DS;
TPT_Tx_U15_DR_num=TPT_Pop.TPT_Tx_U15_DR;

TPT_Tx_P15_DS_num=TPT_Pop.TPT_Tx_P15_DS;
TPT_Tx_P15_DR_num=TPT_Pop.TPT_Tx_P15_DR;

num_intv=size(TPT_DS_Adult_pin,1);
TPT_RN=zeros(num_intv,num_years);
TPT_POP=zeros(num_intv,num_years);

%RN=UC x INFL x TP x PIN x Q
TPT_RN=TPT_RN +...
              IntvnCov_TPT.*(UC_TPT_T+UC_TPT_NT.*repmat(INFL,num_intv,1)).*repmat(TPT_Tx_U15_DS_num,num_intv,1).*repmat(TPT_DS_Child_pin,1,num_years).*repmat(TPT_DS_Child_Q,1,num_years)+...
              IntvnCov_TPT.*(UC_TPT_T+UC_TPT_NT.*repmat(INFL,num_intv,1)).*repmat(TPT_Tx_P15_DS_num,num_intv,1).*repmat(TPT_DS_Adult_pin,1,num_years).*repmat(TPT_DS_Adult_Q,1,num_years)+...
              IntvnCov_TPT.*(UC_TPT_T+UC_TPT_NT.*repmat(INFL,num_intv,1)).*repmat(TPT_Tx_U15_DR_num,num_intv,1).*repmat(TPT_DR_Child_pin,1,num_years).*repmat(TPT_DR_Child_Q,1,num_years)+...
              IntvnCov_TPT.*(UC_TPT_T+UC_TPT_NT.*repmat(INFL,num_intv,1)).*repmat(TPT_Tx_P15_DR_num,num_intv,1).*repmat(TPT_DR_Adult_pin,1,num_years).*repmat(TPT_DR_Adult_Q,1,num_years);
           
TPT_POP=TPT_POP +...
              IntvnCov_TPT.*repmat(TPT_Tx_U15_DS_num,num_intv,1).*repmat(TPT_DS_Child_pin,1,num_years).*repmat(TPT_DS_Child_Q,1,num_years)+...
              IntvnCov_TPT.*repmat(TPT_Tx_P15_DS_num,num_intv,1).*repmat(TPT_DS_Adult_pin,1,num_years).*repmat(TPT_DS_Adult_Q,1,num_years)+...
              IntvnCov_TPT.*repmat(TPT_Tx_U15_DR_num,num_intv,1).*repmat(TPT_DR_Child_pin,1,num_years).*repmat(TPT_DR_Child_Q,1,num_years)+...
              IntvnCov_TPT.*repmat(TPT_Tx_P15_DR_num,num_intv,1).*repmat(TPT_DR_Adult_pin,1,num_years).*repmat(TPT_DR_Adult_Q,1,num_years);
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DirectRN=sum(Dx_RN,1)+sum(Tx_RN,1)+sum(TPT_RN,1)


% sum_dx=sum(Dx_RN,1)
% sum_tx=sum(Tx_RN,1)
% sum_tpt=sum(TPT_RN,1)
% 
% pause

if( ~isempty(intersect([IntvnList],[Intvn_PI_0:Intvn_PI_75])) ),
    enabler_markup=enabler_markup_baseline;
end

enabler_markup=enabler_markup*ones(size(DirectRN));

if( ~isempty(intersect([IntvnList],[Intvn_PI_0:Intvn_PI_75])) ),
    enabler_markup(6:end)=enabler_markup(5);
end

%add enbler costs as percentage of direct costs/budget
EnablerRN=DirectRN.*enabler_markup./(1-enabler_markup);

if( ~isempty(intersect([IntvnList],[Intvn_PI_0:Intvn_PI_75])) ),
    EnablerRN(6:end)=EnablerRN(5);
end


%add program costs as percentage of direct costs and enablers 
DirectRN_Enabler_MarkedUp=DirectRN+EnablerRN;

ProgramCosts0=DirectRN_Enabler_MarkedUp*program_costs_markup;

if(PF_GP==0)
ProgramCosts0(6:end)=ProgramCosts0(5);

INFL_R=INFL_Val/100;
PC_inflator=ones(1,length(NOTI.years));
PC_inflator(2)=1+2/100;%1+INFL_R;
for I=3:length(NOTI.years);
 PC_inflator(I)=PC_inflator(I-1)*(1+INFL_R);
end;

%PC_inflator(7:end)=PC_inflator(6);
ProgramCosts=ProgramCosts0.*PC_inflator;
end

if(PF_GP==1)
ProgramCosts0(9:end)=ProgramCosts0(8);

INFL_R=INFL_Val/100;
PC_inflator=ones(1,length(NOTI.years));
PC_inflator(2)=1+2/100;%1+INFL_R;
for I=3:length(NOTI.years);
 PC_inflator(I)=PC_inflator(I-1)*(1+INFL_R);
end;

%PC_inflator(7:end)=PC_inflator(6);
ProgramCosts=ProgramCosts0.*PC_inflator;

if( ~isempty(intersect([IntvnList],[Intvn_PI_0:Intvn_PI_75])) ),
    PC_inflator(6:end)=PC_inflator(5);
    ProgramCosts=ProgramCosts0.*PC_inflator;
end

end

% ind=find(noti_years==2022);
% PC_inflator=3/100;
% ProgramCosts(1)=ProgramCosts0(1);
% for II=ind+1:length(noti_years)
% ProgramCosts(II)=ProgramCosts0(II-1)*(1+PC_inflator);
% end

% IntvnList
% DirectRN_Enabler_MarkedUp
% ProgramCosts
% Vacc_Costs

Total_RN=DirectRN_Enabler_MarkedUp+ProgramCosts+Vac_UC*Vacc_Costs;


RN_Out=[];
RN_Out{1}=Total_RN;
RN_Out{2}=DirectRN_Enabler_MarkedUp;
RN_Out{3}=ProgramCosts;


RN_Outputs=[];

%Write resource needs report
%bReportRNDetails=1;
if(bReportRNDetails)
    
RN_ScrDxRows=3:30;
RN_TxRows=32:73;
RN_TPTRows=75:88;
RN_DirectCostsRow=86;
RN_PCRow=87;
RN_EnablersRow=88;
RN_VaccRow=89;
RN_TotalRow=90;

RN_Table=Intv_List;
POP_Table=Intv_List;
UC_Table=Intv_List;    

%Screening and Dx
for I=1:size(Dx_RN,1)
for J=1:size(Dx_RN,2)
    RN_Table{RN_ScrDxRows(1)+I-1,2+J}=Dx_RN(I,J);
    POP_Table{RN_ScrDxRows(1)+I-1,2+J}=Dx_POP(I,J);
    UC_Table{RN_ScrDxRows(1)+I-1,2+J}=(UC_Dx_T_0(I,J)+INFL(J)*UC_Dx_NT_0(I,J));
end
end

%Treatment
for I=1:size(Tx_RN,1)
for J=1:size(Tx_RN,2)
    RN_Table{RN_TxRows(1)+I-1,2+J}=Tx_RN(I,J);
    POP_Table{RN_TxRows(1)+I-1,2+J}=Tx_POP(I,J);
    UC_Table{RN_TxRows(1)+I-1,2+J}=(UC_Tx_T(I,J)+INFL(J)*UC_Tx_NT(I,J));
end
end

%Prevention
for I=1:size(TPT_RN,1)
for J=1:size(TPT_RN,2)
    RN_Table{RN_TPTRows(1)+I-1,2+J}=TPT_RN(I,J);
    UC_Table{RN_TPTRows(1)+I-1,2+J}=(UC_TPT_T(I,J)+INFL(J)*UC_TPT_NT(I,J));
end
end

%Prevention
for I=1:size(TPT_POP,1)
for J=1:size(TPT_POP,2)
    POP_Table{RN_TPTRows(1)+I-1,2+J}=TPT_POP(I,J);
end
end

for J=1:size(DirectRN,2)
    RN_Table{RN_DirectCostsRow,2+J}=DirectRN(1,J);
    RN_Table{RN_PCRow,2+J}=ProgramCosts(1,J);
    RN_Table{RN_EnablersRow,2+J}=EnablerRN(1,J);
    RN_Table{RN_VaccRow,2+J}=Vac_UC*Vacc_Costs(1,J);
    RN_Table{RN_TotalRow,2+J}=Total_RN(1,J);
end


RN_Template = 'RN_Table.xls';
sourceTable = fullfile('C:\work\GlobalModel\ScenarioModel\',RN_Template);

if( ~isempty(intersect([IntvnList],[Intvn_Baseline])) )
    outname=['RN_Table_Baseline',ISO3,'_Scn',num2str(Scn_Num),'.xls'];
    outname= fullfile('C:\work\GlobalModel\ScenarioModel\RNTableBaseline\',outname);
else
    outname=['RN_Table_',ISO3,'ic_Scn',num2str(Scn_Num),'.xls'];  
    outname= fullfile('C:\work\GlobalModel\ScenarioModel\RNTableTBGP\',outname);
end

sourceTable
outname

%make a copy of the template RN table
pause(1)
copyfile(sourceTable,outname);
pause(1)

xlswrite(outname,RN_Table,'RN_Table','A1:K90')
pause(0.5)
xlswrite(outname,POP_Table,'POP_Table','A1:K85')
pause(0.5)
xlswrite(outname,UC_Table,'UC_Table','A1:K85')
pause(0.5)

xlswrite(outname,ScrByGrp,'ScrByGrp','B1:J20')
pause(0.5)
xlswrite(outname,DxRefByGrp,'DxRefByGrp','B1:J20')
pause(0.5)
xlswrite(outname,DxByGrp,'DxByGrp','B1:J20')
pause(0.5)
xlswrite(outname,TPTDxByGrp,'TPTDxByGrp','B1:J20')
pause(0.5)



'written report'

%save outputs
RN_Outputs{1}=Dx_RN;
RN_Outputs{2}=Dx_POP;
RN_Outputs{3}=UC_Dx;

RN_Outputs{4}=Tx_RN;
RN_Outputs{5}=Tx_POP;
RN_Outputs{6}=UC_Tx;

RN_Outputs{7}=TPT_RN;
RN_Outputs{9}=UC_TPT;

RN_Outputs{10}=DirectRN;
RN_Outputs{11}=ProgramCosts;
RN_Outputs{12}=EnablerRN;
RN_Outputs{13}=Total_RN;

RN_Outputs{15}=RN_Table;
RN_Outputs{16}=POP_Table;
RN_Outputs{17}=UC_Table;
RN_Outputs{18}=ScrByGrp;
RN_Outputs{19}=DxRefByGrp;
RN_Outputs{20}=DxByGrp;
RN_Outputs{21}=TPTDxByGrp;

end



function [zUC,zUC_T,zUC_NT]=GetUnitCost(UC_dat, UC_list, UC_years)    
zUC=[];
row=0;
for I=1:length(UC_list)
for J=1:size(UC_dat,1)
if(UC_list(I)==UC_dat{J,3})
 row=row+1;
 UC_USD_NT=UC_dat{J,4}.UC_USD_NT;
 UC_USD_T=UC_dat{J,4}.UC_USD_T;
 UC_USD=UC_dat{J,4}.UC_USD;
 [C,IA,IB] = intersect(UC_dat{J,4}.years,UC_years);
 uc=UC_USD(IA);
 zUC(row,:)=uc;
 
 uc=UC_USD_T(IA);
 zUC_T(row,:)=uc;
 
 uc=UC_USD_NT(IA);
 zUC_NT(row,:)=uc;
 

end
end
end

end



end


