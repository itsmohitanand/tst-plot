using NPZ
using StatsBase
using Combinatorics
using CairoMakie
using Colors
using LaTeXStrings
using StatsBase
using Distributions

beech_bins = npzread("data/beech_bins.npy")
pine_bins = npzread("data/pine_bins.npy")

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

function get_var_list(pft)
    age = npzread("data/ml_data/$(pft)_age.npy")
    lai = npzread("data/ml_data/$(pft)_lai.npy")
    precip = npzread("data/ml_data/$(pft)_precip.npy")
    rad = npzread("data/ml_data/$(pft)_rad.npy")
    temp = npzread("data/ml_data/$(pft)_temp.npy")
    labels = npzread("data/ml_data/$(pft)_labels.npy")
    std_Xs = npzread("data/ml_data/$(pft)_std_Xs.npy")
    mean_Xs = npzread("data/ml_data/$(pft)_mean_Xs.npy")

    age_1, age_2, age_3 = age[:,1:33], age[:, 34:66], age[:,67:end]
    lai_1, lai_2, lai_3 = lai[:,1:33], lai[:, 34:66], lai[:,67:end]
    precip_1, precip_2, precip_3 = precip[:,1:73], precip[:, 73:2*73], precip[:,2*73:end]
    rad_1, rad_2, rad_3 = rad[:,1:73], rad[:, 73:2*73], rad[:,2*73:end]
    temp_1, temp_2, temp_3 = temp[:,1:73], temp[:, 73:2*73], temp[:,2*73:end]


    age_1, age_2, age_3 = mean(age_1, dims=2), mean(age_2, dims=2), mean(age_3, dims=2)
    lai_1, lai_2, lai_3 = mean(lai_1, dims=2), mean(lai_2, dims=2), mean(lai_3, dims=2)
    precip_1, precip_2, precip_3 = mean(precip_1, dims=2), mean(precip_2, dims=2), mean(precip_3, dims=2)
    rad_1, rad_2, rad_3 = mean(rad_1, dims=2), mean(rad_2, dims=2), mean(rad_3, dims=2)
    temp_1, temp_2, temp_3 = mean(temp_1, dims=2), mean(temp_2, dims=2), mean(temp_3, dims=2)


    var_list = [rad_1, rad_2, rad_3, precip_1, precip_2, precip_3,  temp_1, temp_2, temp_3, age, lai]

    return var_list, age, lai, mean_Xs, std_Xs, labels
end

var_list_beech, age_beech, lai_beech, mean_Xs_beech, std_Xs_beech, labels_beech = get_var_list("beech")
var_list_pine, age_pine, lai_pine, mean_Xs_pine, std_Xs_pine, labels_pine = get_var_list("pine")

function lagged_correlation_with_CI(x, max_lag, alpha=0.05)
    corrs = zeros(max_lag * 2 + 1)
    ci_bounds = zeros(max_lag * 2 + 1)
    lags = -max_lag:max_lag
    z = quantile(Normal(0,1), 1 - alpha / 2)  # Z-score for confidence level (1.96 for 95%)

    for (i, lag) in enumerate(lags)
        if lag < 0
            corrs[i] = cor(x[1:end+lag], x[1-lag:end])
        else 
            corrs[i] = cor(x[1:end-lag], x[1+lag:end])
        end
        se = 1 / sqrt(size(x)[1]-(abs(i)) - abs(lag))  # Standard error estimate
        ci_bounds[i] = z * se  # Compute confidence interval bound
    end
    return lags, corrs, ci_bounds
end


# reshape(beech_bins[1, 1:end-1], 1, 101)

# ori_histogram = lai_beech.*std_Xs_beech[1] .+ mean_Xs_beech[1]
# x_val = reshape(beech_bins[2, 1:end-1], 1, 101)

# sum(ori_histogram.*x_val, dims=2)./sum(ori_histogram, dims=2)

# lags_lai_beech, corrs_lai_beech, ci_bounds_lai_beech = lagged_correlation_with_CI(ori_histogram, 30)

# lines(corrs_lai_beech)
# Compute lagged correlations with confidence intervals
max_lag = 30
lags_beech, corrs_beech, ci_bounds_beech = lagged_correlation_with_CI(labels_beech, max_lag)
lags_pine, corrs_pine, ci_bounds_pine = lagged_correlation_with_CI(labels_pine, max_lag)

fig = Figure(resolution = (1200, 400))
ax_beech = Axis(fig[1, 1], 
    xlabel = "Lag",
    ylabel = "Auto-correlation (Beech biomass loss)", 
    xticks = -30:5:30, 
    yticks = -1:0.2:1, 
    xgridvisible = false, 
    ygridvisible = false,)

    
ax_pine = Axis(fig[1, 2],
    xlabel = "Lag",
    ylabel = "Auto-correlation (Pine biomass loss)", 
    xticks = -30:5:30, 
    yticks = -1:0.2:1, 
    xgridvisible = false, 
    ygridvisible = false,)

stem!(ax_beech, lags_beech, corrs_beech, color = p["red"], stemcolor=:blue, strokecolor=:red)
# lines!(ax_beech, lags_beech, ci_bounds_beech, linestyle=:dot, color=:bisque, label="95% CI Bound")
# lines!(ax_beech, lags_beech, -ci_bounds_beech, linestyle=:dot, color=:bisque, label="95% CI Bound") # Lower CI

stem!(ax_pine, lags_pine, corrs_pine, color = p["red"], stemcolor=:blue, strokecolor=:red)
# lines!(ax_pine, lags_pine, ci_bounds_pine, linestyle=:dot, color=:bisque, label="95% CI Bound")
# lines!(ax_pine, lags_pine, -ci_bounds_pine, linestyle=:dot, color=:bisque, label="95% CI Bound") # Lower CI

hidespines!(ax_beech, :r, :t)
hidespines!(ax_pine, :r, :t)
fig

save("images/fig_7_lagged_mortality_autocorr.pdf", fig)

