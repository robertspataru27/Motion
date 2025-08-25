--Main function:

(1) Provide Robot code for auto-generation based on data in PTable ,written in FBC Menu/sub/page....

(2) Motion function allow user set up desired target point with either transform or joint




--Structure:

All files(Motion_0~Motion_1) would be parsed in to robot code in specific location in whole program(Not in order).

----Session structue defined in whole program:

'''''''''''''''''''''''''''''''''''''''''''
#Motion_5: BuildInVariable
#Motion_0: StructureScript
void main()
{
RobotStructure
  #Motion_1: PredefinedVariable
IO
  #Motion_4: BeforeInit
Init
  #Motion_6: AfterInit
while(1){

  #Motion_2: Main Script
}
}
  #Motion_3: PredefindedFuctionScript
''''''''''''''''''''''''''''''''''''''''''''

----Session content
Motion_2: Main Implementation of Motion block:
# All data would get from PTable set in FBC menu

# According to selection of User setting in UI, different robot code would be generated

# All step would interated by lua and generate TPUI code


# PreName are defined first in order to concate ID conveniently


----Interface used in the block:
(1)CS.ConfigurationMenu.ConfigurationMenuLuaInterface.Instance
(2)CS.Mantis.RobotCodeGeneration.BlockLuaInterface.thisFlowBlock.pTable
(3)CS.Mantis.RobotCodeGeneration.BlockLuaInterface.thisWorkpieces
(4)CS.Mantis.RobotCodeGeneration.BlockLuaInterface.thisWorkforces





