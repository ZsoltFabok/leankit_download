require 'spec_helper_with_integration'

describe LeankitDownload::DownloadBoard do
  context "unit" do
    before(:each) do
      @files_and_json = double
      @board_name = "first-title"
      @board_id = 1
      @card_id = 2
      @board_all = [[{"Title" => @board_name, "Id" => @board_id}, {"Title" => "second-title"}]]
      @board_find = [{"Lanes" => [{"Cards" => [{"Id" => @card_id, "LastActivity" => "2013/09/16 03:10:48 PM"}]}], "Backlog" => [{"Cards" => []}]}]
      @archive = [[{"Lane" => {"Cards" => []}}]]
      @card_history = [[{"CardId"=>@card_id}], [{"DateTime"=>"2013/09/16 at 03:10:44 PM"}], [{"DateTime"=>"2013/09/16 at 03:10:48 PM"}]]
      @card_info = "info"
      @location = "test_folder/ut/location"
      @download_board = LeankitDownload::DownloadBoard.new(@files_and_json)
      @email = "foo@example.com"
      @password = "password"
      @account = "account"
    end

    it "sets the login credentials" do
      expect(LeanKitKanban::Board).to receive(:all).and_return(@board_all)
      expect(LeanKitKanban::Board).to receive(:find).with(@board_id).and_return([{"Lanes" => [{"Cards" => []}], "Backlog" => [{"Cards" => []}]}])
      expect(LeanKitKanban::Archive).to receive(:fetch).with(@board_id).and_return(@archive)
      expect(@files_and_json).to receive(:to_file).with(@board_all, "#{@location}/all_boards.json")

      @download_board.download_board(@location, @email, @password, @account, @board_name)

      expect(LeanKitKanban::Config.email).to equal(@email)
      expect(LeanKitKanban::Config.password).to equal(@password)
      expect(LeanKitKanban::Config.account).to equal(@account)
    end

    it "downloads the whole history of a new card because the card doesn't have a stored history" do
      expect(File).to receive(:exists?).with("#{@location}/all_boards.json").and_return(false)
      expect(LeanKitKanban::Board).to receive(:all).and_return(@board_all)
      expect(@files_and_json).to receive(:to_file).with(@board_all, "#{@location}/all_boards.json")
      expect(LeanKitKanban::Board).to receive(:find).with(@board_id).and_return(@board_find)
      expect(LeanKitKanban::Archive).to receive(:fetch).with(@board_id).and_return(@archive)
      expect(LeanKitKanban::Card).to receive(:find).with(@board_id, @card_id).and_return(@card_info)
      expect(File).to receive(:exists?).with("#{@location}/#{@board_name}/#{@card_id}.json").and_return(false)
      expect(Dir).to receive(:exists?).with("#{@location}/#{@board_name}").and_return(false)
      expect(Dir).to receive(:mkdir).with("#{@location}/#{@board_name}")
      expect(@files_and_json).to receive(:to_file).with(@card_info, "#{@location}/#{@board_name}/#{@card_id}.json")
      expect(LeanKitKanban::Card).to receive(:history).with(@board_id, @card_id).and_return(@card_history)
      expect(@files_and_json).to receive(:to_file).with(@card_history, "#{@location}/#{@board_name}/#{@card_id}_history.json")
      @download_board.download_board(@location, @email, @password, @account, @board_name)
    end

    it "doesn't downloads the history of a new card because there are no changes regarding that card" do
      expect(File).to receive(:exists?).with("#{@location}/all_boards.json").and_return(true)
      expect(LeanKitKanban::Board).not_to receive(:all)
      expect(@files_and_json).to receive(:from_file).with("#{@location}/all_boards.json").and_return(@board_all)
      expect(LeanKitKanban::Board).to receive(:find).with(@board_id).and_return(@board_find)
      expect(LeanKitKanban::Archive).to receive(:fetch).with(@board_id).and_return(@archive)
      expect(LeanKitKanban::Card).not_to receive(:history)
      expect(File).to receive(:exists?).with("#{@location}/#{@board_name}/#{@card_id}.json").and_return(true)
      expect(@files_and_json).to receive(:from_file).with("#{@location}/#{@board_name}/#{@card_id}_history.json").and_return(@card_history)
      expect(@files_and_json).not_to receive(:to_file)
      @download_board.download_board(@location, @email, @password, @account, @board_name)
    end

    it "downloads the history of a new card because there are changes regarding that card" do
      @card_history = [{"CardId"=>@card_id}, [{"DateTime"=>"2013/09/16 at 03:10:44 PM"}], [{"DateTime"=>"2013/09/16 at 03:09:48 PM"}]]
      expect(File).to receive(:exists?).with("#{@location}/all_boards.json").and_return(true)
      expect(LeanKitKanban::Board).not_to receive(:all)
      expect(@files_and_json).to receive(:from_file).with("#{@location}/all_boards.json").and_return(@board_all)
      expect(LeanKitKanban::Board).to receive(:find).with(@board_id).and_return(@board_find)
      expect(LeanKitKanban::Archive).to receive(:fetch).with(@board_id).and_return(@archive)
      expect(LeanKitKanban::Card).to receive(:history).with(@board_id, @card_id).and_return(@card_history)
      expect(File).to receive(:exists?).with("#{@location}/#{@board_name}/#{@card_id}.json").and_return(true)
      expect(@files_and_json).to receive(:from_file).with("#{@location}/#{@board_name}/#{@card_id}_history.json").and_return(@card_history)
      expect(@files_and_json).to receive(:to_file).with(@card_history, "#{@location}/#{@board_name}/#{@card_id}_history.json")
      @download_board.download_board(@location, @email, @password, @account, @board_name)
    end

    it "downloads the cards from the backlog as well" do
      @board_find = [{"Lanes" => [], "Backlog" => [{"Cards" => [{"Id" => @card_id, "LastActivity" => "2013/09/16 03:10:48 PM"}]}]}]
      expect(File).to receive(:exists?).with("#{@location}/all_boards.json").and_return(true)
      expect(LeanKitKanban::Board).not_to receive(:all)
      expect(@files_and_json).to receive(:from_file).with("#{@location}/all_boards.json").and_return(@board_all)
      expect(LeanKitKanban::Board).to receive(:find).with(@board_id).and_return(@board_find)
      expect(LeanKitKanban::Archive).to receive(:fetch).with(@board_id).and_return(@archive)
      expect(LeanKitKanban::Card).to receive(:find).with(@board_id, @card_id).and_return(@card_info)
      expect(File).to receive(:exists?).with("#{@location}/#{@board_name}/#{@card_id}.json").and_return(false)
      expect(Dir).to receive(:exists?).with("#{@location}/#{@board_name}").and_return(false)
      expect(Dir).to receive(:mkdir).with("#{@location}/#{@board_name}")
      expect(@files_and_json).to receive(:to_file).with(@card_info, "#{@location}/#{@board_name}/#{@card_id}.json")
      expect(LeanKitKanban::Card).to receive(:history).with(@board_id, @card_id).and_return(@card_history)
      expect(@files_and_json).to receive(:to_file).with(@card_history, "#{@location}/#{@board_name}/#{@card_id}_history.json")
      @download_board.download_board(@location, @email, @password, @account, @board_name)
    end

    it "downloads the cards from the archive" do
      archive = [[{"Lane" => {"Cards" => [{"Id" => @card_id, "LastActivity" => "2013/09/16 03:10:48 PM"}]}}]]
      expect(File).to receive(:exists?).with("#{@location}/all_boards.json").and_return(true)
      expect(LeanKitKanban::Board).not_to receive(:all)
      expect(@files_and_json).to receive(:from_file).with("#{@location}/all_boards.json").and_return(@board_all)
      expect(LeanKitKanban::Board).to receive(:find).with(@board_id).and_return([{"Lanes" => [{"Cards" => []}], "Backlog" => [{"Cards" => []}]}])
      expect(LeanKitKanban::Archive).to receive(:fetch).with(@board_id).and_return(archive)
      expect(LeanKitKanban::Card).to receive(:find).with(@board_id, @card_id).and_return(@card_info)
      expect(File).to receive(:exists?).with("#{@location}/#{@board_name}/#{@card_id}.json").and_return(false)
      expect(Dir).to receive(:exists?).with("#{@location}/#{@board_name}").and_return(false)
      expect(Dir).to receive(:mkdir).with("#{@location}/#{@board_name}")
      expect(@files_and_json).to receive(:to_file).with(@card_info, "#{@location}/#{@board_name}/#{@card_id}.json")
      expect(LeanKitKanban::Card).to receive(:history).with(@board_id, @card_id).and_return(@card_history)
      expect(@files_and_json).to receive(:to_file).with(@card_history, "#{@location}/#{@board_name}/#{@card_id}_history.json")
      @download_board.download_board(@location, @email, @password, @account, @board_name)
    end

    it "downloads the cards from the archive from the archive child lanes" do
      archive = [[{"Lane" => {"Cards" => []}, "ChildLanes" => [{"Lane" => {"Cards" => [{"Id" => @card_id, "LastActivity" => "2013/09/16 03:10:48 PM"}]}}]}]]
      expect(File).to receive(:exists?).with("#{@location}/all_boards.json").and_return(true)
      expect(LeanKitKanban::Board).not_to receive(:all)
      expect(@files_and_json).to receive(:from_file).with("#{@location}/all_boards.json").and_return(@board_all)
      expect(LeanKitKanban::Board).to receive(:find).with(@board_id).and_return([{"Lanes" => [{"Cards" => []}], "Backlog" => [{"Cards" => []}]}])
      expect(LeanKitKanban::Archive).to receive(:fetch).with(@board_id).and_return(archive)
      expect(LeanKitKanban::Card).to receive(:find).with(@board_id, @card_id).and_return(@card_info)
      expect(File).to receive(:exists?).with("#{@location}/#{@board_name}/#{@card_id}.json").and_return(false)
      expect(Dir).to receive(:exists?).with("#{@location}/#{@board_name}").and_return(false)
      expect(Dir).to receive(:mkdir).with("#{@location}/#{@board_name}")
      expect(@files_and_json).to receive(:to_file).with(@card_info, "#{@location}/#{@board_name}/#{@card_id}.json")
      expect(LeanKitKanban::Card).to receive(:history).with(@board_id, @card_id).and_return(@card_history)
      expect(@files_and_json).to receive(:to_file).with(@card_history, "#{@location}/#{@board_name}/#{@card_id}_history.json")
      @download_board.download_board(@location, @email, @password, @account, @board_name)
    end
  end

  context "integration" do
    before(:each) do
      clean_test_data
      go_to_test_dir
    end

    after(:each) do
      go_back
    end

    it "downloads the history of the cards for the boards in config file" do
      add_boards_to_config_file("Devops", "portfolio")
      add_login_credentials_to_config_file
      mock_leankit_all_board
      mock_leankit_board_find(12780) # Devops
      mock_leankit_board_find(46517) # portfolio
      mock_leankit_archive_fetch(12780)
      mock_leankit_archive_fetch(46517)
      mock_leankit_card_find(12780, 10795) # backlog
      mock_leankit_card_find(12780, 10831)
      mock_leankit_card_find(12780, 10843) # archive
      mock_leankit_card_find(46517, 10566)
      mock_leankit_card_find(46517, 37655)
      mock_leankit_card_find(46517, 20857)
      mock_leankit_card_history(12780, 10795)
      mock_leankit_card_history(46517, 10566)
      mock_leankit_card_history(46517, 37655)
      mock_leankit_card_history(46517, 20857)
      mock_leankit_card_history(12780, 10831) # backlog
      mock_leankit_card_history(12780, 10843) # archive

      run_app

      all_boards_json_has_been_downloaded
      card_info_has_been_downloaded("Devops", 12780, 10795)
      card_info_has_been_downloaded("Devops", 12780, 10831)
      card_info_has_been_downloaded("Devops", 12780, 10843)
      card_info_has_been_downloaded("portfolio", 46517, 10566)
      card_info_has_been_downloaded("portfolio", 46517, 10566)
      card_info_has_been_downloaded("portfolio", 46517, 20857)
      card_history_has_been_downloaded("Devops", 10795)
      card_history_has_been_downloaded("Devops", 10831)
      card_history_has_been_downloaded("Devops", 10843)
      card_history_has_been_downloaded("portfolio", 10566)
      card_history_has_been_downloaded("portfolio", 10566)
      card_history_has_been_downloaded("portfolio", 20857)
    end

    it "does not download the history of the card because it has not changed" do
      add_boards_to_config_file("Devops")
      add_login_credentials_to_config_file
      mock_leankit_all_board
      mock_leankit_board_find(12780) # sandbox
      mock_leankit_archive_fetch(12780)
      should_not_call_leankit_card_find(12780, 10795) # backlog
      should_not_call_leankit_card_find(12780, 10831)
      should_not_call_leankit_card_find(12780, 10843) # archive
      should_not_call_leankit_card_history(12780, 10831)
      should_not_call_leankit_card_history(12780, 10795) # backlog
      should_not_call_leankit_card_history(12780, 10843) # archive
      copy_card_files("Devops", 12780, 10831)
      copy_card_files("Devops", 12780, 10795)
      copy_card_files("Devops", 12780, 10843)

      run_app
    end
  end
end
