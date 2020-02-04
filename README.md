# Plugin for easy management of CF profiles used by the CF CLI tools.


By default the CF CLI profile is stored in `~/.cf/` and only one target is allowed. Using this zsh plugin, profiles will go into  `~/.cf/profiles`. Selecting a profile is done by changing the `CF_HOME` environment variable for your current shell session.

## Actions available

* cf-profile-list: list all configured profiles
* cf-profile \<name>: switch profile
* cf-profile-create \<name>: create a new profile. After this to `cf login \<url>'
* cf-profile-prompt: echo the name of the profile
* cf-profile-target-prompt: echo the api endpoint for the profile


To add the current region as indicator to your prompt change the `PROMPT` variable in `~/.zshrc` add this:

```
$(cf-profile-target-prompt)
```

## Dependencies:

* `jq`, install via brew


## Installation

```
cd ~/.oh-my-zsh/custom/plugins
git clone https://github.com/cwesdorp/cfprofile.git
```


## Alternatives

* [cf targets](https://github.com/guidowb/cf-targets-plugin)



