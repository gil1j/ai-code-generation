### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ ef15bb1a-69ec-11eb-007e-278ad9a4541b
using Match

# ╔═╡ 70446fba-69ed-11eb-1858-b5a60a6488cb
function brainfuck(prog, memsize = 5000, ticks_lim = 100000)

	str = join(prog)
	
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
						if findnext(collect(code) .== ']', instr) != nothing
                    		instr = findnext(collect(code) .== ']', instr)
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

# ╔═╡ df708826-69fa-11eb-161b-553948a1ab53


# ╔═╡ ff6e8d00-69ec-11eb-203f-09807144f920
begin
	hw = "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."
	out,ticks = brainfuck(hw)
	show(out)
	show(join(Char.(out)))
	println("program executed in $ticks ticks")
	
end

# ╔═╡ 2f99ffdc-69ed-11eb-2060-735b07678435
function filter_bad_candidate(prog)
    
    for i in 1:length(collect(prog))
        if length(findall(collect(prog[1:i]) .== ']')) > length(findall(collect(prog[1:i]) .== '['))
            return "bad"
        end
    end
    
	return "good"

    #TBC
    
end

# ╔═╡ 07d8fe0a-69ed-11eb-3da8-57cf8ae76fb6
function generate_rand_prog(max_size)
	symbols = ['>','<','+','-','.','[',']'] #['>','<','+','-','.',',','[',']']  not using STDIN at the moment
	
	state = "bad"
	
	while state == "bad"
		size = rand(1:max_size)
		code = Array{Char,1}(undef,size)
		for i in 1:size
			code[i] = rand(symbols)
		end
		
		state = filter_bad_candidate(join(code))
		if state == "good"
			return code # "return join(code)" for string instead of array
		end
	end
end 

# ╔═╡ 0e424b20-69ed-11eb-236b-d1dbb4829a75
begin
	out_rand,ticks_rand= brainfuck(generate_rand_prog(50))
	show(join(Char.(out_rand)))
	println("program executed in $ticks_rand ticks")
end

# ╔═╡ 18cd01fa-69ed-11eb-2b2b-39f63fb52165
function fitness_hw(prog)
    expect_out = [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33, 10]
	prog_out,ticks_out = brainfuck(prog)
    if length(prog_out)<length(expect_out)
        pad_prog_out = append!(prog_out,zeros(Int64,length(expect_out)-length(prog_out)))
        pad_expect_out = expect_out
    elseif length(prog_out)>length(expect_out)
        pad_expect_out = append!(expect_out,zeros(Int64,length(prog_out)-length(expect_out)))
        pad_prog_out = prog_out
    else
        pad_prog_out = prog_out
        pad_expect_out = expect_out
    end
    
    diff = 0
    for i in 1:length(pad_prog_out)
        diff += abs(pad_prog_out[i]-pad_expect_out[i])
    end
    
    return diff
    
end

# ╔═╡ 362ae372-69ed-11eb-365a-57ad5c95e68b
function genetic(fitness,batch_size;max_prog_size=5000)
    
    # generate batch
    batch = Array{String,1}(undef,batch_size)
    
    for i in 1:batch_size
        cand = generate_rand_prog(max_prog_size)
        while filter_bad_candidate(cand) == "bad"
            cand = generate_rand_prog(max_prog_size)
        end
        batch[i] = cand
    end
    
    output = Array{Array{Int64,1},1}(undef,batch_size)
    for i in 1:batch_size
        output[i] = brainfuck(batch[i])
    end
    
    # filter out obvious bad candidates in batch, later ???
    #TBC
end

# ╔═╡ Cell order:
# ╠═ef15bb1a-69ec-11eb-007e-278ad9a4541b
# ╠═70446fba-69ed-11eb-1858-b5a60a6488cb
# ╟─df708826-69fa-11eb-161b-553948a1ab53
# ╠═ff6e8d00-69ec-11eb-203f-09807144f920
# ╠═2f99ffdc-69ed-11eb-2060-735b07678435
# ╠═07d8fe0a-69ed-11eb-3da8-57cf8ae76fb6
# ╠═0e424b20-69ed-11eb-236b-d1dbb4829a75
# ╠═18cd01fa-69ed-11eb-2b2b-39f63fb52165
# ╟─362ae372-69ed-11eb-365a-57ad5c95e68b
