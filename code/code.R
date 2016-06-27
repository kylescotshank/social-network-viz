
library("rjson")
library("jsonlite")

l <- fromJSON("https://raw.githubusercontent.com/michaeljules/social-network-viz/master/data/data.js",flatten=TRUE)

# l <- fromJSON("/Users/michael/GitHub/social-network-viz/data/data.js",flatten=TRUE)

#####
# Install and Load Libraries
#####

#install.packages("networkD3")
library("networkD3")

#######
# Translate Data to Network Object
#######

networkData <- l$reducedMatrix
rownames(networkData) <- paste0(l$publicConnections$firstName[1:499]," ",l$publicConnections$lastName[1:499])
#rownames(networkData) <- 0:498
#colnames(networkData) <- 0:498
colnames(networkData) <- rownames(networkData) 

library(igraph) 
g <- graph.adjacency(networkData,mode="undirected")
class(g)

# Add attributes to the network, vertices, or edges:
V(g)$industry <- l$publicConnections$industry[1:499]
table(V(g)$industry)
V(g)$location <- l$publicConnections$location.name[1:499]
table(V(g)$location)
V(g)$names <- paste0(l$publicConnections$firstName[1:499]," ",l$publicConnections$lastName[1:499])
V(g)$click <- l$publicConnections$pictureUrl[1:499]
V(g)$country <- l$publicConnections$location.country.code[1:499]
V(g)$headline <- l$publicConnections$headline[1:499]

# Simplify Job Headline Variable 
V(g)$position <- "Business | Marketing | Sales"
V(g)$position[grepl("graphic|design|art|Museum|animator",ignore.case = TRUE, V(g)$headline)==TRUE] <- "Art | Design"
#V(g)$position[grepl("analyst|strategist|analytics|analytic",ignore.case = TRUE, V(g)$headline)==TRUE] <- "Analytics"
V(g)$position[grepl("candidate|student|professor|ucla|ucsd|university|medical|hospital|research|shell",ignore.case = TRUE, V(g)$headline)==TRUE] <- "Data | Science | Engineering"
V(g)$position[grepl("founder|ceo|president|manager|Marketing|consultant|talent|search|recruiter|recruiting|Acquisition|human|networker|sales",ignore.case = TRUE, V(g)$headline)==TRUE] <- "Business | Marketing | Sales"
#V(g)$position[grepl("market",ignore.case = TRUE, V(g)$headline)==TRUE] <- "Marketing"
#V(g)$position[grepl("talent|search|recruiter|recruiting|Acquisition|human|networker",ignore.case = TRUE, V(g)$headline)==TRUE] <- "Recruiting"
V(g)$position[grepl("data scientist|data science|statistician|Statist|analyst|strategist|analytics|analytic",ignore.case = TRUE, V(g)$headline)==TRUE] <- "Data | Science | Engineering"

#######
# Create Node Dataset
#######

nodes <- as.data.frame(cbind(paste0(l$publicConnections$firstName[1:499]," ",l$publicConnections$lastName[1:499]),l$publicConnections$industry[1:499],l$publicConnections$location.name[1:499],l$publicConnections$pictureUrl[1:499],l$publicConnections$location.country.code[1:499]))
colnames(nodes) <- c("name","industry","location","click","country")

#######
# Create Links Dataset
#######
links <- as.data.frame(get.edgelist(g))
colnames(links) <- c("source","target")

#######
# Calculate Network Centrality
#######

b <- betweenness(g, v=V(g), directed = FALSE, weights = NULL,
                 nobigint = TRUE, normalized = FALSE)
V(g)$betweenness <- sqrt(b)
V(g)$betweenness

eb <- edge.betweenness.community(g)
eb$merges
str(eb)
########
# Remove Isolates
#######

#identify isolated nodes
bad.vs <- V(g)[degree(g) == 0] 

# remove isolated nodes
g <- delete.vertices(g, bad.vs)

#######
# Calculate Neighborhood Clusters
######

