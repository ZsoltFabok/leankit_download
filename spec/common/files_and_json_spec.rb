require 'spec_helper'

describe Common::FilesAndJson do
	it "writes the argument data to a file in json" do
		json_output = "output"
		hash = {}
		file = double
		expect(JSON).to receive(:pretty_generate).with(hash).and_return(json_output)
		expect(File).to receive(:open).with("filename", "w").and_yield(file)
		expect(file).to receive(:write).with(json_output)
		Common::FilesAndJson.new.to_file(hash, "filename")
	end
end
