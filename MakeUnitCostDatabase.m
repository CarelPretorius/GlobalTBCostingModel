function [UC_RES]=MakeUnitCostDatabase(do_USD)

CPI_USD=[1, 1.8, 0.9, 1.2, 1.9, 2.2, 2.3, 2.3, 2.3, 2.3, 2.3, 2.3, 2.3];
USD_INFL=1.785151537*ones(size(CPI_USD));
USD_INFL(1)=2.400981114;

path='C:\work\GlobalModel\ScenarioModel\';
fname=[path,'TGFCostingModel_ImplementationV2f.xlsx'];

[~,~,WB_data]=xlsread(fname,'WBData','A1:AR276');%WB_Data
[~,~,Country_Map]=xlsread(fname,'ValueTBCountryMap','D2:M171');
[~,~,UC_defs]=xlsread(fname,'InterventionAndUnitCostList2','A1:T98');
[~,~,VTB_data]=xlsread(fname,'ValueTBData','A1:BL282');

[~,~,UC_List]=xlsread(fname,'InterventionAndUnitCostList2','A4:A100');
[~,~,WHO_OP_Data]=xlsread(fname,'OP_Visit_WHO');
[~,~,StaffCosts_Data]=xlsread(fname,'StaffCostsperGDPperCapUSD');


for I=1:size(UC_List,1)
    if(isnan(UC_List{I,1})),UC_List{I,1}=-1;end;
end

UC_List=cell2mat(UC_List(:,1));
ind=find(UC_List(:)>0);

%List of interventions used in TP mapping
UC_codes=unique(UC_List(ind,1))

%Value TB countries
VTB=[];
VTB{1,1}='PHL';
VTB{2,1}='KEN';
VTB{3,1}='ETH';
VTB{4,1}='GEO';
VTB{5,1}='IND';

%Map to UC
VTB{1,2}=8;
VTB{2,2}=9;
VTB{3,2}=10;
VTB{4,2}=11;
VTB{5,2}=12;

VTB{1,3}=13;
VTB{2,3}=14;
VTB{3,3}=15;
VTB{4,3}=16;
VTB{5,3}=17;

Intv_num=54;
years=2018:2035;

