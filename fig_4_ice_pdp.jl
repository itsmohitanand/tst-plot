using NPZ
using CairoMakie
using Colors
using StatsBase
using Combinatorics
using LaTeXStrings
using MathTeXEngine

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

pair = collect(combinations(1:5,2))
exp = "attention"

p_list = [L"q_{5}", L"q_{50}", L"q_{95}"]
feature_names = ["Precip", "Temp^1", "Temp^2", "Temp^3", "LAI"]


beech_map_dict = Dict(1=>5, 2=>4, 3 =>2,4=>1,5=>3)
pine_map_dict = Dict(1=>3, 2=>2, 3 =>1,4=>5,5=>4)

function plt_pft!(ax_ice, ax_pdp_1, ax_pdp_2, pft, exp, seed, map_dict)

    num_ice = 20
    pair = collect(combinations(1:5,2))

    color = [p["blue"], p["red"], p["red"], p["red"], p["green"]]
    y = npzread("data/xtree_model_pred/$(pft)/attention/0/y_test_seed_$(seed).npy")[:,1]

    yq_fn = ecdf(y)

    for i in 1:5

        var_index = map_dict[i]
        ice = npzread("data/best_model/$(pft)_$(exp)_$(seed)_5_ice_$(var_index-1)_individual.npy")
        
        min = []
        max = []
        for j in 1:size(ice)[2]
            push!(min, quantile(ice[:,j], 0.05))
            push!(max, quantile(ice[:,j], 0.95))
        end

        band!(ax_ice[i], [1:size(yq_fn.(min))[1];],  yq_fn.(min), yq_fn.(max), color = (color[i], 0.15))

        for j in 1:num_ice
            y = ice[j, :]
            # y = fn.(ice[i, :])
            lines!(ax_ice[i], yq_fn.(y), color = (:grey50, 0.2), linewidth=1)
        end
        
        lines!( ax_ice[i],  yq_fn.(median(ice, dims=1)[1,:]), linewidth=2, color = color[i])
    
    end

    for k = 1:5
        i, j = pair[k]

        i, j = map_dict[i], map_dict[j]

        local pdp
        try
            pdp = npzread("data/best_model/$(pft)_$(exp)_$(seed)_5_pdp_$(i-1)_$(j-1)_individual.npy")
        catch
            pdp = npzread("data/best_model/$(pft)_$(exp)_$(seed)_5_pdp_$(j-1)_$(i-1)_individual.npy")
            pdp = permutedims(pdp, [1,3,2])
        end

        # pdp = npzread("data/best_model/$(pft)_attention_$(seed)_5_pdp_$(i-1)_$(j-1)_individual.npy")
        # y_pdp = median(pdp, dims=1)[1, :, :]

        y_pdp = median(pdp, dims=1)[1, :, :]
        
        y_pdp = yq_fn.(y_pdp)
        heatmap!(ax_pdp_1[k],y_pdp, colormap=:balance, colorrange = (0.05,0.95)) 
    end
    
    local hm
    for k = 1:5
        i, j = pair[k+5]

        i, j = map_dict[i], map_dict[j]
        
        local pdp
        try
            pdp = npzread("data/best_model/$(pft)_$(exp)_$(seed)_5_pdp_$(i-1)_$(j-1)_individual.npy")
        catch
            pdp = npzread("data/best_model/$(pft)_$(exp)_$(seed)_5_pdp_$(j-1)_$(i-1)_individual.npy")
            pdp = permutedims(pdp, [1,3,2])
        end
        # y_pdp = median(pdp, dims=1)[1, :, :]
        y_pdp = median(pdp, dims=1)[1, :, :]
        
        y_pdp = yq_fn.(y_pdp)
        hm = heatmap!(ax_pdp_2[k],y_pdp, colormap=:balance, colorrange = (0.05,0.95)) 
    end
    
    return ax_ice, ax_pdp_1, ax_pdp_2, hm    

end


####################### Figure for beech ####################
textheme = Theme(fonts=(; regular=texfont(:text),
                        bold=texfont(:bold),
                        italic=texfont(:italic),
                        bold_italic=texfont(:bolditalic)),
                fontsize=18,)

set_theme!(textheme)

