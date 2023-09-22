getFrame = function(timestamp) {
  grid.newpage()
  timed_data = subset(intData, timestamps == timestamp)
  
  zoomed_points = timed_data %>% filter(lon >= bbox2[1], 
                                        lon <= bbox2[3], 
                                        lat >= bbox2[2], 
                                        lat <= bbox2[4])
  auckland_visual = ggmap(auckland_map) + 
    geom_point(data = timed_data, aes(x = lon, y= lat, color = status), size = 1.5, alpha = 0.5) +
    scale_color_manual(values = colour_scheme) +
    
    # Remove x and y axes
    theme(axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          # Remove the legend
          legend.position = "none")
  
  zoomed_visual = ggmap(auckland_central) + 
    geom_point(data = zoomed_points, aes(x = lon, y= lat, color = status), size = 1.5, alpha = 0.5) +
    scale_color_manual(values = colour_scheme) +
    theme(axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          # Remove the legend
          legend.position = "none")
  
  print(auckland_visual)
  vp <- viewport(x=1, y=1, width=.4, height=.4,
                 just=c("right", "top"))
  pushViewport(vp)
  print(zoomed_visual, newpage = FALSE)
  upViewport()
}

