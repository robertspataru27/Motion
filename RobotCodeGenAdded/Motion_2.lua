
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
local pre_JointUIName="Joint_StepRobotJoint_values_ID"
local pre_TrajectoryMotionTypeUIName="Dropdown_TrajectoryMotionType_values_ID"
local pre_SpeedMmUIName="Int_Input_SpeedMm_values_ID"
local pre_SpeedPercUIName="Int_Input_SpeedPerc_values_ID"
local pre_SpeedDegUIName="Int_Input_SpeedDeg_values_ID"
local pre_DegreeEnableUIName="CheckBox_DegreeEnable_values_ID"
local pre_ArcDegreeUIName="Float_Input_ArcDegree_values_ID"
local pre_BlendsEnableUIName="CheckBox_BlendsEnable_values_ID"
local pre_BlendsRadiusUIName="Float_Input_BlendsRadius_values_ID"
local pre_CollisionMarginUIName="Float_Input_CollisionMargin_values_ID"
local pre_StepSizeUIName="Float_Input_StepSize_values_ID"
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
local toolDataIndex = "Motion_toolDataIndex"
local getToolDataIndex = 'GetToolDataIndex()'

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

if PTable:ContainsKey("relativeBase")==false then
	relativeBase={0,0,0,0,0,0}
else
	relativeBase=FileReadToTableformate(PTable:get_Item("relativeBase"))
end



