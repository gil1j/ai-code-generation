### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ fde29336-906e-11eb-05ac-0546798d519b
using GAFramework, Brainfuck, Random

# ╔═╡ 05d3aeba-9216-11eb-1892-8d6a391fd216
md"# Perform Logical XOR, OR and AND
## A clean implementation using modules
The crossover/mutation/selection functions are stored in a library included in GAFramework.jl, hence only the fitness function is shown here."

# ╔═╡ 2b4816e0-9216-11eb-0e82-59c984b853d7
md"We will perform logic operations on binary couples, so we can easily train the algorithm on all the combinations"

# ╔═╡ 75c5f5f0-906f-11eb-1a42-21acae635ed4
"fitness calculation, best fitness is 0"
function fitnessLogic(prog,ticksLim)

	training = [[0,0],[0,1],[1,0],[1,1]]
	
	diff = 0
	
	for i in training
		inputNums = i
		expect_out = [xor(inputNums[1],inputNums[2])] # xor
		#expect_out = [Int(!iszero(inputNums[1]) || !iszero(inputNums[2]))] # or (||), and (&&)
		prog_out,ticks_out = brainfuck(prog,inputNums;ticks_lim=ticksLim)

		# Output comparison
		
		if length(prog_out) == 0
			diff += 1
		elseif expect_out[1] != prog_out[1]
			diff += 1
		end
	end
    
		
    return diff
    
end

# ╔═╡ 9f9e70fe-9070-11eb-170e-e5c3b4eebca7
myOptions=GAOptions(popSize=200,maxProgSize=100,crossoverRate=0.7,mutationRate=0.01,showEvery=50,targetFit=0,maxGen=10000000,progTicksLim=2000,elitism=0.1)

# ╔═╡ 5fa98676-9216-11eb-1f9b-2585d3bcf1de
md"This algorithm takes most of the time less than a second to converge. Working only with 1's and 0's seems to be convenient for the brainfuck language, because a 0 input will allow to easily skip a loop"

# ╔═╡ a5ebc786-9070-11eb-0755-bd44f0569aaf
begin
	bestFit1,bestInd1,elapsedTime1,gen1 = myGA(BFProg,fitnessLogic,KB_CX,trivial,KB_mut,myOptions)
	@show bestFit1,bestInd1,elapsedTime1,gen1
end

# ╔═╡ cfdc0cc2-9070-11eb-1f82-7925bfe9f214
begin
	res = purify_code(bestInd1)
	@show res, brainfuck(res,[1,1])[1][1]
end

# ╔═╡ Cell order:
# ╟─05d3aeba-9216-11eb-1892-8d6a391fd216
# ╠═fde29336-906e-11eb-05ac-0546798d519b
# ╟─2b4816e0-9216-11eb-0e82-59c984b853d7
# ╠═75c5f5f0-906f-11eb-1a42-21acae635ed4
# ╠═9f9e70fe-9070-11eb-170e-e5c3b4eebca7
# ╟─5fa98676-9216-11eb-1f9b-2585d3bcf1de
# ╠═a5ebc786-9070-11eb-0755-bd44f0569aaf
# ╠═cfdc0cc2-9070-11eb-1f82-7925bfe9f214
