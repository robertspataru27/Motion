--Main function:

(1) Allow user set branch and condition in UI of each block

(2) Provide branch condition robotcode for generation


--Structure:
#Menu   : configuration of UI 
#OP/init: Refreshing all UI based on Ptable including UI data and UI content.
#OP/OnFinishEdited: Save user input to Ptable 
#OP/RobotCodeGen: Provide robot code for generation


--Steps and UI algorithm 

Core Idea : 
Every step of branch have their own unique ID in order to restore and update their relating UI.
Data in Ptable would be saved with prefix with their own ID.
Furthermore, "Existing_branch_id","current_branch_id" and "previous_branch_id" are saved in Ptable so programmer can get the number of branch,current branch and the branch selection moment. 


--branch name :
User can set the branch name with text input,defalut value is branch + order



UI detail:
https://docs.google.com/presentation/d/1EE7vQbQEJPCAu2fNFjFAp-Ryt3GIFT20Q7xbbJiHRh4/edit?usp=drive_link