if numberOfTotalSteps~=0 then




	------------------------------------Set structure---------------------
	local tempTargetType                                -- Transform/Joint
	------------------------------------Motion and related parameters------------------------------------
	ReturnData.sectionCode = ReturnData.sectionCode .. [[
		]]..baseName..[[.TYPE=0;
		]]..baseName..[[.TRAN.X=]]..string.format("%.3f", relativeBase[1])..[[;
		]]..baseName..[[.TRAN.Y=]]..string.format("%.3f", relativeBase[2])..[[;
		]]..baseName..[[.TRAN.Z=]]..string.format("%.3f", relativeBase[3])..[[;
		]]..baseName..[[.TRAN.A=]]..string.format("%.3f", relativeBase[4])..[[;
		]]..baseName..[[.TRAN.B=]]..string.format("%.3f", relativeBase[5])..[[;
		]]..baseName..[[.TRAN.C=]]..string.format("%.3f", relativeBase[6])..[[;
		]]..baseName..[[.REF_BASE=-1;
		//WaitSS();
		BDAT(]].. baseIndex ..[[, ]] .. baseName ..[[);   
	]]

	local tempMotionTypeUsedInLua
	local motionType
	local motionTypeDefault={'FREE','PTP','LIN', 'ARC'}
	local motionTypeJointDefault={'FREE','PTP'}
	local speedSet
	local blendsEnable
	local blendsRadius
	local numberOfConditions
	local conditinString0
	local conditinString1
	local previous_selectedToolNumber=-1
	local previous_selectedTcpNumber=-1
	-- local tempStepEnable
	local CollisionMarginString
	local StepSizeString

	for i=1,numberOfTotalSteps,1 do
		-- tempStepEnable=PTable:get_Item("stepEnableID"..tostring(Existing_step_id[i]))
		if(PTable:ContainsKey(pre_TargetTypeUIName..tostring(Existing_step_id[i]))) then
			tempTargetType=PTable:get_Item(pre_TargetTypeUIName..tostring(Existing_step_id[i]))
		else
			error("TargetType wasn't set before,can't find in Ptable")
			tempTargetType=0      --this should not happen
		end
		if tempTargetType==1 then
			motionType = motionTypeJointDefault
		else
			motionType = motionTypeDefault
		end
		-- if (tempStepEnable==true) then

			if PTable:ContainsKey(pre_projectToolSelectedName..tostring(Existing_step_id[i])) then
				selectedToolNumber=PTable:get_Item(pre_projectToolSelectedName..tostring(Existing_step_id[i]))
			else
				error("No tool selected in Ptable")
			end
			if PTable:ContainsKey(pre_projectTcpSelectedName..tostring(Existing_step_id[i])) then
				selectedTcpNumber=PTable:get_Item(pre_projectTcpSelectedName..tostring(Existing_step_id[i]))
			else
				error("No tcp selected in Ptable")
			end
			--design whether it's needed to declare tool again(TDAT). If it's the same tool that declare isn't needed.
			if (selectedToolNumber~=previous_selectedToolNumber) or (selectedTcpNumber~=previous_selectedTcpNumber) then
			ReturnData.sectionCode = ReturnData.sectionCode .. [[
			//WaitSS();]]..'\n'..
            toolDataIndex..[[ = ]]..getToolDataIndex..[[;]]..[[
			TDAT(]] .. toolDataIndex .. [[, ]] .. bot.name .. '.' ..'Tool'.. tostring(selectedToolNumber) .. '_tcp' .. tostring(selectedTcpNumber) .. '.Tool_TCP'..[[);
			]]
				previous_selectedToolNumber=selectedToolNumber
				previous_selectedTcpNumber=selectedTcpNumber
			end



			if PTable:ContainsKey(pre_TrajectoryMotionTypeUIName..tostring(Existing_step_id[i]))  then
				tempMotionTypeUsedInLua=tonumber(PTable:get_Item(pre_TrajectoryMotionTypeUIName..tostring(Existing_step_id[i])))+1  --transform from Ptable index to LUA

			else
				tempMotionTypeUsedInLua=1 --default value
			end

			-- if tempTargetType==1 then 
			-- 	tempMotionTypeUsedInLua=2  --shift to motionType because it is always  PTP
			-- end
			-- if motionType[tempMotionTypeUsedInLua]=="ARC" then
			-- 	error("motionType[tempMotionTypeUsedInLua]==ARC")
			-- end
			if motionType[tempMotionTypeUsedInLua]=="FREE" or motionType[tempMotionTypeUsedInLua]=="PTP" then    --Free or PTP ,which require speed in %

				if(PTable:ContainsKey(pre_SpeedPercUIName..tostring(Existing_step_id[i]))) then
					speedSet=PTable:get_Item(pre_SpeedPercUIName..tostring(Existing_step_id[i]))
				else
					speedSet=0 --default value
				end

				if motionType[tempMotionTypeUsedInLua]=="FREE" then
					if(PTable:ContainsKey(pre_CollisionMarginUIName..tostring(Existing_step_id[i]))) then
						CollisionMarginString=tostring(PTable:get_Item(pre_CollisionMarginUIName..tostring(Existing_step_id[i])))
					else
						CollisionMarginString="20" --default value
					end
					if(PTable:ContainsKey(pre_StepSizeUIName..tostring(Existing_step_id[i]))) then
						StepSizeString=tostring(PTable:get_Item(pre_StepSizeUIName..tostring(Existing_step_id[i])))
					else
						StepSizeString="10" --default value
					end
				end

			else

				if(PTable:ContainsKey(pre_SpeedMmUIName..tostring(Existing_step_id[i]))) then     --LIN
					speedSet=PTable:get_Item(pre_SpeedMmUIName..tostring(Existing_step_id[i]))
				else
					speedSet=0 --default value
				end

				if motionType[tempMotionTypeUsedInLua]=="ARC" then
					if (PTable:ContainsKey(pre_SpeedDegUIName..tostring(Existing_step_id[i]))) then
						SpeedDeg=PTable:get_Item(pre_SpeedDegUIName..tostring(Existing_step_id[i]))
					else
						SpeedDeg=0
					end
					if (PTable:get_Item(pre_DegreeEnableUIName..tostring(Existing_step_id[i]))==true) then
						ArcDegree=PTable:get_Item(pre_ArcDegreeUIName..tostring(Existing_step_id[i]))
					else
						ArcDegree=0
					end
				end

			end

			if PTable:ContainsKey(pre_BlendsEnableUIName..tostring(Existing_step_id[i])) then
				blendsEnable = PTable:get_Item(pre_BlendsEnableUIName..tostring(Existing_step_id[i]))
				if blendsEnable and PTable:ContainsKey(pre_BlendsRadiusUIName..tostring(Existing_step_id[i])) then
					blendsRadius=PTable:get_Item(pre_BlendsRadiusUIName..tostring(Existing_step_id[i]))
				else
					blendsRadius=0
				end
			else
				blendsEnable = false
				blendsRadius=0
			end

			if (PTable:ContainsKey(pre_NumberOfConditionsName..tostring(Existing_step_id[i]))) then
				numberOfConditions=PTable:get_Item(pre_NumberOfConditionsName..tostring(Existing_step_id[i]))

			else
				numberOfConditions=0
			end
			if PTable:ContainsKey(pre_numberOfProcedureName..tostring(Existing_step_id[i])) then
				numberOfProcedure=PTable:get_Item(pre_numberOfProcedureName..tostring(Existing_step_id[i]))
			else
				numberOfProcedure=0
			end

		------------------------------------------robot code-------------------------------------------

			if motionType[tempMotionTypeUsedInLua]=="FREE" then                       --Free

				if tempTargetType == 1 then
					ReturnData.sectionCode = ReturnData.sectionCode .. [[
		WaitUntilNotify();
		UpdScene(nSceneDirDepth, nSceneDirNameArr);
		]]..motionType[tempMotionTypeUsedInLua]..[[A(Step_]]..Existing_step_id[i]..[[,]]..speedSet..[[,]]..toolDataIndex..[[,]]..baseIndex..[[,]]..string.format("%d",blendsRadius)..[[,"CONT",]]..CollisionMarginString..[[,]]..StepSizeString..[[);
]]
				else
					ReturnData.sectionCode = ReturnData.sectionCode .. [[
		WaitUntilNotify();
		UpdScene(nSceneDirDepth, nSceneDirNameArr);
		]]..motionType[tempMotionTypeUsedInLua]..[[(Step_]]..Existing_step_id[i]..[[,]]..speedSet..[[,]]..toolDataIndex..[[,]]..baseIndex..[[,]]..string.format("%d",blendsRadius)..[[,"CONT",]]..CollisionMarginString..[[,]]..StepSizeString..[[);
]]
				end

			elseif motionType[tempMotionTypeUsedInLua]=="PTP" then                  --PTP

				ReturnData.sectionCode = ReturnData.sectionCode .. [[
					
				
				
				]]..motionType[tempMotionTypeUsedInLua]..[[(Step_]]..Existing_step_id[i]..[[,VP=]]..speedSet..[[,TL=]]..toolDataIndex..[[,BS=]]..baseIndex
				if blendsEnable then
					ReturnData.sectionCode = ReturnData.sectionCode
					..[[,Z=]]..string.format("%d",blendsRadius)
				else
                    ReturnData.sectionCode = ReturnData.sectionCode
                    .. [[, INP]]
				end
				if numberOfConditions > 0 or numberOfProcedure > 0 then
					ReturnData.sectionCode = ReturnData.sectionCode
					..[[);
]]
				else
					ReturnData.sectionCode = ReturnData.sectionCode
					..[[,CONT);
]]
				end

			elseif motionType[tempMotionTypeUsedInLua]=="LIN" then                        --LIN
				ReturnData.sectionCode = ReturnData.sectionCode .. [[
				
				
				
				]]..motionType[tempMotionTypeUsedInLua]..[[(Step_]]..Existing_step_id[i]..[[,V=]]..speedSet..[[,TL=]]..toolDataIndex..[[,BS=]]..baseIndex
				if blendsEnable then
					ReturnData.sectionCode = ReturnData.sectionCode
					..[[,Z=]]..string.format("%d",blendsRadius)
				else
                    ReturnData.sectionCode = ReturnData.sectionCode
                    .. [[, INP]]
				end
				if numberOfConditions > 0 or numberOfProcedure > 0 then
					ReturnData.sectionCode = ReturnData.sectionCode
					..[[);
]]
				else
					ReturnData.sectionCode = ReturnData.sectionCode
					..[[,CONT);
]]
				end
			elseif motionType[tempMotionTypeUsedInLua]=="ARC" then                        --ARC
				ReturnData.sectionCode = ReturnData.sectionCode .. [[
				
				
				
				]]..motionType[tempMotionTypeUsedInLua]..[[(Step_]]..Existing_step_id[i]..[[_ARC, Step_]]..Existing_step_id[i]..[[,ANG=]]..ArcDegree..[[,V=]]..speedSet..[[,OV=]]..SpeedDeg..[[,TL=]]..toolDataIndex..[[,BS=]]..baseIndex
				if blendsEnable then
					ReturnData.sectionCode = ReturnData.sectionCode
					..[[,Z=]]..string.format("%d",blendsRadius)
				else
                    ReturnData.sectionCode = ReturnData.sectionCode
                    .. [[, INP]]
				end
				if numberOfConditions > 0 or numberOfProcedure > 0 then
					ReturnData.sectionCode = ReturnData.sectionCode
					..[[);
]]
				else
					ReturnData.sectionCode = ReturnData.sectionCode
					..[[,CONT);
]]
				end
			end

			--------------------------------------------------------------------------------------------------




			for procedureIndex=0,numberOfProcedure-1,1 do                         --list based on procedure

				procedureString0=PTable:get_Item(pre_procedureRobotCode0Name..tostring(Existing_step_id[i])..'_'..tostring(procedureIndex))
				procedureString1=PTable:get_Item(pre_procedureRobotCode1Name..tostring(Existing_step_id[i])..'_'..tostring(procedureIndex))

				if PTable:ContainsKey(procedureSkipWaitSSName..tostring(Existing_step_id[i])..'_'..tostring(procedureIndex))==true then
					procedureSkipWaitSS=PTable:get_Item(procedureSkipWaitSSName..tostring(Existing_step_id[i])..'_'..tostring(procedureIndex))
				else
					procedureSkipWaitSS=false
				end

		------------------------------------------robot code-------------------------------------------
				if procedureSkipWaitSS==false then
					ReturnData.sectionCode = ReturnData.sectionCode ..[[
						WaitSS();

						]]
				end
								
				ReturnData.sectionCode = ReturnData.sectionCode ..[[
				]]..procedureString0..[[
				]]..procedureString1..[[
				]]
			end
			if PTable:ContainsKey("List_ProcedureSelection_ReferenceVariableIdList_Step_" .. tostring(Existing_step_id[i])) and PTable:get_Item("List_ProcedureSelection_ReferenceVariableIdList_Step_" .. tostring(Existing_step_id[i])) ~= nil then
				local referenceVariableIdList = FileReadToTableformate(PTable:get_Item("List_ProcedureSelection_ReferenceVariableIdList_Step_" .. tostring(Existing_step_id[i])))
				ReturnData.sectionCode = ReturnData.sectionCode .. [[UpdProjectVariable_StringTcp(]] .. tablelength(referenceVariableIdList) + 4 .. [[, projectVariables_Step_]] ..  tostring(Existing_step_id[i]) .. [[);
				]]
			end
		--------------------------------------------------------------------------------------------------
		if PTable:ContainsKey(pre_DelayTimeUIName..tostring(Existing_step_id[i])) then
			delayBetweenProcedureAndCondition=PTable:get_Item(pre_DelayTimeUIName..tostring(Existing_step_id[i]))
			if (tonumber(delayBetweenProcedureAndCondition) > 0) then
				ReturnData.sectionCode = ReturnData.sectionCode ..[[
	WaitSS();
	WAIT( ]] .. delayBetweenProcedureAndCondition .. [[ );
	]]
			end
		end
			--------------------------------------------------------------------------------------------------

		if numberOfConditions > 0 then
			ReturnData.sectionCode = ReturnData.sectionCode .. [[
WaitSS();
Conditionflag = 0;
while(Conditionflag == 0)
{
]]
				for conditionIndex = 0, numberOfConditions - 1, 1 do
					conditionString0 = PTable:get_Item(pre_RobotCode0Name..tostring(Existing_step_id[i])..'_'..tostring(conditionIndex))
                	conditionString1 = PTable:get_Item(pre_RobotCode1Name..tostring(Existing_step_id[i])..'_'..tostring(conditionIndex))


                	ReturnData.sectionCode = ReturnData.sectionCode ..
                [[    ]] .. conditionString0 .. [[

	WAIT(10);
    if(Conditionflag != 2){
        if(]]
                ReturnData.sectionCode = ReturnData.sectionCode ..
                conditionString1 .. [[)
        {
            Conditionflag = 1;
        }
        else
        {
            Conditionflag = 2;
        }
    }
]]
				end
			ReturnData.sectionCode = ReturnData.sectionCode .. [[
	if(Conditionflag == 2){
        Conditionflag = 0;
    }
}
]]
		end

		-- end



	end
end









