# GitHub Actions Guide for Dotfiles

## 🤔 What is GitHub Actions?

**Think of it as a robot assistant that lives on GitHub's servers.**

When you push code, this robot:
1. Wakes up
2. Gets a fresh computer (Linux or Mac)
3. Downloads your code
4. Runs tests you specify
5. Reports back: ✅ Pass or ❌ Fail

**It's FREE for public repos!** (2,000 minutes/month for private repos)

---

## 📁 How It Works: File Structure

```
dotfiles/
└── .github/                    # Special folder GitHub looks for
    └── workflows/              # Where "automation recipes" live
        └── validate.yml        # Your workflow file (the "recipe")
```

**The `.github/workflows/` folder is MAGIC:**
- GitHub automatically detects any `.yml` files here
- Each file = 1 automated workflow
- You can have multiple workflows (testing, deployment, notifications, etc.)

---

## 🧪 What Our Workflow Does

Every time you push to GitHub, it:

### On Linux VM:
1. ✅ **Check ZSH syntax** - Makes sure no typos in your shell config
2. ✅ **Scan for secrets** - Ensures you didn't accidentally commit API keys
3. ✅ **Verify files exist** - Confirms all important files are present
4. ✅ **Test .gitignore** - Checks that secrets are protected
5. ✅ **Test OS detection** - Ensures Linux is detected correctly
6. ✅ **Validate install script** - Checks bash syntax

### On macOS VM:
1. ✅ **Check ZSH syntax** - Verify Mac compatibility
2. ✅ **Test OS detection** - Ensures Mac is detected correctly
3. ✅ **Verify Brewfile** - Confirms package list exists

---

## 📜 The Workflow File Explained

Let's break down `validate.yml`:

### Part 1: WHEN to run
```yaml
on:
  push:
    branches: [ main ]     # Run when you push to main branch
  pull_request:
    branches: [ main ]     # Run when someone opens a PR
  workflow_dispatch:       # Allow manual runs from GitHub UI
```

**Translation:** "Run this robot whenever code lands on main, or when testing a PR"

### Part 2: WHERE to run
```yaml
jobs:
  test-linux:
    runs-on: ubuntu-latest    # Get a fresh Ubuntu VM
```

**Translation:** "Give me a brand new Ubuntu computer"

### Part 3: WHAT to run
```yaml
steps:
  - name: Checkout dotfiles
    uses: actions/checkout@v4    # Download your repo
  
  - name: Validate ZSH syntax
    run: |                       # Run shell commands
      echo "🔍 Checking ZSH files..."
      zsh -n zsh/.zshrc
      echo "✅ ZSH syntax is valid!"
```

**Translation:** 
1. "Download my code"
2. "Run these shell commands and show me the output"

---

## 🎬 See It In Action

### After you push this workflow:

1. **Go to GitHub.com** → your dotfiles repo
2. **Click "Actions" tab** at the top
3. **See your workflows running** (yellow dots = running, green = passed, red = failed)
4. **Click any workflow** to see detailed logs

### Visual Guide:

```
┌─────────────────────────────────────────┐
│  ⚡ Actions   Code   Issues   Pull...  │  ← Click "Actions"
├─────────────────────────────────────────┤
│                                         │
│  All workflows                          │
│                                         │
│  🟢 Validate Dotfiles                   │  ← See results
│     Update dotfiles from mmm4           │
│     #3: 3 minutes ago                   │
│                                         │
│  🟢 Validate Dotfiles                   │
│     Add GitHub Actions workflow         │
│     #2: 5 minutes ago                   │
│                                         │
└─────────────────────────────────────────┘
```

---

## 🔍 Reading the Results

Click any workflow run to see:

```
┌──────────────────────────────────────┐
│ Jobs                                 │
├──────────────────────────────────────┤
│ ✅ test-linux                        │  ← Click to expand
│    ├─ ✅ Checkout dotfiles           │
│    ├─ ✅ Validate ZSH syntax         │
│    ├─ ✅ Check for leaked secrets    │
│    ├─ ✅ Verify required files       │
│    ├─ ✅ Verify gitignore            │
│    ├─ ✅ Test OS detection           │
│    └─ ✅ Test install script         │
│                                      │
│ ✅ test-macos                        │
│    ├─ ✅ Checkout dotfiles           │
│    ├─ ✅ Validate ZSH syntax         │
│    ├─ ✅ Test OS detection           │
│    └─ ✅ Verify Brewfile             │
└──────────────────────────────────────┘
```

If something fails (❌), click it to see exactly which line of code caused the problem!

---

## 💡 Common Use Cases

