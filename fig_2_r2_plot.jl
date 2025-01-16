using NPZ
using CairoMakie
using ColorSchemes
using StatsBase
using DataFrames
using CSV
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


# read the val R2 for all the model
function r2_score(y_true, y_pred)
    ss_res = sum((y_true .- y_pred).^2) # Residual sum of squares
    ss_tot = sum((y_true .- mean(y_true)).^2) # Candidate sum of squares
    return 1 - (ss_res / ss_tot)
end


# function r2_score_exp_top_k(pft, experiment, q)
#     r2_score_mat = zeros(10, 10)
#     for seed=1:10
#         data_path = "data/xtree_model_pred/$(pft)/$(experiment)/"
#         data_val = npzread(data_path * "y_val_seed_$(seed).npy")
#         data_mini_val = data_val[data_val[:,1] .> percentile(data_val[:,1], q), :]
#         for k=2:11
#             r2_score_mat[k-1, seed] = round(r2_score(data_mini_val[:,1], data_mini_val[:,k]), digits=2)
#         end
#     end

#     return r2_score_mat
# end

function r2_score_exp(pft, experiment)
    r2_score_mat = zeros(10, 10)
    for seed=1:10
        data_path = "data/xtree_model_pred/$(pft)/$(experiment)/"
        data_val = npzread(data_path * "y_val_seed_$(seed).npy")
        for k=2:11
            r2_score_mat[k-1, seed] = round(r2_score(data_val[:,1], data_val[:,k]), digits=2)
        end
    end

    return r2_score_mat
end

r2_beech_attn = r2_score_exp("beech", "attention/0")
r2_beech_rand = r2_score_exp("beech", "random")
r2_beech_rand_small = r2_score_exp("beech", "random_small")

r2_pine_attn = r2_score_exp("pine", "attention/0")
r2_pine_rand = r2_score_exp("pine", "random")
r2_pine_rand_small = r2_score_exp("pine", "random_small")


# argmax(r2_beech_attn[5,:])
# argmax(r2_beech_rand[5,:])
# argmax(r2_beech_rand_small[5,:])

r2_beech_attn[5,5]
r2_beech_rand[5,3]

# argmax(r2_pine_attn[5,:])
# argmax(r2_pine_rand[5,:])
# argmax(r2_pine_rand_small[5,:])

r2_pine_attn[5,2]
r2_pine_rand[5,8]

# r2_beech_attn = r2_score_exp_top_k("beech", "attention/0", 90)
# r2_beech_rand = r2_score_exp_top_k("beech", "random", 90)
# r2_beech_rand_small = r2_score_exp_top_k("beech", "random_small", 90)

# r2_pine_attn = r2_score_exp_top_k("pine", "attention/0", 90)
# r2_pine_rand = r2_score_exp_top_k("pine", "random", 90)
# r2_pine_rand_small = r2_score_exp_top_k("pine", "random_small", 90)

function plt_box!(ax, rand_small, rand, attn)
    x = ones(10)
    for i=1:10
        alpha = 1
        boxplot!(ax, x, rand_small[i, :],  color=(p["green"], alpha) )
        boxplot!(ax, x.+1, rand[i, :],  color=(p["blue"], alpha) ) 
        boxplot!(ax, x.+2, attn[i, :],  color=(p["red"], alpha) )     
        x = x.+5
    end
return ax
end


function plt_n_features!(ax, pft)
    for (i, experiment) in enumerate(["attention_0", "random_small","random" ])
        
        alpha = 1
        if experiment == "random"
            color = (p["blue"], alpha)
        elseif experiment == "random_small"
            color = (p["green"], alpha)
        else
            color = (p["red"], alpha)
        end
    
        data = DataFrame(CSV.File("data/$(pft)_$(experiment)_feature_dist.csv"))
        climate_var = data.temp .+ data.precip .+data.rad
        state_var = data.age .+ data.lai 
    
        barplot!(ax, 1+i, mean(climate_var), color = Pattern("/", background_color = color, linecolor = :grey20) )
        
        if experiment == "attention_0"
            errorbars!(ax, [1.0+i], [mean(climate_var)], [minimum(climate_var)], [maximum(climate_var)], whiskerwidth=10, color = :grey20)
        end
        
        barplot!(ax, 5+i, mean(state_var), color = Pattern("\\", background_color = color, linecolor =:grey20)  )
        if experiment == "attention_0"
            errorbars!(ax, [5+i], [mean(state_var)], [minimum(state_var)], [maximum(state_var)], whiskerwidth=10, color = :grey20)
        end
        
    end
    
    return ax
