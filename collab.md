# Info for contributors

First of all, thanks for being here :) If you want to help to improve the tool in its development of v3 you are more than welcome. Below I will try to detail the main features, ideas and improvements that I want to implement in the new version, they are not few and it won't be fast, but I think it will be worth it.

>**If you think there is something that doesn't make sense or could be done in a better way, feel free to write me on Telegram, on our (new!) Discord server, Twitter or wherever you want**.

# Ideas/brainstorming

## Desirable
- The main script (reconftw.sh) is only like an orchestrator.
	- The main script (reconftw.sh) is in charge of validating the logic and managing the different modes and workflows. 
- All functions must be migrated to separate scripts.
	- It must be possible to launch the new independent scripts outside reconftw.
	- The scripts must validate the input arguments.
	- Add to each individual script a help menu (-h or --help) explaining the input, output and what it does.
	- They must be compatible with reconftw , of course.
- It would be great to work function by function and add a small documentation of each function, just with the expected input arguments and its output.
- Any improvement for the scripts (via ChatGPT or by yourselves xD) is welcome, just make sure that the output has at least the same quality and quantity of results.
- Most important are all recon functions, the "attack" functions are pretty basic imo.
- I'm always open to explain any function, so if you have doubts why something works a certain way, feel free to ask.
- I'll make sure the main contributors have their proper swag for lending a hand :D

## Ideas
- Include the individual scripts in the user's PATH (like axiom) so they can be called from anywhere.
- Change the nomenclature of the individual scripts to something that identifies the project when called externally (Idea: sub_passive.sh -> rftw_sub_passive).
- Create $HOME/.reconftw folder as Axiom to set a default path always and not depend on where the repo has been cloned, so it's time to modify the installer too.

# Examples
This is how looks the file tree on reconftw new:

![image](https://user-images.githubusercontent.com/24670991/205467327-10d1df44-489c-45ca-984b-ffe22eac1dc5.png)

This is the diffence between an old function and a new independant script. Maybe this is a bad example because the code is almost the same in this case, but I'm sure you get the point xD:

![image](https://user-images.githubusercontent.com/24670991/205467606-fe59d0a1-eaf7-4ea5-96f4-95190618e8f2.png)
![image](https://user-images.githubusercontent.com/24670991/205467537-6626c9f2-e099-4f06-9bcb-839bcefe1065.png)
![image](https://user-images.githubusercontent.com/24670991/205467480-a0c667fa-d89c-4dcf-a501-cd10ed0aff7c.png)

By now (04/12/22), the scripts modified have been [modules/osint/google_dorks.sh](https://github.com/six2dez/reconftw/blob/modular/modules/osint/google_dorks.sh), [modules/osint/github_dorks.sh](https://github.com/six2dez/reconftw/blob/modular/modules/osint/github_dorks.sh) and [modules/subdomains/sub_passive.sh](https://github.com/six2dez/reconftw/blob/modular/modules/subdomains/sub_passive.sh) and can be used as examples.

# EOF
From here you can join the Discord channel here: https://discord.gg/R5DdXVEdTy 
DM me asking for developer role and we'll continue discussing about all this :) Thanks again!
