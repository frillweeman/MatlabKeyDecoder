function rotated = straightenToLine(mat, line)
    rotationDeg = rad2deg(atan2(line.point2(2) - line.point1(2), line.point2(1) - line.point1(1)));
    rotated = imrotate(mat, rotationDeg);
end

