### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ dcdc4748-82a6-11eb-0002-63d3d288d3a5
using GAFramework, Brainfuck, Random

# ╔═╡ 70e61762-82a9-11eb-16b8-851f8bc89192
md"# Add (or subtract) 2 numbers
## A clean implementation using modules
The crossover/mutation/selection functions are stored in a library included in GAFramework.jl, hence only the fitness function is shown here."

# ╔═╡ eb652962-9154-11eb-1bcd-a3b6cb84a92a
md"This kind of program requires multiple examples of training of different lengths, because we want to avoid the sum (or difference) beeing \"hard-coded\" in the Brainfuck program"

# ╔═╡ a1896204-82a9-11eb-1827-27d63a1a7c3b
"fitness calculation, best fitness is 0"
function fitnessAdd(prog,ticksLim)
	
	training = [ (1,2), (3, 4), (5,1), (6,2) , (3,6) , (2,0) ] # same as AI-programmer for addition

	diff = 0
	
	for i in training
		
		inputNums = i
		expect_out = [sum(inputNums)] #for addition

		prog_out,ticks_out = brainfuck(prog,[inputNums[1],inputNums[2]];ticks_lim=ticksLim)
		
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

# ╔═╡ 14bb82c0-9155-11eb-0a20-7178c4ab1aeb
md"This is how a human programmer would solve this problem, let's see how the AI does it"

# ╔═╡ cea5b774-8745-11eb-0e7a-1fa91c76bfb2
fitnessAdd(",>,[-<+>]<.",2000)

# ╔═╡ 1ad1944c-9155-11eb-3a37-674d04ef1cc3
md"The logic is exactly the same for subtraction as for addition, the expected output simply needs to be the difference of the training couples instead of the sum"

# ╔═╡ 47d64cec-913e-11eb-2968-87572e4b9ebe
"fitness calculation, best fitness is 0"
function fitnessSubtract(prog,ticksLim)
	
	training = [(9,8),(6,3),(4,2),(5,1),(7,2)] # for subtraction
	diff = 0
	
	for i in training
		
		inputNums = i
		expect_out = [inputNums[1]-inputNums[2]] # for subtraction
		
		prog_out,ticks_out = brainfuck(prog,[inputNums[1],inputNums[2]];ticks_lim=ticksLim)

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

# ╔═╡ 3dee5e2e-9155-11eb-1987-51af44df9554
md"The \"ideal\" code looks very similar to the one of addition, we can probably expect very similar results"

# ╔═╡ e2b9f108-9140-11eb-2d25-21dcea126604
fitnessSubtract(",>,[<->-]<.",5000)

# ╔═╡ 3a9db8f0-82aa-11eb-2f69-3141fad6e346
myOptions=GAOptions(popSize=200,maxProgSize=100,crossoverRate=0.7,mutationRate=0.01,showEvery=50,targetFit=0,maxGen=10000000,progTicksLim=2000,elitism=0.2)

# ╔═╡ 6c89bb5a-9157-11eb-21d2-b957f949437d
md"This algorithm takes between 10 seconds and 10 minutes. This high variance in the convergence time is due to the very short source code of the target program. Luck can very often give a viable candidate very quickly"

# ╔═╡ 69a18d02-82aa-11eb-0a37-bdfaa73eba44
begin
	bestFit1,bestInd1,elapsedTime1,gen1 = myGA(BFProg,fitnessSubtract,KB_CX,trivial,KB_mut,myOptions)
	@show bestFit1,bestInd1,elapsedTime1,gen1
end

# ╔═╡ 46bb48a4-88b9-11eb-3efd-f1bc45bddcaf
begin
	res = purify_code(bestInd1)
	@show res, Int.(brainfuck(res,[25,13])[1][1])
end

# ╔═╡ Cell order:
# ╟─70e61762-82a9-11eb-16b8-851f8bc89192
# ╠═dcdc4748-82a6-11eb-0002-63d3d288d3a5
# ╟─eb652962-9154-11eb-1bcd-a3b6cb84a92a
# ╠═a1896204-82a9-11eb-1827-27d63a1a7c3b
# ╟─14bb82c0-9155-11eb-0a20-7178c4ab1aeb
# ╠═cea5b774-8745-11eb-0e7a-1fa91c76bfb2
# ╟─1ad1944c-9155-11eb-3a37-674d04ef1cc3
# ╠═47d64cec-913e-11eb-2968-87572e4b9ebe
# ╟─3dee5e2e-9155-11eb-1987-51af44df9554
# ╠═e2b9f108-9140-11eb-2d25-21dcea126604
# ╠═3a9db8f0-82aa-11eb-2f69-3141fad6e346
# ╟─6c89bb5a-9157-11eb-21d2-b957f949437d
# ╠═69a18d02-82aa-11eb-0a37-bdfaa73eba44
# ╠═46bb48a4-88b9-11eb-3efd-f1bc45bddcaf