# The neighborhood of a given order o of a vertex v includes all vertices which are closer to v than the order. Ie. order 0 is always v itself, order 1 is v plus its immediate neighbors, order 2 is order 1 plus the immediate neighbors of the vertices in order 1, etc.

fgc <- cluster_fast_greedy(g)
V(g)$neighborhood <- fgc$membership
table(fgc$membership)
#V(g)$neighborhood[]

cle <- cluster_leading_eigen(g)
table(cle$membership)
V(g)$cle <- cle$membership

# 1. c3 <- cluster_walktrap(g)
# 3. c3 <- cluster_infomap(g)
# 4. 
c3 <- cluster_label_prop(g)
# 5. c3 <- cluster_leading_eigen(g)
# 6. c3 <- cluster_louvain(g)
# 7. c3 <- cluster_edge_betweenness(g)
table(c3$membership)
V(g)$c3 <- c3$membership

# Label Group Memberships
c3$group <- c3$membership
#c3$group <- "Misc"
c3$group[c3$membership==1] <- "Visual Design"
c3$group[c3$membership==2] <- "Data Science"
c3$group[c3$membership==3] <- "Architecture & Planning"
c3$group[c3$membership==4] <- "Media & Marketing"
c3$group[c3$membership==5] <- "Media & Marketing"
c3$group[c3$membership==6] <- "Research"
c3$group[c3$membership==7] <- "Engineering"
c3$group[c3$membership==8] <- "Media & Marketing"
c3$group[c3$membership==9] <- "Business"
c3$group[c3$membership==10] <- "Politics"
c3$group[c3$membership==11] <- "Media & Marketing"
#c3$group[c3$membership>11] <- "Misc"
c3$group[c3$membership==12] <- "Data Science"
c3$group[c3$membership==13] <- "Data Science"
c3$group[c3$membership==14] <- "Other"
c3$group[c3$membership==15] <- "Other"
c3$group[c3$membership==16] <- "Other"
c3$group[c3$membership==17] <- "Data Science"
c3$group[c3$membership==18] <- "Other"
c3$group[c3$membership==19] <- "Engineering"
c3$group[c3$membership==20] <- "Politics"
c3$group[c3$membership==21] <- "Media & Marketing"

table(c3$group)
table(c3$membership,c3$group)
V(g)$c3 <- c3$group

library(networkD3)
# Translate to iGraph to D3
g_d3 <- igraph_to_networkD3(g)

## Add Attributes
g_d3$nodes$location <- V(g)$location
g_d3$nodes$industry <- V(g)$industry
g_d3$nodes$click    <- V(g)$click
g_d3$nodes$betweenness  <- V(g)$betweenness
g_d3$nodes$country <- V(g)$country
g_d3$nodes$position <- V(g)$position
g_d3$nodes$group <- V(g)$neighborhood
g_d3$nodes$headline <- V(g)$headline
g_d3$nodes$cle <- V(g)$cle
g_d3$nodes$c3 <- V(g)$c3


forceNetwork(Links=g_d3$links,
             Nodes=g_d3$nodes,
             width=960,
             height=700,
             NodeID = 'headline', 
             Group  = 'c3',
             # radiusCalculation = 0,
             radiusCalculation = JS("Math.sqrt(d.nodesize)+5"),
             Nodesize = 'betweenness',
             #linkWidth = JS("function(d) { return Math.sqrt(d.value); }"),
             charge = -60,
             linkWidth = .4,
             colourScale = JS("d3.scale.category10()"),
             # linkColour = "rgb(230,159,0,200, maxColorValue=255)",
             linkColour = "goldenrod",
             zoom = FALSE,
             legend = TRUE,
             opacity = .85,
             opacityNoHover = 0,
             #  linkDistance = 10,
             bounded = FALSE,
             fontFamily = "San Francisco",
             fontSize = 14) %>%
  saveNetwork(file = '/Users/michael/GitHub/social-network-viz/html/linkedin-network-viz.html')





#####
# Write Data Object To JSON File 
####

library("jsonlite")
library("rjson")
exportJson <- toJSON(g_d3)
write(exportJson, file="/Users/michael/GitHub/social-network-viz/data/output_data.json")



