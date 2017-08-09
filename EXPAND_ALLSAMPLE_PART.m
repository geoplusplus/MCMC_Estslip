function EXPAND_ALLSAMPLE_PART(DIR,burnin)
% function EXPAND_ALLSAMPLE(cha,burnin)
% burnin: enter for percent scale
[INPUT]=READ_CHAFILE(DIR);
[TCHA]=cal_avestdbin(INPUT,burnin);
WRITE_TCHA(TCHA,DIR)
end
%% Read all cha mat file
function [INPUT]=READ_CHAFILE(DIR)
EXT='CHA_test*.mat';
file=dir([DIR,'/',EXT]);
[Nit,~]=size(file);
for ii=1:Nit
  INPUT(ii).fname=fullfile(file(ii).folder,file(ii).name);
end
end
%%
function WRITE_TCHA(TCHA,DIR)
outfile=[DIR,'/TCHA.mat'];
save(outfile,'TCHA','-v7.3');
end
%% Calculate average, std, bin
function [TCHA]=cal_avestdbin(INPUT,burnin)
% load('./Result/Test_06/CHA_test.mat'); % test
NIT=size(INPUT,2);
Mpbin=[-1E-7:1E-10:1E-7];
Mcbin=[-1:0.001:1];
SMPINT=50; % sampling interval
BURNIN=floor(burnin*NIT/100)+1;
for ii=BURNIN:NIT
  load(INPUT(ii).fname);
  if ii==BURNIN
    NCH=size(cha.MpCOMPRESS.SMPMp,2);
    NPOL=length(cha.MpCOMPRESS.NPOL);
    NFLT=length(cha.McCOMPRESS.NFLT);
    SUMPOL=zeros(NPOL,1);
    SUMPOLPAIR=zeros(NPOL,NPOL);
    SUMFLT=zeros(NFLT,1);
    SUMFLTPAIR=zeros(NFLT,NFLT);
    NDATAPOL=zeros(NPOL,1);
    NDATAFLT=zeros(NFLT,1);
    %
    MpHIST=zeros(NPOL,size(Mpbin,2)-1);
    McHIST=zeros(NFLT,size(Mcbin,2)-1);
    SMPID=[1:SMPINT:NCH];
    smppol=zeros(NPOL,NCH);
    smpflt=zeros(NFLT,NCH);
    SMPPOL=[];
    SMPFLT=[];
  end
  for jj=1:NPOL
    infid=cha.MpCOMPRESS.NPOL(jj).Mpscale==Inf;
    if ~infid
      smppol(jj,:)=(double(cha.MpCOMPRESS.SMPMp(jj,:))+128)./(2.55.*cha.MpCOMPRESS.NPOL(jj).Mpscale)+cha.MpCOMPRESS.NPOL(jj).MpMIN;
      MpHIST(jj,:)=MpHIST(jj,:)+histcounts(smppol(jj,:),Mpbin);
      NDATAPOL(jj)=NDATAPOL(jj)+NCH;
    else
      smppol(jj,:)=ones(1,NCH).*cha.MpCOMPRESS.NPOL(jj).MpMAX;
      MpHIST(jj,:)=MpHIST(jj,:)+histcounts(smppol(jj,:),Mpbin);
      NDATAPOL(jj)=NDATAPOL(jj)+NCH;
    end
  end
  SUMPOL=SUMPOL+NCH.*cha.MpCOMPRESS.MEANMp;
  SUMPOLPAIR=SUMPOLPAIR+(NCH-1).*cha.MpCOMPRESS.COVMp+NCH.*cha.MpCOMPRESS.MEANMp*cha.MpCOMPRESS.MEANMp';
  SMPPOL=[SMPPOL smppol(:,SMPID)];
  for kk=1:NFLT
    infid=cha.McCOMPRESS.NFLT(kk).Mcscale==Inf;
    if ~infid
      smpflt(kk,:)=(double(cha.McCOMPRESS.SMPMc(kk,:))+128)./(2.55.*cha.McCOMPRESS.NFLT(kk).Mcscale)+cha.McCOMPRESS.NFLT(kk).McMIN;
      McHIST(kk,:)=McHIST(kk,:)+histcounts(smpflt(kk,:),Mcbin);
      NDATAFLT(kk)=NDATAFLT(kk)+NCH;
    else
      smpflt(kk,:)=ones(1,NCH).*cha.McCOMPRESS.NFLT(kk).McMAX;
      McHIST(kk,:)=McHIST(kk,:)+histcounts(smpflt(kk,:),Mcbin);
      NDATAFLT(kk)=NDATAFLT(kk)+NCH;
    end
  end
  SUMFLT=SUMFLT+NCH.*cha.McCOMPRESS.MEANMc;
  SUMFLTPAIR=SUMFLTPAIR+(NCH-1).*cha.McCOMPRESS.COVMc+NCH.*cha.McCOMPRESS.MEANMc*cha.McCOMPRESS.MEANMc';
  SMPFLT=[SMPFLT smpflt(:,SMPID)];
  clear cha
  fprintf('Now finised at %i/%i\n',ii,NIT)
end
% 
AVEPOL=SUMPOL./NDATAPOL;
AVEFLT=SUMFLT./NDATAFLT;
COVPOL=SUMPOLPAIR./NDATAPOL-(SUMPOL./NDATAPOL)*(SUMPOL./NDATAPOL)';
COVFLT=SUMFLTPAIR./NDATAFLT-(SUMFLT./NDATAFLT)*(SUMFLT./NDATAFLT)';
STDPOL=diag(COVPOL);
STDFLT=diag(COVFLT);
CORPOL=COVPOL./(sqrt(STDPOL)*sqrt(STDPOL'));
CORFLT=COVFLT./(sqrt(STDFLT)*sqrt(STDFLT'));
% 
TCHA.AVEPOL=AVEPOL;
TCHA.AVEFLT=AVEFLT;
TCHA.STDPOL=STDPOL;
TCHA.STDFLT=STDFLT;
TCHA.COVPOL=COVPOL;
TCHA.COVFLT=COVFLT;
TCHA.CORPOL=CORPOL;
TCHA.CORFLT=CORFLT;
TCHA.HISTPOL=MpHIST;
TCHA.HISTFLT=McHIST;
TCHA.NDATPOL=NDATAPOL;
TCHA.NDATFLT=NDATAFLT;
TCHA.SMPPOL=SMPPOL;
TCHA.SMPFLT=SMPFLT;
end