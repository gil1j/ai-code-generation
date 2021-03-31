### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ dcdc4748-82a6-11eb-0002-63d3d288d3a5
using GAFramework, Brainfuck, Random

# ╔═╡ 70e61762-82a9-11eb-16b8-851f8bc89192
md"# Multiply an input with a constant
## A clean implementation using modules
The crossover/mutation/selection functions are stored in a library included in GAFramework.jl, hence only the fitness function is shown here."

# ╔═╡ 6a2cae80-921a-11eb-0d47-c9e151b13520
md"This algorithm requires training to avoid a \"hard-coded\" value"

# ╔═╡ a1896204-82a9-11eb-1827-27d63a1a7c3b
"fitness calculation, best fitness is 0"
function fitnessMultiply(prog,ticksLim)
	
	training = [10,3,1,5,8]
	
	diff = 0
	
	for i in training
		
		inputNums = i
		expect_out = [inputNums*2] 
		prog_out,ticks_out = brainfuck(prog,[inputNums];ticks_lim=ticksLim)
		
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
    
	end
		
    return diff
    
end

# ╔═╡ 3a9db8f0-82aa-11eb-2f69-3141fad6e346
myOptions=GAOptions(popSize=200,maxProgSize=100,crossoverRate=0.7,mutationRate=0.01,showEvery=50,targetFit=0,maxGen=10000000,progTicksLim=2000,elitism=0.2)

# ╔═╡ 48167c0e-921a-11eb-2aec-75a7f89340e5
md"This algorithm converges in 1 to 10 minutes, a bit longer for a multiplication by 3"

# ╔═╡ 69a18d02-82aa-11eb-0a37-bdfaa73eba44
begin
	bestFit1,bestInd1,elapsedTime1,gen1 = myGA(BFProg,fitnessMultiply,KB_CX,trivial,KB_mut,myOptions)
	@show bestFit1,bestInd1,elapsedTime1,gen1
end

# ╔═╡ 46bb48a4-88b9-11eb-3efd-f1bc45bddcaf
begin
	res = purify_code(bestInd1)
	@show res, Int.(brainfuck(res,[12])[1][1])
end

# ╔═╡ Cell order:
# ╟─70e61762-82a9-11eb-16b8-851f8bc89192
# ╠═dcdc4748-82a6-11eb-0002-63d3d288d3a5
# ╟─6a2cae80-921a-11eb-0d47-c9e151b13520
# ╠═a1896204-82a9-11eb-1827-27d63a1a7c3b
# ╠═3a9db8f0-82aa-11eb-2f69-3141fad6e346
# ╟─48167c0e-921a-11eb-2aec-75a7f89340e5
# ╠═69a18d02-82aa-11eb-0a37-bdfaa73eba44
# ╠═46bb48a4-88b9-11eb-3efd-f1bc45bddcaf
