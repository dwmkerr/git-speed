# git-speed

### Show helpful guides that come with Git

```bash
git help -g
```

### Remove All Deleted Files from the Working Tree
When you delete a lot of files using `/bin/rm` you can use the following command to remove them from the working tree and from the index, eliminating the need to remove each one individually:

```bash
$ git rm $(git ls-files -d)
```

For example:

```bash
$ git status
On branch master
Changes not staged for commit:
	deleted:    a
	deleted:    c

$ git rm $(git ls-files -d)
rm 'a'
rm 'c'

$ git status
On branch master
Changes to be committed:
	deleted:    a
	deleted:    c
```

### Previous Branch
To move to the previous branch in Git:

```bash
$ git checkout -
# Switched to branch 'master'

$ git checkout -
# Switched to branch 'next'

$ git checkout -
# Switched to branch 'master'
```

__Alternatives:__
```bash
git checkout @{-1}
```

### Checking out Pull Requests
Or should you work on more repositories, you can globally configure fetching pull requests in the global git config instead.

```bash
git config --global --add remote.origin.fetch "+refs/pull/*/head:refs/remotes/origin/pr/*"
```

This way, you can use the following short commands in all your repositories:

```bash
git fetch origin
```

```bash
git checkout pr/42
```

[*Read more about checking out pull requests locally.*](https://help.github.com/articles/checking-out-pull-requests-locally/)

### Styled Git Status
Running:

```bash
$ git status
```

produces:

![git status](http://i.imgur.com/qjPyvXb.png)

By adding `-sb`:

```bash
$ git status -sb
```

this is produced:

![git status -sb](http://i.imgur.com/K0OY3nm.png)

[*Read more about the Git `status` command.*](http://git-scm.com/docs/git-status)

### Styled Git Log
Running:

```bash
$ git log --all --graph --pretty=format:'%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative
```

produces:

![git log --all --graph --pretty=format:'%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative](http://i.imgur.com/58eOtkW.png)

Credit to [Palesz](http://stackoverflow.com/users/88355/palesz)

*This can be aliased using the instructions found [here](https://github.com/tiimgreen/github-cheat-sheet#aliases).*

[*Read more about the Git `log` command.*](http://git-scm.com/docs/git-log)

### Git Query
A Git query allows you to search all your previous commit messages and find the most recent one matching the query.

```bash
$ git show :/query
```

where `query` (case-sensitive) is the term you want to search, this then finds the last one and gives details on the lines that were changed.

```bash
$ git show :/typo
```
![git show :/query](http://i.imgur.com/icaGiNt.png)

*Press `q` to quit.*

### Search change by content

```bash
git log -S'<a term in the source>'
```

### List all the conflicted files

```bash
git diff --name-only --diff-filter=U
```

### Unstaged changes since last commit
```bash
git diff
```

### Changes staged for commit
```bash
git diff --cached
```

__Alternatives:__
```bash
git diff --staged
```

## Show both staged and unstaged changes
```sh
git diff HEAD
```

### Git Grep

Git Grep will return a list of lines matching a pattern.

Running:
```bash
$ git grep aliases
```
will show all the files containing the string *aliases*.

![git grep aliases](http://i.imgur.com/DL2zpQ9.png)

*Press `q` to quit.*

You can also use multiple flags for more advanced search. For example:

 * `-e` The next parameter is the pattern (e.g., regex)
 * `--and`, `--or` and `--not` Combine multiple patterns.

Use it like this:
```bash
 $ git grep -e pattern --and -e anotherpattern
```

[*Read more about the Git `grep` command.*](http://git-scm.com/docs/git-grep)

### Merged Branches
Running:

```bash
$ git branch --merged
```

will give you a list of all branches that have been merged into your current branch.

Conversely:

```bash
$ git branch --no-merged
```

will give you a list of branches that have not been merged into your current branch.

[*Read more about the Git `branch` command.*](http://git-scm.com/docs/git-branch)


### Web Server for Browsing Local Repositories
Use the Git `instaweb` command to instantly browse your working repository in `gitweb`. This command is a simple script to set up `gitweb` and a web server for browsing the local repository.

```bash
$ git instaweb
```

opens:

![Git instaweb](http://i.imgur.com/Dxekmqc.png)

[*Read more about the Git `instaweb` command.*](http://git-scm.com/docs/git-instaweb)

#### Aliases
Aliases are helpers that let you define your own git calls. For example you could set `git a` to run `git add --all`.

To add an alias, either navigate to `~/.gitconfig` and fill it out in the following format:

```
[alias]
  co = checkout
  cm = commit
  p = push
  # Show verbose output about tags, branches or remotes
  tags = tag -l
  branches = branch -a
  remotes = remote -v
```

...or type in the command-line:

```bash
$ git config --global alias.new_alias git_function
```

For example:

```bash
$ git config --global alias.cm commit
```

For an alias with multiple functions use quotes:

```bash
$ git config --global alias.ac 'add -A . && commit'
```

Some useful aliases include:

| Alias | Command | What to Type |
| --- | --- | --- |
| `git cm` | `git commit` | `git config --global alias.cm commit` |
| `git co` | `git checkout` | `git config --global alias.co checkout` |
| `git ac` | `git add . -A` `git commit` | `git config --global alias.ac '!git add -A && git commit'` |
| `git st` | `git status -sb` | `git config --global alias.st 'status -sb'` |
| `git tags` | `git tag -l` | `git config --global alias.tags 'tag -l'` |
| `git branches` | `git branch -a` | `git config --global alias.branches 'branch -a'` |
| `git cleanup` | `git branch --merged | grep -v '*' | xargs git branch -d` | `git config --global alias.cleanup "!git branch --merged | grep -v '*' | xargs git branch -d"` |
| `git remotes` | `git remote -v` | `git config --global alias.remotes 'remote -v'` |
| `git lg` | `git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --` | `git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"` |

*Some Aliases are taken from [@mathiasbynens](https://github.com/mathiasbynens) dotfiles: https://github.com/mathiasbynens/dotfiles/blob/master/.gitconfig*
