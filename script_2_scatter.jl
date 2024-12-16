using NPZ
using CairoMakie
using ColorSchemes
using StatsBase

p = Dict(
    "red"=> parse(Colorant, "#FF1F5B"),
    "green"=> parse(Colorant, "#00CD6C"),
    "blue"=> parse(Colorant, "#009ADE"),
    "purple"=> parse(Colorant, "#AF58BA"),
    "yellow"=> parse(Colorant, "#FFC61E"),
    "orange" => parse(Colorant, "#F28522"),
    "grey"=> parse(Colorant, "#A0B1BA"),
    "brown" => parse(Colorant, "#A6761D")
)

function plot_scatter!(ax, model, pft)
    y_true = npzread("data/$(pft)_$(model)_y.npy")[:]
    y_pred = npzread("data/$(pft)_$(model)_y_pred.npy")[:]

    scatter!(ax, y_true, y_pred, color = p["grey"], markersize=4)
    lines!(ax, [0, .15], [0, .15], color=p["brown"], linestyle=:dash)


    hidespines!(ax, :r, :t)

    return ax
end

function plot_hist!(ax, pft)
    model = "lr"
    y_true = npzread("data/$(pft)_$(model)_y.npy")[:]

    hist!(ax, y_true, color=p["grey"], normalization = :pdf, bins=100)
    vlines!(ax, percentile(y_true, 90), ymin=0, color="black", linestyle=:dashdot)

    hidespines!(ax, :r, :t)

    return ax
end


fontsize_theme = Theme(fontsize = 18)
set_theme!(fontsize_theme)

f = Figure(size = (1400, 600))

ax_1 = Axis(f[1,1], xgridvisible = false, ygridvisible=false)
ax_2 = Axis(f[1,2], xgridvisible = false, ygridvisible=false)
ax_3 = Axis(f[1,3], xgridvisible = false, ygridvisible=false)
ax_4 = Axis(f[1,4], xgridvisible = false, ygridvisible=false)

ax_5 = Axis(f[2,1], xgridvisible = false, ygridvisible=false)
ax_6 = Axis(f[2,2], xgridvisible = false, ygridvisible=false)
ax_7 = Axis(f[2,3], xgridvisible = false, ygridvisible=false)
ax_8 = Axis(f[2,4], xgridvisible = false, ygridvisible=false)



plot_hist!(ax_1, "beech")
plot_scatter!(ax_2, "lr", "beech")
plot_scatter!(ax_3, "xt", "beech")
plot_scatter!(ax_4, "transformer", "beech")
plot_hist!(ax_5, "pine")
plot_scatter!(ax_6, "lr", "pine")
plot_scatter!(ax_7, "xt", "pine")
plot_scatter!(ax_8, "transformer", "pine")

f


