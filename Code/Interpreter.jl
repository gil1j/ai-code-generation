### A Pluto.jl notebook ###
# v0.12.7

using Markdown
using InteractiveUtils

# ╔═╡ ef15bb1a-69ec-11eb-007e-278ad9a4541b
using Match

# ╔═╡ 70446fba-69ed-11eb-1858-b5a60a6488cb
function brainfuck(str, memsize = 5000)

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

    # Run the program
    while instr <= length(code)  
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
                       instr = findnext(collect(code) .== ']', instr)
                   else
                       push!(stack, instr)
                    end)
            ']' => (if memory[ptr] != 0
                        instr = pop!(stack) - 1
                    else
                        pop!(stack)
                    end)      
        end
        instr += 1
    end
    return out
end

# ╔═╡ df708826-69fa-11eb-161b-553948a1ab53
function brainfuck_to(str, time_out = 1,memsize = 5000)
	@async((sleep(time_out);exit()))  
	brainfuck(str, memsize = 5000)
end

# ╔═╡ ff6e8d00-69ec-11eb-203f-09807144f920
Char.(brainfuck("++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."))

# ╔═╡ 07d8fe0a-69ed-11eb-3da8-57cf8ae76fb6
function generate_rand_prog(max_size)
    symbols = ['>','<','+','-','.','[',']'] #['>','<','+','-','.',',','[',']']  not using STDIN at the moment
    size = rand(1:max_size)
    code = Array{Char,1}(undef,size)
    for i in 1:size
        code[i] = rand(symbols)
    end
    return join(code)
end 

# ╔═╡ 0e424b20-69ed-11eb-236b-d1dbb4829a75
try
    brainfuck_to(generate_rand_prog(50))
catch
    println("Program cannot compile")
end

# ╔═╡ 18cd01fa-69ed-11eb-2b2b-39f63fb52165
function fitness(prog_out,expect_out)
    
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

# ╔═╡ 1fd460d0-69ed-11eb-162b-f3f2b0d8919c
fitness([5,6,2,8],[1,0,5])

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

# ╔═╡ 212e7470-69ed-11eb-0c91-0d2fedbde742
filter_bad_candidate(generate_rand_prog(50))

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
    
    # filter out obvious bad candidates in batch
    #TBC
end

# ╔═╡ 3c5231f6-69ed-11eb-03d1-5d5deef6299d
# genetic(fitness,10)

# ╔═╡ Cell order:
# ╠═ef15bb1a-69ec-11eb-007e-278ad9a4541b
# ╠═70446fba-69ed-11eb-1858-b5a60a6488cb
# ╠═df708826-69fa-11eb-161b-553948a1ab53
# ╠═ff6e8d00-69ec-11eb-203f-09807144f920
# ╠═07d8fe0a-69ed-11eb-3da8-57cf8ae76fb6
# ╠═0e424b20-69ed-11eb-236b-d1dbb4829a75
# ╠═18cd01fa-69ed-11eb-2b2b-39f63fb52165
# ╠═1fd460d0-69ed-11eb-162b-f3f2b0d8919c
# ╠═2f99ffdc-69ed-11eb-2060-735b07678435
# ╠═212e7470-69ed-11eb-0c91-0d2fedbde742
# ╠═362ae372-69ed-11eb-365a-57ad5c95e68b
# ╠═3c5231f6-69ed-11eb-03d1-5d5deef6299d
