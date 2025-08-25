
-- Core Idea
-- every step have their own unique Id so programmer can get required datas based on ID index;

-- About robot code generation:
-- (1) iterate all steps with "numberOfTotalSteps"                 
-- (2) get all required datas of the step in Ptable with their ID
-- (3) Declare TPUI variable(CP_T or AP_T) 
-- (4) Iterate to next step until all done                         ^^^^^^^^

-- (5) Iterate all steps with "numberOfTotalSteps" again
-- (6) set motion command(PTP,FREE or LIN) including their parameters
-- 	(7) Iterate all procedure with "numberOfProcedure"
-- 	(8) Get robotCode0,robotcode1,robotcode2(Flag) of ConditionalAssignment UIelement value

-- 	(9) Iterate all procedure with "numberOfConditions"
-- 	(10) Get robotCode0,robotcode1, of Conditional UIelement value

--About condition & procedure:
--In the program, robotcode1,robotcode2 can be call via Ptable and it's complete robot code so programmer don't add extra robot code on it
--However,Flag (for example:SkipWaitSS )should be considered to determine if add specific code session 

---------------------------------------------------------------------------------------------


local Instance = CS.ConfigurationMenu.ConfigurationMenuLuaInterface.Instance
local PTable = CS.Mantis.RobotCodeGeneration.BlockLuaInterface.thisFlowBlock.pTable
local UiElement = Instance.uiElementOnEdit
local bot = CS.Mantis.RobotCodeGeneration.BlockLuaInterface.thisWorkforces[0]
local workpiece=CS.Mantis.RobotCodeGeneration.BlockLuaInterface.thisWorkpieces[0]
local selectedToolNumber
local selectedTcpNumber
local pre_TransformUIName="Transform_StepTransform_values_ID"
local pre_ARCTransformUIName="Transform_ARCTransform_values_ID"
local pre_JointUIName="Joint_StepRobotJoint_values_ID"
local pre_TrajectoryMotionTypeUIName="Dropdown_TrajectoryMotionType_values_ID"
local pre_SpeedMmUIName="Int_Input_SpeedMm_values_ID"
local pre_SpeedPercUIName="Int_Input_SpeedPerc_values_ID"
local pre_BlendsEnableUIName="CheckBox_BlendsEnable_values_ID"
local pre_BlendsRadiusUIName="Float_Input_BlendsRadius_values_ID"
local pre_DelayTimeUIName="Int_Input_DelaytimeBetweenPandC_values_ID"
local pre_ConditionSelectionUIName="List_ConditionSelection_values_ID"
local pre_RobotCode0Name="List_ConditionSelection_robotCode0_ID"
local pre_RobotCode1Name="List_ConditionSelection_robotCode1_ID"
local pre_procedureRobotCode0Name="List_ProcedureSelection_robotCode0_ID"   
local pre_procedureRobotCode1Name="List_ProcedureSelection_robotCode1_ID"
local procedureSkipWaitSSName="SkipWaitSS_ID"
local pre_NumberOfConditionsName="numberOfCondition_ID" 
local pre_TargetTypeUIName="Dropdown_TargetType_values_ID" 
local pre_projectToolSelectedName="projectToolSelected_ID"
local pre_projectTcpSelectedName="projectTcpSelected_ID" 
local pre_numberOfProcedureName="numberOfProcedure_ID"           
--Ui parameter
local numberOfTotalSteps
local Existing_step_id
local numberOfProcedure
local procedureSkipWaitSS
local delayBetweenProcedureAndCondition
local baseName = "relativeBase"
local baseIndex= "relativeBaseIndex";
local getBaseDataIndex = "GetBaseDataIndex()";
local toolDataIndex = "Motion_toolDataIndex"

------------------local fuction for lua--------




local function XXXX(table_save)
    local datas={}
    local n=1

    if #file_read==0 then
        return {}
    end
    for data in file_read:gmatch('[^,%s]+') do
        datas[n]=data
        n=n+1
    end

    return datas
end
--------------------------------------------

if PTable:ContainsKey("Existing_step_id")==false then
    numberOfTotalSteps=0
else 
	Existing_step_id=FileReadToTableformate(PTable:get_Item("Existing_step_id"))
    numberOfTotalSteps=# Existing_step_id
end

if PTable:ContainsKey("Existing_step_id")==false then
    numberOfTotalSteps=0
else 
	Existing_step_id=FileReadToTableformate(PTable:get_Item("Existing_step_id"))
    numberOfTotalSteps=# Existing_step_id
end

