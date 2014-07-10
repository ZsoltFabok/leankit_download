module LeankitDownload
  class Cli
    def self.run(argv)
      boards_json = argv[0]
      dump_location = argv[1]

      DownloadBoard.create.download(boards_json, dump_location)
    end
  end
end
