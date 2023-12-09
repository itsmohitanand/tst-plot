using DataFrames
using CSV
using CairoMakie
using StatsBase

include("../plots/core.jl")

k1_beech_path = "/Users/anand/Documents/repositories/plots/data/tst/k1_beech.csv"
k2_beech_path = "/Users/anand/Documents/repositories/plots/data/tst/k3_beech.csv"
k1_pine_path = "/Users/anand/Documents/repositories/plots/data/tst/k1_pine.csv"
k2_pine_path = "/Users/anand/Documents/repositories/plots/data/tst/k3_pine.csv"


k1_beech = DataFrame(CSV.File(k1_beech_path, header=false)) |> Matrix
k2_beech = DataFrame(CSV.File(k2_beech_path, header=false)) |> Matrix
k1_pine = DataFrame(CSV.File(k1_pine_path, header=false)) |> Matrix
k2_pine = DataFrame(CSV.File(k2_pine_path, header=false)) |> Matrix


index1_beech = findmax(mean(k1_beech[2:end, :], dims=1))
index2_beech = findmax(mean(k2_beech[2:end, :], dims=1))

index1_pine = findmax(mean(k1_pine[2:end, :], dims=1))
index2_pine = findmax(mean(k2_pine[2:end, :], dims=1))


f = Figure(resolution=(600,400))

ax = Axis(f[2,1], 
    xgridvisible = false, 
    ygridvisible=false, 
    xticks=([0.5,2.5],["Pine", "Beech"]),
    ylabel=L"R^2")

sc_1 = scatter!(ax, 0.25*ones(10), k1_pine[2:end, index1_pine[2][2]], color=palette[3])
sc_2 =  scatter!(ax, 0.75*ones(10), k2_pine[2:end, index2_pine[2][2]], color=palette[5])


scatter!(ax, 2.25*ones(10), k1_beech[2:end, index1_beech[2][2]], color=palette[3])
scatter!(ax, 2.75*ones(10), k2_beech[2:end, index2_beech[2][2]], color=palette[5])

text!(ax, "$(Int(k1_pine[1, index1_pine[2][2]])) features", 
    position = [Point2f(0.40, 0.33)], 
    rotation= pi/2)

text!(ax, "$(Int(k2_pine[1, index2_pine[2][2]])) features", 
    position = [Point2f(0.90, 0.40)], 
    rotation= pi/2)

text!(ax, "$(Int(k1_beech[1, index1_beech[2][2]])) features", 
    position = [Point2f(2.40, 0.28)], 
    rotation= pi/2)

text!(ax, "$(Int(k2_beech[1, index2_beech[2][2]])) features", 
    position = [Point2f(2.90, 0.37)], 
    rotation= pi/2)


hidespines!(ax, :r, :t)
Legend(f[1,1], [sc_1, sc_2], ["only MSE", "with Entropy"], orientation=:horizontal, framevisible=false)
# hidexdecorations!(ax)
# hideydecorations!(ax)

f

save("tst-plot/images/feature_R2.png", f)
