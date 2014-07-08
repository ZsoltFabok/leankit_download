module LeankitDownload
  class Runner
    def self.run
      files_and_json = Common::FilesAndJson.new
      content = files_and_json.from_file("boards.json")
      email = content["leankit"]["email"]
      password = content["leankit"]["password"]
      account = content["leankit"]["account"]
      content["boards"].each do |board|
        DownloadBoard.new(files_and_json).download("./leankit_dump", email, password, account, board[0])
      end
    end
  end
end
