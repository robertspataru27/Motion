--Main function:

(1) SetUp the UI page of motion block, UI configuration written in Menu file

(2) Save all user input from UI to Ptable in related project file folder,which would be used for robot generation

(3) Allow user to set up desired motion steps with customized parameter including target type ,motion setting, 
    OUTPUT procedure and WAIT conditions

(4)Check essential object on desk before allowing user to set up motion block 




--Structure:
#Menu   : configuration of UI 
#OP/init: Refreshing all UI based on Ptable including UI data and UI content.
#OP/OnFinishEdited: save user input to Ptable


--Steps and UI algorithm 

Core Idea : 
Every step of motion have their own unique ID in order to restore and update their relating UI.
Data in Ptable would be saved with prefix with their own ID.
Furthermore, "Existing_step_id","current_step_id" and "previous_step_id" are saved in Ptable so programmer can get the number of step.
current step and the step selection moment. 


--Step name :
For current version, step names would be named based on their order.



UI detail:
https://docs.google.com/presentation/d/1PPniEUSuaZDAB55hMdjh1gFo6M0zdrRoZwBYFDEo61Y/edit?usp=share_link