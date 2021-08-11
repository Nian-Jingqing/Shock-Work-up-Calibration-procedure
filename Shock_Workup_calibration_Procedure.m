
%% shock workup procedure
% The code was adequate for a multichannel stimulator (SXC-4A, Sanxia Technique Inc., China). 
% The code made by Zhiwei Zhang[E-mail:760861993@qq.com]. Modified by Jingqing Nian[E-mail:nianjingqing@126.com].
% School of Psychology,Guizhou Normal University
% The materials have a Creative Commons CC BY license so that you can use them in any way you want. 
% You just need to provide an attribution (��by Zhiwei Zhang,Jingqing Nian����DOI��10.17605/OSF.IO/M3P8Q). 


%% Close all & Clear Command
close all;clear;clc;

%% Serial port

%�ж��Ƿ��д�������ʹ�ã�����ɾ�����д����豸

if ~isempty(instrfind)
    delete(instrfindall);
    pause(8);   
end

%��ȡ��ǰ���ô�����Ϣ
Ports = instrhwinfo('serial'); 

%��ȡ���ô��ڶ˺�
dd = Ports.AvailableSerialPorts;

%���崮�ڲ����ò���,һ��������Ϊ 9600������������Ϊ 115200�������ϴӴ��ڷ����������ʼ����̼���ʱ����ԼΪ 2ms
scom=serial(dd{3},'BaudRate',9600,'Parity','none','DataBits',8,'StopBits',1); 

%�򿪶˿�
fopen(scom);

%����4��ͨ������
fprintf(scom,'%s','$A1R;c1234;#'); 
pause(0.5);%��ͣ0.5s

%% Subject Information

%ע�ӵ�Ĵ�С��λ�ÿɸ�����Ҫ����΢��
%����������ɺ��鱻������Ƿ���ȷ���漴��
%����ѡ������ּ�λΪ���ּ�1��0,�ֱ����1-10�֣�0��Ϊ ��~ ��
%�ռ�������Ϣ

prompt = {'���Ա��','�����Ա�[1=�У�2=Ů]','�꼶','��������','����������[1=���֣�2=����]'};
dlg_title = '������Ϣ';                                                     %���Եĸ�����Ϣ
num_line = 1;
defautanswer = {'','','','',''};                                          %Ĭ����Ϣ
subinfo= inputdlg(prompt,dlg_title,num_line,defautanswer);

%% ����Ļ
%Screen('Preference', 'ConserveVRAM', 64)

Screen('Preference', 'SkipSyncTests', 1)
[w,wsize]=Screen('Openwindow',0,[],[]);

%% ���������ʼֵ

ndjz=250; % ��ʼ���ֵ
Step_Size = 250; % ���岽��

%% ע�ӵ�
Screen('TextSize',w,200);%ע�ӵ��С

%%����
cx=wsize(3)/2;
cy=wsize(4)/2;


cs=0;%csΪ����Ϊ8�Ĵ���

%% ����ͼƬ
kaishi=imread('.\materials\Ins01010.bmp');
shandian=imread('.\materials\T1.bmp');
fankui=imread('.\materials\Ins03.bmp');

%% �������

KbName('UnifyKeyNames');
[~,~,keycode]=KbCheck;
startkey=KbName('q');
fb0=192;fb1=49;fb2=50;fb3=51;fb4=52;fb5=53;fb6=54;fb7=55;fb8=56;fb9=57;fb10=48;


%% ָ����
tex=Screen('MakeTexture',w,kaishi);
Screen('DrawTexture',w,tex);
Screen(w,'Flip');


while true
    [~,~,keycode]=KbCheck;
    if keycode(startkey)
        WaitSecs(1);
        break
    end
    
end


tiaojian=1;
i=1;%iΪtrial����
%resultΪ������Ϊ��¼��trial��ʾ�ڼ����ԴΣ�djz��ʾ�����С��pfΪ�������֣�zong3Ϊ��������Ϊ8�ĵ��ֵ
result.trial=[];
result.djz=[];
result.pf=[];
zong3=[];


