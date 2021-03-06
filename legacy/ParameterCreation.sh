
#!/bin/ksh
#set -vx
echo $AppName
printf "stream=\"$stream\"" > /tmp/$AppName-Config.properties
printf "\nAppName=\"$AppName\"" >> /tmp/$AppName-Config.properties
printf "\ncomponent=\"$component\"" >> /tmp/$AppName-Config.properties
printf "\nucdApplicationName=\"$ucdApplicationName\"" >> /tmp/$AppName-Config.properties
printf "\nucdComponentName=\"$ucdComponentName\"" >> /tmp/$AppName-Config.properties
printf "\nassetname=\"$assetname\"" >> /tmp/$AppName-Config.properties
printf "\nprojectLocation=\"$projectLocation\"" >> /tmp/$AppName-Config.properties
printf "\nBuildPath=\"$BuildPath\"" >> /tmp/$AppName-Config.properties
printf "\nUCD_Component=\"$UCD_Component\"" >> /tmp/$AppName-Config.properties
printf "\nBase_Artifact_Directory=\"$Base_Artifact_Directory\"" >> /tmp/$AppName-Config.properties
printf "\nearFileName=\"$earFileName\"" >> /tmp/$AppName-Config.properties
printf "\nlogFileName=\"POM.log\"" >> /tmp/$AppName-Config.properties
printf "\nregion=\"national\"" >> /tmp/$AppName-Config.properties
printf "\nisRamPublish=\"YES\"" >> /tmp/$AppName-Config.properties
printf "\nearFileCopyTo=\"/apps/build/EAR-KPCC\"" >> /tmp/$AppName-Config.properties
printf "\nramcategory=\"Kaiser NW\"" >> /tmp/$AppName-Config.properties
printf "\nisFileRename=\"1\"" >> /tmp/$AppName-Config.properties
printf "\nJunitlogFileName=\"$AppName-$BUILD_NUMBER-Junitlog.log\"" >> /tmp/$AppName-Config.properties
printf "\nBuildlogFileName=\"$AppName-$BUILD_NUMBER-BuildLog.log\"" >> /tmp/$AppName-Config.properties
printf "\nSonarlogFileName=\"$AppName-$BUILD_NUMBER-SonarLog.log\"" >> /tmp/$AppName-Config.properties
printf "\npword=\"+rAd3fU+WuHe\"" >> /tmp/$AppName-Config.properties
printf "\nuser=\"rational.jazz.builduser.Tapestry\"" >> /tmp/$AppName-Config.properties
printf "\nearTargetLocation=\"$earTargetLocation\"" >> /tmp/$AppName-Config.properties
printf "\nCodeType=\"Java\"" >> /tmp/$AppName-Config.properties
printf "\nUC=\"$UC\"" >> /tmp/$AppName-Config.properties
printf "\nUCD_DA=\"$UCD_DA\"" >> /tmp/$AppName-Config.properties
printf "\nUCD_DE=\"$UCD_DE\"" >> /tmp/$AppName-Config.properties
printf "\nUCD_Process=\"$UCD_Process\"" >> /tmp/$AppName-Config.properties
if [[ $AppName = "Claim_Inventory" ]]; then
	printf "\nProjectID=\"org.kpcc.kbsql.extract:kbsql-ci-extract\"" >> /tmp/$AppName-Config.properties
elif [[ $AppName = "Support_Console" ]]; then
	printf "\nProjectID=\"org.kp:kpccui\"" >> /tmp/$AppName-Config.properties
elif [[ $AppName = "PDF_Utility" ]]; then
	printf "\nProjectID=\"org.kp.pdfutility:PDFConsumerUtility\"" >> /tmp/$AppName-Config.properties
elif [[ $AppName = "OCI_CAQHUpdate" ]]; then
	printf "\nProjectID=\"org.kp.svc.ocivalidatorws:OCIValidatorWS\"" >> /tmp/$AppName-Config.properties
elif [[ $AppName = "Common_Extract" ]]; then
	printf "\nProjectID=\"org.kpcc.kbsql.extract:kbsql-extract-estate\"" >> /tmp/$AppName-Config.properties
elif [[ $AppName = "Accums_CompositeService" ]]; then
	printf "\nProjectID=\"org.kpcc.ws.interfaces.accums:AccumsCompositeService\"" >> /tmp/$AppName-Config.properties
elif [[ $AppName = "Accums" ]]; then
	printf "\nProjectID=\"org.kp.interfaces.accums:Accumulations\"" >> /tmp/$AppName-Config.properties
elif [[ $AppName = "OCI_837ClaimValidator" ]]; then
	printf "\nProjectID=\"org.kp.svc.ocivalidator:OCI837ClaimValidator\"" >> /tmp/$AppName-Config.properties
elif [[ $AppName = "accumulations-outbound-delta" ]]; then
	printf "\nProjectID=\"org.kp.accums.out:Accumulations-Outbound\"" >> /tmp/$AppName-Config.properties
elif [[ $AppName = "accumulations-outbound-cmk" ]]; then
	printf "\nProjectID=\"org.kp.accums.out:Accumulations-Outbound\"" >> /tmp/$AppName-Config.properties
elif [[ $AppName = "accumulations-outbound-mi" ]]; then
	printf "\nProjectID=\"org.kp.accums.out:Accumulations-Outbound\"" >> /tmp/$AppName-Config.properties
elif [[ $AppName = "OCI_Revalidator_UI" ]]; then
	printf "\nProjectID=\"org.kp.svc.ocivalidator:ociuirevalidator\"" >> /tmp/$AppName-Config.properties
elif [[ $AppName = "OCI_DataMiningValidator" ]]; then
	printf "\nProjectID=\"org.kp.svc.ocivalidator:OCIDataMiningValidator\"" >> /tmp/$AppName-Config.properties
elif [[ $AppName = "OCI_CommonComponent" ]]; then
	printf "\nProjectID=\"org.kp.svc.oci.ocicommoncomponent:OCICommonComponent\"" >> /tmp/$AppName-Config.properties
elif [[ $AppName = "OCI_CommonWS" ]]; then
	printf "\nProjectID=\"org.kp.svc.oci.ocicommonwsjar:OCICommonWSJar\"" >> /tmp/$AppName-Config.properties
elif [[ $AppName = "DASP" ]]; then
	printf "\nProjectID=\"org.kp.dasp:DASP\"" >> /tmp/$AppName-Config.properties
elif [[ $AppName = "Incident_Utility" ]]; then
        printf "\nProjectID=\"org.kp.incident:Incident-Client\"" >> /tmp/$AppName-Config.properties
elif [[ $AppName = "Print_Consolidator" ]]; then
        printf "\nProjectID=\"org.kpcc.interfaces:PrintConsolidator\"" >> /tmp/$AppName-Config.properties
fi
echo $ProjectID
