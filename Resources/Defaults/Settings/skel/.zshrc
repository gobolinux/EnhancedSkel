
alias pico="nano -p"
alias rm="rm -i"
alias cp="cp -i"
alias d="ls --color"

export PATH=$PATH:.

if [ "$SSH_CONNECTION" ]
then prompt lode yellow
else prompt lode cyan
fi

# function to start one instance of gpg-agent for current user
#if [ -z "$(echo $(ps -C gpg-agent -o user=) | grep $(whoami))" ]
#then
#   gpg-agent --daemon --enable-ssh-support --sh --write-env-file ~/.gnupg/gpg-agent.env 1> /dev/null
#fi
#export $(cat ~/.gnupg/gpg-agent.env)