if numberOfTotalSteps~=0 then

	ReturnData.sectionCode = ReturnData.sectionCode .. [[
		/*GC-Motion-2*/	

		BDAT_T ]]..baseName..[[;
        I32_T ]] .. baseIndex .. [[ = ]] .. getBaseDataIndex ..[[;		
        I32_T ]] .. toolDataIndex .. [[;
		I32_T Conditionflag;
	]]


	------------------------------------Set structure---------------------
	local tempTransformUsedInLua={}
	local tempJointUsedInLua={}
	local tempOffsetValueUsedInLua = {}
	local tempTargetType                                -- Transform/Joint
	for i=1,numberOfTotalSteps,1 do


		if(PTable:ContainsKey(pre_TargetTypeUIName..tostring(Existing_step_id[i]))) then
			tempTargetType=PTable:get_Item(pre_TargetTypeUIName..tostring(Existing_step_id[i]))
		else
			error("TargetType wasn't set before,can't find in Ptable")
			tempTargetType=0      --this should not happen
		end

		if tempTargetType==0 then    --transform
			if(PTable:ContainsKey(pre_TransformUIName..tostring(Existing_step_id[i]))) then
				load_values=PTable:get_Item(pre_TransformUIName..tostring(Existing_step_id[i]))
				n=1
				for value in load_values:gmatch('[^,%s]+') do
					tempTransformUsedInLua[n]=tonumber(value)
					n=n+1
				end 

				if(PTable:ContainsKey(pre_TransformUIName .. tostring(Existing_step_id[i]) .. "_offsetValues")) then
					load_values = PTable:get_Item(pre_TransformUIName .. tostring(Existing_step_id[i]) .. "_offsetValues")
					n = 1
					for value in load_values:gmatch('[^,%s]+') do
						tempOffsetValueUsedInLua[n] = value
						n = n + 1
					end 
				else
					tempOffsetValueUsedInLua[1] = 0
					tempOffsetValueUsedInLua[2] = 0
					tempOffsetValueUsedInLua[3] = 0
					tempOffsetValueUsedInLua[4] = 0
					tempOffsetValueUsedInLua[5] = 0
					tempOffsetValueUsedInLua[6] = 0
				end

	ReturnData.sectionCode = ReturnData.sectionCode .. [[
		CP_T Step_]] .. Existing_step_id[i] .. [[={]] .. string.format("%.3f",tempTransformUsedInLua[1]) .. [[+]] .. tempOffsetValueUsedInLua[1] .. [[,]] .. string.format("%.3f",tempTransformUsedInLua[2]) .. [[+]] .. tempOffsetValueUsedInLua[2] .. [[,]] .. string.format("%.3f",tempTransformUsedInLua[3]) .. [[+]] .. tempOffsetValueUsedInLua[3] .. [[,]] .. string.format("%.3f",tempTransformUsedInLua[4]) .. [[+]] .. tempOffsetValueUsedInLua[4] .. [[,]] .. string.format("%.3f",tempTransformUsedInLua[5]) .. [[+]] .. tempOffsetValueUsedInLua[5] .. [[,]] .. string.format("%.3f",tempTransformUsedInLua[6]) .. [[+]] .. tempOffsetValueUsedInLua[6] .. [[};
	]]
			end

			if(PTable:ContainsKey(pre_ARCTransformUIName..tostring(Existing_step_id[i]))) then
				load_values=PTable:get_Item(pre_ARCTransformUIName..tostring(Existing_step_id[i]))
				n=1
				for value in load_values:gmatch('[^,%s]+') do
					tempTransformUsedInLua[n]=tonumber(value)
					n=n+1
				end 

				if(PTable:ContainsKey(pre_ARCTransformUIName .. tostring(Existing_step_id[i]) .. "_offsetValues")) then
					load_values = PTable:get_Item(pre_ARCTransformUIName .. tostring(Existing_step_id[i]) .. "_offsetValues")
					n = 1
					for value in load_values:gmatch('[^,%s]+') do
						tempOffsetValueUsedInLua[n] = value
						n = n + 1
					end 
				else
					tempOffsetValueUsedInLua[1] = 0
					tempOffsetValueUsedInLua[2] = 0
					tempOffsetValueUsedInLua[3] = 0
					tempOffsetValueUsedInLua[4] = 0
					tempOffsetValueUsedInLua[5] = 0
					tempOffsetValueUsedInLua[6] = 0
				end

	ReturnData.sectionCode = ReturnData.sectionCode .. [[
		CP_T Step_]] .. Existing_step_id[i] .. [[_ARC={]] .. string.format("%.3f",tempTransformUsedInLua[1]) .. [[+]] .. tempOffsetValueUsedInLua[1] .. [[,]] .. string.format("%.3f",tempTransformUsedInLua[2]) .. [[+]] .. tempOffsetValueUsedInLua[2] .. [[,]] .. string.format("%.3f",tempTransformUsedInLua[3]) .. [[+]] .. tempOffsetValueUsedInLua[3] .. [[,]] .. string.format("%.3f",tempTransformUsedInLua[4]) .. [[+]] .. tempOffsetValueUsedInLua[4] .. [[,]] .. string.format("%.3f",tempTransformUsedInLua[5]) .. [[+]] .. tempOffsetValueUsedInLua[5] .. [[,]] .. string.format("%.3f",tempTransformUsedInLua[6]) .. [[+]] .. tempOffsetValueUsedInLua[6] .. [[};
	]]
			end

		elseif tempTargetType==1 then
			if(PTable:ContainsKey(pre_JointUIName..tostring(Existing_step_id[i]))) then
				load_values=PTable:get_Item(pre_JointUIName..tostring(Existing_step_id[i]))
				n=1
				for value in load_values:gmatch('[^,%s]+') do
					tempJointUsedInLua[n]=tonumber(value)
					n=n+1
				end 

			if(PTable:ContainsKey(pre_JointUIName .. tostring(Existing_step_id[i]) .. "_offsetValues")) then
				load_values = PTable:get_Item(pre_JointUIName .. tostring(Existing_step_id[i]) .. "_offsetValues")
				n = 1
				for value in load_values:gmatch('[^,%s]+') do
					tempOffsetValueUsedInLua[n] = value
					n = n + 1
				end 
			else
				tempOffsetValueUsedInLua[1] = 0
				tempOffsetValueUsedInLua[2] = 0
				tempOffsetValueUsedInLua[3] = 0
				tempOffsetValueUsedInLua[4] = 0
				tempOffsetValueUsedInLua[5] = 0
				tempOffsetValueUsedInLua[6] = 0
			end

	ReturnData.sectionCode = ReturnData.sectionCode .. [[
		AP_T Step_]] .. Existing_step_id[i] .. [[={]] .. string.format("%.3f",tempJointUsedInLua[1]) .. [[+]] .. tempOffsetValueUsedInLua[1] .. [[,]] .. string.format("%.3f",tempJointUsedInLua[2]) .. [[+]] .. tempOffsetValueUsedInLua[2] .. [[,]] .. string.format("%.3f",tempJointUsedInLua[3]) .. [[+]] .. tempOffsetValueUsedInLua[3] .. [[,]] .. string.format("%.3f",tempJointUsedInLua[4]) .. [[+]] .. tempOffsetValueUsedInLua[4] .. [[,]] .. string.format("%.3f",tempJointUsedInLua[5]) .. [[+]] .. tempOffsetValueUsedInLua[5] .. [[,]] .. string.format("%.3f",tempJointUsedInLua[6]) .. [[+]] .. tempOffsetValueUsedInLua[6] .. [[,0};
	]]


			end
		else
			error("Unknow TargetType")
		end

		if(PTable:ContainsKey(pre_TransformUIName..tostring(Existing_step_id[i]).."_pickPoint")) then
			load_values=PTable:get_Item(pre_TransformUIName..tostring(Existing_step_id[i]).."_pickPoint")
			n=1
			for value in load_values:gmatch('[^,%s]+') do
				tempTransformUsedInLua[n]=tonumber(value)
				n=n+1
			end 
		end

		if PTable:ContainsKey("List_ProcedureSelection_ReferenceVariableIdList_Step_" .. tostring(Existing_step_id[i])) and PTable:get_Item("List_ProcedureSelection_ReferenceVariableIdList_Step_" .. tostring(Existing_step_id[i])) ~= nil then
			local referenceVariableIdList = FileReadToTableformate(PTable:get_Item("List_ProcedureSelection_ReferenceVariableIdList_Step_" .. tostring(Existing_step_id[i])))
			ReturnData.sectionCode = ReturnData.sectionCode .. [[F64_T projectVariables_Step_]] .. tostring(Existing_step_id[i]) .. [[[]] .. tablelength(referenceVariableIdList) + 4 .. [[] = {]] .. PTable:get_Item('ProcessNumber') .. [[, 0, 0, ]] .. tostring(Existing_step_id[i])
			for index, obj in pairs(referenceVariableIdList) do
				ReturnData.sectionCode = ReturnData.sectionCode .. [[, ]] .. obj
			end
			ReturnData.sectionCode = ReturnData.sectionCode .. [[};
			]]
		end
	------------------------------------------robot code-------------------------------------------


	----------------------------------------------------------------------------------------------------------------------------------  
	end
end









