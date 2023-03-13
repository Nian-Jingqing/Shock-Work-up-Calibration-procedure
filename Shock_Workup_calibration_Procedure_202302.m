
%% shock work-up procedure
    % The script was adequate for a multichannel stimulator (SXC-4A, Sanxia Technique Inc., China). 
    % This script is mainly used to measure the threshold of each participant before using electric shock and color or shape conditioned learning or electric shock to induce threat or anxiety.
    % The materials have a Creative Commons CC BY license so that you can use them in any way you want. 
    % You just need to provide an attribution (��by Zhiwei Zhang,Jingqing Nian����DOI��10.17605/OSF.IO/M3P8Q). 
    % If you have any questions, please send an email to J.Q Nian��E-mail:nianjingqing@126.com).
%% Author Information
    % Version 1.0 made by Zhiwei Zhang[E-mail:760861993@qq.com]
    % Version 1.1 modified by Jingqing Nian[E-mail:nianjingqing@126.com]
    % Version 1.2 modified by Jingqing Nian[E-mail:nianjingqing@126.com] in 13th March 2023.
    % Author Unit:School of Psychology,Guizhou Normal University

%% Version History
   % Version 1.0 has completed the preparation of the core process and some basic functions, such as interrupting the task when the score reaches the preset value.
   % Version 1.1 modifies the code adaptively according to the parameter setting requirements of the electric shock instrument.
   % Version 1.2 mainly changes is the scoring method from pressing the corresponding number keys to sliding the mouse, and further simplifies and optimizes the script. 

%% Basic parameters
close all;clear;clc;% Close all & Clear Command

% Set the basic value of sliding scoring window
rand('seed',sum(100 * clock)); % Set random number seed
step_size = 1;  % The numerical change step length of each mouse movement

% Initial value of the number of scoring cycles
cs=0;

% Electric shock parameter setting
ndjz=0; % Initial shock value
Step_Size = 100; % Step length of electric shock value change

%Import picture
kaishi=imread('.\materials\Ins.png');
shandian=imread('.\materials\T1.bmp');
fankui=imread('.\materials\PF01.png');

% Find & Open Serial port
    % Determine whether the serial port is in use in the segment, and if so, delete all serial port devices
    if ~isempty(instrfind)
        delete(instrfindall);
        pause(8);   
    end
    Ports = instrhwinfo('serial'); % Get the currently available serial port information
    dd = Ports.AvailableSerialPorts;% Get available serial port pin numbers 
% Define the serial port and set the parameters. 
% The first generation baud rate is 9600; The second generation baud rate is 115200. 
% In theory, the time interval from the serial port sending command to the instrument starting to output stimulus is about 2ms
scom=serial(dd{length(dd)},'BaudRate',9600,'Parity','none','DataBits',8,'StopBits',1); 
fopen(scom);% Open serial port
fprintf(scom,'%s','$A1R;c1234;#'); %Reset 4 channel parameters
pause(0.5);% Pause for 0.5 s


%% Subject Information
prompt = {'���Ա��','�����Ա�[1=�У�2=Ů]','�꼶','��������','����������[1=���֣�2=����]'};
dlg_title = '������Ϣ';                                                     %���Եĸ�����Ϣ
num_line = 1;
defautanswer = {'','','','',''};                                          %Ĭ����Ϣ
subinfo= inputdlg(prompt,dlg_title,num_line,defautanswer);

%% Open Window
%Screen('Preference', 'ConserveVRAM', 64)
Screen('Preference', 'SkipSyncTests', 1)
[window,windowRect]=Screen('Openwindow',0,[],[]);

%% ע�ӵ�
Screen('TextSize',window,200);%ע�ӵ��С
Screen('TextSize',window, 36);% ���������С
[xCenter, yCenter] = RectCenter(windowRect);% ���ô��������X��Y����
cx=windowRect(3)/2;cy=windowRect(4)/2;