pft = "beech"
f = Figure(size = (1200,600))

ax_ice_b = [Axis(f[1,i],
    xticks=([1,13,25],  p_list),
    yticks=([0.05,0.5,0.95],  p_list),
    xlabel = latexstring("$(feature_names[i])"), #*"_{$(pft)}"),
    ylabel = latexstring("Biomass \\ Loss"), #_{$(pft)}"),
    xgridvisible = false,
    ygridvisible = false,
    ) for i=1:5]

ax_pdp_b1 = [Axis(f[2, i],
    xticks=([1,13,25],  p_list),
    yticks=([1,13,25],  p_list),
    xgridvisible = false,
    xlabel = latexstring("$(feature_names[pair[i][1]])"), #*"_{$(pft)}"),
    ylabel = latexstring("$(feature_names[pair[i][2]])"), #*"_{$(pft)}"),
    ygridvisible = false,
    ) for i=1:5]


ax_pdp_b2 = [Axis(f[3, i],
    xticks=([1,13,25],  p_list),
    yticks=([1,13,25],  p_list),
    xlabel = latexstring("$(feature_names[pair[i+5][1]])"), #*"_{$(pft)}"),
    ylabel = latexstring("$(feature_names[pair[i+5][2]])"), #*"_{$(pft)}"),
    xgridvisible = false,
    ygridvisible = false,
    ) for i=1:5]

f
_, _, _, hm = plt_pft!(ax_ice_b, ax_pdp_b1, ax_pdp_b2, pft, "attention", 5, beech_map_dict)
Colorbar(f[2:3,6], hm )

for ax in ax_ice_b
    xlims!(ax, 1, 25)
end
f

label = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o"]
for i=1:15 
    print("ind:($(Int(round((i)/5)+1)) , $((i-1)%5))")
    Label(f[Int(floor((i-1)/5)+1),((i-1)%5)+1,  TopLeft()], 
        label[i],
        fontsize=16, 
        font = :bold,
        halign = :right, 
        padding = (0,20,5,0) )
end

f
save("images/fig_4a_ice_pdp_beech.pdf", f)

####################### Another figure for pine ####################
pft = "pine"

f = Figure(size = (1000,500))
ax_ice_p = [Axis(f[1,i],
    xticks=([1,13,25],  p_list),
    yticks=([0.05,0.5,0.95],  p_list),
    xlabel = latexstring("$(feature_names[i])"), #*"_{$(pft)}"),
    ylabel = latexstring("Biomass \\ Loss"), #_{$(pft)}"),
    xgridvisible = false,
    ygridvisible = false,
    ) for i=1:5]

f
    ax_pdp_p1 = [Axis(f[2, i],
    xticks=([1,13,25],  p_list),
    yticks=([1,13,25],  p_list),
    xgridvisible = false,
    xlabel = latexstring("$(feature_names[pair[i][1]])"), #*"_{$(pft)}"),
    ylabel = latexstring("$(feature_names[pair[i][2]])"), #*"_{$(pft)}"),
    ygridvisible = false,
    ) for i=1:5]


ax_pdp_p2 = [Axis(f[3, i],
    xticks=([1,13,25],  p_list),
    yticks=([1,13,25],  p_list),
    xlabel = latexstring("$(feature_names[pair[i+5][1]])"), #*"_{$(pft)}"),
    ylabel = latexstring("$(feature_names[pair[i+5][2]])"), #*"_{$(pft)}"),
    xgridvisible = false,
    ygridvisible = false,
    ) for i=1:5]

_, _, _, hm = plt_pft!(ax_ice_p, ax_pdp_p1, ax_pdp_p2, pft, "attention", 2, pine_map_dict)

Colorbar(f[2:3,6], hm )
for ax in ax_ice_p
    xlims!(ax, 1, 25)
end
f

label = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o"]
for i=1:15 
    print("ind:($(Int(round((i)/5)+1)) , $((i-1)%5))")
    Label(f[Int(floor((i-1)/5)+1),((i-1)%5)+1,  TopLeft()], 
        label[i],
        fontsize=16, 
        font = :bold,
        halign = :right, 
        padding = (0,20,5,0) )
end
f
save("images/fig_4b_ice_pdp_pine.pdf", f)