end

ticks = [2:5:50;] .+0.5
labels = string.([1:10;])

fontsize_theme = Theme(fontsize = 18)
set_theme!(fontsize_theme)
f = Figure(size=(1400,400))

ax1 = Axis(f[2, 1], 
xgridvisible=false, 
ygridvisible=false, 
xlabel = "Beech",
xticksvisible = false,
xticklabelsvisible = false,
ylabel = "Candidate Features"
    )

ax2 = Axis(f[2,2:3],
xgridvisible=false, 
    ygridvisible=false, 
    xticks=(ticks, labels),
    xlabel = "Number of features (Beech)",
    ylabel = L"R^2",
   )

ax3 = Axis(f[2,4], 
xgridvisible=false, 
ygridvisible=false,
xlabel = "Pine",
xticksvisible = false,
xticklabelsvisible = false,
ylabel = "Candidate Features"
    )

ax4 = Axis(f[2,5:6],
xgridvisible=false, 
ygridvisible=false, 
xticks=(ticks, labels),
xlabel = "Number of features (Pine)",
ylabel = L"R^2",
)

f


plt_n_features!(ax1, "beech")
plt_box!(ax2, r2_beech_rand_small, r2_beech_rand ,r2_beech_attn)
plt_n_features!(ax3, "pine")
plt_box!(ax4, r2_pine_rand_small, r2_pine_rand, r2_pine_attn)

f

ylims!(ax2, 0, 0.7)
ylims!(ax4, 0, 0.7)

f

hidespines!(ax1, :r, :t)
hidespines!(ax2, :r, :t)
hidespines!(ax3, :r, :t)
hidespines!(ax4, :r, :t)
f

alpha = 1

elem_3 = [PolyElement(color = (p["blue"], alpha), strokecolor = :transparent, strokewidth = 1, points = Point2f[(0, 0), (0, 1), (1,1), (1, 0)] )]


elem_2 = [PolyElement(color = (p["green"], alpha), strokecolor = :transparent, strokewidth = 1, points = Point2f[(0, 0), (0, 1), (1,1), (1, 0)] )]

elem_1 = [PolyElement(color = (p["red"], alpha), strokecolor = :transparent, strokewidth = 1, points = Point2f[(0, 0), (0, 1), (1,1), (1, 0)] )]

elem_4 = [PolyElement(color = Pattern("/", background_color = :grey80, linecolor = :grey20), strokecolor = :transparent, strokewidth = 1, points = Point2f[(0, 0), (0, 1), (1,1), (1, 0)] )]

elem_5 = [PolyElement(color = Pattern("\\", background_color = :grey80, linecolor = :grey20), strokecolor = :transparent, strokewidth = 1, points = Point2f[(0, 0), (0, 1), (1,1), (1, 0)] )]

Legend(f[1,1:end], [elem_1, elem_2, elem_3, elem_4, elem_5], ["Attention",  "Random small", "Random huge", "Climate Pool", "State Pool"], framevisible=false, orientation= :horizontal)
f

alphabet = ["a)","b)","c)","d)"]
for (i, j) in enumerate([1,2,4,5])        
    Label(f[2,j, TopLeft()],
    alphabet[i],
    font = "TeX Gyre Heros Bold",
    fontsize = 22,
    padding = (0, 50, -10, 0),
    halign = :right )

end
f
save("images/fig_2_r2.pdf", f)