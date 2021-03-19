### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ dcdc4748-82a6-11eb-0002-63d3d288d3a5
using GAFramework, Brainfuck, Dates, Random

# ╔═╡ 2477253e-82aa-11eb-3b39-8d040b9063b9
begin
	using StatsBase
	
	"roulette selection, probability of an individual being selected is proportional to its fitness. note : roulette selection kills strict elitism"
	function roulette(fitPop, N)
		fitPopRel = abs.(fitPop.-maximum(fitPop))
		fitPopRel = fitPopRel .+ 0.001
		prob = Weights(fitPopRel./sum(fitPopRel))
		selectionFit = sample(fitPopRel,prob,N,replace=false)

		selectionInd = []
		for i in 1:length(selectionFit)
			append!(selectionInd,[findfirst(fitPopRel.==selectionFit[i])])
			fitPopRel[findfirst(fitPopRel.==selectionFit[i])] = -1
		end

		return selectionInd
	end
end

# ╔═╡ 70e61762-82a9-11eb-16b8-851f8bc89192
md"# Add 2 numbers
## A clean implementation using modules"

# ╔═╡ a1896204-82a9-11eb-1827-27d63a1a7c3b
"fitness calculation, best fitness is 0"
function fitnessAdd(prog,ticksLim)
	
	training = [ (1,2), (3, 4), (5,1), (6,2) , (3,6) , (2,0) ] # same as AI-programmer
	
	diff = 0
	
	#penalties

		
		if filter_bad_candidate(prog) == "bad"
			#diff += 25
		end
		
	
	for i in training
		
		inputNums = i
		expect_out = [sum(inputNums)]
		prog_out,ticks_out = brainfuck(prog,[inputNums[1],inputNums[2]];ticks_lim=ticksLim)

		if length(prog_out) != length(expect_out)
			#diff += 25
		end
		if ticks_out == ticksLim
			#diff += 50
		end

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


		for i in 1:length(pad_prog_out)
			diff += abs(pad_prog_out[i]-pad_expect_out[i])
			#penalty for different char

			if pad_prog_out[i] != pad_expect_out[i]
				#diff += 10
			end
		end
    
	end
		
    return diff
    
end

# ╔═╡ cea5b774-8745-11eb-0e7a-1fa91c76bfb2
fitnessAdd(",>,[-<+>]<.",2000)

# ╔═╡ 986c1276-82c1-11eb-33e6-6bb62e52f59e
begin
	inputNums = rand(1:255,2)
	expect_out = [sum(inputNums)]
end

# ╔═╡ ec13eb8e-82a9-11eb-36f5-3d052464482e
"One Point Crossover"
function CX(p1,p2)
	if length(p1)>1 && length(p2)>1
		marker1 = rand(1:min(length(p1)-1,length(p2)-1))


		c1 = p1[1:marker1]*p2[marker1+1:end]
		c2 = p2[1:marker1]*p1[marker1+1:end]
	else
		c1 = p1
		c2 = p2
	end

	return c1,c2
end

# ╔═╡ f052edea-857e-11eb-32ab-a74b385adca8
function CX_KB(p1,p2)
	if length(p1)>1 && length(p2)>1
	
		marker1 = rand(1:length(p1)-1)

		c1 = p1[1:marker1]*join(rand(['>','<','+','-','.','[',']'],length(p1[marker1+1:end])))
		c2 = join(rand(['>','<','+','-','.','[',']'],length(p1[1:marker1])))*p1[marker1+1:end]
	
	else
		c1 = p1
		c2 = p2
	end
	
	return c1,c2
end


# ╔═╡ 0de70c9e-82aa-11eb-005f-d5a184dee5e6
"mutation function as implemented by Kory Becker in her AI-programmer.
4 equiprobable mutations : delete, insert, modify or shift"
function mut(str)
	str_mut = collect(str)
	r = rand()

	if r<=0.25 && length(str_mut) > 1 #delete
		i = rand(1:length(str_mut))
		deleteat!(str_mut,i)
	elseif r<=0.5 #insert
		i = rand(1:length(str_mut)+1)
		insert!(str_mut,i,rand(['>','<','+','-','.','[',']']))
	elseif r<=0.75 #modify
		i = rand(1:length(str))
		str_mut[i] = rand(['>','<','+','-','.','[',']'])
	else #shift
		if rand()<0.5
			str_mut = circshift(str_mut,1)
		else
			str_mut = circshift(str_mut,-1)
		end
	end

	return join(str_mut)
end

# ╔═╡ 90551370-82c7-11eb-3ef2-97cd3fbf7baa
"trivial selection"
function mySelection(fitPop,popSize)
	indexSorted = sortperm(fitPop)
	toKeep = indexSorted[1:popSize]
	
	return toKeep
end

# ╔═╡ 3a9db8f0-82aa-11eb-2f69-3141fad6e346
myOptions=GAOptions(popSize=200,maxProgSize=100,crossoverRate=0.7,mutationRate=0.01,showEvery=50,targetFit=0,maxGen=10000000,progTicksLim=2000,elitism=0.2)

# ╔═╡ 44691fa0-82aa-11eb-27a2-fdc13a60b4f7
begin
	@show Dates.now()
	@show "solved genetic variety issue, using concatenation at random location as crossover"
	@show myOptions
end

# ╔═╡ 69a18d02-82aa-11eb-0a37-bdfaa73eba44
begin
	bestFit1,bestInd1,elapsedTime1,gen1 = myGA(BFProg,fitnessAdd,CX,roulette,mut,myOptions)
	@show bestFit1,bestInd1,elapsedTime1,gen1
end

# ╔═╡ Cell order:
# ╟─70e61762-82a9-11eb-16b8-851f8bc89192
# ╠═dcdc4748-82a6-11eb-0002-63d3d288d3a5
# ╠═a1896204-82a9-11eb-1827-27d63a1a7c3b
# ╠═cea5b774-8745-11eb-0e7a-1fa91c76bfb2
# ╠═986c1276-82c1-11eb-33e6-6bb62e52f59e
# ╠═ec13eb8e-82a9-11eb-36f5-3d052464482e
# ╠═f052edea-857e-11eb-32ab-a74b385adca8
# ╠═0de70c9e-82aa-11eb-005f-d5a184dee5e6
# ╠═2477253e-82aa-11eb-3b39-8d040b9063b9
# ╠═90551370-82c7-11eb-3ef2-97cd3fbf7baa
# ╠═3a9db8f0-82aa-11eb-2f69-3141fad6e346
# ╠═44691fa0-82aa-11eb-27a2-fdc13a60b4f7
# ╠═69a18d02-82aa-11eb-0a37-bdfaa73eba44
