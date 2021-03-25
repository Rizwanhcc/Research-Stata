#http://www.datasciencecentral.com/profiles/blogs/creating-maps-in-r-using-ggplot2-and-maps-libraries?utm_content=bufferb19d4&utm_medium=social&utm_source=twitter.com&utm_campaign=buffer

require(maps)
require(mapdata)
library(ggplot2)
library(ggrepel)


cities = c("Beijing","Shanghai")
global <- map_data("world") ggplot () + geom_polygon(data = global, aes(x=long, y = lat, group = group)) + coord_fixed(1.3)
ggplot() + geom_polygon(data = global, aes(x=long, y = lat, group = group), fill = NA, color = "red") + coord_fixed(1.3)
gg1 <- ggplot() + geom_polygon(data = global, aes(x=long, y = lat, group = group), fill = "green", color = "blue") + coord_fixed(1.3)
gg1
coors <- data.frame( long = c(122.064873,121.4580600), lat = c(36.951968,31.2222200),
                     stringsAsFactors = FALSE
)
#xlim and ylim can be manipulated to zoom in or out of the map
coors$cities <- cities gg1 + geom_point(data=coors, aes(long, lat), colour="red", size=1) +
  ggtitle("World Map") +
  geom_text_repel(data=coors, aes(long, lat, label=cities)) + xlim(0,150) + ylim(0,100)
