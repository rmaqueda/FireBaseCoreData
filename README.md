
Un ejemplo de uso de múltiples contextos anidados en Core Data y de sincronización con [Firebase](https://www.firebase.com).

##Preparativos
**NO FUNCIONA EN SIMULADOR**. Usa la librería de música MediaPlayer para los ejemplos.

Para realizar estas pruebas es necesario crear una cuenta (gratuita) en FireBase y dar de alta una aplicación. Una vez creada la aplicación se usa su URL en la constante definida en el NetworkManayer (RMMNetworkManager.m):

```
static NSString *const firebaseURL = @"https://**your_app**.firebaseio.com/coreData";
```

Si solo quieres probar la parte de Core Data y multiples contestos pon a nil la URL:
```
static NSString *const firebaseURL = nil;
```

##Core Data

La clase RMMCoreDataStack, prepara un stack de Core Data con tres contextos anidados. 
Son los siguiente:

Contexto | Uso
------------- | -------------
rootMOC |Todas las operaciones CRUD a disco
mainMOC |Todas las operaciones relativas a UI
backgroundMOC |Todas las operaciones relativas a red

Están anidados y configurados de la siguiente forma:

Contexto | Tipo | Parent
------------- | ------------- | ------------- 
rootMOC  | NSPrivateQueueConcurrencyType | storeCoordinator
mainMOC  | NSMainQueueConcurrencyType | rootMOC
backgroundMOC | NSPrivateQueueConcurrencyType | mainMOC

Esta configuración permite que al salvar datos en un contexto estos datos se vuelcan automáticamente a su contexto definico como parent. Gracias a esto evitamos bloqueos en la interfaz gráfica cuando se realizan operaciones de red o de salvado a disco.

Contexto | Parent
------------- | -------------
backgroundMOC | mainMOC
mainMOC | rootMOC
rootMOC | storeCoordinator (disco)

La clase RMMNetworkManager usa el contexto backgroundMOC para las operaciones relativas a red con FireBase.

La clase RMMMasterViewController tiene una tabla y un fetchedResultsController que usa el contexto mainMOC, para la actulización de UI.

El contexto rootMOC se puede usar para gravar a disco la información cuando se quiera, esto persistirá la información, en este ejemplo no la he usado.

##Sincronización con FireBase

La clase RMMNetworkManager es una ejemplo de como sincronizar Core Data con el backend en tiempo real [Firebase](https://www.firebase.com).
 
Cualquier cambio realizado en el backend se refleja en tiempo real en Core Data.


Para Poder usarla es necesario crear una cuenta (gratuita) en FireBase y dar de alta una aplicación. Una vez dada de alta la aplicacion, se usa la URL de esta en la clase AppDelegate:

```
static NSString *const firebaseURL = @"https://your_app.firebaseio.com/coreData";
```
