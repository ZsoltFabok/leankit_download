### Leankit Download
[![Build Status](https://travis-ci.org/ZsoltFabok/leankit_download.png)](https://travis-ci.org/ZsoltFabok/leankit_download)
[![Dependency Status](https://gemnasium.com/ZsoltFabok/leankit_download.png)](https://gemnasium.com/ZsoltFabok/leankit_download)
[![Code Climate](https://codeclimate.com/github/ZsoltFabok/leankit_download.png)](https://codeclimate.com/github/ZsoltFabok/leankit_download)
[![Coverage Status](https://coveralls.io/repos/ZsoltFabok/leankit_download/badge.png?branch=master)](https://coveralls.io/r/ZsoltFabok/leankit_download?branch=master)

Downloads card history data from Leankit.

#### Install
    gem install leankit_download

#### Usage

First you will need a `boards.json` file that contains the authentication credentials and list of boards which cards you want to download:

    {
      "leankit" : {
        "email": "<email>",
        "password": "<password>",
        "account": "<account>"
      },
      "boards": {
        "<case sensitive board name>" : { 
        }
      }
    }

For command line:

     leankit_download [--dry-run] <boards.json location> <destination>

Using `--dry-run` will tell the application not to connect to *leankit*.

For ruby code:

    requre 'leankit_download'

    download_board = LeankitDownload::DownloadBoard.create
    download_locations = download_board.download(
        "./boards.json", "./leankit_dump")

The `download_board.download` returns the paths to the individual boards with card histories.

### Copyright

Copyright (c) 2014 Zsolt Fabok and Contributors. See [LICENSE](LICENSE.md) for details.
