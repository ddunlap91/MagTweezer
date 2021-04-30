function FE_Process_test(hMain)


handles = guidata(hMain);

persistent tacc;
persistent thdl;
persistent ImageData;
persistent FrameTime;

if handles.FE_CurrentFrame == 1
    tacc = zeros(handles.FE_FrameCount,1);
    thdl = zeros(handles.FE_FrameCount,1);
    ImageData = cell(handles.FE_FrameCount,1);%saving image data in cell array appears to be faster than using an imagestack (probably because there's no copying involved since matlab is just moving pointers)
    FrameTime = zeros(handles.FE_FrameCount,1);
end
t1= tic;
if handles.FE_CurrentFrame<=handles.FE_FrameCount
    ImageData{handles.FE_CurrentFrame} = handles.MMcam.ImageData;
    FrameTime(handles.FE_CurrentFrame) = handles.MMcam.clkImageTime;
    tacc(handles.FE_CurrentFrame) = toc(t1);
    handles.FE_CurrentFrame = handles.FE_CurrentFrame+1;
    guidata(hMain,handles);
    thdl(handles.FE_CurrentFrame-1) = toc(t1);
end


if handles.FE_CurrentFrame>handles.FE_FrameCount
    fprintf('Average Capture Time: %f\n',mean(tacc));
    fprintf('Average save handles time: %f\n',mean(thdl-tacc));
    MultiMTgui_stopForceExtension(hMain);
end