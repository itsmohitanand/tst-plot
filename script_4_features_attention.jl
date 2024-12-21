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

n_features = "5"

function str_to_num_attn(row)
    
    row = replace(row, "[" => "")
    row = replace(row, "]" => "")
    row = parse.(Float64, split(row, ", "))

    return row
end

pft = "beech"
seed = "5"
exp = "attention"

path_beech = "/Users/anand/Documents/repositories/tst-plot/data/best_model/$(pft)_$(exp)_$(seed)_$(n_features).csv"

pft = "pine"
seed = "2"
exp = "attention"

path_pine = "/Users/anand/Documents/repositories/tst-plot/data/best_model/$(pft)_$(exp)_$(seed)_$(n_features).csv"

df_beech = DataFrame(CSV.File(path_beech))
df_pine = DataFrame(CSV.File(path_pine))

beech_y = npzread("data/xtree_model_pred/beech/attention/0/y_test_seed_$(seed).npy")[:,1]
pine_y = npzread("data/xtree_model_pred/pine/attention/0/y_test_seed_$(seed).npy")[:,1] 

fn_b = ecdf(beech_y)
fn_p = ecdf(pine_y)

df_beech.attn = str_to_num_attn.(df_beech.attn)
df_pine.attn = str_to_num_attn.(df_pine.attn)

month_labels = repeat(["Jan", "Apr", "July", "Oct"], 3)
month_ticks = [0.2, 18.2, 36.4, 55.0, 73.2, 91.2, 109.4, 128.0, 146.2, 164.2, 182.4, 201.0]

month_ticklabels = (month_ticks, month_labels)

bins_dist = Matrix(DataFrame(CSV.File("data/bins_dist.csv", header=false)))

bins_dist

function plot_features!(ax, ax_list, data_frame, element_list, fn, pft, exp, seed)

    h = 0
    ax_ind = 1
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
            lines!(ax, [row.left_index:row.right_index-1;], h.+(row.right_index - row.left_index)*row.attn, color = color)
            h = h-5
            var_index = row.index            
            
            ice = npzread("data/best_model/$(pft)_$(exp)_$(seed)_5_ice_$(var_index)_individual.npy")
            # grid_values = npzread("data/best_model/$(pft)_$(exp)_$(seed)_5_ice_$(var_index)_grid_values.npy")
            
            for i in 1:500
                y = fn.(ice[i, :])
                lines!(ax_list[ax_ind], y*100, color = (:grey80, 0.1), linewidth=1)
            end
            lines!(ax_list[ax_ind], fn.(median(ice, dims=1)[1,:])*100, color = (color, 0.9), linewidth=2)

            
            ax_ind+=1

        end
    end

    return ax
end

f = Figure(size=(1200, 600))
ax_1 = Axis(f[1:4,1:2],
    xgridvisible=false, ygridvisible=false, xticks = month_ticklabels, xticklabelrotation = pi/3)
ax_2 = Axis(f[5,1:2],
    xgridvisible=false, ygridvisible=false,)
ax_3 = Axis(f[1:4,4:5],
    xgridvisible=false, ygridvisible=false, xticks = month_ticklabels, xticklabelrotation = pi/3)
ax_4 = Axis(f[5,4:5],
    xgridvisible=false, ygridvisible=false,)

p_list = Int.(collect(range(5, 95, length=3)))
p_list = [L"q_{5}", L"q_{50}", L"q_{95}"]

ax_5_list = [Axis(f[i, 3], yticks=([0, 50, 100], [L"q_{0}", L"q_{50}", L"q_{100}"]),
    xgridvisible=false, ygridvisible=false, xticks=([1,13,25],  p_list), ylabel="Biomass loss") for i=1:5]

ax_6_list = [Axis(f[i, 6], yticks=([0, 50, 100], [L"q_{0}", L"q_{50}", L"q_{100}"]),
    xgridvisible=false, ygridvisible=false, xticks=([1,13,25],  p_list), ylabel="Biomass loss") for i=1:5]

# element_list = ["precip", "temp", "rad", "lai", "age"]

plot_features!(ax_1, ax_5_list[1:4], df_beech, ["precip", "temp", "rad"], fn_b, "beech", "attention", 5)
plot_features!(ax_2, [ax_5_list[5]], df_beech, ["lai", "age"], fn_b, "beech", "attention", 5)

plot_features!(ax_3,ax_6_list[1:4],  df_pine, ["precip", "temp", "rad"], fn_p, "pine", "attention", 2)
plot_features!(ax_4,[ax_6_list[5]], df_pine, ["lai", "age"], fn_p, "pine", "attention", 2)

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

for i=1:5
    hidespines!(ax_5_list[i], :r, :t)
    hidespines!(ax_6_list[i], :r, :t)
end

hideydecorations!(ax_1)
hideydecorations!(ax_2)
hideydecorations!(ax_3)
hideydecorations!(ax_4)

f


save("images/best_xtree_features.png", f)

percentile

ice = npzread("data/best_model/$(pft)_$(exp)_$(seed)_5_ice_$(var_index)_individual.npy")

mean(ice, dims=1)

fn_b.(ice)