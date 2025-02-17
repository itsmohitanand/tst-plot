using CairoMakie
using Colors
using Peaks
using MakieExtra


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

struct TextBox
    x::Float64  # Lower-left x
    y::Float64  # Lower-left y
    w::Float64  # Width
    h::Float64  # Height

    function TextBox(x, y, w, h)
        new(x, y, w, h)
    end
end

# Extension methods to compute midpoints and corners
function upper_mid(tb::TextBox)
    return (tb.x + tb.w / 2, tb.y + tb.h)  # Middle of top edge
end

function lower_mid(tb::TextBox)
    return (tb.x + tb.w / 2, tb.y)  # Middle of bottom edge
end

function left_mid(tb::TextBox)
    return (tb.x, tb.y + tb.h / 2)  # Middle of left edge
end

function right_mid(tb::TextBox)
    return (tb.x + tb.w, tb.y + tb.h / 2)  # Middle of right edge
end

function left_bottom(tb::TextBox)
    return (tb.x, tb.y)  # Lower-left corner
end

function left_upper(tb::TextBox)
    return (tb.x, tb.y + tb.h)  # Upper-left corner
end

function right_bottom(tb::TextBox)
    return (tb.x + tb.w, tb.y)  # Lower-right corner
end

function right_upper(tb::TextBox)
    return (tb.x + tb.w, tb.y + tb.h)  # Upper-right corner
end

function plt_box!(ax, x, y, w, h, txt; strokecolor=:grey70, color=:grey20, bg_color = :grey90, strokewidth=2)
    poly!(ax, Rect(x, y, w, h), color=bg_color, strokecolor=strokecolor, strokewidth = strokewidth)
    text!(ax, txt, position = Point2f(x+w/2, y+h/2), align = (:center,:center), fontsize = 14, color=color, word_wrap_width=300)
end

function plot_attn!(ax, x, y, width)
    
    function mock_attn(t,x,y)
        a, b = 1/10, x
        multisin(t) = 3sinpi.(0.1*a*(t .- b)) + 2sinpi.(0.2*a*(t .-b)) + sinpi.(0.6*a*(t .- b))
        attn_fn(t) = (multisin(t) .+ 0.1) *10 .+ y
        return attn_fn(t)
    end
    
    x_arr = [x:1:x+width;]

    y_arr = mock_attn(x_arr, x, y)

    pks = findmaxima(y_arr) |> peakproms!(;strict=false) |> peakwidths!()

    pos = Point2f[]
    color = []
    for i=1:width+1
        push!(pos, Point2f(x_arr[i], y_arr[i]))
        if y_arr[i]>y
            push!(color, p["blue"])
        else
            push!(color, RGBA(p["blue"], 0.2))
        end
    end

    lines!(ax, pos, color = color, linewidth = 2)

    for (a, b) in zip(x_arr[pks.indices], y_arr[pks.indices])

        if b > y
            lines!(ax, [Point2f(a, b), Point2f(a, y)], color=:grey50, linestyle=:dash)
            scatter!(ax, [a], [b], color = p["red"], markersize = 5)    
        end
    end
    lines!(ax, [Point2f(x, y), Point2f(x+width, y)], color=:grey80)
    lines!(ax, [Point2f(x, y-50), Point2f(x+width, y-50)], color=:grey20)
    lines!(ax, [Point2f(x,  y-50), Point2f(x, y+50)], color=:grey20)

    for (i, (left, right)) in enumerate(pks.edges)
        left, right = left+x, right+x
        height = pks.heights[i] - pks.proms[i]/2

        if height > y
            lines!(ax, [Point2f(left, height), Point2f(right, height)], color=p["purple"])
        end
            end

    return ax; 
end


