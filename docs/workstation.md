# Steps from a new workstation configuration

## Get started

1. Create a new key ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/id_ed25519 -C "<john@example.com>"
2. Upload key to github cat ~/.ssh/id_ed25519.
3. Update workstation sudo apt update && sudo apt upgrade
4. `curl https://github.com/irish1986.keys >> ~/.ssh/authorized_keys`
5. Setup `git config --global user.email "<you@example.com>"` and `git config --global user.name "Your Name"`

## Pull my ssh public key from Github

```bash
curl https://github.com/irish1986.keys >> ~/.ssh/authorized_keys
```

Update and clean up

```bash
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y
```

Install a few packages

```bash
sudo apt update && sudo apt install apt-transport-https curl git gpg gnupg openssh-server htop p7zip-full software-properties-common tmux tree virtualbox vlc wget
```

## Software

Install ansible

```bash
sudo apt update && sudo apt install pipx -y
pipx install --include-deps ansible
pipx install --include-deps netaddr
```

Install ghcli

```bash
wget -O- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
sudo apt update && sudo apt install gh -y
```

Install go-task

```bash
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin
mv ~/.local/bin/task /usr/local/share/zsh/site-functions/_task
```

Install google chrome

```bash
wget https://dl.google.com/linux/direct/google-chrome-stable_current_$(dpkg --print-architecture).deb
sudo apt install ./google-chrome-stable_current_$(dpkg --print-architecture).deb
```

Install flux

```bash
curl -s https://fluxcd.io/install.sh | sudo bash
flux check --pre

```

Install kubectl

```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /usr/share/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/usr/share/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update && sudo apt install kubectl -y
```

Install helm

```bash
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update && sudo apt-get install helm -y
```

Install steam

```bash
sudo add-apt-repository multiverse
sudo apt update && sudo apt install steam -y
```

Install terraform

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform -y
```

Install vscode

```bash
wget -O- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/packages.microsoft.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
rm -f packages.microsoft.gpg
sudo apt update && sudo apt install code -y
```

## ZSH

Install zsh package and oh-my-zsh

```bash
sudo apt update && sudo apt install zsh -y
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

Install powerlevel10k theme

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

Install a zsh plugins

```bash
git clone https://github.com/MichaelAquilina/zsh-you-should-use ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use
git clone https://github.com/ptavares/zsh-exa ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-exa
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# plugins=(docker exa-zsh git kubectl sudo you-should-use web-search zsh-autosuggestions zsh-exa zsh-syntax-highlighting)
```

## Dev Tool

## Hardware & Drivers

Install a few packages

```bash
```
