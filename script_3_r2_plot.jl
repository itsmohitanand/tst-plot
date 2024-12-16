using NPZ
using CairoMakie
using ColorSchemes


p = Dict(
    "red"=>"#FF1F5B",
    "green"=> "#00CD6C",
    "blue"=> "#009ADE",
    "purple"=> "#AF58BA",
    "yellow"=> "#FFC61E",
    "orange" => "#F28522",
    "grey"=> "#A0B1BA",
    "brown" => "#A6761D"
)

data_pine

pft = "pine"
data_pine = npzread("data/r2_cv_$(pft).npy")

pft = "beech"
data_beech = npzread("data/r2_cv_$(pft).npy")

ticks = [5:5:50;] .+0.5
labels = string.([1:10;])

f = Figure(size=(1400,400))
ax1 = Axis(f[1,1], xgridvisible=false, ygridvisible=false, xticks=(ticks, labels))
ax2 = Axis(f[1,2], xgridvisible=false, ygridvisible=false, xticks=(ticks, labels))
f

plt_box!(ax1, data_beech)
plt_box!(ax2, data_pine)

f
function plt_box!(ax, data)
    for j=1:10
        x=zeros(10).+j*5
        boxplot!(ax, x, data[1,j,:], color=p["green"])
        boxplot!(ax, x.+1, data[2,j,:], color=p["purple"])
        boxplot!(ax, x.+2, data[3,j,:], color=p["orange"])

    end

    return ax
end

hidespines!(ax1, :r, :t)
hidespines!(ax2, :r, :t)
f
save("images/feature_r2.png", f)