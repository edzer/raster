# Author: Robert J. Hijmans
# Date : January 2009
# Version 0.9
# Licence GPL v3

.startGDALwriting <- function(x, filename, options, setStatistics=TRUE, ...) {

	temp <- .getGDALtransient(x, filename=filename, options=options, ...)
	attr(x@file, "transient") <- temp[[1]]
	x@file@nodatavalue <- temp[[2]]
	attr(x@file, "options") <- temp[[3]]
	attr(x@file, "stats") <- setStatistics

	x@data@min <- rep(Inf, nlayers(x))
	x@data@max <- rep(-Inf, nlayers(x))
	x@data@haveminmax <- FALSE
	
	x@file@datanotation <- .getRasterDType(temp[[4]])
	x@file@driver <- 'gdal'
	x@data@fromdisk <- TRUE
	x@file@name <- filename
	return(x)
}


.stopGDALwriting <- function(x, stat=cbind(NA,NA)) {

	nl <- nlayers(x)

	statistics <- cbind(x@data@min, x@data@max)	
	if (substr(x@file@datanotation, 1, 1) != 'F') {
		statistics <- round(statistics)
	}

	
	if (isTRUE( attr(x@file, "stats") ) ) {
	
		statistics <- cbind(statistics, stat[,1], stat[,2])	

		# could do wild guesses to avoid problems in other software
		# but not sure if this cure would be worse. Could have an option to do this
		#i <- is.na(statistics[,3])
		#if (sum(i) > 0) {
		#	statistics[i, 3] <- (statistics[i, 1] + statistics[i, 2]) / 2
		#	statistics[i, 4] <- statistics[i, 3] * 0.2
		#}
		
		for (i in 1:nl) {
			b <- methods::new("GDALRasterBand", x@file@transient, i)
			rgdal::GDALcall(b, "SetStatistics", as.double(statistics[i,]))
		}
	}
	
	if(x@file@options[1] != "") {
		rgdal::saveDataset(x@file@transient, x@file@name, options=x@file@options)
	} else {
		rgdal::saveDataset(x@file@transient, x@file@name)	
	}
	
	rgdal::GDAL.close(x@file@transient) 
	
	if (nl > 1) {
		out <- brick(x@file@name)
	} else {
		out <- raster(x@file@name)
	}
	
	if (! out@data@haveminmax ) {
		out@data@min <- statistics[, 1]
		out@data@max <- statistics[, 2]
		out@data@haveminmax <- TRUE
	}

	return(out)
}