num_countries=[1:size(Country_Map,1) ]
uc_num=0;
uc_row=0;
UC_RES=[];
for I=num_countries
    
    iso3=Country_Map{I,1}
    
    %test country
    %if(~strcmp(iso3,'ALB')),continue; end;
    
    %skip VEN
    if(strcmp(iso3,'VEN')),continue; end;
    
    
    iso3_vtb=Country_Map{I,10};
    %vtb_n=find(strcmp(iso3_vtb,VTB(:,1)));
    UC=[];
    UC_test_list=[1:20,21:24,25:31,32:41,42:50,51:59,60:67,68:69,70:73,74,75];%full list
    for J=[1:length(UC_codes)]

      
        iso3_vtb=Country_Map{I,10};
        vtb_n=find(strcmp(iso3_vtb,VTB(:,1)));
        
        %vtb_s=UC_defs{J+3,vtb_n+8-1};
        %if(isempty(vtb_s)),continue;end;   
            
        
        %if(strcmp(iso3_vtb_2,iso3_vtb)==0),
        %    iso3_vtb=iso3_vtb_2;
            %vtb_n=find(strcmp(iso3_vtb,VTB(:,1)));
        %end
                
        intv_code=UC_codes(J);
        if(~ismember(intv_code,UC_test_list)),continue,end
        
        %Find value TB entry in UC def sheet
        intv_row=5;
        for JJ=1:size(UC_defs,1)
            if(intv_code==UC_defs{JJ,1})
             intv_row=JJ;
             break;
            end;       
        end  
        
        input_type=UC_defs{intv_row,7};
        vtb_map=UC_defs{intv_row,VTB{vtb_n,2}};
        vtb_num=UC_defs{intv_row,VTB{vtb_n,3}};
        
        if(isempty(vtb_map)),continue;end;   
        
        add_consum=UC_defs{intv_row,18};
        if(isnan(add_consum)),add_consum=0;end;
        
        op_visit=UC_defs{intv_row,19};
        ip_visit=UC_defs{intv_row,20};

 
        %Find value TB data entry 
        vtb_row=-1;
        vtb_s0=[iso3_vtb,'_',num2str(vtb_num)];
        iso3_vtb_2=vtb_map(1:3);
        if(strcmp(iso3_vtb_2,iso3_vtb)==1)
        for JJ=1:size(VTB_data,1)
            if( strcmp(vtb_s0,VTB_data{JJ,64}) )
             vtb_row=JJ;
             break;
            end;
        end  
        end
        
        %not found with direct VTB mapping, look for second mapping
        if( (vtb_row==-1)&&(strcmp(input_type,'From Value TB')==1||strcmp(input_type,'Value TB')==1)) % not found and [from value TB]
        for JJ=1:size(VTB_data,1)
            if( strcmp(vtb_map,VTB_data{JJ,63}) )
                vtb_row=JJ;
                iso3_vtb=VTB_data{vtb_row,2};%map to possibly different VTB country
                break;
            end;
          
        end
        end
        
           
        %special mapping for OP visits
        if((vtb_num<0)&&(strcmp(op_visit,'Add OPD visit')==1)),
            vtb_row=54;
        end

        %special mapping for IP visits,
        if((vtb_num<0)&&(strcmp(ip_visit,'Add inpatient costs')==1)),
            vtb_row=54;
        end
        
        if(vtb_row>0)
            
            uc_num=uc_num+1;
            
            value_tb_data=VTB_data(vtb_row,:);
            vtb_dat.intv_s=value_tb_data{62};
            vtb_dat.Capital=value_tb_data{6};
            vtb_dat.Consumables=value_tb_data{13};
            vtb_dat.Overhead=value_tb_data{20};
            vtb_dat.Staff=value_tb_data{27};
            
            %vtb_dat
            
            %set UB struct
            UC.iso3=iso3;
            
            UC.years=years;
            
            UC.intv_code=intv_code;
            UC.intv_s=vtb_dat.intv_s;
            
            UC.iso3_vtb=iso3_vtb;
            UC.vtb_map=vtb_map;
            UC.vtb_num=vtb_num;
            
            UC.vtb_dat=vtb_dat;
            UC.input_type=input_type;
            
            UC.add_consum=add_consum;
             
              
            %find WB data of value TB country
            ind=find(strcmp(WB_data(:,2),iso3_vtb));
            wb_data=WB_data(ind,:);
            ER_2018_vtb=cell2mat(wb_data(4:8));  % official exchnage rate 
            %ER_2018_vtb=cell2mat(wb_data(34:38)); % exchange rate GDD LC / GDP USD
            ind1=find(ER_2018_vtb>0);
            ind2=find(ER_2018_vtb==0);
            ER_2018_vtb(ind2)=mean(ER_2018_vtb(ind1));
            PPP_2018_vtb=cell2mat(wb_data(22:26));     
            
            %find WB data of country
            ind=find(strcmp(WB_data(:,2),iso3));
            wb_data=WB_data(ind,:);
            ER_2018=cell2mat(wb_data(4:8));  % official exchnage rate 
            %ER_2018_2=cell2mat(wb_data(4:8)); % exchange rate GDD LC / GDP USD
            %ER_2018=cell2mat(wb_data(34:38)); % exchange rate GDD LC / GDP USD
            PPP_2018=cell2mat(wb_data(22:26));
            
            %if(strcmp(iso3,'AGO')||strcmp(iso3,'ZWE')||strcmp(iso3,'COD')||strcmp(iso3,'SDN')||strcmp(iso3,'ARG'))
            %    ER_2018=ER_2018_2;  
            %end 
                      
            ind1=find(ER_2018>0);
            ind2=find(ER_2018==0);
            if(~isempty(ind2)), 
                ER_2018
                pause
            end
            ER_2018(ind2)=mean(ER_2018(ind1));
            
            INFL_2018=cell2mat(wb_data(28:32));
            
  
            IsLumpsum=0;
            DirectInput=0;
            %other types of direct input
            if(strcmp(input_type,'From Value TB')==1),
                IsLumpsum=1;
                DirectInput=1;
                %convert to LC, except for GEO and PHL
                Curr_convert=ER_2018_vtb(1);%vtb convert to USD
                %GEO and PHL LC conversion done below
                %if(strcmp(iso3_vtb,'GEO')==1),Curr_convert=1;end
                %if(strcmp(iso3_vtb,'PHL')==1),Curr_convert=1;end
                vtb_dat.Consumables=add_consum*Curr_convert;
                %update only the consumable component of the UC, use vtb
                %for the other components 
                %vtb_dat.Capital=0;
                %vtb_dat.Overhead=0;
                %vtb_dat.Staff=0;
            end
            
             
            %direct input, e.g. from GDF
            if( (strcmp(input_type,'Input')==1)||(strcmp(input_type,'Input (GDF)')==1) ),
            %if( (strcmp(input_type,'Input (GDF)')==1) ),
                IsLumpsum=1;
                DirectInput=1;
                Curr_convert=ER_2018_vtb(1);%vtb convert from USD to VTB currency
                %GEO and PHL LC conversion done below
                %if(~DirectInput)%adjust only VTB consumable inputs
                %if(strcmp(iso3_vtb,'GEO')==1),Curr_convert=1;end
                %if(strcmp(iso3_vtb,'PHL')==1),Curr_convert=1;end
                %end
                vtb_dat.Consumables=add_consum*Curr_convert;
                vtb_dat.Capital=0;
                vtb_dat.Overhead=0;
                vtb_dat.Staff=0;
            end
            
