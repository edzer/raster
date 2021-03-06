# Author: Robert J. Hijmans
# Date: December 2011
# Version 1.0
# Licence GPL v3

if (!isGeneric('symdif')) {
	setGeneric('symdif', function(x, y, ...)
		standardGeneric('symdif'))
}	



setMethod('symdif', signature(x='SpatialPolygons', y='SpatialPolygons'), 
function(x, y, ...) {
	stopifnot(requireNamespace("rgeos"))

	haswarned <- FALSE

	yy <- list(y, ...)
	for (y in yy) {
		if (! identical(proj4string(x), proj4string(y)) ) {
			if (!haswarned) {
				warning('non identical CRS')
				haswarned <- TRUE
			}
			crs(y) <- proj4string(x)
		}
		if (rgeos::gIntersects(x, y)) {
			part1 <- erase(x, y)
			part2 <- erase(y, x)
			x <- bind(part1, part2)
		}
	}
	x
}
)

