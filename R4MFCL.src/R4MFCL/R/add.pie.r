addpie <- function (x, labels = names(x), edges = 200, radius = 0.8, density = NULL,
    angle = 45, col = NULL, border = NULL, lty = NULL, main = NULL, lat = 0, long =0, rscale = 1,
    ...)
{
#    if (!is.numeric(x) || any(is.na(x) | x <= 0))
#        stop("pie: `x' values must be positive.")
#    if (is.null(labels))
#        labels <- as.character(1:length(x))
    radius <- sqrt(sum(x)/3.148) * rscale
    x <- c(0, cumsum(x)/sum(x))
     dx <- diff(x)
#    pin <- par("pin")
#    xlim <- ylim <- c(-1, 1)
#    if (pin[1] > pin[2])
#        xlim <- (pin[1]/pin[2]) * xlim
#    else ylim <- (pin[2]/pin[1]) * ylim
#    plot.new()
#    plot.window(xlim, ylim, "", asp = 1)
    nx <- length(dx)
    if (is.null(col))
        col <- if (is.null(density))
            c("white", "lightblue", "mistyrose", "lightcyan",
                "lavender", "cornsilk")
        else par("fg")
    col <- rep(col, length = nx)
    border <- rep(border, length = nx)
    lty <- rep(lty, length = nx)
    angle <- rep(angle, length = nx)
    density <- rep(density, length = nx)
    for (i in 1:nx) {
        n <- max(2, floor(edges * dx[i]))
        t2p <- 2 * pi * seq(x[i], x[i + 1], length = n)
        xc <- c(cos(t2p), 0) * radius
        yc <- c(sin(t2p), 0) * radius
        polygon(xc + long, yc + lat, density = density[i], angle = angle[i],
            border = border[i], col = col[i], lty = lty[i])
        t2p <- 2 * pi * mean(x[i + 0:1])
        xc <- cos(t2p) * radius
        yc <- sin(t2p) * radius
        if (!is.na(lab <- labels[i]) && lab != "") {
#            lines(c(1, 1.05) * xc, c(1, 1.05) * yc)
            text(1 * (xc+long), 1 * (yc+lat), lab, cex=0.75, xpd = TRUE, adj = ifelse(xc <
                0, 1, 0), ...)
        }
    }
#    title(main = main, ...)
    invisible(NULL)
}
