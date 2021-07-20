# signal-export
Export chats from the [Signal](https://www.signal.org/) [Desktop app](https://www.signal.org/download/) to Markdown and HTML files with attachments. Each chat is exported as an individual .md/.html file and the attachments for each are stored in a separate folder. Attachments are linked from the Markdown files and displayed in the HTML (pictures, videos, voice notes).

Currently this seems to be the only way to get chat history out of Signal!

Adapted from https://github.com/mattsta/signal-backup, which I suspect will be hard to get working now.

## Example
An export for a group conversation looks as follows:
```markdown
[2019-05-29, 15:04] Me: How is everyone?
[2019-05-29, 15:10] Aya: We're great!
[2019-05-29, 15:20] Jim: I'm not.
```

Images are attached inline with `![name](path)` while other attachments (voice notes, videos, documents) are included as links like `[name](path)` so a click will take you to the file.

This is converted to HTML at the end so it can be opened with any web browser. The stylesheet `.css` is still very basic but I'll get to it sooner or later.

## Installation
First clone and install requirements (preferably into a virtualenv):
```
git clone https://github.com/carderne/signal-export.git
cd signal-export
pip install -r requirements.txt
```

### For Linux
Then to get sqlcipher working:
```
sudo apt install libsqlcipher-dev libssl-dev
```

Then clone [sqlcipher](https://github.com/sqlcipher/sqlcipher) and install it:
```
git clone https://github.com/sqlcipher/sqlcipher.git
cd sqlcipher
mkdir build && cd build
../configure --enable-tempstore=yes CFLAGS="-DSQLITE_HAS_CODEC" LDFLAGS="-lcrypto"
sudo make install
```

### For MacOS
- Install [Homebrew](https://brew.sh).
- Run `brew install openssl sqlcipher`

### For Windows
YMMV, but apparently Ubuntu 20.04 on WSL2 should work! That is, install WSL2 and Ubuntu 20.04 on Windows, and then follow the **For Linux** instructions and feel your way forward.

## Usage
The following should work:
```
./sigexport.py outputdir
```

To create HTML with no pagination:
```
./sigexport.py outputdir -p0
```

If you get an error:

    pysqlcipher3.dbapi2.DatabaseError: file is not a database

try adding the `--manual` option.

The full options are below:
```
Usage: ./sigexport.py [OPTIONS] [DEST]

Options:
  -s, --source PATH       Path to Signal source and database
  -c, --chats TEXT        Comma-separated chat names to include. These are
                          contact names or group names

  -p, --paginate INTEGER  Number of messages per page in the HTML output. Set
                          to 0 for no pagination. Defaults to 100.

  --list-chats            List all available chats/conversations and then quit
  --old PATH              Path to previous export to merge with
  -o, --overwrite         Flag to overwrite existing output
  -v, --verbose           Enable verbose output logging
  -m, --manual            Whether to manually decrypt the db
  --help                  Show this message and exit.
```

You can add `--source /path/to/source/dir/` if the script doesn't manage to find the Signal config location. Default locations per OS are below. The directory should contain a folder called `sql` with a `db.sqlite` inside it.
- Linux: `~/.config/Signal/`
- macOS: `~/Library/Application Support/Signal/`
- Windows: `~/AppData/Roaming/Signal/`

You can also use `--old /previously/exported/dir/` to merge the new export with a previous one. _Nothing will be overwritten!_ It will put the combined results in whatever output directory you specified and leave your previos export untouched. Exercise is left to the reader to verify that all went well before deleting the previous one.