%             %other types of direct input
%             if(strcmp(input_type,'Input')==1),
%                 IsLumpsum=1;
%             end
            
            %OPD and In-patient data    
            add_op_visit=0;
            UC.add_ip_visit='FALSE';
            %Add OPD to Clinical assessment
            if(strcmp(op_visit,'Add OPD visit')==1),
                add_op_visit=1;
                UC.add_op_visit='TRUE';
            end

            add_ip_visit=0;
            UC.add_op_visit='FALSE';
            %Add Inpatient to Inpatient interventions
            if(strcmp(ip_visit,'Add inpatient costs')==1),
                add_ip_visit=1;
                UC.add_ip_visit='TRUE';
            end
            
            %OP costs
            %OP data. Local currency of GP country
            ind=find(strcmp(WHO_OP_Data(:,2),iso3));
            op_visit_cost_LC=cell2mat(WHO_OP_Data(ind,4));
            ip_day_cost_LC=cell2mat(WHO_OP_Data(ind,9));
            
            
            %Staff Costs per year, fraction of GDP per cap, vtb ref country
            ind_st=find(strcmp(StaffCosts_Data(:,2),iso3_vtb));
            staff_data_vtb=StaffCosts_Data(ind_st,:);
            StaffCostPerYearUSD_S1_vtb=cell2mat(staff_data_vtb(10));%physicians
            StaffCostPerYearUSD_S2_vtb=cell2mat(staff_data_vtb(11));%nurses
            StaffCostPerYearUSD_S3_vtb=cell2mat(staff_data_vtb(12));%other
           
            
            %Staff Costs per year, fraction of GDP per cap, for country
            ind_st=find(strcmp(StaffCosts_Data(:,2),iso3));
            staff_data=StaffCosts_Data(ind_st,:);
            StaffCostPerYearUSD_S1=cell2mat(staff_data(10));%physicians
            StaffCostPerYearUSD_S2=cell2mat(staff_data(11));%nurses
            StaffCostPerYearUSD_S3=cell2mat(staff_data(12));%other
           

            tradable_goods=(vtb_dat.Consumables);
            staff_costs=vtb_dat.Staff;
            staff_costs_LC=(vtb_dat.Staff)*(ER_2018(1)/ER_2018_vtb(1))*(StaffCostPerYearUSD_S2/StaffCostPerYearUSD_S1_vtb);
            non_tradable_goods=(vtb_dat.Capital+vtb_dat.Overhead);
            
            %Georgia in USD, convert to local currency of value TB
            %country
            if(strcmp(iso3_vtb,'GEO')==1),
                PPP_convert=PPP_2018_vtb(1);
                Curr_convert=ER_2018_vtb(1);
                if(~DirectInput)%adjust only VTB consumable inputs
                     tradable_goods=tradable_goods*Curr_convert;%PPP conversion to local currency
                end
                 non_tradable_goods=non_tradable_goods*PPP_convert;%ER conversion to local currency
               
            end
            
            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %All value TB UCs now in LC
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            
            %Add OP to non-tradable goods in LC
            if(add_op_visit==11)
                %op_visit_cost=op_visit_cost;%use WHO LC estimate for OP
                non_tradable_goods=non_tradable_goods+op_visit_cost_LC;
                tradable_goods=0;
            end

            if(add_ip_visit==11)
                %op_visit_cost=op_visit_cost;%use WHO LC estimate for OP
                non_tradable_goods=non_tradable_goods+ip_day_cost_LC;
                tradable_goods=0;
            end 
            
            
            %PHL data in 2017, need to inflate 1 year to 2018
            if(strcmp(iso3_vtb,'PHL')==1)
                infl_LC=2.32/100;
                infl_usd=1.88/100;

                non_tradable_goods=non_tradable_goods*(1+infl_LC);
                if(~DirectInput)%adjust only VTB consumable inputs
                    tradable_goods=tradable_goods*(1+infl_usd);
                end
            end

           %Staff time, based on GDP per cap 2018, USD
           %Based of physicians annual salary  
           %staffcosts=(vtb_dat.Staff/(StaffCostPerYearUSD_S1_vtb*ER_2018(1)) );
           %staffcosts=min(staffcosts,1);
           %staffcosts=staffcosts*StaffCostPerYearUSD_S1;
            
           
        
           %Non-Tradable Goods          
           %Apply PPP ratio to NT goods and add stafftime
           PPP_convert=PPP_2018(1)/PPP_2018_vtb(1);%vtb convert to LC
           %staffcosts=PPP_2018(1)*staffcosts;
           non_tradable_goods_LC=(non_tradable_goods)*PPP_convert+staff_costs_LC;
           UC_LC_NT(1)=non_tradable_goods_LC;
           Curr_convert=1/ER_2018(1);
           UC_USD_NT(1)=UC_LC_NT(1)*Curr_convert; 
  
           %extrapolate non-tradeble goods
           %inflate to 2022 using local gdp deflator 
           c=1;
           for t=2019:2022
               c=c+1;
               infl_LC=INFL_2018(2)/100;
               UC_LC_NT(c)=UC_LC_NT(c-1)*(1+infl_LC);
               Curr_convert=1/ER_2018(1);
               UC_USD_NT(c)=UC_LC_NT(c)*Curr_convert;       
           end
            
           %inflate to 2030 using usd gdp deflator 
           c=5;
           for t=2023:2035
           c=c+1;
           %infl_usd=USD_INFL(c)/100;
           infl_usd=0;%do inflation in the costing model 
           UC_USD_NT(c)=UC_USD_NT(c-1)*(1+infl_usd);
           end

           
           %Tradable Goods   
           %Apply ER to Tradable goods
           Curr_convert=1/ER_2018_vtb(1);%vtb convert to USD
           tradable_goods=tradable_goods*Curr_convert;
           UC_USD_T(1)=tradable_goods;
           
           Curr_convert=ER_2018(1);%vtb convert to USD
           UC_LC_T(1)=UC_USD_T(1)*Curr_convert;
           
           %extrapolate tradeble goods
           %inflate to 2022 using usd gdp deflator                 
           c=1;
           for t=2019:2022
               c=c+1;
               infl_usd=USD_INFL(2)/100;
               if(IsLumpsum==1),infl_usd=0;end%dont inflate direct consumable inputs
               UC_USD_T(c)=UC_USD_T(c-1)*(1+infl_usd);
               
               Curr_convert=ER_2018(t-2018+1);
               UC_LC_T(c)=UC_USD_T(c)*Curr_convert;
           end
           
            %inflate to 2030 using usd gdp deflator
            c=5;
            for t=2023:2035
               c=c+1;
               %infl_usd=USD_INFL(2)/100;
               infl_usd=0;%do inflation in the costing model 
               if(IsLumpsum==1),infl_usd=0;end%dont inflate direct consumable inputs
               UC_USD_T(c)=UC_USD_T(1)*(1+infl_usd);
            end
            
            %add trade + non-tradable
            c=0;
            for t=2018:2035
               c=c+1;
               if(t<=2022)  
                UC_LC(c)=UC_LC_T(c)+UC_LC_NT(c);%trade + non-trade
               end
               UC_USD(c)=UC_USD_T(c)+UC_USD_NT(c);%trade + non-trade
            end 
            
            
            
            UC.UC_USD_T=UC_USD_T;
            UC.UC_USD_NT=UC_USD_NT;
            UC.UC_LC_T=UC_LC_T;
            UC.UC_LC_NT=UC_LC_NT;
            
            UC.UC_LC=UC_LC;
            UC.UC_USD=UC_USD;
 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            uc_row=uc_row+1;
            
            UC_RES{uc_row,1}=iso3;
            UC_RES{uc_row,2}=iso3_vtb;
            UC_RES{uc_row,3}=intv_code;
            UC_RES{uc_row,4}=UC;
                          
        end
        
     
    end
   
      
end

    
    UC_RES
    uc_row
    
    delete UC_Res_Table.mat
    save UC_Res_Table.mat UC_RES
