function [bitting, pinPositions] = decodeKW1(mat, bladeBounds)

% find normalized pin positions
pinPositions = zeros(1,5);
for p = 1:length(pinPositions)
    pinPositions(p) = round(bladeBounds(1,2) - ((0.247 + 0.15*(p-1)) * (bladeBounds(1,2) - bladeBounds(1,1)) / 1.15));
end

% find mode y value for each pin (-5:+5)
cutDepths = zeros(1,5);
for p = 1:length(pinPositions)
    x = pinPositions(p);
    roi = mat(bladeBounds(2,2):bladeBounds(2,1)-5, x-5:x+5);
    [r,c] = find(roi);
    cutDepths(p) = mode(r);
end

% bitting specs
normalizedBittingSpecs = 1 - ([.329, .306, .283, .260, .237, .214, .191] / .335);

% normalized cut depths
normalizedCutDepths = cutDepths / (bladeBounds(2,1) - bladeBounds(2,2));

% calculate bitting code with smallest error
bitting = zeros(1,5);
for p = 1:length(pinPositions)
    error = abs(normalizedBittingSpecs - normalizedCutDepths(p));
    [m, i] = min(error);
    bitting(p) = i;
end


end

