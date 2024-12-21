using NPZ
using CairoMakie
using DataFrames
using StatsBase
using CSV

pft = "beech"
exp = "attention"
seed = 5

df_beech = DataFrame(CSV.File(path_beech))


function plot_ice!(ax_list, data_frame, element_list)

    ax_index = 0
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
            
            var_index = row.index
            ice = npzread("data/best_model/$(pft)_$(exp)_$(seed)_5_ice_$(var_index)_individual.npy")

            lines!(ax_list, ice )
            ax_index+=1
        end
    end

    return ax
end



    
f = Figure()
ax = Axis(f[1,1])

element_list = ["precip", "temp", "rad", "lai", "age"]
plot_ice!(ax, df_beech ,element_list)

var_index = 1
ice = npzread("data/best_model/$(pft)_$(exp)_$(seed)_5_ice_$(var_index)_individual.npy")

 
f = Figure()
ax = Axis(f[1,1])

for i in 1:1000
    lines!(ax, ice[i,:], color = (:grey20, 0.1), linewidth=1)
end
lines!(ax, mean(ice, dims=1)[1,:], color = (:red, 0.9), linewidth=2)
f


ice