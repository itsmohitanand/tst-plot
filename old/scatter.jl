using CairoMakie
using DataFrames
using CSV

include("../plots/core.jl")


pine_y_path = "/Users/anand/Documents/repositories/plots/tst-plot/data/pine_y.csv"
pine_y1_path = "/Users/anand/Documents/repositories/plots/tst-plot/data/pine_y_pred1.csv"
pine_y3_path = "/Users/anand/Documents/repositories/plots/tst-plot/data/pine_y_pred3.csv"

beech_y_path = "/Users/anand/Documents/repositories/plots/tst-plot/data/beech_y.csv"
beech_y1_path = "/Users/anand/Documents/repositories/plots/tst-plot/data/beech_y_pred1.csv"
beech_y3_path = "/Users/anand/Documents/repositories/plots/tst-plot/data/beech_y_pred3.csv"


pine_y = Matrix(DataFrame(CSV.File(pine_y_path)))[:,1]
pine_y1 = Matrix(DataFrame(CSV.File(pine_y1_path)))[:,1] 
pine_y2 = Matrix(DataFrame(CSV.File(pine_y3_path)))[:,1] 

beech_y = Matrix(DataFrame(CSV.File(beech_y_path)))[:,1]
beech_y1 = Matrix(DataFrame(CSV.File(beech_y1_path)))[:,1]
beech_y2 = Matrix(DataFrame(CSV.File(beech_y3_path)))[:,1]

palette

f = Figure(resolution=(800,400))
ax_pine = Axis(f[1,1])
ax_pine_e = Axis(f[1,2])

alpha = 0.4
scatter!(ax_pine, pine_y, pine_y1, color=(palette[3], alpha))
lines!(ax_pine, [0.015, 0.14], [0.015, 0.14], color="black", linestyle=:dashdot )
scatter!(ax_pine_e, pine_y, pine_y2, color=(palette[5], alpha))
lines!(ax_pine_e, [0.015, 0.14], [0.015, 0.14], color="black", linestyle=:dashdot )

f