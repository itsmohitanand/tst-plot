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


# read the val R2 for all the model
function r2_score(y_true, y_pred)
    ss_res = sum((y_true .- y_pred).^2) # Residual sum of squares
    ss_tot = sum((y_true .- mean(y_true)).^2) # Total sum of squares
    return 1 - (ss_res / ss_tot)
end


function r2_score_exp_top_k(pft, experiment, q)
    r2_score_mat = zeros(10, 10)
    for seed=1:10
        data_path = "data/xtree_model_pred/$(pft)/$(experiment)/"
        data_val = npzread(data_path * "y_val_seed_$(seed).npy")
        print(size(data_val))
        data_mini_val = data_val[data_val[:,1] .> percentile(data_val[:,1], q), :]
        for k=2:11
            r2_score_mat[k-1, seed] = round(r2_score(data_mini_val[:,1], data_mini_val[:,k]), digits=2)
        end
    end

    return r2_score_mat
end

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
        boxplot!(ax, x, rand_small[i, :],  color=p["blue"] )
        boxplot!(ax, x.+1, rand[i, :],  color=p["green"] ) 
        boxplot!(ax, x.+2, attn[i, :],  color=p["red"] )     
        x = x.+5
    end
return ax
end

ticks = [2:5:50;] .+0.5
labels = string.([1:10;])

f = Figure(size=(1400,400))
ax1 = Axis(f[1,1], 
    xgridvisible=false, 
    ygridvisible=false, 
    xticks=(ticks, labels)
    )
ax2 = Axis(f[1,2], 
    xgridvisible=false, 
    ygridvisible=false, 
    xticks=(ticks, labels)
    )
f

plt_box!(ax1, r2_beech_rand_small, r2_beech_rand ,r2_beech_attn)
plt_box!(ax2, r2_pine_rand_small, r2_pine_rand, r2_pine_attn)

f
ylims!(ax1, 0, 0.7)
ylims!(ax2, 0, 0.7)
f
hidespines!(ax1, :r, :t)
hidespines!(ax2, :r, :t)

f
save("images/feature_r2_ylim_0.pdf", f)