function plot_combined_data!(ax, x, y, w, h)
    plt_box!(ax, x, y, w, h, "", bg_color = :transparent )

    for j=1:10
        width, height = 9,9
        x_base, y_base = x+160, y+110
        plt_box!(ax, x_base, y_base - (height+1)*j, width, height,  "", bg_color=p["purple"], strokewidth=1)
        plt_box!(ax, x_base+10, y_base - (height+1)*j, width, height,  "", bg_color=p["green"], strokewidth=1)
    end


    for i=1:36
        x_base, y_base = x+190, y+130
        width, height = 9,9
        plt_box!(ax, x_base+(width+1)*i, y_base, width, height,  "", bg_color=p["yellow"], strokewidth=1)
        plt_box!(ax, x_base+(width+1)*i, y_base-10, width, height,  "", bg_color=p["blue"], strokewidth=1)
        plt_box!(ax, x_base+(width+1)*i, y_base-20, width, height,  "", bg_color=p["red"], strokewidth=1)
    end

    for i=0:3
        lines!(ax, [Point2f(x+200+(120*i), y+100), Point2f(x+200+(120*i), y+150)],color = :grey50, linestyle=:dash)
    end

    plt_box!(ax, x+440, y+10, 120, 10,  "", bg_color=:grey40, strokewidth=1)

    return ax 
end

w_size, h_size = 1200, 1000

###### FIGURE


f = Figure(size = (w_size,h_size))

ax = Axis(f[1,1], xgridvisible = false,
    ygridvisible = false)
hidespines!(ax)
hidedecorations!(ax)
xlims!(-w_size/2, w_size/2)
ylims!(-h_size/2, h_size/2)


## WEATHER MODEL
x, y = -500, 450
w, h = 350, 50
y_delta = 80

bg_color = RGBA(p["blue"], 0.2)

plt_box!(ax, x, y, w,h,  "Bias adjusted ERA-5 reanalysis data (Calibration)", bg_color = bg_color)
b11 = TextBox(x, y, w, h)

plt_box!(ax, x, y-y_delta, w,h,  "Weather generator (AWEGEN)", bg_color = bg_color)
b21 = TextBox(x, y-y_delta, w,h)

plt_box!(ax, x, y-2*y_delta, w,h, "Weather data - solar radiation, temperature, precipitation", bg_color = bg_color)
b31 = TextBox(x, y-2*y_delta, w,h)

arrow_color = p["brown"]

arrowlines!(ax, [lower_mid(b11), upper_mid(b21)],linewidth = 2, color=arrow_color)
arrowlines!(ax, [lower_mid(b21), upper_mid(b31)],linewidth = 2, color=arrow_color)
f

## FOREST MODEL

x = 150

bg_color = RGBA(p["green"], 0.2)

plt_box!(ax,x, y, w,h, "Forest inventory data (Parametrisation)", bg_color = bg_color)
b12 = TextBox(x, y, w,h)

plt_box!(ax, x, y-y_delta, w,h, "Physiological forest model (FORMIND)", bg_color = bg_color)
b22 = TextBox(x, y-y_delta, w,h)

plt_box!(ax, x, y-2*y_delta, w,h, "Forest structures (aggregated) - age, LAI, biomass loss, species", bg_color = bg_color)
b32 = TextBox(x, y-2*y_delta, w,h)

arrowlines!(ax, [lower_mid(b12), upper_mid(b22)],linewidth = 2, color=arrow_color)
arrowlines!(ax, [lower_mid(b22), upper_mid(b32)],linewidth = 2, color=arrow_color)

f

arrowlines!(ax, [right_mid(b31), (0, right_mid(b31)[2])],linewidth = 2, color=arrow_color, arrowstyle="-")
arrowlines!(ax, [(0, right_mid(b31)[2]), (0, left_mid(b22)[2])],linewidth = 2, color=arrow_color, arrowstyle="-")
arrowlines!(ax, [(0, right_mid(b22)[2]), left_mid(b22)],linewidth = 2, color=arrow_color)

f

## DATA
x, y, w, h = -175, 375, 350, 50
plt_box!(ax, x, y-2*y_delta, w,h, "Combined weather and forest data")
b4 = TextBox(x, y-2*y_delta, w,h)


arrowlines!(ax, [lower_mid(b31), (lower_mid(b31)[1], left_mid(b4)[2])] , y,linewidth = 2, color=arrow_color, arrowstyle="-")

arrowlines!(ax, [(lower_mid(b31)[1], left_mid(b4)[2]), left_mid(b4)] , y,linewidth = 2, color=arrow_color)

arrowlines!(ax, [lower_mid(b32), (lower_mid(b32)[1], right_mid(b4)[2])] , y,linewidth = 2, color=arrow_color, arrowstyle="-")
f

arrowlines!(ax, [(lower_mid(b32)[1], right_mid(b4)[2]), right_mid(b4)] , y,linewidth = 2, color=arrow_color)
f

