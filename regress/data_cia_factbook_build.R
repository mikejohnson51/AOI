# https://www.naturalearthdata.com/downloads/50m-cultural-vectors/50m-admin-0-countries-2/

  # Build CIA Factbook!

w = read_sf('/Users/mikejohnson/Downloads/ne_50m_admin_0_countries/ne_50m_admin_0_countries.shp')
w = w[,-c(74:94)]
w = w[,-c(32:35)]
w = w[,-c(1)]
names(w)

cat = read.csv('/Users/mikejohnson/Downloads/factbook.csv-master/categories.csv', stringsAsFactors = FALSE)
codes = read.csv('/Users/mikejohnson/Downloads/factbook.csv-master/codes.csv', stringsAsFactors = FALSE)

ww = w[c(w$ISO_A3 %in% codes$A2),]

path = paste0('/Users/mikejohnson/Downloads/factbook.csv-master/data/c', cat$Num[1],'.csv')

start = data.frame(Name = codes$Name, stringsAsFactors = TRUE)

for(i in 1:NROW(cat)){
  path = paste0('/Users/mikejohnson/Downloads/factbook.csv-master/data/c', cat$Num[i],'.csv')
  name = cat$Name[i]
  tmp = read.csv(path, stringsAsFactors = F)
  tmp[,3] <- as.numeric(gsub('[$,]', '', tmp[,3]))
  tmp = tmp[,-1]
  names(tmp) = c('Name', name)
  start = merge(start, tmp, "Name", all.x = T, all.y  =T)
}


test = merge(start, codes, by = "Name")

xx = merge(ww, test, by.x = "ISO_A3", by.y = "A2", all.x = TRUE)
xx = janitor::clean_names(xx)

countries = xx %>% st_transform(AOI::aoiProj)


save(countries, file = "./data/cia_world.rda", compress  = "xz")



# first define a set of layout/design parameters to re-use in each map
mapTheme <- function() {
  theme_void() +
    theme(
      text = element_text(size = 7),
      plot.title = element_text(size = 11, color = "#1c5074", hjust = 0, vjust = 2, face = "bold"),
      plot.subtitle = element_text(size = 8, color = "#3474A2", hjust = 0, vjust = 0),
      axis.ticks = element_blank(),
      legend.direction = "vertical",
      legend.position = "right",
      plot.margin = margin(1, 1, 1, 1, 'cm'),
      legend.key.height = unit(1, "cm"), legend.key.width = unit(0.4, "cm")
    )
}

names(countries)
unique(countries$subregion)
ca = countries %>% filter(subregion =="Central America") %>% select(73, 18)
world = countries  %>% select(73)



ggplot(world) +
  geom_sf(aes(fill = world[[1]] ), color = NA) +
  scale_fill_gradient(paste0(names(world)[1], ' \n')) +
  labs(
    title = 'CIA World Factbook',
    subtitle = names(world)[1],
    caption = "Source: CIA World Factbook"
  ) + mapTheme()

lon = st_coordinates(st_centroid(ca))[,2]
lat = st_coordinates(st_centroid(ca))[,1]

ggplot(ca) +
  geom_sf(aes(fill = ca[[1]] ), color = NA) +
  scale_fill_gradient(paste0(names(ca)[1], ' \n')) +
  geom_label(aes(lat,lon, label = name), alpha = 0.8, size = 2) +
  labs(
    title = 'CIA World Factbook',
    subtitle = names(ca)[1],
    caption = "Source: CIA World Factbook"
  ) + mapTheme()


janitor::make_clean_names(names(ca), case = "upper_camel")




