*====South Asia Map in STAT=====
https://www.researchgate.net/publication/299013667_HOW_TO_DRAW_MAPS_IN_STATA


ssc install spmap
ssc install shp2dta
shp2dta using ne_110m_admin_0_countries, data(worlddata) coor(worldcoor) genid(id) 
shp2dta using ne_10m_admin_0_countries, data(worlddata) coor(worldcoor) genid(id) type: 5
generate length = length(ADMIN)
spmap length using worldcoor.dta, id(id)
spmap length using worldcoor.dta, id(id) fcolor(Blues) clnumber(5) legend(symy(*2) symx(*2) size(*2)) 
spmap length using worldcoor.dta if ADMIN=="Bangladesh" | ADMIN=="India" | ADMIN=="Pakistan", id(id