cdjz=ndjz;
while tiaojian
    
    %% ע�ӵ�
    Screen('DrawDots',w,[cx-50,cy-90],50,[0 0 0],[],[1]);
    Screen(w,'Flip');
    WaitSecs(0.5);
    sdjz=strcat('i',num2str(cdjz));
    %% ���
    tex=Screen('MakeTexture',w,shandian);
    Screen('DrawTexture',w,tex);
    Screen(w,'Flip');    
    fprintf(scom,'%s',['$A1S;c2;w3;f100;p2000;o1;r10;' sdjz ';#']); % Ԥ���̼���ͨ������ 
    % Э�����$-��ʼ��; #-��ֹ��
    % �����룺A1
    % Э�����S-���ò���;R-���ò���;T-������̼�;P-�̼�������ͣ
    % ͨ���ţ�c, c1~c4��ʾ1~4��ͨ��
    % ���Σ�w, w1-������w2-���Ҳ���w3-������w4-���ǲ�
    % Ƶ�ʣ�f,1~100 Hz
    % ����p, 50~9950 ��s
    % ����o1-����; o2-����
    % ����ʱ�䣺����- t+���֣���ʾ�������� ms; te ��ʾһֱ���
             % �Ǻ���-r+����,��ʾѭ�����ٴ�;re ��ʾ�������
    % ����ǿ�ȣ�i+���֣�5~9995����A
    
    pause(0.5);%��ͣ0.5s
    
    fprintf(scom,'%s',['$A1T;c2;#']); %����ָ��ͨ�� 
    WaitSecs(2);
    
    result(i).trial=i;
    result(i).djz=cdjz;
    
    %% ����
    tex=Screen('MakeTexture',w,fankui);
    Screen('DrawTexture',w,tex);
    Screen(w,'Flip');
    WaitSecs(0.3);%Ϊ�˱��Բ�Ҫ�Ұ��������޶�ʱ��
    while true
        [~,~,keycode]=KbCheck;
        if keycode(192)
            result(i).pf=0;
            cdjz=cdjz+Step_Size;
            break
        elseif keycode(49)
            result(i).pf=1;
            cdjz=cdjz+Step_Size;
            break
        elseif keycode(50)
            result(i).pf=2;
            cdjz=cdjz+Step_Size;
            break
        elseif keycode(51)
            result(i).pf=3;
            cdjz=cdjz+Step_Size;
            break
        elseif keycode(52)
            result(i).pf=4;
            cdjz=cdjz+Step_Size;
            break
        elseif keycode(53)
            result(i).pf=5;
            cdjz=cdjz+Step_Size;
            break
        elseif keycode(54)
            result(i).pf=6;
            cdjz=cdjz+Step_Size;
            break
        elseif keycode(55)
            result(i).pf=7;
            cdjz=cdjz+Step_Size;
            break
        elseif keycode(56)
            cs=cs+1;
            result(i).pf=8;
            zong3=[cdjz,zong3];
            cdjz=ndjz;
            break
        elseif keycode(57)
            result(i).pf=9;
            cdjz=cdjz-Step_Size;
            break
        elseif keycode(48)
            result(i).pf=10;
            cdjz=cdjz-Step_Size;
            break
        elseif keycode(27)
            sca
            break
        end
        
    end
    
    if cs==3
        tiaojian=0;
        break
    end
    
    i=i+1;
    
end
avg=mean(zong3);
result(1).avg=avg;%������������Ϊ8�ĵ��ֵ��ƽ��

Screen('DrawText',w,double('ʵ�����'),cx-50,cy-90);
Screen(w,'Flip');
WaitSecs(1);

fclose(scom);%�رմ����豸����
delete(scom);%ɾ���ڴ��еĴ����豸����
clear scom; %��������ռ��еĴ����豸����


sca

bs=strcat('bs',cell2mat(subinfo(1)));
uisave({'result'},bs);
