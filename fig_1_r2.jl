using CairoMakie
using NPZ
using ColorSchemes


p = ColorSchemes.:Set2_7

data = npzread("/Users/anand/Documents/data/tst/r2_sfs.npy")[:,:,:,:]

y = Float64.(data[:,:,:, 3])

f = Figure(resolution=(600,400))
ax = Axis(f[1,1], xlabel="Num of features", ylabel = L"R^2", xticks=([5:5:50;],string.([1:10;])), xgridvisible = false, ygridvisible=false)

for i=5:5:50
    k = div(i,5)
    b1 = boxplot!(ax, i*ones(10).+1, y[:,2, k], color=p[1])
    b2 = boxplot!(ax, i*ones(10), y[:,1, k], color=p[2])
end

hidespines!(ax, :r, :t)
axislegend(ax, [b1, b2], ["Attention", "Random"], position=:rb)
f
save("R2.png", f)

data[:, 2, 7, 3]
