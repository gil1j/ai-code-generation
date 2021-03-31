### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ fde29336-906e-11eb-05ac-0546798d519b
using GAFramework, Brainfuck, Random

# ╔═╡ 2a3477f6-913c-11eb-0b6c-779a908c5d75
md"# Output the Length of a String
## A clean implementation using Modules
The crossover/mutation/selection functions are stored in a library included in GAFramework.jl, hence only the fitness function is shown here."

# ╔═╡ 6c7f3862-913c-11eb-3fb4-7bf009e40ed6
md"This kind of program requires multiple examples of training of different lengths, because we want to avoid the length of the String beeing \"hard-coded\" in the Brainfuck program"

# ╔═╡ 75c5f5f0-906f-11eb-1a42-21acae635ed4
"fitness calculation, best fitness is 0"
function fitnessLength(prog,ticksLim)

	training = [[5, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33, 10],[72, 101, 108, 108, 111],[87, 111, 114, 108, 100,1],[72],[18,21],[2,48,47]]
	
	diff = 0
	
	for i in training
		inputNums = i
		expect_out = [length(inputNums)]
		prog_out,ticks_out = brainfuck(prog,inputNums;ticks_lim=ticksLim)

		# Padding of program output / expected output, to be able to compare output even if their length differ
		
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
	end
    
		
    return diff
    
end

# ╔═╡ a40a4fa6-913c-11eb-1974-c727cf6dea9e
md"This is how a human programmer would solve this problem, let's see how the AI does it"

# ╔═╡ 19614dc2-9093-11eb-2932-6f7a90383c2b
fitnessLength("+[<+>,]<-.",5000)

# ╔═╡ 9f9e70fe-9070-11eb-170e-e5c3b4eebca7
myOptions=GAOptions(popSize=200,maxProgSize=100,crossoverRate=0.7,mutationRate=0.01,showEvery=50,targetFit=0,maxGen=10000000,progTicksLim=2000,elitism=0.1)

# ╔═╡ d09c8d9a-913c-11eb-2771-dddc8485d42a
md"Impressive ! The search should normally take between 1 and 60 seconds. It is amazing to see that the AI replicated the exact same loop I came up with previously, except it doesn't know how to program !"

# ╔═╡ a5ebc786-9070-11eb-0755-bd44f0569aaf
begin
	bestFit1,bestInd1,elapsedTime1,gen1 = myGA(BFProg,fitnessLength,KB_CX,trivial,KB_mut,myOptions)
	@show bestFit1,bestInd1,elapsedTime1,gen1
end

# ╔═╡ cfdc0cc2-9070-11eb-1f82-7925bfe9f214
begin
	res = purify_code(bestInd1)
	@show res, Int(brainfuck(res,rand(1:255,42))[1][1])
end

# ╔═╡ Cell order:
# ╟─2a3477f6-913c-11eb-0b6c-779a908c5d75
# ╠═fde29336-906e-11eb-05ac-0546798d519b
# ╟─6c7f3862-913c-11eb-3fb4-7bf009e40ed6
# ╠═75c5f5f0-906f-11eb-1a42-21acae635ed4
# ╟─a40a4fa6-913c-11eb-1974-c727cf6dea9e
# ╠═19614dc2-9093-11eb-2932-6f7a90383c2b
# ╠═9f9e70fe-9070-11eb-170e-e5c3b4eebca7
# ╟─d09c8d9a-913c-11eb-2771-dddc8485d42a
# ╠═a5ebc786-9070-11eb-0755-bd44f0569aaf
# ╠═cfdc0cc2-9070-11eb-1f82-7925bfe9f214
