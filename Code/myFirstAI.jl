### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ d11a8770-71d6-11eb-1ab4-5102c438d49e
using Match

# ╔═╡ daad98ea-71d6-11eb-332c-f900695f315a
using Evolutionary

# ╔═╡ bc269058-76e4-11eb-150b-cf062276d5e6
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
		

# ╔═╡ 0382db68-76eb-11eb-2576-f5f307f9f656
typeof(find_matching_bracket("["))

# ╔═╡ f9fab714-71d6-11eb-30f5-970b89dd1e60
# Interpreter, using a @match macro

function brainfuck(prog, memsize = 500, ticks_lim = 5000)

	#str = join(prog)
	str = join(Char.(prog))
	
    out = Array{Int64,1}()
    
    # Read program and filter symbols
    symbols = ['>','<','+','-','.',',','[',']']
    code = filter(x -> in(x, symbols), str)
    
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
            '.' => push!(out,memory[ptr]) # NUMERICAL OUTPUT conv to ascii -> String(UInt8.([memory[ptr]]))
            ',' => (memory[ptr] = read(STDIN, Char)) # To be adapted
            '[' => (if memory[ptr] == 0
						if find_matching_bracket(code[instr+1:end]) != nothing
							instr = find_matching_bracket(code[instr+1:end])
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

# ╔═╡ 1d4ccbe4-71d7-11eb-1005-6774318f64f4
# random individuals generation

begin
	function filter_bad_candidate(prog)
    
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
			# return code # "return join(code)" for string instead of array
			return Int.(code) # for usage with evolutionary.jl (easier with Int instead of Char)
		end
	end
	end
end
	

# ╔═╡ 36447d48-71d7-11eb-2c15-9b5a7d8d665b
# fitness calculation, best fitness is 0

function fitness_hw(prog)
	
    #expect_out = [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33, 10] 
	expect_out = [72,87] # let's start with something more simple perhapse...
	prog_out,ticks_out = brainfuck(prog)
	
	diff = 0
	
	#penalties
	
	if length(prog_out) == 0
		diff += 50
	end
	if length(prog_out) != length(expect_out)
		diff += 25
	end
	if filter_bad_candidate(join(prog)) == "bad"
		diff += 100
	end
	
    if length(prog_out)<length(expect_out)
        pad_prog_out = append!(prog_out,zeros(Int64,length(expect_out)-length(prog_out)))
        pad_expect_out = expect_out
    elseif length(prog_out)>length(expect_out)
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

# ╔═╡ 9941edba-71d7-11eb-2dc2-6300f642969e
function CX(p1,p2)
	marker1 = rand(1:min(length(p1)-1,length(p2)-1))
	
	
	c1 = vcat(p1[1:marker1],p2[marker1+1:end])
	c2 = vcat(p2[1:marker1],p1[marker1+1:end])
	
	return c1,c2
end

# ╔═╡ 73ee950e-76d7-11eb-1a55-23de5fa98221
function CX_KB(p1,p2)
	marker1 = rand(1:length(p1))
	
	c1 = vcat(p1[1:marker1],Int.(rand(['>','<','+','-','.','[',']'],length(p1[marker1+1:end]))))
	c2 = vcat(Int.(rand(['>','<','+','-','.','[',']'],length(p1[1:marker1]))),p1[marker1+1:end])
	
	return c1,c2
end

# ╔═╡ 7566367a-71d8-11eb-1365-a13177c37284
function mut(str)
	str_mut = str
	i = rand(1:length(str))
	str_mut[i] = Int(rand(['>','<','+','-','.','[',']']))
	str = str_mut
end

# ╔═╡ 69d36fca-76d9-11eb-2b66-096a828b117c
function mut_KB(str)
	str_mut = str
	r = rand()
	
	if r<=0.25 && length(str_mut) != 0 #delete
		i = rand(1:length(str_mut))
		str_mut = deleteat!(str_mut,i)
	#elseif r<=0.5 #insert
		#i = rand(1:length(str_mut))
		#str_mut = insert!(str_mut,i,Int(rand(['>','<','+','-','.','[',']'])))
	elseif r<=0.75 #modify
		i = rand(1:length(str))
		str_mut[i] = Int(rand(['>','<','+','-','.','[',']']))
	#else #shift
		#if rand()<0.5
		#	str_mut = circshift(str_mut,1)
		#else
		#	str_mut = circshift(str_mut,-1)
		#end
	end
	
	str = str_mut
end

# ╔═╡ 997183a8-71d8-11eb-25d2-5734f4ae0619
myGA = GA(populationSize=100,
	crossoverRate=0.8,
	mutationRate=0.1,
	epsilon=5,
	selection=roulette,
	crossover=CX_KB,
	mutation=mut)

# ╔═╡ a84a2484-71d8-11eb-2f82-b5ae6dcc6b9c
begin
	
	# callback function used to stop the optimization when fitness reaches 0
	
	function cb(trace::Evolutionary.OptimizationTraceRecord{Int64,Evolutionary.GA})
		if trace.value == 0
			return true
		else
			return false
		end
	end
	
	opts = Evolutionary.Options(iterations=100000,successive_f_tol=100000,show_trace=true,show_every=10,callback=cb)
end

# ╔═╡ b9b31dbe-71d8-11eb-1d83-256f0bcdd00e
res = Evolutionary.optimize(fitness_hw,generate_rand_prog(200),myGA,opts)

# ╔═╡ 4a95d330-71fe-11eb-0d33-1716772482e7
filter_bad_candidate(join(Char.(res.minimizer))) == "bad"

# ╔═╡ 3848f30a-76dc-11eb-3a50-170b14292d8b
begin
			i = rand(1:11)
			str_mut = insert!(Int.(rand(['>','<','+','-','.','[',']'],10)),i,Int(rand(['>','<','+','-','.','[',']'])))
end

# ╔═╡ Cell order:
# ╠═d11a8770-71d6-11eb-1ab4-5102c438d49e
# ╠═daad98ea-71d6-11eb-332c-f900695f315a
# ╠═bc269058-76e4-11eb-150b-cf062276d5e6
# ╠═0382db68-76eb-11eb-2576-f5f307f9f656
# ╠═f9fab714-71d6-11eb-30f5-970b89dd1e60
# ╠═1d4ccbe4-71d7-11eb-1005-6774318f64f4
# ╠═36447d48-71d7-11eb-2c15-9b5a7d8d665b
# ╠═9941edba-71d7-11eb-2dc2-6300f642969e
# ╠═73ee950e-76d7-11eb-1a55-23de5fa98221
# ╠═7566367a-71d8-11eb-1365-a13177c37284
# ╠═69d36fca-76d9-11eb-2b66-096a828b117c
# ╠═997183a8-71d8-11eb-25d2-5734f4ae0619
# ╠═a84a2484-71d8-11eb-2f82-b5ae6dcc6b9c
# ╠═b9b31dbe-71d8-11eb-1d83-256f0bcdd00e
# ╠═4a95d330-71fe-11eb-0d33-1716772482e7
# ╠═3848f30a-76dc-11eb-3a50-170b14292d8b
