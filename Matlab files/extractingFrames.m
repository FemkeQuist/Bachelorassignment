clc 
clear 
close all 

%% Information needed
% Directories
% Detectory to store the frames of cam 1 
% Seperate files for each video will be made autometically 
% mkdir and dirProcessedCam1 should be the same 
mkdir('...')
dirProcessedCam1 = '...';
% Detectory to store the frames of cam 2
% Seperate files for each video will be made autometically 
% mkdir and dirProcessedCam2 should be the same 
mkdir('...')
dirProcessedCam2 = '...';

% Information about the videos
% Example: full name is shoecam1105.001.avi for file from cam 1 where 001
% is the numbering which changes per file, then: 
% nameCam1 = 'shoecam1105.' and type = '.avi'
nameCam1 = 'shoecam1105.'; 
nameCam2 = 'shoecam2173.'; 
type = '.avi';

% Amount of videos of which the frames should be saved 
amountVideos = 10;

%% Extracting frames of cam 1
cd(dirProcessedCam1)
% Making files with the names of the files in which the frames of the video should be saved
for j = 1:amountVideos
    
    folderName = 'Cam1_FramesVideo'+ string(j);
    mkdir(folderName);
end 

% Saving frames of each video in the allocated folder 
for j = 1:amountVideos
    % Import the video file
    if j < 10
        videoNumber = '00' + string(j);
    elseif j < 100
        videoNumber = '0' + string(j);
    end 
    videoName = nameCam1 + videoNumber + type;
    videoFrames = VideoReader(videoName);
    videoReader = read(videoFrames);
      
    % Read the total number of frames
    frames = videoFrames.NumFrames;
      
    % File format of the frames to be saved in
    ST ='.png';
      
    % Reading and writing the frames 
    for i = 1 : frames
      
        % Converting integer to string
        Sx = num2str(i);
      
        % Concatenating 2 strings
        Strc = strcat(Sx, ST);
        Vid = videoReader(:, :, :, i);
        folderName = 'Cam1_FramesVideo' + string(j);
        cd(folderName);
      
        % Exporting the frames
        imwrite(Vid, Strc);
        cd ..  
    end
end 

%% Extracting frames of cam 2
cd(dirProcessedCam2)
% Making files with the names of the files in which the frames of the video should be saved
for j = 1:amountVideos
    
    folderName = 'Cam2_FramesVideo'+ string(j);
    mkdir(folderName);
end 

% Saving frames of each video in the allocated folder 
for j = 1:amountVideos
    % Import the video file
    if j < 10
        videoNumber = '00' + string(j);
    elseif j < 100
        videoNumber = '0' + string(j);
    end 
    videoName = nameCam1 + videoNumber + type;
    videoFrames = VideoReader(videoName);
    videoReader = read(videoFrames);
      
    % Read the total number of frames
    frames = videoFrames.NumFrames;
      
    % File format of the frames to be saved in
    ST ='.png';
      
    % Reading and writing the frames 
    for i = 1 : frames
      
        % Converting integer to string
        Sx = num2str(i);
      
        % Concatenating 2 strings
        Strc = strcat(Sx, ST);
        Vid = videoReader(:, :, :, i);
        folderName = 'Cam2_FramesVideo' + string(j);
        cd(folderName);
      
        % Exporting the frames
        imwrite(Vid, Strc);
        cd ..  
    end
end 