### 1. Catch Mistakes Before They Break Things
```yaml
- name: Check ZSH syntax
  run: zsh -n zsh/.zshrc
```
If you have a typo, this fails BEFORE you pull it to another machine.

### 2. Prevent Accidentally Committing Secrets
```yaml
- name: Check for leaked secrets
  run: |
    if grep -r "sk-\|ghp_" .; then
      echo "Found API keys!"
      exit 1
    fi
```
If you accidentally commit an API key, the workflow fails and alerts you.

### 3. Test on Multiple OSes
```yaml
jobs:
  test-linux:
    runs-on: ubuntu-latest
  test-macos:
    runs-on: macos-latest
```
Ensures your dotfiles work on both Linux and Mac.

---

## 🚀 Advanced Ideas (Optional)

### Auto-update Brewfile on Push
```yaml
- name: Update Brewfile
  run: |
    brew bundle dump --force
    git add Brewfile
    git commit -m "Auto-update Brewfile"
    git push
```

### Notify You on Slack/Discord
```yaml
- name: Notify on failure
  if: failure()
  uses: slackapi/slack-github-action@v1
  with:
    webhook: ${{ secrets.SLACK_WEBHOOK }}
```

### Run Security Scans
```yaml
- name: Scan for vulnerabilities
  uses: trufflesecurity/trufflehog@main
```

---

## 🎯 Your Workflow Flow

Here's what happens when you make a change:

```
1. You edit .zshrc locally
   ↓
2. You run: dotfiles-update
   ↓
3. Git commits and pushes to GitHub
   ↓
4. GitHub sees the push
   ↓
5. GitHub Actions starts validate.yml
   ↓
6. Two VMs spin up (Ubuntu + macOS)
   ↓
7. Each runs your tests
   ↓
8. Results appear on GitHub
   ↓
9. You get email if something fails
```

---

## 📊 Understanding the YAML Syntax

YAML is like a recipe card. Indentation matters!

```yaml
name: Validate Dotfiles          # Workflow name (shows in GitHub UI)

on:                              # Trigger section
  push:                          # When you push...
    branches: [ main ]           # ...to main branch

jobs:                            # Things to do
  test-linux:                    # Job name
    runs-on: ubuntu-latest       # What computer to use
    
    steps:                       # List of tasks
      - name: Do something       # Task name (shows in logs)
        run: echo "Hello"        # Shell command(s) to run
```

**Key rules:**
- Indentation = 2 spaces (not tabs!)
- `-` = list item
- `|` = multi-line string

---

## 🛠️ Customizing Your Workflow

### Add a new check:
```yaml
- name: Check for TODO comments
  run: |
    if grep -r "TODO\|FIXME" zsh/; then
      echo "⚠️  Found TODO items - consider addressing them"
    fi
```

### Run only on specific files:
```yaml
on:
  push:
    paths:
      - 'zsh/**'              # Only run if zsh/ changes
      - 'git/.gitconfig'      # Or gitconfig changes
```

### Add environment variables:
```yaml
env:
  DOTFILES_ENV: testing
  DEBUG: true
```

---

## 🎓 Learning Resources

- **GitHub Actions Docs:** https://docs.github.com/actions
- **Workflow Syntax:** https://docs.github.com/actions/reference/workflow-syntax-for-github-actions
- **Marketplace:** https://github.com/marketplace?type=actions (pre-built actions)
- **Awesome Actions:** https://github.com/sdras/awesome-actions (community examples)

---

## 🐛 Troubleshooting

### "Workflow not running"
- Check `.github/workflows/` folder exists
- Verify file is named `.yml` (not `.yaml`)
- Ensure proper YAML indentation

### "zsh: command not found"
- Ubuntu/macOS VMs come with zsh installed
- If using custom tools, install them first:
  ```yaml
  - name: Install dependencies
    run: sudo apt install -y zsh starship
  ```

### "Permission denied"
- Make scripts executable:
  ```yaml
  - name: Make executable
    run: chmod +x install.sh
  ```

---

## 🎉 Benefits for You

1. **Peace of Mind** - Know your dotfiles work before syncing to other machines
2. **Catch Mistakes Early** - Syntax errors found immediately
3. **Security** - Automated checks for leaked secrets
4. **Documentation** - Workflow serves as documentation of "what works"
5. **Multi-machine Testing** - Test on Linux + Mac automatically
6. **Free** - All of this costs nothing for public repos

---

## 🚦 Next Steps

1. Push this workflow to GitHub
2. Go to the "Actions" tab and watch it run
3. Make a small change and push again - see it run automatically
4. Try breaking something (add invalid ZSH syntax) and see it catch the error!

**That's it!** You now have automated validation for your dotfiles. 🎊
