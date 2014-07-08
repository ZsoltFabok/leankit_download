require 'spec_helper'
require 'json'

TEST_AT_FOLDER = "test_folder/at"
TEST_DATA_FOLDER = "test_folder/data"
MODIFICATION_DATE = {}


def clean_test_data
	FileUtils.rm_rf(TEST_AT_FOLDER)
	FileUtils.mkdir_p(File.join(TEST_AT_FOLDER, "leankit_dump"))
end

def go_to_test_dir
	Dir.chdir(TEST_AT_FOLDER)
end

def go_back
	Dir.chdir("../..")
end

def add_boards_to_config_file(*boards)
	content = read_json("boards.json")
  boards_ = []
  boards.each do |board|
    boards_ << [board, {}]
  end
  content["boards"] = boards_
	write_json("boards.json", content)
end

def add_login_credentials_to_config_file
	content = read_json("boards.json")
	content["leankit"] = {:email => "foo@example.com", :password => "password", :account => "account"}
	write_json("boards.json", content)
end

def mock_leankit_all_board
	response = read_json_from_test_data("leankit_response_all_boards.json")
	allow(LeanKitKanban::Board).to receive(:all).and_return(response)
end

def mock_leankit_board_find(board_id)
	response = read_json_from_test_data("leankit_response_board_find_#{board_id}.json")
	expect(LeanKitKanban::Board).to receive(:find).with(board_id).and_return(response)
end

def mock_leankit_archive_fetch(board_id)
	response = read_json_from_test_data("leankit_response_archive_fetch_#{board_id}.json")
	expect(LeanKitKanban::Archive).to receive(:fetch).with(board_id).and_return(response)
end

def mock_leankit_card_find(board_id, card_id)
	response = read_json_from_test_data("leankit_response_card_find_#{board_id}_#{card_id}.json")
	expect(LeanKitKanban::Card).to receive(:find).with(board_id, card_id).and_return(response)
end

def mock_leankit_card_history(board_id, card_id)
	response = read_json_from_test_data("leankit_response_card_history_#{card_id}.json")
	expect(LeanKitKanban::Card).to receive(:history).with(board_id, card_id).and_return(response)
end

def should_not_call_leankit_card_find(board_id, card_id)
	expect(LeanKitKanban::Card).not_to receive(:find).with(board_id, card_id)
end

def should_not_call_leankit_card_history(board_id, card_id)
	expect(LeanKitKanban::Card).not_to receive(:history).with(board_id, card_id)
end

def all_boards_json_has_been_downloaded
	files_are_the_same("leankit_dump/all_boards.json", "leankit_response_all_boards.json")
end

def card_info_has_been_downloaded(board_name, board_id, card_id)
	files_are_the_same("leankit_dump/#{board_name}/#{card_id}.json", "leankit_response_card_find_#{board_id}_#{card_id}.json")
end

def card_history_has_been_downloaded(board_name, card_id)
  files_are_the_same("leankit_dump/#{board_name}/#{card_id}_history.json", "leankit_response_card_history_#{card_id}.json")
end

def copy_card_files(board_name, board_id, card_id)
	history_file = "leankit_dump/#{board_name}/#{card_id}_history.json"
	FileUtils.mkdir_p("leankit_dump/#{board_name}") unless Dir.exists?("leankit_dump/#{board_name}")
	FileUtils.cp("../data/leankit_response_card_history_#{card_id}.json", history_file)
	FileUtils.cp("../data/leankit_response_card_find_#{board_id}_#{card_id}.json", "leankit_dump/#{board_name}/#{card_id}.json")
end

def add_board_column_mapping_to_config_file(board_name, mapping)
	File.open("boards.json", "w") {|f| f.write(JSON.pretty_generate({:boards => {board_name => mapping}}))}
end

def run_app
	LeankitDownload::Runner.run
end

def read_file(file_name)
  File.open(file_name).read
end

def write_file(file_name, content)
  File.open(file_name, "w+") {|f| f.write(content)}
end

private
def files_are_the_same(filename1, filename2)
	expect(FileUtils.compare_file(filename1, File.join("../data", filename2))).to be true
end

def read_json(filename)
	if File.exists?(filename)
		JSON.load(File.open(filename, "r"))
	else
		{}
	end
end

def read_json_from_test_data(filename)
	read_json(File.join("../data", filename))
end

def write_json(filename, content)
	File.open(filename, "w+") {|f| f.write(JSON.pretty_generate(content))}
end
