### A Pluto.jl notebook ###
# v0.12.7

using Markdown
using InteractiveUtils

# ╔═╡ 0f52e60e-6d18-11eb-1bfb-9f4846f48a06
Threads.@spawn begin
	i = 0
	while i<20
		sleep(1)
		i += 1
	end
	println("i'm done counting")
end

# ╔═╡ 3f0b9f8a-6d18-11eb-24fa-9fe7d925d73d
Threads.@spawn begin
	sleep(5)
	interrupt(2)
	println("i stopped that slow bastard")
end

# ╔═╡ 5d3ce3c4-6d18-11eb-14a8-99316c7bbaba


# ╔═╡ Cell order:
# ╠═0f52e60e-6d18-11eb-1bfb-9f4846f48a06
# ╠═3f0b9f8a-6d18-11eb-24fa-9fe7d925d73d
# ╠═5d3ce3c4-6d18-11eb-14a8-99316c7bbaba
