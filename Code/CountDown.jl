### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 37820bbc-9097-11eb-3dd4-5d9899fce2ff
using GAFramework, Brainfuck, Random

# ╔═╡ bc5f1d62-9217-11eb-172c-49f3fe241849
md"# Countdown from input value
## A clean implementation using modules
The crossover/mutation/selection functions are stored in a library included in GAFramework.jl, hence only the fitness function is shown here."

# ╔═╡ ebe67d14-9217-11eb-0910-550f26e49de8
md"As long as we take a value sufficiently high as input for the fitness calculation, we don't require training to achieve a general implementation"

# ╔═╡ 4040291e-9097-11eb-0dde-df597c639dcb
"fitness calculation, best fitness is 0"
function fitnessCountDown(prog,ticksLim)
	
	diff = 0

	inputNums = [45]
	expect_out = reverse(1:inputNums[1])
	prog_out,ticks_out = brainfuck(prog,inputNums;ticks_lim=ticksLim)
	
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

# ╔═╡ a7714260-9097-11eb-0f28-a775bfdac7e1
myOptions=GAOptions(popSize=200,maxProgSize=100,crossoverRate=0.7,mutationRate=0.01,showEvery=50,targetFit=0,maxGen=10000000,progTicksLim=2000,elitism=0.1)

# ╔═╡ 7416ed72-9218-11eb-3b9e-5f0d6922c927
md"This algorithm takes a few seconds to converge, the countdown function is actually one of the easiest programs to implement in Brainfuck"

# ╔═╡ ad816bdc-9097-11eb-1639-6b66be3ecf18
begin
	bestFit1,bestInd1,elapsedTime1,gen1 = myGA(BFProg,fitnessCountDown,KB_CX,trivial,KB_mut,myOptions)
	@show bestFit1,bestInd1,elapsedTime1,gen1
end

# ╔═╡ ea2fa8aa-9097-11eb-3518-651a45727571
begin
	res = purify_code(bestInd1)
	@show res, Int.(brainfuck(res,[10])[1])
end

# ╔═╡ Cell order:
# ╟─bc5f1d62-9217-11eb-172c-49f3fe241849
# ╠═37820bbc-9097-11eb-3dd4-5d9899fce2ff
# ╟─ebe67d14-9217-11eb-0910-550f26e49de8
# ╠═4040291e-9097-11eb-0dde-df597c639dcb
# ╠═a7714260-9097-11eb-0f28-a775bfdac7e1
# ╟─7416ed72-9218-11eb-3b9e-5f0d6922c927
# ╠═ad816bdc-9097-11eb-1639-6b66be3ecf18
# ╠═ea2fa8aa-9097-11eb-3518-651a45727571
