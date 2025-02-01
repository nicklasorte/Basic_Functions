function dist = weighted_distance(x1, x2, w1, w2)

dist = sqrt(sum((x1 - x2).^2 .* (w1 + w2) / 2));

end