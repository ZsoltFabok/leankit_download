require 'json'

module Common
	class FilesAndJson
		 def to_file(hash, filename)
		 	File.open(filename, "w") {|f| f.write(JSON.pretty_generate(hash))}
		end

		def from_file(filename)
			JSON.load(File.open(filename, "r"))
	  end
	end
end
