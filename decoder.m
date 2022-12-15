close all;
clear;
clc;

% imgFile = 'kw1.jpg';
% imgFile = 'kw1-blank.jpg';
imgFile = 'kw1-house.jpg';

% resize to familiar size (for use with my kernels)
mat = imread(imgFile);
[w, h] = size(mat);
mat = imresize(mat, [895 1280]);

% convert to grayscale
gray = rgb2gray(mat);

% smooth out noise while preserving edges
smoothed = imbilatfilt(gray, 0.5*diff(getrangefromclass(gray).^2), 2);

% find edges
edges = edge(smoothed, 'Canny', [0.05 0.20]);

% figure; imshowpair(smoothed, edges, 'montage');

% fill gaps with morphological close (dilation followed by erosion)
se = strel('disk', 7);
closed = imclose(edges, se);

% fill contours
filled = imfill(closed, 'holes');

% keep only largest object
keyonly = bwareafilt(filled, 1);

% find outer contour for line identification
outerLoop = bwperim(keyonly);

% find bottom of blade using hough
[H, T, R] = hough(outerLoop);
P = houghpeaks(H, 1, 'Threshold', ceil(0.1 * max(H(:))));
lines = houghlines(outerLoop, T, R, P, 'FillGap', 200, 'MinLength', 50);
bottomOfBladePreRotation = lines(1);

% rotate key to be straight
rotated = straightenToLine(outerLoop, bottomOfBladePreRotation);

% display image
figure; imshow(straightenToLine(mat, bottomOfBladePreRotation)); title('Bitting Code');
% figure; imshow(rotated); title('Bitting Code');

% find new bottom of blade
[H, T, R] = hough(rotated);
P = houghpeaks(H, 1, 'Threshold', ceil(0.1 * max(H(:))));
lines = houghlines(rotated, T, R, P, 'FillGap', 200, 'MinLength', 50);
bb = lines(1);

bottomBladeY = (bb.point1(2) + bb.point2(2)) / 2;
yline(bottomBladeY, 'LineWidth', 2, 'Color', 'green');



% find blade X limits

verticalTheta = -3:3; % theta values from -10 to +10

% hough transform to identify vertical lines
[H, T, R] = hough(rotated, 'Theta', verticalTheta);
P = houghpeaks(H, 4, 'Threshold', ceil(0.1 * max(H(:))), 'Theta', verticalTheta);
lines = houghlines(rotated, T, R, P, 'FillGap', 500, 'MinLength', 10);

% leftmost line is the shoulder, find its midpoint
shoulderX = w;
for p = 1:length(lines)
    x = [lines(p).point1(1), lines(p).point2(1)];
    if (x(1) < shoulderX)
        shoulderX = x(1);
    end
    if (x(2) < shoulderX)
        shoulderX = x(1);
    end
end

xline(shoulderX, 'LineWidth', 2, 'Color', 'magenta');

% leftmost point is tip
[r,c] = find(rotated);
tipX = min(c);
xline(tipX, 'LineWidth', 2, 'Color', 'magenta');




% create ROI for top of blade detection
roi = rotated(1:bottomBladeY, tipX:shoulderX-10); % -10 for clearance
[r,c] = find(roi);
topOfBladeY = min(r);

yline(topOfBladeY, 'LineWidth', 2, 'Color', 'green');


bladeBounds = [tipX shoulderX; bottomBladeY topOfBladeY];
[bitting, pinPositions] = decodeKW1(rotated, bladeBounds);



% draw bitting on key
for p = 1:length(pinPositions)
    xline(pinPositions(p), 'LineWidth', 2, 'Color', 'red');
    text(pinPositions(p), 100, int2str(bitting(p)), 'fontsize', 20, 'color', 'white');
end

text(shoulderX + 100, 100, mat2str(bitting), 'fontsize', 40, 'color', 'white');

