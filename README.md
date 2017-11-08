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

### What did I just commit?

Let's say that you just blindly committed changes with `git commit -a` and you're not sure what the actual content of the commit you just made was. You can show the latest commit on your current HEAD with:

```bash
git show
```

or

```bash
$ git log -p -1
```

### I want to delete or remove my last commit

If you need to delete pushed commits, you can use the following. However, it will irreversibly change your history, and mess up the history of anyone else who had already pulled from the repository. In short, if you're not sure, you should never do this, ever.

```sh
$ git reset HEAD^ --hard
$ git push --force-with-lease [remote] [branch]
```

If you haven't pushed, to reset Git to the state it was in before you made your last commit (while keeping your staged changes):

```
(my-branch*)$ git reset --soft HEAD@{1}

```

This only works if you haven't pushed. If you have pushed, the only truly safe thing to do is `git revert SHAofBadCommit`. That will create a new commit that undoes all the previous commit's changes. Or, if the branched you pushed to is rebase-safe (ie. other devs aren't expected to pull from it), you can just use `git push --force-with-lease`. For more, see [the above section](#deleteremove-last-pushed-commit).

<a name="delete-any-commit"></a>
### Delete/remove arbitrary commit

The same warning applies as above. Never do this if possible.

```sh
$ git rebase --onto SHA1_OF_BAD_COMMIT^ SHA1_OF_BAD_COMMIT
$ git push --force-with-lease [remote] [branch]
```

Or do an [interactive rebase](#interactive-rebase) and remove the line(s) corresponding to commit(s) you want to see removed.

<a name="#force-push"></a>
### I tried to push my amended commit to a remote, but I got an error message

```sh
To https://github.com/yourusername/repo.git
! [rejected]        mybranch -> mybranch (non-fast-forward)
error: failed to push some refs to 'https://github.com/tanay1337/webmaker.org.git'
hint: Updates were rejected because the tip of your current branch is behind
hint: its remote counterpart. Integrate the remote changes (e.g.
hint: 'git pull ...') before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
```

Note that, as with rebasing (see below), amending **replaces the old commit with a new one**, so you must force push (`--force-with-lease`) your changes if you have already pushed the pre-amended commit to your remote. Be careful when you do this &ndash; *always* make sure you specify a branch!

```sh
(my-branch)$ git push origin mybranch --force-with-lease
```

In general, **avoid force pushing**. It is best to create and push a new commit rather than force-pushing the amended commit as it has will cause conflicts in the source history for any other developer who has interacted with the branch in question or any child branches. `--force-with-lease` will still fail, if someone else was also working on the same branch as you, and your push would overwrite those changes.

If you are *absolutely* sure that nobody is working on the same branch or you want to update the tip of the branch *unconditionally*, you can use `--force` (`-f`), but this should be avoided in general.

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

create an alias for it
```bash
$ git config --global alias.shorty 'status --short --branch'
```


[*Read more about the Git `status` command.*](http://git-scm.com/docs/git-status)


### Git reflog
If you accidentally do `git reset --hard`, you can normally still get your commit back, as git keeps a log of everything for a few days.

```sh
(master)$ git reflog
```

You'll see a list of your past commits, and a commit for the reset. Choose the SHA of the commit you want to return to, and reset again:

```sh
(master)$ git reset --hard SHA1234
```

And you should be good to go.


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

### Amending

## Reword the previous commit message
```sh
git commit -v --amend
```

## Amend author.
```sh
git commit --amend --author='Author Name <email@address.com>'
```

## Reset author, after author has been changed in the global config.
```sh
git commit --amend --reset-author --no-edit
```

## Staging

<a href="#i-need-to-add-staged-changes-to-the-previous-commit"></a>
### I need to add staged changes to the previous commit

```sh
(my-branch*)$ git commit --amend

```

<a name="commit-partial-new-file"></a>
### I want to stage part of a new file, but not the whole file

Normally, if you want to stage part of a file, you run this:

```sh
$ git add --patch filename.x
```

`-p` will work for short. This will open interactive mode. You would be able to use the `s` option to split the commit - however, if the file is new, you will not have this option. To add a new file, do this:

```sh
$ git add -N filename.x
```

Then, you will need to use the `e` option to manually choose which lines to add. Running `git diff --cached` will show you which lines you have staged compared to which are still saved locally.


<a href="stage-in-two-commits"></a>
### I want to add changes in one file to two different commits

`git add` will add the entire file to a commit. `git add -p` will allow to interactively select which changes you want to add.

## Stage parts of a changed file, instead of the entire file
```sh
git add -p
```

## Interactiv staging
```sh
git add -i
```

--interactive (or -i) is the big brother of --patch. --patch only lets you decide about the individual hunks in files. --interactive enters the interactive mode, and is a bit more powerful. So powerful that it has its own little submenu:

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

Checkout undesired changes, keep good changes.

```sh
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

## What changed since two weeks?
```sh
git log --no-merges --raw --since='2 weeks ago'
```


__Alternatives:__
```sh
git whatchanged --since='2 weeks ago'
```

## Prunes references to remote branches that have been deleted in the remote.
```sh
git fetch -p
```


__Alternatives:__
```sh
git remote prune origin
```


## Change previous two commits with an interactive rebase.
```sh
git rebase --interactive HEAD~2
```

> ! The golden rule of git rebase is to never use it on public branches.

## Forced push but still ensure you don't overwrite other's work
```sh
git push --force-with-lease <remote-name> <branch-name>
```

## Group commits by authors and title
```sh
git shortlog
```

### I accidentally deleted my branch

If you're regularly pushing to remote, you should be safe most of the time. But still sometimes you may end up deleting your branches. Let's say we create a branch and create a new file:

```sh
(master)$ git checkout -b my-branch
(my-branch)$ git branch
(my-branch)$ touch foo.txt
(my-branch)$ ls
README.md foo.txt
```

Let's add it and commit.

```sh
(my-branch)$ git add .
(my-branch)$ git commit -m 'foo.txt added'
(my-branch)$ foo.txt added
 1 files changed, 1 insertions(+)
 create mode 100644 foo.txt
(my-branch)$ git log

commit 4e3cd85a670ced7cc17a2b5d8d3d809ac88d5012
Author: siemiatj <siemiatj@example.com>
Date:   Wed Jul 30 00:34:10 2014 +0200

    foo.txt added

commit 69204cdf0acbab201619d95ad8295928e7f411d5
Author: Kate Hudson <katehudson@example.com>
Date:   Tue Jul 29 13:14:46 2014 -0400

    Fixes #6: Force pushing after amending commits
```

Now we're switching back to master and 'accidentally' removing our branch.

```sh
(my-branch)$ git checkout master
Switched to branch 'master'
Your branch is up-to-date with 'origin/master'.
(master)$ git branch -D my-branch
Deleted branch my-branch (was 4e3cd85).
(master)$ echo oh noes, deleted my branch!
oh noes, deleted my branch!
```

At this point you should get familiar with 'reflog', an upgraded logger. It stores the history of all the action in the repo.

```
(master)$ git reflog
69204cd HEAD@{0}: checkout: moving from my-branch to master
4e3cd85 HEAD@{1}: commit: foo.txt added
69204cd HEAD@{2}: checkout: moving from master to my-branch
```

As you can see we have commit hash from our deleted branch. Let's see if we can restore our deleted branch.

```sh
(master)$ git checkout -b my-branch-help
Switched to a new branch 'my-branch-help'
(my-branch-help)$ git reset --hard 4e3cd85
HEAD is now at 4e3cd85 foo.txt added
(my-branch-help)$ ls
README.md foo.txt
```

Voila! We got our removed file back. Git reflog is also useful when rebasing goes terribly wrong.
