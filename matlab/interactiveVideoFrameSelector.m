% made by Dongyun Kang at 2024.09.22
function interactiveVideoFrameSelector()
    %% 기본 UI 창 설정
    fig = figure('Name', 'Interactive Frame Selector', 'NumberTitle', 'off', ...
        'Position', [100, 100, 1000, 900]);

    % 미리보기 영역을 subplot으로 위쪽에 배치
    axesPreview = axes('Position', [0.05, 0.30, 0.9, 0.65]); % 미리보기 창 (위쪽)

    % 파일 경로 설정 섹션 
    uicontrol('Style', 'text', 'Position', [20, 20, 120, 20], 'String', 'Video File Path:');
    filePathBox = uicontrol('Style', 'edit', 'Position', [150, 20, 600, 20], 'Enable', 'off');
    uicontrol('Style', 'pushbutton', 'Position', [760, 20, 100, 25], 'String', 'Select File', ...
        'Callback', @selectFile);

    % Grid 설정 섹션 
    uicontrol('Style', 'text', 'Position', [20, 50, 120, 20], 'String', 'Grid Rows:');
    gridRowsBox = uicontrol('Style', 'edit', 'Position', [150, 50, 100, 20], 'String', '3');
    uicontrol('Style', 'text', 'Position', [270, 50, 120, 20], 'String', 'Grid Columns:');
    gridColsBox = uicontrol('Style', 'edit', 'Position', [400, 50, 100, 20], 'String', '3');

    % FrameSet 숫자 입력 섹션 
    uicontrol('Style', 'text', 'Position', [20, 80, 180, 20], 'String', 'Frame Set (comma separated):');
    frameSetBox = uicontrol('Style', 'edit', 'Position', [200, 80, 550, 20], 'String', '1, 2, 3, 4, 5');
    frameSetLimit = uicontrol('Style', 'text', 'Position', [760, 80, 200, 20], 'String', ''); % FrameSet 범위 표시

    % Trim 시작 위치 및 크기 입력 섹션 (아래쪽)
    uicontrol('Style', 'text', 'Position', [20, 150, 120, 20], 'String', 'Start X:');
    startXBox = uicontrol('Style', 'edit', 'Position', [150, 150, 100, 20], 'String', '1');
    startXLimit = uicontrol('Style', 'text', 'Position', [260, 150, 120, 20], 'String', '');

    uicontrol('Style', 'text', 'Position', [20, 120, 120, 20], 'String', 'Start Y:');
    startYBox = uicontrol('Style', 'edit', 'Position', [150, 120, 100, 20], 'String', '1');
    startYLimit = uicontrol('Style', 'text', 'Position', [260, 120, 120, 20], 'String', '');

    uicontrol('Style', 'text', 'Position', [270, 150, 120, 20], 'String', 'Trim Height:');
    trimHeightBox = uicontrol('Style', 'edit', 'Position', [400, 150, 100, 20], 'String', '750');
    trimHeightLimit = uicontrol('Style', 'text', 'Position', [510, 150, 120, 20], 'String', '');

    uicontrol('Style', 'text', 'Position', [270, 120, 120, 20], 'String', 'Trim Width:');
    trimWidthBox = uicontrol('Style', 'edit', 'Position', [400, 120, 100, 20], 'String', '700');
    trimWidthLimit = uicontrol('Style', 'text', 'Position', [510, 120, 120, 20], 'String', '');

    % 이미지 간격 설정 섹션
    uicontrol('Style', 'text', 'Position', [620, 150, 120, 20], 'String', 'Horizontal Gap:');
    hGapBox = uicontrol('Style', 'edit', 'Position', [740, 150, 60, 20], 'String', '10');
    uicontrol('Style', 'text', 'Position', [620, 120, 120, 20], 'String', 'Vertical Gap:');
    vGapBox = uicontrol('Style', 'edit', 'Position', [740, 120, 60, 20], 'String', '10');

    % Preview와 Export 버튼 섹션 
    uicontrol('Style', 'pushbutton', 'Position', [50, 200, 200, 40], 'String', 'Preview Frame', ...
        'Callback', @previewFrame);
    uicontrol('Style', 'pushbutton', 'Position', [300, 200, 200, 40], 'String', 'Export to PDF', ...
        'Callback', @exportToPDF);

    % 설정 저장 버튼
    uicontrol('Style', 'pushbutton', 'Position', [600, 200, 150, 40], 'String', 'Save Settings', ...
        'Callback', @saveSettings);

    % 설정 불러오기 버튼
    uicontrol('Style', 'pushbutton', 'Position', [760, 200, 150, 40], 'String', 'Load Settings', ...
        'Callback', @loadSettings);

    %% 파일 선택 콜백 함수
    function selectFile(~, ~)
        [fileName, filePath] = uigetfile('*.mp4', 'Select a video file');
        if fileName
            fileFullPath = fullfile(filePath, fileName);
            set(filePathBox, 'String', fileFullPath);

            % 비디오 파일 정보를 바탕으로 한계 수치 설정
            video = VideoReader(fileFullPath);
            set(startXLimit, 'String', sprintf('(1 to %d)', video.Width));
            set(startYLimit, 'String', sprintf('(1 to %d)', video.Height));
            set(trimWidthLimit, 'String', sprintf('(1 to %d)', video.Width));
            set(trimHeightLimit, 'String', sprintf('(1 to %d)', video.Height));
            set(frameSetLimit, 'String', sprintf('(1 to %d)', video.NumFrames)); % FrameSet 범위 설정
        end
    end

    %% 설정 저장 콜백 함수
    function saveSettings(~, ~)
        % 현재 설정된 값을 저장
        settings.filePath = get(filePathBox, 'String');
        settings.gridRows = get(gridRowsBox, 'String');
        settings.gridCols = get(gridColsBox, 'String');
        settings.frameSet = get(frameSetBox, 'String');
        settings.startX = get(startXBox, 'String');
        settings.startY = get(startYBox, 'String');
        settings.trimHeight = get(trimHeightBox, 'String');
        settings.trimWidth = get(trimWidthBox, 'String');
        settings.hGap = get(hGapBox, 'String');
        settings.vGap = get(vGapBox, 'String');

        % 파일로 저장
        [fileName, path] = uiputfile('*.mat', 'Save Settings As');
        if fileName
            save(fullfile(path, fileName), 'settings');
            fprintf('Settings saved: %s\n', fullfile(path, fileName));
        end
    end

    %% 설정 불러오기 콜백 함수
    function loadSettings(~, ~)
        % 설정 파일 불러오기
        [fileName, path] = uigetfile('*.mat', 'Load Settings');
        if fileName
            load(fullfile(path, fileName), 'settings');

            % 불러온 설정 값 적용
            set(filePathBox, 'String', settings.filePath);
            set(gridRowsBox, 'String', settings.gridRows);
            set(gridColsBox, 'String', settings.gridCols);
            set(frameSetBox, 'String', settings.frameSet);
            set(startXBox, 'String', settings.startX);
            set(startYBox, 'String', settings.startY);
            set(trimHeightBox, 'String', settings.trimHeight);
            set(trimWidthBox, 'String', settings.trimWidth);
            set(hGapBox, 'String', settings.hGap);
            set(vGapBox, 'String', settings.vGap);

            fprintf('Settings loaded: %s\n', fullfile(path, fileName));
        end
    end

    %% 프레임 미리보기 콜백 함수
    function previewFrame(~, ~)
        % 입력된 값 가져오기
        videoFilePath = get(filePathBox, 'String');
        if isempty(videoFilePath)
            errordlg('Please select a video file.', 'Error');
            return;
        end
        
        frameSetStr = get(frameSetBox, 'String');
        frameSet = str2num(frameSetStr); %#ok<ST2NM> % 여러 프레임 입력을 숫자로 변환
        if isempty(frameSet)
            errordlg('Invalid frame set. Enter valid numbers separated by commas.', 'Error');
            return;
        end

        % 자르기 관련 값 가져오기
        startX = str2double(get(startXBox, 'String'));
        startY = str2double(get(startYBox, 'String'));
        trimHeight = str2double(get(trimHeightBox, 'String'));
        trimWidth = str2double(get(trimWidthBox, 'String'));

        gridRows = str2double(get(gridRowsBox, 'String'));
        gridCols = str2double(get(gridColsBox, 'String'));
        hGap = str2double(get(hGapBox, 'String')); % 수평 간격
        vGap = str2double(get(vGapBox, 'String')); % 수직 간격

        % 비디오 파일 읽기
        video = VideoReader(videoFilePath);
        D_set = zeros(trimHeight, trimWidth, 3, length(frameSet));

        % 선택된 프레임에 대해 이미지를 자르고 저장
        for j = 1:length(frameSet)
            frameIdx = frameSet(j);
            video.CurrentTime = (frameIdx - 1) / video.FrameRate;
            frame = readFrame(video);

            % 자르기 범위 설정
            heightRange = startY:(startY + trimHeight - 1);
            widthRange = startX:(startX + trimWidth - 1);
            croppedImg = frame(heightRange, widthRange, :);

            D_set(:, :, :, j) = double(croppedImg) / 255;
        end

        % 타일 형식으로 미리보기 이미지 생성, 수직/수평 간격 적용
        outImg = imtile(D_set, 'GridSize', [gridRows, gridCols], 'BorderSize', [vGap, hGap], 'BackgroundColor', 'w');

        % 미리보기 출력
        axes(axesPreview); % 미리보기 영역 선택
        imshow(outImg);
    end

    %% PDF 내보내기 콜백 함수
    function exportToPDF(~, ~)
        % PDF로 저장 - exportgraphics 사용
        [fileName, path] = uiputfile('*.pdf', 'Save PDF As');
        if fileName
            exportgraphics(axesPreview, fullfile(path, fileName), 'ContentType', 'vector');
            fprintf('PDF 저장 완료: %s\n', fullfile(path, fileName));
        end
    end
end
