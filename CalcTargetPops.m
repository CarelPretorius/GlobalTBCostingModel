function [CostingData,ImpactData]=CalcTargetPops(ISO3, TargetPop_Data, NOTI_Dat, CostIntvn, ImpactDenoms)
PF_GP=1;

noti_years=NOTI_Dat{1};%2022:2030;
noti_target=NOTI_Dat{2};
if(length(noti_target)==9),noti_target(10:14)=noti_target(9);end

DP_pop_15Plus = NOTI_Dat{3};

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



PI_Factor(Intvn_PI_0)=0.01;
PI_Factor(Intvn_PI_25)=0.15;
PI_Factor(Intvn_PI_50)=0.3;
PI_Factor(Intvn_PI_75)=0.5;


GP_Factor=ones(Intvn_Baseline,1);
GP_Factor(Intvn_GP_25)=0.25;
GP_Factor(Intvn_GP_50)=0.5;
GP_Factor(Intvn_GP_75)=0.75;


IntvnList=CostIntvn.IntvnList;

BaseYear=CostIntvn.year1;
ScaleYear=CostIntvn.year2;
c0=[];
if(BaseYear>2022+2),c0=ones(1,length(2022:BaseYear-2));end

CostEndYear=CostIntvn.year3;
CostYears2=CostEndYear-ScaleYear;
CostYearsN=length(noti_years);

rp_15p=[];

%%%%%%%%%%%%%%%%%%%%%%%%%
TB_SEN = 1;
TB_MDR = 2;
TB_ResistanceLen = 2;

TB_ResistAge0_14 = 1;
TB_ResistAge15p  = 2;
TB_ResistAgeLen  = 2;

TB_NewCases=1;
TB_RetreatCases = 2;
TB_NewRetreatLen = 2;

TB_Child = 1;
TB_Adult = 2;
TB_ChildAdultLen = 2;

TB_PTB = 1;
TB_ETB = 2;
TB_PulLen = 2;

TB_HH0_4  = 1 ;
TB_HH5_14 = 2;
TB_HH15p  = 3;
TB_HHAgeLen = 3;

TB_ART0_9    = 1;
TB_ART10_14  = 2;
TB_ART15p    = 3;
TB_ARTAgeLen = 3;

TB_ARTNotServere    = 1;
TB_ARTSevereIllness = 2;
TB_ARTSevereLen     = 2;

TB_HRG_HighTBPrev        = 1;
TB_HRG_Miners            = 2;
TB_HRG_SeekingCare       = 3;
TB_HRG_StructuralRFs     = 4;
TB_HRG_Prisoners         = 5;
TB_HRG_UntreatedFibrosis = 6;
TB_HRG_Other             = 7;
TB_HRG_Len               = 1; %using 1 HRG currently


% Pulmonary TB
TB_PTB_HIVn_014_grp  = 1;
TB_PTB_HIVn_15p_grp  = 2;
TB_PTB_HIVp_09_grp   = 3;
TB_PTB_HIVp_1014_grp = 4;
TB_PTB_HIVp_15p_grp  = 5;

% Extra-Pulmonary TB
TB_ETB_HIVn_014_grp  = 6;
TB_ETB_HIVn_15p_grp  = 7;
TB_ETB_HIVp_09_grp   = 8;
TB_ETB_HIVp_1014_grp = 9;
TB_ETB_HIVp_15p_grp  = 10;

TB_PatientInitiated_count = 10;


TB_PatientInitiated_List = [TB_PTB_HIVn_014_grp,... 
                            TB_PTB_HIVn_15p_grp,... 
                            TB_PTB_HIVp_09_grp ...
                            TB_PTB_HIVp_1014_grp,...
                            TB_PTB_HIVp_15p_grp,... 
                            TB_ETB_HIVn_014_grp,... 
                            TB_ETB_HIVn_15p_grp,... 
                            TB_ETB_HIVp_09_grp,... 
                            TB_ETB_HIVp_1014_grp,...
                            TB_ETB_HIVp_15p_grp];
 
TB_HH0_4_grp  = 11;
TB_HH5_14_grp = 12;
TB_HH15p_grp  = 13;                        
                                             
TB_ARTNotServere_0_9_grp    = 14;
TB_ARTNotServere_10_14_grp  = 15;
TB_ARTNotServere15p_grp     = 16;

TB_ARTSevereIllness_0_9_grp    = 17;
TB_ARTSevereIllness_10_14_grp  = 18;
TB_ARTSevereIllness15p_grp     = 19;

TB_HRG_HighTBPrev_grp =20;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DxByGrp=zeros(TB_HRG_HighTBPrev_grp,length(noti_years));
ScrByGrp=zeros(TB_HRG_HighTBPrev_grp,length(noti_years));
DxRefByGrp=zeros(TB_HRG_HighTBPrev_grp,length(noti_years));
TPTDxByGrp=zeros(TB_HRG_HighTBPrev_grp,length(noti_years));
%%%%%


% path='C:\work\GlobalModel\';
% fname=[path,'WHO_TB_CountryDataUpdateWorkbook.xlsx'];
% 
% [~,~,Noti_Profile_dat]=xlsread(fname,'NotificationDistributionByType3');
% 
% fname=[path,'TGFCostingModel_ImplementationV2c.xlsx'];
% 
% [~,~,RR_ProfileU15_dat]=xlsread(fname,'RR_Profile_U15');
% [~,~,RR_Profile15P_dat]=xlsread(fname,'RR_Profile_15PLus');
% 
% [~,~,HH_Inputs_dat]=xlsread(fname,'HHContactInputs');
% [~,~,ART_Inputs_dat]=xlsread(fname,'ARTCohortInputs');
% [~,~,HRG_Inputs_dat]=xlsread(fname,'HRGInputs');
% 
% 
% [~,~,DST_dat]=xlsread(fname,'DST_COverage');


%assigning pre-read data
Noti_Profile_dat=TargetPop_Data{1};
RR_ProfileU15_dat=TargetPop_Data{2};
RR_Profile15P_dat=TargetPop_Data{3};
HH_Inputs_dat=TargetPop_Data{4};
ART_Inputs_dat=TargetPop_Data{5};
HRG_Inputs_dat=TargetPop_Data{6};
DST_dat=TargetPop_Data{7};
ART_dat=TargetPop_Data{9};
ALG_Dat=TargetPop_Data{10};
%Noti_GP_dat=TargetPop_Data{11};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ind=find(strcmp(Noti_GP_dat(:,3),ISO3));
%if(~isempty(ind))
%    noti_target=cell2mat(Noti_GP_dat(ind,8:16));
%end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ART data
ind=find(strcmp(ART_dat(:,3),ISO3));
ART_dat=cell2mat(ART_dat(ind,60:73));
if(CostIntvn.art_num==0)
 ART_dat=0.01*ones(size(ART_dat));
end