% %% ��ʾ���̶ֿ�
barWidth = 2000;
barHeight = 10;
% barRect = [xCenter-barWidth/2, yCenter-500, xCenter+barWidth/2, yCenter-50+barHeight];
% barColor = [240 161 168];
% Screen('FillRect', window, barColor, barRect);
% 
% %% ��ʾ������
sliderWidth = 20;
sliderHeight = 50;
% sliderRect = [xCenter-sliderWidth/2, yCenter-70, xCenter+sliderWidth/2, yCenter-70+sliderHeight];
% sliderColor = [240 161 168];
% Screen('FillRect', window, sliderColor, sliderRect);

%% �������
KbName('UnifyKeyNames');
[~,~,keycode]=KbCheck;
startkey=KbName('q');

%% ��ʼ�������
mouseClick = 0;

% fb0=192;fb1=49;fb2=50;fb3=51;fb4=52;fb5=53;fb6=54;fb7=55;fb8=56;fb9=57;fb10=48;


%% ָ����
tex=Screen('MakeTexture',window,kaishi);
Screen('DrawTexture',window,tex);
Screen(window,'Flip');

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
    Screen('DrawDots',window,[xCenter,yCenter],50,[0 0 0],[],[1]);
    Screen(window,'Flip');
    WaitSecs(0.5);
    sdjz=strcat('i',num2str(cdjz));
    %% ���
    tex=Screen('MakeTexture',window,shandian);
    Screen('DrawTexture',window,tex);
    Screen(window,'Flip');    
    fprintf(scom,'%s',['$A1S;c2;w3;f100;p2000;o2;r15;' sdjz ';#']); % Ԥ���̼���ͨ������ 
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
    
    %% ��ʼ�����λ��
    SetMouse(xCenter, yCenter, window);
    
    %% ����
%     tex=Screen('MakeTexture',window,fankui);
%     Screen('DrawTexture',window,tex);
%     Screen(window,'Flip');
    while true
        while ~any(mouseClick)
        
            % ��ȡ���λ��
            [mousePosition, ~, mouseClick] = GetMouse(window);
        
        % ȷ�����������ο̶ȷ�Χ��
            if mousePosition(1) < xCenter-barWidth/2+sliderWidth/2
                mousePosition(1) = xCenter-barWidth/2+sliderWidth/2;
            elseif mousePosition(1) > xCenter+barWidth/2-sliderWidth/2
                mousePosition(1) = xCenter+barWidth/2-sliderWidth/2;
            end
        
        %��ʾͼƬ
         tex=Screen('MakeTexture',window,fankui);
         Screen('DrawTexture',window,tex);
        % ��ʾ���̶ֿ�
            barWidth = 1800;
            barHeight = 20;
            barRect = [xCenter-barWidth/2,yCenter+150, xCenter+barWidth/2, yCenter+200+barHeight];  
            barColor = [0 0 0];
            Screen('FillRect', window, barColor, barRect);
            DrawFormattedText(window,'0',xCenter-barWidth/2,yCenter+150, barColor);
            DrawFormattedText(window, '10',xCenter+barWidth/2,yCenter+150,barColor);
            
        % �ƶ�����
            sliderRect = [mousePosition(1)-sliderWidth/2, yCenter+100, mousePosition(1)+sliderWidth/2, yCenter+150+sliderHeight];
            rating = round((mousePosition(1)-(xCenter-barWidth/2))/barWidth*10);
            rating_text = num2str(rating);
            DrawFormattedText(window,['Scores is:' rating_text ],'center', yCenter+250,[0 0 0]);
            sliderColor = [0 0 0];
            Screen('FillRect',window,sliderColor,sliderRect);
            Screen('Flip', window);
        end
        mouseClick = 0;
        result(i).pf = rating;
            
       if rating<7
          cdjz= cdjz + Step_Size;
          break 
       elseif rating>7
          cdjz=cdjz - Step_Size;
          break
        else
           cs=cs+1;
           zong3=[cdjz,zong3];
           cdjz=ndjz;
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

Screen('DrawText',window,double('ʵ�����'),cx-50,cy-90);
Screen(window,'Flip');
WaitSecs(1);

fclose(scom);%�رմ����豸����
delete(scom);%ɾ���ڴ��еĴ����豸����
clear scom; %��������ռ��еĴ����豸����

Screen('CloseAll');
bs=strcat('bs',cell2mat(subinfo(1)));
uisave({'result'},bs);
