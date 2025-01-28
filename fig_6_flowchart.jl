using CairoMakie

w_size, h_size = 1200, 1200

function plt_box!(ax, x, y, w, h, txt; color=:black)
    poly!(ax, Rect(x, y, w, h), color=:transparent, strokecolor=:grey20, strokewidth = 2)
    text!(ax, txt, position = Point2f(x+w/2, y+h/2), align = (:center,:center), fontsize = 24, color=color, word_wrap_width=350)
end



f = Figure(size = (w_size,h_size))

ax = Axis(f[1,1], xgridvisible = false,
    ygridvisible = false)
hidespines!(ax)
hidedecorations!(ax)
xlims!(-w_size/2, w_size/2)
ylims!(-h_size/2, h_size/2)

plt_box!(ax, -300, 350, 150, 80,  "Physiological forest model (FORMIND)")
plt_box!(ax, -300, 250, 150, 80,  "Forest Structures (aggregated) - Age, LAI, Biomass loss, Species")
f
plt_box!(ax, 300, 450, 150, 80,  "Weather generator (AWEGEN)")
plt_box!(ax, 300, 350, 150, 80,  "Weather data - Solar radiation, Temperature, Precipitation")
plt_box!(ax, 300, 250, 150, 80,  "Weather data (aggregated) - 5 day 
averages")


plt_box!(ax, 0, 150, 150, 80,  "Combined input modalities (forest structure and weather) and output (biomass loss)")

plt_box!(ax, -100, 50, 150, 80,  "Linear regression")
plt_box!(ax, 100, 50, 150, 80,  "Extra tree regressor")

plt_box!(ax, 0, -150, 150, 80,  "Generate random pool of candidates")

plt_box!(ax, -450, 50, 150, 80,  "Transformer model")
plt_box!(ax, -450, -50, 150, 80,  "Extract attention weights")
plt_box!(ax, -450, -150, 150, 80,  "Generate atttenion pool of candidates")

plt_box!(ax, -200, -250, 150, 80,  "Subselect best candidates using sequential forward floating selection")

plt_box!(ax, -200, -350, 150, 80,  "Interpret the best model with ICE and PDP")


f

