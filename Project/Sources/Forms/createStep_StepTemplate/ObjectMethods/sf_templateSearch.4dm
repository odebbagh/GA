Case of 
	: (FORM Event:C1606.code=-2000)
		//TRACE
		OBJECT SET VISIBLE:C603(*; "sf_templateSearch"; False:C215)
		
		If (Form:C1466.sf_templateSearch.selectedItem#Null:C1517)
			Form:C1466.searchTemplate:=Form:C1466.sf_templateSearch.selectedItem.name
			
			Form:C1466.lotStep.tools:=New object:C1471("items"; New collection:C1472())
			Form:C1466.lotStep.skills:=New object:C1471("items"; New collection:C1472())
			Form:C1466.lotStep.requitedCertifications:=New object:C1471("items"; New collection:C1472())
			
			$stepTemplateTools:=ds:C1482.StepTemplateTool.query("UUID_StepTemplate = :1"; Form:C1466.sf_templateSearch.selectedItem.UUID)
			
			For each ($tool; $stepTemplateTools)
				Form:C1466.lotStep.tools.items.push(New object:C1471(\
					"UUID"; $tool.toolType.UUID; \
					"order"; $tool.order; \
					"name"; $tool.toolType.name; \
					"date"; $tool.toolType.date; \
					"tool"; New object:C1471("UUID"; ""; "name"; ""; "date"; "")\
					))
			End for each 
			
			$stepTemplateSkills:=ds:C1482.StepTemplateCertification.query("UUID_StepTemplate = :1"; Form:C1466.sf_templateSearch.selectedItem.UUID)
			
			For each ($skill; $stepTemplateSkills)
				Form:C1466.lotStep.skills.items.push(New object:C1471(\
					"UUID"; $skill.certification.UUID; \
					"name"; $skill.certification.name; \
					"ref"; $skill.certification.ref\
					))
			End for each 
			
			For each ($st_certification; Form:C1466.sf_templateSearch.selectedItem.stepTemplateCertifications)
				Form:C1466.lotStep.requitedCertifications.items.push(New object:C1471(\
					"UUID_Certification"; $st_certification.certification.UUID; \
					"name"; $st_certification.certification.name\
					))
			End for each 
			
			Form:C1466.lotStep.commentFormat1:=Form:C1466.sf_templateSearch.selectedItem.comment1
			Form:C1466.lotStep.commentFormat2:=Form:C1466.sf_templateSearch.selectedItem.comment2
			Form:C1466.lotStep.dataTables:=Form:C1466.sf_templateSearch.selectedItem.dataTables
			Form:C1466.lotStep.parametricMeasurements:=Form:C1466.sf_templateSearch.selectedItem.parametricMeasurements
			Form:C1466.lotStep.bins:=Form:C1466.sf_templateSearch.selectedItem.bins

			If (Form:C1466.lotStep.dataTables#Null:C1517) && (Form:C1466.lotStep.dataTables.items#Null:C1517) && (Form:C1466.lotStep.dataTables.items.length>0)
				$dataTable:=New object:C1471()
				For each ($dtCol; Form:C1466.lotStep.dataTables.items.orderBy("order asc"))
					$dataTable[$dtCol.key]:=New collection:C1472()
				End for each
				Form:C1466.lotStep.dataTable:=$dataTable
			End if
		End if 
		
	: (FORM Event:C1606.code=-3000)
		OBJECT SET VISIBLE:C603(*; "sf_templateSearch"; False:C215)
		OBJECT SET SUBFORM:C1138(*; "sf_templateSearch"; "")
End case 