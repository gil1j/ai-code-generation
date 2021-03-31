### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ dcdc4748-82a6-11eb-0002-63d3d288d3a5
using GAFramework, Brainfuck, Random

# ╔═╡ 70e61762-82a9-11eb-16b8-851f8bc89192
md"# Print a String
## A clean implementation using modules
The crossover/mutation/selection functions are stored in a library included in GAFramework.jl, hence only the fitness function is shown here."

# ╔═╡ ad0f5cb2-9165-11eb-2648-ebfec1cb07fb
md"For this kind of program, we simply want the output String to be \"hard-coded\" in the source code, so we don't need any training. The length of the desired String will obviously influence drasticaly the speed of execution of the algorithm"

# ╔═╡ a1896204-82a9-11eb-1827-27d63a1a7c3b
"fitness calculation, best fitness is 0"
function fitnessStr(prog,ticksLim)
	#expect_out = [72, 101, 108, 108, 111] # Hello
    #expect_out = [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33, 10] # Hello World!
	expect_out = [104, 105, 33] # hi
	
	prog_out,ticks_out = brainfuck(prog;ticks_lim=ticksLim)
	
	diff = 0
	
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

# ╔═╡ e842e118-9166-11eb-397b-bfbbda6a1d9e
md"This is a very efficient way to display \"Hello World\\n\""

# ╔═╡ d3daf648-9166-11eb-1fee-c37569bc4791
fitnessStr("++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.",10000)

# ╔═╡ 3a9db8f0-82aa-11eb-2f69-3141fad6e346
myOptions=GAOptions(popSize=100,maxProgSize=200,crossoverRate=0.7,mutationRate=0.05,showEvery=100,targetFit=0,maxGen=10000000,progTicksLim=1000,elitism=0.1)

# ╔═╡ d1ab1132-9175-11eb-1e2c-5f1866fc99f8
md"This works quite well for strings up to 3-4 characters (a few seconds for \"hi\", a few minutes for \"hi!\"), but for more, cell initialization takes an enormous amount of time because characters are often 100+ in ASCII. We will later tackle this problem using Brainfuck Extended, which supports digits for faster cell initialization."

# ╔═╡ 69a18d02-82aa-11eb-0a37-bdfaa73eba44
begin
	bestFit1,bestInd1,elapsedTime1,gen1 = myGA(BFProg,fitnessStr,KB_CX,trivial,KB_mut,myOptions)
	@show bestFit1,bestInd1,elapsedTime1,gen1
end

# ╔═╡ be7c0406-9164-11eb-124d-5b69ff19f18f
begin
	res = purify_code(bestInd1)
	@show res, join(Char.(brainfuck(res)[1]))
end

# ╔═╡ Cell order:
# ╟─70e61762-82a9-11eb-16b8-851f8bc89192
# ╠═dcdc4748-82a6-11eb-0002-63d3d288d3a5
# ╟─ad0f5cb2-9165-11eb-2648-ebfec1cb07fb
# ╠═a1896204-82a9-11eb-1827-27d63a1a7c3b
# ╟─e842e118-9166-11eb-397b-bfbbda6a1d9e
# ╠═d3daf648-9166-11eb-1fee-c37569bc4791
# ╠═3a9db8f0-82aa-11eb-2f69-3141fad6e346
# ╟─d1ab1132-9175-11eb-1e2c-5f1866fc99f8
# ╠═69a18d02-82aa-11eb-0a37-bdfaa73eba44
# ╠═be7c0406-9164-11eb-124d-5b69ff19f18f
