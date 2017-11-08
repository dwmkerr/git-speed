# Advanced Git Techniques

## Git Help
List available subcommands and some concept guides. See 'git help <command>' or 'git help <concept>' to read about a specific subcommand or concept.

```bash
# show helpful guides that come with Git
git help -g

# show helpful commands that come with Git
git help -a
```

### TLDR
Simplified and community-driven man pages

```bash
brew install tldr
tldr git commit
```

### Git-standup
Recall what you did on the last working day, or be nosy and find what someone else in your team did.

```bash
npm install -g git-standup
git-standup
```

---

## Aliases and Functions
Aliases are helpers that let you define your own git calls. For example, you could set `git a` to run `git add --all` or you could configure `git add -all` to be `gaa`.

### (1) .gitconfig
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
git config --global alias.cm commit
```

For an alias with multiple functions use quotes:

```bash
git config --global alias.ac 'add -A . && commit'
```

### (2) .zshrc or .bash_profile
If you want even shorter aliases, you can configure them in your preferred shell configuration file. For example if you are using zsh, open its rc file `vim ~/.zshrc` and add a new alias like so:

```bash
alias gds="git diff --staged"
```

You can also add functions:
```bash
# clone repository and directly cd into it
gclone() {
  git clone "$1" && cd "$(basename "$1")"
}
```

Have a look at this [example .zshrc](https://github.com/tobiasbueschel/git-speed/blob/master/.zshrc) configuration. Alternatively, you can also install [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh/wiki/Plugin:git) to get a pre-configured list of many aliases.

---

## Git Techniques

### Speed Up Daily Tasks

#### What did I just commit?
Let's say that you just blindly committed changes with `git commit -a` and you're not sure what the actual content of the commit you just made was. You can show the latest commit on your current HEAD with:

```bash
git show

# or
git log -p -1
```

#### Switching Between Branches
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

# or create a shortcut
gco -
```

#### Styled Git Status
Show the index (changed files).

```bash
git status

# or simplify the output
git status -sb
```

the latter produces:
![git status -sb](http://i.imgur.com/K0OY3nm.png)

[*Read more about the Git `status` command.*](http://git-scm.com/docs/git-status)

#### Styled Git Log
Running:

```bash
git log --graph --pretty='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all

# or use an alias
glola
```

## Group commits by authors and title
```sh
git shortlog
```

[*Read more about the Git `log` command.*](http://git-scm.com/docs/git-log)

#### Git Query
A Git query allows you to search all your previous commit messages and find the most recent one matching the query.

```bash
$ git show :/query
```

where `query` (case-sensitive) is the term you want to search, this then finds the last one and gives details on the lines that were changed.

```bash
$ git show :/typo
```
![git show :/query](http://i.imgur.com/icaGiNt.png)

#### Git Diff
Show changes between commits, commit and working tree, etc

```bash
# List all the conflicted files
git diff --name-only --diff-filter=U

# Unstaged changes since last commit
git diff

# Show both staged and unstaged changes
git diff HEAD

# Changes staged for commit
git diff --cached
git diff --staged

# or just use an alias
gds
```

#### What changed since two weeks?
```sh
git log --no-merges --raw --since='2 weeks ago'

# or use this alternative
git whatchanged --since='2 weeks ago'
```

#### Prunes references to remote branches that have been deleted in the remote.
```sh
git fetch -p

# or use this alternative
git remote prune origin

# or just an alias
grpo
```

### Patching & Interactive Staging

I want to stage part of a new file, but not the whole file. Normally, if you want to stage part of a file, you run this:

```bash
$ git add --patch filename.x
```

`-p` will work for short. This will open interactive mode. You would be able to use the `s` option to split the commit - however, if the file is new, you will not have this option. To add a new file, do this:

```bash
$ git add -N filename.x
```

Then, you will need to use the `e` option to manually choose which lines to add. Running `git diff --cached` will show you which lines you have staged compared to which are still saved locally.


#### I want to add changes in one file to two different commits
`git add` will add the entire file to a commit. `git add -p` will allow to interactively select which changes you want to add.

#### Stage parts of a changed file, instead of the entire file
```bash
git add -p
```

```
y – stage this hunk
n – do not stage this hunk
a – stage this and all the remaining hunks in the file
d – do not stage this hunk nor any of the remaining hunks in the file
j – leave this hunk undecided, see next undecided hunk
J – leave this hunk undecided, see next hunk
k – leave this hunk undecided, see previous undecided hunk
K – leave this hunk undecided, see previous hunk
s – split the current hunk into smaller hunks
```

#### Interactiv staging
```bash
git add -i
```

--interactive (or -i) is the big brother of --patch. --patch only lets you decide about the individual hunks in files. --interactive enters the interactive mode, and is a bit more powerful. So powerful that it has its own little submenu:

#### Patching Checkouts and Stashes
Checkout undesired changes, keep good changes.

```bash
$ git checkout -p
# Answer y to all of the snippets you want to drop
```

Another strategy involves using `stash`. Stash all the good changes, reset working copy, and reapply good changes.

```sh
$ git stash -p
# Select all of the snippets you want to save
$ git reset --hard
$ git stash pop
```

### Rewriting History

#### (1) Amending Commits

```bash
# Reword the previous commit message
git commit -v --amend

# Amend author
git commit --amend --author='Author Name <email@address.com>'

# Reset author, after author has been changed in the global config.
git commit --amend --reset-author --no-edit
```

#### (2) Rebasing Feature Branches


> ! The golden rule of git rebase is to never use it on public branches.

```bash
# Change previous two commits with an interactive rebase.
git rebase --interactive HEAD~2
```

```bash
# Forced push but still ensure you don't overwrite other's work
git push --force-with-lease <remote-name> <branch-name>
```

### Git Reflog
If you accidentally do `git reset --hard`, you can normally still get your commit back, as git keeps a log of everything for a few days.

```bash
git reflog
```

You'll see a list of your past commits, and a commit for the reset. Choose the SHA of the commit you want to return to, and reset again:

```bash
git reset --hard SHA1234
```

And you should be good to go.
