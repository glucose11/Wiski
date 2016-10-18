public class metadatademo {

     public static void createFlow() {

        MetadataService.MetadataPort service = MetadataServiceExamples.createService();

        // Create Flow
        MetadataService.Flow flow = new MetadataService.Flow();
        flow.fullName = 'NewFlow-1';
        flow.description = 'New Flow';
        flow.label = 'New Flow';
        flow.processType = 'Workflow';
        
        MetadataService.FlowActionCall actionCall = new MetadataService.FlowActionCall();
        actionCall.actionName = 'testAction';
        actionCall.actionType = 'apex';        
        flow.actionCalls = new List<MetadataService.FlowActionCall> { actionCall };
        
        MetadataService.FlowApexPluginCall apexPluginCall = new MetadataService.FlowApexPluginCall();
        apexPluginCall.apexClass = 'processbuilderdemo';
            MetadataService.FlowApexPluginCallInputParameter inputParam = new MetadataService.FlowApexPluginCallInputParameter();
            inputParam.name = 'kaId';            
        apexPluginCall.inputParameters = new List<MetadataService.FlowApexPluginCallInputParameter> { inputParam };
        flow.apexPluginCalls = new List<MetadataService.FlowApexPluginCall> { apexPluginCall };   
        
        MetadataService.FlowVariable flowvariable = new MetadataService.FlowVariable();
        flowvariable.dataType = 'sObject';
        flowvariable.isInput = true;
        flowvariable.objectType = 'Account';
        flow.variables = new List<MetadataService.FlowVariable> { flowvariable };  
        
        flow.startElementReference = 'myVariable_waitStartTimeAssignment';
        
        MetadataServiceExamples.handleSaveResults(service.createMetadata(new List<MetadataService.Metadata> { flow })[0]);
    }
}