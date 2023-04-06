@description('Required. The name of the parent Azure Data Factory.')
param dataFactoryName string

@description('Required. The ID of the storage account.')
param storageAccountId string

@description('Required. The name of the pipeline to execute.')
param PipelineName string

@description('Required. Container to monitor.')
param BlobContainerName string

@description('Required. Trigger name.')
param triggerName string

resource dataFactoryRef 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}

resource trigger 'Microsoft.DataFactory/factories/triggers@2018-06-01' =  {
  name: triggerName
  parent: dataFactoryRef
  properties: {
    annotations: []
    pipelines: [
      {
        pipelineReference: {
          referenceName: PipelineName
          type: 'PipelineReference'
        }
        parameters: {
          folderName: '@triggerBody().folderPath'
          fileName: '@triggerBody().fileName'
        }
      }
    ]
    type: 'BlobEventsTrigger'
    typeProperties: {
      blobPathBeginsWith: '/${BlobContainerName}/blobs/'
      blobPathEndsWith: '.csv'
      ignoreEmptyBlobs: true
      scope: storageAccountId
      events: [
        'Microsoft.Storage.BlobCreated'
      ]
    }
  }

}

@description('The name of the linked service.')
output name string = trigger.name

@description('The resource ID of the linked service.')
output resourceId string = trigger.id