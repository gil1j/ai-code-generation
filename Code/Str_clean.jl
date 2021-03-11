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
md"# Print \"hello\"
## A clean implementation using modules"

# ╔═╡ a1896204-82a9-11eb-1827-27d63a1a7c3b
"fitness calculation, best fitness is 0"
function fitnessStr(prog,ticksLim)

	#expect_out = [72, 101, 108, 108, 111]
    expect_out = [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33, 10] # Hello World!
	#expect_out = [72,87] # HW
	prog_out,ticks_out = brainfuck(prog;ticks_lim=ticksLim)
	
	diff = 0
	
	#penalties
	
	if length(prog_out) == 0
		diff += 50
	end
	if length(prog_out) != length(expect_out)
		diff += 25
	end
	if filter_bad_candidate(prog) == "bad"
		diff += 100
	end
	if ticks_out == ticksLim
		diff += 50
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
			diff += 10
		end
    end
    
	

		
    return diff
    
end

# ╔═╡ ec13eb8e-82a9-11eb-36f5-3d052464482e
"One Point Crossover"
function CX(p1,p2)
	marker1 = rand(1:min(length(p1)-1,length(p2)-1))


	c1 = p1[1:marker1]*p2[marker1+1:end]
	c2 = p2[1:marker1]*p1[marker1+1:end]

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

# ╔═╡ 3a9db8f0-82aa-11eb-2f69-3141fad6e346
myOptions=GAOptions(popSize=100,maxProgSize=5000,crossoverRate=0.8,mutationRate=0.05,showEvery=50,targetFit=0,maxGen=10000000,progTicksLim=5000,elitism=0.1)

# ╔═╡ 44691fa0-82aa-11eb-27a2-fdc13a60b4f7
begin
	@show Dates.now()
	@show "print hello world with roulette and adapted options"
	@show myOptions
end

# ╔═╡ 69a18d02-82aa-11eb-0a37-bdfaa73eba44
begin
	bestFit1,bestInd1,elapsedTime1,gen1 = myGA(BFProg,fitnessStr,CX,roulette,mut,myOptions)
	@show bestFit1,bestInd1,elapsedTime1,gen1
end

# ╔═╡ Cell order:
# ╟─70e61762-82a9-11eb-16b8-851f8bc89192
# ╠═dcdc4748-82a6-11eb-0002-63d3d288d3a5
# ╠═a1896204-82a9-11eb-1827-27d63a1a7c3b
# ╠═ec13eb8e-82a9-11eb-36f5-3d052464482e
# ╠═0de70c9e-82aa-11eb-005f-d5a184dee5e6
# ╠═2477253e-82aa-11eb-3b39-8d040b9063b9
# ╠═3a9db8f0-82aa-11eb-2f69-3141fad6e346
# ╠═44691fa0-82aa-11eb-27a2-fdc13a60b4f7
# ╠═69a18d02-82aa-11eb-0a37-bdfaa73eba44
