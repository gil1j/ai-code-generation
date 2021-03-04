### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ d58647ee-7740-11eb-2281-cf75aefc8acc
using Match

# ╔═╡ 38bcbb86-7773-11eb-3d04-53fc9ecf45c6
using Random

# ╔═╡ ccc45988-7755-11eb-164b-559cc5c48157
begin
	using TickTock
	
	function myGA(generator,fitness,crossover,selection,mutation,options)
		tick()
		
		pop = [generator(options.maxProgSize) for i in 1:options.popSize]
		
		Threads.@threads for i in 1:length(pop)
			if pop[i].fitness == 10^10
				pop[i].fitness = fitness(pop[i].program,options.progTicksLim)
			end
		end
		
		stop = false
		
		gen = 0
		
		while(!stop)
			gen += 1
			
			parents = shuffle(pop)
			
			childs = []
			
			#crossover
			
			for i in 1:2:length(parents)

				p1 = parents[i]
				if options.popSize % 2 == 0
					p2 = parents[i+1]
				else
					p2 = parents[i-1]
				end
				
				if rand() <= options.crossoverRate
	
					c1_prog,c2_prog = crossover(p1.program,p2.program)
					c1 = generator(c1_prog,10^10)
					c2 = generator(c2_prog,10^10)
	
					append!(childs,[c1,c2])
				else
					c1 = p1
					c2 = p2
					
					append!(childs,[c1,c2])
				end
			end
			
			#mutation
			
			for i in 1:length(childs)
				
				if rand() <= options.mutationRate
					mut_prog = mutation(childs[i].program)
					mut = generator(mut_prog,10^10)
					
					childs[i] = mut
				end
			end
			
			if length(childs)<options.popSize
				append!(childs,[generator(options.maxProgSize) for i in 1:options.popSize-length(childs)])
			end
			
			#fitness
			
			Threads.@threads for i in 1:length(childs)
				if childs[i].fitness == 10^10
					childs[i].fitness = fitness(childs[i].program,options.progTicksLim)
				end
			end
			
			fitParents = Array{Int64,1}(undef,length(parents))
			
			for i in 1:length(parents)
				fitParents[i] = parents[i].fitness
			end
			
			indexElite = selection(fitParents,Int(round(length(parents)*options.elitism)))
			
			append!(childs,parents[indexElite])
			
			fitChilds = Array{Int64,1}(undef,length(childs))
			
			for i in 1:length(childs)
				fitChilds[i] = childs[i].fitness
			end
			
			#data
			
			bestFit = minimum(fitChilds)
			bestInd = childs[findfirst(fitChilds.==bestFit)].program
			elapsedTime = peektimer()
			
			if gen % options.showEvery == 0
				@show bestFit,bestInd,elapsedTime,gen
			end
			
			#selection
			
			indexToKeep = selection(fitChilds,options.popSize)
			indexToDelete = [x for x ∈ 1:length(childs) if x ∉ indexToKeep]
			
			deleteat!(childs,indexToDelete)
			pop = childs
			
			#stop criterion
			
			if gen > options.maxGen
				stop = true
				@show "Not good enough ..."
				return bestFit,bestInd,elapsedTime,gen
			elseif bestFit == options.targetFit
				stop = true
				@show "Il l'a fait ! Avec un vent légèrement défavorable ! IL L'A FAIT !!!"
				return bestFit,bestInd,elapsedTime,gen
			end
		end
	end
end

# ╔═╡ cfb0161a-7740-11eb-2fb6-79da5b2f1fe3
#function needed in the interpreter to find the matching ']' of a '['

function find_matching_bracket(str)
	counter_open = 1
	counter_close = 0
	for i in 1:length(str)
		if str[i] == '['
			counter_open += 1
		elseif str[i] == ']'
			counter_close += 1
		end
		
		if counter_open==counter_close
			return i
		end
	end
end

# ╔═╡ ba4e219a-7740-11eb-3420-bba8151ff8c6
# Interpreter, using a @match macro

