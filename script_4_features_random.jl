using NPZ
using DataFrames
using CSV
using CairoMakie
using ColorSchemes
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



function str_to_num_attn(row)
    
    row = replace(row, "[" => "")
    row = replace(row, "]" => "")
    row = parse.(Float64, split(row, ", "))

    return row
end

n_features = "5"
exp = "random"

pft = "beech"
seed = "3"

path_beech = "/Users/anand/Documents/repositories/tst-plot/data/best_model/$(pft)_$(exp)_$(seed)_$(n_features).csv"

pft = "pine"
seed = "8"

path_pine = "/Users/anand/Documents/repositories/tst-plot/data/best_model/$(pft)_$(exp)_$(seed)_$(n_features).csv"

df_beech = DataFrame(CSV.File(path_beech))
df_pine = DataFrame(CSV.File(path_pine))

df_beech.attn = str_to_num_attn.(df_beech.attn)
df_pine.attn = str_to_num_attn.(df_pine.attn)


bins_dist = Matrix(DataFrame(CSV.File("data/bins_dist.csv", header=false)))

bins_dist

function plot_features!(ax, data_frame, element_list)

    h = 0
    for element in element_list
        filtered_df = filter(row -> row.var == element, data_frame)

        filtered_df = sort(filtered_df, :left_index)
        for row in eachrow(filtered_df)
            if row.var == "temp"
                color = p["red"]
            elseif row.var == "precip"
                color = p["blue"]
            elseif row.var == "rad"
                color = p["yellow"]
            elseif row.var == "lai"
                color = p["green"]
            elseif row.var == "age"
                color = p["purple"]
            else
                color = "black"
            end

            x1, y1 = row.left_index, h
            x2, y2 = row.right_index-1, h-0.5
            rect = Point2f[(x1, y1), (x2, y1), (x2, y2), (x1, y2)]
            poly!(ax,rect, color = color)
            text!(ax, 0, h, text = row.aggregator)
            lines!(ax, [row.left_index:row.right_index-1;], h.+(row.right_index - row.left_index)*row.attn, color = color)
            h = h-5
            
            ice = npzread("data/best_model/$(pft)_$(exp)_$(seed)_5_ice_$(var_index)_individual.npy")

        end
    end

    return ax
end

f = Figure(size=(1200, 400))
ax_1 = Axis(f[1:4,1:2],
    xgridvisible=false, ygridvisible=false,)
ax_2 = Axis(f[5,1:2],
    xgridvisible=false, ygridvisible=false,)
ax_3 = Axis(f[6:9,1:2],
    xgridvisible=false, ygridvisible=false,)
ax_4 = Axis(f[10,1:2],
    xgridvisible=false, ygridvisible=false,)


element_list = ["precip", "temp", "rad", "lai", "age"]
plot_features!(ax_1, df_beech, ["precip", "temp", "rad"])
plot_features!(ax_2, df_beech, ["lai", "age"])

plot_features!(ax_3, df_pine, ["precip", "temp", "rad"])
plot_features!(ax_4, df_pine, ["lai", "age"])
vlines!(ax_1, [73, 2*73], color = :grey20, linestyle = :dash)
vlines!(ax_3, [73, 2*73], color = :grey20, linestyle = :dash)

xlims!(ax_1, 0, 219)
xlims!(ax_2, 0, 101)
xlims!(ax_3, 0, 219)
xlims!(ax_4, 0, 101)

ylims!(ax_1, -16, 3)
ylims!(ax_2, -2, 3)
ylims!(ax_3, -16, 3)
ylims!(ax_4, -2, 3)

hidespines!(ax_1, :l, :t, :r)
hidespines!(ax_2, :l, :t, :r)
hidespines!(ax_3, :l, :t, :r)
hidespines!(ax_4, :l, :t, :r)

hideydecorations!(ax_1)
hideydecorations!(ax_2)
hideydecorations!(ax_3)
hideydecorations!(ax_4)

f

save("images/best_xtree_features_random.png", f)

