
install.packages(c("waffle", "extrafont"))

library(waffle)
library(extrafont)

font_import()

# check that Font Awesome is imported
fonts()[grep("Awesome", fonts())]
# [1] "FontAwesome"


# this should be fine for Mac OSX
loadfonts()
# use this if things look odd in RStudio under Windows
loadfonts(device = "win")

waffle(c(50, 30, 15, 5), rows = 5, title = "Your basic waffle chart")

waffle(c(50, 30, 15, 5), rows = 5, use_glyph = "fa-university", glyph_size = 6, 
       title = "Look I made an infographic using R!")