f

x, y = -350, 0
w, h = 700, 180

text!(ax, Point2f(x+10,y+h-10), text="a", align = (:center,:center), fontsize = 16, color=:grey10)

plot_combined_data!(ax, x, y, w, h)
b5 = TextBox(x, y, w, h)

arrowlines!(ax, [left_bottom(b4), left_upper(b5)],linewidth = 2, color=:grey50, arrowstyle="--")
arrowlines!(ax, [right_bottom(b4), right_upper(b5)],linewidth = 2, color=:grey50, arrowstyle="--")

f


## MODELS 

x, y, w, h = -525, -125, 250, 50
plt_box!(ax, x, y, w, h,  "Transformer model")
f
b61 = TextBox(x, y, w, h)



x, y, w, h = -150, -150, 700, 100
plt_box!(ax, x, y, w, h,  "", bg_color = RGBA(p["yellow"], 0.5))

b6 = TextBox(x, y, w, h)


x, y, w, h = -125, -125, 250, 50
plt_box!(ax, x, y, w, h,  "Linear regression")
b62 = TextBox(x, y, w, h)
f

x, y, w, h = 275, -125, 250, 50

plt_box!(ax, x, y, w, h,  "Extra tree regressor")

b63 = TextBox(x, y, w, h)
f

arrowlines!(ax, [left_mid(b5),(upper_mid(b61)[1], left_mid(b5)[2]) ],linewidth = 2, color=arrow_color, arrowstyle="-")
arrowlines!(ax, [(upper_mid(b61)[1], left_mid(b5)[2]), (upper_mid(b61))],linewidth = 2, color=arrow_color, linestyle="-")

f
arrowlines!(ax, [(lower_mid(b6)[1], lower_mid(b5)[2]), upper_mid(b6)],linewidth = 2, color=arrow_color)
f



f


y, w = -225, 250
x = -525
plt_box!(ax, x, y, w, h,  "Extract attention weights")
b71 = TextBox(x, y, w, h)

x= -125
plt_box!(ax, x, y, w, h, "Generate attenion pool of candidates")
b72 = TextBox(x, y, w, h)


x = 275
plt_box!(ax, x, y, w, h,   "Generate random pool of candidates")
b73 = TextBox(x, y, w, h)

arrowlines!(ax, [lower_mid(b61), upper_mid(b71) ],linewidth = 2, color=arrow_color)
arrowlines!(ax, [right_mid(b71), left_mid(b72) ],linewidth = 2, color=arrow_color)

f



x, y, w, h = 50, -350, 300, 50
plt_box!(ax, x, y, w, h,  "Subselect features using sequential forward floating selection")

b8 = TextBox(x, y, w, h)

f



x, y, w, h = 50, -450, 300, 50
plt_box!(ax, x,y,w,h,  "Interpret the best model with ICE and PDP")
b9 = TextBox(x, y, w, h)

arrowlines!(ax, [lower_mid(b72), (lower_mid(b72)[1], left_mid(b8)[2])],linewidth = 2, color=arrow_color, arrowstyle="-")
arrowlines!(ax, [(lower_mid(b72)[1], left_mid(b8)[2]), left_mid(b8) ],linewidth = 2, color=arrow_color)

arrowlines!(ax, [lower_mid(b73), (lower_mid(b73)[1], right_mid(b8)[2])],linewidth = 2, color=arrow_color, arrowstyle="-")
arrowlines!(ax, [(lower_mid(b73)[1], right_mid(b8)[2]), right_mid(b8) ],linewidth = 2, color=arrow_color)

arrowlines!(ax, [lower_mid(b8), upper_mid(b9)],linewidth = 2, color=arrow_color)

f
## ATTENTION DATA

x, y, w, h = -525, -350, 450, 50

text!(ax, Point2f(x+10,y+h), text="b", align = (:center,:center), fontsize = 16, color=:grey10)

plot_attn!(ax, x, y, w)
f
ab = TextBox(x, y, w, h)

arrowlines!(ax, [left_bottom(b72), left_upper(ab)],linewidth = 2, color=:grey50, arrowstyle="--", )
arrowlines!(ax, [right_bottom(b72), right_upper(ab)],linewidth = 2, color=:grey50, arrowstyle="--")

f

save("images/fig_6_flowchart.pdf", f)