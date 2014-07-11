module LeankitDownload
  class DownloadBoard

    def initialize(files_and_json)
      @files_and_json = files_and_json
    end

    def download(boards_json, destination, dry_run=false)
      content = @files_and_json.from_file(boards_json)
      email = content["leankit"]["email"]
      password = content["leankit"]["password"]
      account = content["leankit"]["account"]

      board_locations = []
      content["boards"].each do |board|
        if !dry_run
          board_locations << download_board(destination, email, password, account, board[0])
        else
          board_location = File.join(destination, board[0])
          if File.exist?(board_location)
            board_locations << board_location
          end
        end
      end
      board_locations
    end

    def download_board(destination, email, password, account, board_name)
      login(email, password, account)
      board_id = get_board_id(destination, board_name)
      get_card_ids(board_id).each do |card_id, last_activity|
        if !File.exists?(card_info_filename(destination, board_name, card_id))
          dump_card_info(destination, board_name, board_id, card_id)
          dump_card_history(destination, board_name, board_id, card_id)
        else
          card_history = @files_and_json.from_file(card_history_filename(destination, board_name, card_id))
          last_history_entry_happened = DateTime.parse(card_history.last[0]["DateTime"])
          if last_history_entry_happened < last_activity
            dump_card_history(destination, board_name, board_id, card_id)
          end
        end
      end
      File.join(destination, board_name)
    end

    def self.create
      new(Common::FilesAndJson.new)
    end

    private
    def login(email, password, account)
      if LeanKitKanban::Config.email == nil
        LeanKitKanban::Config.email    = email
        LeanKitKanban::Config.password = password
        LeanKitKanban::Config.account  = account
      end
    end

    def get_board_id(destination, board_name)
      filename = all_boards_filename(destination)
      if File.exists?(filename)
        all_boards = @files_and_json.from_file(filename)
      end
      if all_boards == nil
        all_boards = LeanKitKanban::Board.all
        @files_and_json.to_file(all_boards, filename)
      end
      all_boards[0].each do |board|
        if board["Title"].eql? board_name
          return board["Id"]
        end
      end
      return nil
    end

    def get_card_ids(board_id)
      board = LeanKitKanban::Board.find(board_id)[0]
      archive = LeanKitKanban::Archive.fetch(board_id)[0][0]
      backlog = board["Backlog"][0]
      remove_the_ghost_card!(archive)
      merge_card_ids(get_backlog_card_ids(backlog), get_board_card_ids(board), get_archive_card_ids(archive))
    end

    def dump_card_history(destination, board_name, board_id, card_id)
      card_history = LeanKitKanban::Card.history(board_id, card_id)
      @files_and_json.to_file(card_history, card_history_filename(destination, board_name, card_id))
    end

    def dump_card_info(destination, board_name, board_id, card_id)
      card_info = LeanKitKanban::Card.find(board_id, card_id)
      Dir.mkdir(board_directory(destination, board_name)) unless Dir.exists?(board_directory(destination, board_name))
      @files_and_json.to_file(card_info, card_info_filename(destination, board_name, card_id))
    end

    def board_directory(destination, board_name)
      "#{destination}/#{board_name}"
    end

    def card_info_filename(destination, board_name, card_id)
      "#{destination}/#{board_name}/#{card_id}.json"
    end

    def card_history_filename(destination, board_name, card_id)
      "#{destination}/#{board_name}/#{card_id}_history.json"
    end

    def all_boards_filename(destination)
      "#{destination}/all_boards.json"
    end

    def remove_the_ghost_card!(archive)
      if archive.has_key?("Lane") && archive["Lane"].has_key?("Cards")
        archive["Lane"]["Cards"].delete_if do |card|
          card["SystemType"] == "GhostCard"
        end
      end
    end

    def get_board_card_ids(board)
      card_ids = {}
      board["Lanes"].each do |lane|
        lane["Cards"].each do |card|
          card_ids[card["Id"]] = DateTime.parse(card["LastActivity"])
        end
      end
      card_ids
    end

    def get_backlog_card_ids(backlog)
      card_ids = {}
      if backlog.has_key?("Cards")
        backlog["Cards"].each do |card|
          card_ids[card["Id"]] = DateTime.parse(card["LastActivity"])
        end
      end
      card_ids
    end

    def get_archive_card_ids(archive)
      card_ids = {}
      archive["Lane"]["Cards"].each do |card|
        card_ids[card["Id"]] = DateTime.parse(card["LastActivity"])
      end
      if archive["ChildLanes"]
        archive["ChildLanes"].each do |child_lane|
          child_lane["Lane"]["Cards"].each do |card|
            card_ids[card["Id"]] = DateTime.parse(card["LastActivity"])
          end
        end
      end
      card_ids
    end

    def merge_card_ids(*boards)
      boards.inject(:merge)
    end
  end
end