function brainfuck(prog, memsize = 500, ticks_lim = 10000)

	#str = join(prog)
	#str = join(Char.(prog))
	
    out = Array{Int64,1}()
    
    # Read program and filter symbols
    symbols = ['>','<','+','-','.',',','[',']']
    code = filter(x -> in(x, symbols), prog)
    
    # Memory of the program
    memory = zeros(Int64, memsize) # Memory in Int64 at the moment, maybe to be adapted ?

    # Stack for loops
    stack = Array{Int64,1}()
    ptr = 1                 # Memory pointer
    instr = 1               # Instruction pointer
	
	ticks = 0 # ticks counter for timeout (and fitness calculation in the future ???)

    # Run the program
    while instr <= length(code) && ticks <= ticks_lim
        if ptr > memsize
            ptr = ptr - memsize
        end
        if ptr <= 0
            ptr = ptr + memsize
        end
        @match code[instr] begin
            '>' => (ptr += 1)
            '<' => (ptr -= 1)
            '+' => (memory[ptr] += 1)
            '-' => (memory[ptr] -= 1)
            '.' => push!(out,memory[ptr]) # NUMERICAL OUTPUT
            ',' => (memory[ptr] = read(STDIN, Char)) # To be adapted
            '[' => (if memory[ptr] == 0
						if find_matching_bracket(code[instr+1:end]) != nothing
							instr += find_matching_bracket(code[instr+1:end])
						end
                	else
                   		push!(stack, instr)
                    end)
            ']' => (if memory[ptr] != 0
						if length(stack) != 0
                        	instr = pop!(stack) - 1
						end
                    else
						if length(stack) != 0
                        	pop!(stack)
						end
                    end)      
        end
        instr += 1
		ticks += 1
    end
    return out,ticks
end

# ╔═╡ 0ebe025e-7741-11eb-3f59-bf14da3bcfc6
begin
	hw = "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."
	out,ticks = brainfuck(hw)
	join(Char.(out))
end

# ╔═╡ 9624d198-773f-11eb-1869-611413d65d6d
# programs (individuals) are stored as strings

# random individuals generation

begin
	function filter_bad_candidate(prog) # this function asserts brackets matching
    
    for i in 1:length(collect(prog))
        if length(findall(collect(prog[1:i]) .== ']')) > length(findall(collect(prog[1:i]) .== '['))
            return "bad"
        end
    end
    
	for i in 1:length(collect(reverse(prog)))
        if length(findall(collect(reverse(prog)[1:i]) .== '[')) > length(findall(collect(reverse(prog)[1:i]) .== ']'))
            return "bad"
        end
    end
		
	return "good"

    #TBC
    
	end
	
	
	function generate_rand_prog(max_size)
	symbols = ['>','<','+','-','.','[',']'] #['>','<','+','-','.',',','[',']']  not using STDIN at the moment
	
	state = "bad"
	
	while state == "bad"
		size = rand(5:max_size)
		code = Array{Char,1}(undef,size)
		for i in 1:size
			code[i] = rand(symbols)
		end
		
		state = filter_bad_candidate(join(code))
		if state == "good"
			return join(code)
		end
	end
	end
end
	

# ╔═╡ c667064e-7741-11eb-369b-693e7fc105f8
# fitness calculation, best fitness is 0

function fitness_hw(prog,ticks_lim)
	
    expect_out = [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33, 10] # let's go for the real stuff now !
	#expect_out = [72,87] # let's start with something more simple perhapse...
	prog_out,ticks_out = brainfuck(prog,ticks_lim)
	
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
	if ticks_out == ticks_lim
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
    end
    
	

		
    return diff
    
end

# ╔═╡ 1d915e2a-775d-11eb-07f7-359794472cfa
#crossover function as implemented by Kory Becker in her AI-programmer
# program is cut in 2 at random location, other half is taken at random

function CX_KB(p1,p2)
	marker1 = rand(1:length(p1)-1)
	
	c1 = p1[1:marker1]*join(rand(['>','<','+','-','.','[',']'],length(p1[marker1+1:end])))
	c2 = join(rand(['>','<','+','-','.','[',']'],length(p1[1:marker1])))*p1[marker1+1:end]
	
	return c1,c2
