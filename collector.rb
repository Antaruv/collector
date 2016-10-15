require_relative "readb.rb"
require_relative "mods.rb"
require 'fileutils'
require 'zip'
pdir = File.basename(Dir.getwd)
Dir.chdir("../")
system 'cls'

puts "If you run into any errors, delete the 'processing' folder and savethehashes.txt if they exist." 
system 'PAUSE'
system 'cls'

if not File.exist?("collection.db") or not File.exist?("osu!.db") or not Dir.exist?("Songs") then
	puts "collection.db not found" if not File.exist?("collection.db")
	puts "osu!.db not found" if not File.exist?("osu!.db")
	puts "Songs folder not found" if not Dir.exist?("Songs")

	puts "--------------","collector.exe should be in a folder in your osu! folder, so osu!/packager/collector.exe, for example."
	system 'PAUSE'
	abort
end


file2 = File.open("collection.db","rb")

headformat = ["in","in","bo","lo","st","in"]


beatformat = ["in","st","st","st","st","st","st","st","st","st","by","sh","sh","sh","lo","si","si","si","si","do","mid","mid","mid","mid","in","in","in","mti","in","in","in","by","by","by","by","sh","si","by","st","st","sh","st","bo",
"lo","bo","st","lo","bo","bo","bo","bo","bo","in","by"]

colhformat = ["in","in"]
collformat = ["st","mst"]

colh = readformat(colhformat, file2)

if colh[0].to_i < 20140609 then
	puts "This does not work with your version of osu because your version of osu is outdated. What the fuck though, really, the oldest working version is 2014!"
	system "PAUSE"
	abort
end

collections = {}

colh[1].times do |t|
	coll = readformat(collformat,file2)
	#puts "#{coll[0]} has #{coll[1].size} maps"
	collections[coll[0]] = coll[1]
end



answer = ""
if File.exist?("#{pdir}/savethehashes.txt") then
	puts "Have you added any maps since last running the program? y/n"
	answer = gets.chomp
end

if answer.downcase == "y" or not File.exist?("#{pdir}/savethehashes.txt") then
	file = File.open("osu!.db","rb")
	head = readformat(headformat, file)

	mtable = {}

	head[5].times do |t|
		b = readformat(beatformat,file)
		mtable[b[8]] = b[45]

		if t.to_f/500 == (t/500).to_i then
			system 'cls'
			puts "Building map table... (This can take a while if you have a lot of maps)"
			puts "#{((t.to_f/head[5])*100).round(2)}%" 
		end
	end

	hfile = File.new("#{pdir}/savethehashes.txt","w")
	mtable.each do |h,v|
		hfile.puts "#{h}\t#{v}"
	end
	hfile.close
	puts "Map table built!"
else
	puts "If, when packaging a collection, you get a 'no map folder' error, then you need rebuild the map table from scratch."
	file = File.open("#{pdir}/savethehashes.txt","r")
	mtable = {}
	file.each do |l|
		l.force_encoding("utf-8")
		arr = l.delete("\n").split("\t") 
		mtable[arr[0]] = arr[1]
	end
end

system 'PAUSE'


Dir.chdir("#{pdir}")
collections.each do |h,v|
	system 'cls'
	puts "Package the collection '#{h}?' (#{v.size} maps) Y/N"
	yn = gets.chomp

	if yn.downcase == "y" then
		foldernames = []
		v.each do |hash|
			if mtable[hash] then
				foldernames.push mtable[hash]
			else
				puts "Map missing!"
			end
		end

		foldernames.uniq!

		cont = true

		if File.exist?("collection-#{h}.zip") then
			puts "collection-#{h}.zip already exists, overwrite? Y/N"
			answer = gets.chomp
			if answer.downcase == "y" then
				File.delete("collection-#{h}.zip")
			else
				cont = false
			end
		end

		if cont then
			if not Dir.exist?("processing") then
				Dir.mkdir("processing")
			end
			#Dir.mkdir("#{h}")
			zipnames = []
			system 'cls'
			puts "Packaging maps..."
			t=0
			foldernames.each do |name|
				if File.exist?("../Songs/#{name}") then
					folder = "../Songs/#{name}"
					filenames = Dir.entries(folder)

					zipn = "#{name}.osz"

					zipnames.push(zipn)
					Zip::File.open("processing/#{zipn}",Zip::File::CREATE) do |zipfile|
						filenames.each do |fn|
							zipfile.add(fn,folder+'/'+fn)
						end
					end


				else
					puts "-------\nERROR: no map folder for #{name}\n-------"
				end
				t+=1
				puts "#{t}/#{foldernames.size}"
			end
			puts "Creating collection-#{h}.zip..."
			Zip::File.open("collection-#{h}.zip",Zip::File::CREATE) do |zipfile|
				zipnames.each do |zipn|
					zipfile.add(zipn,"processing/#{zipn}")
				end
			end

			#zipnames.each do |zipn|
			#	File.delete("processing/#{zipn}")
			#end
			puts "Removing trash..."


			FileUtils.rm_rf("processing")
			puts "Done!"
		end
	end
end
system 'cls'
puts "Finished!"
system 'PAUSE'