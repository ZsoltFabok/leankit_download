module LeankitDownload
  class Cli
    def self.run(argv)
      dry_run = false
      if argv[0] == "--dry-run"
        argv.shift
        dry_run = true
      end
      boards_json = argv[0]
      dump_location = argv[1]

      DownloadBoard.create.download(boards_json, dump_location, dry_run)
    end
  end
end