ART_dat_0to9=sum(ART_dat(1:2,:),1);
ART_dat_10to14=sum(ART_dat(3,:),1);
ART_dat_15p=sum(ART_dat(4:end,:),1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ARTFromAIM{TB_ARTNotServere,TB_ART0_9}=0.9*ART_dat_0to9;
ARTFromAIM{TB_ARTNotServere,TB_ART10_14}=0.9*ART_dat_10to14;
ARTFromAIM{TB_ARTNotServere,TB_ART15p}=0.9*ART_dat_15p;

ARTFromAIM{TB_ARTSevereIllness,TB_ART0_9}=0.1*ART_dat_0to9;
ARTFromAIM{TB_ARTSevereIllness,TB_ART10_14}=0.1*ART_dat_10to14;
ARTFromAIM{TB_ARTSevereIllness,TB_ART15p}=0.1*ART_dat_15p;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Intervention specification
%Systematic screening
DoHH_ACF=CostIntvn.DoHH_ACF;
DoART_ACF=CostIntvn.DoART_ACF;
DoHRG_ACF=CostIntvn.DoHRG_ACF;

%For now, remove ACF for baseline, just do const cov for ACF
if( ~isempty(intersect([IntvnList],[Intvn_Baseline,Intvn_PF])) ), 
DoHH_ACF=1;
DoART_ACF=0;
DoHRG_ACF=0;
end

if( ~isempty(intersect([IntvnList],[Intvn_PI_0:Intvn_PI_75])) ),
DoHH_ACF=1;
DoART_ACF=0;
DoHRG_ACF=0;
end

%Systematic screening targets
HH_Tracing_Base=CostIntvn.HH_Tracing_Base;
HH_TBScr_Base=CostIntvn.HH_TBScr_Base;
ART_TBScr_Base=CostIntvn.ART_TBScr_Base;
HRG_TBScr_Base=CostIntvn.HRG_TBScr_Base;

HH_Tracing_Target=CostIntvn.HH_Tracing_Target;
HH_TBScr_Target=CostIntvn.HH_TBScr_Target;
ART_TBScr_Target=CostIntvn.ART_TBScr_Target;
HRG_TBScr_Target=CostIntvn.HRG_TBScr_Target;

%TPT targets
HH_TPTCov_Base=0.2;%CostIntvn.HH_TPTCov_Base;
ART_TPTCov_Base=0.05;%CostIntvn.ART_TPTCov_Base;
HRG_TPTCov_Base=0;%CostIntvn.HRG_TPTCov_Base;

HH_TPTCov_Target=CostIntvn.HH_TPTCov_Target;
ART_TPTCov_Target=CostIntvn.ART_TPTCov_Target;
HRG_TPTCov_Target=CostIntvn.HRG_TPTCov_Target;

%DST targets
DST_Cov_RR_DST_Base=CostIntvn.DST_Cov_RR_DST_Base;
DST_Cov_INH_RR_Sens_DST_Base=CostIntvn.DST_Cov_INH_RR_Sens_DST_Base;
DST_Cov_FQ_RR_Res_DST_Base=CostIntvn.DST_Cov_FQ_RR_Res_DST_Base;

DST_Cov_RR_DST_Target=CostIntvn.DST_Cov_RR_DST_Target;
DST_Cov_INH_RR_Sens_DST_Target=CostIntvn.DST_Cov_INH_RR_Sens_DST_Target;
DST_Cov_FQ_RR_Res_DST_Target=CostIntvn.DST_Cov_FQ_RR_Res_DST_Target;

%Default rates
TxDS_Default_Base=CostIntvn.TxDS_Default_Base;
TxDR_Default_Base=CostIntvn.TxDR_Default_Base;

TxDS_Default_Target=CostIntvn.TxDS_Default_Target;
TxDR_Default_Target=CostIntvn.TxDR_Default_Target;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
noti_ind=find(strcmp(Noti_Profile_dat(:,3),ISO3)); 
noti_dat=Noti_Profile_dat(noti_ind,:);

NOTI=[];
NOTI.years=noti_years;
%noti type
NOTI.c_newinc=noti_dat{17};
NOTI.ret_nrel=noti_dat{18};
NOTI.new_labconf=noti_dat{19};
NOTI.new_clindx=noti_dat{20};
NOTI.new_ep=noti_dat{21};
NOTI.ret_rel_labconf=noti_dat{22};
NOTI.ret_rel_clindx=noti_dat{23};
NOTI.ret_rel_ep=noti_dat{24};
NOTI.PropPTB=(NOTI.new_labconf+NOTI.new_clindx)/(NOTI.new_labconf+NOTI.new_clindx+NOTI.new_ep);

%noti age
NOTI.age=[];
NOTI.newrel_04=noti_dat{43};
NOTI.newrel_59=noti_dat{44};	
NOTI.newrel_1014=noti_dat{45};
NOTI.newrel_09=NOTI.newrel_04+NOTI.newrel_59;
NOTI.newrel_015=NOTI.newrel_04+NOTI.newrel_59+NOTI.newrel_1014;
NOTI.newrel_514=noti_dat{46};	
NOTI.newrel_014=noti_dat{47};	
NOTI.newrel_1519=noti_dat{48};	
NOTI.newrel_2024=noti_dat{49};	
NOTI.newrel_1524=noti_dat{50};	
NOTI.newrel_2534=noti_dat{51};	
NOTI.newrel_3544=noti_dat{52};	
NOTI.newrel_4554=noti_dat{53};	
NOTI.newrel_5564=noti_dat{54};	
NOTI.newrel_65=noti_dat{55};	
NOTI.newrel_15plus=noti_dat{56};

%hiv
NOTI.hiv=[];
NOTI.newrel_hivpos=noti_dat{63};
NOTI.newrel_art=noti_dat{64};

%bacp
NOTI.Bacp=[];
NOTI.Bacp_new=noti_dat{66};
NOTI.Bacp_ret=noti_dat{67};


%resitance profile
rr_ind=find(strcmp(RR_ProfileU15_dat(:,3),ISO3)); 
rr_dat=RR_ProfileU15_dat(rr_ind,:);


NOTI.U15_ResisProfileNew=[];
NOTI.U15_RifR_new=rr_dat{17};
NOTI.U15_FQS_new=rr_dat{18};
NOTI.U15_FQS_reg1_new=rr_dat{19};
NOTI.U15_FQS_reg2_new=rr_dat{20};
NOTI.U15_FQR_new=rr_dat{21};
NOTI.U15_FQR_reg1_new=rr_dat{22};
NOTI.U15_FQR_reg2_new=rr_dat{23};
NOTI.U15_RifS_new=rr_dat{24};
NOTI.U15_InhS_new=rr_dat{25};
NOTI.U15_InhS_reg1_new=rr_dat{26};
NOTI.U15_InhS_reg2_new=rr_dat{27};
NOTI.U15_InhS_reg3_new=rr_dat{28};
NOTI.U15_InhR_new=rr_dat{29};


NOTI.U15_ResisProfileRew=[];
NOTI.U15_RifR_ret=rr_dat{31};
NOTI.U15_FQS_ret=rr_dat{32};
NOTI.U15_FQS_reg1_ret=rr_dat{33};
NOTI.U15_FQS_reg2_ret=rr_dat{34};
NOTI.U15_FQR_ret=rr_dat{35};
NOTI.U15_FQR_reg1_ret=rr_dat{36};
NOTI.U15_FQR_reg2_ret=rr_dat{36};
NOTI.U15_RifS_ret=rr_dat{38};
NOTI.U15_InhS_ret=rr_dat{39};
NOTI.U15_InhS_reg1_ret=rr_dat{40};
NOTI.U15_InhS_reg2_ret=rr_dat{41};
NOTI.U15_InhS_reg3_ret=rr_dat{42};
NOTI.U15_InhR_ret=rr_dat{43};

NOTI.RifR_new=NOTI.U15_RifR_new;
NOTI.FQS_new=NOTI.U15_FQS_new;
NOTI.FQR_new=NOTI.U15_FQR_new;
NOTI.RifS_new=NOTI.U15_RifS_new;
NOTI.InhS_new=NOTI.U15_InhS_new;
NOTI.InhR_new=NOTI.U15_InhR_new;

NOTI.RifR_ret=NOTI.U15_RifR_ret;
NOTI.FQS_ret=NOTI.U15_FQS_ret;
NOTI.FQR_ret=NOTI.U15_FQR_ret;
NOTI.RifS_ret=NOTI.U15_RifS_ret;
NOTI.InhS_ret=NOTI.U15_InhS_ret;
NOTI.InhR_ret=NOTI.U15_InhR_ret;

rr_ind=find(strcmp(RR_Profile15P_dat(:,3),ISO3)); 
rr_dat=RR_Profile15P_dat(rr_ind,:);

NOTI.P15_ResisProfileNew=[];
NOTI.P15_RifR_new=rr_dat{17};
NOTI.P15_FQS_new=rr_dat{18};
NOTI.P15_FQS_reg1_new=rr_dat{19};
NOTI.P15_FQS_reg2_new=rr_dat{20};
NOTI.P15_FQR_new=rr_dat{21};
NOTI.P15_FQR_reg1_new=rr_dat{22};
NOTI.P15_FQR_reg2_new=rr_dat{23};
NOTI.P15_RifS_new=rr_dat{24};
NOTI.P15_InhS_new=rr_dat{25};
NOTI.P15_InhS_reg1_new=rr_dat{26};
NOTI.P15_InhS_reg2_new=rr_dat{27};
NOTI.P15_InhR_new=rr_dat{28};

NOTI.P15_ResisProfileRew=[];
NOTI.P15_RifR_ret=rr_dat{30};
NOTI.P15_FQS_ret=rr_dat{31};
NOTI.P15_FQS_reg1_ret=rr_dat{32};
NOTI.P15_FQS_reg2_ret=rr_dat{33};
NOTI.P15_FQR_ret=rr_dat{34};
NOTI.P15_FQR_reg1_ret=rr_dat{35};
NOTI.P15_FQR_reg2_ret=rr_dat{36};
NOTI.P15_RifS_ret=rr_dat{37};
NOTI.P15_InhS_ret=rr_dat{38};
NOTI.P15_InhS_reg1_ret=rr_dat{39};
NOTI.P15_InhS_reg2_ret=rr_dat{40};
NOTI.P15_InhR_new=rr_dat{41};


% x=[];
% x.P15_ResisProfileNew=NOTI.P15_ResisProfileNew;
% x.P15_RifR_new=NOTI.P15_RifR_new;
% x.P15_FQS_new=NOTI.P15_FQS_new;
% x.P15_FQS_reg1_new=NOTI.P15_FQS_reg1_new;
% x.P15_FQS_reg2_new=NOTI.P15_FQS_reg2_new;
% x.P15_FQR_new=NOTI.P15_FQR_new;
% x.P15_FQR_reg1_new=NOTI.P15_FQR_reg1_new;
% x.P15_FQR_reg2_new=NOTI.P15_FQR_reg2_new;
% x.P15_RifS_new=NOTI.P15_RifS_new;
% x.P15_InhS_new=NOTI.P15_InhS_new;
% x.P15_InhS_reg1_new=NOTI.P15_InhS_reg1_new;
% x.P15_InhS_reg2_new=NOTI.P15_InhS_reg2_new;
% x.P15_InhR_new=NOTI.P15_InhR_new;
% 
% x
% pause



%Screening and Diagnostic algorithms
a_rows=[3:12,15:17,19:24,26];
ALG.BaseScrSens=cell2mat(ALG_Dat(a_rows,9));
ALG.BaseScrSpec=cell2mat(ALG_Dat(a_rows,10));
ALG.BaseDxSens=cell2mat(ALG_Dat(a_rows,11));
ALG.BaseDxSpec=cell2mat(ALG_Dat(a_rows,12));
ALG.BasePropCurrentScr=cell2mat(ALG_Dat(a_rows,13));
ALG.BasePropCurrentDx=cell2mat(ALG_Dat(a_rows,14));

ALG.TargetScrSens=cell2mat(ALG_Dat(a_rows,17));
ALG.TargetScrSpec=cell2mat(ALG_Dat(a_rows,18));
ALG.TargetDxSens=cell2mat(ALG_Dat(a_rows,19));
ALG.TargetDxSpec=cell2mat(ALG_Dat(a_rows,20));
ALG.TargetPropCurrentScr=cell2mat(ALG_Dat(a_rows,21));
ALG.TargetPropCurrentDx=cell2mat(ALG_Dat(a_rows,22));


if( isempty(intersect([IntvnList],[Intvn_ACF:Intvn_TPT,Intvn_All,Intvn_GP_25:Intvn_GP_75])) ),    
        ALG.TargetPropCurrentScr=ALG.BasePropCurrentScr;
        ALG.TargetPropCurrentDx=ALG.BasePropCurrentDx;
end


% ALG.TargetScrSens=ones(size(ALG.TargetScrSens));
% ALG.TargetPropCurrentScr=ones(size(ALG.TargetPropCurrentScr));

for JJ=TB_PTB_HIVn_014_grp:TB_HRG_HighTBPrev_grp

c1=ALG.BasePropCurrentScr(JJ)*ALG.BaseScrSens(JJ)+(1-ALG.BasePropCurrentScr(JJ))*ALG.TargetScrSens(JJ);
c2=(1-ALG.TargetPropCurrentScr(JJ))*ALG.BaseScrSens(JJ)+ALG.TargetPropCurrentScr(JJ)*ALG.TargetScrSens(JJ);
if(PF_GP==0)
    c3=linspace(c1,c2,ScaleYear-BaseYear+1);
    c4=c2*ones(1,CostYears2);
    c5=c2*ones(1,5);
    ALG.ScrSens(JJ,:)=[c0*c1(1),c1,c3,c4,c5];
else
    c3=c1*ones(1,ScaleYear-BaseYear);
    c4=linspace(c1,c2,CostYears2+1);
    c5=c2*ones(1,5);
    ALG.ScrSens(JJ,:)=[c0*c1(1),c1,c3,c4,c5];
end

c1=ALG.BasePropCurrentScr(JJ)*ALG.BaseScrSpec(JJ)+(1-ALG.BasePropCurrentScr(JJ))*ALG.TargetScrSpec(JJ);
c2=(1-ALG.TargetPropCurrentScr(JJ))*ALG.BaseScrSpec(JJ)+ALG.TargetPropCurrentScr(JJ)*ALG.TargetScrSpec(JJ);
if(PF_GP==0)
    c3=linspace(c1,c2,ScaleYear-BaseYear+1);
    c4=c2*ones(1,CostYears2);
    c5=c2*ones(1,5);
    ALG.ScrSpec(JJ,:)=[c0*c1(1),c1,c3,c4,c5];
else
    c3=c1*ones(1,ScaleYear-BaseYear);
    c4=linspace(c1,c2,CostYears2+1);
    c5=c2*ones(1,5);
    ALG.ScrSpec(JJ,:)=[c0*c1(1),c1,c3,c4,c5];    
end


c1=ALG.BasePropCurrentDx(JJ)*ALG.BaseDxSens(JJ)+(1-ALG.BasePropCurrentDx(JJ))*ALG.TargetDxSens(JJ);
c2=(1-ALG.TargetPropCurrentDx(JJ))*ALG.BaseDxSens(JJ)+ALG.TargetPropCurrentDx(JJ)*ALG.TargetDxSens(JJ);
if(PF_GP==0)
    c3=linspace(c1,c2,ScaleYear-BaseYear+1);
    c4=c2*ones(1,CostYears2);
    c5=c2*ones(1,5);
    ALG.DxSens(JJ,:)=[c0*c1(1),c1,c3,c4,c5];
else
    c3=c1*ones(1,ScaleYear-BaseYear);
    c4=linspace(c1,c2,CostYears2+1);
    c5=c2*ones(1,5);
    ALG.DxSens(JJ,:)=[c0*c1(1),c1,c3,c4,c5];
end


c1=ALG.BasePropCurrentDx(JJ)*ALG.BaseDxSpec(JJ)+(1-ALG.BasePropCurrentDx(JJ))*ALG.TargetDxSpec(JJ);
c2=(1-ALG.TargetPropCurrentDx(JJ))*ALG.BaseDxSpec(JJ)+ALG.TargetPropCurrentDx(JJ)*ALG.TargetDxSpec(JJ);
if(PF_GP==0)
    c3=linspace(c1,c2,ScaleYear-BaseYear+1);
    c4=c2*ones(1,CostYears2);
    c5=c2*ones(1,5);
    ALG.DxSpec(JJ,:)=[c0*c1(1),c1,c3,c4,c5];
else
    c3=c1*ones(1,ScaleYear-BaseYear);
    c4=linspace(c1,c2,CostYears2+1);
    c5=c2*ones(1,5);
    ALG.DxSpec(JJ,:)=[c0*c1(1),c1,c3,c4,c5];    
end

end


%DST coverage
dst_ind=find(strcmp(DST_dat(:,2),ISO3)); 
dst_dat=DST_dat(dst_ind,:);

DST_Cov=[];
% DST_Cov.RR_DST_base=dst_dat{5};
% DST_Cov.INH_RR_Sens_DST_base=dst_dat{6};
% DST_Cov.FQ_RR_Res_DST_base=dst_dat{7};

% DST_Cov.RR_DST_target=dst_dat{9};
% DST_Cov.INH_RR_Sens_DST_target=dst_dat{10};
% DST_Cov.FQ_RR_Res_DST_target=dst_dat{11};

DST_Cov.RR_DST_Base=DST_Cov_RR_DST_Base;
DST_Cov.INH_RR_Sens_DST_Base=DST_Cov_INH_RR_Sens_DST_Base;
DST_Cov.FQ_RR_Res_DST_Base=DST_Cov_FQ_RR_Res_DST_Base;

DST_Cov.RR_DST_Target=DST_Cov_RR_DST_Target;
DST_Cov.INH_RR_Sens_DST_Target=DST_Cov_INH_RR_Sens_DST_Target;
DST_Cov.FQ_RR_Res_DST_Target=DST_Cov_FQ_RR_Res_DST_Target;


% if( ~isempty(intersect([IntvnList],[Intvn_PI_0:Intvn_PI_75])) ),     
%      DST_Cov.RR_DST_Target=DST_Cov.RR_DST_Base;%PI_Factor(IntvnList)*DST_Cov.RR_DST_Target;
%      DST_Cov.INH_RR_Sens_DST_Target=DST_Cov.INH_RR_Sens_DST_Base;%PI_Factor(IntvnList)*DST_Cov.INH_RR_Sens_DST_Target;
%      DST_Cov.FQ_RR_Res_DST_Target=DST_Cov.FQ_RR_Res_DST_Base;%PI_Factor(IntvnList)*DST_Cov.FQ_RR_Res_DST_Target;   
% end
if( ~isempty(intersect([IntvnList],[Intvn_GP_25:Intvn_GP_75])) ),
     dt=max(DST_Cov.RR_DST_Target-DST_Cov.RR_DST_Base,0);
     DST_Cov.RR_DST_Target=DST_Cov.RR_DST_Base+GP_Factor(IntvnList)*dt;
     
     dt=max(DST_Cov.INH_RR_Sens_DST_Target-DST_Cov.INH_RR_Sens_DST_Base,0);
     DST_Cov.INH_RR_Sens_DST_Target=DST_Cov.INH_RR_Sens_DST_Base+GP_Factor(IntvnList)*dt;
     
     dt=max(DST_Cov.FQ_RR_Res_DST_Target-DST_Cov.FQ_RR_Res_DST_Base,0);
     DST_Cov.FQ_RR_Res_DST_Target=DST_Cov.FQ_RR_Res_DST_Base+GP_Factor(IntvnList)*dt;   
end
if( isempty(intersect([IntvnList],[Intvn_PI_0:Intvn_PI_75,Intvn_DSTandDef,Intvn_All,Intvn_GP_25:Intvn_GP_75])) ),
    DST_Cov.RR_DST_Target=DST_Cov.RR_DST_Base;
    DST_Cov.INH_RR_Sens_DST_Target=DST_Cov.INH_RR_Sens_DST_Base;
    DST_Cov.FQ_RR_Res_DST_Target=DST_Cov.FQ_RR_Res_DST_Base;
end    

c1=DST_Cov.RR_DST_Base;
c2=DST_Cov.RR_DST_Target;
if(PF_GP==0)
    c3=linspace(c1,c2,ScaleYear-BaseYear+1);
    c4=c2*ones(1,CostYears2);
    c5=c2*ones(1,5);
    DST_Cov.RR_DST=[c0*c1(1),c1,c3,c4,c5];
else
    c3=c1*ones(1,ScaleYear-BaseYear);
    c4=linspace(c1,c2,CostYears2+1);
    c5=c2*ones(1,5);
    DST_Cov.RR_DST=[c0*c1(1),c1,c3,c4,c5];
end


c1=DST_Cov.INH_RR_Sens_DST_Base;
c2=DST_Cov.INH_RR_Sens_DST_Target;
if(PF_GP==0)
    c3=linspace(c1,c2,ScaleYear-BaseYear+1);
    c4=c2*ones(1,CostYears2);
    c5=c2*ones(1,5);
    DST_Cov.INH_RR_Sens_DST=[c0*c1(1),c1,c3,c4,c5];
else
    c3=c1*ones(1,ScaleYear-BaseYear);
    c4=linspace(c1,c2,CostYears2+1);
    c5=c2*ones(1,5);
    DST_Cov.INH_RR_Sens_DST=[c0*c1(1),c1,c3,c4,c5];
end

c1=DST_Cov.FQ_RR_Res_DST_Base;
c2=DST_Cov.FQ_RR_Res_DST_Target;
if(PF_GP==0)
    c3=linspace(c1,c2,ScaleYear-BaseYear+1);
    c4=c2*ones(1,CostYears2);
    c5=c2*ones(1,5);
    DST_Cov.FQ_RR_Res_DST=[c0*c1(1),c1,c3,c4,c5];
else
    c3=c1*ones(1,ScaleYear-BaseYear);
    c4=linspace(c1,c2,CostYears2+1);
    c5=c2*ones(1,5);
    DST_Cov.FQ_RR_Res_DST=[c0*c1(1),c1,c3,c4,c5];
end

if( isempty(intersect([IntvnList],[Intvn_DSTandDef,Intvn_All,Intvn_GP_25:Intvn_GP_75])) )    
    TxDS_Default_Target=TxDS_Default_Base;
    TxDR_Default_Target=TxDR_Default_Base;
end 


c1=TxDS_Default_Base;
c2=TxDS_Default_Target;
if(PF_GP==0)
    c3=linspace(c1,c2,ScaleYear-BaseYear+1);
    c4=c2*ones(1,CostYears2);
    c5=c2*ones(1,5);
    DefaultRateDS=[c0*c1(1),c1,c3,c4,c5];
else
    c3=c1*ones(1,ScaleYear-BaseYear);
    c4=linspace(c1,c2,CostYears2+1);
    c5=c2*ones(1,5);
    DefaultRateDS=[c0*c1(1),c1,c3,c4,c5];
end


c1=TxDR_Default_Base;
c2=TxDR_Default_Target;
if(PF_GP==0)
    c3=linspace(c1,c2,ScaleYear-BaseYear+1);
    c4=c2*ones(1,CostYears2);
    c5=c2*ones(1,5);
    DefaultRateDR=[c0*c1(1),c1,c3,c4,c5];
else
    c3=c1*ones(1,ScaleYear-BaseYear);
    c4=linspace(c1,c2,CostYears2+1);
    c5=c2*ones(1,5);
    DefaultRateDR=[c0*c1(1),c1,c3,c4,c5];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%HH inputs
hh_ind=find(strcmp(HH_Inputs_dat(:,2),ISO3)); 
hh_dat=HH_Inputs_dat(hh_ind,:)

HH_Inputs.HH_Info=[];
HH_Inputs.TB_HHSize=hh_dat{4};	
HH_Inputs.TB_HHPropU5=hh_dat{5};	
HH_Inputs.TB_HHProp5_14=hh_dat{6};		
HH_Inputs.TB_HHCasesinIndexHH=hh_dat{7};	
HH_Inputs.Intv_Inputs=[];
HH_Inputs.TB_HHPropBACnScreened=hh_dat{9};

%HH_Inputs.TB_HHPIndexCasesScreened_Base=hh_dat{10};
HH_Inputs.TB_HHPIndexCasesScreened_Base=HH_Tracing_Base;
if( ~isempty(intersect([IntvnList],[Intvn_GP_25:Intvn_GP_75])) ),
    dt=max(HH_Tracing_Target-HH_Tracing_Base,0);
    HH_Tracing_Target=HH_Tracing_Base+GP_Factor(IntvnList)*dt;
end 

if( isempty(intersect([IntvnList],[Intvn_ACF,Intvn_All,Intvn_GP_25:Intvn_GP_75])) ),
    HH_Tracing_Target=HH_Inputs.TB_HHPIndexCasesScreened_Base;
end

if( ~isempty(intersect([IntvnList],[Intvn_PI_0:Intvn_PI_75])) ),     
    HH_Tracing_Target=HH_Inputs.TB_HHPIndexCasesScreened_Base;%PI_Factor(IntvnList)*HH_Tracing_Target; 
end

HH_Inputs.TB_HHPIndexCasesScreened_Target=HH_Tracing_Target;%hh_dat{11};
c1=HH_Inputs.TB_HHPIndexCasesScreened_Base;
c2=HH_Inputs.TB_HHPIndexCasesScreened_Target;
%if(PF_GP==0)
    c3=linspace(c1,c2,ScaleYear-BaseYear+1);
    c4=c2*ones(1,CostYears2);
    c5=c2*ones(1,5);
    HH_Inputs.TB_HHPIndexCasesScreened = DoHH_ACF*[c0*c1(1),c1,c3,c4,c5];
%    HH_Inputs.TB_HHPIndexCasesScreened = DoHH_ACF*[ones(1,14)];
%else
%    c3=c1*ones(1,ScaleYear-BaseYear);
%    c4=linspace(c1,c2,CostYears2+1);
%    c5=c2*ones(1,5);
%    HH_Inputs.TB_HHPIndexCasesScreened = DoHH_ACF*[c0*c1(1),c1,c3,c4,c5];
%end

%TPT coverage
HH_Inputs.TB_TPTCov_Base=HH_TPTCov_Base;
if( ~isempty(intersect([IntvnList],[Intvn_GP_25:Intvn_GP_75])) ),
    dt=max(HH_TPTCov_Target-HH_TPTCov_Base,0);
    HH_TPTCov_Target=HH_TPTCov_Base+GP_Factor(IntvnList)*dt;
end
if( isempty(intersect([IntvnList],[Intvn_TPT,Intvn_All,Intvn_GP_25:Intvn_GP_75])) ),     
    HH_TPTCov_Target=HH_Inputs.TB_TPTCov_Base;
end

if( ~isempty(intersect([IntvnList],[Intvn_PI_0:Intvn_PI_75])) ),     
    HH_TPTCov_Target=HH_Inputs.TB_TPTCov_Base;%PI_Factor(IntvnList)*HH_TPTCov_Target;    
end 

HH_Inputs.TB_TPTCov_Target=HH_TPTCov_Target;
c1=HH_Inputs.TB_TPTCov_Base;
c2=HH_Inputs.TB_TPTCov_Target;
%if(PF_GP==0)
    c3=linspace(c1,c2,ScaleYear-BaseYear+1);
    c4=c2*ones(1,CostYears2);
    c5=c2*ones(1,5);
    %HH_Inputs.HH_TPTCov = DoHH_ACF*[c0*c1(1),c1,c3,c4,c5];
    HH_Inputs.HH_TPTCov = DoHH_ACF*[ones(1,14)];
    
%else
%    c3=c1*ones(1,ScaleYear-BaseYear);
%    c4=linspace(c1,c2,CostYears2+1);
%    c5=c2*ones(1,5);
%    HH_Inputs.HH_TPTCov = DoHH_ACF*[c0*c1(1),c1,c3,c4,c5];
%end


HH_Age_0to4 = [];
%HH_Age_0to4.TB_PropScreened_Base = hh_dat{13};
HH_Age_0to4.TB_PropScreened_Base = HH_TBScr_Base;
if( ~isempty(intersect([IntvnList],[Intvn_GP_25:Intvn_GP_75])) ),
    dt=max(HH_TBScr_Target-HH_TBScr_Base,0);
    HH_TBScr_Target=HH_TBScr_Base+GP_Factor(IntvnList)*dt;
end    
if( isempty(intersect([IntvnList],[Intvn_ACF,Intvn_All,Intvn_GP_25:Intvn_GP_75])) ), 
    HH_TBScr_Target=HH_Age_0to4.TB_PropScreened_Base;
end

if( ~isempty(intersect([IntvnList],[Intvn_PI_0:Intvn_PI_75])) ),     
     HH_TBScr_Target=HH_Age_0to4.TB_PropScreened_Base;%PI_Factor(IntvnList)*HH_TBScr_Target;    
end

HH_Age_0to4.TB_PropScreened_Target = HH_TBScr_Target;%hh_dat{14};
c1=HH_Age_0to4.TB_PropScreened_Base;
c2=HH_Age_0to4.TB_PropScreened_Target;
%if(PF_GP==0)
    c3=linspace(c1,c2,ScaleYear-BaseYear+1);
    c4=c2*ones(1,CostYears2);
    c5=c2*ones(1,5);
    HH_Age_0to4.TB_PropScreened=  DoHH_ACF*[c0*c1(1),c1,c3,c4,c5];
%    HH_Age_0to4.TB_PropScreened=  DoHH_ACF*[ones(1,14)];
  
%else
%    c3=c1*ones(1,ScaleYear-BaseYear);
%    c4=linspace(c1,c2,CostYears2+1);
%    c5=c2*ones(1,5);
%    HH_Age_0to4.TB_PropScreened= [c0*c1(1),c1,c3,c4,c5];
%end


HH_Age_0to4.TB_Screen_Sens_PTB=hh_dat{15};
HH_Age_0to4.TB_Screen_Spec_PTB=hh_dat{16};
HH_Age_0to4.TB_Diag_Sens_PTB=hh_dat{17};
HH_Age_0to4.TB_Diag_Spec_PTB=hh_dat{18};
HH_Age_0to4.TB_PropDiagLinkedTx = hh_dat{19};
HH_Age_0to4.TB_PropTPTPresumptiveTx=hh_dat{20};
HH_Age_0to4.TB_PropEligibleTPTtested=hh_dat{21};
HH_Age_0to4.TB_PropEligibleLinkedTPT=hh_dat{22};
HH_Inputs.HH_Age{1}=HH_Age_0to4;

HH_Age_5to14 = [];
%HH_Age_5to14.TB_PropScreened_Base = hh_dat{24};
HH_Age_5to14.TB_PropScreened_Base = HH_TBScr_Base;
if( ~isempty(intersect([IntvnList],[Intvn_GP_25:Intvn_GP_75])) ),
    dt=max(HH_TBScr_Target-HH_TBScr_Base,0);
    HH_TBScr_Target=HH_TBScr_Base+GP_Factor(IntvnList)*dt;
end
if( isempty(intersect([IntvnList],[Intvn_ACF,Intvn_All,Intvn_GP_25:Intvn_GP_75])) ),    
    HH_TBScr_Target=HH_Age_5to14.TB_PropScreened_Base;
end
if( ~isempty(intersect([IntvnList],[Intvn_PI_0:Intvn_PI_75])) ),     
     HH_TBScr_Target=HH_Age_5to14.TB_PropScreened_Base;%PI_Factor(IntvnList)*HH_TBScr_Target;    
end

HH_Age_5to14.TB_PropScreened_Target = HH_TBScr_Target;%hh_dat{25};
c1=HH_Age_5to14.TB_PropScreened_Base;
c2=HH_Age_5to14.TB_PropScreened_Target;
%if(PF_GP==0)
    c3=linspace(c1,c2,ScaleYear-BaseYear+1);
    c4=c2*ones(1,CostYears2);
    c5=c2*ones(1,5);
    HH_Age_5to14.TB_PropScreened= DoHH_ACF*[c0*c1(1),c1,c3,c4,c5];
    HH_Age_5to14.TB_PropScreened= DoHH_ACF*[ones(1,14)]
%else
%    c3=c1*ones(1,ScaleYear-BaseYear);
%    c4=linspace(c1,c2,CostYears2+1);
%    c5=c2*ones(1,5);
%    HH_Age_5to14.TB_PropScreened= [c0*c1(1),c1,c3,c4,c5];    
%end

HH_Age_5to14.TB_Screen_Sens_PTB=hh_dat{26};
HH_Age_5to14.TB_Screen_Spec_PTB=hh_dat{27};
HH_Age_5to14.TB_Diag_Sens_PTB=hh_dat{28};
HH_Age_5to14.TB_Diag_Spec_PTB=hh_dat{29};
HH_Age_5to14.TB_PropDiagLinkedTx = hh_dat{30};
HH_Age_5to14.TB_PropTPTPresumptiveTx=hh_dat{31};
HH_Age_5to14.TB_PropEligibleTPTtested=hh_dat{32};
HH_Age_5to14.TB_PropEligibleLinkedTPT=hh_dat{33};
HH_Inputs.HH_Age{2}=HH_Age_5to14;

HH_Age_15p = [];
%HH_Age_15p.TB_PropScreened_Base = hh_dat{35};
HH_Age_15p.TB_PropScreened_Base = HH_TBScr_Base;
if( ~isempty(intersect([IntvnList],[Intvn_GP_25:Intvn_GP_75])) ), 
    dt=max(HH_TBScr_Target-HH_TBScr_Base,0);
    HH_TBScr_Target=HH_TBScr_Base+GP_Factor(IntvnList)*dt;
end
if( isempty(intersect([IntvnList],[Intvn_ACF,Intvn_All,Intvn_GP_25:Intvn_GP_75])) ),
    HH_TBScr_Target=HH_Age_15p.TB_PropScreened_Base;
end
if( ~isempty(intersect([IntvnList],[Intvn_PI_0:Intvn_PI_75])) ),     
     HH_TBScr_Target=HH_Age_15p.TB_PropScreened_Base;%PI_Factor(IntvnList)*HH_TBScr_Target;    
end
HH_Age_15p.TB_PropScreened_Target = HH_TBScr_Target;%hh_dat{36};
c1=HH_Age_15p.TB_PropScreened_Base;
c2=HH_Age_15p.TB_PropScreened_Target;
%if(PF_GP==0)
    c3=linspace(c1,c2,ScaleYear-BaseYear+1);
    c4=c2*ones(1,CostYears2);
    c5=c2*ones(1,5);
    HH_Age_15p.TB_PropScreened= DoHH_ACF*[c0*c1(1),c1,c3,c4,c5];
%    HH_Age_15p.TB_PropScreened= DoHH_ACF*[ones(1,14)]
%else
%    c3=c1*ones(1,ScaleYear-BaseYear);
%    c4=linspace(c1,c2,CostYears2+1);
%    c5=c2*ones(1,5);
%    HH_Age_15p.TB_PropScreened= [c0*c1(1),c1,c3,c4,c5];
%end

HH_Age_15p.TB_Screen_Sens_PTB=hh_dat{37};
HH_Age_15p.TB_Screen_Spec_PTB=hh_dat{38};
HH_Age_15p.TB_Diag_Sens_PTB=hh_dat{39};
HH_Age_15p.TB_Diag_Spec_PTB=hh_dat{40};
HH_Age_15p.TB_PropDiagLinkedTx = hh_dat{41};
HH_Age_15p.TB_PropTPTPresumptiveTx=hh_dat{42};
HH_Age_15p.TB_PropEligibleTPTtested=hh_dat{43};
HH_Age_15p.TB_PropEligibleLinkedTPT=hh_dat{44};
HH_Inputs.HH_Age{3}=HH_Age_15p;

HH_Inputs.TB_HHPropU5TB=hh_dat{46};	
HH_Inputs.TB_HHPropU5LTBI=hh_dat{47};	
HH_Inputs.TB_HHPropO5TB=hh_dat{48};	
HH_Inputs.TB_HHPropO5LTBI=hh_dat{49};
HH_Inputs.PropPTB=NOTI.PropPTB;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%ART inputs
ART_Inputs=[];
art_ind=find(strcmp(ART_Inputs_dat(:,2),ISO3)); 
art_dat=ART_Inputs_dat(art_ind,:);

for sv  = [1:TB_ARTSevereLen]
for age = [1:TB_ARTAgeLen]
        
    %ART_Inputs.Sev_ART_age{sv,age}.TB_ARTProportionScreened_Base = art_dat{5};
    ART_Inputs.Sev_ART_age{sv,age}.TB_ARTProportionScreened_Base = ART_TBScr_Base;
      if( ~isempty(intersect([IntvnList],[Intvn_GP_25:Intvn_GP_75])) ),
       dt=max(ART_TBScr_Target-ART_TBScr_Base,0); 
       ART_TBScr_Target=ART_TBScr_Base+GP_Factor(IntvnList)*dt;
    end    
    if( isempty(intersect([IntvnList],[Intvn_ACF,Intvn_All,Intvn_GP_25:Intvn_GP_75])) ),    
       ART_TBScr_Target=ART_Inputs.Sev_ART_age{sv,age}.TB_ARTProportionScreened_Base;
    end
    ART_Inputs.Sev_ART_age{sv,age}.TB_ARTProportionScreened_Target = ART_TBScr_Target;%art_dat{6};
    c1=ART_Inputs.Sev_ART_age{sv,age}.TB_ARTProportionScreened_Base;
    c2=ART_Inputs.Sev_ART_age{sv,age}.TB_ARTProportionScreened_Target;
   % if(PF_GP==0)
        c3=linspace(c1,c2,ScaleYear-BaseYear+1);
        c4=c2*ones(1,CostYears2);
        c5=c2*ones(1,5);
        ART_Inputs.Sev_ART_age{sv,age}.TB_ARTProportionScreened = DoART_ACF*[c0*c1(1),c1,c3,c4,c5];
        ART_Inputs.Sev_ART_age{sv,age}.TB_ARTProportionScreened = DoART_ACF*[ones(1,14)];
   % else
   %     c3=c1*ones(1,ScaleYear-BaseYear);
   %     c4=linspace(c1,c2,CostYears2+1);
   %     c5=c2*ones(1,5);
   %     ART_Inputs.Sev_ART_age{sv,age}.TB_ARTProportionScreened = DoART_ACF*[c0*c1(1),c1,c3,c4,c5];
   % end
    
    ART_Inputs.Sev_ART_age{sv,age}.TB_ARTScreenSensitivity=art_dat{7};
    ART_Inputs.Sev_ART_age{sv,age}.TB_ARTScreenSpecificity=art_dat{8};
    ART_Inputs.Sev_ART_age{sv,age}.TB_ARTDiagSensitivity=art_dat{9};
    ART_Inputs.Sev_ART_age{sv,age}.TB_ARTDiagSpecificity=art_dat{10};
    ART_Inputs.Sev_ART_age{sv,age}.TB_ARTPropLinkedTreat=art_dat{11};
    ART_Inputs.Sev_ART_age{sv,age}.TB_ARTPropPrvntPresump=art_dat{12};
    ART_Inputs.Sev_ART_age{sv,age}.TB_ARTPropPrvntTested=art_dat{13};
    ART_Inputs.Sev_ART_age{sv,age}.TB_ARTPropEligiblePrvntLink=art_dat{14};
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TPT coverage
ART_Inputs.TB_TPTCov_Base=ART_TPTCov_Base;
if( ~isempty(intersect([IntvnList],[Intvn_GP_25:Intvn_GP_75])) ),
    dt=max(ART_TPTCov_Target-ART_TPTCov_Base,0); 
    ART_TPTCov_Target=ART_TPTCov_Base+GP_Factor(IntvnList)*dt;
end    
if( isempty(intersect([IntvnList],[Intvn_TPT,Intvn_GP_25:Intvn_All])) ),       
    ART_TPTCov_Target=ART_Inputs.TB_TPTCov_Base;
end
if( ~isempty(intersect([IntvnList],[Intvn_PI_0:Intvn_PI_75])) ),     
    ART_TPTCov_Target=ART_Inputs.TB_TPTCov_Base;%PI_Factor(IntvnList)*ART_TPTCov_Target;    
end

ART_Inputs.TB_TPTCov_Target=ART_TPTCov_Target;
c1=ART_Inputs.TB_TPTCov_Base;
c2=ART_Inputs.TB_TPTCov_Target;
%if(PF_GP==0)
    c3=linspace(c1,c2,ScaleYear-BaseYear+1);
    c4=c2*ones(1,CostYears2);
    c5=c2*ones(1,5);
    ART_Inputs.ART_TPTCov = DoHH_ACF*[c0*c1(1),c1,c3,c4,c5];
%    ART_Inputs.ART_TPTCov = DoHH_ACF*[ones(1,14)];
%else
%    c3=c1*ones(1,ScaleYear-BaseYear);
%    c4=linspace(c1,c2,CostYears2+1);
%    c5=c2*ones(1,5);
%    ART_Inputs.ART_TPTCov = DoHH_ACF*[c0*c1(1),c1,c3,c4,c5];
%end

%LTBI
ART_Inputs.ART_age{TB_ARTNotServere,TB_ART0_9}.TB_ART_WithTBInfection=art_dat{17};
ART_Inputs.ART_age{TB_ARTNotServere,TB_ART10_14}.TB_ART_WithTBInfection=art_dat{17};
ART_Inputs.ART_age{TB_ARTNotServere,TB_ART15p}.TB_ART_WithTBInfection=art_dat{19};

ART_Inputs.ART_age{TB_ARTSevereIllness,TB_ART0_9}.TB_ART_WithTBInfection=art_dat{17};
ART_Inputs.ART_age{TB_ARTSevereIllness,TB_ART10_14}.TB_ART_WithTBInfection=art_dat{17};
ART_Inputs.ART_age{TB_ARTSevereIllness,TB_ART15p}.TB_ART_WithTBInfection=art_dat{19};

%TB
ART_Inputs.ART_age{TB_ARTNotServere,TB_ART0_9}.TB_ART_WithTBDisease=art_dat{16};
ART_Inputs.ART_age{TB_ARTNotServere,TB_ART10_14}.TB_ART_WithTBDisease=art_dat{16};
ART_Inputs.ART_age{TB_ARTNotServere,TB_ART15p}.TB_ART_WithTBDisease=art_dat{18};

ART_Inputs.ART_age{TB_ARTSevereIllness,TB_ART0_9}.TB_ART_WithTBDisease=art_dat{16};
ART_Inputs.ART_age{TB_ARTSevereIllness,TB_ART10_14}.TB_ART_WithTBDisease=art_dat{16};
ART_Inputs.ART_age{TB_ARTSevereIllness,TB_ART15p}.TB_ART_WithTBDisease=art_dat{18};

%PTB
ART_Inputs.ART_age{TB_ARTNotServere,TB_ART0_9}.TB_ART_PropPTB=NOTI.PropPTB;
ART_Inputs.ART_age{TB_ARTNotServere,TB_ART10_14}.TB_ART_PropPTB=NOTI.PropPTB;
ART_Inputs.ART_age{TB_ARTNotServere,TB_ART15p}.TB_ART_PropPTB=NOTI.PropPTB;

ART_Inputs.ART_age{TB_ARTSevereIllness,TB_ART0_9}.TB_ART_PropPTB=NOTI.PropPTB;
ART_Inputs.ART_age{TB_ARTSevereIllness,TB_ART10_14}.TB_ART_PropPTB=NOTI.PropPTB;
ART_Inputs.ART_age{TB_ARTSevereIllness,TB_ART15p}.TB_ART_PropPTB=NOTI.PropPTB;


%%HRG inputs
HRG_Inputs=[];
hrg_ind=find(strcmp(HRG_Inputs_dat(:,2),ISO3)); 
hrg_dat=HRG_Inputs_dat(hrg_ind,:);

for hrg = [1:TB_HRG_Len]
    
    %HRG_Inputs.Group{hrg}.TB_HRGProportionScreened_Base = hrg_dat{5};
    HRG_Inputs.Group{hrg}.TB_HRGProportionScreened_Base = HRG_TBScr_Base;
    if( ~isempty(intersect([IntvnList],[Intvn_GP_25:Intvn_GP_75])) ),
         dt=max(HRG_TBScr_Target-HRG_TBScr_Base,0);
         HRG_TBScr_Target=HRG_TBScr_Base+GP_Factor(IntvnList)*dt;       
    end    
    if( isempty(intersect([IntvnList],[Intvn_ACF,Intvn_All,Intvn_GP_25:Intvn_GP_75])) ),     
         HRG_TBScr_Target=HRG_Inputs.Group{hrg}.TB_HRGProportionScreened_Base;       
    end
    if( ~isempty(intersect([IntvnList],[Intvn_PI_0:Intvn_PI_75])) ),     
      HRG_TBScr_Target=HRG_Inputs.Group{hrg}.TB_HRGProportionScreened_Base;%PI_Factor(IntvnList)*HRG_TBScr_Target;    
    end 
    HRG_Inputs.Group{hrg}.TB_HRGProportionScreened_Target = HRG_TBScr_Target;%hrg_dat{6};
    c1=HRG_Inputs.Group{hrg}.TB_HRGProportionScreened_Base;
    c2=HRG_Inputs.Group{hrg}.TB_HRGProportionScreened_Target; 
    if(PF_GP==0)
        c3=linspace(c1,c2,ScaleYear-BaseYear+1);
        c4=c2*ones(1,CostYears2);
        c5=c2*ones(1,5);
        HRG_Inputs.Group{hrg}.TB_HRGProportionScreened = DoHRG_ACF*[c0*c1(1),c1,c3,c4,c5];
    else
        %c3=c1*ones(1,ScaleYear-BaseYear);
        c3=linspace(c1,0.5*c2,ScaleYear-BaseYear);
        c4=linspace(0.5*c2,c2,CostYears2+1);
        c5=c2*ones(1,5);
        HRG_Inputs.Group{hrg}.TB_HRGProportionScreened = DoHRG_ACF*[c0*c1(1),c1,c3,c4,c5];
    end

    HRG_Inputs.Group{hrg}.TB_HRGScreenSensitivity=hrg_dat{7};
    HRG_Inputs.Group{hrg}.TB_HRGScreenSpecificity=hrg_dat{8};
    HRG_Inputs.Group{hrg}.TB_HRGDiagSensitivity=hrg_dat{9};
    HRG_Inputs.Group{hrg}.TB_HRGDiagSpecificity=hrg_dat{10};
    HRG_Inputs.Group{hrg}.TB_HRGPropLinkedTreat=hrg_dat{11};
    HRG_Inputs.Group{hrg}.TB_HRGPropPrvntPresump=hrg_dat{12};
    HRG_Inputs.Group{hrg}.TB_HRGPropPrvntTested=hrg_dat{13};
    HRG_Inputs.Group{hrg}.TB_HRGPropEligiblePrvntLink=hrg_dat{14};
end

HRG_Inputs.Group{TB_HRG_HighTBPrev}.TB_HRG_Dem_Prop15p=hrg_dat{17};
HRG_Inputs.Group{TB_HRG_HighTBPrev}.TB_HRG_WithTBDisease=hrg_dat{18};
HRG_Inputs.Group{TB_HRG_HighTBPrev}.TB_HRG_WithTBInfection=hrg_dat{19};
HRG_Inputs.Group{TB_HRG_HighTBPrev}.TB_HRG_PropPTB=NOTI.PropPTB;

%TPT coverage
HRG_Inputs.TB_TPTCov_Base=HRG_TPTCov_Base;

if( ~isempty(intersect([IntvnList],[Intvn_GP_25:Intvn_GP_75])) ),
    dt=max(HRG_TPTCov_Target-HRG_TPTCov_Base,0);
    HRG_TPTCov_Target=HRG_TPTCov_Base+GP_Factor(IntvnList)*dt;
end    
if( isempty(intersect([IntvnList],[Intvn_TPT,Intvn_All,Intvn_GP_25:Intvn_GP_75])) ),    
    HRG_TPTCov_Target=HRG_Inputs.TB_TPTCov_Base;
end
if( ~isempty(intersect([IntvnList],[Intvn_PI_0:Intvn_PI_75])) ),     
HRG_TPTCov_Target=HRG_Inputs.TB_TPTCov_Base;%PI_Factor(IntvnList)*HRG_TPTCov_Target;    
end 

HRG_Inputs.TB_TPTCov_Target=HRG_TPTCov_Target;
c1=HRG_Inputs.TB_TPTCov_Base;
c2=HRG_Inputs.TB_TPTCov_Target;
if(PF_GP==0)
    c3=linspace(c1,c2,ScaleYear-BaseYear+1);
    c4=c2*ones(1,CostYears2);
    c5=c2*ones(1,5);
    HRG_Inputs.HRG_TPTCov = DoHH_ACF*[c0*c1(1),c1,c3,c4,c5];
else
    %c3=c1*ones(1,ScaleYear-BaseYear);
    %c4=linspace(c1,c2,CostYears2+1);
    c3=linspace(c1,0.5*c2,ScaleYear-BaseYear);
    c4=linspace(0.5*c2,c2,CostYears2+1);
    c5=c2*ones(1,5);
    HRG_Inputs.HRG_TPTCov = DoHH_ACF*[c0*c1(1),c1,c3,c4,c5];
end

%Patient initiated inputs  
Patient_Inputs = [];
for pt = TB_PatientInitiated_List
    Patient_Inputs{pt}.TB_Prevalence = 10/100;%
    Patient_Inputs{pt}.TB_PatientScreenSensitivity=85/100;
    Patient_Inputs{pt}.TB_PatientScreenSpecificity=97/100;
    Patient_Inputs{pt}.TB_PatientDiagSpecificityTag=85/100;
    Patient_Inputs{pt}.TB_PatientDiagSensitivity=97/100;
    Patient_Inputs{pt}.PropDiagLinkedTx=100/100;
end;

%After the pre-amble and data reading, calcs start here:
%Decline in Patient Initated prevalence due to eligibiliy relaxing
c1=1;
c2=0.2; 

%c3=linspace(c1,c2,CostYearsN-1);
%PI_Prev_Trend=[c1,c3];

if(PF_GP==1)
    c1=1;
    c2=0.8;%0.2;
    c2a=0.7;
    if( ~isempty(intersect([IntvnList],[Intvn_ACF,Intvn_All])) )
        c2a=0.35;
    end
   

    c3=linspace(c1,c2,ScaleYear-BaseYear);
    c4=linspace(c2,c2a,CostYears2+1);
    c5=c2a*ones(1,5);
    PI_Prev_Trend=[c0*c1(1),c1,c3,c4,c5];
    x=1;
    %PI_Prev_Trend=ones(size(PI_Prev_Trend));
else
    c1=1;
    c2=0.25;
    %c1=0.8;
    %c2=0.8;
    c3=linspace(c1,c2,ScaleYear-BaseYear+1);
    c4=c2*ones(1,CostYears2);
    c5=c2*ones(1,5);
    PI_Prev_Trend=[c0*c1(1),c1,c3,c4,c5];
end

if( ~isempty(intersect([IntvnList],[Intvn_Baseline])) ), 
    %PI_Prev_Trend=ones(size(PI_Prev_Trend));
    PI_Prev_Trend(6:end)=ones(size(PI_Prev_Trend(6:end)));
end

if( ~isempty(intersect([IntvnList],[Intvn_PI_0:Intvn_PI_75])) ), 
    %PI_Prev_Trend=ones(size(PI_Prev_Trend));
    c3=linspace(PI_Prev_Trend(6),1,8);
    PI_Prev_Trend=[PI_Prev_Trend(1:6),c3];%ones(size(PI_Prev_Trend(6:end)));
end


%Calc provider initiated notifications first
IntvnList
[HH_Contacts]=CalcHouseHoldTargetPopulations(HH_Inputs,NOTI,noti_target)
[ART_Cohorts]=CalculateARTCohortTargetPopulations(ART_Inputs)
[HR_Groups]=CalculateHRGTargetPopulations(HRG_Inputs)
%Total notificaiton from provider-initiated to be deducted from total notification to find patient-initiated 
[PatientInitiated]=CalcPatientInitiatedTargetPopulations(Patient_Inputs,HH_Contacts, HR_Groups, NOTI, noti_target)


[CostingTPs, RR_Profiles, DST_Coverage, Resis_Profiles]=CalcTargetPopulationTable(HH_Contacts, ART_Cohorts, HR_Groups, PatientInitiated, NOTI, DST_Cov)

CostingData=[];
CostingData{1}=ISO3;
CostingData{2}=NOTI;
CostingData{3}=HH_Contacts;
CostingData{4}=ART_Cohorts;
CostingData{5}=HR_Groups;
CostingData{6}=PatientInitiated;
CostingData{7}=CostingTPs;
CostingData{8}=DST_Cov;


% delete CostingData.mat
% save CostingData.mat CostingData

%Cals 'Hazard' or 'Rate' of being 'detected' or 'protected'
[Hd,Hi,Hd_ByCat,Hi_ByCat,total_PrevTB,total_Dx,total_PrevTB_ByCat,total_Dx_ByCat, totalTPTDenom]=CalcHazardRates(HH_Contacts, ART_Cohorts, HR_Groups, PatientInitiated, NOTI, ImpactDenoms);

%%%%
%DST and default rate impact on treatment outcomes
TS_SLgetFL=0.6;%relative outcomes for DR TB receiving FL Tx
TS_SLFQgetSL=0.4;%relative outcomes for DR FQ TB receiving SL no FQ Tx

% DST_Coverage.INH_RR_Sens_DST_PTB=ones( size(DST_Coverage.INH_RR_Sens_DST_PTB) );
% DST_Coverage.RR_DST_PTB=ones( size(DST_Coverage.RR_DST_PTB) );
% DST_Coverage.FQ_RR_Res_DST_PTB=ones( size(DST_Coverage.FQ_RR_Res_DST_PTB) );

PropDS=(rp_15p.Rif_Sen*rp_15p.INH_Sen)*ones(size(DST_Coverage.RR_DST_PTB));
PropDS_DST=(DST_Coverage.RR_DST_PTB.*DST_Coverage.INH_RR_Sens_DST_PTB).*(rp_15p.Rif_Sen*rp_15p.INH_Sen*(1-DefaultRateDS));
%no RR DST
PropDS_NoDST=(1-DST_Coverage.RR_DST_PTB).*( (rp_15p.Rif_Res)*TS_SLgetFL*(1-DefaultRateDR) );
%RR DST but no INH DST
PropDS_NoDST=PropDS_NoDST+DST_Coverage.RR_DST_PTB.*(1-DST_Coverage.INH_RR_Sens_DST_PTB).*( (rp_15p.Rif_Sen*rp_15p.INH_Sen)*(1-DefaultRateDS) + (rp_15p.Rif_Sen*rp_15p.INH_Res)*TS_SLgetFL*(1-DefaultRateDR));
PropFL=PropDS_DST+PropDS_NoDST

DST_Impact_FL_TSR = PropFL./PropDS;

PropDR=rp_15p.Rif_Res*ones(size(DST_Coverage.RR_DST_PTB));
PropDR_DST=(DST_Coverage.RR_DST_PTB.*DST_Coverage.FQ_RR_Res_DST_PTB).*(rp_15p.Rif_Res*(1-DefaultRateDR));
PropDR_NoDST=DST_Coverage.RR_DST_PTB.*(1-DST_Coverage.FQ_RR_Res_DST_PTB).*( (rp_15p.Rif_Res*rp_15p.FQ_Res)*TS_SLFQgetSL*(1-DefaultRateDR) );
PropSL=PropDR_DST+PropDR_NoDST
% 
DST_Impact_SL_TSR=PropSL./PropDR;
%%%%%%%%%%%%%%%%%%%%%%%%%  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ImpactData=[];
ImpactData{1}=Hd;
ImpactData{2}=Hi;
ImpactData{3}=Hd_ByCat;
ImpactData{4}=Hi_ByCat;
ImpactData{5}=total_PrevTB;
ImpactData{6}=total_Dx;
ImpactData{7}=total_PrevTB_ByCat;
ImpactData{8}=total_Dx_ByCat;
ImpactData{9}=DST_Impact_FL_TSR;
ImpactData{10}=DST_Impact_SL_TSR;
ImpactData{11}=totalTPTDenom;

% DSTData{1}=rp_U15;
% DSTData{2}=rp_15p;
% DSTData{3}=DST_Coverage;


% delete ImpactData.mat
% save ImpactData.mat ImpactData

function  [ACF_Pop]=Set_ACF_Pop(ACF_POP_Inputs, GroupID);

    ACF_Pop = [];
    % Map inputs to ACF object
    Pop_Size=ACF_POP_Inputs.Pop;

    PropLTBI=ACF_POP_Inputs.PropLTBI;
    PrevTB=ACF_POP_Inputs.PropTB;
    PropPTB=ACF_POP_Inputs.PropPTB;

    PropScreened=ACF_POP_Inputs.PropScreened;

    Screen_Sens_PTB=ALG.ScrSens(GroupID,:);
    Screen_Spec_PTB=ALG.ScrSpec(GroupID,:);
    
    Diag_Sens_PTB=ALG.DxSens(GroupID,:);
    Diag_Spec_PTB=ALG.DxSpec(GroupID,:); 
    
    %Screen_Sens_PTB=ACF_POP_Inputs.Screen_Sens_PTB;
    %Screen_Spec_PTB=ACF_POP_Inputs.Screen_Spec_PTB;

    %Diag_Sens_PTB=ACF_POP_Inputs.Diag_Sens_PTB;
    %Diag_Spec_PTB=ACF_POP_Inputs.Diag_Spec_PTB;

    PropDiagLinkedTx=ACF_POP_Inputs.PropDiagLinkedTx;

    PropTPTPresumptiveTx=ACF_POP_Inputs.PropTPTPresumptiveTx;
    PropEligibleTPTtested=ACF_POP_Inputs.PropEligibleTPTtested;
    PropEligibleLinkedTPT=ACF_POP_Inputs.PropEligibleLinkedTPT;
    
    TPT_Cov=ACF_POP_Inputs.TPT_Cov;

    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    ACF_Pop.GroupID=GroupID;
    % Populations size, LTBI and TB prevalence
    % Number aged 0 to 4 years in households of index cases
    ACF_Pop.pop=Pop_Size;
    % Number without TB infection or disease
    ACF_Pop.noTB=ACF_Pop.pop*(1-PropLTBI-PrevTB);
    % Number with TB infection
    ACF_Pop.LTBI=ACF_Pop.pop*(PropLTBI);
    % Number with TB disease
    ACF_Pop.TB=ACF_Pop.pop*(PrevTB);
    % Number with pulmonary TB
    ACF_Pop.PTB=ACF_Pop.TB*PropPTB;
    % adjust ACF TBPrev for pulmonary TB, as algorithms pertain to PTB and not
    % also to ETB
    PrevTB=PrevTB*PropPTB;
    
    ACF_Pop.pop
    PropScreened
    
    % Number screened
    ACF_Pop.NumScreened=ACF_Pop.pop .* PropScreened;
    % Number referred for diagnostic evaluation of TB disease 
    ACF_Pop.NumReferredDiag=ACF_Pop.NumScreened .* (Screen_Sens_PTB*PrevTB+(1-Screen_Spec_PTB)*(1-PrevTB));
    % Number screened to refer one true PTB case for diagnostic evaluation
    ACF_Pop.NNTS=ACF_Pop.NumScreened./(ACF_Pop.NumScreened .* Screen_Sens_PTB*PrevTB);

    ACF_Pop.PropTrueCases=(ACF_Pop.NumScreened .* Screen_Sens_PTB*PrevTB)./ACF_Pop.NumScreened;
    
    ACF_Pop.TP_screen  = ACF_Pop.NumScreened .* Screen_Sens_PTB*PrevTB;
    ACF_Pop.FP_screen = ACF_Pop.NumScreened .* (1-Screen_Spec_PTB)*(1-PrevTB);
    ACF_Pop.FN_screen = ACF_Pop.NumScreened .* (1-Screen_Sens_PTB)*PrevTB;

    ACF_Pop.TPFPRatio_screen =  ACF_Pop.TP_screen./(ACF_Pop.FP_screen);
   
    ACF_Pop.TPFP_screen = ACF_Pop.TP_screen+ACF_Pop.FP_screen;
    ACF_Pop.TrueCasesPct_screen = ACF_Pop.TP_screen./ACF_Pop.TPFP_screen;
    
    % Diagnosis
    PrevTB_diag=ACF_Pop.TrueCasesPct_screen;
    ACF_Pop.TP_diag  = ACF_Pop.NumReferredDiag .* Diag_Sens_PTB.*PrevTB_diag;
    ACF_Pop.FP_diag = ACF_Pop.NumReferredDiag .*(1-Diag_Spec_PTB).*(1-PrevTB_diag);
    ACF_Pop.FN_diag  = ACF_Pop.NumReferredDiag .*(1-Diag_Sens_PTB).*PrevTB_diag;

    ACF_Pop.TPFPRatio_diag =  ACF_Pop.TP_diag./ACF_Pop.FP_diag ;
   
    ACF_Pop.TPFP_diag = ACF_Pop.TP_diag+ACF_Pop.FP_diag;
    ACF_Pop.TrueCasesPct_diag = ACF_Pop.TP_diag./ACF_Pop.TPFP_diag;
   
    % Number diagnosed with PTB
    ACF_Pop.NumDiagnosed=ACF_Pop.NumReferredDiag.*(PrevTB_diag .*Diag_Sens_PTB + (1-PrevTB_diag).*(1-Diag_Spec_PTB));
    % Number evaluated to confirm one PTB case
    ACF_Pop.NNTT=ACF_Pop.NumScreened./ACF_Pop.NumDiagnosed;
   
    % TB disease and treatment
    % Number initiated on appropriate treatment for TB disease
    ACF_Pop.NumberDiagLinkedTx=PropDiagLinkedTx*ACF_Pop.NumDiagnosed;

    % Latent TB and TB preventive treatment
    % Number of household contacts without active TB and eligible for TB preventive treatment evaluation
    ACF_Pop.NumberEligibleTPTEval=TPT_Cov.*(ACF_Pop.NumScreened-ACF_Pop.NumDiagnosed);


    % Number eligible for screening and diagnosis of TB disease
    ACF_Pop.EligleScreening=ACF_Pop.pop;
    % Number screened for TB disease
    ACF_Pop.Screened=ACF_Pop.NumScreened;
    % Number referred for diagnostic evaluation of TB disease
    ACF_Pop.ReferredDxTB=ACF_Pop.NumReferredDiag;
    % Number diagnosed with PTB
    ACF_Pop.DiagnosedTB=ACF_Pop.NumDiagnosed;
    % Number initiated on treatment for TB disease
    ACF_Pop.TreatmentTBInit=ACF_Pop.NumberDiagLinkedTx;
    
    % Number eligible for evaluation of TB infection
    ACF_Pop.EligibleTPTEval=ACF_Pop.NumberEligibleTPTEval;
    % Number tested for TB infection
    ACF_Pop.EligibleLTBItested=ACF_Pop.NumberEligibleTPTEval*(1-PropTPTPresumptiveTx)*PropEligibleTPTtested;
    ACF_Pop.Presumptive=ACF_Pop.NumberEligibleTPTEval*PropTPTPresumptiveTx;
    % Number with presumed or confirmed TB infection
    ACF_Pop.WithLTBI=(ACF_Pop.NumberEligibleTPTEval*PropTPTPresumptiveTx+...
                     ACF_Pop.NumberEligibleTPTEval*(1-PropTPTPresumptiveTx)*PropEligibleTPTtested*PropLTBI);
    % Number initiated on TB preventive treatment
    ACF_Pop.InitiatedTPT=ACF_Pop.WithLTBI*PropEligibleLinkedTPT;
    
    %RemoveNanfromFields(ACF_Pop);
    
end

 function [PatientInitiated_Pop]=Set_PatientInit_Pop(PatientInitiated_Inputs,GroupID)
    PatientInitiated_Pop = [];

    % Map inputs to PatientInitiated object
    PrevTB=PatientInitiated_Inputs.PrevTB*PI_Prev_Trend;
    %PrevTB2=PatientInitiated_Inputs.PrevTB*0.8*ones(size(PI_Prev_Trend));
    Diagnosed=PatientInitiated_Inputs.Diagnosed;
    
    Screen_Sens_TB=ALG.ScrSens(GroupID,:);
    Screen_Spec_TB=ALG.ScrSpec(GroupID,:);
    
    Diag_Sens_TB=ALG.DxSens(GroupID,:);
    Diag_Spec_TB=ALG.DxSpec(GroupID,:); 
    
%     Screen_Sens_TB=PatientInitiated_Inputs.Screen_Sens_TB;
%     Screen_Spec_TB=PatientInitiated_Inputs.Screen_Spec_TB;
% 
%     Diag_Sens_TB=PatientInitiated_Inputs.Diag_Sens_TB;
%     Diag_Spec_TB=PatientInitiated_Inputs.Diag_Spec_TB;

    PropDiagLinkedTx=PatientInitiated_Inputs.PropDiagLinkedTx;

    PatientInitiated_Pop.GroupID=GroupID;
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    % Number screened
    NNTS_calc=1./(Screen_Sens_TB.*Diag_Sens_TB.*PrevTB +(1-Screen_Spec_TB).*(1-Diag_Spec_TB).*(1-PrevTB));
    %NNTS_calc2=1./(Screen_Sens_TB.*Diag_Sens_TB.*PrevTB2 +(1-Screen_Spec_TB).*(1-Diag_Spec_TB).*(1-PrevTB2));
    

    %NNTS_calc=1./(Screen_Sens_TB.*Diag_Sens_TB.*PrevTB +(1-Screen_Spec_TB).*(1-Diag_Spec_TB).*(1-PrevTB));
    
    % ind40=find(NNTS_calc>40);
    % if(~isempty(ind40))
    %     x=0;
    % end
    NNTS_calc=min(NNTS_calc,40);
    PatientInitiated_Pop.NumAssesed=Diagnosed.*NNTS_calc;

    %PatientInitiated_Pop.NumAssesed=Diagnosed ./(Screen_Sens_TB.*Diag_Sens_TB.*PrevTB +(1-Screen_Spec_TB).*(1-Diag_Spec_TB).*(1-PrevTB));
    PatientInitiated_Pop.NumScreened=PatientInitiated_Pop.NumAssesed;
    % Number referred for diagnostic evaluation of TB disease 
    PatientInitiated_Pop.NumReferredDiag=PatientInitiated_Pop.NumAssesed.*(Screen_Sens_TB.*PrevTB +(1-Screen_Spec_TB).*(1-PrevTB));
    % Number screened to refer one true case for diagnostic evaluation
    PatientInitiated_Pop.NNTS=PatientInitiated_Pop.NumAssesed./(PatientInitiated_Pop.NumAssesed.*Screen_Sens_TB.*PrevTB);
    ind=find(isnan(PatientInitiated_Pop.NNTS));PatientInitiated_Pop.NNTS(ind)=0;
    PatientInitiated_Pop.PropTrueCases=PatientInitiated_Pop.NumAssesed.*Screen_Sens_TB.*PrevTB./PatientInitiated_Pop.NumReferredDiag;
    ind=find(isnan(PatientInitiated_Pop.PropTrueCases));PatientInitiated_Pop.PropTrueCases(ind)=0;
    
    %Number with pulmonary TB among screened
    PatientInitiated_Pop.TB=PatientInitiated_Pop.NumAssesed.*PrevTB;
    
    % Diagnosis
    % Number diagnosed with PTB
    PatientInitiated_Pop.NumDiagnosed=Diagnosed;
    % Number evaluated to confirm one PTB case
    PatientInitiated_Pop.NNTT=PatientInitiated_Pop.NumAssesed./PatientInitiated_Pop.NumDiagnosed;
    ind=find(isnan(PatientInitiated_Pop.NNTT));PatientInitiated_Pop.NNTT(ind)=0;
    
    % TB disease and treatment
    % Number initiated on appropriate treatment for TB disease
    PatientInitiated_Pop.NumberDiagLinkedTx=PropDiagLinkedTx*PatientInitiated_Pop.NumDiagnosed;
    
    % TP, FP, FN for screening
    PatientInitiated_Pop.TP_screen = PatientInitiated_Pop.NumAssesed.*Screen_Sens_TB.*PrevTB  ;
    PatientInitiated_Pop.FP_screen = PatientInitiated_Pop.NumAssesed.*(1-Screen_Spec_TB).*(1-PrevTB);
    PatientInitiated_Pop.FN_screen = PatientInitiated_Pop.NumAssesed.*(1-Screen_Sens_TB).*PrevTB;

    PatientInitiated_Pop.TPFPRatio_screen =  PatientInitiated_Pop.TP_screen./PatientInitiated_Pop.FP_screen;
    ind=find(isnan(PatientInitiated_Pop.TPFPRatio_screen));PatientInitiated_Pop.TPFPRatio_screen(ind)=0;
    
    PatientInitiated_Pop.TPFP_screen = PatientInitiated_Pop.TP_screen+PatientInitiated_Pop.FP_screen;
    PatientInitiated_Pop.TrueCasesPct_screen = PatientInitiated_Pop.TP_screen./PatientInitiated_Pop.TPFP_screen;
    ind=find(isnan(PatientInitiated_Pop.TrueCasesPct_screen));PatientInitiated_Pop.TrueCasesPct_screen(ind)=0; 
    
    % TP, FP, FN for diagnosis
    PrevTB_diag=PatientInitiated_Pop.TrueCasesPct_screen;
    PatientInitiated_Pop.TP_diag  = PatientInitiated_Pop.NumReferredDiag.*Diag_Sens_TB.*PrevTB_diag ;
    PatientInitiated_Pop.FP_diag = PatientInitiated_Pop.NumReferredDiag.*(1-Diag_Spec_TB).*(1-PrevTB_diag);
    PatientInitiated_Pop.FN_diag  = PatientInitiated_Pop.NumReferredDiag.*(1-Diag_Sens_TB).*PrevTB_diag ;

    PatientInitiated_Pop.TPFPRatio_diag =  PatientInitiated_Pop.TP_diag./PatientInitiated_Pop.FP_diag;
    ind=find(isnan(PatientInitiated_Pop.TPFPRatio_diag));PatientInitiated_Pop.TPFPRatio_diag(ind)=0; 
    
    PatientInitiated_Pop.TPFP_diag = PatientInitiated_Pop.TP_diag+PatientInitiated_Pop.FP_diag;
    PatientInitiated_Pop.TrueCasesPct_diag = PatientInitiated_Pop.TP_diag./PatientInitiated_Pop.TPFP_diag;
    ind=find(isnan(PatientInitiated_Pop.TrueCasesPct_diag));PatientInitiated_Pop.TrueCasesPct_diag(ind)=0;
    
    % Latent TB and TB preventive treatment
    % Number of household contacts without active TB and eligible for TB preventive treatment evaluation
    PatientInitiated_Pop.NumberEligibleTPTEval=[];


    % Number clinically assesed for TB disease
    PatientInitiated_Pop.ClinicallyAssesed=PatientInitiated_Pop.NumAssesed;
    % Number referred for diagnostic evaluation of TB disease
    PatientInitiated_Pop.ReferredDxTB=PatientInitiated_Pop.NumReferredDiag;
    % Number diagnosed with PTB
    PatientInitiated_Pop.DiagnosedTB=PatientInitiated_Pop.NumDiagnosed;
    % Number initiated on treatment for TB disease
    PatientInitiated_Pop.TreatmentTBInit=PatientInitiated_Pop.NumberDiagLinkedTx;
    % Number eligible for evaluation of TB infection
    PatientInitiated_Pop.EligibleTPTEval=[];
    % Number tested for TB infection
    PatientInitiated_Pop.EligibleLTBItested=[];
    % Number with presumed or confirmed TB infection
    PatientInitiated_Pop.WithLTBI=[];
    % Number initiated on TB preventive treatment
    PatientInitiated_Pop.InitiatedTPT=[];

 end

function [HH_Contacts]=CalcHouseHoldTargetPopulations(HH_Inputs,NOTI,TB_TargNotification)
    
   
   HH_Group(TB_HH0_4)  = TB_HH0_4_grp;
   HH_Group(TB_HH5_14) = TB_HH5_14_grp;
   HH_Group(TB_HH15p)  = TB_HH15p_grp;
   
    HH_Contacts = [];

    % Household demographic info    
    % Average household size (%)
    HH_Size=HH_Inputs.TB_HHSize;
    % Proportion of household that is 0-4 yrs (% )
    HH_PropU5=HH_Inputs.TB_HHPropU5;
    % Proportion of household that is 5-14 yrs (% )
    HH_Prop5to14=HH_Inputs.TB_HHProp5_14;
    % Average number of TB cases in household with at least one case (%)
    TBCasesinIndexHH=HH_Inputs.TB_HHCasesinIndexHH;

    % Number of index cases
    % Number of new bacteriologically positive TB cases (adult)
    bac_pos_pct = (NOTI.new_labconf + NOTI.ret_rel_labconf);

    % Number of new bacteriologically positive TB cases (adult)
    BACpAdult = TB_TargNotification*bac_pos_pct;
    
    % Number of new bacteriologically negative TB cases (adult)
    BACnAdult = TB_TargNotification*(1-bac_pos_pct);

    % Proportion of contacts of new bacteriologically negative cases screened/evaluated
    HH_Prop_BACnContactsScreened= HH_Inputs.TB_HHPropBACnScreened;
    
    % Proportion of households of index cases screened/evaluated does not vary by age group 
    HH_Prop_Screened=HH_Inputs.TB_HHPIndexCasesScreened;
    
    HH_TPT_Cov=HH_Inputs.HH_TPTCov;

    %Number of notified cases who are index cases to follow up
    IntvnList
    % HH_Prop_Screened
    % BACpAdult
    % HH_Prop_BACnContactsScreened
    % BACnAdult
    NotiAdult=HH_Prop_Screened.*(BACpAdult + HH_Prop_BACnContactsScreened*BACnAdult);

    
    HH_Pops = [HH_PropU5*(NotiAdult/TBCasesinIndexHH)*HH_Size,                     % HH 0-4                                      
               HH_Prop5to14*(NotiAdult/TBCasesinIndexHH)*HH_Size,                  % HH 5-14        
               (1-HH_PropU5-HH_Prop5to14)*(NotiAdult/TBCasesinIndexHH)*(HH_Size-1)]; % HH 15 Plus  
    
     % for each of the three age group, collect ACF parameters and call Set_ACF_Pop 
     for hh = [1:TB_HHAgeLen]
       
        % HH_Contacs, number of age groups for age group hh
        HH_Contact=[];
        % Proportion with TB infection/LTBI
        HH_Contact.PropLTBI = HH_Inputs.TB_HHPropO5LTBI;
        if(hh==1)
            HH_Contact.PropLTBI = HH_Inputs.TB_HHPropU5LTBI;
        end

        % Proportion with TB disease/TB
        HH_Contact.PropTB = HH_Inputs.TB_HHPropU5TB;
        if(hh==1)
            HH_Contact.PropTB = HH_Inputs.TB_HHPropU5TB;
        end

        % Proportion with pulmonary TB, PTB (% )
        HH_Contact.PropPTB = HH_Inputs.PropPTB;

        HH_Contact.Pop = HH_Pops(hh,:);
        
        HH_Contact.PropScreened = HH_Inputs.HH_Age{hh}.TB_PropScreened;
        HH_Contact.Screen_Sens_PTB=HH_Inputs.HH_Age{hh}.TB_Screen_Sens_PTB;% value read from a table
        HH_Contact.Screen_Spec_PTB=HH_Inputs.HH_Age{hh}.TB_Screen_Spec_PTB;% value read from a table
        HH_Contact.Diag_Sens_PTB=HH_Inputs.HH_Age{hh}.TB_Diag_Sens_PTB;% value read from a table
        HH_Contact.Diag_Spec_PTB=HH_Inputs.HH_Age{hh}.TB_Diag_Spec_PTB;% value read from a table
        HH_Contact.PropDiagLinkedTx = HH_Inputs.HH_Age{hh}.TB_PropDiagLinkedTx;
        HH_Contact.PropTPTPresumptiveTx=HH_Inputs.HH_Age{hh}.TB_PropTPTPresumptiveTx;
        HH_Contact.PropEligibleTPTtested=HH_Inputs.HH_Age{hh}.TB_PropEligibleTPTtested;
        HH_Contact.PropEligibleLinkedTPT=HH_Inputs.HH_Age{hh}.TB_PropEligibleLinkedTPT;
        HH_Contact.TPT_Cov=HH_TPT_Cov;
        

        HH_Contacts{hh,1} = RemoveNanfromFields(Set_ACF_Pop(HH_Contact,HH_Group(hh)));

        HH_POP=[];
        HH_POP.TB_ScreenedNum = HH_Contacts{hh}.NumScreened;
        HH_POP.TB_ScreenedNumReferred = HH_Contacts{hh}.NumReferredDiag;
        HH_POP.TB_ScreenedTP = HH_Contacts{hh}.TP_screen;
        HH_POP.TB_ScreenedFP = HH_Contacts{hh}.FP_screen;
        HH_POP.TB_ScreenedTrueCases = HH_Contacts{hh}.TrueCasesPct_screen;
        HH_POP.TB_ScreenedNNTS = HH_Contacts{hh}.NNTS ;
        HH_POP.TB_ScreenedTPFP = HH_Contacts{hh}.TPFPRatio_screen;
        HH_POP.TB_ScreenedTPMissed = HH_Contacts{hh}.FN_screen;

        HH_POP.TB_DiagnosisNum       = HH_Contacts{hh}.NumReferredDiag;
        HH_POP.TB_DiagnosisConfirmed = HH_Contacts{hh}.NumDiagnosed;
        HH_POP.TB_DiagnosisTP        = HH_Contacts{hh}.TP_diag;
        HH_POP.TB_DiagnosisFP        = HH_Contacts{hh}.FP_diag;
        HH_POP.TB_DiagnosisTrueCases = HH_Contacts{hh}.TrueCasesPct_diag;
        HH_POP.TB_DiagnosisNNTT      = HH_Contacts{hh}.NNTT;
        HH_POP.TB_DiagnosisTPFP      = HH_Contacts{hh}.TPFPRatio_diag;
        HH_POP.TB_DiagnosisTPMissed  = HH_Contacts{hh}.FN_diag;

        HH_POP.TB_NumEligibleScreen = HH_Contacts{hh}.EligleScreening;
        HH_POP.TB_NumScreened       = HH_Contacts{hh}.Screened; 
        HH_POP.TB_NumReferredDiag   = HH_Contacts{hh}.ReferredDxTB;
        HH_POP.TB_NumDiagPulmTB     = HH_Contacts{hh}.DiagnosedTB;
        HH_POP.TB_NumInitTreatment  = HH_Contacts{hh}.TreatmentTBInit;
        HH_POP.TB_NumEligibleEval   = HH_Contacts{hh}.EligibleTPTEval;
        HH_POP.TB_NumTestedInfect   = HH_Contacts{hh}.EligibleLTBItested;
        HH_POP.TB_NumConfirmInfect  = HH_Contacts{hh}.WithLTBI;
        HH_POP.TB_NumInitTPT        = HH_Contacts{hh}.InitiatedTPT;    
       
        HH_Contacts{hh,2}=HH_POP; 
       end
         
end


function [ART_Cohorts]=CalculateARTCohortTargetPopulations(ART_Inputs)
    
ART_group(TB_ARTNotServere,TB_ART0_9)=TB_ARTNotServere_0_9_grp;
ART_group(TB_ARTNotServere,TB_ART10_14)=TB_ARTNotServere_10_14_grp;
ART_group(TB_ARTNotServere,TB_ART15p)=TB_ARTNotServere15p_grp;

ART_group(TB_ARTSevereIllness,TB_ART0_9)=TB_ARTSevereIllness_0_9_grp;
ART_group(TB_ARTSevereIllness,TB_ART10_14)=TB_ARTSevereIllness_10_14_grp;
ART_group(TB_ARTSevereIllness,TB_ART15p)=TB_ARTSevereIllness15p_grp;

ART_Cohorts=[];
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
for sv  = [1:TB_ARTSevereLen]
for age = [1:TB_ARTAgeLen]
    
  
    % ART, TB infection and disease characteristics
    % Proportion of ART patients 0 to 9 years with TB infection (% )
    ART_PropLTBI=ART_Inputs.ART_age{age}.TB_ART_WithTBInfection;
    % Proportion of ART patients 0 to 9 years with TB disease (% )
    ART_PropTB=ART_Inputs.ART_age{age}.TB_ART_WithTBDisease;
    % Proportion with pulmonary TB, PTB (% )
    ART_PropPTB=ART_Inputs.ART_age{age}.TB_ART_PropPTB;
   
    ACF_POP_Inputs=[];
    ACF_POP_Inputs.Pop=GetARTFromAIM(sv,age); % from AIM
     
    % Proportion with TB infection/LTBI
    ACF_POP_Inputs.PropLTBI=ART_PropLTBI;
    % Proportion with TB disease/TB
    ACF_POP_Inputs.PropTB=ART_PropTB;
    % Proportion with pulmonary TB, PTB (% )
    ACF_POP_Inputs.PropPTB=ART_PropPTB;
    % ACF pop size
    ACF_POP_Inputs.PropScreened = ART_Inputs.Sev_ART_age{sv,age}.TB_ARTProportionScreened;
    ACF_POP_Inputs.Screen_Sens_PTB=ART_Inputs.Sev_ART_age{sv,age}.TB_ARTScreenSensitivity;
    ACF_POP_Inputs.Screen_Spec_PTB=ART_Inputs.Sev_ART_age{sv,age}.TB_ARTScreenSpecificity;
    ACF_POP_Inputs.Diag_Sens_PTB=ART_Inputs.Sev_ART_age{sv,age}.TB_ARTDiagSensitivity;
    ACF_POP_Inputs.Diag_Spec_PTB=ART_Inputs.Sev_ART_age{sv,age}.TB_ARTDiagSpecificity;
    ACF_POP_Inputs.PropDiagLinkedTx = ART_Inputs.Sev_ART_age{sv,age}.TB_ARTPropLinkedTreat;
    ACF_POP_Inputs.PropTPTPresumptiveTx=ART_Inputs.Sev_ART_age{sv,age}.TB_ARTPropPrvntPresump;
    ACF_POP_Inputs.PropEligibleTPTtested=ART_Inputs.Sev_ART_age{sv,age}.TB_ARTPropPrvntTested;
    ACF_POP_Inputs.PropEligibleLinkedTPT=ART_Inputs.Sev_ART_age{sv,age}.TB_ARTPropEligiblePrvntLink;
    ACF_POP_Inputs.TPT_Cov=ART_Inputs.ART_TPTCov;
 
    ART_Cohorts{sv,age} = RemoveNanfromFields(Set_ACF_Pop(ACF_POP_Inputs,ART_group(sv,age)));
    

end
   
end

end


function [HRGs]=CalculateHRGTargetPopulations(HRG_Inputs)
HRGs = [];
pop_15Plus = DP_pop_15Plus;

for h = [1:TB_HRG_Len]
    
    % HRG demographic variables
    % Note:HRG rel risk is not used but can be used to calc prop TB disease, for later
    % Proportion of population 15+ in HRG
    PropPop15pHRG = 1.1*HRG_Inputs.Group{h}.TB_HRG_Dem_Prop15p;
    % Proportion of?ART patients 15 years and older with TB infection (% )
    HRG_PropLTBI = HRG_Inputs.Group{h}.TB_HRG_WithTBInfection;
    % Proportion of HRG 15 years and older with TB disease (% )
    HRG_PropTB = HRG_Inputs.Group{h}.TB_HRG_WithTBDisease;

    % Proportion with pulmonary TB, PTB (% )
    HRG_PropPTB= HRG_Inputs.Group{h}.TB_HRG_PropPTB;
    

    ACF_POP_Inputs=[];
    % Proportion with TB infection/LTBI
    ACF_POP_Inputs.PropLTBI=HRG_PropLTBI;
    % Proportion with TB disease/TB
    ACF_POP_Inputs.PropTB=HRG_PropTB;
    % Proportion with pulmonary TB, PTB (% )
    ACF_POP_Inputs.PropPTB=HRG_PropPTB;
    % ACF pop size
    ACF_POP_Inputs.Pop=pop_15Plus*PropPop15pHRG;  %point wise multiplication
    ACF_POP_Inputs.PropScreened = HRG_Inputs.Group{h}.TB_HRGProportionScreened;
    ACF_POP_Inputs.Screen_Sens_PTB=HRG_Inputs.Group{h}.TB_HRGScreenSensitivity;
    ACF_POP_Inputs.Screen_Spec_PTB=HRG_Inputs.Group{h}.TB_HRGScreenSpecificity;
    ACF_POP_Inputs.Diag_Sens_PTB=HRG_Inputs.Group{h}.TB_HRGDiagSensitivity;
    ACF_POP_Inputs.Diag_Spec_PTB=HRG_Inputs.Group{h}.TB_HRGDiagSpecificity;
    ACF_POP_Inputs.PropDiagLinkedTx =HRG_Inputs.Group{h}.TB_HRGPropLinkedTreat;
    ACF_POP_Inputs.PropTPTPresumptiveTx=HRG_Inputs.Group{h}.TB_HRGPropPrvntPresump;
    ACF_POP_Inputs.PropEligibleTPTtested=HRG_Inputs.Group{h}.TB_HRGPropPrvntTested;
    ACF_POP_Inputs.PropEligibleLinkedTPT=HRG_Inputs.Group{h}.TB_HRGPropEligiblePrvntLink;
    ACF_POP_Inputs.TPT_Cov=HRG_Inputs.HRG_TPTCov;

    HRGs{h} = RemoveNanfromFields(Set_ACF_Pop(ACF_POP_Inputs,TB_HRG_HighTBPrev_grp));

end

end


%noti type
NOTI.c_newinc=noti_dat{17};
NOTI.ret_nrel=noti_dat{18};
NOTI.new_labconf=noti_dat{19};
NOTI.new_clindx=noti_dat{20};
NOTI.new_ep=noti_dat{21};
NOTI.ret_rel_labconf=noti_dat{22};
NOTI.ret_rel_clindx=noti_dat{23};
NOTI.ret_rel_ep=noti_dat{24};

%noti age
NOTI.age=[];
NOTI.newrel_04=noti_dat{43};
NOTI.newrel_59=noti_dat{44};	
NOTI.newrel_1014=noti_dat{45};
NOTI.newrel_09=NOTI.newrel_04+NOTI.newrel_59;
NOTI.newrel_015=NOTI.newrel_04+NOTI.newrel_59+NOTI.newrel_1014;
NOTI.newrel_514=noti_dat{46};	
NOTI.newrel_014=noti_dat{47};	
NOTI.newrel_1519=noti_dat{48};	
NOTI.newrel_2024=noti_dat{49};	
NOTI.newrel_1524=noti_dat{50};	
NOTI.newrel_2534=noti_dat{51};	
NOTI.newrel_3544=noti_dat{52};	
NOTI.newrel_4554=noti_dat{53};	
NOTI.newrel_5564=noti_dat{54};	
NOTI.newrel_65=noti_dat{55};	
NOTI.newrel_15plus=noti_dat{56};

%hiv
NOTI.hiv=[];
NOTI.newrel_hivpos=noti_dat{63};
NOTI.newrel_art=noti_dat{64};

%bacp
NOTI.Bacp=[];
NOTI.Bacp_new=noti_dat{66};
NOTI.Bacp_ret=noti_dat{67};


function [result]=PT_NumDiagnosed(HH_Contacts, HRGs, NOTI, noti_target)
    result = [];

    notif_proj =noti_target;

    PropHIVpNotonART = NOTI.newrel_hivpos*(1-NOTI.newrel_art);
    PropHIVn         = 1-PropHIVpNotonART;

    c_ep = (NOTI.new_ep+NOTI.ret_rel_ep)/NOTI.c_newinc;
     
    NewRelapse0_9Cases   = NOTI.newrel_09;
    NewRelapse10_14Cases = NOTI.newrel_1014;
    NewRelapse15pCases   = 1-(NewRelapse0_9Cases+NewRelapse10_14Cases) ;

    HIVpCases         = NOTI.newrel_hivpos;
    HIVp15pCases      = NOTI.newrel_15plus;
    HIVp0_14Cases     = 1-HIVp15pCases;
    
    hrg_num_diagnosed=0;
    for hrg = [1:TB_HRG_Len]
        hrg_num_diagnosed =  hrg_num_diagnosed+HRGs{hrg}.NumDiagnosed;  
    end
    
    PI_HIVn_014_PTB_Dx = (notif_proj*PropHIVn...          
                        *(1-c_ep)...
                        *(NewRelapse0_9Cases+NewRelapse10_14Cases)...
                        -HH_Contacts{TB_HH0_4}.NumDiagnosed...
                        -HH_Contacts{TB_HH5_14}.NumDiagnosed);

    PI_HIVn_15p_PTB_Dx=(notif_proj*PropHIVn...
                        *(1-c_ep)*NewRelapse15pCases...
                        -HH_Contacts{TB_HH15p}.NumDiagnosed...
                        -hrg_num_diagnosed); 
                
    % 2/3 for the number of 0-9
    PI_HIVp_09_PTB_Dx=(notif_proj*PropHIVpNotonART*(1-c_ep)*HIVp0_14Cases*2/3);
    PI_HIVp_1014_PTB_Dx=(notif_proj*PropHIVpNotonART*(1-c_ep)*HIVp0_14Cases*1/3);
    PI_HIVp_15p_PTB_Dx=(notif_proj*PropHIVpNotonART*(1-c_ep)*HIVp15pCases);
    
    % Extra-Pulmonary TB
    PI_HIVn_014_ETB_Dx=notif_proj*PropHIVn*c_ep*(NewRelapse0_9Cases+NewRelapse10_14Cases);                     
    PI_HIVn_15p_ETB_Dx=notif_proj*PropHIVn*c_ep*NewRelapse15pCases;
    PI_HIVp_09_ETB_Dx=notif_proj*PropHIVpNotonART*c_ep*HIVp0_14Cases*2/3;
    PI_HIVp_1014_ETB_Dx=notif_proj*PropHIVpNotonART*c_ep*HIVp0_14Cases*1/3;
    PI_HIVp_15p_ETB_Dx=notif_proj*PropHIVpNotonART*c_ep*HIVp15pCases;

   tdx= PI_HIVn_014_PTB_Dx(1)+...
    PI_HIVn_15p_PTB_Dx(1)+...
    PI_HIVp_09_PTB_Dx(1)+...
    PI_HIVp_1014_PTB_Dx(1)+...
    PI_HIVp_15p_PTB_Dx(1)+...
    PI_HIVn_014_ETB_Dx(1)+...
    PI_HIVn_15p_ETB_Dx(1)+...
    PI_HIVp_09_ETB_Dx(1)+...
    PI_HIVp_1014_ETB_Dx(1)+...
    PI_HIVp_15p_ETB_Dx(1);
    
    PI_HIVn_014_PTB_Dx=max(PI_HIVn_014_PTB_Dx,0);
    PI_HIVn_15p_PTB_Dx=max(PI_HIVn_15p_PTB_Dx,0);
    PI_HIVp_09_PTB_Dx=max(PI_HIVp_09_PTB_Dx,0);
    PI_HIVp_1014_PTB_Dx=max(PI_HIVp_1014_PTB_Dx,0);
    PI_HIVp_15p_PTB_Dx=max(PI_HIVp_15p_PTB_Dx,0);
    
    PI_HIVn_014_ETB_Dx=max(PI_HIVn_014_ETB_Dx,0);
    PI_HIVn_15p_ETB_Dx=max(PI_HIVn_15p_ETB_Dx,0);
    PI_HIVp_09_ETB_Dx=max(PI_HIVp_09_ETB_Dx,0);
    PI_HIVp_1014_ETB_Dx=max(PI_HIVp_1014_ETB_Dx,0);
    PI_HIVp_15p_ETB_Dx=max(PI_HIVp_15p_ETB_Dx,0);
    

    result =  [PI_HIVn_014_PTB_Dx;...
               PI_HIVn_15p_PTB_Dx;...
               PI_HIVp_09_PTB_Dx;...
               PI_HIVp_1014_PTB_Dx;...
               PI_HIVp_15p_PTB_Dx;...

               PI_HIVn_014_ETB_Dx;... 
               PI_HIVn_15p_ETB_Dx;...
               PI_HIVp_09_ETB_Dx;...
               PI_HIVp_1014_ETB_Dx;...
               PI_HIVp_15p_ETB_Dx];

    % removes all negative values
    result=max(result,0);
   
end


function [PatientInitiated]=CalcPatientInitiatedTargetPopulations(Patient_Inputs,HH_Contacts, HRGs, NOTI, noti_target)
   
    
    PatientInitiated=[];
    num_diagnosed = PT_NumDiagnosed(HH_Contacts, HRGs, NOTI, noti_target);
 
    for pt = TB_PatientInitiated_List
        PatientInitiated_Inputs = [];
        PatientInitiated_Inputs.PrevTB = Patient_Inputs{pt}.TB_Prevalence;
        PatientInitiated_Inputs.Diagnosed = num_diagnosed(pt,:);
          
        PatientInitiated_Inputs.Screen_Sens_TB=Patient_Inputs{pt}.TB_PatientScreenSensitivity;
        PatientInitiated_Inputs.Screen_Spec_TB=Patient_Inputs{pt}.TB_PatientScreenSpecificity;

        PatientInitiated_Inputs.Diag_Sens_TB=Patient_Inputs{pt}.TB_PatientDiagSensitivity;
        PatientInitiated_Inputs.Diag_Spec_TB=Patient_Inputs{pt}.TB_PatientDiagSpecificityTag;
              
        PatientInitiated_Inputs.PropDiagLinkedTx=Patient_Inputs{pt}.PropDiagLinkedTx;
        
        PatientInitiated{pt} = Set_PatientInit_Pop(PatientInitiated_Inputs,pt); 
    end
    
%     PatientInitiated{1}
%     PatientInitiated{2}
%     PatientInitiated{6}
%     PatientInitiated{7}
%     pause
%     

end

function [ART_Cohort]=GetARTFromAIM(sv,age) % from AIM
    ART_Cohort=ARTFromAIM{sv,age}; 
end 


function [CostingTPs, RR_Profiles, DST_Coverage, Resis_Profiles]=CalcTargetPopulationTable(HH_Contacts, ART_Cohorts, HRGs, PatientInitiated, NOTI, DST_Cov)

%Set inputs for DST profile
[RR_Profiles, DST_Coverage] = SetMDRandDSTInputs(NOTI,DST_Cov);

Dx_Pop=[];
% Pulmonary TB
DxByGrp=zeros(TB_HRG_HighTBPrev_grp,length(noti_years));
Dx_Pop{TB_PTB,TB_Child} = aggregateTargetValues( {PatientInitiated{TB_PTB_HIVn_014_grp}, ...
                                                  PatientInitiated{TB_PTB_HIVp_09_grp},...
                                                  PatientInitiated{TB_PTB_HIVp_1014_grp},...
                                                  HH_Contacts{TB_HH0_4},...
                                                  HH_Contacts{TB_HH5_14},...
                                                  ART_Cohorts{TB_ARTNotServere,TB_ART0_9},...
                                                  ART_Cohorts{TB_ARTNotServere,TB_ART10_14},...
                                                  ART_Cohorts{TB_ARTSevereIllness,TB_ART0_9},...
                                                  ART_Cohorts{TB_ARTSevereIllness,TB_ART10_14}} );


Dx_Pop{TB_PTB,TB_Adult}=aggregateTargetValues( {PatientInitiated{TB_PTB_HIVn_15p_grp},... 
                                                PatientInitiated{TB_PTB_HIVp_15p_grp},... 
                                                HH_Contacts{TB_HH15p},...
                                                ART_Cohorts{TB_ARTNotServere,TB_ART15p},...
                                                ART_Cohorts{TB_ARTSevereIllness,TB_ART15p},...
                                                HRGs{TB_HRG_HighTBPrev} } );


%Extra-Pulmonary TB
Dx_Pop{TB_ETB,TB_Child}=aggregateTargetValues( {PatientInitiated{TB_ETB_HIVn_014_grp},... 
                                                PatientInitiated{TB_ETB_HIVp_09_grp},...
                                                PatientInitiated{TB_ETB_HIVp_1014_grp} } );

Dx_Pop{TB_ETB,TB_Adult}=aggregateTargetValues({PatientInitiated{TB_ETB_HIVn_15p_grp},...
                                               PatientInitiated{TB_ETB_HIVp_15p_grp}} );
                                           
                                         
DxByGrp=zeros(TB_HRG_HighTBPrev_grp,length(noti_years));
aggregateTargetValuesDx(  {PatientInitiated{TB_PTB_HIVn_014_grp}, ...
                           PatientInitiated{TB_PTB_HIVn_15p_grp},...
                           PatientInitiated{TB_PTB_HIVp_09_grp},...
                           PatientInitiated{TB_PTB_HIVp_1014_grp},...
                           PatientInitiated{TB_PTB_HIVp_15p_grp},...
                           PatientInitiated{TB_ETB_HIVn_014_grp}, ...
                           PatientInitiated{TB_ETB_HIVn_15p_grp},...
                           PatientInitiated{TB_ETB_HIVp_09_grp},...
                           PatientInitiated{TB_ETB_HIVp_1014_grp},...
                           PatientInitiated{TB_ETB_HIVp_15p_grp},...
                           HH_Contacts{TB_HH0_4},...
                           HH_Contacts{TB_HH5_14},...
                           HH_Contacts{TB_HH15p},...
                           ART_Cohorts{TB_ARTNotServere,TB_ART0_9},...
                           ART_Cohorts{TB_ARTNotServere,TB_ART10_14},...
                           ART_Cohorts{TB_ARTNotServere,TB_ART15p},...
                           ART_Cohorts{TB_ARTSevereIllness,TB_ART0_9},...
                           ART_Cohorts{TB_ARTSevereIllness,TB_ART10_14},...
                           ART_Cohorts{TB_ARTSevereIllness,TB_ART15p},...
                           HRGs{TB_HRG_HighTBPrev}} );                        
 
% DxByGrp
% DxByGrp(6:10,:)
% 
% DxByGrp(11:12,:)
% pause

%collect screening volumes
ScrByGrp=zeros(TB_HRG_HighTBPrev_grp,length(noti_years));

aggregateTargetValuesScr( {  PatientInitiated{TB_PTB_HIVn_014_grp}, ...
                             PatientInitiated{TB_PTB_HIVn_15p_grp},...
                            PatientInitiated{TB_PTB_HIVp_09_grp},...
                            PatientInitiated{TB_PTB_HIVp_1014_grp},...
                            PatientInitiated{TB_PTB_HIVp_15p_grp},...
                             PatientInitiated{TB_ETB_HIVn_014_grp}, ...
                             PatientInitiated{TB_ETB_HIVn_15p_grp},...
                             PatientInitiated{TB_ETB_HIVp_09_grp},...
                             PatientInitiated{TB_ETB_HIVp_1014_grp},...
                             PatientInitiated{TB_ETB_HIVp_15p_grp},...
                             HH_Contacts{TB_HH0_4},...
                             HH_Contacts{TB_HH5_14},...
                             HH_Contacts{TB_HH15p},...
                             ART_Cohorts{TB_ARTNotServere,TB_ART0_9},...
                             ART_Cohorts{TB_ARTNotServere,TB_ART10_14},...
                             ART_Cohorts{TB_ARTNotServere,TB_ART15p},...
                             ART_Cohorts{TB_ARTSevereIllness,TB_ART0_9},...
                             ART_Cohorts{TB_ARTSevereIllness,TB_ART10_14},...
                             ART_Cohorts{TB_ARTSevereIllness,TB_ART15p},...
                             HRGs{TB_HRG_HighTBPrev} } );
 
                         
%collect diagnostic referral volumes
DxRefByGrp=zeros(TB_HRG_HighTBPrev_grp,length(noti_years));
aggregateTargetValuesDxRef( {PatientInitiated{TB_PTB_HIVn_014_grp}, ...
                           PatientInitiated{TB_PTB_HIVn_15p_grp},...
                           PatientInitiated{TB_PTB_HIVp_09_grp},...
                           PatientInitiated{TB_PTB_HIVp_1014_grp},...
                           PatientInitiated{TB_PTB_HIVp_15p_grp},...
                           PatientInitiated{TB_ETB_HIVn_014_grp}, ...
                           PatientInitiated{TB_ETB_HIVn_15p_grp},...
                           PatientInitiated{TB_ETB_HIVp_09_grp},...
                           PatientInitiated{TB_ETB_HIVp_1014_grp},...
                           PatientInitiated{TB_ETB_HIVp_15p_grp},...
                           HH_Contacts{TB_HH0_4},...
                           HH_Contacts{TB_HH5_14},...
                           HH_Contacts{TB_HH15p},...
                           ART_Cohorts{TB_ARTNotServere,TB_ART0_9},...
                           ART_Cohorts{TB_ARTNotServere,TB_ART10_14},...
                           ART_Cohorts{TB_ARTNotServere,TB_ART15p},...
                           ART_Cohorts{TB_ARTSevereIllness,TB_ART0_9},...
                           ART_Cohorts{TB_ARTSevereIllness,TB_ART10_14},...
                           ART_Cohorts{TB_ARTSevereIllness,TB_ART15p},...
                           HRGs{TB_HRG_HighTBPrev}} );                      
                       

% Dx_Pop{TB_PTB,TB_Child}
% Dx_Pop{TB_PTB,TB_Adult}
% Dx_Pop{TB_ETB,TB_Child}
% Dx_Pop{TB_ETB,TB_Adult}

TPT_Screened_U15=[];
TPT_Screened_U15=aggregateTargetValuesTPTScreened( { HH_Contacts{TB_HH0_4},...
                                                     HH_Contacts{TB_HH5_14},...
                                                     ART_Cohorts{TB_ARTNotServere,TB_ART0_9},...
                                                     ART_Cohorts{TB_ARTNotServere,TB_ART10_14},...
                                                     ART_Cohorts{TB_ARTSevereIllness,TB_ART0_9},...
                                                     ART_Cohorts{TB_ARTSevereIllness,TB_ART10_14} } );
TPT_Tx_U15=[];
TPT_Tx_U15=aggregateTargetValuesTPTTx( { HH_Contacts{TB_HH0_4},...
                                                     HH_Contacts{TB_HH5_14},...
                                                     ART_Cohorts{TB_ARTNotServere,TB_ART0_9},...
                                                     ART_Cohorts{TB_ARTNotServere,TB_ART10_14},...
                                                     ART_Cohorts{TB_ARTSevereIllness,TB_ART0_9},...
                                                     ART_Cohorts{TB_ARTSevereIllness,TB_ART10_14} } );
                                                 
TPT_LTBIDx_U15=[];                                                 
TPT_LTBIDx_U15=aggregateTargetValuesLTBIDx( { HH_Contacts{TB_HH0_4},...
                                                     HH_Contacts{TB_HH5_14},...
                                                     ART_Cohorts{TB_ARTNotServere,TB_ART0_9},...
                                                     ART_Cohorts{TB_ARTNotServere,TB_ART10_14},...
                                                     ART_Cohorts{TB_ARTSevereIllness,TB_ART0_9},...
                                                     ART_Cohorts{TB_ARTSevereIllness,TB_ART10_14} } );

% TPT_Screened_P15=[];
% TPT_Screened_P15=aggregateTargetValuesTPTScreened( { HH_Contacts{TB_HH15p},...
%                                                      ART_Cohorts{TB_ARTNotServere,TB_ART15p},...
%                                                      ART_Cohorts{TB_ARTSevereIllness,TB_ART15p} } );
TPT_Tx_P15=[];
TPT_Tx_P15=aggregateTargetValuesTPTTx( {   HH_Contacts{TB_HH15p},...
                                           ART_Cohorts{TB_ARTNotServere,TB_ART15p},...
                                           ART_Cohorts{TB_ARTSevereIllness,TB_ART15p} } );
                                                 
TPT_LTBIDx_P15=[];                                                 
TPT_LTBIDx_P15=aggregateTargetValuesLTBIDx( { HH_Contacts{TB_HH15p},...
                                              ART_Cohorts{TB_ARTNotServere,TB_ART15p},...
                                              ART_Cohorts{TB_ARTSevereIllness,TB_ART15p} } );


%collect LTBI testing
TPTDxByGrp=zeros(TB_HRG_HighTBPrev_grp,length(noti_years));
aggregateTargetValuesLTBIDx( {HH_Contacts{TB_HH0_4},...
                           HH_Contacts{TB_HH5_14},...
                           HH_Contacts{TB_HH15p},...
                           ART_Cohorts{TB_ARTNotServere,TB_ART0_9},...
                           ART_Cohorts{TB_ARTNotServere,TB_ART10_14},...
                           ART_Cohorts{TB_ARTNotServere,TB_ART15p},...
                           ART_Cohorts{TB_ARTSevereIllness,TB_ART0_9},...
                           ART_Cohorts{TB_ARTSevereIllness,TB_ART10_14},...
                           ART_Cohorts{TB_ARTSevereIllness,TB_ART15p},...
                           HRGs{TB_HRG_HighTBPrev}} );                                                              
                                          
                                                 
                                                 
TPT_Pop=[];
%TPT_Pop.TPT_Screened_U15=TPT_Screened_U15;
TPT_Pop.TPT_LTBIDx_U15=TPT_LTBIDx_U15;
TPT_Pop.TPT_Tx_U15=TPT_Tx_U15;
TPT_Pop.TPT_Tx_U15_DS=TPT_Pop.TPT_Tx_U15*(1-NOTI.U15_RifR_new);
TPT_Pop.TPT_Tx_U15_DR=TPT_Pop.TPT_Tx_U15*(NOTI.U15_RifR_new);



%TPT_Pop.TPT_Screened_P15=TPT_Screened_P15;
TPT_Pop.TPT_LTBIDx_P15=TPT_LTBIDx_P15;
TPT_Pop.TPT_Tx_P15=TPT_Tx_P15;
TPT_Pop.TPT_Tx_P15_DS=TPT_Pop.TPT_Tx_P15*(1-NOTI.P15_RifR_new);
TPT_Pop.TPT_Tx_P15_DR=TPT_Pop.TPT_Tx_P15*(NOTI.P15_RifR_new);



%x=[Dx_Pop{TB_PTB,TB_Child};Dx_Pop{TB_PTB,TB_Adult};Dx_Pop{TB_ETB,TB_Child};Dx_Pop{TB_ETB,TB_Adult}];
% sum(x,1)
% sum(DxByGrp,1)
% pause
%Add DST TPs by group 
[DST_Out]=DST_TargetPops(DxByGrp, DST_Coverage, RR_Profiles, NOTI);

%Add DST TPs
[DST_Pops, Tx_PopsU15, Tx_PopsP15, Resis_Profiles] = Add_DST_And_Tx_ToTargetPop(Dx_Pop, DST_Cov, RR_Profiles, NOTI);

CostingTPs{1}=DxByGrp;% number diagnosed
CostingTPs{2}=DST_Pops;%number to receive DST
CostingTPs{3}=Tx_PopsU15;%Tx by regimen U15
CostingTPs{4}=Tx_PopsP15;%Tx by regimen P15
CostingTPs{5}=TPT_Pop;% NumScreened
CostingTPs{6}=ScrByGrp;% number screened
CostingTPs{7}=DxRefByGrp;%referrred for diagnosis
CostingTPs{8}=TPTDxByGrp;%received LTBI test
CostingTPs{9}=DST_Out;%DST results

end

        
function [RR_Profile]=get_rr_profile(nr, NOTI)
RR_Profile=[];
if(nr==TB_NewCases)
    RR_Profile.Rif_Sen =NOTI.RifS_new;
    RR_Profile.INH_Sen = NOTI.InhS_new;
    RR_Profile.INH_Res = NOTI.InhR_new;
    RR_Profile.Rif_Res = NOTI.RifR_new;
    RR_Profile.FQ_Sen  = NOTI.FQS_new;
    RR_Profile.FQ_Res  = NOTI.FQR_new;
    RR_Profile.XDR     = 1/100;
    RR_Profile.WithSevereDisease = 1/100;
    RR_Profile.WithMeningitis = 1/100;
else
    RR_Profile.Rif_Sen =NOTI.RifS_ret;
    RR_Profile.INH_Sen = NOTI.InhS_ret;
    RR_Profile.INH_Res = NOTI.InhR_ret;
    RR_Profile.Rif_Res = NOTI.RifR_ret;
    RR_Profile.FQ_Sen  = NOTI.FQS_ret;
    RR_Profile.FQ_Res  = NOTI.FQR_ret;
    RR_Profile.XDR     = 1/100;
    RR_Profile.WithSevereDisease = 1/100;
    RR_Profile.WithMeningitis = 1/100;
end

end
    

 function [RR_Profiles,DST_Coverage] = SetMDRandDSTInputs(NOTI,DST_Cov) 

    RR_Profiles = []; 
    DST_Coverage = [];

    % Set resitance profile objects
    RR_Profiles= {get_rr_profile(TB_NewCases, NOTI);...
                  get_rr_profile(TB_RetreatCases, NOTI)};
            
    % Rifampicin resistance testing [or simultaneous Rifampicin and Isoniazid resistance testing]
    DST_Coverage.RR_DST_PTB = DST_Cov.RR_DST;
    DST_Coverage.RR_DST_ETB = DST_Cov.RR_DST;
    
    % Isoniazid resistance testing, among Rifampicin sensitive
    DST_Coverage.INH_RR_Sens_DST_PTB = DST_Cov.INH_RR_Sens_DST;
    DST_Coverage.INH_RR_Sens_DST_ETB = DST_Cov.INH_RR_Sens_DST;

    % Fluoroquinolone resistance testing, among Rifampicin resistant [bacteriologically confirmed]
    DST_Coverage.FQ_RR_Res_DST_PTB = DST_Cov.FQ_RR_Res_DST;
    DST_Coverage.FQ_RR_Res_DST_ETB = DST_Cov.FQ_RR_Res_DST;
    
 end

function [DST_Out]=DST_TargetPops(DxByGrp, DST_Coverage, RR_Profiles, NOTI);

rp_newU15 = RR_Profiles{TB_NewCases};
rp_new15p = RR_Profiles{TB_NewCases};

rp_retU15 = RR_Profiles{TB_RetreatCases};
rp_ret15p = RR_Profiles{TB_RetreatCases};

pRet       = NOTI.ret_nrel+NOTI.ret_rel_labconf+NOTI.ret_rel_clindx+NOTI.ret_rel_ep;
pNew      = 1-pRet;

%for each field of the rr profile, take a weighted average of the field using the %
%cases that are new and ret+relapse
rp_U15=rp_newU15;
rp_15p=rp_new15p;

%get weighted average for each field on the profile structure
rp_U15.Rif_Res=pNew *(rp_newU15.Rif_Res) + (pRet)*(rp_retU15.Rif_Res);   
rp_15p.Rif_Res=pNew *(rp_new15p.Rif_Res) + (pRet)*(rp_ret15p.Rif_Res); 

rp_U15.Rif_Sen=(1-rp_U15.Rif_Res);
rp_15p.Rif_Sen=(1-rp_15p.Rif_Res);

rp_U15.INH_Res=pNew*(rp_newU15.INH_Res) + (pRet)*(rp_retU15.INH_Res);    
rp_15p.INH_Res=pNew*(rp_new15p.INH_Res) + (pRet)*(rp_ret15p.INH_Res); 

rp_U15.INH_Sen=(1-rp_U15.INH_Res);
rp_15p.INH_Sen=(1-rp_15p.INH_Res);

rp_U15.FQ_Sen=pNew*(rp_newU15.FQ_Sen) + (pRet)*(rp_retU15.FQ_Sen);    
rp_15p.FQ_Sen=pNew*(rp_new15p.FQ_Sen) + (pRet)*(rp_ret15p.FQ_Sen); 

rp_U15.FQ_Res=pNew*(rp_newU15.FQ_Res) + (pRet)*(rp_retU15.FQ_Res);    
rp_15p.FQ_Res=pNew*(rp_new15p.FQ_Res) + (pRet)*(rp_ret15p.FQ_Res) ;

rp_U15.XDR=pNew*(rp_newU15.XDR) + (pRet)*(rp_retU15.XDR);   
rp_15p.XDR=pNew*(rp_new15p.XDR) + (pRet)*(rp_ret15p.XDR); 

rp_U15.WithSevereDisease=pNew*(rp_newU15.WithSevereDisease) + (pRet)*(rp_retU15.WithSevereDisease);    
rp_15p.WithSevereDisease=pNew*(rp_new15p.WithSevereDisease) + (pRet)*(rp_ret15p.WithSevereDisease); 

rp_U15.WithMeningitis=pNew*(rp_newU15.WithMeningitis) + (pRet)*(rp_retU15.WithMeningitis);   
rp_15p.WithMeningitis=pNew*(rp_new15p.WithMeningitis) + (pRet)*(rp_ret15p.WithMeningitis);

%rp_newU15, rp_new15p used in the code below,technically now an average of new and ret
rp_newU15=rp_U15;
rp_new15p=rp_15p;

RR_DST_Dx=zeros(size(DxByGrp,1), length(NOTI.years));
FQ_DST_Dx=zeros(size(DxByGrp,1), length(NOTI.years));
INH_DST_Dx=zeros(size(DxByGrp,1), length(NOTI.years));

RR_Confirmed=zeros(size(DxByGrp,1), length(NOTI.years));
RS_Confirmed=zeros(size(DxByGrp,1), length(NOTI.years));
    
for I=1:size(DxByGrp,1)
 
grpDx=DxByGrp(I,:);

% RR screening
RR_DST_dx=(grpDx).*(DST_Coverage.RR_DST_PTB);

RR_Confirmed(I,:)=(RR_DST_dx)*(rp_newU15.Rif_Res);
RS_Confirmed(I,:)=(RR_DST_dx)*(rp_newU15.Rif_Sen);
FQR_Confirmed(I,:)=(RR_DST_dx)*(rp_newU15.Rif_Res).*(DST_Coverage.FQ_RR_Res_DST_PTB)*(rp_newU15.FQ_Res);
INH_Confirmed(I,:)=(RR_DST_dx)*(rp_newU15.Rif_Sen).*(DST_Coverage.INH_RR_Sens_DST_PTB)*(rp_newU15.INH_Res);

% establish INH status
INH_DST_Dx(I,:) =(RR_DST_dx)*(rp_newU15.Rif_Sen).*(DST_Coverage.INH_RR_Sens_DST_PTB);

% establish RR status
RR_DST_Dx(I,:)=RR_DST_dx-INH_DST_Dx(I,:);

% establish FQ status
FQ_DST_Dx(I,:)=(RR_DST_dx)*(rp_newU15.Rif_Res).*(DST_Coverage.FQ_RR_Res_DST_PTB);

end

DST_Out=cell(1);
DST_Out{1}=RR_DST_Dx;
DST_Out{2}=INH_DST_Dx;
DST_Out{3}=FQ_DST_Dx;
DST_Out{4}=RR_Confirmed;
DST_Out{5}=RS_Confirmed;
DST_Out{6}=FQR_Confirmed;
DST_Out{7}=INH_Confirmed;

end


      
        

function [DST_Pops, Tx_PopsU15, Tx_PopsP15, Resis_Profiles]=Add_DST_And_Tx_ToTargetPop(Dx_Pop, DST_Coverage, RR_Profiles, NOTI);

DST_Pops=[];
Tx_PopsU15=[];
Tx_PopsP15=[];

lPTB_U15    = Dx_Pop{TB_PTB,TB_Child};
lPTB_15Plus = Dx_Pop{TB_PTB,TB_Adult};
lETB_U15    = Dx_Pop{TB_ETB,TB_Child};
lETB_15Plus = Dx_Pop{TB_ETB,TB_Adult};

% lPTB_U15+lPTB_15Plus+lETB_U15+lETB_15Plus
% pause

rp_newU15 = RR_Profiles{TB_NewCases};
rp_new15p = RR_Profiles{TB_NewCases};

rp_retU15 = RR_Profiles{TB_RetreatCases};
rp_ret15p = RR_Profiles{TB_RetreatCases};

pRet       = NOTI.ret_nrel+NOTI.ret_rel_labconf+NOTI.ret_rel_clindx+NOTI.ret_rel_ep;
pNew      = 1-pRet;

%for each field of the rr profile, take a weighted average of the field using the %
%cases that are new and ret+relapse
rp_U15=rp_newU15;
rp_15p=rp_new15p;

%get weighted average for each field on the profile structure
rp_U15.Rif_Res=pNew *(rp_newU15.Rif_Res) + (pRet)*(rp_retU15.Rif_Res);   
rp_15p.Rif_Res=pNew *(rp_new15p.Rif_Res) + (pRet)*(rp_ret15p.Rif_Res); 

rp_U15.Rif_Sen=(1-rp_U15.Rif_Res);
rp_15p.Rif_Sen=(1-rp_15p.Rif_Res);

rp_U15.INH_Res=pNew*(rp_newU15.INH_Res) + (pRet)*(rp_retU15.INH_Res);    
rp_15p.INH_Res=pNew*(rp_new15p.INH_Res) + (pRet)*(rp_ret15p.INH_Res); 

rp_U15.INH_Sen=(1-rp_U15.INH_Res);
rp_15p.INH_Sen=(1-rp_15p.INH_Res);

rp_U15.FQ_Sen=pNew*(rp_newU15.FQ_Sen) + (pRet)*(rp_retU15.FQ_Sen);    
rp_15p.FQ_Sen=pNew*(rp_new15p.FQ_Sen) + (pRet)*(rp_ret15p.FQ_Sen); 

rp_U15.FQ_Res=pNew*(rp_newU15.FQ_Res) + (pRet)*(rp_retU15.FQ_Res);    
rp_15p.FQ_Res=pNew*(rp_new15p.FQ_Res) + (pRet)*(rp_ret15p.FQ_Res) ;

rp_U15.XDR=pNew*(rp_newU15.XDR) + (pRet)*(rp_retU15.XDR);   
rp_15p.XDR=pNew*(rp_new15p.XDR) + (pRet)*(rp_ret15p.XDR); 

rp_U15.WithSevereDisease=pNew*(rp_newU15.WithSevereDisease) + (pRet)*(rp_retU15.WithSevereDisease);    
rp_15p.WithSevereDisease=pNew*(rp_new15p.WithSevereDisease) + (pRet)*(rp_ret15p.WithSevereDisease); 

rp_U15.WithMeningitis=pNew*(rp_newU15.WithMeningitis) + (pRet)*(rp_retU15.WithMeningitis);   
rp_15p.WithMeningitis=pNew*(rp_new15p.WithMeningitis) + (pRet)*(rp_ret15p.WithMeningitis);

%rp_newU15, rp_new15p used in the code below,technically now an average of new and ret
rp_newU15=rp_U15;
rp_new15p=rp_15p;

Resis_Profiles=[];
Resis_Profiles{1}=rp_U15;
Resis_Profiles{2}=rp_U15;

% then use rp_U15 and rp_15p in the calcs below in this function   

DST_Pops = [];
DST_Pops.PTB_U15_Dx=lPTB_U15;
DST_Pops.PTB_15Plus_Dx=lPTB_15Plus;

DST_Pops.ETB_U15_Dx=lETB_U15;
DST_Pops.ETB_15Plus_Dx=lETB_15Plus;

DST_Pops.PTB_AllAges_Dx=lPTB_U15+lPTB_15Plus;
DST_Pops.ETB_AllAges_Dx=lETB_U15+lETB_15Plus;

DST_Pops.DST_Conf_RifR=0;

% PTB, U15
% establish RR status
RR_DST_PTB_Dx_U15=(DST_Pops.PTB_U15_Dx).*(DST_Coverage.RR_DST);
RR_DST_PTB_NoDx_U15=(DST_Pops.PTB_U15_Dx).*(1-DST_Coverage.RR_DST);

% establish FQ status
FQ_DST_PTB_Dx_U15=(RR_DST_PTB_Dx_U15)*(rp_newU15.Rif_Res).*(DST_Coverage.FQ_RR_Res_DST);
FQ_DST_PTB_NoDx_U15=(RR_DST_PTB_Dx_U15)*(rp_newU15.Rif_Res).*(1-DST_Coverage.FQ_RR_Res_DST);

RR_DST_PTB_Num_U15=(DST_Pops.PTB_U15_Dx);
INH_DST_PTB_Num_U15=(RR_DST_PTB_Dx_U15)*(rp_newU15.Rif_Sen);%to test for INH resistance
FQ_DST_PTB_Num_U15=(RR_DST_PTB_Dx_U15)*(rp_newU15.Rif_Res);%to test for FQ resistance
DST_Pops.DST_Conf_RifR=DST_Pops.DST_Conf_RifR+FQ_DST_PTB_Num_U15;

RR_DST_PTB_NumDx_U15=RR_DST_PTB_Dx_U15;
INH_DST_PTB_NumDx_U15=(INH_DST_PTB_Num_U15).*(DST_Coverage.INH_RR_Sens_DST);
INH_DST_PTB_NumNoDx_U15=(INH_DST_PTB_Num_U15).*(1-DST_Coverage.INH_RR_Sens_DST);
FQ_DST_PTB_NumDx_U15=(FQ_DST_PTB_Num_U15).*(DST_Coverage.FQ_RR_Res_DST);
FQ_DST_PTB_NumNoDx_U15=(FQ_DST_PTB_Num_U15).*(1-DST_Coverage.FQ_RR_Res_DST);

% PTB, 15Plus
% establish RR status
RR_DST_PTB_Dx_15Plus=(DST_Pops.PTB_15Plus_Dx).*(DST_Coverage.RR_DST);
RR_DST_PTB_NoDx_15Plus=(DST_Pops.PTB_15Plus_Dx).*(1-DST_Coverage.RR_DST);
% establish FQ status
FQ_DST_PTB_Dx_15Plus=(RR_DST_PTB_Dx_15Plus)*(rp_new15p.Rif_Res).*(DST_Coverage.FQ_RR_Res_DST);
FQ_DST_PTB_NoDx_15Plus=(RR_DST_PTB_Dx_15Plus)*(rp_new15p.Rif_Res).*(1-DST_Coverage.FQ_RR_Res_DST);

RR_DST_PTB_Num_15Plus     = DST_Pops.PTB_15Plus_Dx;
INH_DST_PTB_Num_15Plus    = (RR_DST_PTB_Dx_15Plus)*(rp_new15p.Rif_Sen);%to test for INH resistance
FQ_DST_PTB_Num_15Plus     = (RR_DST_PTB_Dx_15Plus)*(rp_new15p.Rif_Res);%to test for FQ resistance
DST_Pops.DST_Conf_RifR=DST_Pops.DST_Conf_RifR+FQ_DST_PTB_Num_15Plus;

RR_DST_PTB_NumDx_15Plus     = (RR_DST_PTB_Dx_15Plus);
INH_DST_PTB_NumDx_15Plus    = (INH_DST_PTB_Num_15Plus).*(DST_Coverage.INH_RR_Sens_DST);
INH_DST_PTB_NumNoDx_15Plus    = (INH_DST_PTB_Num_15Plus).*(1-DST_Coverage.INH_RR_Sens_DST);
FQ_DST_PTB_NumDx_15Plus     = (FQ_DST_PTB_Num_15Plus).*(DST_Coverage.FQ_RR_Res_DST);
FQ_DST_PTB_NumNoDx_15Plus     = (FQ_DST_PTB_Num_15Plus).*(1-DST_Coverage.FQ_RR_Res_DST);

% PTB, All ages
% Number to be tested for Rifampicin and Isoniazid resistance
RR_DST_PTB_Num=RR_DST_PTB_Num_U15+RR_DST_PTB_Num_15Plus;

% Number to be tested for Isoniazid resistance, among Rifampicin sensitive cases
INH_DST_PTB_Num=INH_DST_PTB_Num_U15+INH_DST_PTB_Num_15Plus;

% Number to be tested for Fluoroquinolone resistance, among Rifampicin resistant cases
FQ_DST_PTB_Num=FQ_DST_PTB_Num_U15+FQ_DST_PTB_Num_15Plus;

% Number tested
% Number tested for Rifampicin and Isoniazid resistance
RR_DST_PTB_NumDx=RR_DST_PTB_NumDx_U15+RR_DST_PTB_NumDx_15Plus;

% Number tested for Isoniazid resistance, among Rifampicin sensitive cases
INH_DST_PTB_NumDx=INH_DST_PTB_NumDx_U15+INH_DST_PTB_NumDx_15Plus;

% Number tested for Fluoroquinolone resistance, among Rifampicin resistant cases
FQ_DST_PTB_NumDx=FQ_DST_PTB_NumDx_U15+FQ_DST_PTB_NumDx_15Plus;

% Extra-Pulmonary TB, DST
% establish RR status
RR_DST_ETB_Dx_U15=(DST_Pops.ETB_U15_Dx).*(DST_Coverage.RR_DST);
RR_DST_ETB_NoDx_U15=(DST_Pops.ETB_U15_Dx).*(1-DST_Coverage.RR_DST);
% establish FQ status
FQ_DST_ETB_Dx_U15=(RR_DST_ETB_Dx_U15)*(rp_newU15.Rif_Res).*(DST_Coverage.FQ_RR_Res_DST);
FQ_DST_ETB_NoDx_U15=(RR_DST_ETB_Dx_U15)*(rp_newU15.Rif_Res).*(1-DST_Coverage.FQ_RR_Res_DST);

RR_DST_ETB_Num_U15=(DST_Pops.ETB_U15_Dx);
INH_DST_ETB_Num_U15=(RR_DST_ETB_Dx_U15)*(rp_newU15.Rif_Sen);
FQ_DST_ETB_Num_U15=(RR_DST_ETB_Dx_U15)*(rp_newU15.Rif_Res);
DST_Pops.DST_Conf_RifR=DST_Pops.DST_Conf_RifR+FQ_DST_ETB_Num_U15;

RR_DST_ETB_NumDx_U15=RR_DST_ETB_Dx_U15;
INH_DST_ETB_NumDx_U15=(INH_DST_ETB_Num_U15).*(DST_Coverage.INH_RR_Sens_DST);
INH_DST_ETB_NumNoDx_U15=(INH_DST_ETB_Num_U15).*(1-DST_Coverage.INH_RR_Sens_DST);
FQ_DST_ETB_NumDx_U15=(FQ_DST_ETB_Num_U15).*(DST_Coverage.FQ_RR_Res_DST);
FQ_DST_ETB_NumNoDx_U15=(FQ_DST_ETB_Num_U15).*(1-DST_Coverage.FQ_RR_Res_DST);

% Extra-Pulmonary TB, DST
% establish RR status
RR_DST_ETB_Dx_15Plus=(DST_Pops.ETB_15Plus_Dx).*(DST_Coverage.RR_DST);
RR_DST_ETB_NoDx_15Plus=(DST_Pops.ETB_15Plus_Dx).*(1-DST_Coverage.RR_DST);

% establish FQ status
FQ_DST_ETB_Dx_15Plus=(RR_DST_ETB_Dx_15Plus)*(rp_new15p.Rif_Res).*(DST_Coverage.FQ_RR_Res_DST);
FQ_DST_ETB_NoDx_15Plus=(RR_DST_ETB_Dx_15Plus)*(rp_new15p.Rif_Res).*(1-DST_Coverage.FQ_RR_Res_DST);

RR_DST_ETB_Num_15Plus=(DST_Pops.ETB_15Plus_Dx);
INH_DST_ETB_Num_15Plus=(RR_DST_ETB_Dx_15Plus)*(rp_new15p.Rif_Sen);
FQ_DST_ETB_Num_15Plus=(RR_DST_ETB_Dx_15Plus)*(rp_new15p.Rif_Res);
DST_Pops.DST_Conf_RifR=DST_Pops.DST_Conf_RifR+FQ_DST_ETB_Num_15Plus;

RR_DST_ETB_NumDx_15Plus=RR_DST_ETB_Dx_15Plus;
INH_DST_ETB_NumDx_15Plus=(INH_DST_ETB_Num_15Plus).*(DST_Coverage.INH_RR_Sens_DST);
INH_DST_ETB_NumNoDx_15Plus=(INH_DST_ETB_Num_15Plus).*(1-DST_Coverage.INH_RR_Sens_DST);
FQ_DST_ETB_NumDx_15Plus=(FQ_DST_ETB_Num_15Plus).*(DST_Coverage.FQ_RR_Res_DST);
FQ_DST_ETB_NumNoDx_15Plus=(FQ_DST_ETB_Num_15Plus).*(1-DST_Coverage.FQ_RR_Res_DST);


% ETB, All ages
% Number to be tested for Rifampicin and Isoniazid resistance
RR_DST_ETB_Num=RR_DST_ETB_Num_U15+RR_DST_ETB_Num_15Plus;

% Number to be tested for Isoniazid resistance, among Rifampicin sensitive cases
INH_DST_ETB_Num=INH_DST_ETB_Num_U15+INH_DST_ETB_Num_15Plus;

% Number to be tested for Fluoroquinolone resistance, among Rifampicin resistant cases
FQ_DST_ETB_Num=FQ_DST_ETB_Num_U15+FQ_DST_ETB_Num_15Plus;

% Number tested for Rifampicin and Isoniazid resistance
RR_DST_ETB_NumDx=RR_DST_ETB_NumDx_U15+RR_DST_ETB_NumDx_15Plus;

% Number tested for Isoniazid resistance, among Rifampicin sensitive cases
INH_DST_ETB_NumDx=INH_DST_ETB_NumDx_U15+INH_DST_ETB_NumDx_15Plus;

% Number tested for Fluoroquinolone resistance, among Rifampicin resistant cases
FQ_DST_ETB_NumDx=FQ_DST_ETB_NumDx_U15+FQ_DST_ETB_NumDx_15Plus;

for I=1:2
    
ptb=0;
etb=0;
if(I==1), ptb=1; end;
if(I==2), etb=1; end;

%Treatment for TB disease
% Number confirmed Rifampicin and Isoniazid sensitive';
NoDx_U15 = 0;
NoDx_15Plus = 0;
Rif_INH_Sen_NumDx_U15=(NoDx_U15) +(ptb*INH_DST_PTB_NumDx_U15+etb*INH_DST_ETB_NumDx_U15)*(rp_newU15.INH_Sen);
Rif_INH_Sen_NumDx_15Plus=(NoDx_15Plus)+(ptb*INH_DST_PTB_NumDx_15Plus+etb*INH_DST_ETB_NumDx_15Plus)*(rp_new15p.INH_Sen);

% Number not confirmed Rifampicin and Isoniazid sensitive';
NoDx_U15=(ptb*RR_DST_PTB_NoDx_U15+etb*RR_DST_ETB_NoDx_U15);% no RR DST
NoDx_U15=NoDx_U15+(ptb*INH_DST_PTB_NumNoDx_U15+etb*INH_DST_ETB_NumNoDx_U15);%confirmed RR sens but no INH DST

NoDx_15Plus=(ptb*RR_DST_PTB_NoDx_15Plus+etb*RR_DST_ETB_NoDx_15Plus);% no RR DST
NoDx_15Plus=NoDx_15Plus+(ptb*INH_DST_PTB_NumNoDx_15Plus+etb*INH_DST_ETB_NumNoDx_15Plus);%confirmed RR sens but no INH DST

Rif_INH_Sen_NumNoDx_U15=NoDx_U15;
Rif_INH_Sen_NumNoDx_15Plus=NoDx_15Plus;

Rif_INH_Sen_Severe_U15    = (Rif_INH_Sen_NumDx_U15+Rif_INH_Sen_NumNoDx_U15)*rp_newU15.WithSevereDisease; % Children, aged 0-14, with severe TB
Rif_INH_Sen_Severe_15Plus = (Rif_INH_Sen_NumDx_15Plus+Rif_INH_Sen_NumNoDx_15Plus)*rp_new15p.WithSevereDisease; % Adults, aged 15+, with severe TB

Rif_INH_Sen_NotSevere_U15    = (Rif_INH_Sen_NumDx_U15+Rif_INH_Sen_NumNoDx_U15)*(1-rp_newU15.WithSevereDisease); % Children, aged 0-14, without severe TB
Rif_INH_Sen_NotSevere_15Plus = (Rif_INH_Sen_NumDx_15Plus+Rif_INH_Sen_NumNoDx_15Plus)*(1-rp_new15p.WithSevereDisease); % Adults, aged 15+, without severe TB


% Number drug-susceptible TB with meningitis and pericarditis';
Rif_INH_Sen_Meningitis_U15 =  (Rif_INH_Sen_NumDx_U15)*(rp_newU15.WithMeningitis); % Children, aged 0-14
Rif_INH_Sen_Meningitis_15Plus = (Rif_INH_Sen_NumDx_15Plus)*(rp_new15p.WithMeningitis); % Adults, aged 15+

% Number confirmed and in need of treatment
% Number confirmed Rifampicin sensitive and Isoniazid resistant';
Rif_INH_Res_NumDx_U15=(ptb*INH_DST_PTB_NumDx_U15+etb*INH_DST_ETB_NumDx_U15)*(rp_newU15.INH_Res);
Rif_INH_Res_NumDx_15Plus=(ptb*INH_DST_PTB_NumDx_15Plus+etb*INH_DST_ETB_NumDx_15Plus)*(rp_new15p.INH_Res);

% Number confirmed Rifampicin resistant and Fluoroquinolone sensitive';
RR_FQ_Sen_NumDx_U15=(ptb*FQ_DST_PTB_NumDx_U15+etb*FQ_DST_ETB_NumDx_U15)*(rp_newU15.FQ_Sen);
RR_FQ_Sen_NumDx_15Plus=(ptb*FQ_DST_PTB_NumDx_15Plus+etb*FQ_DST_ETB_NumDx_15Plus)*(rp_new15p.FQ_Sen);

%Number confirmed Rifampicin resistant and not confirmed Fluoroquinolone status, asssume FQ sens
RR_FQ_Sen_NumNoDx_U15=ptb*FQ_DST_PTB_NumNoDx_U15+etb*FQ_DST_ETB_NumNoDx_U15;
RR_FQ_Sen_NumNoDx_15Plus=ptb*FQ_DST_PTB_NumNoDx_15Plus+etb*FQ_DST_ETB_NumNoDx_15Plus;

% Number confirmed Rifampicin resistant and Fluoroquinolone resistant, pre-XDR';
Rif_FQ_Res_NumDx_U15=(ptb*FQ_DST_PTB_NumDx_U15+etb*FQ_DST_ETB_NumDx_U15)*(rp_newU15.FQ_Res);
Rif_FQ_Res_NumDx_15Plus=(ptb*FQ_DST_PTB_NumDx_15Plus+etb*FQ_DST_ETB_NumDx_15Plus)*(rp_new15p.FQ_Res);

Rif_FQ_Res_NumDx_PTB_U15=(ptb*FQ_DST_PTB_NumDx_U15)*(rp_newU15.FQ_Res);
Rif_FQ_Res_NumDx_PTB_15Plus=(ptb*FQ_DST_PTB_NumDx_15Plus)*(rp_new15p.FQ_Res);

Rif_FQ_Res_NumDx_ETB_U15=(etb*FQ_DST_ETB_NumDx_U15)*(rp_newU15.FQ_Res);
Rif_FQ_Res_NumDx_ETB_15Plus=(etb*FQ_DST_ETB_NumDx_15Plus)*(rp_new15p.FQ_Res);

TB_NumConfRifSen_INHSen{TB_Child,I}  = Rif_INH_Sen_NumDx_U15+Rif_INH_Sen_NumNoDx_U15;
TB_NumConfRifSen_INHSen{TB_Adult,I}  = Rif_INH_Sen_NumDx_15Plus+Rif_INH_Sen_NumNoDx_15Plus;

TB_NumConfRifSen_INHMDR{TB_Child,I}  = Rif_INH_Res_NumDx_U15;
TB_NumConfRifSen_INHMDR{TB_Adult,I}  = Rif_INH_Res_NumDx_15Plus;

TB_NumConfRIFMDR{TB_Child,I}  = Rif_INH_Res_NumDx_U15;
TB_NumConfRIFMDR{TB_Adult,I}  = Rif_INH_Res_NumDx_15Plus;

TB_NumConfRIFMDR_FQSen{TB_Child,I} = RR_FQ_Sen_NumDx_U15+RR_FQ_Sen_NumNoDx_U15;
TB_NumConfRIFMDR_FQSen{TB_Adult,I}  = RR_FQ_Sen_NumDx_15Plus+RR_FQ_Sen_NumNoDx_15Plus;

TB_NumConfRIFMDR_FQMDR{TB_Child,I} = Rif_FQ_Res_NumDx_U15;
TB_NumConfRIFMDR_FQMDR{TB_Adult,I}  = Rif_FQ_Res_NumDx_15Plus;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Tx_PopsU15{I}.FQ_S_BPALM=TB_NumConfRIFMDR_FQSen{TB_Child,I}*NOTI.U15_FQS_reg1_new;
Tx_PopsU15{I}.FQ_S_ShortBDQ=TB_NumConfRIFMDR_FQSen{TB_Child,I}*NOTI.U15_FQS_reg2_new;
Tx_PopsU15{I}.FQ_R_BPAL=TB_NumConfRIFMDR_FQMDR{TB_Child,I}*NOTI.U15_FQR_reg1_new;
Tx_PopsU15{I}.FQ_R_LongDel=TB_NumConfRIFMDR_FQMDR{TB_Child,I}*NOTI.U15_FQR_reg2_new;
Tx_PopsU15{I}.INH_S_2HRZE4HR=TB_NumConfRifSen_INHSen{TB_Child,I}*NOTI.U15_InhS_reg1_new;
Tx_PopsU15{I}.INH_S_6HRZEto=TB_NumConfRifSen_INHSen{TB_Child,I}*NOTI.U15_InhS_reg2_new;
Tx_PopsU15{I}.INH_S_2HRZHR=TB_NumConfRifSen_INHSen{TB_Child,I}*NOTI.U15_InhS_reg3_new;
Tx_PopsU15{I}.INH_R_6HREZLfx=TB_NumConfRifSen_INHMDR{TB_Child,I};%*NOTI.U15_InhR_new;

Tx_PopsP15{I}.FQ_S_BPALM=TB_NumConfRIFMDR_FQSen{TB_Adult,I}*NOTI.P15_FQS_reg1_new;
Tx_PopsP15{I}.FQ_S_ShortBDQ=TB_NumConfRIFMDR_FQSen{TB_Adult,I}*NOTI.P15_FQS_reg2_new;
Tx_PopsP15{I}.FQ_R_BPAL=TB_NumConfRIFMDR_FQMDR{TB_Adult,I}*NOTI.P15_FQR_reg1_new;
Tx_PopsP15{I}.FQ_R_LongDel=TB_NumConfRIFMDR_FQMDR{TB_Adult,I}*NOTI.P15_FQR_reg2_new;
Tx_PopsP15{I}.INH_S_2HRZE=TB_NumConfRifSen_INHSen{TB_Adult,I}*NOTI.P15_InhS_reg1_new;
Tx_PopsP15{I}.INH_S_RPTMOX=TB_NumConfRifSen_INHSen{TB_Adult,I}*NOTI.P15_InhS_reg2_new;
Tx_PopsP15{I}.INH_R_6HREZLfx=TB_NumConfRifSen_INHMDR{TB_Adult,I};%*NOTI.P15_InhR_new;



% Tx_PopsU15{I}.Rif_INH_Sen_NumDx_U15=Rif_INH_Sen_NumDx_U15;
% Tx_PopsU15{I}.Rif_INH_Sen_NumNoDx_U15=Rif_INH_Sen_NumNoDx_U15;
% Tx_PopsU15{I}.PropWith_RRDST=Rif_INH_Sen_NumDx_U15/(Rif_INH_Sen_NumDx_U15+Rif_INH_Sen_NumNoDx_U15);
% x1=Tx_PopsU15{I}.PropWith_RRDST

% x=[];
% x.P15_ResisProfileNew=NOTI.P15_ResisProfileNew;
% x.P15_RifR_new=NOTI.P15_RifR_new;
% x.P15_FQS_new=NOTI.P15_FQS_new;
% x.P15_FQS_reg1_new=NOTI.P15_FQS_reg1_new;
% x.P15_FQS_reg2_new=NOTI.P15_FQS_reg2_new;
% x.P15_FQR_new=NOTI.P15_FQR_new;
% x.P15_FQR_reg1_new=NOTI.P15_FQR_reg1_new;
% x.P15_FQR_reg2_new=NOTI.P15_FQR_reg2_new;
% x.P15_RifS_new=NOTI.P15_RifS_new;
% x.P15_InhS_new=NOTI.P15_InhS_new;
% x.P15_InhS_reg1_new=NOTI.P15_InhS_reg1_new;
% x.P15_InhS_reg2_new=NOTI.P15_InhS_reg2_new;
% x.P15_InhR_new=NOTI.P15_InhR_new;
% 
% x
% 
% 
% y=0;
% y=y+NOTI.P15_FQS_reg1_new;
% y=y+NOTI.P15_FQS_reg2_new;
% y=y+NOTI.P15_FQR_reg1_new;
% y=y+NOTI.P15_FQR_reg2_new;
% y=y+NOTI.P15_InhS_reg1_new;
% y=y+NOTI.P15_InhS_reg2_new;
% y=y+NOTI.U15_InhR_new;
% 
% y
% pause

% Tx_PopsP15{I}.FQ_S_BPALM=TB_NumConfRIFMDR_FQSen{TB_Adult,I}*NOTI.P15_FQS_reg1_new;
% Tx_PopsP15{I}.FQ_S_ShortBDQ=TB_NumConfRIFMDR_FQSen{TB_Adult,I}*NOTI.P15_FQS_reg2_new;
% Tx_PopsP15{I}.FQ_R_BPAL=TB_NumConfRIFMDR_FQMDR{TB_Adult,I}*NOTI.P15_FQR_reg1_new;
% Tx_PopsP15{I}.FQ_R_LongDel=TB_NumConfRIFMDR_FQMDR{TB_Adult,I}*NOTI.P15_FQR_reg2_new;
% Tx_PopsP15{I}.INH_S_2HRZE=TB_NumConfRifSen_INHSen{TB_Adult,I}*NOTI.P15_InhS_reg1_new;
% Tx_PopsP15{I}.INH_S_RPTMOX=TB_NumConfRifSen_INHSen{TB_Adult,I}*NOTI.P15_InhS_reg2_new;
% Tx_PopsP15{I}.INH_R_6HREZLfx=TB_NumConfRifSen_INHMDR{TB_Adult,I};%*NOTI.P15_InhR_new;
% Tx_PopsP15{I}.Rif_INH_Sen_NumDx_15Plus=Rif_INH_Sen_NumDx_15Plus;
% Tx_PopsP15{I}.Rif_INH_Sen_NumNoDx_15Plus=Rif_INH_Sen_NumNoDx_15Plus;
% Tx_PopsU15{I}.PropWith_RRDST=Rif_INH_Sen_NumDx_15Plus/(Rif_INH_Sen_NumDx_15Plus+Rif_INH_Sen_NumNoDx_15Plus);
% x2=Tx_PopsU15{I}.PropWith_RRDST

% DST_Pops.DST_Conf_RifR=Tx_PopsU15{I}.FQ_S_BPALM+Tx_PopsU15{I}.FQ_S_ShortBDQ+Tx_PopsU15{I}.FQ_R_BPAL+Tx_PopsU15{I}.FQ_R_LongDel + ...
%                        Tx_PopsP15{I}.FQ_S_BPALM+Tx_PopsP15{I}.FQ_S_ShortBDQ+Tx_PopsP15{I}.FQ_R_BPAL+Tx_PopsP15{I}.FQ_R_LongDel;
%  
% DST_Pops.DST_Conf_RifS=Tx_PopsU15{I}.INH_S_2HRZE4HR+Tx_PopsU15{I}.INH_S_6HRZEto+Tx_PopsU15{I}.INH_S_2HRZHR+Tx_PopsU15{I}.INH_R_6HREZLfx + ...
%                        Tx_PopsP15{I}.INH_S_2HRZE+Tx_PopsP15{I}.INH_S_RPTMOX+Tx_PopsP15{I}.INH_R_6HREZLfx;
%               
%               
end

% Tx_PopsU15{TB_PTB}
% Tx_PopsU15{TB_ETB}
% 
% Tx_PopsP15{TB_PTB}
% Tx_PopsP15{TB_ETB}
% 
% pause


% TB_PTB = 1;
% TB_ETB = 2;

% Tx_PopsU15.FQ_S_BPALM{TB_PTB}=TB_NumConfRIFMDR_FQSen{TB_Child,TB_PTB}*NOTI.U15_FQS_reg1_new;
% Tx_PopsU15.FQ_S_ShortBDQ=TB_NumConfRIFMDR_FQSen{TB_Child}*NOTI.U15_FQS_reg2_new;
% Tx_PopsU15.FQ_R_BPAL=TB_NumConfRIFMDR_FQMDR{TB_Child}*NOTI.U15_FQR_reg1_new;
% Tx_PopsU15.FQ_R_LongDel=TB_NumConfRIFMDR_FQMDR{TB_Child}*NOTI.U15_FQR_reg2_new;
% Tx_PopsU15.FQ_INH_S_2HRZE4HR=TB_NumConfRifSen_INHSen{TB_Child}*NOTI.U15_InhS_reg1_new;
% Tx_PopsU15.FQ_INH_S_6HRZEto=TB_NumConfRifSen_INHSen{TB_Child}*NOTI.U15_InhS_reg2_new;
% Tx_PopsU15.FQ_INH_S_2HRZHR=TB_NumConfRifSen_INHSen{TB_Child}*NOTI.U15_InhS_reg3_new;
% Tx_PopsU15.FQ_INH_R_6HREZLfx=TB_NumConfRifSen_INHMDR{TB_Child}*NOTI.U15_InhR_new;
% 
% Tx_PopsP15.FQ_S_BPALM=TB_NumConfRIFMDR_FQSen{TB_Adult}*NOTI.P15_FQS_reg1_new;
% Tx_PopsP15.FQ_S_ShortBDQ=TB_NumConfRIFMDR_FQSen{TB_Adult}*NOTI.P15_FQS_reg2_new;
% Tx_PopsP15.FQ_R_BPAL=TB_NumConfRIFMDR_FQMDR{TB_Adult}*NOTI.P15_FQR_reg1_new;
% Tx_PopsP15.FQ_R_LongDel=TB_NumConfRIFMDR_FQMDR{TB_Adult}*NOTI.P15_FQR_reg2_new;
% Tx_PopsP15.FQ_INH_S_2HRZE=TB_NumConfRifSen_INHSen{TB_Adult}*NOTI.P15_InhS_reg1_new;
% Tx_PopsP15.FQ_INH_S_RPTMOX=TB_NumConfRifSen_INHSen{TB_Adult}*NOTI.P15_InhS_reg2_new;
% Tx_PopsP15.FQ_INH_R_6HREZLfx=TB_NumConfRifSen_INHMDR{TB_Adult}*NOTI.U15_InhR_new;


total_treat=0;
total_treat=total_treat+...
TB_NumConfRifSen_INHSen{TB_Child}+...
TB_NumConfRifSen_INHSen{TB_Adult}+...
TB_NumConfRifSen_INHMDR{TB_Child}+...
TB_NumConfRifSen_INHMDR{TB_Adult}+...
TB_NumConfRIFMDR{TB_Child}+...
TB_NumConfRIFMDR{TB_Adult}+...
TB_NumConfRIFMDR_FQSen{TB_Child}+...
TB_NumConfRIFMDR_FQSen{TB_Adult}+...
TB_NumConfRIFMDR_FQMDR{TB_Child}+...
TB_NumConfRIFMDR_FQMDR{TB_Adult};

end


function [Hd,Hi,Hd_ByCat,Hi_ByCat,total_PrevTB,total_Dx,total_PrevTB_ByCat,total_Dx_ByCat,total_pop_eligibleTPT_denom]=CalcHazardRates(HH_Contacts, ART_Cohorts, HR_Groups, PatientInitiated, NOTI, totalTPTDenom)
% Calc 'hazard' of being detected and then 'hazard' of receiving TPT or of
% 'infection'
yr_len=length(NOTI.years);
total_pop=DP_pop_15Plus*(ones(1,14));

%total
PrevTB         = zeros(1,yr_len);
HighRiskPop    = zeros(1,yr_len);
total_PrevTB   = zeros(1,yr_len);
total_HRPrevTB = zeros(1,yr_len);
total_Dx       = zeros(1,yr_len);
Hd             = zeros(1,yr_len);
Hi             = zeros(1,yr_len);

%by age and HIV: 1=HIV-neg 0-14, 2=HIV-pos 15p, 3=HIV-neg 0-14, 4=HIV-pos 15p
PrevTB_ByCat         = zeros(4,yr_len);
HighRiskPop_ByCat    = zeros(4,yr_len);
total_PrevTB_ByCat   = zeros(4,yr_len);
total_HRPrevTB_ByCat = zeros(4,yr_len);
total_Dx_ByCat       = zeros(4,yr_len);
Hd_ByCat             = zeros(4,yr_len);
Hi_ByCat             = zeros(4,yr_len);

%HH contacts
for p=1:size(HH_Contacts,1)
acf_pop=HH_Contacts{p};
%acf_pop.TB
%acf_pop.TP_diag

if(acf_pop.GroupID==TB_HH0_4_grp),groupID=1;end;
if(acf_pop.GroupID==TB_HH5_14_grp),groupID=1;end;
if(acf_pop.GroupID==TB_HH15p_grp),groupID=2;end;

    if max(acf_pop.NumScreened)>0        
        total_PrevTB=total_PrevTB+acf_pop.TB;
        total_HRPrevTB=total_HRPrevTB+acf_pop.TB;
        total_Dx=total_Dx+acf_pop.TP_diag+acf_pop.FP_diag;
        
        total_PrevTB_ByCat(groupID,:)=total_PrevTB_ByCat(groupID,:)+acf_pop.TB;
        total_HRPrevTB_ByCat(groupID,:)=total_HRPrevTB_ByCat(groupID,:)+acf_pop.TB;
        total_Dx_ByCat(groupID,:)=total_Dx_ByCat(groupID,:)+acf_pop.TP_diag+acf_pop.FP_diag; 
    end
    
end

 
%PLHIV on ART
for sv  = [1:TB_ARTSevereLen]
for age = [1:TB_ARTAgeLen] 
acf_pop=ART_Cohorts{sv,age};
%acf_pop.TB
%acf_pop.TP_diag

if(acf_pop.GroupID==TB_ARTNotServere_0_9_grp),groupID=3;end;
if(acf_pop.GroupID==TB_ARTNotServere_10_14_grp),groupID=3;end;
if(acf_pop.GroupID==TB_ARTNotServere15p_grp),groupID=4;end;

if(acf_pop.GroupID==TB_ARTSevereIllness_0_9_grp),groupID=3;end;
if(acf_pop.GroupID==TB_ARTSevereIllness_10_14_grp),groupID=3;end;
if(acf_pop.GroupID==TB_ARTSevereIllness15p_grp),groupID=4;end;

    if max(acf_pop.NumScreened)>0
        total_PrevTB=total_PrevTB+acf_pop.TB;
        total_HRPrevTB=total_HRPrevTB+acf_pop.TB;
        total_Dx=total_Dx+acf_pop.TP_diag+acf_pop.FP_diag;

        total_PrevTB_ByCat(groupID,:)=total_PrevTB_ByCat(groupID,:)+acf_pop.TB;
        total_HRPrevTB_ByCat(groupID,:)=total_HRPrevTB_ByCat(groupID,:)+acf_pop.TB;
        total_Dx_ByCat(groupID,:)=total_Dx_ByCat(groupID,:)+acf_pop.TP_diag;    
    end
end
end

%High risk groups
for p=1:size(HR_Groups,1)
acf_pop=HR_Groups{p};
%acf_pop.TB
%acf_pop.TP_diag
if(acf_pop.GroupID==TB_HRG_HighTBPrev_grp ),groupID=2;end;

    if max(acf_pop.NumScreened)>0
        total_PrevTB=total_PrevTB+acf_pop.TB;
        total_HRPrevTB=total_HRPrevTB+acf_pop.TB;
        total_Dx=total_Dx+acf_pop.TP_diag+acf_pop.FP_diag;

        total_PrevTB_ByCat(groupID,:)=total_PrevTB_ByCat(groupID,:)+acf_pop.TB;
        total_HRPrevTB_ByCat(groupID,:)=total_HRPrevTB_ByCat(groupID,:)+acf_pop.TB;
        total_Dx_ByCat(groupID,:)=total_Dx_ByCat(groupID,:)+acf_pop.TP_diag;    
    end
        
end


%Patient initiated
for p=1:size(PatientInitiated,2)   
pi_pop=PatientInitiated{p};
%pi_pop.TB
%pi_pop.TP_diag

if(pi_pop.GroupID==TB_PTB_HIVn_014_grp ),groupID=1;end;
if(pi_pop.GroupID==TB_PTB_HIVn_15p_grp ),groupID=2;end;
if(pi_pop.GroupID==TB_PTB_HIVp_09_grp ),groupID=3;end;
if(pi_pop.GroupID==TB_PTB_HIVp_1014_grp ),groupID=3;end;
if(pi_pop.GroupID==TB_PTB_HIVp_15p_grp ),groupID=4;end;
if(pi_pop.GroupID==TB_ETB_HIVn_014_grp ),groupID=1;end;
if(pi_pop.GroupID==TB_ETB_HIVn_15p_grp ),groupID=2;end;
if(pi_pop.GroupID==TB_ETB_HIVp_09_grp ),groupID=3;end;
if(pi_pop.GroupID==TB_ETB_HIVp_1014_grp ),groupID=3;end;
if(pi_pop.GroupID==TB_ETB_HIVp_15p_grp ),groupID=4;end;

    if max(pi_pop.NumScreened)>0
        total_PrevTB=total_PrevTB+pi_pop.TB;
        total_Dx=total_Dx+pi_pop.TP_diag+pi_pop.FP_diag;
        
        total_PrevTB_ByCat(groupID,:)=total_PrevTB_ByCat(groupID,:)+pi_pop.TB;
        total_Dx_ByCat(groupID,:)=total_Dx_ByCat(groupID,:)+pi_pop.TP_diag+pi_pop.FP_diag;   
    end
end


%probability of being detected out of prevalence cases 
if(max(total_PrevTB)>0)
    Hd=total_Dx./total_pop;
    Hd_ByCat=total_Dx_ByCat./total_PrevTB_ByCat;
end


%Hazard for TPT
if(~max(total_HRPrevTB)>0)
    return
end

RelRisk=2;
total_pop_eligibleTPT=0;
for p=1:size(HH_Contacts,1)
acf_pop=HH_Contacts{p};
if max(acf_pop.InitiatedTPT)>0
    total_pop_eligibleTPT=total_pop_eligibleTPT+(acf_pop.NumScreened-acf_pop.NumDiagnosed);
end
end

for sv  = [1:TB_ARTSevereLen]
for age = [1:TB_ARTAgeLen]   
    acf_pop=ART_Cohorts{sv,age};
    if max(acf_pop.InitiatedTPT)>0
        total_pop_eligibleTPT=total_pop_eligibleTPT+(acf_pop.NumScreened-acf_pop.NumDiagnosed);
    end
end
end

for p=1:size(HR_Groups,1)
acf_pop=HR_Groups{p};
if max(acf_pop.InitiatedTPT)>0
    total_pop_eligibleTPT=total_pop_eligibleTPT+(acf_pop.NumScreened-acf_pop.NumDiagnosed);
end  
end

total_pop_eligibleTPT_denom=total_pop_eligibleTPT;
if(~isempty(totalTPTDenom))
    total_pop_eligibleTPT_denom=totalTPTDenom;
end

InitiatedTPT_total=0;
for p=1:size(HH_Contacts,1)
    acf_pop=HH_Contacts{p};
    
    if(acf_pop.GroupID==TB_HH0_4_grp),groupID=1;end;
    if(acf_pop.GroupID==TB_HH5_14_grp),groupID=1;end;
    if(acf_pop.GroupID==TB_HH15p_grp),groupID=2;end;
    
    if max(acf_pop.InitiatedTPT)>0
        PrevTB=acf_pop.TB;
        HighRiskPop=acf_pop.pop;
        InitiatedTPT=acf_pop.InitiatedTPT;
        InitiatedTPT_total=InitiatedTPT_total+InitiatedTPT;
        prob_protect=RelRisk*0.7*ones(1,yr_len);
        %prob_protect=prob_protect .* (InitiatedTPT./total_pop);
        %Hi=Hi+prob_protect.*(InitiatedTPT./total_pop_eligibleTPT_denom);
        Hi=Hi+prob_protect.*(InitiatedTPT./total_pop);
       
        %Hi=Hi+prob_protect.*(PrevTB./total_HRPrevTB);
        Hi_ByCat(groupID,:)=Hi_ByCat(groupID,:)+prob_protect.*(PrevTB./total_PrevTB_ByCat(groupID,:));
        %Hi_ByCat(groupID,:)=Hi_ByCat(groupID,:)+prob_protect.*(PrevTB./total_PrevTB_ByCat(groupID,:));
     end
end


for sv  = [1:TB_ARTSevereLen]
for age = [1:TB_ARTAgeLen]   
    acf_pop=ART_Cohorts{sv,age};
    
    if(acf_pop.GroupID==TB_ARTNotServere_0_9_grp),groupID=3;end;
    if(acf_pop.GroupID==TB_ARTNotServere_10_14_grp),groupID=3;end;
    if(acf_pop.GroupID==TB_ARTNotServere15p_grp),groupID=4;end;

    if(acf_pop.GroupID==TB_ARTSevereIllness_0_9_grp),groupID=3;end;
    if(acf_pop.GroupID==TB_ARTSevereIllness_10_14_grp),groupID=3;end;
    if(acf_pop.GroupID==TB_ARTSevereIllness15p_grp),groupID=4;end;

    if max(acf_pop.InitiatedTPT)>0
        PrevTB=acf_pop.TB;
        HighRiskPop=acf_pop.pop;
        InitiatedTPT=acf_pop.InitiatedTPT;
        InitiatedTPT_total=InitiatedTPT_total+InitiatedTPT;
        prob_protect=RelRisk*0.7*ones(1,yr_len);
        %Hi=Hi+prob_protect.*(InitiatedTPT./total_pop_eligibleTPT_denom);
        Hi=Hi+prob_protect.*(InitiatedTPT./total_pop);
        %probprotect=prob_protect .* (InitiatedTPT./EligibleTPTEval);
        %Hi=Hi+prob_protect.*(PrevTB./total_HRPrevTB);
        Hi_ByCat(groupID,:)=Hi_ByCat(groupID,:)+prob_protect.*(PrevTB./total_PrevTB_ByCat(groupID,:));
    end
end
end

for p=1:size(HR_Groups,1)
acf_pop=HR_Groups{p};
if(acf_pop.GroupID==TB_HRG_HighTBPrev_grp ),groupID=2;end;

    if max(acf_pop.InitiatedTPT)>0
        PrevTB=acf_pop.TB;
        HighRiskPop=acf_pop.pop;
        InitiatedTPT=acf_pop.InitiatedTPT;
        InitiatedTPT_total=InitiatedTPT_total+InitiatedTPT;
        prob_protect=RelRisk*0.7*ones(1,yr_len);
        %Hi=Hi+prob_protect.*(InitiatedTPT./total_pop_eligibleTPT_denom); 
        Hi=Hi+prob_protect.*(InitiatedTPT./total_pop);
        %prob_protect=prob_protect .* (InitiatedTPT./HighRiskPop);
        %Hi=Hi+prob_protect.*(PrevTB./total_HRPrevTB);
        Hi_ByCat(groupID,:)=Hi_ByCat(groupID,:)+prob_protect.*(PrevTB./total_PrevTB_ByCat(groupID,:));
    end
end


end


function [resultPop]=aggregateTargetValues(targetPopList)
resultPop =0;
for k=1:length(targetPopList)
    resultPop=resultPop+targetPopList{k}.NumDiagnosed;
end

end

function [resultPop]=aggregateTargetValuesDx(targetPopList)
resultPop =0;
for k=1:length(targetPopList)
    resultPop=resultPop+targetPopList{k}.NumDiagnosed;
    grp=targetPopList{k}.GroupID;
%     x=targetPopList{k}
%     x=targetPopList{k}.NumScreened
%     pause
    DxByGrp(grp,:)=DxByGrp(grp,:)+targetPopList{k}.NumDiagnosed;
end

end



function [resultPop]=aggregateTargetValuesDxRef(targetPopList)
resultPop =0;
for k=1:length(targetPopList)
    resultPop=resultPop+targetPopList{k}.ReferredDxTB;
    grp=targetPopList{k}.GroupID;
    DxRefByGrp(grp,:)=DxRefByGrp(grp,:)+targetPopList{k}.ReferredDxTB;
end
end

function [resultPop]=aggregateTargetValuesScr(targetPopList)
resultPop =0;
for k=1:length(targetPopList)
    %targetPopList{k}
    resultPop=resultPop+targetPopList{k}.NumScreened;
    grp=targetPopList{k}.GroupID;
    ScrByGrp(grp,:)=ScrByGrp(grp,:)+targetPopList{k}.NumScreened;
end
end

% function [resultPop]=aggregateTargetValues(targetPopList)
% resultPop =0;
% 
% for k=1:length(targetPopList)
%     resultPop=resultPop+targetPopList{k}.NumDiagnosed;
%     grp=targetPopList{k}.GroupID;
%     DxByGrp(grp,:)=DxByGrp(grp,:)+targetPopList{k}.NumDiagnosed;
% end
% 
% 
% end


function [resultPop]=aggregateTargetValuesTPTScreened(targetPopList)
resultPop =0;
for k=1:length(targetPopList)
    resultPop=resultPop+targetPopList{k}.NumDiagnosed;
    %grp=targetPopList{k}.GroupID;
    %DxByGrp(grp,:)=DxByGrp(grp,:)+targetPopList{k}.Presumptive+targetPopList{k}.EligibleLTBItested;
end


end

function [resultPop]=aggregateTargetValuesTPTTx(targetPopList)
resultPop =0;

for k=1:length(targetPopList)
    resultPop=resultPop+targetPopList{k}.InitiatedTPT;
    %grp=targetPopList{k}.GroupID;
    %DxByGrp(grp,:)=DxByGrp(grp,:)+targetPopList{k}.NumDiagnosed;
end


end

function [resultPop]=aggregateTargetValuesLTBIDx(targetPopList)
resultPop =0;

for k=1:length(targetPopList)
    resultPop=resultPop+targetPopList{k}.EligibleLTBItested;
    grp=targetPopList{k}.GroupID;
    TPTDxByGrp(grp,:)=TPTDxByGrp(grp,:)+targetPopList{k}.EligibleLTBItested;
end


end



function [OutStruct] = RemoveNanfromFields(InStruct)
OutStruct=InStruct;
fn = fieldnames(OutStruct);
for k=1:numel(fn)
    if( isnan(OutStruct.(fn{k})) )
        OutStruct.(fn{k})=zeros(size(OutStruct.(fn{k})));
    end
end    
end



    
end