end

# ╔═╡ 02f67570-7cd0-11eb-3c52-9d73da3a893b
function CX(p1,p2)
	marker1 = rand(1:min(length(p1)-1,length(p2)-1))
	
	
	c1 = p1[1:marker1]*p2[marker1+1:end]
	c2 = p2[1:marker1]*p1[marker1+1:end]
	
	return c1,c2
end

# ╔═╡ 5d15d69a-775d-11eb-0ef5-33a11d94ae5d
# mutation function as implemented by Kory Becker in her AI-programmer
# 4 equiprobable mutations : delete, insert, modify or shift

function mut_KB(str)
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

# ╔═╡ 2e483ae6-775e-11eb-1ab6-75e8643b488e
# trivial selection, take best individuals

function mySelection(fitPop,popSize)
	indexSorted = sortperm(fitPop)
	toKeep = indexSorted[1:popSize]
	
	return toKeep
end

# ╔═╡ 6af8e4ae-7a60-11eb-3238-8d40e5ac2379
mutable struct BFProg
	program
	fitness::Int64
	
	function BFProg(maxProgSize::Int64)
		return new(generate_rand_prog(maxProgSize),10^10)
	end
	
	function BFProg(program,fitness::Int64)
		return new(program,fitness)
	end
end

# ╔═╡ 752264fe-775f-11eb-37bd-a3891c6f7b92
mutable struct GAOptions
	popSize::Int64
	maxProgSize::Int64
	crossoverRate::Float64
	mutationRate::Float64
	showEvery::Int64
	targetFit::Int64
	maxGen::Int64
	progTicksLim::Int64
	elitism::Float64
	genVariety::Int64
end

# ╔═╡ ae05c122-776d-11eb-064d-4796f6c58f3b
myOptions=GAOptions(200,500,0.8,0.05,50,0,10000000,10000,0.1,400)

# ╔═╡ a3d911f2-7cd0-11eb-3c48-55422fe25c8f
begin
	@show "RUN 04/03/2021, solved genetic variety issue, using concatenation at random location as crossover"
	@show myOptions
end

# ╔═╡ 0bf7c2c6-775d-11eb-3ee3-c5bc6abdc3e5
begin
	bestFit1,bestInd1,elapsedTime1,gen1 = myGA(BFProg,fitness_hw,CX,mySelection,mut_KB,myOptions)
	@show bestFit1,bestInd1,elapsedTime1,gen1
end

# ╔═╡ Cell order:
# ╟─d58647ee-7740-11eb-2281-cf75aefc8acc
# ╟─cfb0161a-7740-11eb-2fb6-79da5b2f1fe3
# ╠═ba4e219a-7740-11eb-3420-bba8151ff8c6
# ╟─0ebe025e-7741-11eb-3f59-bf14da3bcfc6
# ╠═9624d198-773f-11eb-1869-611413d65d6d
# ╠═c667064e-7741-11eb-369b-693e7fc105f8
# ╠═1d915e2a-775d-11eb-07f7-359794472cfa
# ╠═02f67570-7cd0-11eb-3c52-9d73da3a893b
# ╠═5d15d69a-775d-11eb-0ef5-33a11d94ae5d
# ╠═2e483ae6-775e-11eb-1ab6-75e8643b488e
# ╟─38bcbb86-7773-11eb-3d04-53fc9ecf45c6
# ╠═6af8e4ae-7a60-11eb-3238-8d40e5ac2379
# ╠═ccc45988-7755-11eb-164b-559cc5c48157
# ╠═752264fe-775f-11eb-37bd-a3891c6f7b92
# ╠═ae05c122-776d-11eb-064d-4796f6c58f3b
# ╠═a3d911f2-7cd0-11eb-3c48-55422fe25c8f
# ╠═0bf7c2c6-775d-11eb-3ee3-c5bc6abdc3e5
