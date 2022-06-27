clc
clear 
close all 

%% Information needed
% Directories
% Create directory to save the files in which the frames are matched to the IMU data
mkdir '...';
% Directory of frames for camera 1 (see dirProcessedCam1 extractingFrames.m)
dirFramesCam1 = '...';
% Directory of the IMU data
dirProcessedIMUData = '...';
% Directory to save the files in which the frames are matched to the IMU data
dirSaveMatchingFiles = '...';
% Directory of frames for camera 2 (see dirProcessedCam2 extractingFrames.m)
dirFramesCam2 = '...';

% Data of the videos 
% Numbers of the videos which need to be processed
videos = [1 3 6 7];
amountVideos = length(videos);
% Splitting the names of the recordings to make a for loop possible 
% Example: full name is shoecam1105.001.avi for file from cam 1 where 001
% is the numbering which changes per file, then: 
% nameCam1 = 'shoecam1105.' and type = '.avi'
nameCam1 = 'shoecam1105.'; 
nameCam2 = 'shoecam2173.'; 
type = '.avi';

%% Connection data to frame for cam1
cd(dirFramesCam1)

% Creating a matrix with the times for each frame of each video 
% Vertical: number of the frame
% Horizontal: number of the video (same order as videos)
% Value in the cell is the time of the frame of the video

for j = 1:amountVideos
    k = videos(j);
    if k < 10
        videoNumber = '00' + string(k);
    elseif k < 100
        videoNumber = '0' + string(k);
    end 
    videoName = nameCam1 + videoNumber + type;
    videoFrames = VideoReader(videoName);

    numberOfFrames(1,j) = videoFrames.NumFrames;

    for a = 1:videoFrames.NumFrames
        videoReader = read(videoFrames,a);
        timePerFrame(a,j) = videoFrames.CurrentTime;
        width(a,j) = videoFrames.Width;
        height(a,j) = videoFrames.Height;
    end 
end

% Matching the data from the IMU's to the frames of the video 
for i = 1:amountVideos
    
    % Opening data structure beloning to the video
    openFile = 'Xsens_record-00' + string(videos(i)) + '.mat';
    load(fullfile(dirProcessedIMUData,openFile))
    RecordingTime = length(Datastr.IMU.IMUData)/Datastr.IMU.IMUFrameRate;
    timeDifferenceFrames = RecordingTime/length(Datastr.IMU.IMUData);

    % For each frame get the right data from the IMU's
    for j = 1:numberOfFrames(i)
        currentTime = timePerFrame(j,i);
        if mod((currentTime/timeDifferenceFrames)*10,10) == 0 && ((currentTime/timeDifferenceFrames)+1) <= length(Datastr.IMU.IMUData)
            dataBelongingToFrame(j,:) = Datastr.IMU.IMUData((currentTime/timeDifferenceFrames)+1,:);
        else
            if round(currentTime,2)<currentTime
                limit = [round(currentTime,2), round(currentTime,2) + timeDifferenceFrames];
            elseif round(currentTime,2)>currentTime
                limit = [round(currentTime,2) - timeDifferenceFrames, round(currentTime,2)];
            end
            rowsInterpolation = round((limit/timeDifferenceFrames)+1);
            if rowsInterpolation(1,1) <= length(Datastr.IMU.IMUData) && rowsInterpolation(1,2) <= length(Datastr.IMU.IMUData)
                dataBelongingToFrame(j,:) = Datastr.IMU.IMUData(rowsInterpolation(1,1),:) + ((currentTime-rowsInterpolation(1,1))*(Datastr.IMU.IMUData(rowsInterpolation(1,2),:)-Datastr.IMU.IMUData(rowsInterpolation(1,1),:)))/(rowsInterpolation(1,2)-currentTime);
            else
                dataBelongingToFrame(j,:) = NaN;
            end
        end  
    end

    % Adding path to the matrix
    cam = zeros(numberOfFrames(i),1);
    video = zeros(numberOfFrames(i),1);
    frame = zeros(numberOfFrames(i),1);
    for a = 1:numberOfFrames(i)
        cam(a,1) = 1;
        video(a,1) = videos(i);
        frame(a,1) = a;
    end

    % Removing the first three frames and the frames with NaN as data
    % First three frames are from the previous recording
    dataBelongingToFrameComplete = [cam video frame dataBelongingToFrame];
    dataBelongingToFrameEdit = dataBelongingToFrameComplete(3:end,:);
    dataBelongingToFrameFinal = dataBelongingToFrameEdit(sum(isnan(dataBelongingToFrameEdit),2)==0,:);

    % Making a table with the lables of the data 
    label = ['Camera' 'Video' 'Frame' Datastr.IMU.IMUDataLabel];
    tabelFinal = array2table(dataBelongingToFrameFinal,"VariableNames",label);

    % Exporting data to excel
    % Vertical: data point (which IMU) 
    % Horizontal: frames of the video
    cd(dirSaveMatchingFiles)
    
    % name = (number of camera).(number of video).txt
    name = '1.' + string(videos(i)) + '.txt';
    writetable(tabelFinal,name)

    clear cam video frame dataBelongingToFrameComplete dataBelongingToFrameEdit dataBelongingToFrameFinal tabelFinal label dataBelongingToFrame width height
