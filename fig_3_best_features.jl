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

function str_to_num_attn(row)
    
    row = replace(row, "[" => "")
    row = replace(row, "]" => "")
    row = parse.(Float64, split(row, ", "))

    return row
end

pft = "beech"
seed = "5"
exp = "attention"

# pft = "pine"
# seed = "2"
# exp = "attention"

path_features = "/Users/anand/Documents/repositories/tst-plot/data/best_model/$(pft)_$(exp)_$(seed)_5.csv"


df = DataFrame(CSV.File(path_features))

y = npzread("data/xtree_model_pred/beech/attention/0/y_test_seed_$(seed).npy")[:,1]

cdf = ecdf(y)

df.attn = str_to_num_attn.(df.attn)

month_labels = repeat(["Jan", "Apr", "July", "Oct"], 3)
month_ticks = [0.2, 18.2, 36.4, 55.0, 73.2, 91.2, 109.4, 128.0, 146.2, 164.2, 182.4, 201.0]

month_ticklabels = (month_ticks, month_labels)

bins_dist = Matrix(DataFrame(CSV.File("data/bins_dist.csv", header=false)))

function plot_features!(ax, ax_list, element_list, pft, exp, seed, ind_list)
    path_features = "/Users/anand/Documents/repositories/tst-plot/data/best_model/$(pft)_$(exp)_$(seed)_5.csv"
    data_frame = DataFrame(CSV.File(path_features))
    data_frame.attn = str_to_num_attn.(data_frame.attn)

    x = npzread("/Users/anand/Documents/repositories/tst-plot/data/best_model/$(pft)_$(seed)_mean_x_features.npy")
    attn = npzread("/Users/anand/Documents/repositories/tst-plot/data/best_model/$(pft)_$(seed)_sum_attn_x_features.npy")

    h = 0
    i=1
    
    if pft == "beech"
        var_map_dict = Dict(1=>5, 2=>4, 3 =>2,4=>1,5=>3)
    elseif pft == "pine"
        var_map_dict = Dict(1=>3, 2=>2, 3 =>1,4=>5,5=>4)
    end
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
            
            var_ind = var_map_dict[ind_list[i]]
            x_val =  x[:,var_ind]
            y_val = attn[:,var_ind]*50
            
            x_val = ecdf(x_val)(x_val)*100
            
            scatter!(ax_list[ind_list[i]],x_val, y_val, color = (:grey80, 0.2), markersize=4)
            i+=1
            # var_index = row.index            
            
            # ice = npzread("data/best_model/$(pft)_$(exp)_$(seed)_5_ice_$(var_index)_individual.npy")
            # # grid_values = npzread("data/best_model/$(pft)_$(exp)_$(seed)_5_ice_$(var_index)_grid_values.npy")
            
            # for i in 1:500
            #     y = fn.(ice[i, :])
            #     lines!(ax_list[ax_ind], y*100, color = (:grey80, 0.1), linewidth=1)
            # end
            # lines!(ax_list[ax_ind], fn.(median(ice, dims=1)[1,:])*100, color = (color, 0.9), linewidth=2)

        end
    end

    return ax
end

beech_bins = npzread("data/beech_bins.npy")
pine_bins = npzread("data/pine_bins.npy")

# fontsize_theme = Theme(fontsize = 18)
textheme = Theme(fonts=(; regular=texfont(:text),
                        bold=texfont(:bold),
                        italic=texfont(:italic),
                        bold_italic=texfont(:bolditalic)),
                fontsize=18,)

set_theme!(textheme)
f = Figure(size=(1200, 800))
ax_1 = Axis(f[1:4,1:2],
    xgridvisible=false, ygridvisible=false, xticks = month_ticklabels, xticklabelrotation = pi/3)
ax_2 = Axis(f[5,1:2],
    xgridvisible=false, ygridvisible=false,
    xticks = ([1:20:102;],  string.(pine_bins[2,[1:20:102;]])),
    xlabel =  L"LAI [m^2/m^2]",
    )
ax_3 = Axis(f[1:4,4:5],
    xgridvisible=false, ygridvisible=false, xticks = month_ticklabels, xticklabelrotation = pi/3)
ax_4 = Axis(f[5,4:5],
    xgridvisible=false, ygridvisible=false,
    xticks = ([1:20:102;],  string.(pine_bins[2,[1:20:102;]])),
    xlabel = L"LAI [m^2/m^2]",)




p_list = Int.(collect(range(5, 95, length=3)))
p_list = [L"q_{5}", L"q_{50}", L"q_{95}"]

y_ticks_beech = [[27.5, 30., 32.5], [0.6, 0.9, 1.2],  [10, 11, 12, 13], [1.5, 2., 2.5, 3.], [4,5,6,7]]
ax_5_list = [Axis(f[i, 3], xticks=([0, 50, 100], [L"q_{0}", L"q_{50}", L"q_{100}"]),
    xgridvisible=false, ygridvisible=false, ylabel="Attention", yticks = y_ticks_beech[i]) for i=1:5]
y_ticks_pine = [[20, 25, 30], [25, 30, 35],   [25, 30, 35], [0,5,10], [1,3,5]]

ax_6_list = [Axis(f[i, 6], xticks=([0, 50, 100], [L"q_{0}", L"q_{50}", L"q_{100}"]),
    xgridvisible=false, ygridvisible=false, ylabel="Attention", yticks = y_ticks_pine[i]) for i=1:5]

# element_list = ["precip", "temp", "rad", "lai", "age"]

ax_5_list[[1:4;]]



plot_features!(ax_1,ax_5_list, ["precip", "temp", "rad"], "beech", "attention", 5, [1:4;])

plot_features!(ax_2, ax_5_list, ["lai", "age"],  "beech", "attention", 5, [5:5;])

plot_features!(ax_3, ax_6_list, ["precip", "temp", "rad"], "pine", "attention", 2,[1:4;])
plot_features!(ax_4,ax_6_list, ["lai", "age"], "pine", "attention", 2, [5:5;])

f
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


label = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n"]
ind_list = [(1:4,1:2),(5,1:2), (1, 3), (2,3), (3,3), (4,3), (5,3), (1:4,4:5), (5,4:5), (1,6), (2,6), (3,6), (4,6), (5,6)]

for (i, ind) in enumerate(ind_list)
    Label(f[ind[1], ind[2], TopLeft()], 
        label[i],
        fontsize=16, 
        font = :bold,
        halign = :right, 
        padding = (0,20,5,0) )
end
f
save("images/fig_3_best_features_attention.pdf", f)


attn = npzread("/Users/anand/Documents/repositories/tst-plot/data/best_model/$(pft)_$(seed)_sum_attn_x_features.npy")

y
attn[:,5]

x = npzread("/Users/anand/Documents/repositories/tst-plot/data/best_model/$(pft)_$(seed)_mean_x_features.npy")

scatter(attn[:,3]/2, y)
