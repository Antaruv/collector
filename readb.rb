puts "Loaded readb.rb"

def readformat(format,file)

	#by=byte, sh=short, in=int, lo=long, ul=uleb, si=single, do=double, bo=boolean, st=string, id=int-double pair, ti=timing point, mid=multiple id's, mti=multiple timings, mst=multiple strings
	returner = []
	format.each do |ar|
		val = readbyte(file) if ar=="by"
		val = readshort(file) if ar=="sh"
		val = readint(file) if ar=="in"
		val = readlong(file) if ar=="lo"
		val = readULEB(file) if ar=="ul"
		val = readsingle(file) if ar=="si"
		val = readdouble(file) if ar=="do"
		val = readbool(file) if ar=="bo"
		val = readstring(file) if ar=="st"
		val = readintdouble(file) if ar=="id"
		val = readtime(file) if ar=="ti"
		val = readmid(file) if ar=="mid"
		val = readmti(file) if ar=="mti"
		val = readmst(file) if ar=="mst"

		#puts "NO VAL, #{ar}" if val == nil
		returner.push val
	end

	return returner

end

def getbytes(file,size)
	array = []
	size.times do |t|
		array.push file.readbyte.to_s(16).rjust(2,"0")
	end
	bytes = ""
	array.reverse.each do |a|
		bytes+=a
	end
	return bytes
end

def readbyte(file)
	byte = getbytes(file,1)
	return byte.to_i(16)
end

def readshort(file)
	byte = getbytes(file,2)
	return byte.to_i(16)
end

def readint(file)
	byte = getbytes(file,4)
	return byte.to_i(16)
end

def readlong(file)
	byte = getbytes(file,8)
	return byte.to_i(16)
end

def readULEB(file)
	done = false
	bys = []
	while not done
		bin = getbytes(file,1).to_i(16).to_s(2).rjust(8,"0")
		if bin[0] == "0" then
			done = true
		end

		bys.unshift(bin[1..7])
	end

	total = ""
	bys.each do |b|
		total+=b
	end

	return total.to_i(2)
end

def readstring(file)
	byte = file.readbyte().to_s(16).rjust(2,"0")


	if byte == "00" then
		return nil
	elsif byte == "0b" then
		n = readULEB(file)

		newar = []
		n.times do |t|
			newar.push(getbytes(file,1).to_i(16))
		end

		return newar.pack("C*").force_encoding("utf-8")
	end
end

def readbool(file)
	byte = file.readbyte()
	if byte == 0 then
		return false
	else
		return true
	end
end

def readsingle(file)
	by = getbytes(file,4).to_i(16).to_s(2).rjust(32,"0")

	s = by[0]
	e = by[1..8]
	f = by[9..31]

	fa = 1
	fe = f.split("")

	22.times do |t|
		i = t+1
		fa+=fe[t].to_f*2**(-i)
	end

	return (-1)**s.to_i*2**(e.to_i(2)-127)*fa
end

def readdouble(file)
	by = getbytes(file,8).to_i(16).to_s(2).rjust(64,"0")

	s = by[0]
	e = by[1..11]
	f = by[12..63]

	fa = 1
	fe = f.split("")

	51.times do |t|
		i = t+1
		fa+=fe[t].to_f*2**(-i)
	end

	return (-1)**s.to_i*2**(e.to_i(2)-1023)*fa
end

def readintdouble(file)
	byte = getbytes(file,1)

	puts "PANIC1" if not byte == "08"

	int = readint(file)

	byte = getbytes(file,1)
	puts "PANIC2!!" if not byte == "0d"

	double = readdouble(file)

	return [int,double]
end

def readtime(file)
	bpm = readdouble(file)
	offset = readdouble(file)
	inherit = readbool(file)

	return [bpm,offset,inherit]
end

def readmid(file)
	tot = readint(file)

	pairs = []
	tot.times do |i|
		pairs.push(readintdouble(file))
	end

	return pairs
end

def readmti(file)
	tot = readint(file)

	timing = []
	tot.times do |i|
		timing.push(readtime(file))
	end

	return timing
end

def readmst(file)
	tot = readint(file)

	strings = []
	tot.times do |i|
		strings.push(readstring(file))
	end

	return strings
end