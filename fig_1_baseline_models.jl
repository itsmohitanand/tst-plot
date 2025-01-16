using NPZ
using CairoMakie
using ColorSchemes
using StatsBase
using Colors


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

function r2(y_true, y_pred)
    ssr = sum((y_true - y_pred).^2)
    sst = sum((y_true .- mean(y_pred)).^2)
    r2 = 1-(ssr/sst)
    return r2
end

function plot_scatter!(ax, model, pft)
    y_true = npzread("data/$(pft)_$(model)_y.npy")[:]
    y_pred = npzread("data/$(pft)_$(model)_y_pred.npy")[:]

    if model == "lr"
        legend = "Linear"
    elseif model == "xt"
        legend = "ExtraTrees"
    elseif model == "transformer"
        legend = "Transformer"
    end

    r_squared = round(r2(y_true, y_pred), digits=2)
    
    legend = "$(legend) | R2: $(r_squared)"
    
    text!(ax, 0, 0.12, text = legend)
    scatter!(ax, y_true, y_pred, color = p["grey"], markersize=3)
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

ax_1 = Axis(f[1,1], xgridvisible = false, ygridvisible=false, ylabel = "Beech", xticks=[0:0.05:0.15;])
ax_2 = Axis(f[1,2], xgridvisible = false, ygridvisible=false,ylabel = "Biomass loss (pred)")
ax_3 = Axis(f[1,3], xgridvisible = false, ygridvisible=false)
ax_4 = Axis(f[1,4], xgridvisible = false, ygridvisible=false)

ax_5 = Axis(f[2,1], xgridvisible = false, ygridvisible=false, ylabel = "Pine", xticks=[0:0.05:0.15;], xlabel = "Biomass loss [-]")
ax_6 = Axis(f[2,2], xgridvisible = false, ygridvisible=false, xlabel = "Biomass loss (true)", ylabel = "Biomass loss (pred)")
ax_7 = Axis(f[2,3], xgridvisible = false, ygridvisible=false, xlabel = "Biomass loss (true)")
ax_8 = Axis(f[2,4], xgridvisible = false, ygridvisible=false, xlabel = "Biomass loss (true)")

f
plot_hist!(ax_1, "beech")
xlims!(ax_1, 0.01, 0.15)
ylims!(ax_1, 0, 200)
plot_scatter!(ax_2, "lr", "beech")
plot_scatter!(ax_3, "xt", "beech")
plot_scatter!(ax_4, "transformer", "beech")
plot_hist!(ax_5, "pine")
xlims!(ax_5, 0.01, 0.15)
ylims!(ax_5, 0, 150)
plot_scatter!(ax_6, "lr", "pine")
plot_scatter!(ax_7, "xt", "pine")
plot_scatter!(ax_8, "transformer", "pine")


alphabet = ["a)","b)","c)","d)","e)","f)","g)","h)",]
for i = 1:2
    for j = 1:4
        label =  alphabet[4*(i-1) + j,]
        
        Label(f[i,j, TopLeft()],
        label,
        font = "TeX Gyre Heros Bold",
        fontsize = 22,
        padding = (0, 50, -10, 0),
        halign = :right )

    end
end

f

# g1 = GridLayout(f[:, 1], alignmode = Outside(10))
# g2 = GridLayout(f[:, 2:end], alignmode = Outside(10))
# f

# box1 = Box(f[:, 1, Makie.GridLayoutBase.Outer()], cornerradius = 10, color = :transparent, strokecolor = :tomato, alignmode = Outside(0, -15, -10, -10))
# f
# box2 = Box(f[:, 2:end, Makie.GridLayoutBase.Outer()], cornerradius = 10, color = :transparent, strokecolor = :teal,
# alignmode = Outside(0, -15, -10, -10))


# box1 = Box(f[:, 1, Makie.GridLayoutBase.Outer()], cornerradius = 10, color = (:tomato, 0.1), strokecolor = :tomato)
# f
# box2 = Box(f[:, 2:end, Makie.GridLayoutBase.Outer()], cornerradius = 10, color = (:teal, 0.1), strokecolor = :teal)
# f

# Makie.translate!(box1.blockscene, 0, 0, -100)
# f
# Makie.translate!(box2.blockscene, 0, 0, -100)
# f
# for i=1:2
#     for j=1:4
#         Axis(f[i, j], backgroundcolor = :white)
#     end
# end



save("images/fig_1_baseline_models.pdf", f)
