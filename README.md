<!-- README.md is generated from README.Rmd. Please edit that file -->
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