end 

clear timePerFrame  

%% Connecting data to frames for cam2
cd(dirFramesCam2)
    
% Creating a matrix with the times for each frame of each video 
% Vertical: number of the frame
% Horizontal: number of the video (same order as videos)
% Value in the cell is the time of the frame of the video
for j = 1:amountVideos
    k = videos(j);
    if k < 10
        videoNumber = '00' + string(k);
    elseif k < 100
        videoNumber = '0' + string(k);
    end 
    videoName = nameCam2 + videoNumber + type;
    videoFrames = VideoReader(videoName);

    numberOfFrames(1,j) = videoFrames.NumFrames;

    for a = 1:videoFrames.NumFrames
        videoReader = read(videoFrames,a);
        timePerFrame(a,j) = videoFrames.CurrentTime;
    end 
end


for i = 1:amountVideos
    % Opening data structure beloning to the video
    openFile = 'Xsens_record-00' + string(videos(i)) + '.mat';
    load(fullfile(dirProcessedIMUData,openFile))
    RecordingTime = length(Datastr.IMU.IMUData)/Datastr.IMU.IMUFrameRate;
    timeDifferenceFrames = RecordingTime/length(Datastr.IMU.IMUData);

    % For each frame get the right data from the IMU's
    for j = 1:numberOfFrames(i)
        currentTime = timePerFrame(j,i);
        if mod((currentTime/timeDifferenceFrames)*10,10) == 0 && ((currentTime/timeDifferenceFrames)+1) <= length(Datastr.IMU.IMUData)
            dataBelongingToFrame(j,:) = Datastr.IMU.IMUData((currentTime/timeDifferenceFrames)+1,:);
        else
            if round(currentTime,2)<currentTime
                limit = [round(currentTime,2), round(currentTime,2) + timeDifferenceFrames];
            elseif round(currentTime,2)>currentTime
                limit = [round(currentTime,2) - timeDifferenceFrames, round(currentTime,2)];
            end
            rowsInterpolation = round((limit/timeDifferenceFrames)+1);
            if rowsInterpolation(1,1) <= length(Datastr.IMU.IMUData) && rowsInterpolation(1,2) <= length(Datastr.IMU.IMUData)
                dataBelongingToFrame(j,:) = Datastr.IMU.IMUData(rowsInterpolation(1,1),:) + ((currentTime-rowsInterpolation(1,1))*(Datastr.IMU.IMUData(rowsInterpolation(1,2),:)-Datastr.IMU.IMUData(rowsInterpolation(1,1),:)))/(rowsInterpolation(1,2)-currentTime);
            else
                dataBelongingToFrame(j,:) = NaN;
            end
        end  
    end 

    % Adding path to the matrix
    cam = zeros(numberOfFrames(i),1);
    video = zeros(numberOfFrames(i),1);
    frame = zeros(numberOfFrames(i),1);
    for a = 1:numberOfFrames(i)
        cam(a,1) = 2;
        video(a,1) = videos(i);
        frame(a,1) = a;
    end

    % Removing the first three frames and the frames with NaN as data
    % First three frames are from the previous recording
    dataBelongingToFrameComplete = [cam video frame dataBelongingToFrame];
    dataBelongingToFrameEdit = dataBelongingToFrameComplete(3:end,:);
    dataBelongingToFrameFinal = dataBelongingToFrameEdit(sum(isnan(dataBelongingToFrameEdit),2)==0,:);

    % Making a table with the lables of the data 
    label = ['Camera' 'Video' 'Frame' Datastr.IMU.IMUDataLabel];
    tabelFinal = array2table(dataBelongingToFrameFinal,"VariableNames",label);

    % Exporting data to excel
    % Vertical: data point (which IMU) 
    % Horizontal: frames of the video
    cd(dirSaveMatchingFiles)
    % name = (number of camera).(number of video).txt
    name = '2.' + string(videos(i)) + '.txt';
    writetable(tabelFinal,name)

    clear cam video frame dataBelongingToFrameComplete dataBelongingToFrameEdit dataBelongingToFrameFinal tabelFinal label dataBelongingToFrame
end 
