using CairoMakie
include("../plots/core.jl")


pine_h1_path = "/Users/anand/Documents/repositories/plots/tst-plot/data/pine_h1.csv"
pine_h3_path = "/Users/anand/Documents/repositories/plots/tst-plot/data/pine_h3.csv"
pine_peaks1_path = "/Users/anand/Documents/repositories/plots/tst-plot/data/pine_peaks1.csv"
pine_peaks3_path = "/Users/anand/Documents/repositories/plots/tst-plot/data/pine_peaks3.csv"
pine_results_half1 = "/Users/anand/Documents/repositories/plots/tst-plot/data/pine_results_half1.csv"
pine_results_half3 = "/Users/anand/Documents/repositories/plots/tst-plot/data/pine_results_half3.csv"

pine_h1 = DataFrame(CSV.File(pine_h1_path, header=false)) |> Matrix
pine_peaks1 = DataFrame(CSV.File(pine_peaks1_path, header=false)) |> Matrix
pine_results_half1 = DataFrame(CSV.File(pine_results_half1, header=false)) |> Matrix

pine_h1 = pine_h1/16000

f = Figure(resolution=(800,800))
ax_rad = Axis(f[1,1], xgridvisible=false, ygridvisible=false)
ax_precip = Axis(f[2,1], xgridvisible=false, ygridvisible=false)
ax_temp = Axis(f[3,1], xgridvisible=false, ygridvisible=false)
ax_age = Axis(f[4,1], xgridvisible=false, ygridvisible=false)
ax_lai = Axis(f[5,1], xgridvisible=false, ygridvisible=false)

lines!(ax_rad, pine_h1[1:36,1], color = palette[12])
lines!(ax_precip, pine_h1[36:72,1], color = palette[6])
lines!(ax_temp, pine_h1[72:108,1], color = palette[9])
lines!(ax_age, pine_h1[108:209,1], color = palette[2])
lines!(ax_lai, pine_h1[209:end,1], color = palette[5])


palette

for i=1:14
    index = Int(pine_peaks1[i]) 
    if index<=36
        scatter!(ax_rad, index, pine_h1[index], marker = :x, color="black", markersize=15)
        # vlines!(ax_rad,[12,24], linestyle = "--", color ="black")
    elseif 36<index<=72
        scatter!(ax_precip, index-35, pine_h1[index], marker = :x, color="black", markersize=15)
        # vlines!(ax_precip,[12,24], linestyle = "--", color ="black")

    elseif 72<index<=108
        scatter!(ax_temp, index-71, pine_h1[index], marker = :x, color="black", markersize=15)
        # vlines!(ax_temp,[12,24], linestyle = "--", color ="black")

    elseif 108<index<=209
        scatter!(ax_age, index-107, pine_h1[index], marker = :x, color="black", markersize=15)
    elseif 209<index<=310
        scatter!(ax_lai, index-208, pine_h1[index], marker = :x, color="black", markersize=15)
    end

end


ylims!(ax_rad, (0,1.1))
ylims!(ax_precip, (0,1.1))
ylims!(ax_temp, (0,1.1))
ylims!(ax_age, (0,1.1))
ylims!(ax_lai, (0,1.1))

f