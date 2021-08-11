
%% shock workup procedure
% The code was adequate for a multichannel stimulator (SXC-4A, Sanxia Technique Inc., China). 
% The code made by Zhiwei Zhang[E-mail:760861993@qq.com]. Modified by Jingqing Nian[E-mail:nianjingqing@126.com].
% School of Psychology,Guizhou Normal University
% The materials have a Creative Commons CC BY license so that you can use them in any way you want. 
% You just need to provide an attribution (“by Zhiwei Zhang,Jingqing Nian”，DOI：10.17605/OSF.IO/M3P8Q). 


%% Close all & Clear Command
close all;clear;clc;

%% Serial port

%判段是否有串口正在使用，如有删除所有串口设备

if ~isempty(instrfind)
    delete(instrfindall);
    pause(8);   
end

%获取当前可用串口信息
Ports = instrhwinfo('serial'); 

%获取可用串口端号
dd = Ports.AvailableSerialPorts;

%定义串口并设置参数,一代波特率为 9600；二代波特率为 115200，理论上从串口发命令到仪器开始输出刺激的时间间隔约为 2ms
scom=serial(dd{3},'BaudRate',9600,'Parity','none','DataBits',8,'StopBits',1); 

%打开端口
fopen(scom);

%重置4个通道参数
fprintf(scom,'%s','$A1R;c1234;#'); 
pause(0.5);%暂停0.5s

%% Subject Information

%注视点的大小和位置可根据需要进行微调
%程序运行完成后检查被试序号是否正确保存即可
%这里选择的评分键位为数字键1到0,分别代表1-10分，0分为 、~ 键
%收集被试信息

prompt = {'被试编号','被试性别[1=男，2=女]','年级','被试年龄','被试优势手[1=左手，2=右手]'};
dlg_title = '被试信息';                                                     %被试的各种信息
num_line = 1;
defautanswer = {'','','','',''};                                          %默认信息
subinfo= inputdlg(prompt,dlg_title,num_line,defautanswer);

%% 打开屏幕
%Screen('Preference', 'ConserveVRAM', 64)

Screen('Preference', 'SkipSyncTests', 1)
[w,wsize]=Screen('Openwindow',0,[],[]);

%% 电击参数初始值

ndjz=250; % 初始电击值
Step_Size = 250; % 定义步长

%% 注视点
Screen('TextSize',w,200);%注视点大小

%%坐标
cx=wsize(3)/2;
cy=wsize(4)/2;


cs=0;%cs为评分为8的次数

%% 导入图片
kaishi=imread('.\materials\Ins01010.bmp');
shandian=imread('.\materials\T1.bmp');
fankui=imread('.\materials\Ins03.bmp');

%% 定义键盘

KbName('UnifyKeyNames');
[~,~,keycode]=KbCheck;
startkey=KbName('q');
fb0=192;fb1=49;fb2=50;fb3=51;fb4=52;fb5=53;fb6=54;fb7=55;fb8=56;fb9=57;fb10=48;


%% 指导语
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
i=1;%i为trial数量
%result为被试行为记录，trial表示第几个试次，djz表示电击大小，pf为反馈评分，zong3为三个评分为8的电击值
result.trial=[];
result.djz=[];
result.pf=[];
zong3=[];


cdjz=ndjz;
while tiaojian
    
    %% 注视点
    Screen('DrawDots',w,[cx-50,cy-90],50,[0 0 0],[],[1]);
    Screen(w,'Flip');
    WaitSecs(0.5);
    sdjz=strcat('i',num2str(cdjz));
    %% 电击
    tex=Screen('MakeTexture',w,shandian);
    Screen('DrawTexture',w,tex);
    Screen(w,'Flip');    
    fprintf(scom,'%s',['$A1S;c2;w3;f100;p2000;o1;r10;' sdjz ';#']); % 预设电刺激仪通道参数 
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
    
    %% 评分
    tex=Screen('MakeTexture',w,fankui);
    Screen('DrawTexture',w,tex);
    Screen(w,'Flip');
    WaitSecs(0.3);%为了被试不要乱按，加了限定时间
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
result(1).avg=avg;%代表三个评分为8的电击值的平均

Screen('DrawText',w,double('实验结束'),cx-50,cy-90);
Screen(w,'Flip');
WaitSecs(1);

fclose(scom);%关闭串口设备对象
delete(scom);%删除内存中的串口设备对象
clear scom; %清除工作空间中的串口设备对象


sca

bs=strcat('bs',cell2mat(subinfo(1)));
uisave({'result'},bs);
