### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ d58647ee-7740-11eb-2281-cf75aefc8acc
using Match

# ╔═╡ cfb0161a-7740-11eb-2fb6-79da5b2f1fe3
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

function brainfuck(prog, memsize = 500, ticks_lim = 5000)

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
			return join(code)
		end
	end
	end
end
	

# ╔═╡ c667064e-7741-11eb-369b-693e7fc105f8
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
	if filter_bad_candidate(prog) == "bad"
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

# ╔═╡ d99c1f6e-773f-11eb-29a6-bb8545a6e04f
begin
	popSize = 100
	pop = [generate_rand_prog(200) for i in 1:popSize]
	
	fitness = fitness_hw.(pop)
	
end

# ╔═╡ Cell order:
# ╠═d58647ee-7740-11eb-2281-cf75aefc8acc
# ╠═cfb0161a-7740-11eb-2fb6-79da5b2f1fe3
# ╠═ba4e219a-7740-11eb-3420-bba8151ff8c6
# ╠═0ebe025e-7741-11eb-3f59-bf14da3bcfc6
# ╠═9624d198-773f-11eb-1869-611413d65d6d
# ╠═c667064e-7741-11eb-369b-693e7fc105f8
# ╠═d99c1f6e-773f-11eb-29a6-bb8545a6e04f
