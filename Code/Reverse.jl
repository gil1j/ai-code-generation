### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ fde29336-906e-11eb-05ac-0546798d519b
using GAFramework, Brainfuck, Random

# ╔═╡ 9515582c-921a-11eb-05e1-c9f2b0a64b6b
md"# Repeat or reverse an input String
## A clean implementation using modules
The crossover/mutation/selection functions are stored in a library included in GAFramework.jl, hence only the fitness function is shown here."

# ╔═╡ 56a9a600-921b-11eb-174c-b5bc03c4dd2a
md"This algorithm doesn't really require training, because the \"hard-coded\" program to print a string such as \"Hello World!\\n\" has proven to be very long to find (several hours)"

# ╔═╡ 75c5f5f0-906f-11eb-1a42-21acae635ed4
"fitness calculation, best fitness is 0"
function fitnessRepeat(prog,ticksLim)

	diff = 0
	
	input = [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33, 10] # Hello World!
	expect_out = [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33, 10] # Hello World! # add reverse() for fitnessReverse
	prog_out,ticks_out = brainfuck(prog,input;ticks_lim=ticksLim)
	
	# Padding
	
	if length(prog_out)<length(expect_out)
		pad_prog_out = append!(prog_out,zeros(Int64,length(expect_out)-length(prog_out)))
		pad_expect_out = expect_out
	elseif length(prog_out)>length(expect_out) #if the output is too long, we can simply cut the program
		pad_expect_out = expect_out
		pad_prog_out = prog_out[1:length(expect_out)]
	else
		pad_prog_out = prog_out
		pad_expect_out = expect_out
	end

	# Output comparison

	for i in 1:length(pad_prog_out)
		diff += abs(pad_prog_out[i]-pad_expect_out[i])
	end
    
		
    return diff
    
end

# ╔═╡ 9f9e70fe-9070-11eb-170e-e5c3b4eebca7
myOptions=GAOptions(popSize=200,maxProgSize=100,crossoverRate=0.7,mutationRate=0.01,showEvery=50,targetFit=0,maxGen=10000000,progTicksLim=2000,elitism=0.1)

# ╔═╡ 39d92e6c-921b-11eb-1f85-0b425678745b
md"This algorithms converges most of the time in less than a second !"

# ╔═╡ a5ebc786-9070-11eb-0755-bd44f0569aaf
begin
	bestFit1,bestInd1,elapsedTime1,gen1 = myGA(BFProg,fitnessRepeat,KB_CX,trivial,KB_mut,myOptions)
	@show bestFit1,bestInd1,elapsedTime1,gen1
end

# ╔═╡ cfdc0cc2-9070-11eb-1f82-7925bfe9f214
begin
	res = purify_code(bestInd1)
	@show res, join(Char.(brainfuck(res,[72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33, 10])[1]))
end

# ╔═╡ Cell order:
# ╟─9515582c-921a-11eb-05e1-c9f2b0a64b6b
# ╠═fde29336-906e-11eb-05ac-0546798d519b
# ╟─56a9a600-921b-11eb-174c-b5bc03c4dd2a
# ╠═75c5f5f0-906f-11eb-1a42-21acae635ed4
# ╠═9f9e70fe-9070-11eb-170e-e5c3b4eebca7
# ╟─39d92e6c-921b-11eb-1f85-0b425678745b
# ╠═a5ebc786-9070-11eb-0755-bd44f0569aaf
# ╠═cfdc0cc2-9070-11eb-1f82-7925bfe9f214
