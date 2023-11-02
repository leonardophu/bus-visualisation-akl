#Attempt the problem in ggmap
library(ggmap)
library(gganimate)
library(httr)
# No need to load gganimate and httr for just fetching a map

bbox = c(174.60639400225304, -37.11639297694985, 175.08353095289567, -36.6479440556029)
zoom_level_full = 11
auckland_map = get_stamenmap(bbox, zoom = zoom_level_full, maptype = 'terrain')

# assumes we have the complete dataset
trial_df = read.csv('complete_data.csv')
# Convert status from numeric to factor
trial_df$status = as.factor(trial_df$status)
# Get posixt time 
trial_df$posixct = as.POSIXct(trial_df$timestamps, origin = "1970-01-01", tz = "UTC")

#Sort out visual 
visual <- ggmap(auckland_map) + 
  geom_point(data = trial_df, mapping = aes(x = stop_lon, y = stop_lat, group = trip_id, col = as.factor(status))) + 
  theme(legend.position="none", 
        axis.title.x = element_blank(), 
        axis.title.y = element_blank(), 
        axis.text.x = element_blank(), 
        axis.text.y = element_blank(), 
        axis.ticks.x = element_blank(), 
        axis.ticks.y = element_blank()) + 
  transition_reveal(posixct, keep_last = FALSE) +
  ease_aes('linear') +
  labs(title = 'Time: {frame_along}') +
  enter_fade() + 
  exit_shrink() +
  # Manually set the colors for each status
  scale_color_manual(values = c("0" = "darkgrey", "1" = "blue", "2" = "orange", "3" = "red"))

#Going to take an hour to do, since it gets the number of frames. 2280
system.time(anim_save("gganimate_animation.gif", animation = visual))


