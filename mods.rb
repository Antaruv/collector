puts "Loaded mods.rb"




def convert(num)

	mods = ["NF","EZ","NV","HD","HR","SD","DT","Relax","HT","NC","FL","Auto","SO","Relax2","PF"]
	num = num.to_i
	bin = num.to_s(2).rjust(15,"0").reverse
	con = []
	mods.size.times do |i|
		if bin[i] == "1" then
			con.push(mods[i])
		end
	end
	return con
end

def ARcon(ar,modn)
	mods = convert(modn)

	ar*=1.4 if mods.include? "HR"
	ar*=0.5 if mods.include? "EZ"

	ar = [ar,10].min

	arms = 1950-(150*ar)
	arms = 1800-(120*ar) if ar<5

	arms/=1.5 if mods.include? "DT"
	arms/=0.75 if mods.include? "HT"

	ar = 13-(arms/150)
	ar = 15-(arms/120) if arms>1200

	return ar
end
