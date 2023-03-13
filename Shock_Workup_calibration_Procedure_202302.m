
%% shock work-up procedure
    % The script was adequate for a multichannel stimulator (SXC-4A, Sanxia Technique Inc., China). 
    % This script is mainly used to measure the threshold of each participant before using electric shock and color or shape conditioned learning or electric shock to induce threat or anxiety.
    % The materials have a Creative Commons CC BY license so that you can use them in any way you want. 
    % You just need to provide an attribution (“by Zhiwei Zhang,Jingqing Nian”，DOI：10.17605/OSF.IO/M3P8Q). 
    % If you have any questions, please send an email to J.Q Nian（E-mail:nianjingqing@126.com).
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
prompt = {'被试编号','被试性别[1=男，2=女]','年级','被试年龄','被试优势手[1=左手，2=右手]'};
dlg_title = '被试信息';                                                     %被试的各种信息
num_line = 1;
defautanswer = {'','','','',''};                                          %默认信息
subinfo= inputdlg(prompt,dlg_title,num_line,defautanswer);

%% Open Window
%Screen('Preference', 'ConserveVRAM', 64)
Screen('Preference', 'SkipSyncTests', 1)
[window,windowRect]=Screen('Openwindow',0,[],[]);

%% 注视点
Screen('TextSize',window,200);%注视点大小
Screen('TextSize',window, 36);% 设置字体大小
[xCenter, yCenter] = RectCenter(windowRect);% 设置窗口中央的X和Y坐标
cx=windowRect(3)/2;cy=windowRect(4)/2;

% %% 显示评分刻度
barWidth = 2000;
barHeight = 10;
% barRect = [xCenter-barWidth/2, yCenter-500, xCenter+barWidth/2, yCenter-50+barHeight];
% barColor = [240 161 168];
% Screen('FillRect', window, barColor, barRect);
% 
% %% 显示滑动条
sliderWidth = 20;
sliderHeight = 50;
% sliderRect = [xCenter-sliderWidth/2, yCenter-70, xCenter+sliderWidth/2, yCenter-70+sliderHeight];
% sliderColor = [240 161 168];
% Screen('FillRect', window, sliderColor, sliderRect);

%% 定义键盘
KbName('UnifyKeyNames');
[~,~,keycode]=KbCheck;
startkey=KbName('q');

%% 初始化鼠标点击
mouseClick = 0;

% fb0=192;fb1=49;fb2=50;fb3=51;fb4=52;fb5=53;fb6=54;fb7=55;fb8=56;fb9=57;fb10=48;


%% 指导语
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
i=1;%i为trial数量
%result为被试行为记录，trial表示第几个试次，djz表示电击大小，pf为反馈评分，zong3为三个评分为8的电击值
result.trial=[];
result.djz=[];
result.pf=[];
zong3=[];

cdjz=ndjz;
while tiaojian
    
    %% 注视点
    Screen('DrawDots',window,[xCenter,yCenter],50,[0 0 0],[],[1]);
    Screen(window,'Flip');
    WaitSecs(0.5);
    sdjz=strcat('i',num2str(cdjz));
    %% 电击
    tex=Screen('MakeTexture',window,shandian);
    Screen('DrawTexture',window,tex);
    Screen(window,'Flip');    
    fprintf(scom,'%s',['$A1S;c2;w3;f100;p2000;o2;r15;' sdjz ';#']); % 预设电刺激仪通道参数 
    % 协议符：$-起始符; #-终止符
    % 机器码：A1
    % 协议命令：S-设置参数;R-重置参数;T-触发电刺激;P-刺激序列暂停
    % 通道号：c, c1~c4表示1~4个通道
    % 波形：w, w1-恒流，w2-正弦波，w3-方波，w4-三角波
    % 频率：f,1~100 Hz
    % 脉宽：p, 50~9950 μs
    % 方向：o1-正向; o2-反向
    % 持续时间：恒流- t+数字，表示持续多少 ms; te 表示一直输出
             % 非恒流-r+数字,表示循环多少次;re 表示持续输出
    % 电流强度：i+数字（5~9995）μA
    
    pause(0.5);%暂停0.5s
    
    fprintf(scom,'%s',['$A1T;c2;#']); %触发指定通道 
    WaitSecs(2);
    
    result(i).trial=i;
    result(i).djz=cdjz;
    
    %% 初始化鼠标位置
    SetMouse(xCenter, yCenter, window);
    
    %% 评分
%     tex=Screen('MakeTexture',window,fankui);
%     Screen('DrawTexture',window,tex);
%     Screen(window,'Flip');
    while true
        while ~any(mouseClick)
        
            % 获取鼠标位置
            [mousePosition, ~, mouseClick] = GetMouse(window);
        
        % 确保滑块在条形刻度范围内
            if mousePosition(1) < xCenter-barWidth/2+sliderWidth/2
                mousePosition(1) = xCenter-barWidth/2+sliderWidth/2;
            elseif mousePosition(1) > xCenter+barWidth/2-sliderWidth/2
                mousePosition(1) = xCenter+barWidth/2-sliderWidth/2;
            end
        
        %显示图片
         tex=Screen('MakeTexture',window,fankui);
         Screen('DrawTexture',window,tex);
        % 显示评分刻度
            barWidth = 1800;
            barHeight = 20;
            barRect = [xCenter-barWidth/2,yCenter+150, xCenter+barWidth/2, yCenter+200+barHeight];  
            barColor = [0 0 0];
            Screen('FillRect', window, barColor, barRect);
            DrawFormattedText(window,'0',xCenter-barWidth/2,yCenter+150, barColor);
            DrawFormattedText(window, '10',xCenter+barWidth/2,yCenter+150,barColor);
            
        % 移动滑块
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
result(1).avg=avg;%代表三个评分为8的电击值的平均

Screen('DrawText',window,double('实验结束'),cx-50,cy-90);
Screen(window,'Flip');
WaitSecs(1);

fclose(scom);%关闭串口设备对象
delete(scom);%删除内存中的串口设备对象
clear scom; %清除工作空间中的串口设备对象

Screen('CloseAll');
bs=strcat('bs',cell2mat(subinfo(1)));
uisave({'result'},bs);
