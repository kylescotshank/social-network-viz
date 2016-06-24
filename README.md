<!-- README.md is generated from README.Rmd. Please edit that file -->
<a href="https://d3js.org"><img src="https://d3js.org/logo.svg" align="left" hspace="10" vspace="6"></a>

<iframe src="https://raw.githubusercontent.com/michaeljules/social-network-viz/master/html/linkedin-network-viz.html">
</iframe>
``` r

library("rjson")
library("jsonlite")
#> 
#> Attaching package: 'jsonlite'
#> The following objects are masked from 'package:rjson':
#> 
#>     fromJSON, toJSON

l <- fromJSON("https://raw.githubusercontent.com/michaeljules/social-network-viz/master/data/data.js",flatten=TRUE)

#install.packages("networkD3")
library("networkD3")

#######
# Translate Data to Network Object
#######

networkData <- l$reducedMatrix
dim(networkData)
#> [1] 499 499
```

Including Plots
---------------

You can also embed plots, for example:

![](README-pressure-1.png)

Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.
