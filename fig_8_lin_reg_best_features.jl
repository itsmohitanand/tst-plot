using NPZ
using DataFrames
using CSV
using CairoMakie
using ColorSchemes
using Colors
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



beech_mean_x = npzread("data/features/beech_5_mean_x_features.npy")
beech_x = npzread("data/features/beech_5_x_features.npy")
beech_y = npzread("data/features/beech_5_y.npy")



beech_mean_x = hcat(beech_mean_x, zeros(size(beech_mean_x, 1)))
beech_x = hcat(beech_x, zeros(size(beech_x, 1)))

w_mean_x = beech_mean_x \ beech_y
w_x = beech_x \ beech_y

beech_y_pred_mean_X = beech_mean_x * w_mean_x
beech_y_pred_X = beech_x * w_x

f = Figure(resolution = (800, 600))
ax_1 = Axis(f[1, 1], xlabel = "Measured", ylabel = "Predicted", title = "Mean X")
ax_2 = Axis(f[1, 2], xlabel = "Measured", ylabel = "Predicted", title = "X")

scatter!(ax_1, beech_y, beech_y_pred_mean_X, color = p["blue"], markersize = 3, label = "Measured vs Predicted")
scatter!(ax_2, beech_y, beech_y_pred_X, color = p["blue"], markersize = 3, label = "Measured vs Predicted")
f


#define r2 function
function r2_score(y, y_pred)
    ss_res = sum((y - y_pred).^2)
    ss_tot = sum((y .- mean(y)).^2)
    return 1 - ss_res/ss_tot
end

r2_mean_x = r2_score(beech_y, beech_y_pred_mean_X)
r2_x = r2_score(beech_y, beech_y_pred_X)